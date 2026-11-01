#lang racket/base

;;; type-registry.rkt — map FHIR type codes to names + classify them (a codegen-time helper).
;;;
;;; In this project the datatypes are generated too (not hand-written model types), so only the
;;; abstract base types are excluded from generation. Everything else (datatype or resource) is
;;; generated and referenced by its bare FHIR type name.

(require racket/string)

(provide primitive-type-code?
         abstract-type?
         resolve-type
         backbone-class-name
         field-name
         choice-suffix
         system-type->fhir
         capitalize)

;; the 21 FHIR primitive type codes (match fhir/primitives/primitives.rkt)
(define primitive-codes
  (list "base64Binary" "boolean" "canonical" "code" "date" "dateTime" "decimal"
        "id" "instant" "integer" "integer64" "markdown" "oid" "positiveInt"
        "string" "time" "unsignedInt" "uri" "url" "uuid" "xhtml"))

(define (primitive-type-code? code) (and (member code primitive-codes) #t))

;; the abstract base types — never generated (hand-written in model/base.rkt)
(define abstract-codes
  (list "Base" "Element" "BackboneElement" "DataType" "BackboneType"
        "PrimitiveType" "Resource" "DomainResource"))

(define (abstract-type? code) (and (member code abstract-codes) #t))

;; FHIRPath System.* aliases used in some snapshots
(define system-map
  (hash "http://hl7.org/fhirpath/System.String"   "string"
        "http://hl7.org/fhirpath/System.Boolean"  "boolean"
        "http://hl7.org/fhirpath/System.Integer"  "integer"
        "http://hl7.org/fhirpath/System.Decimal"  "decimal"
        "http://hl7.org/fhirpath/System.Date"     "date"
        "http://hl7.org/fhirpath/System.Time"     "time"
        "http://hl7.org/fhirpath/System.DateTime" "dateTime"
        "System.String" "string" "System.Boolean" "boolean"))

(define (system-type->fhir code) (hash-ref system-map code code))

;; Quantity flavours collapse to Quantity
(define quantity-aliases (hash "SimpleQuantity" "Quantity" "MoneyQuantity" "Quantity"))

;; Resolve a FHIR type code to the bare FHIR type name it should reference.
;; Returns #f for BackboneElement/Element (signal: this field is a nested backbone).
(define (resolve-type code0)
  (define code (system-type->fhir code0))
  (cond
    [(string=? code "BackboneElement") #f]
    [(string=? code "Element") #f]
    [(hash-ref quantity-aliases code #f) => values]
    [else code]))

;; nested backbone class name from a path: "Patient.contact" -> "Contact" (parent prefixed by caller)
(define (backbone-class-name path)
  (capitalize (last* (string-split path "."))))

;; field name from a path: "Patient.deceased[x]" -> "deceased"
(define (field-name path)
  (define last (last* (string-split path ".")))
  (if (string-suffix? last "[x]") (substring last 0 (- (string-length last) 3)) last))

;; choice-type suffix: "boolean" -> "Boolean", "dateTime" -> "DateTime", "Quantity" -> "Quantity"
(define (choice-suffix code) (capitalize code))

(define (capitalize s)
  (if (= 0 (string-length s)) s
      (string-append (string-upcase (substring s 0 1)) (substring s 1))))

(define (last* xs) (car (reverse xs)))
