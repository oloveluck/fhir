#lang racket/base

;;; operation.rkt — FHIR operations as procedures: apply them by reference, thread them together.
;;;
;;; A FHIR operation is defined by an OperationDefinition (its code, levels, in/out parameters). Here an
;;; operation is that definition plus an implementation, and nothing about HTTP — a procedure whose
;;; keyword arguments are the definition's parameters:
;;;
;;;   (apply-operation "StructureMap/$transform" qr #:srcMap fml)      apply by reference
;;;   (define transform (operation "StructureMap/$transform"))         or resolve once …
;;;   (transform qr #:srcMap fml)                                      … and apply it
;;;   (~> qr (transform #:srcMap fml) (ensure-valid) ($snapshot))      thread a value through
;;;
;;; A reference is the definition's canonical url (a `|version` is ignored), the OperationDefinition
;;; itself, "$code", or "Type/$code" when several operations share a code. Applying:
;;;   (op [subject [parameters]] #:name value …)
;;;   subject    — the resource the operation is applied to: the value a pipeline threads
;;;   parameters — a Parameters resource, for inputs only known at run time
;;;   #:name     — an `in` parameter by its name (#:periodStart, #:srcMap); a list gives several values
;;; Inputs are checked against the definition (an unknown name is an error that lists the known ones;
;;; cardinality), strings given for integer / decimal / boolean parameters are converted, and the
;;; result is the `return` resource, or a Parameters of the outputs. A failure raises
;;; `exn:fail:operation` carrying an OperationOutcome (`apply-operation/outcome` returns it instead).
;;; Operations read their context from parameters: `current-data-source` (fhir/data-source) for FHIR
;;; data, `current-sd-packages` (fhir/sd/sd-index) for profiles and terminology.
;;;
;;; Implementing one: (make-operation definition run #:subject name) where
;;;   run     : Inputs Subject -> Result
;;;   Inputs  : (hash name -> (listof value)), a value being FHIR JSON or a string / number / boolean
;;;   Result  : a resource (the single `return`) | (hash name -> (listof value)) (the outputs)
;;;   subject : the `in` parameter the subject fills ("resource" for $validate, "content" for
;;;             $transform), or #f when the operation applies to the subject itself (instance level:
;;;             a ValueSet into $expand) — then `run` receives it
;;; and `register-operation!` makes it resolvable by reference (the implementing packages do so when
;;; their module loads). `invoke` applies an operation to an Inputs hash (what a server holds).

(require racket/contract racket/list racket/string (for-syntax racket/base))

(provide
 ~>
 (struct-out exn:fail:operation)
 (contract-out
  [operation (-> (or/c string? hash? operation?) operation?)]
  [apply-operation (unconstrained-domain-> hash?)]
  [apply-operation/outcome (unconstrained-domain-> hash?)]
  [make-operation (->* (hash? procedure?) (#:subject (or/c string? #f)) operation?)]
  [register-operation! (-> operation? void?)]
  [registered-operations (-> (listof operation?))]
  [operation? (-> any/c boolean?)]
  [operation-definition (-> operation? hash?)]
  [operation-subject (-> operation? (or/c string? #f))]
  [operation-code (-> operation? string?)]
  [operation-url (-> operation? (or/c string? #f))]
  [operation-levels (-> operation? (listof (or/c 'system 'type 'instance)))]
  [operation-resource-types (-> operation? (listof string?))]
  [invoke (-> operation? any/c hash? hash?)]
  [input (->* (hash? string?) (any/c) any/c)]
  [operation-error (->* (string? string?) () #:rest list? none/c)]
  [outcome (-> string? string? string? hash?)]
  [outcome-errors? (-> hash? boolean?)]
  [parameters->inputs (-> hash? hash?)]
  [outputs->parameters (-> operation? hash? hash?)]))

(struct exn:fail:operation exn:fail (outcome) #:transparent)

;; An operation applies like a procedure: (op [subject [parameters]] #:name value …)
(struct op (definition subject run)
  #:property prop:procedure
  (make-keyword-procedure (lambda (kws kw-args self . positional) (apply-to self kws kw-args positional)))
  #:property prop:custom-write
  (lambda (o port mode) (fprintf port "#<operation $~a>" (operation-code o))))

(define operation? op?)
(define operation-definition op-definition)
(define operation-subject op-subject)
(define (make-operation definition run #:subject [subject #f]) (op definition subject run))

;; ---- the definition -------------------------------------------------------------------------
(define (operation-code o) (hash-ref (op-definition o) 'code ""))
(define (operation-url o) (hash-ref (op-definition o) 'url #f))
(define (operation-levels o)
  (for/list ([l (in-list '(system type instance))] #:when (eq? #t (hash-ref (op-definition o) l #f))) l))
(define (operation-resource-types o)
  (let ([r (hash-ref (op-definition o) 'resource '())]) (if (list? r) r '())))
(define (parameters-of o use)
  (for/list ([p (in-list (hash-ref (op-definition o) 'parameter '()))] #:when (equal? (hash-ref p 'use #f) use)) p))

;; ---- outcomes -------------------------------------------------------------------------------
(define (outcome severity code diagnostics)
  (hasheq 'resourceType "OperationOutcome"
          'issue (list (hasheq 'severity severity 'code code 'diagnostics diagnostics))))
(define (operation-error code fmt . args)
  (define msg (apply format fmt args))
  (raise (exn:fail:operation msg (current-continuation-marks) (outcome "error" code msg))))
(define (outcome-errors? oo)
  (for/or ([i (in-list (hash-ref oo 'issue '()))]) (and (member (hash-ref i 'severity #f) '("error" "fatal")) #t)))

;; ---- applying -------------------------------------------------------------------------------
;; apply-to : operation keywords values positional -> resource
(define (apply-to o kws kw-args positional)
  (define-values (subject parameters) (match-positional o positional))
  (define from-keywords
    (for/hash ([k (in-list kws)] [v (in-list kw-args)])
      (values (keyword->string k) (if (list? v) v (list v)))))
  (define from-parameters (if parameters (parameters->inputs parameters) (hash)))
  (invoke o subject (for/fold ([h from-parameters]) ([(k vs) (in-hash from-keywords)])
                      (hash-update h k (lambda (old) (append old vs)) '()))))
(define (match-positional o positional)
  (cond [(null? positional) (values #f #f)]
        [(null? (cdr positional)) (values (car positional) #f)]
        [(and (null? (cddr positional)) (hash? (cadr positional))
              (equal? (hash-ref (cadr positional) 'resourceType #f) "Parameters"))
         (values (car positional) (cadr positional))]
        [else (operation-error "invalid" "$~a takes a subject and a Parameters resource at most; name the inputs with keywords (#:name value)"
                               (operation-code o))]))

;; invoke : operation subject Inputs -> resource   (what a host holds: a server's request Parameters)
(define (invoke o subject inputs0)
  (define inputs (if (and subject (op-subject o))
                     (hash-update inputs0 (op-subject o) (lambda (old) (append old (list subject))) '())
                     inputs0))
  (check-inputs o inputs)
  (define result ((op-run o) (coerce-inputs o inputs) (and (not (op-subject o)) subject)))
  (if (and (hash? result) (string? (hash-ref result 'resourceType #f)))
      result
      (outputs->parameters o result)))

;; check-inputs : operation Inputs -> void   names the definition knows, cardinality it allows
(define (check-inputs o inputs)
  (define ins (parameters-of o "in"))
  (define known (map (lambda (p) (hash-ref p 'name)) ins))
  (for ([name (in-hash-keys inputs)] #:unless (member name known))
    (operation-error "invalid" "$~a has no input parameter '~a' (it takes: ~a)"
                     (operation-code o) name (string-join known ", ")))
  (for ([p (in-list ins)])
    (define n (length (hash-ref inputs (hash-ref p 'name) '())))
    (define mn (hash-ref p 'min 0))
    (define mx (hash-ref p 'max "*"))
    (when (and (exact-integer? mn) (< n mn))
      (operation-error "required" "$~a needs input '~a' (at least ~a, got ~a)" (operation-code o) (hash-ref p 'name) mn n))
    (when (and (string->number mx) (> n (string->number mx)))
      (operation-error "invalid" "$~a takes at most ~a '~a' (got ~a)" (operation-code o) mx (hash-ref p 'name) n))))

;; coerce-inputs : operation Inputs -> Inputs   a string given for an integer / decimal / boolean
;; parameter (an HTTP query value, a command-line argument) becomes that type
(define (coerce-inputs o inputs)
  (define types (for/hash ([p (in-list (parameters-of o "in"))]) (values (hash-ref p 'name) (hash-ref p 'type #f))))
  (for/hash ([(name vs) (in-hash inputs)])
    (define t (hash-ref types name #f))
    (values name
            (for/list ([v (in-list vs)])
              (cond [(not (string? v)) v]
                    [(member t '("integer" "positiveInt" "unsignedInt" "integer64" "decimal"))
                     (or (string->number v) (operation-error "invalid" "$~a: '~a' must be a number, got ~s" (operation-code o) name v))]
                    [(equal? t "boolean")
                     (cond [(equal? v "true") #t] [(equal? v "false") #f]
                           [else (operation-error "invalid" "$~a: '~a' must be true or false, got ~s" (operation-code o) name v)])]
                    [else v])))))

;; input : Inputs name [default] -> value   the first value given for `name` (for implementations)
(define (input in name [default #f]) (let ([v (hash-ref in name '())]) (if (pair? v) (car v) default)))

;; ---- by reference ---------------------------------------------------------------------------
;; canonical url -> operation; filled by the packages that implement operations (as they load)
(define registry (make-hash))
(define (register-operation! o)
  (unless (operation-url o) (raise-arguments-error 'register-operation! "an operation needs a canonical url" "operation" o))
  (hash-set! registry (operation-url o) o))
(define (registered-operations) (sort (hash-values registry) string<? #:key operation-url))

;; operation : reference -> operation   (see the header for the reference forms)
(define (operation ref)
  (define (by-code type code)
    (define hits (for/list ([o (in-hash-values registry)]
                            #:when (and (equal? (operation-code o) code)
                                        (or (not type) (member type (operation-resource-types o)))))
                   o))
    (cond [(= 1 (length hits)) (car hits)]
          [(null? hits) (operation-error "not-found" "no operation $~a~a is registered" code (if type (format " on ~a" type) ""))]
          [else (operation-error "multiple-matches" "$~a is ambiguous: ~a — name it as Type/$~a or by url"
                                 code (string-join (sort (map operation-url hits) string<?) ", ") code)]))
  (cond
    [(op? ref) ref]
    [(hash? ref) (operation (or (hash-ref ref 'url #f) (operation-error "invalid" "an OperationDefinition without a url")))]
    [(regexp-match #px"^(?:([A-Z][A-Za-z]+)/)?[$]([A-Za-z-]+)$" ref) => (lambda (m) (by-code (cadr m) (caddr m)))]
    [(hash-ref registry (car (string-split ref "|")) #f) => values]
    [else (operation-error "not-found" "no implementation is registered for ~a" ref)]))

;; apply-operation : reference [subject [parameters]] #:name value … -> resource
(define apply-operation
  (make-keyword-procedure
   (lambda (kws kw-args ref . positional) (apply-to (operation ref) kws kw-args positional))))

;; apply-operation/outcome : like apply-operation, but a failure is returned as its OperationOutcome
(define apply-operation/outcome
  (make-keyword-procedure
   (lambda (kws kw-args . positional)
     (with-handlers ([exn:fail:operation? exn:fail:operation-outcome]
                     [exn:fail? (lambda (e) (outcome "error" "exception" (exn-message e)))])
       (keyword-apply apply-operation kws kw-args positional)))))

;; ---- threading ------------------------------------------------------------------------------
;; (~> v (f arg …) …) : each form receives the previous value as its first argument —
;; (~> qr (transform #:srcMap m) (ensure-valid)) = (ensure-valid (transform qr #:srcMap m))
(define-syntax (~> stx)
  (syntax-case stx ()
    [(_ v) #'v]
    [(_ v (f arg ...) more ...) #'(~> (f v arg ...) more ...)]
    [(_ v f more ...) #'(~> (f v) more ...)]))

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
(define (outputs->parameters o outs)
  (define types (for/hash ([p (in-list (parameters-of o "out"))]) (values (hash-ref p 'name) (hash-ref p 'type #f))))
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
  ;; a toy operation: Patient/$greet (in: resource 1..1, greeting 0..1, times 0..1 integer)
  (define od (hasheq 'resourceType "OperationDefinition" 'url "http://example.org/OperationDefinition/greet"
                     'code "greet" 'system #f 'type #t 'instance #f 'resource '("Patient")
                     'parameter (list (hasheq 'name "resource" 'use "in" 'min 1 'max "1" 'type "Resource")
                                      (hasheq 'name "greeting" 'use "in" 'min 0 'max "1" 'type "string")
                                      (hasheq 'name "times" 'use "in" 'min 0 'max "1" 'type "integer")
                                      (hasheq 'name "return" 'use "out" 'min 1 'max "1" 'type "Parameters"))))
  (define $greet
    (make-operation od #:subject "resource"
                    (lambda (in _)
                      (define r (input in "resource"))
                      (hash "message" (list (string-join (for/list ([_ (in-range (input in "times" 1))])
                                                           (format "~a, ~a" (input in "greeting" "hello") (hash-ref r 'id)))
                                                         " "))))))
  (define (message ps) (hash-ref (car (hash-ref ps 'parameter)) 'valueString))
  (define p (hasheq 'resourceType "Patient" 'id "p1"))
  (check-equal? (operation-levels $greet) '(type))
  ;; an operation is a procedure; its keyword arguments are the definition's parameters
  (check-equal? (message ($greet p)) "hello, p1")
  (check-equal? (message ($greet p #:greeting "hi")) "hi, p1")
  (check-equal? (message ($greet p #:times "2")) "hello, p1 hello, p1")     ; "2" is converted (integer)
  (check-exn #rx"has no input parameter 'greting' [(]it takes: resource, greeting, times[)]"
             (lambda () ($greet p #:greting "hi")))
  (check-exn #rx"takes at most 1 'greeting'" (lambda () ($greet p #:greeting '("a" "b"))))
  (check-exn #rx"'times' must be a number" (lambda () ($greet p #:times "x")))
  ;; by reference: the canonical, $code, Type/$code, the OperationDefinition; Parameters at run time
  (register-operation! $greet)
  (check-equal? (message (apply-operation "http://example.org/OperationDefinition/greet" p #:greeting "hi")) "hi, p1")
  (check-equal? (message (apply-operation "$greet" p)) "hello, p1")
  (check-equal? (message ((operation "Patient/$greet") p)) "hello, p1")
  (check-equal? (message (apply-operation od p (hasheq 'resourceType "Parameters" 'parameter (list (hasheq 'name "greeting" 'valueString "yo")))))
                "yo, p1")
  (check-exn #rx"no operation [$]nope is registered" (lambda () (apply-operation "$nope" p)))
  (check-true (outcome-errors? (apply-operation/outcome "$greet")))
  ;; threading: each result is the next form's first argument
  (define $id (make-operation (hash-set* od 'code "id" 'url "http://example.org/OperationDefinition/id") #:subject "resource"
                              (lambda (in _) (input in "resource"))))
  (check-equal? (~> p ($id) $id) p)
  (check-equal? (message (~> p ($id) ($greet #:greeting "hey"))) "hey, p1")
  (check-equal? (parameters->inputs (hasheq 'parameter (list (hasheq 'name "greeting" 'valueString "yo") (hasheq 'name "resource" 'resource p))))
                (hash "greeting" '("yo") "resource" (list p))))
