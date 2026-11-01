#lang racket/base
;;; GENERATED from hl7.fhir.uv.omop#2.0.0-ballot — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'episode_event (fhir-spec 'episode_event "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#episode_event" 'type)
  #:schema (type-schema 'episode_event #f 'Base "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#episode_event"
             (list
    (schema-field 'episode_id 1 1 (vector 'prim "integer") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#episode_event.episode_id" #f)
    (schema-field 'event_id 1 1 (vector 'prim "code") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#episode_event.event_id" #f)
    (schema-field 'episode_event_field_concept_id 1 1 (vector 'prim "code") #f "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#episode_event.episode_event_field_concept_id" #f)
             ) #f #f))
(register-element! "episode_event.episode_id" (fhir-spec (string->symbol "episode_event.episode_id") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#episode_event.episode_id" 'element))
(register-element! "episode_event.event_id" (fhir-spec (string->symbol "episode_event.event_id") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#episode_event.event_id" 'element))
(register-element! "episode_event.episode_event_field_concept_id" (fhir-spec (string->symbol "episode_event.episode_event_field_concept_id") "https://build.fhir.org/ig/HL7/fhir-omop-ig/datatypes.html#episode_event.episode_event_field_concept_id" 'element))

