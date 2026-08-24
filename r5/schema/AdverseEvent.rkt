#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'AdverseEvent (fhir-spec 'AdverseEvent "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent" 'type)
  #:schema (type-schema 'AdverseEvent #f 'DomainResource "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.identifier" #f)
    (schema-field 'status 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.status" #f)
    (schema-field 'actuality 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.actuality" #f)
    (schema-field 'category 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.category" #f)
    (schema-field 'code 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.code" #f)
    (schema-field 'subject 1 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.subject" #f)
    (schema-field 'encounter 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.encounter" #f)
    (schema-field 'detected 0 1 (vector 'prim "dateTime") #f "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.detected" #f)
    (schema-field 'recordedDate 0 1 (vector 'prim "dateTime") #f "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.recordedDate" #f)
    (schema-field 'resultingEffect 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.resultingEffect" #f)
    (schema-field 'location 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.location" #f)
    (schema-field 'seriousness 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.seriousness" #f)
    (schema-field 'outcome 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.outcome" #f)
    (schema-field 'recorder 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.recorder" #f)
    (schema-field 'participant 0 '* (vector 'type 'AdverseEventParticipant) #f "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.participant" #f)
    (schema-field 'study 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.study" #f)
    (schema-field 'expectedInResearchStudy 0 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.expectedInResearchStudy" #f)
    (schema-field 'suspectEntity 0 '* (vector 'type 'AdverseEventSuspectEntity) #f "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.suspectEntity" #f)
    (schema-field 'contributingFactor 0 '* (vector 'type 'AdverseEventContributingFactor) #f "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.contributingFactor" #f)
    (schema-field 'preventiveAction 0 '* (vector 'type 'AdverseEventPreventiveAction) #f "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.preventiveAction" #f)
    (schema-field 'mitigatingAction 0 '* (vector 'type 'AdverseEventMitigatingAction) #f "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.mitigatingAction" #f)
    (schema-field 'supportingInfo 0 '* (vector 'type 'AdverseEventSupportingInfo) #f "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.supportingInfo" #f)
    (schema-field 'note 0 '* (vector 'type 'Annotation) #f "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.note" #f)
    (schema-field 'occurrenceDateTime 0 1 (vector 'prim "dateTime") 'occurrence "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.occurrence[x]" #f)
    (schema-field 'occurrencePeriod 0 1 (vector 'type 'Period) 'occurrence "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.occurrence[x]" #f)
    (schema-field 'occurrenceTiming 0 1 (vector 'type 'Timing) 'occurrence "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.occurrence[x]" #f)
             ) #f #f))
(register-element! "AdverseEvent.identifier" (fhir-spec (string->symbol "AdverseEvent.identifier") "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.identifier" 'element))
(register-element! "AdverseEvent.status" (fhir-spec (string->symbol "AdverseEvent.status") "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.status" 'element))
(register-element! "AdverseEvent.actuality" (fhir-spec (string->symbol "AdverseEvent.actuality") "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.actuality" 'element))
(register-element! "AdverseEvent.category" (fhir-spec (string->symbol "AdverseEvent.category") "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.category" 'element))
(register-element! "AdverseEvent.code" (fhir-spec (string->symbol "AdverseEvent.code") "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.code" 'element))
(register-element! "AdverseEvent.subject" (fhir-spec (string->symbol "AdverseEvent.subject") "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.subject" 'element))
(register-element! "AdverseEvent.encounter" (fhir-spec (string->symbol "AdverseEvent.encounter") "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.encounter" 'element))
(register-element! "AdverseEvent.detected" (fhir-spec (string->symbol "AdverseEvent.detected") "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.detected" 'element))
(register-element! "AdverseEvent.recordedDate" (fhir-spec (string->symbol "AdverseEvent.recordedDate") "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.recordedDate" 'element))
(register-element! "AdverseEvent.resultingEffect" (fhir-spec (string->symbol "AdverseEvent.resultingEffect") "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.resultingEffect" 'element))
(register-element! "AdverseEvent.location" (fhir-spec (string->symbol "AdverseEvent.location") "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.location" 'element))
(register-element! "AdverseEvent.seriousness" (fhir-spec (string->symbol "AdverseEvent.seriousness") "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.seriousness" 'element))
(register-element! "AdverseEvent.outcome" (fhir-spec (string->symbol "AdverseEvent.outcome") "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.outcome" 'element))
(register-element! "AdverseEvent.recorder" (fhir-spec (string->symbol "AdverseEvent.recorder") "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.recorder" 'element))
(register-element! "AdverseEvent.participant" (fhir-spec (string->symbol "AdverseEvent.participant") "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.participant" 'element))
(register-element! "AdverseEvent.study" (fhir-spec (string->symbol "AdverseEvent.study") "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.study" 'element))
(register-element! "AdverseEvent.expectedInResearchStudy" (fhir-spec (string->symbol "AdverseEvent.expectedInResearchStudy") "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.expectedInResearchStudy" 'element))
(register-element! "AdverseEvent.suspectEntity" (fhir-spec (string->symbol "AdverseEvent.suspectEntity") "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.suspectEntity" 'element))
(register-element! "AdverseEvent.contributingFactor" (fhir-spec (string->symbol "AdverseEvent.contributingFactor") "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.contributingFactor" 'element))
(register-element! "AdverseEvent.preventiveAction" (fhir-spec (string->symbol "AdverseEvent.preventiveAction") "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.preventiveAction" 'element))
(register-element! "AdverseEvent.mitigatingAction" (fhir-spec (string->symbol "AdverseEvent.mitigatingAction") "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.mitigatingAction" 'element))
(register-element! "AdverseEvent.supportingInfo" (fhir-spec (string->symbol "AdverseEvent.supportingInfo") "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.supportingInfo" 'element))
(register-element! "AdverseEvent.note" (fhir-spec (string->symbol "AdverseEvent.note") "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.note" 'element))
(register-element! "AdverseEvent.occurrence[x]" (fhir-spec (string->symbol "AdverseEvent.occurrence[x]") "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.occurrence[x]" 'element))
(register-element! "AdverseEvent.occurrence[x]" (fhir-spec (string->symbol "AdverseEvent.occurrence[x]") "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.occurrence[x]" 'element))
(register-element! "AdverseEvent.occurrence[x]" (fhir-spec (string->symbol "AdverseEvent.occurrence[x]") "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.occurrence[x]" 'element))

(register-type! 'AdverseEventParticipant (fhir-spec 'AdverseEventParticipant "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.participant" 'type)
  #:schema (type-schema 'AdverseEventParticipant #f 'BackboneElement "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.participant"
             (list
    (schema-field 'function 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.participant.function" #f)
    (schema-field 'actor 1 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.participant.actor" #f)
             ) #f #f))
(register-element! "AdverseEvent.participant.function" (fhir-spec (string->symbol "AdverseEvent.participant.function") "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.participant.function" 'element))
(register-element! "AdverseEvent.participant.actor" (fhir-spec (string->symbol "AdverseEvent.participant.actor") "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.participant.actor" 'element))

(register-type! 'AdverseEventSuspectEntity (fhir-spec 'AdverseEventSuspectEntity "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.suspectEntity" 'type)
  #:schema (type-schema 'AdverseEventSuspectEntity #f 'BackboneElement "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.suspectEntity"
             (list
    (schema-field 'causality 0 1 (vector 'type 'AdverseEventSuspectEntityCausality) #f "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.suspectEntity.causality" #f)
    (schema-field 'instanceCodeableConcept 0 1 (vector 'type 'CodeableConcept) 'instance "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.suspectEntity.instance[x]" #f)
    (schema-field 'instanceReference 0 1 (vector 'type 'Reference) 'instance "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.suspectEntity.instance[x]" #f)
             ) #f #f))
(register-element! "AdverseEvent.suspectEntity.causality" (fhir-spec (string->symbol "AdverseEvent.suspectEntity.causality") "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.suspectEntity.causality" 'element))
(register-element! "AdverseEvent.suspectEntity.instance[x]" (fhir-spec (string->symbol "AdverseEvent.suspectEntity.instance[x]") "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.suspectEntity.instance[x]" 'element))
(register-element! "AdverseEvent.suspectEntity.instance[x]" (fhir-spec (string->symbol "AdverseEvent.suspectEntity.instance[x]") "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.suspectEntity.instance[x]" 'element))

(register-type! 'AdverseEventSuspectEntityCausality (fhir-spec 'AdverseEventSuspectEntityCausality "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.suspectEntity.causality" 'type)
  #:schema (type-schema 'AdverseEventSuspectEntityCausality #f 'BackboneElement "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.suspectEntity.causality"
             (list
    (schema-field 'assessmentMethod 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.suspectEntity.causality.assessmentMethod" #f)
    (schema-field 'entityRelatedness 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.suspectEntity.causality.entityRelatedness" #f)
    (schema-field 'author 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.suspectEntity.causality.author" #f)
             ) #f #f))
(register-element! "AdverseEvent.suspectEntity.causality.assessmentMethod" (fhir-spec (string->symbol "AdverseEvent.suspectEntity.causality.assessmentMethod") "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.suspectEntity.causality.assessmentMethod" 'element))
(register-element! "AdverseEvent.suspectEntity.causality.entityRelatedness" (fhir-spec (string->symbol "AdverseEvent.suspectEntity.causality.entityRelatedness") "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.suspectEntity.causality.entityRelatedness" 'element))
(register-element! "AdverseEvent.suspectEntity.causality.author" (fhir-spec (string->symbol "AdverseEvent.suspectEntity.causality.author") "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.suspectEntity.causality.author" 'element))

(register-type! 'AdverseEventContributingFactor (fhir-spec 'AdverseEventContributingFactor "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.contributingFactor" 'type)
  #:schema (type-schema 'AdverseEventContributingFactor #f 'BackboneElement "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.contributingFactor"
             (list
    (schema-field 'itemReference 0 1 (vector 'type 'Reference) 'item "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.contributingFactor.item[x]" #f)
    (schema-field 'itemCodeableConcept 0 1 (vector 'type 'CodeableConcept) 'item "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.contributingFactor.item[x]" #f)
             ) #f #f))
(register-element! "AdverseEvent.contributingFactor.item[x]" (fhir-spec (string->symbol "AdverseEvent.contributingFactor.item[x]") "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.contributingFactor.item[x]" 'element))
(register-element! "AdverseEvent.contributingFactor.item[x]" (fhir-spec (string->symbol "AdverseEvent.contributingFactor.item[x]") "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.contributingFactor.item[x]" 'element))

(register-type! 'AdverseEventPreventiveAction (fhir-spec 'AdverseEventPreventiveAction "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.preventiveAction" 'type)
  #:schema (type-schema 'AdverseEventPreventiveAction #f 'BackboneElement "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.preventiveAction"
             (list
    (schema-field 'itemReference 0 1 (vector 'type 'Reference) 'item "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.preventiveAction.item[x]" #f)
    (schema-field 'itemCodeableConcept 0 1 (vector 'type 'CodeableConcept) 'item "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.preventiveAction.item[x]" #f)
             ) #f #f))
(register-element! "AdverseEvent.preventiveAction.item[x]" (fhir-spec (string->symbol "AdverseEvent.preventiveAction.item[x]") "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.preventiveAction.item[x]" 'element))
(register-element! "AdverseEvent.preventiveAction.item[x]" (fhir-spec (string->symbol "AdverseEvent.preventiveAction.item[x]") "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.preventiveAction.item[x]" 'element))

(register-type! 'AdverseEventMitigatingAction (fhir-spec 'AdverseEventMitigatingAction "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.mitigatingAction" 'type)
  #:schema (type-schema 'AdverseEventMitigatingAction #f 'BackboneElement "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.mitigatingAction"
             (list
    (schema-field 'itemReference 0 1 (vector 'type 'Reference) 'item "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.mitigatingAction.item[x]" #f)
    (schema-field 'itemCodeableConcept 0 1 (vector 'type 'CodeableConcept) 'item "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.mitigatingAction.item[x]" #f)
             ) #f #f))
(register-element! "AdverseEvent.mitigatingAction.item[x]" (fhir-spec (string->symbol "AdverseEvent.mitigatingAction.item[x]") "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.mitigatingAction.item[x]" 'element))
(register-element! "AdverseEvent.mitigatingAction.item[x]" (fhir-spec (string->symbol "AdverseEvent.mitigatingAction.item[x]") "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.mitigatingAction.item[x]" 'element))

(register-type! 'AdverseEventSupportingInfo (fhir-spec 'AdverseEventSupportingInfo "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.supportingInfo" 'type)
  #:schema (type-schema 'AdverseEventSupportingInfo #f 'BackboneElement "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.supportingInfo"
             (list
    (schema-field 'itemReference 0 1 (vector 'type 'Reference) 'item "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.supportingInfo.item[x]" #f)
    (schema-field 'itemCodeableConcept 0 1 (vector 'type 'CodeableConcept) 'item "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.supportingInfo.item[x]" #f)
             ) #f #f))
(register-element! "AdverseEvent.supportingInfo.item[x]" (fhir-spec (string->symbol "AdverseEvent.supportingInfo.item[x]") "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.supportingInfo.item[x]" 'element))
(register-element! "AdverseEvent.supportingInfo.item[x]" (fhir-spec (string->symbol "AdverseEvent.supportingInfo.item[x]") "https://hl7.org/fhir/R5/adverseevent.html#AdverseEvent.supportingInfo.item[x]" 'element))

