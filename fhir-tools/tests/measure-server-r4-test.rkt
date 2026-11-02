#lang racket/base

;;; measure-server-r4-test.rkt — a measure-processing server GENERATED from the CQF Measures IG 5.0.0
;;; (its measure-calculation-service-example CapabilityStatement), executing CQL over its store.
;;;
;;; Loaded through the server's own transaction endpoint (POST /): two eCQMs (Breast and Colorectal
;;; Cancer Screening) with their Libraries (CQL as base64 Library.content), the 57 value sets they use,
;;; and their 65 test patients — the cql package's execution corpus (cql/tests/vendor/ecqm,
;;; cqframework/ecqm-content-r4-2021, CC0). Then Measure/{id}/$evaluate-measure per patient
;;; (individual MeasureReport) and without a subject (summary), compared with the corpus' expected
;;; populations. Differences the SERVER is right to have, named below:
;;;   - a resource whose subject is a bare id ("denomexcl-EXM125-frailtyWcRx", not Patient/…) or names
;;;     a sibling patient (numer-EXM130-sigmoidoscopy-FAIL-missing's Encounter: "…-5yr") is not in the
;;;     patient's data for a server, which retrieves in patient context (the corpus run counts the case
;;;     directory as the record)
;;;   - the corpus' own disagreements (cql/tests/measure-test.rkt): the two TZoffset-07 cases and
;;;     FitDNA-FAIL-category-laboratory
;;; Resource ids repeated across test cases (Encounter/denomexcl-EXM125-hospice is in two) would
;;; overwrite each other in one store, so a repeated id is prefixed with its case on loading.

(require rackunit racket/file racket/list racket/string json net/base64
         (only-in fhir/http/router handle)
         (only-in fhir/store/fhir-sqlite open-fhir-store close-fhir-store)
         (only-in fhir/spec-package spec-package-path)
         (only-in cql/run read-json-files)
         (only-in cql/tests/measure-harness run-measure-corpus case-result-measure case-result-case case-result-expected)
         fhir/store/ig-server)

(define corpus (collection-file-path "tests/vendor/ecqm" "cql"))
(define measures '("BreastCancerScreeningsFHIR" "ColorectalCancerScreeningsFHIR"))

(define db (make-temporary-file "measure-server-~a.db"))
(define store (open-fhir-store db))
(define srv (make-ig-server store (spec-package-path "hl7.fhir.us.cqfmeasures-5.0.0.tgz")
                            #:capability "measure-calculation-service-example" #:validate? #f #:offset -420))
(for ([g (in-list (ig-server-gaps srv))]) (eprintf "  unmet: ~s\n" (gap->list g)))
(check-equal? (ig-server-gaps srv) '())
(define app (ig-server-app srv))
(define (go method path [q '()] [body ""]) (call-with-values (lambda () (handle app method path q body)) list))

;; ---- load through the transaction endpoint -------------------------------------------------
(define (cql->library f)
  (define src (file->string f))
  (define m (regexp-match #px"library\\s+(\\S+)\\s+version\\s+'([^']+)'" src))
  (hasheq 'resourceType "Library" 'id (cadr m) 'name (cadr m) 'version (caddr m) 'status "active"
          'url (string-append "http://ecqi.healthit.gov/ecqms/Library/" (cadr m))
          'type (hasheq 'coding (list (hasheq 'system "http://terminology.hl7.org/CodeSystem/library-type" 'code "logic-library")))
          'content (list (hasheq 'contentType "text/cql" 'data (bytes->string/utf-8 (base64-encode (string->bytes/utf-8 src) #""))))))
(define cases
  (for*/list ([m (in-list measures)]
              [c (in-list (sort (map path->string (directory-list (build-path corpus "tests" m))) string<?))]
              #:when (directory-exists? (build-path corpus "tests" m c "Patient")))
    (cons m c)))
(define seen (make-hash))
(define patient-data
  (for*/list ([mc (in-list cases)] [r (in-list (read-json-files (build-path corpus "tests" (car mc) (cdr mc))))])
    (define key (cons (hash-ref r 'resourceType) (hash-ref r 'id)))
    (define r* (if (hash-ref seen key #f) (hash-set r 'id (string-append (cdr mc) "--" (hash-ref r 'id))) r))
    (hash-set! seen (cons (hash-ref r* 'resourceType) (hash-ref r* 'id)) #t)
    r*))
(define resources
  (append (for/list ([f (in-list (directory-list (build-path corpus "cql") #:build? #t))]) (cql->library f))
          (read-json-files (build-path corpus "valueset"))
          (for/list ([m (in-list measures)]) (call-with-input-file (build-path corpus "measure" (string-append m ".json")) read-json))
          patient-data))
(define tx (go "POST" "/" '()
               (jsexpr->string (hasheq 'resourceType "Bundle" 'type "transaction"
                                       'entry (for/list ([r (in-list resources)])
                                                (hasheq 'resource r 'request (hasheq 'method "PUT"
                                                                                     'url (format "~a/~a" (hash-ref r 'resourceType) (hash-ref r 'id)))))))))
(check-equal? (car tx) 200)

;; ---- evaluate ------------------------------------------------------------------------------
(define (populations report)
  (for/hash ([p (in-list (hash-ref (car (hash-ref report 'group)) 'population))])
    (values (hash-ref (car (hash-ref (hash-ref p 'code) 'coding)) 'code) (hash-ref p 'count))))
(define expected
  (for/hash ([r (in-list (run-measure-corpus corpus))] #:when (member (case-result-measure r) measures))
    (values (case-result-case r) (case-result-expected r))))
(define period '((periodStart . "2021-01-01") (periodEnd . "2021-12-31")))
(define disagree
  (for/list ([mc (in-list cases)]
             #:unless (let* ([pid (hash-ref (car (read-json-files (build-path corpus "tests" (car mc) (cdr mc) "Patient"))) 'id)]
                             [r (go "GET" (format "/Measure/~a/$evaluate-measure" (car mc)) (cons (cons 'subject (string-append "Patient/" pid)) period))])
                        (and (= (car r) 200)
                             (equal? (hash-ref (cadr r) 'type) "individual")
                             (for/and ([(k v) (in-hash (hash-ref expected (cdr mc)))]) (equal? v (hash-ref (populations (cadr r)) k #f))))))
    (cdr mc)))
(printf "  measure server (CQF Measures): ~a/~a patients' individual MeasureReports as expected\n"
        (- (length cases) (length disagree)) (length cases))
(check-equal? (sort disagree string<?)
              '("denomexcl-EXM125-frailtyWcRx" "numer-EXM130-FecalOccult-FAIL-1yr-TZoffset-07"
                "numer-EXM130-FitDNA-FAIL-3yr-TZoffset-07" "numer-EXM130-FitDNA-FAIL-category-laboratory"
                "numer-EXM130-sigmoidoscopy-FAIL-missing"))

;; a summary report over all stored patients; type level by canonical; errors as OperationOutcome
(define summary (go "GET" "/Measure/BreastCancerScreeningsFHIR/$evaluate-measure" period))
(check-equal? (car summary) 200)
(check-equal? (hash-ref (cadr summary) 'type) "summary")
(check-equal? (hash-ref (populations (cadr summary)) "initial-population") 17)
(check-true (hash-has-key? (car (hash-ref (cadr summary) 'group)) 'measureScore))
(define by-url (go "GET" "/Measure/$evaluate-measure"
                   (append '((measure . "http://ecqi.healthit.gov/ecqms/Measure/BreastCancerScreeningsFHIR")
                             (subject . "Patient/numer-EXM125-observation"))
                           period)))
(check-equal? (car by-url) 200)
(check-equal? (hash-ref (populations (cadr by-url)) "numerator") 1)
(check-equal? (car (go "GET" "/Measure/nope/$evaluate-measure" period)) 404)
(check-equal? (car (go "GET" "/Measure/BreastCancerScreeningsFHIR/$evaluate-measure")) 400)   ; periodStart 1..1

(close-fhir-store store)
(delete-file db)
