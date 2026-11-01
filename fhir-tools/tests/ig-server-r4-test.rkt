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

;; no unmet SHALL: every SHALL interaction, search parameter, include and operation is implemented
(define shall-gaps (filter (lambda (g) (equal? (gap-expectation g) "SHALL")) (ig-server-gaps srv)))
(for ([g (in-list shall-gaps)]) (eprintf "  unmet SHALL: ~s\n" (gap->list g)))
(check-equal? shall-gaps '())
(printf "  US Core server: ~a resource types; ~a unmet MAY/SHOULD requirements\n"
        (length (ig-plan-resources plan)) (length (ig-server-gaps srv)))

;; every example loads, validated against the profiles it claims
(define-values (loaded rejected) (load-ig-examples! srv))
(for ([r (in-list rejected)]) (eprintf "  rejected ~a: ~a\n" (car r) (cdr r)))
(check-equal? rejected '())
(check-true (>= loaded 230))

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
(check-equal? (length (ids (go "GET" "/DocumentReference/$docref" '((patient . "example"))))) 5)
(check-equal? (car (go "GET" "/DocumentReference/$docref")) 400)               ; patient is 1..1

;; writes are validated against the claimed profile (422), unprofiled writes accepted (201)
(check-equal? (car (go "POST" "/Patient" '()
                       (jsexpr->string (hasheq 'resourceType "Patient"
                                               'meta (hasheq 'profile (list "http://hl7.org/fhir/us/core/StructureDefinition/us-core-patient"))))))
              422)
(check-equal? (car (go "POST" "/Patient" '() (jsexpr->string (hasheq 'resourceType "Patient" 'gender "female")))) 201)

(close-fhir-store store)
(delete-file db)
