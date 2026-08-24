#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'SubscriptionStatus (fhir-spec 'SubscriptionStatus "https://build.fhir.org/subscriptionstatus.html#SubscriptionStatus" 'type)
  #:schema (type-schema 'SubscriptionStatus #f 'DomainResource "https://build.fhir.org/subscriptionstatus.html#SubscriptionStatus"
             (list
    (schema-field 'status 0 1 (vector 'prim "code") #f "https://build.fhir.org/subscriptionstatus.html#SubscriptionStatus.status" #f)
    (schema-field 'type 1 1 (vector 'prim "code") #f "https://build.fhir.org/subscriptionstatus.html#SubscriptionStatus.type" #f)
    (schema-field 'eventsSinceSubscriptionStart 0 1 (vector 'prim "integer64") #f "https://build.fhir.org/subscriptionstatus.html#SubscriptionStatus.eventsSinceSubscriptionStart" #f)
    (schema-field 'notificationEvent 0 '* (vector 'type 'SubscriptionStatusNotificationEvent) #f "https://build.fhir.org/subscriptionstatus.html#SubscriptionStatus.notificationEvent" #f)
    (schema-field 'subscription 1 1 (vector 'type 'Reference) #f "https://build.fhir.org/subscriptionstatus.html#SubscriptionStatus.subscription" #f)
    (schema-field 'topic 0 1 (vector 'prim "canonical") #f "https://build.fhir.org/subscriptionstatus.html#SubscriptionStatus.topic" #f)
    (schema-field 'error 0 '* (vector 'type 'CodeableConcept) #f "https://build.fhir.org/subscriptionstatus.html#SubscriptionStatus.error" #f)
             ) #f #f))
(register-element! "SubscriptionStatus.status" (fhir-spec (string->symbol "SubscriptionStatus.status") "https://build.fhir.org/subscriptionstatus.html#SubscriptionStatus.status" 'element))
(register-element! "SubscriptionStatus.type" (fhir-spec (string->symbol "SubscriptionStatus.type") "https://build.fhir.org/subscriptionstatus.html#SubscriptionStatus.type" 'element))
(register-element! "SubscriptionStatus.eventsSinceSubscriptionStart" (fhir-spec (string->symbol "SubscriptionStatus.eventsSinceSubscriptionStart") "https://build.fhir.org/subscriptionstatus.html#SubscriptionStatus.eventsSinceSubscriptionStart" 'element))
(register-element! "SubscriptionStatus.notificationEvent" (fhir-spec (string->symbol "SubscriptionStatus.notificationEvent") "https://build.fhir.org/subscriptionstatus.html#SubscriptionStatus.notificationEvent" 'element))
(register-element! "SubscriptionStatus.subscription" (fhir-spec (string->symbol "SubscriptionStatus.subscription") "https://build.fhir.org/subscriptionstatus.html#SubscriptionStatus.subscription" 'element))
(register-element! "SubscriptionStatus.topic" (fhir-spec (string->symbol "SubscriptionStatus.topic") "https://build.fhir.org/subscriptionstatus.html#SubscriptionStatus.topic" 'element))
(register-element! "SubscriptionStatus.error" (fhir-spec (string->symbol "SubscriptionStatus.error") "https://build.fhir.org/subscriptionstatus.html#SubscriptionStatus.error" 'element))

(register-type! 'SubscriptionStatusNotificationEvent (fhir-spec 'SubscriptionStatusNotificationEvent "https://build.fhir.org/subscriptionstatus.html#SubscriptionStatus.notificationEvent" 'type)
  #:schema (type-schema 'SubscriptionStatusNotificationEvent #f 'BackboneElement "https://build.fhir.org/subscriptionstatus.html#SubscriptionStatus.notificationEvent"
             (list
    (schema-field 'eventNumber 1 1 (vector 'prim "integer64") #f "https://build.fhir.org/subscriptionstatus.html#SubscriptionStatus.notificationEvent.eventNumber" #f)
    (schema-field 'triggerEvent 0 '* (vector 'type 'CodeableConcept) #f "https://build.fhir.org/subscriptionstatus.html#SubscriptionStatus.notificationEvent.triggerEvent" #f)
    (schema-field 'timestamp 0 1 (vector 'prim "instant") #f "https://build.fhir.org/subscriptionstatus.html#SubscriptionStatus.notificationEvent.timestamp" #f)
    (schema-field 'focus 0 1 (vector 'type 'Reference) #f "https://build.fhir.org/subscriptionstatus.html#SubscriptionStatus.notificationEvent.focus" #f)
    (schema-field 'additionalContext 0 '* (vector 'type 'Reference) #f "https://build.fhir.org/subscriptionstatus.html#SubscriptionStatus.notificationEvent.additionalContext" #f)
    (schema-field 'relatedQuery 0 '* (vector 'type 'SubscriptionStatusNotificationEventRelatedQuery) #f "https://build.fhir.org/subscriptionstatus.html#SubscriptionStatus.notificationEvent.relatedQuery" #f)
    (schema-field 'authorizationHint 0 '* (vector 'type 'SubscriptionStatusNotificationEventAuthorizationHint) #f "https://build.fhir.org/subscriptionstatus.html#SubscriptionStatus.notificationEvent.authorizationHint" #f)
             ) #f #f))
(register-element! "SubscriptionStatus.notificationEvent.eventNumber" (fhir-spec (string->symbol "SubscriptionStatus.notificationEvent.eventNumber") "https://build.fhir.org/subscriptionstatus.html#SubscriptionStatus.notificationEvent.eventNumber" 'element))
(register-element! "SubscriptionStatus.notificationEvent.triggerEvent" (fhir-spec (string->symbol "SubscriptionStatus.notificationEvent.triggerEvent") "https://build.fhir.org/subscriptionstatus.html#SubscriptionStatus.notificationEvent.triggerEvent" 'element))
(register-element! "SubscriptionStatus.notificationEvent.timestamp" (fhir-spec (string->symbol "SubscriptionStatus.notificationEvent.timestamp") "https://build.fhir.org/subscriptionstatus.html#SubscriptionStatus.notificationEvent.timestamp" 'element))
(register-element! "SubscriptionStatus.notificationEvent.focus" (fhir-spec (string->symbol "SubscriptionStatus.notificationEvent.focus") "https://build.fhir.org/subscriptionstatus.html#SubscriptionStatus.notificationEvent.focus" 'element))
(register-element! "SubscriptionStatus.notificationEvent.additionalContext" (fhir-spec (string->symbol "SubscriptionStatus.notificationEvent.additionalContext") "https://build.fhir.org/subscriptionstatus.html#SubscriptionStatus.notificationEvent.additionalContext" 'element))
(register-element! "SubscriptionStatus.notificationEvent.relatedQuery" (fhir-spec (string->symbol "SubscriptionStatus.notificationEvent.relatedQuery") "https://build.fhir.org/subscriptionstatus.html#SubscriptionStatus.notificationEvent.relatedQuery" 'element))
(register-element! "SubscriptionStatus.notificationEvent.authorizationHint" (fhir-spec (string->symbol "SubscriptionStatus.notificationEvent.authorizationHint") "https://build.fhir.org/subscriptionstatus.html#SubscriptionStatus.notificationEvent.authorizationHint" 'element))

(register-type! 'SubscriptionStatusNotificationEventRelatedQuery (fhir-spec 'SubscriptionStatusNotificationEventRelatedQuery "https://build.fhir.org/subscriptionstatus.html#SubscriptionStatus.notificationEvent.relatedQuery" 'type)
  #:schema (type-schema 'SubscriptionStatusNotificationEventRelatedQuery #f 'BackboneElement "https://build.fhir.org/subscriptionstatus.html#SubscriptionStatus.notificationEvent.relatedQuery"
             (list
    (schema-field 'queryType 0 1 (vector 'type 'Coding) #f "https://build.fhir.org/subscriptionstatus.html#SubscriptionStatus.notificationEvent.relatedQuery.queryType" #f)
    (schema-field 'query 1 1 (vector 'prim "string") #f "https://build.fhir.org/subscriptionstatus.html#SubscriptionStatus.notificationEvent.relatedQuery.query" #f)
             ) #f #f))
(register-element! "SubscriptionStatus.notificationEvent.relatedQuery.queryType" (fhir-spec (string->symbol "SubscriptionStatus.notificationEvent.relatedQuery.queryType") "https://build.fhir.org/subscriptionstatus.html#SubscriptionStatus.notificationEvent.relatedQuery.queryType" 'element))
(register-element! "SubscriptionStatus.notificationEvent.relatedQuery.query" (fhir-spec (string->symbol "SubscriptionStatus.notificationEvent.relatedQuery.query") "https://build.fhir.org/subscriptionstatus.html#SubscriptionStatus.notificationEvent.relatedQuery.query" 'element))

(register-type! 'SubscriptionStatusNotificationEventAuthorizationHint (fhir-spec 'SubscriptionStatusNotificationEventAuthorizationHint "https://build.fhir.org/subscriptionstatus.html#SubscriptionStatus.notificationEvent.authorizationHint" 'type)
  #:schema (type-schema 'SubscriptionStatusNotificationEventAuthorizationHint #f 'BackboneElement "https://build.fhir.org/subscriptionstatus.html#SubscriptionStatus.notificationEvent.authorizationHint"
             (list
    (schema-field 'authorizationType 1 1 (vector 'type 'Coding) #f "https://build.fhir.org/subscriptionstatus.html#SubscriptionStatus.notificationEvent.authorizationHint.authorizationType" #f)
    (schema-field 'value 0 1 (vector 'prim "string") #f "https://build.fhir.org/subscriptionstatus.html#SubscriptionStatus.notificationEvent.authorizationHint.value" #f)
             ) #f #f))
(register-element! "SubscriptionStatus.notificationEvent.authorizationHint.authorizationType" (fhir-spec (string->symbol "SubscriptionStatus.notificationEvent.authorizationHint.authorizationType") "https://build.fhir.org/subscriptionstatus.html#SubscriptionStatus.notificationEvent.authorizationHint.authorizationType" 'element))
(register-element! "SubscriptionStatus.notificationEvent.authorizationHint.value" (fhir-spec (string->symbol "SubscriptionStatus.notificationEvent.authorizationHint.value") "https://build.fhir.org/subscriptionstatus.html#SubscriptionStatus.notificationEvent.authorizationHint.value" 'element))

