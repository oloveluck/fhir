#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'EnrollmentResponse (fhir-spec 'EnrollmentResponse "https://hl7.org/fhir/R4/enrollmentresponse.html#EnrollmentResponse" 'type)
  #:schema (type-schema 'EnrollmentResponse #f 'DomainResource "https://hl7.org/fhir/R4/enrollmentresponse.html#EnrollmentResponse"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R4/enrollmentresponse.html#EnrollmentResponse.identifier" #f)
    (schema-field 'status 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/enrollmentresponse.html#EnrollmentResponse.status" #f)
    (schema-field 'request 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/enrollmentresponse.html#EnrollmentResponse.request" #f)
    (schema-field 'outcome 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/enrollmentresponse.html#EnrollmentResponse.outcome" #f)
    (schema-field 'disposition 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/enrollmentresponse.html#EnrollmentResponse.disposition" #f)
    (schema-field 'created 0 1 (vector 'prim "dateTime") #f "https://hl7.org/fhir/R4/enrollmentresponse.html#EnrollmentResponse.created" #f)
    (schema-field 'organization 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/enrollmentresponse.html#EnrollmentResponse.organization" #f)
    (schema-field 'requestProvider 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/enrollmentresponse.html#EnrollmentResponse.requestProvider" #f)
             ) #f #f))
(register-element! "EnrollmentResponse.identifier" (fhir-spec (string->symbol "EnrollmentResponse.identifier") "https://hl7.org/fhir/R4/enrollmentresponse.html#EnrollmentResponse.identifier" 'element))
(register-element! "EnrollmentResponse.status" (fhir-spec (string->symbol "EnrollmentResponse.status") "https://hl7.org/fhir/R4/enrollmentresponse.html#EnrollmentResponse.status" 'element))
(register-element! "EnrollmentResponse.request" (fhir-spec (string->symbol "EnrollmentResponse.request") "https://hl7.org/fhir/R4/enrollmentresponse.html#EnrollmentResponse.request" 'element))
(register-element! "EnrollmentResponse.outcome" (fhir-spec (string->symbol "EnrollmentResponse.outcome") "https://hl7.org/fhir/R4/enrollmentresponse.html#EnrollmentResponse.outcome" 'element))
(register-element! "EnrollmentResponse.disposition" (fhir-spec (string->symbol "EnrollmentResponse.disposition") "https://hl7.org/fhir/R4/enrollmentresponse.html#EnrollmentResponse.disposition" 'element))
(register-element! "EnrollmentResponse.created" (fhir-spec (string->symbol "EnrollmentResponse.created") "https://hl7.org/fhir/R4/enrollmentresponse.html#EnrollmentResponse.created" 'element))
(register-element! "EnrollmentResponse.organization" (fhir-spec (string->symbol "EnrollmentResponse.organization") "https://hl7.org/fhir/R4/enrollmentresponse.html#EnrollmentResponse.organization" 'element))
(register-element! "EnrollmentResponse.requestProvider" (fhir-spec (string->symbol "EnrollmentResponse.requestProvider") "https://hl7.org/fhir/R4/enrollmentresponse.html#EnrollmentResponse.requestProvider" 'element))

