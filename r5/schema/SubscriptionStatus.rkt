#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'SubscriptionStatus (fhir-spec 'SubscriptionStatus "https://hl7.org/fhir/R5/subscriptionstatus.html#SubscriptionStatus" 'type)
  #:schema (type-schema 'SubscriptionStatus #f 'DomainResource "https://hl7.org/fhir/R5/subscriptionstatus.html#SubscriptionStatus"
             (list
    (schema-field 'status 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/subscriptionstatus.html#SubscriptionStatus.status" #f)
    (schema-field 'type 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/subscriptionstatus.html#SubscriptionStatus.type" #f)
    (schema-field 'eventsSinceSubscriptionStart 0 1 (vector 'prim "integer64") #f "https://hl7.org/fhir/R5/subscriptionstatus.html#SubscriptionStatus.eventsSinceSubscriptionStart" #f)
    (schema-field 'notificationEvent 0 '* (vector 'type 'SubscriptionStatusNotificationEvent) #f "https://hl7.org/fhir/R5/subscriptionstatus.html#SubscriptionStatus.notificationEvent" #f)
    (schema-field 'subscription 1 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/subscriptionstatus.html#SubscriptionStatus.subscription" #f)
    (schema-field 'topic 0 1 (vector 'prim "canonical") #f "https://hl7.org/fhir/R5/subscriptionstatus.html#SubscriptionStatus.topic" #f)
    (schema-field 'error 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/subscriptionstatus.html#SubscriptionStatus.error" #f)
             ) #f #f))
(register-element! "SubscriptionStatus.status" (fhir-spec (string->symbol "SubscriptionStatus.status") "https://hl7.org/fhir/R5/subscriptionstatus.html#SubscriptionStatus.status" 'element))
(register-element! "SubscriptionStatus.type" (fhir-spec (string->symbol "SubscriptionStatus.type") "https://hl7.org/fhir/R5/subscriptionstatus.html#SubscriptionStatus.type" 'element))
(register-element! "SubscriptionStatus.eventsSinceSubscriptionStart" (fhir-spec (string->symbol "SubscriptionStatus.eventsSinceSubscriptionStart") "https://hl7.org/fhir/R5/subscriptionstatus.html#SubscriptionStatus.eventsSinceSubscriptionStart" 'element))
(register-element! "SubscriptionStatus.notificationEvent" (fhir-spec (string->symbol "SubscriptionStatus.notificationEvent") "https://hl7.org/fhir/R5/subscriptionstatus.html#SubscriptionStatus.notificationEvent" 'element))
(register-element! "SubscriptionStatus.subscription" (fhir-spec (string->symbol "SubscriptionStatus.subscription") "https://hl7.org/fhir/R5/subscriptionstatus.html#SubscriptionStatus.subscription" 'element))
(register-element! "SubscriptionStatus.topic" (fhir-spec (string->symbol "SubscriptionStatus.topic") "https://hl7.org/fhir/R5/subscriptionstatus.html#SubscriptionStatus.topic" 'element))
(register-element! "SubscriptionStatus.error" (fhir-spec (string->symbol "SubscriptionStatus.error") "https://hl7.org/fhir/R5/subscriptionstatus.html#SubscriptionStatus.error" 'element))

(register-type! 'SubscriptionStatusNotificationEvent (fhir-spec 'SubscriptionStatusNotificationEvent "https://hl7.org/fhir/R5/subscriptionstatus.html#SubscriptionStatus.notificationEvent" 'type)
  #:schema (type-schema 'SubscriptionStatusNotificationEvent #f 'BackboneElement "https://hl7.org/fhir/R5/subscriptionstatus.html#SubscriptionStatus.notificationEvent"
             (list
    (schema-field 'eventNumber 1 1 (vector 'prim "integer64") #f "https://hl7.org/fhir/R5/subscriptionstatus.html#SubscriptionStatus.notificationEvent.eventNumber" #f)
    (schema-field 'timestamp 0 1 (vector 'prim "instant") #f "https://hl7.org/fhir/R5/subscriptionstatus.html#SubscriptionStatus.notificationEvent.timestamp" #f)
    (schema-field 'focus 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/subscriptionstatus.html#SubscriptionStatus.notificationEvent.focus" #f)
    (schema-field 'additionalContext 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/subscriptionstatus.html#SubscriptionStatus.notificationEvent.additionalContext" #f)
             ) #f #f))
(register-element! "SubscriptionStatus.notificationEvent.eventNumber" (fhir-spec (string->symbol "SubscriptionStatus.notificationEvent.eventNumber") "https://hl7.org/fhir/R5/subscriptionstatus.html#SubscriptionStatus.notificationEvent.eventNumber" 'element))
(register-element! "SubscriptionStatus.notificationEvent.timestamp" (fhir-spec (string->symbol "SubscriptionStatus.notificationEvent.timestamp") "https://hl7.org/fhir/R5/subscriptionstatus.html#SubscriptionStatus.notificationEvent.timestamp" 'element))
(register-element! "SubscriptionStatus.notificationEvent.focus" (fhir-spec (string->symbol "SubscriptionStatus.notificationEvent.focus") "https://hl7.org/fhir/R5/subscriptionstatus.html#SubscriptionStatus.notificationEvent.focus" 'element))
(register-element! "SubscriptionStatus.notificationEvent.additionalContext" (fhir-spec (string->symbol "SubscriptionStatus.notificationEvent.additionalContext") "https://hl7.org/fhir/R5/subscriptionstatus.html#SubscriptionStatus.notificationEvent.additionalContext" 'element))

