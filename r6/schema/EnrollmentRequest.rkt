#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'EnrollmentRequest (fhir-spec 'EnrollmentRequest "https://build.fhir.org/enrollmentrequest.html#EnrollmentRequest" 'type)
  #:schema (type-schema 'EnrollmentRequest #f 'DomainResource "https://build.fhir.org/enrollmentrequest.html#EnrollmentRequest"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://build.fhir.org/enrollmentrequest.html#EnrollmentRequest.identifier" #f)
    (schema-field 'status 0 1 (vector 'prim "code") #f "https://build.fhir.org/enrollmentrequest.html#EnrollmentRequest.status" #f)
    (schema-field 'created 0 1 (vector 'prim "dateTime") #f "https://build.fhir.org/enrollmentrequest.html#EnrollmentRequest.created" #f)
    (schema-field 'insurer 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/enrollmentrequest.html#EnrollmentRequest.insurer" #f)
    (schema-field 'provider 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/enrollmentrequest.html#EnrollmentRequest.provider" #f)
    (schema-field 'candidate 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/enrollmentrequest.html#EnrollmentRequest.candidate" #f)
    (schema-field 'coverage 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/enrollmentrequest.html#EnrollmentRequest.coverage" #f)
             ) #f #f))
(register-element! "EnrollmentRequest.identifier" (fhir-spec (string->symbol "EnrollmentRequest.identifier") "https://build.fhir.org/enrollmentrequest.html#EnrollmentRequest.identifier" 'element))
(register-element! "EnrollmentRequest.status" (fhir-spec (string->symbol "EnrollmentRequest.status") "https://build.fhir.org/enrollmentrequest.html#EnrollmentRequest.status" 'element))
(register-element! "EnrollmentRequest.created" (fhir-spec (string->symbol "EnrollmentRequest.created") "https://build.fhir.org/enrollmentrequest.html#EnrollmentRequest.created" 'element))
(register-element! "EnrollmentRequest.insurer" (fhir-spec (string->symbol "EnrollmentRequest.insurer") "https://build.fhir.org/enrollmentrequest.html#EnrollmentRequest.insurer" 'element))
(register-element! "EnrollmentRequest.provider" (fhir-spec (string->symbol "EnrollmentRequest.provider") "https://build.fhir.org/enrollmentrequest.html#EnrollmentRequest.provider" 'element))
(register-element! "EnrollmentRequest.candidate" (fhir-spec (string->symbol "EnrollmentRequest.candidate") "https://build.fhir.org/enrollmentrequest.html#EnrollmentRequest.candidate" 'element))
(register-element! "EnrollmentRequest.coverage" (fhir-spec (string->symbol "EnrollmentRequest.coverage") "https://build.fhir.org/enrollmentrequest.html#EnrollmentRequest.coverage" 'element))

