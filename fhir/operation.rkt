#lang racket/base

;;; operation.rkt — FHIR operations as values: invoke them, compose them, serve them.
;;;
;;; A FHIR operation is defined by an OperationDefinition (its code, levels, in/out parameters). Here
;;; an operation is that definition plus an implementation, and nothing about HTTP: a pipeline calls
;;; it, a server (fhir-server) routes requests to it, and both see the same inputs and outputs.
;;;
;;; An Operation is (operation definition subject run)
;;;   definition : OperationDefinition (FHIR JSON)
;;;   subject    : string | #f   the `in` parameter a piped value fills ("resource" for $validate,
;;;                "content" for $transform), or #f when the operation applies to the value itself
;;;                (instance level: ValueSet/$expand on a ValueSet)
;;;   run        : Inputs Subject -> Result
;;; Inputs : (hash name -> (listof value)), value = a resource or datatype (FHIR JSON), or a string,
;;;          number or boolean (a primitive)
;;; Result : a resource (the operation's single `return`) | (hash name -> (listof value)) (its outputs,
;;;          returned as a Parameters resource)
;;; An operation is also a procedure: (op subject name value ...) = (invoke op subject name value ...).
;;;
;;; Failures raise `exn:fail:operation`, carrying an OperationOutcome; `invoke/outcome` returns it
;;; instead. A run reads its context from parameters: `current-data-source` (fhir/data-source) for
;;; FHIR data, `current-sd-packages` (fhir/sd/sd-index) for profiles and terminology.
;;;
;;; Pipelines are function composition: `(pipeline value step ...)` threads a value through steps,
;;; and `(step op name value ...)` is the one-argument procedure that applies `op` with those inputs.
;;;
;;; Calling by reference, like a function call: implementations register under their
;;; OperationDefinition's canonical (`register-operation!`, done by the packages that implement them),
;;; and `(call-operation ref subject param ...)` resolves the reference and invokes it:
;;;   ref    = the canonical url ("http://hl7.org/fhir/OperationDefinition/Resource-validate", a
;;;            `|version` is ignored), an OperationDefinition resource, "$code", or "Type/$code" when
;;;            several registered operations share a code
;;;   params = name/value pairs, or one Parameters resource

(require racket/contract racket/list racket/string)

(provide
 (struct-out exn:fail:operation)
 (contract-out
  [make-operation (->* (hash? procedure?) (#:subject (or/c string? #f)) operation?)]
  [operation? (-> any/c boolean?)]
  [operation-definition (-> operation? hash?)]
  [operation-subject (-> operation? (or/c string? #f))]
  [operation-code (-> operation? string?)]
  [operation-url (-> operation? (or/c string? #f))]
  [operation-levels (-> operation? (listof (or/c 'system 'type 'instance)))]
  [operation-resource-types (-> operation? (listof string?))]
  [invoke (->* (operation? any/c) () #:rest list? hash?)]
  [invoke/inputs (-> operation? any/c hash? hash?)]
  [invoke/outcome (->* (operation? any/c) () #:rest list? hash?)]
  [step (->* (operation?) () #:rest list? procedure?)]
  [pipeline (->* (any/c) () #:rest (listof procedure?) any/c)]
  [operation-error (->* (string? string?) () #:rest list? none/c)]
  [outcome (->* (string? string? string?) () hash?)]
  [outcome-errors? (-> hash? boolean?)]
  [input (->* (hash? string?) (any/c) any/c)]
  [register-operation! (-> operation? void?)]
  [registered-operations (-> (listof operation?))]
  [lookup-operation (-> (or/c string? hash?) operation?)]
  [call-operation (->* ((or/c string? hash?) any/c) () #:rest list? hash?)]
  [parameters->inputs (-> hash? hash?)]
  [outputs->parameters (-> operation? hash? hash?)]))

(struct exn:fail:operation exn:fail (outcome) #:transparent)

(struct operation (definition subject run)
  #:property prop:procedure (lambda (op subject . args) (apply invoke op subject args))
  #:property prop:custom-write
  (lambda (op port mode) (fprintf port "#<operation $~a>" (operation-code op))))

(define (make-operation definition run #:subject [subject #f])
  (operation definition subject run))

;; ---- the definition -------------------------------------------------------------------------
(define (operation-code op) (hash-ref (operation-definition op) 'code ""))
(define (operation-url op) (hash-ref (operation-definition op) 'url #f))
(define (operation-levels op)
  (define od (operation-definition op))
  (for/list ([l (in-list '(system type instance))] #:when (eq? #t (hash-ref od l #f))) l))
(define (operation-resource-types op)
  (let ([r (hash-ref (operation-definition op) 'resource '())]) (if (list? r) r '())))
(define (parameters-of op use)
  (for/list ([p (in-list (hash-ref (operation-definition op) 'parameter '()))]
             #:when (equal? (hash-ref p 'use #f) use))
    p))

;; ---- outcomes -------------------------------------------------------------------------------
;; outcome : severity code diagnostics -> OperationOutcome
(define (outcome severity code diagnostics)
  (hasheq 'resourceType "OperationOutcome"
          'issue (list (hasheq 'severity severity 'code code 'diagnostics diagnostics))))
;; operation-error : code format-string arg ... -> raises exn:fail:operation
(define (operation-error code fmt . args)
  (define msg (apply format fmt args))
  (raise (exn:fail:operation msg (current-continuation-marks) (outcome "error" code msg))))
(define (outcome-errors? oo)
  (for/or ([i (in-list (hash-ref oo 'issue '()))]) (and (member (hash-ref i 'severity #f) '("error" "fatal")) #t)))

;; ---- invoking -------------------------------------------------------------------------------
;; invoke : operation subject name value ... -> resource
;; names are strings or symbols; a list value is several values for that name
(define (invoke op subject . args)
  (unless (even? (length args))
    (operation-error "invalid" "$~a: inputs come in name/value pairs" (operation-code op)))
  (define inputs
    (for/fold ([h (hash)]) ([name (in-list args)] [i (in-naturals)] #:when (even? i))
      (define v (list-ref args (add1 i)))
      (hash-update h (if (symbol? name) (symbol->string name) name)
                   (lambda (old) (append old (if (list? v) v (list v)))) '())))
  (invoke/inputs op subject inputs))

;; invoke/inputs : operation subject Inputs -> resource   (the server's entry point)
(define (invoke/inputs op subject inputs0)
  (define inputs (if (and subject (operation-subject op))
                     (hash-update inputs0 (operation-subject op) (lambda (old) (append old (list subject))) '())
                     inputs0))
  (check-inputs op inputs)
  (define result ((operation-run op) (coerce-inputs op inputs) (and (not (operation-subject op)) subject)))
  (if (and (hash? result) (string? (hash-ref result 'resourceType #f)))
      result
      (outputs->parameters op result)))

;; invoke/outcome : like invoke, but a failure is returned as its OperationOutcome
(define (invoke/outcome op subject . args)
  (with-handlers ([exn:fail:operation? exn:fail:operation-outcome]
                  [exn:fail? (lambda (e) (outcome "error" "exception" (exn-message e)))])
    (apply invoke op subject args)))

;; check-inputs : operation Inputs -> void   names the definition knows, cardinality it allows
(define (check-inputs op inputs)
  (define ins (parameters-of op "in"))
  (define known (map (lambda (p) (hash-ref p 'name)) ins))
  (for ([name (in-hash-keys inputs)] #:unless (member name known))
    (operation-error "invalid" "$~a has no input parameter '~a' (it takes: ~a)"
                     (operation-code op) name (string-join known ", ")))
  (for ([p (in-list ins)])
    (define n (length (hash-ref inputs (hash-ref p 'name) '())))
    (define mn (hash-ref p 'min 0))
    (define mx (hash-ref p 'max "*"))
    (when (and (exact-integer? mn) (< n mn))
      (operation-error "required" "$~a needs input '~a' (at least ~a, got ~a)" (operation-code op) (hash-ref p 'name) mn n))
    (when (and (string->number mx) (> n (string->number mx)))
      (operation-error "invalid" "$~a takes at most ~a '~a' (got ~a)" (operation-code op) mx (hash-ref p 'name) n))))

;; coerce-inputs : operation Inputs -> Inputs   a string given for an integer / decimal / boolean
;; parameter (an HTTP query value, a command-line argument) becomes that type
(define (coerce-inputs op inputs)
  (define types (for/hash ([p (in-list (parameters-of op "in"))]) (values (hash-ref p 'name) (hash-ref p 'type #f))))
  (for/hash ([(name vs) (in-hash inputs)])
    (define t (hash-ref types name #f))
    (values name
            (for/list ([v (in-list vs)])
              (cond [(not (string? v)) v]
                    [(member t '("integer" "positiveInt" "unsignedInt" "integer64" "decimal"))
                     (or (string->number v) (operation-error "invalid" "$~a: '~a' must be a number, got ~s" (operation-code op) name v))]
                    [(equal? t "boolean")
                     (cond [(equal? v "true") #t] [(equal? v "false") #f]
                           [else (operation-error "invalid" "$~a: '~a' must be true or false, got ~s" (operation-code op) name v)])]
                    [else v])))))

;; ---- composing ------------------------------------------------------------------------------
;; step : operation name value ... -> (subject -> resource)
(define (step op . args) (lambda (subject) (apply invoke op subject args)))
;; pipeline : value step ... -> value   each step receives the previous one's result
(define (pipeline v . steps) (for/fold ([v v]) ([f (in-list steps)]) (f v)))

;; input : Inputs name [default] -> value   the first value given for `name` (for implementations)
(define (input in name [default #f]) (let ([v (hash-ref in name '())]) (if (pair? v) (car v) default)))

;; ---- the registry: call an operation by reference -------------------------------------------
;; canonical url -> operation; filled by the packages that implement operations (as they load)
(define registry (make-hash))
(define (register-operation! op)
  (unless (operation-url op) (raise-arguments-error 'register-operation! "an operation needs a canonical url" "operation" op))
  (hash-set! registry (operation-url op) op))
(define (registered-operations) (sort (hash-values registry) string<? #:key operation-url))

;; lookup-operation : ref -> operation   (see the header for the reference forms)
(define (lookup-operation ref)
  (define (by-code type code)
    (define hits (for/list ([op (in-hash-values registry)]
                            #:when (and (equal? (operation-code op) code)
                                        (or (not type) (member type (operation-resource-types op)))))
                   op))
    (cond [(= 1 (length hits)) (car hits)]
          [(null? hits) (operation-error "not-found" "no operation $~a~a is registered" code (if type (format " on ~a" type) ""))]
          [else (operation-error "multiple-matches" "$~a is ambiguous: ~a — name it as Type/$~a or by url"
                                 code (string-join (sort (map operation-url hits) string<?) ", ") code)]))
  (cond
    [(hash? ref) (lookup-operation (or (hash-ref ref 'url #f) (operation-error "invalid" "an OperationDefinition without a url")))]
    [(regexp-match #px"^(?:([A-Z][A-Za-z]+)/)?[$]([A-Za-z-]+)$" ref) => (lambda (m) (by-code (cadr m) (caddr m)))]
    [(hash-ref registry (car (string-split ref "|")) #f) => values]
    [else (operation-error "not-found" "no implementation is registered for ~a" ref)]))

;; call-operation : ref subject param ... -> resource   params: name/value pairs or one Parameters
(define (call-operation ref subject . params)
  (define op (lookup-operation ref))
  (if (and (= 1 (length params)) (hash? (car params)) (equal? (hash-ref (car params) 'resourceType #f) "Parameters"))
      (invoke/inputs op subject (parameters->inputs (car params)))
      (apply invoke op subject params)))

;; ---- Parameters <-> inputs / outputs ----------------------------------------------------------
;; parameters->inputs : Parameters -> Inputs   value[x] gives the value, `resource` the resource,
;; `part` the parameter itself
(define (parameters->inputs ps)
  (for/fold ([h (hash)]) ([p (in-list (hash-ref ps 'parameter '()))] #:when (string? (hash-ref p 'name #f)))
    (define v (or (for/first ([(k v) (in-hash p)] #:when (regexp-match? #rx"^value" (symbol->string k))) v)
                  (hash-ref p 'resource #f)
                  p))
    (hash-update h (hash-ref p 'name) (lambda (old) (append old (list v))) '())))

;; outputs->parameters : operation Outputs -> Parameters   a value's type is the definition's
;; out parameter type; a resource goes in `resource`
(define (outputs->parameters op outs)
  (define types (for/hash ([p (in-list (parameters-of op "out"))]) (values (hash-ref p 'name) (hash-ref p 'type #f))))
  (hasheq 'resourceType "Parameters"
          'parameter
          (for*/list ([(name vs) (in-hash outs)] [v (in-list vs)])
            (cond
              [(and (hash? v) (string? (hash-ref v 'resourceType #f))) (hasheq 'name name 'resource v)]
              [else (hasheq 'name name (value-key (hash-ref types name #f) v) v)]))))
(define (value-key type v)
  (string->symbol
   (string-append "value"
                  (cond [(and (string? type) (> (string-length type) 0))
                         (string-append (string-upcase (substring type 0 1)) (substring type 1))]
                        [(boolean? v) "Boolean"] [(exact-integer? v) "Integer"] [(number? v) "Decimal"]
                        [else "String"]))))

(module+ test
  (require rackunit)
  ;; a toy operation: $greet (in: resource 1..1, greeting 0..1; out: return)
  (define od (hasheq 'resourceType "OperationDefinition" 'url "http://example.org/OperationDefinition/greet"
                     'code "greet" 'system #f 'type #t 'instance #f 'resource '("Patient")
                     'parameter (list (hasheq 'name "resource" 'use "in" 'min 1 'max "1" 'type "Resource")
                                      (hasheq 'name "greeting" 'use "in" 'min 0 'max "1" 'type "string")
                                      (hasheq 'name "return" 'use "out" 'min 1 'max "1" 'type "Parameters"))))
  (define $greet
    (make-operation od #:subject "resource"
                    (lambda (in _)
                      (define r (car (hash-ref in "resource")))
                      (hash "message" (list (format "~a, ~a" (car (hash-ref in "greeting" '("hello"))) (hash-ref r 'id)))))))
  (define p (hasheq 'resourceType "Patient" 'id "p1"))
  (check-equal? (operation-levels $greet) '(type))
  (check-equal? ($greet p) (hasheq 'resourceType "Parameters" 'parameter (list (hasheq 'name "message" 'valueString "hello, p1"))))
  (check-equal? (hash-ref (car (hash-ref ($greet p "greeting" "hi") 'parameter)) 'valueString) "hi, p1")
  ;; definitions are checked: unknown names and cardinality
  (check-exn #rx"has no input parameter 'greting'" (lambda () ($greet p "greting" "hi")))
  (check-exn #rx"takes at most 1 'greeting'" (lambda () ($greet p "greeting" '("a" "b"))))
  (check-true (outcome-errors? (invoke/outcome $greet #f)))
  ;; pipelines thread a value through steps
  (define $id (make-operation (hash-set od 'code "id") #:subject "resource" (lambda (in _) (car (hash-ref in "resource")))))
  (check-equal? (pipeline p (step $id) (step $id)) p)
  ;; by reference: the canonical, $code, Type/$code, or the OperationDefinition itself; a Parameters
  (register-operation! $greet)
  (define url "http://example.org/OperationDefinition/greet")
  (check-equal? (call-operation url p "greeting" "hi") ($greet p "greeting" "hi"))
  (check-equal? (call-operation "$greet" p) ($greet p))
  (check-equal? (call-operation "Patient/$greet" p) ($greet p))
  (check-equal? (call-operation od p (hasheq 'resourceType "Parameters" 'parameter (list (hasheq 'name "greeting" 'valueString "hi"))))
                ($greet p "greeting" "hi"))
  (check-exn #rx"no operation [$]nope" (lambda () (call-operation "$nope" p)))
  ;; typed inputs given as strings (an HTTP query) are coerced to the parameter's type
  (define $count (make-operation (hasheq 'url "http://example.org/OperationDefinition/count" 'code "count" 'type #t
                                         'parameter (list (hasheq 'name "n" 'use "in" 'min 1 'max "1" 'type "integer")
                                                          (hasheq 'name "return" 'use "out" 'min 1 'max "1" 'type "Parameters")))
                                 (lambda (in _) (hash "twice" (list (* 2 (input in "n")))))))
  (check-equal? (hash-ref (car (hash-ref ($count #f "n" "21") 'parameter)) 'valueInteger) 42)
  (check-exn #rx"'n' must be a number" (lambda () ($count #f "n" "x")))
  (check-equal? (parameters->inputs (hasheq 'parameter (list (hasheq 'name "greeting" 'valueString "yo") (hasheq 'name "resource" 'resource p))))
                (hash "greeting" '("yo") "resource" (list p))))
