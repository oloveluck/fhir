#lang racket/base

;;; conditional-writes-test.rkt — writes conditional on a search (https://hl7.org/fhir/http.html
;;; #ccreate, #cond-update, #cdelete), through `answer`, with no socket:
;;;   - a create with If-None-Exist is made when the search finds nothing, answered with the
;;;     resource found when it finds one (nothing written), refused (412) when it finds several;
;;;   - PUT /Type?search creates when nothing matches, updates the one that does, refuses a body
;;;     whose id is another and a search that finds several;
;;;   - DELETE /Type?search deletes the one that matches;
;;;   - the criteria are held strictly: a parameter the server does not search on is a 400.
;;; None of these were served: PUT and DELETE on /Type were "not allowed", and If-None-Exist was
;;; ignored, so a client retrying a create made a second copy.

(require rackunit racket/file
         (only-in json bytes->jsexpr)
         (only-in fhir/http/server answer response-status response-body response-headers))

(define dir (make-temporary-directory "conditional-writes-~a"))
(define app-file (build-path dir "clinic.rkt"))
(void (call-with-output-file app-file
        (lambda (o) (write-string (string-append "#lang fhir/capability\n(server #:url \"http://example.org/fhir\")\n"
                                                 "(resource Patient #:interactions (read vread create update delete search-type history-instance)"
                                                 " #:search-params ([identifier token] [gender token]))\n") o))))
(define app (dynamic-require app-file 'app))
(define host '(("host" . "localhost:8080")))
(define (ask method target [headers '()] [body ""]) (answer app method target (append host headers) body))
(define (json r) (bytes->jsexpr (response-body r)))
(define (patient mrn gender [id #f])
  (format "{\"resourceType\":\"Patient\",~a\"identifier\":[{\"system\":\"urn:mrn\",\"value\":\"~a\"}],\"gender\":\"~a\"}"
          (if id (format "\"id\":\"~a\"," id) "") mrn gender))
(define (total q) (hash-ref (json (ask "GET" (string-append "/Patient?" q))) 'total))
(define (diagnostics r) (hash-ref (car (hash-ref (json r) 'issue)) 'diagnostics))

;; conditional create: made once, then answered with what is there
(define once (ask "POST" "/Patient" '(("if-none-exist" . "identifier=urn:mrn|1")) (patient 1 "female")))
(check-equal? (response-status once) 201)
(define id1 (hash-ref (json once) 'id))
(define twice (ask "POST" "/Patient" '(("if-none-exist" . "identifier=urn:mrn|1")) (patient 1 "female")))
(check-equal? (response-status twice) 200)
(check-equal? (hash-ref (json twice) 'id) id1)
(check-equal? (total "identifier=urn:mrn|1") 1)
;; written as the query a client would put after `Patient?`, the same
(check-equal? (response-status (ask "POST" "/Patient" '(("if-none-exist" . "Patient?identifier=urn:mrn|1")) (patient 1 "female"))) 200)
;; several match: refused, nothing written
(check-equal? (response-status (ask "POST" "/Patient" '() (patient 1 "male"))) 201)
(define many (ask "POST" "/Patient" '(("if-none-exist" . "identifier=urn:mrn|1")) (patient 1 "female")))
(check-equal? (response-status many) 412)
(check-regexp-match #rx"matches 2 Patient resources" (diagnostics many))
(check-equal? (total "identifier=urn:mrn|1") 2)
;; criteria the server does not search on are the client's error, not ignored
(define unknown (ask "POST" "/Patient" '(("if-none-exist" . "family=Ng")) (patient 9 "female")))
(check-equal? (response-status unknown) 400)
(check-equal? (total "identifier=urn:mrn|9") 0)

;; conditional update: created when nothing matches, then updated in place
(define made (ask "PUT" "/Patient?identifier=urn:mrn|2" '() (patient 2 "female")))
(check-equal? (response-status made) 201)
(define id2 (hash-ref (json made) 'id))
(define changed (ask "PUT" "/Patient?identifier=urn:mrn|2" '() (patient 2 "other")))
(check-equal? (response-status changed) 200)
(check-equal? (hash-ref (json changed) 'id) id2)
(check-equal? (hash-ref (hash-ref (json changed) 'meta) 'versionId) "2")
(check-equal? (hash-ref (json (ask "GET" (format "/Patient/~a" id2))) 'gender) "other")
(define other-id (ask "PUT" "/Patient?identifier=urn:mrn|2" '() (patient 2 "male" "someone-else")))
(check-equal? (response-status other-id) 400)
(check-regexp-match #rx"the body's id is someone-else" (diagnostics other-id))
(check-equal? (response-status (ask "PUT" "/Patient?identifier=urn:mrn|1" '() (patient 1 "male"))) 412)
;; a body that names an id, with nothing matching: created under it
(check-equal? (response-status (ask "PUT" "/Patient?identifier=urn:mrn|3" '() (patient 3 "male" "chosen"))) 201)
(check-equal? (hash-ref (json (ask "GET" "/Patient/chosen")) 'gender) "male")

;; conditional delete: the one that matches, then nothing to do
(check-equal? (response-status (ask "DELETE" "/Patient?identifier=urn:mrn|2")) 200)
(check-equal? (response-status (ask "GET" (format "/Patient/~a" id2))) 410)
(define nothing (ask "DELETE" "/Patient?identifier=urn:mrn|2"))
(check-equal? (response-status nothing) 200)
(check-regexp-match #rx"nothing to delete" (diagnostics nothing))
(check-equal? (response-status (ask "DELETE" "/Patient?identifier=urn:mrn|1")) 412)
(check-equal? (total "identifier=urn:mrn|1") 2)

;; a plain create and a plain search are what they were
(check-equal? (response-status (ask "POST" "/Patient" '() (patient 4 "female"))) 201)
(check-equal? (total "gender=female") 2)

(delete-directory/files dir)
