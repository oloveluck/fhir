#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Subscription (fhir-spec 'Subscription "https://hl7.org/fhir/R4/subscription.html#Subscription" 'type)
  #:schema (type-schema 'Subscription #f 'DomainResource "https://hl7.org/fhir/R4/subscription.html#Subscription"
             (list
    (schema-field 'status 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/subscription.html#Subscription.status" #f)
    (schema-field 'contact 0 '* (vector 'type 'ContactPoint) #f "https://hl7.org/fhir/R4/subscription.html#Subscription.contact" #f)
    (schema-field 'end 0 1 (vector 'prim "instant") #f "https://hl7.org/fhir/R4/subscription.html#Subscription.end" #f)
    (schema-field 'reason 1 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/subscription.html#Subscription.reason" #f)
    (schema-field 'criteria 1 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/subscription.html#Subscription.criteria" #f)
    (schema-field 'error 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/subscription.html#Subscription.error" #f)
    (schema-field 'channel 1 1 (vector 'type 'SubscriptionChannel) #f "https://hl7.org/fhir/R4/subscription.html#Subscription.channel" #f)
             ) #f #f))
(register-element! "Subscription.status" (fhir-spec (string->symbol "Subscription.status") "https://hl7.org/fhir/R4/subscription.html#Subscription.status" 'element))
(register-element! "Subscription.contact" (fhir-spec (string->symbol "Subscription.contact") "https://hl7.org/fhir/R4/subscription.html#Subscription.contact" 'element))
(register-element! "Subscription.end" (fhir-spec (string->symbol "Subscription.end") "https://hl7.org/fhir/R4/subscription.html#Subscription.end" 'element))
(register-element! "Subscription.reason" (fhir-spec (string->symbol "Subscription.reason") "https://hl7.org/fhir/R4/subscription.html#Subscription.reason" 'element))
(register-element! "Subscription.criteria" (fhir-spec (string->symbol "Subscription.criteria") "https://hl7.org/fhir/R4/subscription.html#Subscription.criteria" 'element))
(register-element! "Subscription.error" (fhir-spec (string->symbol "Subscription.error") "https://hl7.org/fhir/R4/subscription.html#Subscription.error" 'element))
(register-element! "Subscription.channel" (fhir-spec (string->symbol "Subscription.channel") "https://hl7.org/fhir/R4/subscription.html#Subscription.channel" 'element))

(register-type! 'SubscriptionChannel (fhir-spec 'SubscriptionChannel "https://hl7.org/fhir/R4/subscription.html#Subscription.channel" 'type)
  #:schema (type-schema 'SubscriptionChannel #f 'BackboneElement "https://hl7.org/fhir/R4/subscription.html#Subscription.channel"
             (list
    (schema-field 'type 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/subscription.html#Subscription.channel.type" #f)
    (schema-field 'endpoint 0 1 (vector 'prim "url") #f "https://hl7.org/fhir/R4/subscription.html#Subscription.channel.endpoint" #f)
    (schema-field 'payload 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/subscription.html#Subscription.channel.payload" #f)
    (schema-field 'header 0 '* (vector 'prim "string") #f "https://hl7.org/fhir/R4/subscription.html#Subscription.channel.header" #f)
             ) #f #f))
(register-element! "Subscription.channel.type" (fhir-spec (string->symbol "Subscription.channel.type") "https://hl7.org/fhir/R4/subscription.html#Subscription.channel.type" 'element))
(register-element! "Subscription.channel.endpoint" (fhir-spec (string->symbol "Subscription.channel.endpoint") "https://hl7.org/fhir/R4/subscription.html#Subscription.channel.endpoint" 'element))
(register-element! "Subscription.channel.payload" (fhir-spec (string->symbol "Subscription.channel.payload") "https://hl7.org/fhir/R4/subscription.html#Subscription.channel.payload" 'element))
(register-element! "Subscription.channel.header" (fhir-spec (string->symbol "Subscription.channel.header") "https://hl7.org/fhir/R4/subscription.html#Subscription.channel.header" 'element))

