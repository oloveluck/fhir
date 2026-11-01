#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Group (fhir-spec 'Group "https://hl7.org/fhir/R5/group.html#Group" 'type)
  #:schema (type-schema 'Group #f 'DomainResource "https://hl7.org/fhir/R5/group.html#Group"
             (list
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R5/group.html#Group.identifier" #f)
    (schema-field 'active 0 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R5/group.html#Group.active" #f)
    (schema-field 'type 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/group.html#Group.type" #f)
    (schema-field 'membership 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/group.html#Group.membership" #f)
    (schema-field 'code 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/group.html#Group.code" #f)
    (schema-field 'name 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/group.html#Group.name" #f)
    (schema-field 'description 0 1 (vector 'prim "markdown") #f "https://hl7.org/fhir/R5/group.html#Group.description" #f)
    (schema-field 'quantity 0 1 (vector 'prim "unsignedInt") #f "https://hl7.org/fhir/R5/group.html#Group.quantity" #f)
    (schema-field 'managingEntity 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/group.html#Group.managingEntity" #f)
    (schema-field 'characteristic 0 '* (vector 'type 'GroupCharacteristic) #f "https://hl7.org/fhir/R5/group.html#Group.characteristic" #f)
    (schema-field 'member 0 '* (vector 'type 'GroupMember) #f "https://hl7.org/fhir/R5/group.html#Group.member" #f)
             ) #f #f))
(register-element! "Group.identifier" (fhir-spec (string->symbol "Group.identifier") "https://hl7.org/fhir/R5/group.html#Group.identifier" 'element))
(register-element! "Group.active" (fhir-spec (string->symbol "Group.active") "https://hl7.org/fhir/R5/group.html#Group.active" 'element))
(register-element! "Group.type" (fhir-spec (string->symbol "Group.type") "https://hl7.org/fhir/R5/group.html#Group.type" 'element))
(register-element! "Group.membership" (fhir-spec (string->symbol "Group.membership") "https://hl7.org/fhir/R5/group.html#Group.membership" 'element))
(register-element! "Group.code" (fhir-spec (string->symbol "Group.code") "https://hl7.org/fhir/R5/group.html#Group.code" 'element))
(register-element! "Group.name" (fhir-spec (string->symbol "Group.name") "https://hl7.org/fhir/R5/group.html#Group.name" 'element))
(register-element! "Group.description" (fhir-spec (string->symbol "Group.description") "https://hl7.org/fhir/R5/group.html#Group.description" 'element))
(register-element! "Group.quantity" (fhir-spec (string->symbol "Group.quantity") "https://hl7.org/fhir/R5/group.html#Group.quantity" 'element))
(register-element! "Group.managingEntity" (fhir-spec (string->symbol "Group.managingEntity") "https://hl7.org/fhir/R5/group.html#Group.managingEntity" 'element))
(register-element! "Group.characteristic" (fhir-spec (string->symbol "Group.characteristic") "https://hl7.org/fhir/R5/group.html#Group.characteristic" 'element))
(register-element! "Group.member" (fhir-spec (string->symbol "Group.member") "https://hl7.org/fhir/R5/group.html#Group.member" 'element))

(register-type! 'GroupCharacteristic (fhir-spec 'GroupCharacteristic "https://hl7.org/fhir/R5/group.html#Group.characteristic" 'type)
  #:schema (type-schema 'GroupCharacteristic #f 'BackboneElement "https://hl7.org/fhir/R5/group.html#Group.characteristic"
             (list
    (schema-field 'code 1 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/group.html#Group.characteristic.code" #f)
    (schema-field 'exclude 1 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R5/group.html#Group.characteristic.exclude" #f)
    (schema-field 'period 0 1 (vector 'type 'Period) #f "https://hl7.org/fhir/R5/group.html#Group.characteristic.period" #f)
    (schema-field 'valueCodeableConcept 0 1 (vector 'type 'CodeableConcept) 'value "https://hl7.org/fhir/R5/group.html#Group.characteristic.value[x]" #f)
    (schema-field 'valueBoolean 0 1 (vector 'prim "boolean") 'value "https://hl7.org/fhir/R5/group.html#Group.characteristic.value[x]" #f)
    (schema-field 'valueQuantity 0 1 (vector 'type 'Quantity) 'value "https://hl7.org/fhir/R5/group.html#Group.characteristic.value[x]" #f)
    (schema-field 'valueRange 0 1 (vector 'type 'Range) 'value "https://hl7.org/fhir/R5/group.html#Group.characteristic.value[x]" #f)
    (schema-field 'valueReference 0 1 (vector 'type 'Reference) 'value "https://hl7.org/fhir/R5/group.html#Group.characteristic.value[x]" #f)
             ) #f #f))
(register-element! "Group.characteristic.code" (fhir-spec (string->symbol "Group.characteristic.code") "https://hl7.org/fhir/R5/group.html#Group.characteristic.code" 'element))
(register-element! "Group.characteristic.exclude" (fhir-spec (string->symbol "Group.characteristic.exclude") "https://hl7.org/fhir/R5/group.html#Group.characteristic.exclude" 'element))
(register-element! "Group.characteristic.period" (fhir-spec (string->symbol "Group.characteristic.period") "https://hl7.org/fhir/R5/group.html#Group.characteristic.period" 'element))
(register-element! "Group.characteristic.value[x]" (fhir-spec (string->symbol "Group.characteristic.value[x]") "https://hl7.org/fhir/R5/group.html#Group.characteristic.value[x]" 'element))
(register-element! "Group.characteristic.value[x]" (fhir-spec (string->symbol "Group.characteristic.value[x]") "https://hl7.org/fhir/R5/group.html#Group.characteristic.value[x]" 'element))
(register-element! "Group.characteristic.value[x]" (fhir-spec (string->symbol "Group.characteristic.value[x]") "https://hl7.org/fhir/R5/group.html#Group.characteristic.value[x]" 'element))
(register-element! "Group.characteristic.value[x]" (fhir-spec (string->symbol "Group.characteristic.value[x]") "https://hl7.org/fhir/R5/group.html#Group.characteristic.value[x]" 'element))
(register-element! "Group.characteristic.value[x]" (fhir-spec (string->symbol "Group.characteristic.value[x]") "https://hl7.org/fhir/R5/group.html#Group.characteristic.value[x]" 'element))

(register-type! 'GroupMember (fhir-spec 'GroupMember "https://hl7.org/fhir/R5/group.html#Group.member" 'type)
  #:schema (type-schema 'GroupMember #f 'BackboneElement "https://hl7.org/fhir/R5/group.html#Group.member"
             (list
    (schema-field 'entity 1 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/group.html#Group.member.entity" #f)
    (schema-field 'period 0 1 (vector 'type 'Period) #f "https://hl7.org/fhir/R5/group.html#Group.member.period" #f)
    (schema-field 'inactive 0 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R5/group.html#Group.member.inactive" #f)
             ) #f #f))
(register-element! "Group.member.entity" (fhir-spec (string->symbol "Group.member.entity") "https://hl7.org/fhir/R5/group.html#Group.member.entity" 'element))
(register-element! "Group.member.period" (fhir-spec (string->symbol "Group.member.period") "https://hl7.org/fhir/R5/group.html#Group.member.period" 'element))
(register-element! "Group.member.inactive" (fhir-spec (string->symbol "Group.member.inactive") "https://hl7.org/fhir/R5/group.html#Group.member.inactive" 'element))

