#lang racket/base

;;; state-test.rkt — what one process stages or computes, another uses: two hubs over one workspace
;;; (as two `raco fhir-mcp call`s are), a stage made by the first committed by the second, a result
;;; described, joined in SQL and staged from; numbers continue; results and stages count apart.

(require rackunit racket/file json racket/system
         fhir/mcp/workspace fhir/mcp/verbs fhir/mcp/init
         (only-in fhir/mcp/tools tool-name tool-run))

(define dir (make-temporary-directory "state-~a"))
(void (init-workspace! dir))
(define (tools-of h) (for/hash ([t (in-list (workspace-tools h))]) (values (tool-name t) t)))
(define (call h name args)
  (define-values (text err?) ((tool-run (hash-ref (tools-of h) name)) args))
  (check-false err? (format "~a: ~a" name text))
  (with-handlers ([exn:fail? (lambda (_) text)]) (string->jsexpr text)))

(define a (open-hub dir))
(define s1 (with-hub a (lambda () (call a "stage" (hasheq 'fsh "Instance: ann\nInstanceOf: Patient\n* gender = #female\n")))))
(check-equal? (hash-ref s1 'stage) "stage-1")
(define q1 (with-hub a (lambda () (call a "query" (hasheq 'language "fhirpath" 'text "Patient.gender" 'over "Patient")))))
(check-equal? (hash-ref q1 'result) "result://r1")                 ; results count on their own

;; a second process: commits the first one's stage, reads its result
(define b (open-hub dir))
(with-hub b
  (lambda ()
    (check-regexp-match #rx"^Provenance/" (hash-ref (call b "commit" (hasheq 'stage "stage-1" 'reason "from another process")) 'provenance))
    (check-equal? (hash-ref (call b "describe" (hasheq 'ref "result://r1")) 'kind) (hash-ref q1 'kind))
    (define q2 (call b "query" (hasheq 'language "sql" 'text "SELECT count(*) AS n FROM Patient")))
    (check-equal? (hash-ref q2 'result) "result://r2")             ; numbers continue from what is saved
    (check-equal? (hash-ref q2 'rows) (list (hasheq 'n 1)))
    (check-equal? (hash-ref (call b "stage" (hasheq 'fsh "Instance: bob\nInstanceOf: Patient\n")) 'stage) "stage-2")))  ; a committed stage's number is not reused
;; a committed stage is gone for everyone
(define-values (t err?) ((tool-run (hash-ref (tools-of a) "commit")) (hasheq 'stage "stage-9")))
(check-true err?)
(check-regexp-match #rx"no stage stage-9 [(]stages: stage-2[)]" t)
;; the stages not committed are listed and can be dropped; a create reads "created"
(define c (open-hub dir))
(with-hub c
  (lambda ()
    (define st (call c "describe" (hasheq 'ref "stages")))
    (check-equal? (map (lambda (s) (hash-ref s 'stage)) (hash-ref st 'stages)) '("stage-2"))
    (check-equal? (hash-ref (car (hash-ref st 'stages)) 'resources) '("create Patient/bob"))
    (check-equal? (hash-ref (car (hash-ref (call c "stage" (hasheq 'fsh "Instance: cy\nInstanceOf: Patient\n")) 'changes)) 'changed) "created")
    (check-equal? (hash-ref (call c "stage" (hasheq 'drop "stage-2")) 'stages) '("stage-3"))
    (check-equal? (map (lambda (s) (hash-ref s 'stage)) (hash-ref (call c "describe" (hasheq 'ref "stages")) 'stages)) '("stage-3"))))
;; the shell: a call whose answer counts errors exits 1
(define (shell . words)
  (define out (open-output-string))
  (define code (parameterize ([current-output-port out] [current-error-port out])
                 (apply system*/exit-code (find-executable-path "raco") "fhir-mcp" "call" (append words (list "--workspace" (path->string dir))))))
  (values code (get-output-string out)))
(let-values ([(code out) (shell "stage" "resources:=[{\"resourceType\": \"Patient\", \"gender\": \"femme\"}]")])
  (check-equal? code 1 out)
  (check-regexp-match #rx"\"errors\":[1-9]" out))
(let-values ([(code out) (shell "query" "language=sql" "text=SELECT count(*) AS n FROM Patient")])
  (check-equal? code 0 out))
(delete-directory/files dir)
