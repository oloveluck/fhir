#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Permission (fhir-spec 'Permission "https://hl7.org/fhir/R5/permission.html#Permission" 'type)
  #:schema (type-schema 'Permission #f 'DomainResource "https://hl7.org/fhir/R5/permission.html#Permission"
             (list
    (schema-field 'status 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/permission.html#Permission.status" #f)
    (schema-field 'asserter 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/permission.html#Permission.asserter" #f)
    (schema-field 'date 0 '* (vector 'prim "dateTime") #f "https://hl7.org/fhir/R5/permission.html#Permission.date" #f)
    (schema-field 'validity 0 1 (vector 'type 'Period) #f "https://hl7.org/fhir/R5/permission.html#Permission.validity" #f)
    (schema-field 'justification 0 1 (vector 'type 'PermissionJustification) #f "https://hl7.org/fhir/R5/permission.html#Permission.justification" #f)
    (schema-field 'combining 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/permission.html#Permission.combining" #f)
    (schema-field 'rule 0 '* (vector 'type 'PermissionRule) #f "https://hl7.org/fhir/R5/permission.html#Permission.rule" #f)
             ) #f #f))
(register-element! "Permission.status" (fhir-spec (string->symbol "Permission.status") "https://hl7.org/fhir/R5/permission.html#Permission.status" 'element))
(register-element! "Permission.asserter" (fhir-spec (string->symbol "Permission.asserter") "https://hl7.org/fhir/R5/permission.html#Permission.asserter" 'element))
(register-element! "Permission.date" (fhir-spec (string->symbol "Permission.date") "https://hl7.org/fhir/R5/permission.html#Permission.date" 'element))
(register-element! "Permission.validity" (fhir-spec (string->symbol "Permission.validity") "https://hl7.org/fhir/R5/permission.html#Permission.validity" 'element))
(register-element! "Permission.justification" (fhir-spec (string->symbol "Permission.justification") "https://hl7.org/fhir/R5/permission.html#Permission.justification" 'element))
(register-element! "Permission.combining" (fhir-spec (string->symbol "Permission.combining") "https://hl7.org/fhir/R5/permission.html#Permission.combining" 'element))
(register-element! "Permission.rule" (fhir-spec (string->symbol "Permission.rule") "https://hl7.org/fhir/R5/permission.html#Permission.rule" 'element))

(register-type! 'PermissionJustification (fhir-spec 'PermissionJustification "https://hl7.org/fhir/R5/permission.html#Permission.justification" 'type)
  #:schema (type-schema 'PermissionJustification #f 'BackboneElement "https://hl7.org/fhir/R5/permission.html#Permission.justification"
             (list
    (schema-field 'basis 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/permission.html#Permission.justification.basis" #f)
    (schema-field 'evidence 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/permission.html#Permission.justification.evidence" #f)
             ) #f #f))
(register-element! "Permission.justification.basis" (fhir-spec (string->symbol "Permission.justification.basis") "https://hl7.org/fhir/R5/permission.html#Permission.justification.basis" 'element))
(register-element! "Permission.justification.evidence" (fhir-spec (string->symbol "Permission.justification.evidence") "https://hl7.org/fhir/R5/permission.html#Permission.justification.evidence" 'element))

(register-type! 'PermissionRule (fhir-spec 'PermissionRule "https://hl7.org/fhir/R5/permission.html#Permission.rule" 'type)
  #:schema (type-schema 'PermissionRule #f 'BackboneElement "https://hl7.org/fhir/R5/permission.html#Permission.rule"
             (list
    (schema-field 'type 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/permission.html#Permission.rule.type" #f)
    (schema-field 'data 0 '* (vector 'type 'PermissionRuleData) #f "https://hl7.org/fhir/R5/permission.html#Permission.rule.data" #f)
    (schema-field 'activity 0 '* (vector 'type 'PermissionRuleActivity) #f "https://hl7.org/fhir/R5/permission.html#Permission.rule.activity" #f)
    (schema-field 'limit 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/permission.html#Permission.rule.limit" #f)
             ) #f #f))
(register-element! "Permission.rule.type" (fhir-spec (string->symbol "Permission.rule.type") "https://hl7.org/fhir/R5/permission.html#Permission.rule.type" 'element))
(register-element! "Permission.rule.data" (fhir-spec (string->symbol "Permission.rule.data") "https://hl7.org/fhir/R5/permission.html#Permission.rule.data" 'element))
(register-element! "Permission.rule.activity" (fhir-spec (string->symbol "Permission.rule.activity") "https://hl7.org/fhir/R5/permission.html#Permission.rule.activity" 'element))
(register-element! "Permission.rule.limit" (fhir-spec (string->symbol "Permission.rule.limit") "https://hl7.org/fhir/R5/permission.html#Permission.rule.limit" 'element))

(register-type! 'PermissionRuleData (fhir-spec 'PermissionRuleData "https://hl7.org/fhir/R5/permission.html#Permission.rule.data" 'type)
  #:schema (type-schema 'PermissionRuleData #f 'BackboneElement "https://hl7.org/fhir/R5/permission.html#Permission.rule.data"
             (list
    (schema-field 'resource 0 '* (vector 'type 'PermissionRuleDataResource) #f "https://hl7.org/fhir/R5/permission.html#Permission.rule.data.resource" #f)
    (schema-field 'security 0 '* (vector 'type 'Coding) #f "https://hl7.org/fhir/R5/permission.html#Permission.rule.data.security" #f)
    (schema-field 'period 0 '* (vector 'type 'Period) #f "https://hl7.org/fhir/R5/permission.html#Permission.rule.data.period" #f)
    (schema-field 'expression 0 1 (vector 'type 'Expression) #f "https://hl7.org/fhir/R5/permission.html#Permission.rule.data.expression" #f)
             ) #f #f))
(register-element! "Permission.rule.data.resource" (fhir-spec (string->symbol "Permission.rule.data.resource") "https://hl7.org/fhir/R5/permission.html#Permission.rule.data.resource" 'element))
(register-element! "Permission.rule.data.security" (fhir-spec (string->symbol "Permission.rule.data.security") "https://hl7.org/fhir/R5/permission.html#Permission.rule.data.security" 'element))
(register-element! "Permission.rule.data.period" (fhir-spec (string->symbol "Permission.rule.data.period") "https://hl7.org/fhir/R5/permission.html#Permission.rule.data.period" 'element))
(register-element! "Permission.rule.data.expression" (fhir-spec (string->symbol "Permission.rule.data.expression") "https://hl7.org/fhir/R5/permission.html#Permission.rule.data.expression" 'element))

(register-type! 'PermissionRuleDataResource (fhir-spec 'PermissionRuleDataResource "https://hl7.org/fhir/R5/permission.html#Permission.rule.data.resource" 'type)
  #:schema (type-schema 'PermissionRuleDataResource #f 'BackboneElement "https://hl7.org/fhir/R5/permission.html#Permission.rule.data.resource"
             (list
    (schema-field 'meaning 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/permission.html#Permission.rule.data.resource.meaning" #f)
    (schema-field 'reference 1 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/permission.html#Permission.rule.data.resource.reference" #f)
             ) #f #f))
(register-element! "Permission.rule.data.resource.meaning" (fhir-spec (string->symbol "Permission.rule.data.resource.meaning") "https://hl7.org/fhir/R5/permission.html#Permission.rule.data.resource.meaning" 'element))
(register-element! "Permission.rule.data.resource.reference" (fhir-spec (string->symbol "Permission.rule.data.resource.reference") "https://hl7.org/fhir/R5/permission.html#Permission.rule.data.resource.reference" 'element))

(register-type! 'PermissionRuleActivity (fhir-spec 'PermissionRuleActivity "https://hl7.org/fhir/R5/permission.html#Permission.rule.activity" 'type)
  #:schema (type-schema 'PermissionRuleActivity #f 'BackboneElement "https://hl7.org/fhir/R5/permission.html#Permission.rule.activity"
             (list
    (schema-field 'actor 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/permission.html#Permission.rule.activity.actor" #f)
    (schema-field 'action 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/permission.html#Permission.rule.activity.action" #f)
    (schema-field 'purpose 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/permission.html#Permission.rule.activity.purpose" #f)
             ) #f #f))
(register-element! "Permission.rule.activity.actor" (fhir-spec (string->symbol "Permission.rule.activity.actor") "https://hl7.org/fhir/R5/permission.html#Permission.rule.activity.actor" 'element))
(register-element! "Permission.rule.activity.action" (fhir-spec (string->symbol "Permission.rule.activity.action") "https://hl7.org/fhir/R5/permission.html#Permission.rule.activity.action" 'element))
(register-element! "Permission.rule.activity.purpose" (fhir-spec (string->symbol "Permission.rule.activity.purpose") "https://hl7.org/fhir/R5/permission.html#Permission.rule.activity.purpose" 'element))

