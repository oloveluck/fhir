#lang racket/base

;;; views.rkt — the workspace's own tables, as SQL on FHIR ViewDefinitions.
;;;
;;; What the workspace flattens for SQL — the trail of commits, and a type's values beside it — is
;;; written as ViewDefinitions (https://sql-on-fhir.org) and run by the sql-on-fhir engine, the same
;;; way a workspace's `*.view.json` files are: columns are FHIRPath over the typed resource, not JSON
;;; paths and string slicing in SQL. Pure: each function answers a ViewDefinition (jsexpr).
;;;
;;;   trail-view   : fhir-version -> ViewDefinition over Provenance
;;;                  one row per version a commit wrote (a target `Type/id/_history/v`):
;;;                  type, id, versionId, at | recorded, agent, reason, source, sha1, provenance
;;;   values-view  : type has? -> ViewDefinition over the type
;;;                  id, versionId, then what the type has of subject, name (a Patient's own),
;;;                  value (value[x], else its components' values joined by " / "), date
;;;   names-view   : -> ViewDefinition over Patient   id, name ("given family")
;;;
;;; `has?` : symbol -> boolean says whether the type has an element (`value` for value[x]); the
;;; workspace answers it from the FHIR tower it registered, so a column names only elements the type
;;; has (FHIRPath over an element a type lacks is an error in a strict engine).

(require racket/contract racket/string racket/list)

(provide
 (contract-out
  [trail-view (-> string? hash?)]
  [values-view (-> string? (-> symbol? any/c) hash?)]
  [names-view (-> hash?)]
  [sha1-system string?]
  [source-line-url string?]))

;; sha1-system : a source's SHA-1 is the Provenance entity's identifier in this system (RFC 3174, hex)
(define sha1-system "urn:ietf:rfc:3174")
;; source-line-url : the extension a Provenance target carries: the file and line that wrote it
(define source-line-url "urn:fhir-mcp:source-line")

;; col : name path [type] -> Column
(define (col name path [type #f])
  (if type (hasheq 'name name 'path path 'type type) (hasheq 'name name 'path path)))

(define (view name resource description select)
  (hasheq 'resourceType "ViewDefinition" 'name name 'status "active" 'resource resource
          'description description 'select select))

;; first-of : (listof fhirpath) -> fhirpath   the first that has a value, in this order (a union does
;; not promise one)
(define (first-of exprs)
  (if (null? (cdr exprs))
      (car exprs)
      (format "iif(~a.exists(), ~a, ~a)" (car exprs) (car exprs) (first-of (cdr exprs)))))

(define (r4? v) (regexp-match? #rx"^4[.]" v))

;; trail-view : version -> ViewDefinition
;; A target is `Type/id/_history/v` (a commit names the version it wrote); `at` is the target's
;; source-line extension; the reason is R4's `reason.text`, R5's `why`.
(define (trail-view v)
  (define ref "reference")
  (view "trail" "Provenance"
        "Each version a commit wrote: who, when, why, from which source (its SHA-1 apart) and line."
        (list (hasheq 'forEach (format "target.where(~a.contains('/_history/'))" ref)
                      'column (list (col "type" (format "~a.substring(0, ~a.indexOf('/'))" ref ref))
                                    (col "id" (format "~a.substring(~a.indexOf('/') + 1, ~a.indexOf('/_history/') - ~a.indexOf('/') - 1)" ref ref ref ref))
                                    (col "versionId" (format "~a.substring(~a.indexOf('/_history/') + 10).toInteger()" ref ref) "integer")
                                    (col "at" (format "extension('~a').value.ofType(string)" source-line-url))))
              (hasheq 'column (list (col "recorded" "recorded")
                                    (col "agent" "agent.first().who.select(iif(display.exists(), display, reference))")
                                    (col "reason" (if (r4? v) "reason.text.first()" "why"))
                                    (col "source" "entity.first().what.display")
                                    (col "sha1" (format "entity.first().what.identifier.where(system = '~a').value" sha1-system))
                                    (col "provenance" "'Provenance/' + getResourceKey()"))))))

;; value-text : fhirpath -> fhirpath   a value[x] as one line: a Quantity `120 mm[Hg]` (code, else
;; unit), a string, a CodeableConcept's first code, a boolean
(define (value-text x)
  (first-of (list (format "~a.ofType(Quantity).select(value.toString() + ' ' + iif(code.exists(), code, iif(unit.exists(), unit, '')))" x)
                  (format "~a.ofType(string)" x)
                  (format "~a.ofType(CodeableConcept).coding.first().code" x)
                  (format "~a.ofType(boolean).toString()" x))))

;; name-text : the first name as "given family" (else its text)
(define name-text
  "name.first().select((iif(given.exists(), given.first(), '') + ' ' + iif(family.exists(), family, iif(text.exists(), text, ''))).trim())")

;; values-view : type has? -> ViewDefinition
(define (values-view type has?)
  (define subject (filter-map (lambda (e) (and (has? e) (format "~a.reference" e))) '(subject patient)))
  (define value
    (cond [(and (has? 'value) (has? 'component))
           (format "iif(value.exists(), ~a, iif(component.exists(), component.select(~a).join(' / '), {}))"
                   (value-text "value") (value-text "value"))]
          [(has? 'value) (value-text "value")]
          [(has? 'component) (format "iif(component.exists(), component.select(~a).join(' / '), {})" (value-text "value"))]
          [else #f]))
  (define dates
    (append (if (has? 'effective) '("effective.ofType(dateTime)" "effective.ofType(Period).start") '())
            (filter-map (lambda (e) (and (has? e) (symbol->string e))) '(issued authoredOn recordedDate birthDate))))
  (view (string-append (string-downcase type) "_values") type
        (format "Each ~a with its subject, value and date." type)
        (list (hasheq 'column
                      (append (list (col "id" "getResourceKey()") (col "versionId" "meta.versionId"))
                              (if (pair? subject) (list (col "subject" (first-of subject))) '())
                              (if (equal? type "Patient") (list (col "name" name-text)) '())
                              (if value (list (col "value" value)) '())
                              (if (pair? dates) (list (col "date" (first-of dates))) '()))))))

;; names-view : -> ViewDefinition   each Patient's id and name
(define (names-view)
  (view "patient_names" "Patient" "Each patient's name, given then family."
        (list (hasheq 'column (list (col "id" "getResourceKey()") (col "name" name-text))))))

(module+ test
  (require rackunit)
  (define obs (lambda (e) (memq e '(subject value component effective issued))))
  (define v (values-view "Observation" obs))
  (check-equal? (map (lambda (c) (hash-ref c 'name)) (hash-ref (car (hash-ref v 'select)) 'column))
                '("id" "versionId" "subject" "value" "date"))
  ;; a type's columns are only the elements it has (a Patient has no value; its name is its own)
  (define p (values-view "Patient" (lambda (e) (memq e '(birthDate)))))
  (check-equal? (map (lambda (c) (hash-ref c 'name)) (hash-ref (car (hash-ref p 'select)) 'column))
                '("id" "versionId" "name" "date"))
  (check-regexp-match #rx"reason[.]text" (hash-ref (list-ref (hash-ref (cadr (hash-ref (trail-view "4.0.1") 'select)) 'column) 2) 'path))
  (check-equal? (hash-ref (list-ref (hash-ref (cadr (hash-ref (trail-view "5.0.0") 'select)) 'column) 2) 'path) "why")
  (check-equal? (first-of '("a" "b")) "iif(a.exists(), a, b)"))
