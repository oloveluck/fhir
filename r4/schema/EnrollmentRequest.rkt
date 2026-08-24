#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'EnrollmentRequest (fhir-spec 'EnrollmentRequest "https://hl7.org/fhir/R4/enrollmentrequest.html#EnrollmentRequest" 'type)
  #:schema (type-schema 'EnrollmentRequest #f 'DomainResource "https://hl7.org/fhir/R4/enrollmentrequest.html#EnrollmentRequest"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R4/enrollmentrequest.html#EnrollmentRequest.identifier" #f)
    (schema-field 'status 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/enrollmentrequest.html#EnrollmentRequest.status" #f)
    (schema-field 'created 0 1 (vector 'prim "dateTime") #f "https://hl7.org/fhir/R4/enrollmentrequest.html#EnrollmentRequest.created" #f)
    (schema-field 'insurer 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/enrollmentrequest.html#EnrollmentRequest.insurer" #f)
    (schema-field 'provider 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/enrollmentrequest.html#EnrollmentRequest.provider" #f)
    (schema-field 'candidate 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/enrollmentrequest.html#EnrollmentRequest.candidate" #f)
    (schema-field 'coverage 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/enrollmentrequest.html#EnrollmentRequest.coverage" #f)
             ) #f #f))
(register-element! "EnrollmentRequest.identifier" (fhir-spec (string->symbol "EnrollmentRequest.identifier") "https://hl7.org/fhir/R4/enrollmentrequest.html#EnrollmentRequest.identifier" 'element))
(register-element! "EnrollmentRequest.status" (fhir-spec (string->symbol "EnrollmentRequest.status") "https://hl7.org/fhir/R4/enrollmentrequest.html#EnrollmentRequest.status" 'element))
(register-element! "EnrollmentRequest.created" (fhir-spec (string->symbol "EnrollmentRequest.created") "https://hl7.org/fhir/R4/enrollmentrequest.html#EnrollmentRequest.created" 'element))
(register-element! "EnrollmentRequest.insurer" (fhir-spec (string->symbol "EnrollmentRequest.insurer") "https://hl7.org/fhir/R4/enrollmentrequest.html#EnrollmentRequest.insurer" 'element))
(register-element! "EnrollmentRequest.provider" (fhir-spec (string->symbol "EnrollmentRequest.provider") "https://hl7.org/fhir/R4/enrollmentrequest.html#EnrollmentRequest.provider" 'element))
(register-element! "EnrollmentRequest.candidate" (fhir-spec (string->symbol "EnrollmentRequest.candidate") "https://hl7.org/fhir/R4/enrollmentrequest.html#EnrollmentRequest.candidate" 'element))
(register-element! "EnrollmentRequest.coverage" (fhir-spec (string->symbol "EnrollmentRequest.coverage") "https://hl7.org/fhir/R4/enrollmentrequest.html#EnrollmentRequest.coverage" 'element))

