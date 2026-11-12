#lang racket/base

;;; check.rkt — the verbs write and check: a file of the workspace written (its problems in the same
;;; answer), and what the files and the data hold, checked.

(require racket/list racket/string racket/file racket/path fhir/lang/workspace
         (only-in fhir/registry registered-resources) "hub.rkt" "data.rkt")

;; Contracted in workspace.rkt.
(provide hub-write! hub-check)

;; ---- write -------------------------------------------------------------------------------------
(define (hub-write! h p text #:enforce? [enforce? #f] #:from [from #f])
  (define full (inside h p))
  (define config? (equal? (path->string (file-name-from-path full)) "workspace.yaml"))
  (define lang (workspace-language-of full))
  ;; the workspace's implementation guide states its canonical, FHIR version, packages and
  ;; constraints: writing it is a new configuration too
  (define guide? (equal? (path-string full) (path-string (simplify-path (build-path (hub-root h) ig-file-name)))))
  (unless (or config? lang)
    (error 'write (format "~a is not a file of the workspace's languages (.fsh .cql .fhirpath .vcl .map/.fml .view.json .json sushi-config.yaml) or workspace.yaml" p)))
  (cond
    [(string=? (string-trim text) "")
     (when (file-exists? full) (delete-file full))]
    [else (make-parent-directory* full)
          (call-with-output-file full (lambda (o) (write-string text o)) #:exists 'truncate/replace)])
  (when (or config? guide?) (configure! h (hub-root h)))
  (refresh! h)
  (define mine (if config? '() (problems-of h full)))
  (define others (- (length (hub-diagnostics h)) (length mine)))
  (define answer
    (hasheq 'path (rel h full)
            'language (or lang "workspace.yaml")
            'written (file-exists? full)
            'problems (map (lambda (d) (problem-json h d)) mine)
            'problemsElsewhere others))
  (define answer*
    (cond [(not (equal? lang "fsh")) answer]
          [enforce?
           (define sds (unlisted-profile-sds h text))
           (if (null? sds) answer (hash-set answer 'enforced (enforce-profiles! h sds)))]
          [else (let ([unenforced (unlisted-profiles h text)])
                  (if (pair? unenforced) (hash-set answer 'notes unenforced) answer))]))
  ;; text read from a file elsewhere (`text=@../a.fsh`) is COPIED: say so, since a later edit of that
  ;; file changes nothing here (a rerun's agent edited its original and staged the old copy)
  (define answer** (if (and from (not (equal? (path-string (simplify-path (path->complete-path from))) (path-string full))))
                       (hash-set answer* 'copied
                                 ;; both named from where the call was made: the same file name in two
                                 ;; places read as one file
                                 ;; short: a batch writing several files repeated a sentence each time
                                 (format "~a (a copy: edit it, or write again)" (from-here full)))
                       answer*))
  ;; the configuration only when it is what was written
  (if (or config? guide?) (hash-set answer** 'config (config-json h)) answer**))

;; unlisted-profiles : hub fsh-text -> (listof string)   a profile the text defines that workspace.yaml's
;; `profiles` does not name: its examples are checked against it, but stage and check(data: true)
;; hold the data only to the listed ones (a rerun's agent expected a new rule to apply at once)
(define (unlisted-profiles h text)
  (for/list ([sd (in-list (unlisted-profile-sds h text))])
    (format "profile ~a (~a) is not in workspace.yaml's `profiles`: examples are checked against it, but stage and check(data: true) hold data to it only once listed (write it again with enforce: true, or add profiles:\n  ~a: ~a)"
            (hash-ref sd 'name "?") (hash-ref sd 'url "?") (hash-ref sd 'type "?") (hash-ref sd 'url "?"))))

;; enforce-profiles! : hub (listof SD) -> (listof string)   each profile added to workspace.yaml's
;; `profiles` under its type (the file edited as text: the line after `profiles:`, else a new block)
(define (enforce-profiles! h sds)
  (define f (build-path (hub-root h) "workspace.yaml"))
  (define text (if (file-exists? f) (file->string f) ""))
  (define lines (for/list ([sd (in-list sds)]) (format "  ~a: ~a" (hash-ref sd 'type) (hash-ref sd 'url))))
  ;; a type already listed takes the new canonical on its own line (`Observation: a b`); a second
  ;; `Observation:` line was what YAML would read as the only one
  (define (add-to-listed text sd)
    (define rx (pregexp (format "(?m:^(  ~a:[^\n#]*?)[ \t]*(#[^\n]*)?$)" (regexp-quote (hash-ref sd 'type)))))
    (and (regexp-match? #px"(?m:^profiles:)" text) (regexp-match? rx text)
         (regexp-replace rx text (lambda (all head comment)
                                   (if (regexp-match? (regexp (regexp-quote (hash-ref sd 'url))) head) all
                                       (string-append head " " (hash-ref sd 'url) (if comment (string-append "  " comment) "")))))))
  (define-values (text* rest-sds)
    (for/fold ([t text] [rest '()]) ([sd (in-list sds)])
      (define t2 (add-to-listed t sd))
      (if t2 (values t2 rest) (values t (append rest (list sd))))))
  (define rest-lines (for/list ([sd (in-list rest-sds)]) (format "  ~a: ~a" (hash-ref sd 'type) (hash-ref sd 'url))))
  (define block (string-append "profiles:                    # rules the data keeps: FSH profiles (or an IG's) by type\n"
                               (string-join rest-lines "\n") "\n"))
  (define new-text
    (cond
      [(null? rest-sds) text*]
      [(regexp-match? #px"(?m:^profiles:)" text*)
       (regexp-replace #px"(?m:^profiles:[^\n]*$)" text* (lambda (head) (string-append head "\n" (string-join rest-lines "\n"))))]
      ;; init's commented template: filled in place (it was left, and a second `profiles:` appended)
      [(regexp-match? #px"(?m:^# profiles:[^\n]*\n(?:#   [^\n]*\n)?)" text*)
       (regexp-replace #px"(?m:^# profiles:[^\n]*\n(?:#   [^\n]*\n)?)" text* (lambda (_) block))]
      [else (string-append text* (if (or (string=? text* "") (regexp-match? #rx"\n$" text*)) "" "\n") block)]))
  (call-with-output-file f (lambda (o) (write-string new-text o)) #:exists 'truncate/replace)
  (configure! h (hub-root h))
  (refresh! h)
  (map (lambda (sd) (format "~a: ~a" (hash-ref sd 'type) (hash-ref sd 'url))) sds))

;; unlisted-profile-sds : hub fsh-text -> (listof SD)   the text's profiles workspace.yaml does not list
(define (unlisted-profile-sds h text)
  (define listed (append* (hash-values (ws-config-profiles (workspace-config (hub-ws h))))))
  (define sds (registered-resources "StructureDefinition"))
  (for*/list ([e (in-list (regexp-match* #px"(?m:^Profile:\\s*([A-Za-z0-9_.-]+)\\s*$)((?:\n(?!Profile:|Instance:|Extension:|ValueSet:|CodeSystem:|Invariant:|RuleSet:|Logical:|Resource:|Mapping:|Alias:).*)*)" text #:match-select values))]
              [name (in-value (cadr e))]
              [id (in-value (let ([m (regexp-match #px"(?m:^Id:\\s*([A-Za-z0-9.-]+))" (caddr e))]) (if m (cadr m) name)))]
              [sd (in-value (findf (lambda (r) (and (equal? (hash-ref r 'id #f) id) (equal? (hash-ref r 'derivation #f) "constraint"))) sds))]
              #:when sd
              #:unless (member (hash-ref sd 'url #f) listed))
    (hash-set sd 'name name)))

(define (config-json h)
  (define c (workspace-config (hub-ws h)))
  (hasheq 'fhirVersion (ws-config-fhir-version c) 'canonical (ws-config-canonical c)
          'packages (map path-string (hub-packages h)) 'data (hub-data-label h)
          'parameters (for/hasheq ([(k v) (in-hash (ws-config-parameters c))]) (values (string->symbol k) v))
          'warnings (hub-warnings h)))

;; ---- check -------------------------------------------------------------------------------------
(define (hub-check h paths #:data? [data? #f])
  (refresh! h)
  (define ds (if (null? paths) (hub-diagnostics h)
                 (append* (for/list ([p (in-list paths)]) (problems-of h (inside h p))))))
  (define base (hasheq 'files (map (lambda (f) (rel h f)) (workspace-files (hub-ws h)))
                       'errors (count-severity ds 'error)
                       'warnings (count-severity ds 'warning)
                       'problems (map (lambda (d) (problem-json h d)) ds)
                       'workspace (config-json h)))
  (if data? (hash-set base 'data (with-hub h (lambda () (check-data h)))) base))

;; check-data : hub -> jsexpr   every stored resource validated against its base type and the
;; workspace's profiles for its type: how many, how many break a rule, the rules by how often they
;; are broken, and the first problems as lines (`Observation/x: Observation.value[x]: …`)
(define (check-data h)
  (define resources (all-data h))
  (define found
    (for*/list ([r (in-list resources)]
                [e (in-list (validation-errors (with-profiles h r)))])
      (cons (format "~a/~a" (hash-ref r 'resourceType "?") (hash-ref r 'id "?")) e)))
  (define by-rule (for/fold ([acc (hash)]) ([f (in-list found)]) (hash-update acc (cdr f) add1 0)))
  (define bad (remove-duplicates (map car found)))
  (hasheq 'checked (length resources)
          'invalid (length bad)
          ;; per type: the trail's Provenances and AuditEvents are stored resources too
          'byType (for/hasheq ([t (in-list (remove-duplicates (map (lambda (r) (hash-ref r 'resourceType "?")) resources)))])
                    (values (string->symbol t)
                            (hasheq 'checked (count (lambda (r) (equal? (hash-ref r 'resourceType "?") t)) resources)
                                    'invalid (count (lambda (k) (string-prefix? k (string-append t "/"))) bad))))
          'profiles (for/hasheq ([(t us) (in-hash (ws-config-profiles (workspace-config (hub-ws h))))]) (values (string->symbol t) us))
          'byRule (for/list ([kv (in-list (sort (hash->list by-rule) > #:key cdr))] [_ (in-range 20)])
                    (hasheq 'rule (car kv) 'count (cdr kv)))
          'problems (for/list ([f (in-list found)] [_ (in-range 50)]) (format "~a: ~a" (car f) (cdr f)))))
