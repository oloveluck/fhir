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

(delete-directory/files dir)
