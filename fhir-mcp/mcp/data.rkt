#lang racket/base

;;; data.rkt — the workspace's data as the hub reads it whole, holds a resource to the workspace's
;;; rules, and writes the trail beside it.

(require racket/match (only-in fhir/registry registered-by) (only-in fhir/data-source data-source-read) racket/list json fhir/lang/workspace (only-in fhir/data-source data-source-all bundle-resources)
         (only-in fhir/rest-data-source rest-url?) (only-in db sqlite3-connect query-list disconnect)
         (only-in fhir/operation apply-operation exn:fail:operation?) "artifacts.rkt" "trail.rkt" "hub.rkt")

;; For the verbs' modules (workspace.rkt is the contracted interface).
(provide data-resources all-data stored-artifact with-manifest with-profiles validation-errors validation-issues
         write-trail! audited now-instant new-id)

;; ---- the data, read whole ----------------------------------------------------------------------
;; data-resources : hub -> (listof jsexpr)   every resource of the data when it is files (a
;; directory's JSON files, or the one file), Bundles as they are
(define (data-resources h)
  (define d (ws-config-data (workspace-config (hub-ws h))))
  (define p (and d (not (rest-url? d)) (simplify-path (path->complete-path d (hub-root h)))))
  (define (read-one f) (with-handlers ([exn:fail? (lambda (_) #f)]) (call-with-input-file f read-json)))
  (cond [(and p (directory-exists? p))
         (for*/list ([f (in-directory p)] #:when (regexp-match? #rx"[.]json$" (path->string f))
                     [js (in-value (read-one f))] #:when (and (hash? js) (string? (hash-ref js 'resourceType #f))))
           js)]
        [(and p (file-exists? p)) (let ([js (read-one p)]) (if (hash? js) (list js) '()))]
        [else '()]))

;; all-data : hub -> (listof resource)   every resource the data holds (a store's current versions,
;; a directory's files); a FHIR server is not read whole
(define (all-data h)
  (define p (data-store-path h))
  (cond
    [p (define c (sqlite3-connect #:database p #:mode 'read-only))
       (begin0 (map string->jsexpr (query-list c "SELECT json(resource) FROM fhir_resources ORDER BY resource_type, id"))
               (disconnect c))]
    [else (append-map bundle-resources (data-resources h))]))

;; stored-artifact : hub canonical -> artifact | #f   a stored artifact by its url: the version a
;; `|version` names, else the current one of its stored versions (artifacts.rkt `current-versions`)
(define (stored-artifact h ref)
  (define parts (regexp-split #rx"[|]" ref))
  (define url (car parts))
  (define version (and (pair? (cdr parts)) (not (string=? (cadr parts) "")) (cadr parts)))
  (for/or ([type (in-list artifact-types)])
    (define mine (filter (lambda (r) (equal? (hash-ref r 'url #f) url)) ((data-source-all (hub-data h)) type)))
    (cond [(null? mine) #f]
          [version (findf (lambda (r) (equal? (hash-ref r 'version #f) version)) mine)]
          [else (car (versions-in-force (hub-manifest h) mine))])))

;; manifest-argument : hub any -> manifest | #f   the pins a call names (`manifest=`): a Parameters
;; resource as JSON (an object, or its text: `manifest=@pins.json`), or `Parameters/<id>` — one
;; the workspace defines, else a stored one
(define (manifest-argument h v)
  (define (parameters? x) (and (hash? x) (equal? (hash-ref x 'resourceType #f) "Parameters")))
  (define (refuse) (error 'manifest "a manifest is a Parameters resource of pinned versions: its JSON (manifest=@pins.json), or Parameters/<id> as the workspace defines or stores it"))
  (match v
    [(or #f 'null) #f]
    [(? parameters?) v]
    [(pregexp #px"^Parameters/([A-Za-z0-9.-]+)$" (list _ id))
     (or (findf (lambda (r) (and (parameters? r) (equal? (hash-ref r 'id #f) id)))
                (registered-by (lambda (source) (and (pair? source) (eq? (car source) 'workspace)))))
         ((data-source-read (hub-data h)) "Parameters" id)
         (error 'manifest (format "no ~a in the workspace or the data" v)))]
    [(? string?) (let ([js (with-handlers ([exn:fail? (lambda (_) #f)]) (string->jsexpr v))]) (if (parameters? js) js (refuse)))]
    [_ (refuse)]))

;; with-manifest : hub any thunk -> value   the call made under the pins it names, when it names any
(define (with-manifest h v thunk)
  (define manifest (manifest-argument h v))
  (if manifest (parameterize ([current-manifest manifest]) (thunk)) (thunk)))

;; ---- a resource held to the workspace's rules --------------------------------------------------
;; with-profiles : hub resource -> resource   the workspace's profiles for its type (workspace.yaml
;; `profiles`) claimed in meta.profile, so validation holds it to them and the data says so
(define (with-profiles h r)
  (define urls (hash-ref (ws-config-profiles (workspace-config (hub-ws h))) (hash-ref r 'resourceType "") '()))
  (cond
    [(null? urls) r]
    [else
     (define meta (let ([m (hash-ref r 'meta #f)]) (if (hash? m) m (hasheq))))
     (define claimed (let ([p (hash-ref meta 'profile '())]) (if (list? p) p '())))
     (hash-set r 'meta (hash-set meta 'profile (append claimed (filter (lambda (u) (not (member u claimed))) urls))))]))

(define (validation-errors r) (validation-issues r '("error" "fatal")))
;; validation-issues : resource severities -> (listof string)   "path: message" for each issue of those
;; severities (a stage's warnings: a unit that is not UCUM, said without refusing the change)
(define (validation-issues r severities #:profile [profile #f])
  (with-handlers ([exn:fail:operation? (lambda (e) (if (member "error" severities) (list (format "~a" (exn-message e))) '()))]
                  [exn:fail? (lambda (_) '())])
    (for/list ([i (in-list (hash-ref (if profile (apply-operation "$validate" r #:profile profile) (apply-operation "$validate" r)) 'issue '()))]
               #:when (member (hash-ref i 'severity #f) severities))
      (format "~a: ~a" (let ([e (hash-ref i 'expression (hash-ref i 'location '()))]) (if (pair? e) (car e) "")) (hash-ref i 'diagnostics (hash-ref i 'code ""))))))

;; ---- the trail, written where the data is ------------------------------------------------------
;; write-trail! : hub (listof resource) -> (listof "Type/id")   the trail written where the data is
(define (write-trail! h resources)
  (define c (workspace-config (hub-ws h)))
  (define d (ws-config-data c))
  (with-handlers ([exn:fail? (lambda (e) (log-warning "fhir-mcp: the trail was not written: ~a" (exn-message e)) '())])
    (cond
      [(store-file? d)
       (define-values (store catalog) (open-store (data-store-path h) (hub-packages h)))
       (define create! (dynamic-require 'fhir/store/fhir-engine 'fhir-create!))
       (for/list ([r (in-list resources)])
         (define-values (t id _v) (create! store r #:search-params catalog))
         (format "~a/~a" t id))]
      [(rest-url? d) '()]                                  ; a server keeps its own audit trail
      [(and d (directory-exists? (simplify-path (path->complete-path d (hub-root h)))))
       (for/list ([r (in-list resources)])
         (define id (new-id))
         (call-with-output-file (build-path (simplify-path (path->complete-path d (hub-root h))) (format "~a-~a.json" (hash-ref r 'resourceType) id))
           (lambda (o) (write-json (hash-set r 'id id) o)) #:exists 'error)
         (format "~a/~a" (hash-ref r 'resourceType) id))]
      [else '()])))

;; audited : hub what Source thunk -> value   with `audit: all`, the execution leaves an AuditEvent
;; in the data (its outcome, its source text), whether it succeeds or fails
(define (audited h what src thunk)
  (define c (workspace-config (hub-ws h)))
  (define (record! outcome)
    (write-trail! h (list (execution-audit (ws-config-fhir-version c) what src outcome (unbox current-agent) (now-instant)))))
  (cond
    [(not (equal? (ws-config-audit c) "all")) (thunk)]
    [else (with-handlers ([exn:fail? (lambda (e) (record! (exn-message e)) (raise e))])
            (begin0 (thunk) (record! #t)))]))

(define (now-instant)
  (define d (seconds->date (current-seconds) #f))
  (format "~a-~a-~aT~a:~a:~aZ" (date-year d) (pad (date-month d)) (pad (date-day d)) (pad (date-hour d)) (pad (date-minute d)) (pad (date-second d))))
(define (pad n) (if (< n 10) (format "0~a" n) (number->string n)))
(define (new-id) (format "ws-~a-~a" (current-seconds) (random 1000000)))
