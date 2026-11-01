#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'ResearchSubject (fhir-spec 'ResearchSubject "https://hl7.org/fhir/R5/researchsubject.html#ResearchSubject" 'type)
  #:schema (type-schema 'ResearchSubject #f 'DomainResource "https://hl7.org/fhir/R5/researchsubject.html#ResearchSubject"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R5/researchsubject.html#ResearchSubject.identifier" #f)
    (schema-field 'status 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/researchsubject.html#ResearchSubject.status" #f)
    (schema-field 'progress 0 '* (vector 'type 'ResearchSubjectProgress) #f "https://hl7.org/fhir/R5/researchsubject.html#ResearchSubject.progress" #f)
    (schema-field 'period 0 1 (vector 'type 'Period) #f "https://hl7.org/fhir/R5/researchsubject.html#ResearchSubject.period" #f)
    (schema-field 'study 1 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/researchsubject.html#ResearchSubject.study" #f)
    (schema-field 'subject 1 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/researchsubject.html#ResearchSubject.subject" #f)
    (schema-field 'assignedComparisonGroup 0 1 (vector 'prim "id") #f "https://hl7.org/fhir/R5/researchsubject.html#ResearchSubject.assignedComparisonGroup" #f)
    (schema-field 'actualComparisonGroup 0 1 (vector 'prim "id") #f "https://hl7.org/fhir/R5/researchsubject.html#ResearchSubject.actualComparisonGroup" #f)
    (schema-field 'consent 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/researchsubject.html#ResearchSubject.consent" #f)
             ) #f #f))
(register-element! "ResearchSubject.identifier" (fhir-spec (string->symbol "ResearchSubject.identifier") "https://hl7.org/fhir/R5/researchsubject.html#ResearchSubject.identifier" 'element))
(register-element! "ResearchSubject.status" (fhir-spec (string->symbol "ResearchSubject.status") "https://hl7.org/fhir/R5/researchsubject.html#ResearchSubject.status" 'element))
(register-element! "ResearchSubject.progress" (fhir-spec (string->symbol "ResearchSubject.progress") "https://hl7.org/fhir/R5/researchsubject.html#ResearchSubject.progress" 'element))
(register-element! "ResearchSubject.period" (fhir-spec (string->symbol "ResearchSubject.period") "https://hl7.org/fhir/R5/researchsubject.html#ResearchSubject.period" 'element))
(register-element! "ResearchSubject.study" (fhir-spec (string->symbol "ResearchSubject.study") "https://hl7.org/fhir/R5/researchsubject.html#ResearchSubject.study" 'element))
(register-element! "ResearchSubject.subject" (fhir-spec (string->symbol "ResearchSubject.subject") "https://hl7.org/fhir/R5/researchsubject.html#ResearchSubject.subject" 'element))
(register-element! "ResearchSubject.assignedComparisonGroup" (fhir-spec (string->symbol "ResearchSubject.assignedComparisonGroup") "https://hl7.org/fhir/R5/researchsubject.html#ResearchSubject.assignedComparisonGroup" 'element))
(register-element! "ResearchSubject.actualComparisonGroup" (fhir-spec (string->symbol "ResearchSubject.actualComparisonGroup") "https://hl7.org/fhir/R5/researchsubject.html#ResearchSubject.actualComparisonGroup" 'element))
(register-element! "ResearchSubject.consent" (fhir-spec (string->symbol "ResearchSubject.consent") "https://hl7.org/fhir/R5/researchsubject.html#ResearchSubject.consent" 'element))

(register-type! 'ResearchSubjectProgress (fhir-spec 'ResearchSubjectProgress "https://hl7.org/fhir/R5/researchsubject.html#ResearchSubject.progress" 'type)
  #:schema (type-schema 'ResearchSubjectProgress #f 'BackboneElement "https://hl7.org/fhir/R5/researchsubject.html#ResearchSubject.progress"
             (list
    (schema-field 'type 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/researchsubject.html#ResearchSubject.progress.type" #f)
    (schema-field 'subjectState 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/researchsubject.html#ResearchSubject.progress.subjectState" #f)
    (schema-field 'milestone 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/researchsubject.html#ResearchSubject.progress.milestone" #f)
    (schema-field 'reason 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/researchsubject.html#ResearchSubject.progress.reason" #f)
    (schema-field 'startDate 0 1 (vector 'prim "dateTime") #f "https://hl7.org/fhir/R5/researchsubject.html#ResearchSubject.progress.startDate" #f)
    (schema-field 'endDate 0 1 (vector 'prim "dateTime") #f "https://hl7.org/fhir/R5/researchsubject.html#ResearchSubject.progress.endDate" #f)
             ) #f #f))
(register-element! "ResearchSubject.progress.type" (fhir-spec (string->symbol "ResearchSubject.progress.type") "https://hl7.org/fhir/R5/researchsubject.html#ResearchSubject.progress.type" 'element))
(register-element! "ResearchSubject.progress.subjectState" (fhir-spec (string->symbol "ResearchSubject.progress.subjectState") "https://hl7.org/fhir/R5/researchsubject.html#ResearchSubject.progress.subjectState" 'element))
(register-element! "ResearchSubject.progress.milestone" (fhir-spec (string->symbol "ResearchSubject.progress.milestone") "https://hl7.org/fhir/R5/researchsubject.html#ResearchSubject.progress.milestone" 'element))
(register-element! "ResearchSubject.progress.reason" (fhir-spec (string->symbol "ResearchSubject.progress.reason") "https://hl7.org/fhir/R5/researchsubject.html#ResearchSubject.progress.reason" 'element))
(register-element! "ResearchSubject.progress.startDate" (fhir-spec (string->symbol "ResearchSubject.progress.startDate") "https://hl7.org/fhir/R5/researchsubject.html#ResearchSubject.progress.startDate" 'element))
(register-element! "ResearchSubject.progress.endDate" (fhir-spec (string->symbol "ResearchSubject.progress.endDate") "https://hl7.org/fhir/R5/researchsubject.html#ResearchSubject.progress.endDate" 'element))

