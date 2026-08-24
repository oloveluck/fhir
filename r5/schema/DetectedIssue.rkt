#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'DetectedIssue (fhir-spec 'DetectedIssue "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue" 'type)
  #:schema (type-schema 'DetectedIssue #f 'DomainResource "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue.identifier" #f)
    (schema-field 'status 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue.status" #f)
    (schema-field 'category 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue.category" #f)
    (schema-field 'code 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue.code" #f)
    (schema-field 'severity 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue.severity" #f)
    (schema-field 'subject 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue.subject" #f)
    (schema-field 'encounter 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue.encounter" #f)
    (schema-field 'author 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue.author" #f)
    (schema-field 'implicated 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue.implicated" #f)
    (schema-field 'evidence 0 '* (vector 'type 'DetectedIssueEvidence) #f "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue.evidence" #f)
    (schema-field 'detail 0 1 (vector 'prim "markdown") #f "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue.detail" #f)
    (schema-field 'reference 0 1 (vector 'prim "uri") #f "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue.reference" #f)
    (schema-field 'mitigation 0 '* (vector 'type 'DetectedIssueMitigation) #f "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue.mitigation" #f)
    (schema-field 'identifiedDateTime 0 1 (vector 'prim "dateTime") 'identified "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue.identified[x]" #f)
    (schema-field 'identifiedPeriod 0 1 (vector 'type 'Period) 'identified "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue.identified[x]" #f)
             ) #f #f))
(register-element! "DetectedIssue.identifier" (fhir-spec (string->symbol "DetectedIssue.identifier") "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue.identifier" 'element))
(register-element! "DetectedIssue.status" (fhir-spec (string->symbol "DetectedIssue.status") "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue.status" 'element))
(register-element! "DetectedIssue.category" (fhir-spec (string->symbol "DetectedIssue.category") "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue.category" 'element))
(register-element! "DetectedIssue.code" (fhir-spec (string->symbol "DetectedIssue.code") "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue.code" 'element))
(register-element! "DetectedIssue.severity" (fhir-spec (string->symbol "DetectedIssue.severity") "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue.severity" 'element))
(register-element! "DetectedIssue.subject" (fhir-spec (string->symbol "DetectedIssue.subject") "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue.subject" 'element))
(register-element! "DetectedIssue.encounter" (fhir-spec (string->symbol "DetectedIssue.encounter") "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue.encounter" 'element))
(register-element! "DetectedIssue.author" (fhir-spec (string->symbol "DetectedIssue.author") "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue.author" 'element))
(register-element! "DetectedIssue.implicated" (fhir-spec (string->symbol "DetectedIssue.implicated") "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue.implicated" 'element))
(register-element! "DetectedIssue.evidence" (fhir-spec (string->symbol "DetectedIssue.evidence") "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue.evidence" 'element))
(register-element! "DetectedIssue.detail" (fhir-spec (string->symbol "DetectedIssue.detail") "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue.detail" 'element))
(register-element! "DetectedIssue.reference" (fhir-spec (string->symbol "DetectedIssue.reference") "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue.reference" 'element))
(register-element! "DetectedIssue.mitigation" (fhir-spec (string->symbol "DetectedIssue.mitigation") "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue.mitigation" 'element))
(register-element! "DetectedIssue.identified[x]" (fhir-spec (string->symbol "DetectedIssue.identified[x]") "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue.identified[x]" 'element))
(register-element! "DetectedIssue.identified[x]" (fhir-spec (string->symbol "DetectedIssue.identified[x]") "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue.identified[x]" 'element))

(register-type! 'DetectedIssueEvidence (fhir-spec 'DetectedIssueEvidence "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue.evidence" 'type)
  #:schema (type-schema 'DetectedIssueEvidence #f 'BackboneElement "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue.evidence"
             (list
    (schema-field 'code 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue.evidence.code" #f)
    (schema-field 'detail 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue.evidence.detail" #f)
             ) #f #f))
(register-element! "DetectedIssue.evidence.code" (fhir-spec (string->symbol "DetectedIssue.evidence.code") "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue.evidence.code" 'element))
(register-element! "DetectedIssue.evidence.detail" (fhir-spec (string->symbol "DetectedIssue.evidence.detail") "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue.evidence.detail" 'element))

(register-type! 'DetectedIssueMitigation (fhir-spec 'DetectedIssueMitigation "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue.mitigation" 'type)
  #:schema (type-schema 'DetectedIssueMitigation #f 'BackboneElement "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue.mitigation"
             (list
    (schema-field 'action 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue.mitigation.action" #f)
    (schema-field 'date 0 1 (vector 'prim "dateTime") #f "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue.mitigation.date" #f)
    (schema-field 'author 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue.mitigation.author" #f)
    (schema-field 'note 0 '* (vector 'type 'Annotation) #f "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue.mitigation.note" #f)
             ) #f #f))
(register-element! "DetectedIssue.mitigation.action" (fhir-spec (string->symbol "DetectedIssue.mitigation.action") "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue.mitigation.action" 'element))
(register-element! "DetectedIssue.mitigation.date" (fhir-spec (string->symbol "DetectedIssue.mitigation.date") "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue.mitigation.date" 'element))
(register-element! "DetectedIssue.mitigation.author" (fhir-spec (string->symbol "DetectedIssue.mitigation.author") "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue.mitigation.author" 'element))
(register-element! "DetectedIssue.mitigation.note" (fhir-spec (string->symbol "DetectedIssue.mitigation.note") "https://hl7.org/fhir/R5/detectedissue.html#DetectedIssue.mitigation.note" 'element))

