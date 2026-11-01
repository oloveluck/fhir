#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'EnrollmentResponse (fhir-spec 'EnrollmentResponse "https://build.fhir.org/enrollmentresponse.html#EnrollmentResponse" 'type)
  #:schema (type-schema 'EnrollmentResponse #f 'DomainResource "https://build.fhir.org/enrollmentresponse.html#EnrollmentResponse"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://build.fhir.org/enrollmentresponse.html#EnrollmentResponse.identifier" #f)
    (schema-field 'status 0 1 (vector 'prim "code") #f "https://build.fhir.org/enrollmentresponse.html#EnrollmentResponse.status" #f)
    (schema-field 'request 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/enrollmentresponse.html#EnrollmentResponse.request" #f)
    (schema-field 'outcome 0 1 (vector 'prim "code") #f "https://build.fhir.org/enrollmentresponse.html#EnrollmentResponse.outcome" #f)
    (schema-field 'disposition 0 1 (vector 'prim "string") #f "https://build.fhir.org/enrollmentresponse.html#EnrollmentResponse.disposition" #f)
    (schema-field 'created 0 1 (vector 'prim "dateTime") #f "https://build.fhir.org/enrollmentresponse.html#EnrollmentResponse.created" #f)
    (schema-field 'organization 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/enrollmentresponse.html#EnrollmentResponse.organization" #f)
    (schema-field 'requestProvider 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/enrollmentresponse.html#EnrollmentResponse.requestProvider" #f)
    (schema-field 'candidate 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/enrollmentresponse.html#EnrollmentResponse.candidate" #f)
             ) #f #f))
(register-element! "EnrollmentResponse.identifier" (fhir-spec (string->symbol "EnrollmentResponse.identifier") "https://build.fhir.org/enrollmentresponse.html#EnrollmentResponse.identifier" 'element))
(register-element! "EnrollmentResponse.status" (fhir-spec (string->symbol "EnrollmentResponse.status") "https://build.fhir.org/enrollmentresponse.html#EnrollmentResponse.status" 'element))
(register-element! "EnrollmentResponse.request" (fhir-spec (string->symbol "EnrollmentResponse.request") "https://build.fhir.org/enrollmentresponse.html#EnrollmentResponse.request" 'element))
(register-element! "EnrollmentResponse.outcome" (fhir-spec (string->symbol "EnrollmentResponse.outcome") "https://build.fhir.org/enrollmentresponse.html#EnrollmentResponse.outcome" 'element))
(register-element! "EnrollmentResponse.disposition" (fhir-spec (string->symbol "EnrollmentResponse.disposition") "https://build.fhir.org/enrollmentresponse.html#EnrollmentResponse.disposition" 'element))
(register-element! "EnrollmentResponse.created" (fhir-spec (string->symbol "EnrollmentResponse.created") "https://build.fhir.org/enrollmentresponse.html#EnrollmentResponse.created" 'element))
(register-element! "EnrollmentResponse.organization" (fhir-spec (string->symbol "EnrollmentResponse.organization") "https://build.fhir.org/enrollmentresponse.html#EnrollmentResponse.organization" 'element))
(register-element! "EnrollmentResponse.requestProvider" (fhir-spec (string->symbol "EnrollmentResponse.requestProvider") "https://build.fhir.org/enrollmentresponse.html#EnrollmentResponse.requestProvider" 'element))
(register-element! "EnrollmentResponse.candidate" (fhir-spec (string->symbol "EnrollmentResponse.candidate") "https://build.fhir.org/enrollmentresponse.html#EnrollmentResponse.candidate" 'element))

