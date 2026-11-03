#lang racket/base

;;; ig-search-harness.rkt — "every resource can be found by its own values": a search oracle that
;;; needs no hand-written expectations.
;;;
;;; Load an IG's examples into a fresh store indexed with a search-param catalog (the IG's own
;;; SearchParameters merged over its core package's). Then, for every example and every indexed
;;; parameter of its type, derive a query value FROM THE EXAMPLE'S OWN INDEX ROWS — the shape a
;;; client would send for that parameter type — search with it alone, and require the example to
;;; be among the hits. This drives extraction, query-value encoding and SQL compilation for every
;;; parameter type end to end; a miss means one of the three disagrees with the others.
;;;
;;;   token     system|code (or code)          uri       the value
;;;   reference Type/id (or the id)            string    the exact value (default starts-with)
;;;   date      le<low> AND separately ge<high> number    the value
;;;   quantity  value|system|code
;;;
;;; Blind spot closed: a parameter whose expression ERRORS on an example indexes nothing, so it would
;;; generate no probe at all; every such error is recorded separately and must also be zero.
;;;
;;; The caller registers the matching tower. Result: (ig-search-report probes hits misses errors)
;;; misses : (listof (list example-type param kind query-value))
;;; errors : (listof (list example-type param message)) — expression evaluation failures

(require racket/contract racket/list racket/string racket/file
         (only-in fhir/serialize/from-json from-json)
         (only-in fhir/serialize/read-json strip-jnum)
         (only-in fhir/result/result ok? ok-value)
         (only-in fhir/model/registry type-registered?)
         (only-in fhirpath/parser/parse parse-fhirpath)
         (only-in fhirpath/eval eval-fhirpath)
         (only-in fhir/store/fhir-sqlite open-fhir-store close-fhir-store)
         (only-in fhir/store/fhir-engine fhir-create! fhir-search search-param-name search-param-kind
                  search-param-path)
         (only-in fhir/store/search-index rows-for indexed-kind? token-row token-row? token-row-system
                  token-row-code reference-row? reference-row-target-type reference-row-target-id
                  string-row? string-row-exact date-row? date-row-low date-row-high number-row?
                  number-row-value quantity-row? quantity-row-value quantity-row-system quantity-row-code)
         (only-in fhir/store/ig-params search-params-from-package merge-search-params)
         (only-in fhir/package read-package))

(provide
 (struct-out ig-search-report)
 (contract-out
  [check-ig-search (-> path-string? path-string? ig-search-report?)]))

(struct ig-search-report (probes hits misses errors) #:transparent)

(define skip-types '("StructureDefinition" "SearchParameter" "ValueSet" "CodeSystem" "CapabilityStatement"
                     "OperationDefinition" "ImplementationGuide" "ConceptMap" "Bundle"))

;; probe-values : Row -> (listof query-value)
(define (probe-values row)
  (cond
    [(token-row? row) (list (if (token-row-system row)
                                (string-append (token-row-system row) "|" (token-row-code row))
                                (token-row-code row)))]
    [(reference-row? row) (list (if (reference-row-target-type row)
                                    (string-append (reference-row-target-type row) "/" (reference-row-target-id row))
                                    (reference-row-target-id row)))]
    [(string-row? row) (list (string-row-exact row))]
    [(date-row? row) (list (string-append "le" (date-row-low row)) (string-append "ge" (date-row-high row)))]
    [(number-row? row) (list (number->string (number-row-value row)))]
    [(quantity-row? row) (list (format "~a|~a|~a" (quantity-row-value row)
                                       (or (quantity-row-system row) "") (or (quantity-row-code row) "")))]
    [else '()]))

(define (check-ig-search ig-tgz core-tgz)
  (define catalog (merge-search-params (search-params-from-package core-tgz)
                                       (search-params-from-package ig-tgz)))
  (define db (make-temporary-file "ig-search-~a.db"))
  (define store (open-fhir-store db))
  (define loaded                                   ; (listof (list type id node))
    (for*/list ([r (in-list (let-values ([(_m rs exs) (read-package ig-tgz #:exact-decimals? #t)]) (append rs exs)))]
                [t (in-value (hash-ref (cdr r) 'resourceType #f))]
                #:when (and (string? t) (not (member t skip-types)) (type-registered? (string->symbol t))))
      (define-values (_t id _v) (fhir-create! store (strip-jnum (cdr r)) #:search-params catalog))
      (define nr (from-json (cdr r) #:lenient? #t))
      (list t id (and (ok? nr) (ok-value nr)))))
  (define errors
    (remove-duplicates
     (for*/list ([ex (in-list loaded)] #:when (caddr ex)
                 [sp (in-list (hash-ref catalog (string->symbol (car ex)) '()))]
                 #:when (indexed-kind? (search-param-kind sp))
                 [msg (in-value (with-handlers ([exn:fail? exn-message])
                                  (eval-fhirpath (parse-fhirpath (search-param-path sp)) (list (caddr ex))
                                                 #:strict? #f)
                                  #f))]
                 #:when msg)
       (list (car ex) (search-param-name sp) msg))))
  (define-values (probes hits misses)
    (for*/fold ([probes 0] [hits 0] [misses '()])
               ([ex (in-list loaded)] #:when (caddr ex)
                [sp (in-list (hash-ref catalog (string->symbol (car ex)) '()))]
                #:when (indexed-kind? (search-param-kind sp))
                [items (in-value (with-handlers ([exn:fail? (lambda (_) '())])
                                   (eval-fhirpath (parse-fhirpath (search-param-path sp)) (list (caddr ex))
                                                  #:strict? #f)))]
                [row (in-value (let ([rs (rows-for (search-param-kind sp) items)]) (and (pair? rs) (car rs))))]
                #:when row
                [v (in-list (probe-values row))])
      (define found (for/or ([js (in-list (fhir-search store (car ex) (list (cons (search-param-name sp) v))
                                                      #:search-params catalog))])
                      (equal? (hash-ref js 'id #f) (cadr ex))))
      (if found
          (values (add1 probes) (add1 hits) misses)
          (values (add1 probes) hits (cons (list (car ex) (search-param-name sp) (search-param-kind sp) v) misses)))))
  (close-fhir-store store)
  (delete-file db)
  (ig-search-report probes hits (reverse misses) errors))
