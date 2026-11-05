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

(require racket/contract racket/match racket/list racket/string
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
  (hasheq 'textDocumentSync (hasheq 'openClose #t 'change 1 'save (hasheq 'includeText #t))))   ; 1 = full text

;; ---- the handlers, a table -------------------------------------------------------------------
;; A RequestHandler is (params state -> (values result state notifications))
(define request-handlers
  (hash "initialize"
        (lambda (params st)
          (values (hasheq 'capabilities server-capabilities
                          'serverInfo (hasheq 'name "fhir-lsp" 'version "0.1"))
                  st '()))
        "shutdown"
        (lambda (params st) (values (json-null) (struct-copy state st [down? #t]) '()))))

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

;; serve : [in out] -> void   read, dispatch, write, until `exit` or the stream ends
(define (serve [in (current-input-port)] [out (current-output-port)])
  (let loop ([st initial-state])
    (define m (read-message in))
    (unless (eof-object? m)
      (define-values (resp st* notes) (dispatch m st))
      (for ([n (in-list notes)]) (write-message n out))
      (when resp (write-message resp out))
      (unless (equal? (message-method m) "exit") (loop st*)))))

(module+ test
  (require rackunit)
  ;; the handshake
  (define-values (r1 s1 n1) (dispatch (request 1 "initialize" (hasheq 'rootUri 'null)) initial-state))
  (check-equal? (hash-ref (hash-ref r1 'result) 'capabilities) server-capabilities)
  (check-equal? n1 '())
  ;; an unknown request is an error; an unknown notification is nothing
  (define-values (r2 s2 n2) (dispatch (request 2 "textDocument/hover" (hasheq)) s1))
  (check-equal? (hash-ref (hash-ref r2 'error) 'code) method-not-found)
  (define-values (r3 s3 n3) (dispatch (notification "workspace/didChangeConfiguration" (hasheq)) s1))
  (check-false r3) (check-equal? n3 '())
  ;; a document in no language of ours: stored, and published with no diagnostics
  (define-values (r4 s4 n4) (dispatch (notification "textDocument/didOpen"
                                                    (hasheq 'textDocument (hasheq 'uri "file:///tmp/notes.txt" 'languageId "plaintext" 'text "hi")))
                                      s1))
  (check-equal? (hash-ref (state-documents s4) "file:///tmp/notes.txt") "hi")
  (check-equal? n4 (list (publish-diagnostics "file:///tmp/notes.txt" '())))
  ;; a fhirpath document: a syntax error is published at its position (the fhirpath package, when installed)
  (when (language-by-id "fhirpath")
    (define-values (r5 s5 n5) (dispatch (notification "textDocument/didOpen"
                                                      (hasheq 'textDocument (hasheq 'uri "file:///tmp/x.fhirpath" 'languageId "fhirpath" 'text "name.given(")))
                                        s4))
    (check-equal? (length n5) 1)
    (define ds (hash-ref (hash-ref (car n5) 'params) 'diagnostics))
    (when (with-handlers ([exn:fail? (lambda (_) #f)]) (dynamic-require 'fhirpath/parser/parse 'parse-fhirpath))
      (check-equal? (length ds) 1)
      (check-equal? (hash-ref (car ds) 'severity) 1)))
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
  ;; a message that is not JSON gets a parse error
  (define-values (r8 s8 n8) (dispatch (hasheq 'jsonrpc "2.0" 'invalid #"x") s1))
  (check-equal? (hash-ref (hash-ref r8 'error) 'code) parse-error))
