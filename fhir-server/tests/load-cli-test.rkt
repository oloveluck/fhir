#lang racket/base

;;; load-cli-test.rkt — `raco fhir-server load … --validate`: every resource the load would write
;;; (a Bundle's entries too) is held to its type and the profiles it claims first; each problem is
;;; said with its file, and nothing is loaded when one is an error. Without the flag the load checks
;;; nothing: a store filled that way held `"gender": "femme"`, and a server over it served it.

(require rackunit racket/file racket/system racket/port racket/string)

(define dir (make-temporary-directory "load-cli-~a"))
(define data (build-path dir "data"))
(make-directory data)
(define db (build-path dir "a.db"))
(define (put! name text) (display-to-file text (build-path data name) #:exists 'replace))
(put! "ann.json" "{\"resourceType\":\"Patient\",\"id\":\"ann\",\"gender\":\"female\",\"birthDate\":\"1980-02-01\"}")
(put! "bea.json" "{\"resourceType\":\"Patient\",\"id\":\"bea\",\"gender\":\"femme\",\"birthDate\":\"1980-02-30\"}")
(put! "bundle.json"
      (string-append "{\"resourceType\":\"Bundle\",\"type\":\"collection\",\"entry\":["
                     "{\"resource\":{\"resourceType\":\"Observation\",\"id\":\"o1\",\"status\":\"final\",\"code\":{\"text\":\"x\"}}},"
                     "{\"resource\":{\"resourceType\":\"Observation\",\"id\":\"o2\",\"code\":{\"text\":\"x\"}}}]}"))

(define (load . flags)
  (define out (open-output-string))
  (define code (parameterize ([current-output-port out] [current-error-port out])
                 (apply system*/exit-code (find-executable-path "raco") "fhir-server" "load"
                        (path->string db) (path->string data) flags)))
  (values code (get-output-string out)))

;; two invalid resources, one of them inside a Bundle: each problem with its file, nothing written
(let-values ([(code out) (load "--validate")])
  (check-equal? code 1 out)
  (check-regexp-match #rx"bea.json: Patient/bea: error: Patient.gender: code `femme` not in required value set" out)
  (check-regexp-match #rx"bea.json: Patient/bea: error: Patient.birthDate: '1980-02-30' is not a valid date" out)
  (check-regexp-match #rx"bundle.json: Observation/o2: error: Observation.status: minimum required = 1" out)
  (check-regexp-match #rx"2 of 4 resource\\(s\\) are not valid FHIR 4.0.1 \\(3 error\\(s\\)\\): nothing was loaded" out)
  (check-false (file-exists? db) "nothing was loaded: no store was made"))

;; a package nothing provides is a usage error, before anything is read
(let-values ([(code out) (load "--validate" "--package" "no.such.package")])
  (check-equal? code 2 out)
  (check-regexp-match #rx"no package no.such.package" out))

;; valid data: said, then loaded as before
(delete-file (build-path data "bea.json"))
(put! "bundle.json"
      (string-append "{\"resourceType\":\"Bundle\",\"type\":\"collection\",\"entry\":["
                     "{\"resource\":{\"resourceType\":\"Observation\",\"id\":\"o1\",\"status\":\"final\",\"code\":{\"text\":\"x\"}}}]}"))
(let-values ([(code out) (load "--validate")])
  (check-equal? code 0 out)
  (check-regexp-match #rx"validated 2 resource\\(s\\) as FHIR 4.0.1\n" out)
  (check-regexp-match #rx"loaded 2 resources into " out))

;; bulk data: a resource to a line (.ndjson), gzipped or not, loaded under the ids the files give —
;; so the references between files hold — and found by search afterwards
(require (only-in file/gzip gzip-through-ports)
         (only-in fhir/store/fhir-sqlite open-fhir-store close-fhir-store)
         (only-in fhir/store/fhir-engine fhir-read))
(define bulk (build-path dir "bulk"))
(make-directory bulk)
(display-to-file (string-append "{\"resourceType\":\"Patient\",\"id\":\"p1\",\"gender\":\"female\"}\n"
                                "\n"
                                "not json\n"
                                "{\"resourceType\":\"Patient\",\"id\":\"p2\",\"gender\":\"male\"}\n")
                 (build-path bulk "Patient.ndjson"))
(let ([text (string-append "{\"resourceType\":\"Observation\",\"id\":\"o1\",\"status\":\"final\",\"code\":{\"text\":\"x\"},\"subject\":{\"reference\":\"Patient/p1\"}}\n"
                           "{\"resourceType\":\"Observation\",\"id\":\"o2\",\"status\":\"final\",\"code\":{\"text\":\"x\"},\"subject\":{\"reference\":\"Patient/p2\"}}\n")])
  (call-with-output-file (build-path bulk "Observation.ndjson.gz")
    (lambda (out) (gzip-through-ports (open-input-string text) out #f 0))))
(define bulk-db (build-path dir "bulk.db"))
(let ()
  (define out (open-output-string))
  (define code (parameterize ([current-output-port out] [current-error-port out])
                 (system*/exit-code (find-executable-path "raco") "fhir-server" "load" (path->string bulk-db) (path->string bulk))))
  (check-equal? code 0 (get-output-string out))
  (check-regexp-match #rx"Observation.ndjson.gz: 2 resource" (get-output-string out))
  (check-regexp-match #rx"Patient.ndjson: 2 resource" (get-output-string out))
  (check-regexp-match #rx"loaded 4 resources" (get-output-string out))
  (define store (open-fhir-store bulk-db))
  (check-equal? (hash-ref (fhir-read store "Patient" "p2") 'gender) "male")           ; the file's id, kept
  (check-equal? (hash-ref (hash-ref (fhir-read store "Observation" "o1") 'subject) 'reference) "Patient/p1")
  (close-fhir-store store))

(delete-directory/files dir)
