#lang racket/base

;;; session.rkt — what a process of the function server holds between calls.
;;;
;;; A Session is (session dir fhir-version packages hubs):
;;;   dir          : path           a temporary directory of its own, removed when it closes
;;;   fhir-version : string         "4.0.1" | "5.0.0": a process reads one version of FHIR (the
;;;                                 types register by name), so a session has one
;;;   packages     : (listof string)  FHIR packages in context for every call (names or .tgz paths)
;;;   hubs         : (hash Key -> hub)  the projects asked of so far, each opened once (fhir-mcp's hub)
;;;
;;; A Project is what a call's sources are, one of:
;;;   - Files: a hash of file name -> text, in any of the languages and FHIR JSON. It is written
;;;     under the session's directory once per content (its Key is the SHA-1 of the names and
;;;     texts), so a caller that repeats a project pays for compiling it once;
;;;   - a directory on disk (the caller's own project: its files are read at every call).
;;; No files and no directory is the empty project.
;;;
;;; Data is what a call's programs read, one of:
;;;   - resources given in the call (a list, a resource, a Bundle), written to a file of the session;
;;;   - a string: a directory of FHIR JSON, a JSON file, a SQLite FHIR store, a FHIR server's url.

(require racket/contract racket/file racket/list racket/path racket/string json file/sha1
         (only-in fhir/lang/workspace open-workspace workspace-config ws-config-fhir-version)
         (only-in fhir/mcp/hub hub? open-hub refresh! hub-root use-data!))

(provide
 (struct-out session)
 (contract-out
  [fhir-versions (listof string?)]
  ;; open-session : [#:fhir-version v] [#:packages ps] -> session
  [open-session (->* () (#:fhir-version string? #:packages (listof string?)) session?)]
  [close-session! (-> session? void?)]
  ;; project-hub : session files|#f directory|#f canonical|#f -> hub   the project's hub, opened
  ;; once and refreshed (what its files define is registered) — raises exn:fail:user when the
  ;; project states another FHIR version than the session's, or a file name leaves the project
  [project-hub (-> session? (or/c hash? #f) (or/c string? #f) (or/c string? #f) hub?)]
  ;; with-data : session hub data thunk -> value   the hub over the data a call gives (#f: the
  ;; project's own, when its workspace.yaml names some)
  [with-data (-> session? hub? any/c (-> any) any)]
  ;; file-name? : string -> boolean   a relative name inside the project: no `..`, not absolute
  [file-name? (-> string? boolean?)]))

(struct session (dir fhir-version packages hubs [recent #:mutable]))

(define fhir-versions '("4.0.1" "5.0.0"))
;; the base of the canonicals a project given as files defines when it states none (FSH's own default)
(define default-canonical "http://example.org")
;; how many projects given as files a session keeps open; the least recently used goes first
(define kept-projects 8)

(define (open-session #:fhir-version [v "4.0.1"] #:packages [packages '()])
  (unless (member v fhir-versions)
    (raise-user-error 'fhir-api "FHIR version ~a is not one this toolkit reads (~a)" v (string-join fhir-versions ", ")))
  (session (make-temporary-file "fhir-api-~a" 'directory) v packages (make-hash) '()))

(define (close-session! s)
  (delete-directory/files (session-dir s) #:must-exist? #f)
  (hash-clear! (session-hubs s)))

;; ---- projects ----------------------------------------------------------------------------------
(define (file-name? name)
  (and (positive? (string-length name))
       (not (regexp-match? #rx"^[/\\\\]|^[A-Za-z]:" name))
       (not (member ".." (regexp-split #rx"[/\\\\]" name)))))

;; files-key : (hash name -> text) canonical|#f -> string   the same for the same names and texts
(define (files-key files canonical)
  (define o (open-output-bytes))
  (write (list canonical (sort (for/list ([(k v) (in-hash files)]) (cons (format "~a" k) v)) string<? #:key car)) o)
  (substring (sha1 (open-input-bytes (get-output-bytes o))) 0 16))

;; write-project! : session dir files canonical -> void   the files as given, and a workspace.yaml
;; that states the session's FHIR version unless the caller's own files configure the project
(define (write-project! s dir files canonical)
  (make-directory* dir)
  (for ([(k text) (in-hash files)])
    (define name (format "~a" k))
    (unless (file-name? name)
      (raise-user-error 'files "`~a` is not a file name inside the project (a relative name, no `..`)" name))
    (unless (string? text) (raise-user-error 'files "the text of `~a` is not a string" name))
    (define f (build-path dir name))
    (make-directory* (let-values ([(base _n _d) (split-path f)]) base))
    (call-with-output-file f #:exists 'truncate (lambda (o) (write-string text o))))
  (unless (file-exists? (build-path dir "workspace.yaml"))
    (call-with-output-file (build-path dir "workspace.yaml")
      (lambda (o)
        (fprintf o "fhirVersion: ~a\n" (session-fhir-version s))
        (fprintf o "canonical: ~a\n" (or canonical default-canonical))))))

;; check-version! : session dir -> void   a project that states another version cannot be read here
(define (check-version! s dir)
  (define-values (ws _warnings) (open-workspace dir))
  (define v (ws-config-fhir-version (workspace-config ws)))
  (unless (equal? v (session-fhir-version s))
    (raise-user-error 'fhir-api "the project is FHIR ~a and this process reads FHIR ~a: start one for ~a (a process reads one version)~a"
                      v (session-fhir-version s) v
                      (if (equal? v "4.0.1") "; a project that states no version is 4.0.1: say fhirVersion in workspace.yaml or sushi-config.yaml" ""))))

(define (project-hub s files directory canonical)
  (when (and directory files (positive? (hash-count files)))
    (raise-user-error 'fhir-api "give a project as `files` or as a `directory`, not both"))
  (define-values (key dir)
    (cond [directory
           (define d (simplify-path (path->complete-path directory)))
           (unless (directory-exists? d) (raise-user-error 'directory "~a is not a directory" directory))
           (values (cons 'directory (path->string d)) d)]
          [else
           (define k (files-key (or files (hasheq)) canonical))
           (values k (build-path (session-dir s) (string-append "p-" k)))]))
  (define h
    (or (hash-ref (session-hubs s) key #f)
        ;; a project that cannot be opened leaves nothing behind in the session's directory
        (with-handlers ([exn:fail? (lambda (e) (unless directory (delete-directory/files dir #:must-exist? #f)) (raise e))])
          (unless directory (write-project! s dir (or files (hasheq)) canonical))
          (check-version! s dir)
          (define h (open-hub dir #:packages (session-packages s)))
          (hash-set! (session-hubs s) key h)
          h)))
  (when directory (check-version! s dir))               ; its files may have changed since
  (unless directory (remember! s key))
  (refresh! h)
  h)

;; remember! : session key -> void   the key is the most recently used; past `kept-projects` the
;; oldest project given as files is closed and its directory removed
(define (remember! s key)
  (define recent (cons key (remove key (session-recent s))))
  (define-values (kept dropped) (if (> (length recent) kept-projects) (split-at recent kept-projects) (values recent '())))
  (for ([k (in-list dropped)])
    (hash-remove! (session-hubs s) k)
    (delete-directory/files (build-path (session-dir s) (string-append "p-" k)) #:must-exist? #f))
  (set-session-recent! s kept))

;; ---- data --------------------------------------------------------------------------------------
;; data-place : session data -> string   where the data is, as a workspace's `data` names it
(define (data-place s data)
  (cond
    [(string? data)
     (if (regexp-match? #rx"^https?://" data) data (path->string (simplify-path (path->complete-path data))))]
    [(or (list? data) (hash? data))
     (define resources (if (list? data) data (list data)))
     (unless (andmap hash? resources) (raise-user-error 'data "resources are JSON objects"))
     (define text (jsexpr->string (hasheq 'resourceType "Bundle" 'type "collection"
                                          'entry (for/list ([r (in-list resources)]) (hasheq 'resource r)))))
     (define f (build-path (session-dir s) (string-append "data-" (substring (sha1 (open-input-string text)) 0 16) ".json")))
     (unless (file-exists? f) (call-with-output-file f (lambda (o) (write-string text o))))
     (path->string f)]
    [else (raise-user-error 'data "data is resources (a list, a resource, a Bundle) or a string: a directory, a JSON file, a SQLite store, a FHIR server's url")]))

(define (with-data s h data thunk)
  (when (and data (not (eq? data 'null)))
    (with-handlers ([exn:fail? (lambda (e) (raise-user-error 'data "~a" (regexp-replace #rx"^(data: )?(workspace[.]yaml: )?(data )?" (exn-message e) "")))])
      (use-data! h (data-place s data))))
  (thunk))

(module+ test
  (require rackunit)
  (check-true (file-name? "a.fsh"))
  (check-true (file-name? "fsh/profiles.fsh"))
  (check-false (file-name? "../a.fsh"))
  (check-false (file-name? "/etc/passwd"))
  (check-false (file-name? "C:\\x.fsh"))
  (check-false (file-name? ""))
  ;; the key is of the names and texts, whatever order they come in
  (check-equal? (files-key (hasheq 'a.fsh "x" 'b.cql "y") #f) (files-key (hasheq 'b.cql "y" 'a.fsh "x") #f))
  (check-not-equal? (files-key (hasheq 'a.fsh "x") #f) (files-key (hasheq 'a.fsh "x ") #f))
  (check-not-equal? (files-key (hasheq 'a.fsh "x") #f) (files-key (hasheq 'a.fsh "x") "http://example.org/c"))
  (check-exn #rx"not one this toolkit reads" (lambda () (open-session #:fhir-version "3.0.2"))))
