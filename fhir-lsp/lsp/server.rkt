#lang racket/base

;;; server.rkt — the language server: state, dispatch, the loop.
;;;
;;; A State is (state documents published down?):
;;;   documents : (hash uri -> text)            the open documents, as the editor holds them
;;;   published : (hash uri -> (listof uri))    for each document, the documents its last
;;;                                            diagnostics were published to (a project compile
;;;                                            reports on other files; they are cleared next time)
;;;   down?     : boolean                       shutdown received: only exit is expected
;;; dispatch : Message State -> (values (or Message #f) State (listof Message))
;;;   the response to a request (none for a notification), the next state, and the notifications
;;;   to send (publishDiagnostics). Pure: the loop does the I/O.
;;; The methods: initialize, initialized, shutdown, exit, textDocument/didOpen, didChange (full
;;; text), didSave, didClose. Everything else: a request gets method-not-found, a notification is
;;; ignored (the protocol allows both).

(require racket/contract racket/match racket/list racket/string racket/file
         fhir/lang/support
         "jsonrpc.rkt" "diagnostics.rkt" "languages.rkt")

(provide
 (struct-out state)
 (contract-out
  [initial-state state?]
  [dispatch      (-> hash? state? (values (or/c hash? #f) state? (listof hash?)))]
  [serve         (->* () (input-port? output-port?) void?)]
  [server-capabilities hash?]))

(struct state (documents published down?) #:transparent)
(define initial-state (state (hash) (hash) #f))

(define server-capabilities
  (hasheq 'textDocumentSync (hasheq 'openClose #t 'change 1 'save (hasheq 'includeText #t))   ; 1 = full text
          'hoverProvider #t 'definitionProvider #t 'documentSymbolProvider #t
          'completionProvider (hasheq 'triggerCharacters '(" " "." ":"))))

;; ---- the handlers, a table -------------------------------------------------------------------
;; A RequestHandler is (params state -> (values result state notifications))
;; hover, completion, definition and symbols go to the document's language support with the
;; document's PROJECT: its entities across the project's files (open documents as the editor holds
;; them, the rest from disk) and a way to read any of those texts.
(define request-handlers
  (hash "initialize"
        (lambda (params st)
          (values (hasheq 'capabilities server-capabilities
                          'serverInfo (hasheq 'name "fhir-lsp" 'version "0.1"))
                  st '()))
        "shutdown"
        (lambda (params st) (values (json-null) (struct-copy state st [down? #t]) '()))
        "textDocument/hover"
        (lambda (params st)
          (define-values (uri text pos s) (document-position params st))
          (values (or (and text s
                           (let ([h ((lang-support-hover s) (project-of st uri s) text pos)])
                             (and h (hasheq 'contents (hasheq 'kind "markdown" 'value h)))))
                      (json-null))
                  st '()))
        "textDocument/completion"
        (lambda (params st)
          (define-values (uri text pos s) (document-position params st))
          (values (if (and text s) ((lang-support-complete s) (project-of st uri s) text pos) '()) st '()))
        ;; the document's declarations, as an outline
        "textDocument/documentSymbol"
        (lambda (params st)
          (define uri (hash-ref (hash-ref params 'textDocument (hasheq)) 'uri #f))
          (define text (and uri (hash-ref (state-documents st) uri #f)))
          (define s (and uri (document-support uri)))
          (values (if (and text s)
                      (for/list ([e (in-list ((lang-support-entities s) text (document-path uri s)))])
                        (define range (hasheq 'start (hasheq 'line (entity-line e) 'character 0) 'end (hasheq 'line (entity-line e) 'character 0)))
                        (hasheq 'name (entity-name e) 'detail (entity-kind e) 'kind (symbol-kind (entity-kind e))
                                'range range 'selectionRange range))
                      '())
                  st '()))
        "textDocument/definition"
        (lambda (params st)
          (define-values (uri text pos s) (document-position params st))
          (values (or (and text s
                           (let ([e ((lang-support-definition s) (project-of st uri s) text pos)])
                             (and e (hasheq 'uri (path->uri (entity-file e))
                                            'range (hasheq 'start (hasheq 'line (entity-line e) 'character 0)
                                                           'end (hasheq 'line (entity-line e) 'character 0))))))
                      (json-null))
                  st '()))))

;; symbol-kind : entity kind -> SymbolKind   Class for structures, Enum for terminology, Object for
;; instances, Function for CQL defines and FML groups, Module for libraries and maps
(define (symbol-kind kind)
  (case kind [("Profile" "Extension" "Logical" "Resource") 5] [("ValueSet" "CodeSystem" "valueset" "codesystem" "code" "concept") 10]
             [("Instance") 19] [("Alias" "include" "using" "uses" "imports") 14] [("RuleSet" "Mapping" "Invariant" "define" "group" "conceptmap") 12]
             [("library" "map") 2] [("parameter" "context") 13] [else 5]))
;; document-support : uri -> support|#f   the support of the language the document's extension names
(define (document-support uri) (let ([l (language-of uri)]) (and l (support-of l))))
;; document-path : uri support -> path-string   the file, or a name an untitled document goes by
(define (document-path uri s) (or (uri->path uri) (string-append "untitled." (lang-support-id s))))
;; document-position : params state -> (values uri text|#f position support|#f)
(define (document-position params st)
  (define uri (hash-ref (hash-ref params 'textDocument (hasheq)) 'uri #f))
  (define p (hash-ref params 'position (hasheq)))
  (values uri (and uri (hash-ref (state-documents st) uri #f)) (cons (hash-ref p 'line 0) (hash-ref p 'character 0))
          (and uri (document-support uri))))

;; project-of : state uri support -> project   the document's project: the support's project files
;; and the document itself, each read from the open documents first, then from disk
(define (project-of st uri s)
  (define path (uri->path uri))
  (define (text-of f)
    (or (hash-ref (state-documents st) (path->uri f) #f)
        (and (equal? (path-string f) (and path (path-string path))) (hash-ref (state-documents st) uri #f))
        (with-handlers ([exn:fail? (lambda (_) "")]) (file->string f))))
  (define files (if path
                    (let ([ps ((lang-support-project-files s) path)])
                      (if (member (path-string path) (map path-string ps)) ps (cons path ps)))
                    '()))
  (define texts (if path
                    (for/list ([f (in-list files)]) (cons f (text-of f)))
                    (list (cons (document-path uri s) (hash-ref (state-documents st) uri "")))))
  (project (or path (document-path uri s))
           (append-map (lambda (ft) ((lang-support-entities s) (cdr ft) (car ft))) texts)
           (lambda (f) (or (for/first ([ft (in-list texts)] #:when (equal? (path-string (car ft)) (path-string f))) (cdr ft))
                           (text-of f)))))
(define (path-string p) (if (path? p) (path->string p) p))

;; A NotificationHandler is (params state -> (values state notifications))
(define notification-handlers
  (hash "initialized" (lambda (params st) (values st '()))
        "exit"        (lambda (params st) (values st '()))
        "textDocument/didOpen"
        (lambda (params st)
          (define doc (hash-ref params 'textDocument (hasheq)))
          (define uri (hash-ref doc 'uri #f))
          (define text (hash-ref doc 'text ""))
          (if uri (publish (struct-copy state st [documents (hash-set (state-documents st) uri text)]) uri (hash-ref doc 'languageId #f))
              (values st '())))
        "textDocument/didChange"
        (lambda (params st)
          (define uri (hash-ref (hash-ref params 'textDocument (hasheq)) 'uri #f))
          (define changes (hash-ref params 'contentChanges '()))
          ;; full sync: the last change carries the whole text
          (define text (and (pair? changes) (hash-ref (last changes) 'text #f)))
          (if (and uri text) (publish (struct-copy state st [documents (hash-set (state-documents st) uri text)]) uri #f)
              (values st '())))
        "textDocument/didSave"
        (lambda (params st)
          (define uri (hash-ref (hash-ref params 'textDocument (hasheq)) 'uri #f))
          (define text (or (hash-ref params 'text #f) (and uri (hash-ref (state-documents st) uri #f))))
          (if (and uri text) (publish (struct-copy state st [documents (hash-set (state-documents st) uri text)]) uri #f)
              (values st '())))
        "textDocument/didClose"
        (lambda (params st)
          (define uri (hash-ref (hash-ref params 'textDocument (hasheq)) 'uri #f))
          (cond [(not uri) (values st '())]
                [else (values (struct-copy state st
                                           [documents (hash-remove (state-documents st) uri)]
                                           [published (hash-remove (state-published st) uri)])
                              (for/list ([u (in-list (remove-duplicates (cons uri (hash-ref (state-published st) uri '()))))])
                                (publish-diagnostics u '())))]))))

(define (json-null) 'null)
(define (publish-diagnostics uri ds) (notification "textDocument/publishDiagnostics" (hasheq 'uri uri 'diagnostics ds)))

;; publish : state uri languageId|#f -> (values state notifications)   diagnose the document (by its
;; declared language, else its extension) and publish to every document the diagnostics name; a
;; document reported on last time but not this time is cleared
(define (publish st uri language-id)
  (define text (hash-ref (state-documents st) uri ""))
  (define path (uri->path uri))
  (define lang (or (and language-id (language-by-id language-id)) (and path (language-of path)) (language-of uri)))
  (define groups
    (if lang
        (group-by-uri (diagnose lang text (or path (string-append "untitled." (car (language-extensions lang))))) uri)
        (hash)))
  (define now (hash-set groups uri (hash-ref groups uri '())))
  (define before (hash-ref (state-published st) uri '()))
  (define cleared (for/list ([u (in-list before)] #:unless (hash-has-key? now u)) (publish-diagnostics u '())))
  (values (struct-copy state st [published (hash-set (state-published st) uri (hash-keys now))])
          (append (for/list ([(u ds) (in-hash now)]) (publish-diagnostics u ds)) cleared)))

;; ---- dispatch --------------------------------------------------------------------------------
(define (dispatch m st)
  (cond
    [(hash-has-key? m 'invalid) (values (error-response 'null parse-error "the message was not JSON") st '())]
    [(request? m)
     (define h (hash-ref request-handlers (message-method m) #f))
     (cond
       [h (define-values (result st* notes) (h (or (message-params m) (hasheq)) st))
          (values (response (message-id m) result) st* notes)]
       [(string-prefix? (message-method m) "$/") (values (error-response (message-id m) method-not-found (message-method m)) st '())]
       [else (values (error-response (message-id m) method-not-found (format "unknown method ~a" (message-method m))) st '())])]
    [(notification? m)
     (define h (hash-ref notification-handlers (message-method m) #f))
     (if h (let-values ([(st* notes) (h (or (message-params m) (hasheq)) st)]) (values #f st* notes))
         (values #f st '()))]
    [else (values #f st '())]))

;; serve : [in out] -> void   read, dispatch, write, until `exit` or the stream ends.
;; Diagnostics are computed off the loop: a document notification is dispatched at once for its
;; state change (the stored text, so hover and completion see it), and the diagnosing runs in a
;; worker thread; only the newest run for a document publishes (an edit during a long project
;; compile makes the older result stale), and writes to `out` are serialised.
(define diagnosing-methods '("textDocument/didOpen" "textDocument/didChange" "textDocument/didSave"))
(define (serve [in (current-input-port)] [out (current-output-port)])
  (define out-lock (make-semaphore 1))
  (define (send! m) (call-with-semaphore out-lock (lambda () (write-message m out))))
  (define generation (make-hash))                    ; uri -> the number of the newest edit
  (let loop ([st initial-state])
    (define m (read-message in))
    (unless (eof-object? m)
      (cond
        [(and (notification? m) (member (message-method m) diagnosing-methods))
         (define-values (st* uri) (record-document m st))
         (when uri
           (define n (add1 (hash-ref generation uri 0)))
           (hash-set! generation uri n)
           (define language-id (hash-ref (hash-ref (message-params m) 'textDocument (hasheq)) 'languageId #f))
           (thread (lambda ()
                     (define-values (_st notes) (publish st* uri language-id))
                     (when (= n (hash-ref generation uri 0)) (for-each send! notes)))))
         (loop st*)]
        [else
         (define-values (resp st* notes) (dispatch m st))
         (for-each send! notes)
         (when resp (send! resp))
         (unless (equal? (message-method m) "exit") (loop st*))]))))
;; record-document : message state -> (values state uri|#f)   the document as the message leaves it
(define (record-document m st)
  (define params (or (message-params m) (hasheq)))
  (define uri (hash-ref (hash-ref params 'textDocument (hasheq)) 'uri #f))
  (define text
    (case (message-method m)
      [("textDocument/didOpen") (hash-ref (hash-ref params 'textDocument (hasheq)) 'text #f)]
      [("textDocument/didChange") (let ([cs (hash-ref params 'contentChanges '())]) (and (pair? cs) (hash-ref (last cs) 'text #f)))]
      [else (or (hash-ref params 'text #f) (and uri (hash-ref (state-documents st) uri #f)))]))
  (if (and uri text)
      (values (struct-copy state st [documents (hash-set (state-documents st) uri text)]) uri)
      (values st #f)))

(module+ test
  (require rackunit)
  ;; the handshake
  (define-values (r1 s1 n1) (dispatch (request 1 "initialize" (hasheq 'rootUri 'null)) initial-state))
  (check-equal? (hash-ref (hash-ref r1 'result) 'capabilities) server-capabilities)
  (check-equal? n1 '())
  ;; an unknown request is an error; an unknown notification is nothing
  (define-values (r2 s2 n2) (dispatch (request 2 "textDocument/rename" (hasheq)) s1))
  (check-equal? (hash-ref (hash-ref r2 'error) 'code) method-not-found)
  (define-values (r3 s3 n3) (dispatch (notification "workspace/didChangeConfiguration" (hasheq)) s1))
  (check-false r3) (check-equal? n3 '())
  ;; a document in no language of ours: stored, and published with no diagnostics
  (define-values (r4 s4 n4) (dispatch (notification "textDocument/didOpen"
                                                    (hasheq 'textDocument (hasheq 'uri "file:///tmp/notes.txt" 'languageId "plaintext" 'text "hi")))
                                      s1))
  (check-equal? (hash-ref (state-documents s4) "file:///tmp/notes.txt") "hi")
  (check-equal? n4 (list (publish-diagnostics "file:///tmp/notes.txt" '())))
  ;; a stand-in support for vcl: diagnostics published, the outline, hover, definition and completion
  ;; all go through the support with the document's project (the open text, not the disk)
  (define seen '())
  (define fake
    (lang-support "vcl"
                  (lambda (t p) (list (positionless 'vcl 'compile "bad" p)))
                  (lambda (p) '())
                  (lambda (t f) (list (entity "expr" (string-trim t) #f (if (path? f) (path->string f) f) 0)))
                  (lambda (pr t pos) (set! seen (project-entities pr)) "hovered")
                  (lambda (pr t pos) (car (project-entities pr)))
                  (lambda (pr t pos) (list (hasheq 'label "done" 'kind 1)))))
  (parameterize ([current-language-supports (hash "vcl" fake)])
    (define uri "file:///tmp/nowhere/v.vcl")
    (define-values (ro so no) (dispatch (notification "textDocument/didOpen" (hasheq 'textDocument (hasheq 'uri uri 'languageId "vcl" 'text "(http://x)a"))) s1))
    (check-equal? (length no) 1)
    (check-equal? (hash-ref (car (hash-ref (hash-ref (car no) 'params) 'diagnostics)) 'severity) 1)
    (define-values (rs ss ns) (dispatch (request 5 "textDocument/documentSymbol" (hasheq 'textDocument (hasheq 'uri uri))) so))
    (check-equal? (map (lambda (x) (hash-ref x 'name)) (hash-ref rs 'result)) '("(http://x)a"))
    (define-values (rh sh nh) (dispatch (request 6 "textDocument/hover" (hasheq 'textDocument (hasheq 'uri uri) 'position (hasheq 'line 0 'character 1))) so))
    (check-equal? (hash-ref (hash-ref (hash-ref rh 'result) 'contents) 'value) "hovered")
    (check-equal? (map entity-name seen) '("(http://x)a"))
    (define-values (rd sd nd) (dispatch (request 7 "textDocument/definition" (hasheq 'textDocument (hasheq 'uri uri) 'position (hasheq 'line 0 'character 1))) so))
    (check-equal? (hash-ref (hash-ref rd 'result) 'uri) uri)
    (define-values (rc sc nc) (dispatch (request 8 "textDocument/completion" (hasheq 'textDocument (hasheq 'uri uri) 'position (hasheq 'line 0 'character 1))) so))
    (check-equal? (map (lambda (c) (hash-ref c 'label)) (hash-ref rc 'result)) '("done")))
  ;; a document of an installed language without a support stand-in: hover answers null, never an error
  (define-values (rn sn nn) (dispatch (request 9 "textDocument/hover" (hasheq 'textDocument (hasheq 'uri "file:///tmp/notes.txt") 'position (hasheq 'line 0 'character 0))) s4))
  (check-equal? (hash-ref rn 'result) 'null)
  ;; the real FSH support, when the fsh package is installed: hover on an element path, definition and
  ;; completion across an open document, the outline
  (when (language-support "fsh")
    (define fsh-text (string-append "Alias: $obs = http://hl7.org/fhir/StructureDefinition/Observation\n\nProfile: BP\nParent: $obs\nId: bp\n"
                                    "* component.code 1..1\n\nInstance: a\nInstanceOf: bp\n* status = #final\n"))
    (define fsh-uri "file:///tmp/nowhere/bp.fsh")
    (define-values (r9 s9 n9) (dispatch (notification "textDocument/didOpen" (hasheq 'textDocument (hasheq 'uri fsh-uri 'languageId "fsh" 'text fsh-text))) s1))
    (define-values (rh sh nh) (dispatch (request 10 "textDocument/hover" (hasheq 'textDocument (hasheq 'uri fsh-uri) 'position (hasheq 'line 5 'character 4))) s9))
    (check-regexp-match #rx"Observation.component.code" (hash-ref (hash-ref (hash-ref rh 'result) 'contents) 'value))
    (define-values (rd sd nd) (dispatch (request 11 "textDocument/definition" (hasheq 'textDocument (hasheq 'uri fsh-uri) 'position (hasheq 'line 8 'character 13))) s9))
    (check-equal? (hash-ref (hash-ref rd 'result) 'uri) fsh-uri)
    (check-equal? (hash-ref (hash-ref (hash-ref (hash-ref rd 'result) 'range) 'start) 'line) 2)
    (define-values (rc sc nc) (dispatch (request 13 "textDocument/completion" (hasheq 'textDocument (hasheq 'uri fsh-uri) 'position (hasheq 'line 3 'character 10))) s9))
    (check-true (and (member "BP" (map (lambda (c) (hash-ref c 'label)) (hash-ref rc 'result))) #t))
    (define-values (ro so no) (dispatch (request 14 "textDocument/documentSymbol" (hasheq 'textDocument (hasheq 'uri fsh-uri))) s9))
    (check-equal? (map (lambda (x) (hash-ref x 'name)) (hash-ref ro 'result)) '("$obs" "BP" "a")))
  ;; the real CQL support, when installed: outline, definition of a quoted name, completion inside quotes
  (when (language-support "cql")
    (define cql-uri "file:///tmp/nowhere/l.cql")
    (define-values (rq sq nq) (dispatch (notification "textDocument/didOpen" (hasheq 'textDocument (hasheq 'uri cql-uri 'languageId "cql" 'text "library L\ndefine \"A\": 1\ndefine \"B\": \"A\" + 1\n"))) s1))
    (define-values (rs1 ss1 ns1) (dispatch (request 15 "textDocument/documentSymbol" (hasheq 'textDocument (hasheq 'uri cql-uri))) sq))
    (check-equal? (map (lambda (x) (hash-ref x 'name)) (hash-ref rs1 'result)) '("L" "A" "B"))
    (define-values (rd2 sd2 nd2) (dispatch (request 16 "textDocument/definition" (hasheq 'textDocument (hasheq 'uri cql-uri) 'position (hasheq 'line 2 'character 13))) sq))
    (check-equal? (hash-ref (hash-ref (hash-ref (hash-ref rd2 'result) 'range) 'start) 'line) 1)
    (define-values (rc2 sc2 nc2) (dispatch (request 17 "textDocument/completion" (hasheq 'textDocument (hasheq 'uri cql-uri) 'position (hasheq 'line 2 'character 14))) sq))
    (check-equal? (map (lambda (c) (hash-ref c 'label)) (hash-ref rc2 'result)) '("A")))
  ;; closing clears, including documents reported on through this one
  (define s6 (struct-copy state s4 [published (hash "file:///tmp/notes.txt" '("file:///tmp/notes.txt" "file:///tmp/other.fsh"))]))
  (define-values (r7 s7 n7) (dispatch (notification "textDocument/didClose" (hasheq 'textDocument (hasheq 'uri "file:///tmp/notes.txt"))) s6))
  (check-equal? (sort (map (lambda (n) (hash-ref (hash-ref n 'params) 'uri)) n7) string<?) '("file:///tmp/notes.txt" "file:///tmp/other.fsh"))
  (check-false (hash-has-key? (state-documents s7) "file:///tmp/notes.txt"))
  ;; shutdown then exit, over the wire
  (define in (open-input-bytes (bytes-append (message->bytes (request 1 "initialize" (hasheq)))
                                             (message->bytes (request 2 "shutdown"))
                                             (message->bytes (notification "exit"))
                                             (message->bytes (request 3 "never-read")))))
  (define out (open-output-bytes))
  (serve in out)
  (define replies (let loop ([p (open-input-bytes (get-output-bytes out))] [acc '()])
                    (define m (read-message p)) (if (eof-object? m) (reverse acc) (loop p (cons m acc)))))
  (check-equal? (map message-id replies) '(1 2))
  (check-equal? (hash-ref (cadr replies) 'result) 'null)
  ;; over the wire, a didOpen publishes (asynchronously) before exit is processed
  (define in2 (open-input-bytes (bytes-append (message->bytes (notification "textDocument/didOpen" (hasheq 'textDocument (hasheq 'uri "file:///tmp/n.txt" 'languageId "plaintext" 'text "x"))))
                                              (message->bytes (request 7 "shutdown"))
                                              (message->bytes (notification "exit")))))
  (define out2 (open-output-bytes))
  (serve in2 out2)
  (sync (system-idle-evt))
  (define sent (let loop ([p (open-input-bytes (get-output-bytes out2))] [acc '()])
                 (define m (read-message p)) (if (eof-object? m) (reverse acc) (loop p (cons m acc)))))
  (check-true (and (member "textDocument/publishDiagnostics" (filter-map message-method sent)) #t))
  ;; a message that is not JSON gets a parse error
  (define-values (r8 s8 n8) (dispatch (hasheq 'jsonrpc "2.0" 'invalid #"x") s1))
  (check-equal? (hash-ref (hash-ref r8 'error) 'code) parse-error))
