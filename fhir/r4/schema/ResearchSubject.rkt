#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'ResearchSubject (fhir-spec 'ResearchSubject "https://hl7.org/fhir/R4/researchsubject.html#ResearchSubject" 'type)
  #:schema (type-schema 'ResearchSubject #f 'DomainResource "https://hl7.org/fhir/R4/researchsubject.html#ResearchSubject"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R4/researchsubject.html#ResearchSubject.identifier" #f)
    (schema-field 'status 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/researchsubject.html#ResearchSubject.status" #f)
    (schema-field 'period 0 1 (vector 'type 'Period) #f "https://hl7.org/fhir/R4/researchsubject.html#ResearchSubject.period" #f)
    (schema-field 'study 1 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/researchsubject.html#ResearchSubject.study" #f)
    (schema-field 'individual 1 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/researchsubject.html#ResearchSubject.individual" #f)
    (schema-field 'assignedArm 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/researchsubject.html#ResearchSubject.assignedArm" #f)
    (schema-field 'actualArm 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/researchsubject.html#ResearchSubject.actualArm" #f)
    (schema-field 'consent 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/researchsubject.html#ResearchSubject.consent" #f)
             ) #f #f))
(register-element! "ResearchSubject.identifier" (fhir-spec (string->symbol "ResearchSubject.identifier") "https://hl7.org/fhir/R4/researchsubject.html#ResearchSubject.identifier" 'element))
(register-element! "ResearchSubject.status" (fhir-spec (string->symbol "ResearchSubject.status") "https://hl7.org/fhir/R4/researchsubject.html#ResearchSubject.status" 'element))
(register-element! "ResearchSubject.period" (fhir-spec (string->symbol "ResearchSubject.period") "https://hl7.org/fhir/R4/researchsubject.html#ResearchSubject.period" 'element))
(register-element! "ResearchSubject.study" (fhir-spec (string->symbol "ResearchSubject.study") "https://hl7.org/fhir/R4/researchsubject.html#ResearchSubject.study" 'element))
(register-element! "ResearchSubject.individual" (fhir-spec (string->symbol "ResearchSubject.individual") "https://hl7.org/fhir/R4/researchsubject.html#ResearchSubject.individual" 'element))
(register-element! "ResearchSubject.assignedArm" (fhir-spec (string->symbol "ResearchSubject.assignedArm") "https://hl7.org/fhir/R4/researchsubject.html#ResearchSubject.assignedArm" 'element))
(register-element! "ResearchSubject.actualArm" (fhir-spec (string->symbol "ResearchSubject.actualArm") "https://hl7.org/fhir/R4/researchsubject.html#ResearchSubject.actualArm" 'element))
(register-element! "ResearchSubject.consent" (fhir-spec (string->symbol "ResearchSubject.consent") "https://hl7.org/fhir/R4/researchsubject.html#ResearchSubject.consent" 'element))

