#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'ResearchSubject (fhir-spec 'ResearchSubject "https://build.fhir.org/researchsubject.html#ResearchSubject" 'type)
  #:schema (type-schema 'ResearchSubject #f 'DomainResource "https://build.fhir.org/researchsubject.html#ResearchSubject"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://build.fhir.org/researchsubject.html#ResearchSubject.identifier" #f)
    (schema-field 'status 1 1 (vector 'prim "code") #f "https://build.fhir.org/researchsubject.html#ResearchSubject.status" #f)
    (schema-field 'period 0 1 (vector 'type 'Period) #f "https://build.fhir.org/researchsubject.html#ResearchSubject.period" #f)
    (schema-field 'study 1 1 (vector 'type 'Reference) #f "https://build.fhir.org/researchsubject.html#ResearchSubject.study" #f)
    (schema-field 'subject 1 1 (vector 'type 'Reference) #f "https://build.fhir.org/researchsubject.html#ResearchSubject.subject" #f)
    (schema-field 'subjectState 0 '* (vector 'type 'ResearchSubjectSubjectState) #f "https://build.fhir.org/researchsubject.html#ResearchSubject.subjectState" #f)
    (schema-field 'subjectMilestone 0 '* (vector 'type 'ResearchSubjectSubjectMilestone) #f "https://build.fhir.org/researchsubject.html#ResearchSubject.subjectMilestone" #f)
    (schema-field 'comparisonGroup 0 '* (vector 'type 'CodeableReference) #f "https://build.fhir.org/researchsubject.html#ResearchSubject.comparisonGroup" #f)
    (schema-field 'consent 0 '* (vector 'type 'Reference) #f "https://build.fhir.org/researchsubject.html#ResearchSubject.consent" #f)
             ) #f #f))
(register-element! "ResearchSubject.identifier" (fhir-spec (string->symbol "ResearchSubject.identifier") "https://build.fhir.org/researchsubject.html#ResearchSubject.identifier" 'element))
(register-element! "ResearchSubject.status" (fhir-spec (string->symbol "ResearchSubject.status") "https://build.fhir.org/researchsubject.html#ResearchSubject.status" 'element))
(register-element! "ResearchSubject.period" (fhir-spec (string->symbol "ResearchSubject.period") "https://build.fhir.org/researchsubject.html#ResearchSubject.period" 'element))
(register-element! "ResearchSubject.study" (fhir-spec (string->symbol "ResearchSubject.study") "https://build.fhir.org/researchsubject.html#ResearchSubject.study" 'element))
(register-element! "ResearchSubject.subject" (fhir-spec (string->symbol "ResearchSubject.subject") "https://build.fhir.org/researchsubject.html#ResearchSubject.subject" 'element))
(register-element! "ResearchSubject.subjectState" (fhir-spec (string->symbol "ResearchSubject.subjectState") "https://build.fhir.org/researchsubject.html#ResearchSubject.subjectState" 'element))
(register-element! "ResearchSubject.subjectMilestone" (fhir-spec (string->symbol "ResearchSubject.subjectMilestone") "https://build.fhir.org/researchsubject.html#ResearchSubject.subjectMilestone" 'element))
(register-element! "ResearchSubject.comparisonGroup" (fhir-spec (string->symbol "ResearchSubject.comparisonGroup") "https://build.fhir.org/researchsubject.html#ResearchSubject.comparisonGroup" 'element))
(register-element! "ResearchSubject.consent" (fhir-spec (string->symbol "ResearchSubject.consent") "https://build.fhir.org/researchsubject.html#ResearchSubject.consent" 'element))

(register-type! 'ResearchSubjectSubjectState (fhir-spec 'ResearchSubjectSubjectState "https://build.fhir.org/researchsubject.html#ResearchSubject.subjectState" 'type)
  #:schema (type-schema 'ResearchSubjectSubjectState #f 'BackboneElement "https://build.fhir.org/researchsubject.html#ResearchSubject.subjectState"
             (list
    (schema-field 'code 1 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/researchsubject.html#ResearchSubject.subjectState.code" #f)
    (schema-field 'startDate 1 1 (vector 'prim "dateTime") #f "https://build.fhir.org/researchsubject.html#ResearchSubject.subjectState.startDate" #f)
    (schema-field 'endDate 0 1 (vector 'prim "dateTime") #f "https://build.fhir.org/researchsubject.html#ResearchSubject.subjectState.endDate" #f)
    (schema-field 'reason 0 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/researchsubject.html#ResearchSubject.subjectState.reason" #f)
             ) #f #f))
(register-element! "ResearchSubject.subjectState.code" (fhir-spec (string->symbol "ResearchSubject.subjectState.code") "https://build.fhir.org/researchsubject.html#ResearchSubject.subjectState.code" 'element))
(register-element! "ResearchSubject.subjectState.startDate" (fhir-spec (string->symbol "ResearchSubject.subjectState.startDate") "https://build.fhir.org/researchsubject.html#ResearchSubject.subjectState.startDate" 'element))
(register-element! "ResearchSubject.subjectState.endDate" (fhir-spec (string->symbol "ResearchSubject.subjectState.endDate") "https://build.fhir.org/researchsubject.html#ResearchSubject.subjectState.endDate" 'element))
(register-element! "ResearchSubject.subjectState.reason" (fhir-spec (string->symbol "ResearchSubject.subjectState.reason") "https://build.fhir.org/researchsubject.html#ResearchSubject.subjectState.reason" 'element))

(register-type! 'ResearchSubjectSubjectMilestone (fhir-spec 'ResearchSubjectSubjectMilestone "https://build.fhir.org/researchsubject.html#ResearchSubject.subjectMilestone" 'type)
  #:schema (type-schema 'ResearchSubjectSubjectMilestone #f 'BackboneElement "https://build.fhir.org/researchsubject.html#ResearchSubject.subjectMilestone"
             (list
    (schema-field 'milestone 1 1 (vector 'type 'CodeableConcept) #f "https://build.fhir.org/researchsubject.html#ResearchSubject.subjectMilestone.milestone" #f)
    (schema-field 'date 0 1 (vector 'prim "dateTime") #f "https://build.fhir.org/researchsubject.html#ResearchSubject.subjectMilestone.date" #f)
    (schema-field 'reason 0 '* (vector 'type 'CodeableConcept) #f "https://build.fhir.org/researchsubject.html#ResearchSubject.subjectMilestone.reason" #f)
             ) #f #f))
(register-element! "ResearchSubject.subjectMilestone.milestone" (fhir-spec (string->symbol "ResearchSubject.subjectMilestone.milestone") "https://build.fhir.org/researchsubject.html#ResearchSubject.subjectMilestone.milestone" 'element))
(register-element! "ResearchSubject.subjectMilestone.date" (fhir-spec (string->symbol "ResearchSubject.subjectMilestone.date") "https://build.fhir.org/researchsubject.html#ResearchSubject.subjectMilestone.date" 'element))
(register-element! "ResearchSubject.subjectMilestone.reason" (fhir-spec (string->symbol "ResearchSubject.subjectMilestone.reason") "https://build.fhir.org/researchsubject.html#ResearchSubject.subjectMilestone.reason" 'element))

