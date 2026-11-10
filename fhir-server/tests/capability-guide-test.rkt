#lang racket/base

;;; capability-guide-test.rkt — the capability guide's "An output with a unit" runs as it says: its
;;; Racket block, in an app, answers the Quantity the text shows (fhir-mcp's capability-test runs the
;;; worked example; this is the part an agent asked for after it).

(require rackunit racket/file racket/string json
         (only-in fhir/r6/types)
         fhir/http/router)

(define guide (file->string (collection-file-path "capability/guide.md" "fhir")))
(define block (cadr (regexp-match #px"## An output with a unit\n.*?```racket\n(.*?)```" guide)))
(define dir (make-temporary-directory "cap-guide-~a"))
(define src (build-path dir "creatinine.rkt"))
(void (call-with-output-file src (lambda (o) (write-string (string-append "#lang fhir/capability\n(server)\n" block) o))))
(define app (dynamic-require src 'app))
(define-values (st js) (handle app "GET" "/$creatinine-si" '((creatinine . "1.1")) ""))
(check-equal? st 200)
(check-equal? (hash-ref (car (hash-ref js 'parameter)) 'valueQuantity)
              (hasheq 'value 97.2 'unit "µmol/L" 'system "http://unitsofmeasure.org" 'code "umol/L"))
;; and the text says so
(check-regexp-match #rx"\"valueQuantity\": [{]\"value\": 97.2" guide)
;; #:documentation is each parameter's documentation in the derived OperationDefinition
(define-values (ost od) (handle app "GET" "/OperationDefinition/creatinine-si" '() ""))
(check-equal? ost 200)
(check-equal? (for/list ([p (hash-ref od 'parameter)]) (list (hash-ref p 'use) (hash-ref p 'documentation #f)))
              '(("in" "Serum creatinine, mg/dL") ("out" "The same value in µmol/L")))
(delete-directory/files dir)

;; the smoke test as the guide writes it: the worked example served on a free port, the url read from
;; the banner, every request answered (a rerun's agent had to write its own wait loop)
(require racket/system racket/port)
(when (and (find-executable-path "bash") (find-executable-path "curl"))
  (define app-text (cadr (regexp-match #px"## Worked example.*?```racket\n(.*?)```" guide)))
  (define sh (cadr (regexp-match #px"A smoke test.*?```sh\n(.*?)```" guide)))
  (define d (make-temporary-directory "cap-smoke-~a"))
  (call-with-output-file (build-path d "clinic.capability.rkt") (lambda (o) (write-string app-text o)))
  (parameterize ([current-directory d])
    (check-true (parameterize ([current-output-port (open-output-nowhere)]) (system* (find-executable-path "bash") "-c" sh)))
    (define log (file->string (build-path d "serve.log")))
    (check-regexp-match #rx"^FHIR server on http://localhost:[0-9]+ " log)
    (check-regexp-match #rx"\nsearch: strict" log)
    (for ([line '("GET /metadata 200" "POST /Patient 201" "GET /Patient[?]gender=female 200" "GET /[$]bmi[?]weight=80&height=180 200")])
      (check-regexp-match (regexp line) log)))
  (delete-directory/files d))
