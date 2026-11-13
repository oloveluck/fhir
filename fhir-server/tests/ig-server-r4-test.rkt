#lang racket/base

;;; ig-server-r4-test.rkt — a FHIR server generated from US Core 9.0.0 (store/ig-server.rkt).
;;; RATCHETED: no unmet SHALL requirement (the IG's own server CapabilityStatement is the spec); every
;;; example the IG ships loads through write validation; /metadata is the IG's statement as an
;;; instance; the SHALL behaviours answer over the HTTP router (search, includes, $docref, 422 on a
;;; profile violation).

(require rackunit racket/file racket/list json
         (only-in fhir/http/router handle)
         (only-in fhir/store/fhir-sqlite open-fhir-store close-fhir-store)
         fhir/store/ig-server)

(define db (make-temporary-file "ig-server-~a.db"))
(define store (open-fhir-store db))
(define srv (make-ig-server store (ig-package-path "hl7.fhir.us.core")))
(define plan (ig-server-plan srv))
(check-equal? (ig-plan-fhir-version plan) "4.0.1")

;; no unmet requirement at ANY level (SHALL, SHOULD, MAY): every interaction, search parameter,
;; include and operation of US Core's server CapabilityStatement is implemented
(for ([g (in-list (ig-server-gaps srv))]) (eprintf "  unmet: ~s\n" (gap->list g)))
(check-equal? (ig-server-gaps srv) '())
(printf "  US Core server: ~a resource types; ~a unmet requirements\n"
        (length (ig-plan-resources plan)) (length (ig-server-gaps srv)))

;; every example loads, validated against the profiles it claims
(define-values (loaded rejected) (load-ig-examples! srv))
(for ([r (in-list rejected)]) (eprintf "  rejected ~a: ~a\n" (car r) (cdr r)))
(check-equal? rejected '())
(check-true (>= loaded 255))                                   ; examples + the IG's ValueSets/CodeSystems

(define app (ig-server-app srv))
(define (go method path [q '()] [body ""]) (call-with-values (lambda () (handle app method path q body)) list))
(define (ids r) (for/list ([e (in-list (hash-ref (cadr r) 'entry '()))])
                  (list (hash-ref (hash-ref e 'search (hasheq)) 'mode #f) (hash-ref (hash-ref e 'resource) 'id))))

;; /metadata: the IG's statement, as an instance, trimmed to what runs
(define md (go "GET" "/metadata"))
(check-equal? (car md) 200)
(check-equal? (hash-ref (cadr md) 'kind) "instance")
(check-equal? (length (hash-ref (car (hash-ref (cadr md) 'rest)) 'resource)) (length (ig-plan-resources plan)))

;; search (string, date, token+reference combination), includes, $docref
(check-equal? (length (ids (go "GET" "/Patient" '((name . "shaw"))))) 2)
(check-equal? (length (ids (go "GET" "/Patient" '((birthdate . "1987-02-20"))))) 1)
(check-true (pair? (ids (go "GET" "/Observation" '((patient . "example") (category . "laboratory"))))))
(check-equal? (ids (go "GET" "/MedicationRequest" '((_id . "medicationrequest-referenced-oral-axid")
                                                     (_include . "MedicationRequest:medication"))))
              '(("match" "medicationrequest-referenced-oral-axid") ("include" "uscore-med2")))
;; `*`: every reference parameter (medication, patient/subject, requester, encounter, …)
(define wild (ids (go "GET" "/MedicationRequest" '((_id . "medicationrequest-referenced-oral-axid")
                                                   (_include . "MedicationRequest:*")))))
(check-not-false (member '("include" "uscore-med2") wild))
(check-true (> (length wild) 2))
(check-equal? (ids (go "GET" "/Patient" '((_id . "example") (_revinclude . "Encounter:*"))))
              (ids (go "GET" "/Patient" '((_id . "example") (_revinclude . "Encounter:patient")))))
(check-equal? (length (ids (go "GET" "/DocumentReference/$docref" '((patient . "example"))))) 5)
(check-equal? (car (go "GET" "/DocumentReference/$docref")) 400)               ; patient is 1..1

;; writes are validated against the claimed profile (422), unprofiled writes accepted (201)
(check-equal? (car (go "POST" "/Patient" '()
                       (jsexpr->string (hasheq 'resourceType "Patient"
                                               'meta (hasheq 'profile (list "http://hl7.org/fhir/us/core/StructureDefinition/us-core-patient"))))))
              422)
(check-equal? (car (go "POST" "/Patient" '() (jsexpr->string (hasheq 'resourceType "Patient" 'gender "female")))) 201)

;; history (instance + type), with versions from a PUT and a PATCH
(define p0 (cadr (go "GET" "/Patient/example")))
(check-equal? (car (go "PUT" "/Patient/example" '() (jsexpr->string (hash-set p0 'active #f)))) 200)
(check-equal? (car (go "PATCH" "/Patient/example" '()
                       (jsexpr->string (list (hasheq 'op "add" 'path "/gender" 'value "female")))))
              200)
(define hist (cadr (go "GET" "/Patient/example/_history")))
(check-equal? (hash-ref hist 'type) "history")
(check-equal? (map (lambda (e) (hash-ref (hash-ref e 'request) 'method)) (hash-ref hist 'entry)) '("PUT" "PUT" "POST"))
(check-equal? (hash-ref (cadr (go "GET" "/Patient/_history" '((_count . "1")))) 'total) 1)
;; PATCH: a failing `test` and a profile violation are both 422; a malformed body 400
(check-equal? (car (go "PATCH" "/Patient/example" '()
                       (jsexpr->string (list (hasheq 'op "test" 'path "/gender" 'value "male"))))) 422)
(check-equal? (car (go "PATCH" "/Patient/example" '() (jsexpr->string (list (hasheq 'op "remove" 'path "/name"))))) 422)
(check-equal? (car (go "PATCH" "/Patient/example" '() "{}")) 400)
;; ValueSet $expand: core and IG value sets, by url, with a filter, at instance level
(define (expansion-size r) (length (hash-ref (hash-ref (cadr r) 'expansion) 'contains '())))
(check-equal? (expansion-size (go "GET" "/ValueSet/$expand" '((url . "http://hl7.org/fhir/ValueSet/administrative-gender")))) 4)
(check-equal? (expansion-size (go "GET" "/ValueSet/$expand" '((url . "http://hl7.org/fhir/ValueSet/administrative-gender")
                                                                (filter . "fem")))) 1)
(check-equal? (expansion-size (go "GET" "/ValueSet/us-core-observation-smoking-status-status/$expand")) 2)
(check-equal? (car (go "GET" "/ValueSet/$expand" '((url . "http://example.org/none")))) 404)
(check-equal? (car (go "GET" "/ValueSet/$expand")) 400)

;; a Bundle's writes are held to what a single write is: a transaction with an invalid entry is refused
;; whole, a batch answers that entry and writes the others (POST / stored "femme" before)
(let* ([entry (lambda (id gender) (hasheq 'resource (hasheq 'resourceType "Patient" 'id id 'gender gender)
                                          'request (hasheq 'method "PUT" 'url (string-append "Patient/" id))))]
       [bundle (lambda (type) (jsexpr->string (hasheq 'resourceType "Bundle" 'type type
                                                      'entry (list (entry "tx-ok" "female") (entry "tx-bad" "femme")))))]
       [refused (go "POST" "/" '() (bundle "transaction"))])
  (check-equal? (car refused) 400)
  (check-regexp-match #rx"nothing was written: Bundle.entry\\[1\\] [(]Patient[)]: Patient.gender: code `femme`"
                      (hash-ref (car (hash-ref (cadr refused) 'issue)) 'diagnostics))
  (check-equal? (car (go "GET" "/Patient/tx-ok")) 404)
  (define answered (go "POST" "/" '() (bundle "batch")))
  (check-equal? (map (lambda (e) (hash-ref (hash-ref e 'response) 'status)) (hash-ref (cadr answered) 'entry))
                '("201 Created" "422 Unprocessable Entity"))
  (check-equal? (car (go "GET" "/Patient/tx-ok")) 200)
  (check-equal? (car (go "GET" "/Patient/tx-bad")) 404))
;; transaction and batch are listed once each (the IG lists them itself)
(check-equal? (map (lambda (i) (hash-ref i 'code)) (hash-ref (car (hash-ref (cadr md) 'rest)) 'interaction)) '("transaction" "batch"))

(close-fhir-store store)
(delete-file db)
