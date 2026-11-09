#lang racket/base

;;; capability-test.rkt — a FHIR server declared in a workspace (learn://capability, fhir-server's
;;; capability/guide.md): the guide's worked example, as `clinic.capability.rkt` in a workspace made by
;;; `init`, is checked on write (the problem the guide quotes, at its line), served on run over the
;;; workspace's SQLite store (what the workspace commits, the server finds), its operation applied
;;; through the running server, and explained.

(require rackunit racket/file racket/port racket/string json net/url
         fhir/mcp/workspace fhir/mcp/verbs fhir/mcp/init
         (only-in fhir/mcp/resources learn-text)
         (only-in fhir/mcp/tools tool-name tool-run))

(define guide (learn-text "capability"))
(define app (cadr (regexp-match #px"```racket\n(.*?)```" guide)))

(define dir (make-temporary-directory "cap-ws-~a"))
(void (init-workspace! dir))
(define h (open-hub dir))
(define tools (for/hash ([t (in-list (workspace-tools h))]) (values (tool-name t) t)))
(define (call name args)
  (define-values (text err?) ((tool-run (hash-ref tools name)) args))
  (check-false err? (format "~a: ~a" name text))
  (string->jsexpr text))

(with-hub h
  (lambda ()
    ;; the problem the guide quotes, word for word, at its line
    (define quoted (cadr (regexp-match #px"`(clinic[.]capability[.]rkt:[0-9]+:[0-9]+ error: [^`]*)`" guide)))
    (check-equal? (hash-ref (call "write" (hasheq 'path "clinic.capability.rkt" 'text (string-replace app "resource Observation" "resource Observaton")))
                            'problems)
                  (list quoted))
    (check-equal? (hash-ref (call "write" (hasheq 'path "clinic.capability.rkt" 'text app)) 'problems) '())
    ;; data committed by the workspace, served by the app: one SQLite store
    (call "stage" (hasheq 'fsh "Instance: ann\nInstanceOf: Patient\n* name.family = \"Ng\"\n* gender = #female\n"))
    (call "commit" (hasheq 'stage "stage-1"))
    (define r (call "run" (hasheq 'path "clinic.capability.rkt")))
    (check-equal? (map (lambda (row) (hash-ref row 'type)) (hash-ref r 'rows)) '("Patient" "Observation" "StructureMap" "(system)"))
    (define url (hash-ref (hash-ref r 'summary) 'url))
    (define found (call/input-url (string->url (string-append url "/Patient?family=ng")) get-pure-port read-json))
    (check-equal? (map (lambda (e) (hash-ref (hash-ref e 'resource) 'id)) (hash-ref found 'entry)) '("ann"))
    ;; a resource the app writes is in the workspace's store
    (call/input-url (string->url (string-append url "/Patient"))
                    (lambda (u) (post-pure-port u (string->bytes/utf-8 (jsexpr->string (hasheq 'resourceType "Patient" 'id "bob" 'gender "male")))
                                                '("Content-Type: application/fhir+json")))
                    port->string)
    (check-equal? (hash-ref (call "query" (hasheq 'language "sql" 'text "SELECT count(*) AS n FROM Patient")) 'rows) (list (hasheq 'n 2)))
    ;; the app's own operation, through apply
    (check-equal? (call "apply" (hasheq 'operation "$bmi" 'inputs (hasheq 'weight 80 'height 180)))
                  (hasheq 'resourceType "Parameters" 'parameter (list (hasheq 'name "bmi" 'valueDecimal 24.7))))
    (check-equal? (hash-ref (call "explain" (hasheq 'ref "clinic.capability.rkt" 'subject "Patient")) 'type) "Patient")))

(delete-directory/files dir)
