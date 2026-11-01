#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'OperationOutcome (fhir-spec 'OperationOutcome "https://hl7.org/fhir/R5/operationoutcome.html#OperationOutcome" 'type)
  #:schema (type-schema 'OperationOutcome #f 'DomainResource "https://hl7.org/fhir/R5/operationoutcome.html#OperationOutcome"
             (list
    (schema-field 'issue 1 '* (vector 'type 'OperationOutcomeIssue) #f "https://hl7.org/fhir/R5/operationoutcome.html#OperationOutcome.issue" #f)
             ) #f #f))
(register-element! "OperationOutcome.issue" (fhir-spec (string->symbol "OperationOutcome.issue") "https://hl7.org/fhir/R5/operationoutcome.html#OperationOutcome.issue" 'element))

(register-type! 'OperationOutcomeIssue (fhir-spec 'OperationOutcomeIssue "https://hl7.org/fhir/R5/operationoutcome.html#OperationOutcome.issue" 'type)
  #:schema (type-schema 'OperationOutcomeIssue #f 'BackboneElement "https://hl7.org/fhir/R5/operationoutcome.html#OperationOutcome.issue"
             (list
    (schema-field 'severity 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/operationoutcome.html#OperationOutcome.issue.severity" #f)
    (schema-field 'code 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/operationoutcome.html#OperationOutcome.issue.code" #f)
    (schema-field 'details 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/operationoutcome.html#OperationOutcome.issue.details" #f)
    (schema-field 'diagnostics 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/operationoutcome.html#OperationOutcome.issue.diagnostics" #f)
    (schema-field 'location 0 '* (vector 'prim "string") #f "https://hl7.org/fhir/R5/operationoutcome.html#OperationOutcome.issue.location" #f)
    (schema-field 'expression 0 '* (vector 'prim "string") #f "https://hl7.org/fhir/R5/operationoutcome.html#OperationOutcome.issue.expression" #f)
             ) #f #f))
(register-element! "OperationOutcome.issue.severity" (fhir-spec (string->symbol "OperationOutcome.issue.severity") "https://hl7.org/fhir/R5/operationoutcome.html#OperationOutcome.issue.severity" 'element))
(register-element! "OperationOutcome.issue.code" (fhir-spec (string->symbol "OperationOutcome.issue.code") "https://hl7.org/fhir/R5/operationoutcome.html#OperationOutcome.issue.code" 'element))
(register-element! "OperationOutcome.issue.details" (fhir-spec (string->symbol "OperationOutcome.issue.details") "https://hl7.org/fhir/R5/operationoutcome.html#OperationOutcome.issue.details" 'element))
(register-element! "OperationOutcome.issue.diagnostics" (fhir-spec (string->symbol "OperationOutcome.issue.diagnostics") "https://hl7.org/fhir/R5/operationoutcome.html#OperationOutcome.issue.diagnostics" 'element))
(register-element! "OperationOutcome.issue.location" (fhir-spec (string->symbol "OperationOutcome.issue.location") "https://hl7.org/fhir/R5/operationoutcome.html#OperationOutcome.issue.location" 'element))
(register-element! "OperationOutcome.issue.expression" (fhir-spec (string->symbol "OperationOutcome.issue.expression") "https://hl7.org/fhir/R5/operationoutcome.html#OperationOutcome.issue.expression" 'element))

