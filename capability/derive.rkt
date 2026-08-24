#lang racket/base

;;; derive.rkt — turn validated capability declarations into typed FHIR nodes.
;;;
;;; The declare-and-derive core: a `#lang fhir/capability` module never hand-authors a
;;; CapabilityStatement — it DECLARES supported resources/operations and we DERIVE the
;;; CapabilityStatement (the /metadata artifact) + one OperationDefinition per operation from those
;;; declarations, so /metadata reflects exactly what the app was configured with and cannot drift.
;;;
;;; Every node is built the same way as the rest of the codebase: assemble a jsexpr and run it through
;;; `from-json` (all nested backbones — CapabilityStatementRest*, OperationDefinitionParameter — are
;;; registered, so the whole tree resolves in one call), then `ok-or-raise`.

(require racket/contract
         (only-in "../serialize/from-json.rkt" from-json)
         (only-in "../result/result.rkt" ok-or-raise)
         (only-in "../r6/fhir-version.rkt" fhir-version))

(provide
 (struct-out rc-server)
 (struct-out rc-resource)
 (struct-out rc-operation)
 (struct-out rc-param)
 (contract-out
  [op-code->canonical (-> string? string?)]
  [derive-capability-statement (-> rc-server? (listof rc-resource?) (listof rc-operation?) any/c)]
  [derive-operation-definition (-> rc-operation? any/c)]))

;; ---- runtime declaration data (produced by declare.rkt's emitters) --------------------------

;; server-level metadata (exactly one per module)
(struct rc-server (mode status date fhir-version format url) #:transparent)
;; a supported resource: type-sym, (listof interaction-sym), (listof (cons name-sym type-sym)), profile
(struct rc-resource (type interactions search-params profile) #:transparent)
;; an operation: code (no $), display ($name), levels = (list system? type? instance?),
;; resource-types = (listof string), in/out params = (listof rc-param), canonical = the REAL
;; OperationDefinition.url when the operation comes from an IG package (#f -> the derived urn key)
(struct rc-operation (code display levels resource-types in-params out-params canonical)
  #:transparent)
;; an operation parameter: name/type strings, min (nat), max (nat or '*), use ("in"/"out")
(struct rc-param (name type min max use) #:transparent)

;; ---- the join key linking CapabilityStatement.rest…operation.definition -> OperationDefinition.url
(define (op-code->canonical code) (string-append "urn:fhir-capability:operation:" code))

;; ---- CapabilityStatement ---------------------------------------------------------------------

(define (derive-capability-statement server resources operations)
  (define (op->entry o)
    (hasheq 'name (rc-operation-display o)
            'definition (or (rc-operation-canonical o)
                            (op-code->canonical (rc-operation-code o)))))
  ;; an operation contributes at the resource level for each type it lists; type/system-level
  ;; operations with no target resource contribute at rest.operation.
  (define (ops-for-type ty)
    (for/list ([o (in-list operations)]
               #:when (member (symbol->string ty) (rc-operation-resource-types o)))
      (op->entry o)))
  (define server/type-ops
    (for/list ([o (in-list operations)] #:when (null? (rc-operation-resource-types o)))
      (op->entry o)))
  (define rest-resources
    (for/list ([r (in-list resources)])
      (drop-absent
       (hasheq 'type (symbol->string (rc-resource-type r))       ; rest.resource.type is a `uri`
               'profile (rc-resource-profile r)
               'interaction (for/list ([i (in-list (rc-resource-interactions r))])
                              (hasheq 'code (symbol->string i)))
               ;; a search-param is (list name type expr) — expr drives search, not the CapabilityStatement
               'searchParam (for/list ([sp (in-list (rc-resource-search-params r))])
                              (hasheq 'name (symbol->string (car sp))
                                      'type (symbol->string (cadr sp))))
               'operation (ops-for-type (rc-resource-type r))))))
  (ok-or-raise
   (from-json
    (drop-absent
     (hasheq 'resourceType "CapabilityStatement"
             'url (rc-server-url server)
             'status (rc-server-status server)
             'date (rc-server-date server)
             'kind "instance"
             'fhirVersion (rc-server-fhir-version server)
             'format (rc-server-format server)
             'rest (list (hasheq 'mode (rc-server-mode server)
                                 'resource rest-resources
                                 'operation server/type-ops)))))))

;; ---- OperationDefinition ---------------------------------------------------------------------

(define (derive-operation-definition o)
  (define levels (rc-operation-levels o))
  (ok-or-raise
   (from-json
    (drop-absent
     (hasheq 'resourceType "OperationDefinition"
             'url (op-code->canonical (rc-operation-code o))
             'name (rc-operation-code o)
             'status "active"
             'kind "operation"
             'code (rc-operation-code o)
             'resource (let ([rs (rc-operation-resource-types o)]) (if (null? rs) #f rs))
             'system (list-ref levels 0)
             'type (list-ref levels 1)
             'instance (list-ref levels 2)
             'parameter (append (map param->jsexpr (rc-operation-in-params o))
                                (map param->jsexpr (rc-operation-out-params o))))))))

(define (param->jsexpr p)
  (hasheq 'name (rc-param-name p)
          'use (rc-param-use p)
          'min (rc-param-min p)                              ; unsignedInt -> a JSON number
          'max (let ([m (rc-param-max p)]) (if (eq? m '*) "*" (number->string m)))   ; string
          'type (rc-param-type p)))

;; drop keys whose value is #f or '() so from-json doesn't build empty/absent fields
(define (drop-absent h)
  (for/hasheq ([(k v) (in-hash h)] #:unless (or (eq? v #f) (null? v))) (values k v)))

(module+ test
  (require rackunit
           (only-in "../r6/types.rkt")                       ; register the R6 tower
           (only-in "../model/node.rkt" fhir? fhir-type fhir-ref)
           (only-in "../serialize/to-json.rkt" node->jsexpr))
  (define srv (rc-server "server" "active" "2025-01-01T00:00:00Z" fhir-version
                         '("application/fhir+json") #f))
  (define res (rc-resource 'Patient '(read create search-type)
                           (list (list 'gender 'token "Patient.gender")) #f))
  (define op (rc-operation "expand" "$expand" (list #f #t #f) '("ValueSet")
                           (list (rc-param "url" "uri" 1 1 "in"))
                           (list (rc-param "return" "ValueSet" 1 1 "out"))
                           #f))
  (define cs (derive-capability-statement srv (list res) (list op)))
  (check-true (fhir? cs))
  (check-eq? (fhir-type cs) 'CapabilityStatement)
  (define js (node->jsexpr cs))
  (define rest0 (car (hash-ref js 'rest)))
  (check-equal? (hash-ref (car (hash-ref rest0 'resource)) 'type) "Patient")
  ;; the operation join key matches the derived OperationDefinition url
  (define od (derive-operation-definition op))
  (check-eq? (fhir-type od) 'OperationDefinition)
  (check-equal? (hash-ref (node->jsexpr od) 'url) (op-code->canonical "expand")))
