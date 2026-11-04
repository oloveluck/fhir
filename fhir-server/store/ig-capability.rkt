#lang racket/base

;;; ig-capability.rkt — the IG's server CapabilityStatement held against what a server executes.
;;;
;;; Two readings of the same statement, both pure functions of the statement and of what the server
;;; can do: the GAPS (every requirement the server does not meet, with the IG's SHALL/SHOULD/MAY) and
;;; the INSTANCE statement the server publishes at /metadata (the IG's own statement, trimmed to the
;;; interactions, parameters, includes and operations that run — everything trimmed is a gap).
;;;
;;; Data definitions
;;;   An Executes is (executes interaction? search-param? include? operation?) — what the server runs:
;;;     interaction?  : code -> Boolean                 ("read", "search-type", …)
;;;     search-param? : type name -> Boolean            (an executable, indexed parameter of the type)
;;;     include?      : include-string -> Boolean       ("Source:param[:Target]")
;;;     operation?    : canonical -> Boolean            (an OperationDefinition url, unversioned)
;;;   A Gap is (gap type what name expectation reason) — one IG requirement the server does not meet
;;;     type : a resource type, or "*" for the system level
;;;     what : 'resource | 'interaction | 'search-param | '_include | '_revinclude | 'operation
;;;   The statement itself is jsexpr: `rest` is its rest.mode = server entry, `res` one rest.resource.

(require racket/contract racket/list racket/string racket/date
         (only-in "ig-plan.rkt" ig-plan? ig-plan-ig-cs ig-plan-name ig-plan-version ig-plan-resources
                  ig-resource? ig-resource-type ig-resource-interactions ig-resource-search-params
                  expectation-of server-rest))

(provide
 (struct-out gap) (struct-out executes)
 (contract-out
  [gap->list           (-> gap? list?)]
  [plan-gaps           (-> ig-plan? (listof ig-resource?) executes? (listof gap?))]
  [instance-capability (-> ig-plan? (listof ig-resource?) executes? (or/c string? #f) hash?)]
  [includes-of         (-> hash? symbol? (listof string?))]
  [searchable?         (-> hash? boolean?)]))

(struct gap (type what name expectation reason) #:transparent)
(struct executes (interaction? search-param? include? operation?))

;; gap->list : Gap -> list   the gap as a row
(define (gap->list g) (list (gap-type g) (gap-what g) (gap-name g) (gap-expectation g) (gap-reason g)))

;; ---- reading the statement ----------------------------------------------------------------------

;; searchable? : rest.resource -> Boolean   does it declare search-type?
(define (searchable? res)
  (for/or ([i (in-list (hash-ref res 'interaction '()))]) (equal? (hash-ref i 'code #f) "search-type")))

;; has-interaction? : IgResource code -> Boolean
(define (has-interaction? r code) (and (assoc code (ig-resource-interactions r)) #t))

;; includes-of : rest.resource 'searchInclude|'searchRevInclude -> (listof string)
;; its include values; a bare parameter name in searchInclude (Da Vinci Drug Formulary writes
;; `formulary-coverage`) is read as the resource's own: `InsurancePlan:formulary-coverage`
(define (includes-of res k)
  (for/list ([v (in-list (hash-ref res k '()))])
    (if (and (eq? k 'searchInclude) (not (regexp-match? #rx":" v)))
        (string-append (hash-ref res 'type) ":" v)
        v)))

;; operation-implemented? : Executes rest.operation -> Boolean   by its definition's canonical
(define (operation-implemented? ex cs-op)
  (define def (hash-ref cs-op 'definition #f))
  (and (string? def) ((executes-operation? ex) (car (string-split def "|"))) #t))

;; ---- the gaps -----------------------------------------------------------------------------------

;; plan-gaps : IgPlan (listof IgResource) Executes -> (listof Gap)
;; every requirement of the IG's statement the server does not meet; `served` are the plan's
;; resources whose type the FHIR version has
(define (plan-gaps plan served ex)
  (append
   (for*/list ([r (in-list (ig-plan-resources plan))] #:unless (memq r served))
     (gap (ig-resource-type r) 'resource (ig-resource-type r) "SHALL" "type not in this FHIR version's tower"))
   (append-map (lambda (r) (resource-gaps r ex)) served)
   (rest-gaps (server-rest (ig-plan-ig-cs plan)) ex)))

;; resource-gaps : IgResource Executes -> (listof Gap)   its interactions and parameters not run
(define (resource-gaps r ex)
  (define type (ig-resource-type r))
  (define searches? (has-interaction? r "search-type"))
  (append
   (for/list ([i (in-list (ig-resource-interactions r))] #:unless ((executes-interaction? ex) (car i)))
     (gap type 'interaction (car i) (cdr i) "interaction not implemented"))
   (for/list ([sp (in-list (ig-resource-search-params r))]
              #:unless (and searches? ((executes-search-param? ex) type (car sp))))
     (gap type 'search-param (car sp) (caddr sp)
          (if searches?
              (format "~a parameter not executable" (or (cadr sp) "unknown"))
              "the IG does not declare search-type for this type")))))

;; rest-gaps : rest Executes -> (listof Gap)
;; the statement's system-level parameters and operations, and each resource's includes and operations
(define (rest-gaps rest ex)
  (append
   (for/list ([sp (in-list (hash-ref rest 'searchParam '()))])
     (gap "*" 'search-param (hash-ref sp 'name) (expectation-of sp) "system-level search not implemented"))
   (for*/list ([res (in-list (hash-ref rest 'resource '()))]
               [k (in-list '(searchInclude searchRevInclude))]
               [v (in-list (includes-of res k))]
               #:unless (and ((executes-include? ex) v) (searchable? res)))
     (gap (hash-ref res 'type) (if (eq? k 'searchInclude) '_include '_revinclude) v (expectation-of res)
          (if (searchable? res) ":iterate includes not implemented" "the IG does not declare search-type for this type")))
   (for*/list ([res (in-list (hash-ref rest 'resource '()))]
               [op (in-list (hash-ref res 'operation '()))]
               #:unless (operation-implemented? ex op))
     (gap (hash-ref res 'type) 'operation (hash-ref op 'name) (expectation-of op) "operation not implemented"))
   ;; system-level operations (CQF Measures declares evaluate-measure there)
   (for/list ([op (in-list (hash-ref rest 'operation '()))] #:unless (operation-implemented? ex op))
     (gap "*" 'operation (hash-ref op 'name) (expectation-of op) "operation not implemented"))))

;; ---- the instance statement ---------------------------------------------------------------------

;; instance-capability : IgPlan (listof IgResource) Executes (or/c string #f) -> jsexpr
;; the IG's server CapabilityStatement as this server's instance statement: the served resources
;; with their profiles and expectations, trimmed to the interactions, parameters, includes and
;; operations actually executed; `url` is the server's own, when known
(define (instance-capability plan served ex url)
  (define cs (ig-plan-ig-cs plan))
  (define served-types (map ig-resource-type served))
  (define rest (server-rest cs))
  (define resources
    (for/list ([res (in-list (hash-ref rest 'resource '()))]
               #:when (member (hash-ref res 'type) served-types))
      (searchable-only (trim-resource res ex))))
  (define base
    (for/fold ([h cs]) ([k (in-list '(id meta text url version name title _title publisher contact
                                      jurisdiction copyright instantiates imports _instantiates))])
      (hash-remove h k)))
  (hash-set* base
             'kind "instance"
             'status "active"
             'date (today-string)
             'instantiates (list (string-append (hash-ref cs 'url) "|" (or (ig-plan-version plan) "")))
             'software (hasheq 'name "fhir-server ig-server")
             'implementation (if url (hasheq 'description "generated from the IG" 'url url)
                                 (hasheq 'description (format "generated from ~a ~a" (ig-plan-name plan) (ig-plan-version plan))))
             'rest (list (hash-set* (hash-remove (hash-remove rest 'searchParam) 'operation)
                                    'resource resources
                                    'interaction (filter (lambda (i) (member (hash-ref i 'code #f) '("transaction" "batch")))
                                                         (append (hash-ref rest 'interaction '())
                                                                 (list (hasheq 'code "transaction") (hasheq 'code "batch"))))))))

;; trim-resource : rest.resource Executes -> rest.resource
;; the resource's operations, includes, interactions and search parameters narrowed to what runs
(define (trim-resource res ex)
  (define type (hash-ref res 'type))
  (define with-ops
    (let ([ops (filter (lambda (op) (operation-implemented? ex op)) (hash-ref res 'operation '()))])
      (keep res 'operation ops)))
  (define with-includes
    (for/fold ([h with-ops]) ([k (in-list '(searchInclude searchRevInclude))])
      ;; keep the includes this server executes (their _ extension arrays would no longer line up
      ;; once filtered, so they are dropped)
      (keep (hash-remove h (string->symbol (string-append "_" (symbol->string k))))
            k (filter (executes-include? ex) (includes-of h k)))))
  (for/fold ([h with-includes]) ([k (in-list '(interaction searchParam))])
    (keep h k (filter (lambda (x) (if (eq? k 'interaction)
                                      ((executes-interaction? ex) (hash-ref x 'code #f))
                                      ((executes-search-param? ex) type (hash-ref x 'name ""))))
                      (hash-ref res k '())))))

;; keep : jsexpr key list -> jsexpr   the key set to the list, or removed when it is empty
(define (keep h k vs) (if (null? vs) (hash-remove h k) (hash-set h k vs)))

;; searchable-only : rest.resource -> rest.resource   search parameters and includes are only
;; advertised where search is (IPA lists includes on PractitionerRole, which it only lets clients read)
(define (searchable-only res)
  (if (searchable? res)
      res
      (for/fold ([h res]) ([k (in-list '(searchParam searchInclude _searchInclude searchRevInclude _searchRevInclude))])
        (hash-remove h k))))

;; today-string : -> String   the date of the statement, YYYY-MM-DD
(define (today-string)
  (define d (seconds->date (current-seconds) #f))
  (format "~a-~a-~a" (date-year d) (~2 (date-month d)) (~2 (date-day d))))
(define (~2 n) (if (< n 10) (format "0~a" n) (number->string n)))

;; ---- living examples ----------------------------------------------------------------------------
(module+ test
  (require rackunit (only-in "ig-plan.rkt" ig-plan ig-resource))
  (define shall (hasheq 'url "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation" 'valueCode "SHALL"))
  (define (i code) (hasheq 'code code 'extension (list shall)))
  (define patient (hasheq 'type "Patient" 'supportedProfile '("http://x/P")
                          'interaction (list (i "read") (i "search-type") (i "history-type"))
                          'searchParam (list (hasheq 'name "_id" 'type "token") (hasheq 'name "name" 'type "string"))
                          'searchInclude '("Patient:organization" "Patient:link:iterate")
                          'operation (list (hasheq 'name "everything" 'definition "http://hl7.org/fhir/OperationDefinition/Patient-everything|4.0.1"))))
  (define medication (hasheq 'type "Medication" 'interaction (list (i "read")) 'searchParam (list (hasheq 'name "code" 'type "token"))))
  (define rest (hasheq 'mode "server" 'resource (list patient medication)
                       'searchParam (list (hasheq 'name "_id" 'type "token"))
                       'operation (list (hasheq 'name "validate" 'definition "http://hl7.org/fhir/OperationDefinition/Resource-validate"))))
  (define cs (hasheq 'resourceType "CapabilityStatement" 'url "http://x/cs" 'id "x" 'rest (list rest)))
  (define served (list (ig-resource "Patient" '(("read" . "SHALL") ("search-type" . "SHALL") ("history-type" . "SHALL"))
                                    '(("_id" "token" "SHALL") ("name" "string" "SHALL")) '("http://x/P"))))
  (define unserved (ig-resource "Medication" '(("read" . "SHALL")) '(("code" "token" "SHALL")) '()))
  (define plan (ig-plan "x.ig" "1.0.0" "4.0.1" 'fhir/r4/schemas "core.tgz" cs (append served (list unserved))))
  ;; a server that reads and searches, indexes `_id` only, follows plain includes, validates only
  (define ex (executes (lambda (code) (member code '("read" "search-type")))
                       (lambda (type name) (equal? name "_id"))
                       (lambda (v) (not (regexp-match? #rx":iterate$" v)))
                       (lambda (url) (equal? url "http://hl7.org/fhir/OperationDefinition/Resource-validate"))))
  (check-equal? (map gap->list (plan-gaps plan served ex))
                '(("Medication" resource "Medication" "SHALL" "type not in this FHIR version's tower")
                  ("Patient" interaction "history-type" "SHALL" "interaction not implemented")
                  ("Patient" search-param "name" "SHALL" "string parameter not executable")
                  ("*" search-param "_id" "MAY" "system-level search not implemented")
                  ("Patient" _include "Patient:link:iterate" "MAY" ":iterate includes not implemented")
                  ("Patient" operation "everything" "MAY" "operation not implemented")))
  ;; the instance statement: what runs, and only that
  (define inst (instance-capability plan served ex "http://me"))
  (check-equal? (hash-ref inst 'kind) "instance")
  (check-equal? (hash-ref inst 'instantiates) '("http://x/cs|1.0.0"))
  (check-false (hash-has-key? inst 'id))
  (define irest (car (hash-ref inst 'rest)))
  (check-equal? (map (lambda (x) (hash-ref x 'code)) (hash-ref irest 'interaction)) '("transaction" "batch"))
  (check-false (hash-has-key? irest 'searchParam))
  (check-equal? (length (hash-ref irest 'resource)) 1)
  (define ipatient (car (hash-ref irest 'resource)))
  (check-equal? (map (lambda (x) (hash-ref x 'code)) (hash-ref ipatient 'interaction)) '("read" "search-type"))
  (check-equal? (map (lambda (x) (hash-ref x 'name)) (hash-ref ipatient 'searchParam)) '("_id"))
  (check-equal? (hash-ref ipatient 'searchInclude) '("Patient:organization"))
  (check-false (hash-has-key? ipatient 'operation))
  (check-equal? (hash-ref ipatient 'supportedProfile) '("http://x/P"))
  ;; a resource without search advertises no parameters, whatever it lists
  (check-false (hash-has-key? (searchable-only medication) 'searchParam))
  (check-equal? (includes-of (hasheq 'type "InsurancePlan" 'searchInclude '("formulary-coverage" "A:b")) 'searchInclude)
                '("InsurancePlan:formulary-coverage" "A:b")))
