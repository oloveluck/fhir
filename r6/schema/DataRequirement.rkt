#lang racket/base
;;; GENERATED from hl7.fhir.r6.core#6.0.0-ballot4 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'DataRequirement (fhir-spec 'DataRequirement "https://build.fhir.org/datatypes.html#DataRequirement" 'type)
  #:schema (type-schema 'DataRequirement #f 'DataType "https://build.fhir.org/datatypes.html#DataRequirement"
             (list
    (schema-field 'type 1 1 (vector 'prim "code") #f "https://build.fhir.org/datatypes.html#DataRequirement.type" #f)
    (schema-field 'profile 0 '* (vector 'prim "canonical") #f "https://build.fhir.org/datatypes.html#DataRequirement.profile" #f)
    (schema-field 'mustSupport 0 '* (vector 'prim "string") #f "https://build.fhir.org/datatypes.html#DataRequirement.mustSupport" #f)
    (schema-field 'codeFilter 0 '* (vector 'type 'DataRequirementCodeFilter) #f "https://build.fhir.org/datatypes.html#DataRequirement.codeFilter" #f)
    (schema-field 'dateFilter 0 '* (vector 'type 'DataRequirementDateFilter) #f "https://build.fhir.org/datatypes.html#DataRequirement.dateFilter" #f)
    (schema-field 'valueFilter 0 '* (vector 'type 'DataRequirementValueFilter) #f "https://build.fhir.org/datatypes.html#DataRequirement.valueFilter" #f)
    (schema-field 'limit 0 1 (vector 'prim "positiveInt") #f "https://build.fhir.org/datatypes.html#DataRequirement.limit" #f)
    (schema-field 'sort 0 '* (vector 'type 'DataRequirementSort) #f "https://build.fhir.org/datatypes.html#DataRequirement.sort" #f)
    (schema-field 'subjectCodeableConcept 0 1 (vector 'type 'CodeableConcept) 'subject "https://build.fhir.org/datatypes.html#DataRequirement.subject[x]" #f)
    (schema-field 'subjectReference 0 1 (vector 'type 'Reference) 'subject "https://build.fhir.org/datatypes.html#DataRequirement.subject[x]" #f)
             ) #f #f))
(register-element! "DataRequirement.type" (fhir-spec (string->symbol "DataRequirement.type") "https://build.fhir.org/datatypes.html#DataRequirement.type" 'element))
(register-element! "DataRequirement.profile" (fhir-spec (string->symbol "DataRequirement.profile") "https://build.fhir.org/datatypes.html#DataRequirement.profile" 'element))
(register-element! "DataRequirement.mustSupport" (fhir-spec (string->symbol "DataRequirement.mustSupport") "https://build.fhir.org/datatypes.html#DataRequirement.mustSupport" 'element))
(register-element! "DataRequirement.codeFilter" (fhir-spec (string->symbol "DataRequirement.codeFilter") "https://build.fhir.org/datatypes.html#DataRequirement.codeFilter" 'element))
(register-element! "DataRequirement.dateFilter" (fhir-spec (string->symbol "DataRequirement.dateFilter") "https://build.fhir.org/datatypes.html#DataRequirement.dateFilter" 'element))
(register-element! "DataRequirement.valueFilter" (fhir-spec (string->symbol "DataRequirement.valueFilter") "https://build.fhir.org/datatypes.html#DataRequirement.valueFilter" 'element))
(register-element! "DataRequirement.limit" (fhir-spec (string->symbol "DataRequirement.limit") "https://build.fhir.org/datatypes.html#DataRequirement.limit" 'element))
(register-element! "DataRequirement.sort" (fhir-spec (string->symbol "DataRequirement.sort") "https://build.fhir.org/datatypes.html#DataRequirement.sort" 'element))
(register-element! "DataRequirement.subject[x]" (fhir-spec (string->symbol "DataRequirement.subject[x]") "https://build.fhir.org/datatypes.html#DataRequirement.subject[x]" 'element))
(register-element! "DataRequirement.subject[x]" (fhir-spec (string->symbol "DataRequirement.subject[x]") "https://build.fhir.org/datatypes.html#DataRequirement.subject[x]" 'element))

(register-type! 'DataRequirementCodeFilter (fhir-spec 'DataRequirementCodeFilter "https://build.fhir.org/datatypes.html#DataRequirement.codeFilter" 'type)
  #:schema (type-schema 'DataRequirementCodeFilter #f 'BackboneElement "https://build.fhir.org/datatypes.html#DataRequirement.codeFilter"
             (list
    (schema-field 'path 0 1 (vector 'prim "string") #f "https://build.fhir.org/datatypes.html#DataRequirement.codeFilter.path" #f)
    (schema-field 'searchParam 0 1 (vector 'prim "string") #f "https://build.fhir.org/datatypes.html#DataRequirement.codeFilter.searchParam" #f)
    (schema-field 'valueSet 0 1 (vector 'prim "canonical") #f "https://build.fhir.org/datatypes.html#DataRequirement.codeFilter.valueSet" #f)
    (schema-field 'code 0 '* (vector 'type 'Coding) #f "https://build.fhir.org/datatypes.html#DataRequirement.codeFilter.code" #f)
             ) #f #f))
(register-element! "DataRequirement.codeFilter.path" (fhir-spec (string->symbol "DataRequirement.codeFilter.path") "https://build.fhir.org/datatypes.html#DataRequirement.codeFilter.path" 'element))
(register-element! "DataRequirement.codeFilter.searchParam" (fhir-spec (string->symbol "DataRequirement.codeFilter.searchParam") "https://build.fhir.org/datatypes.html#DataRequirement.codeFilter.searchParam" 'element))
(register-element! "DataRequirement.codeFilter.valueSet" (fhir-spec (string->symbol "DataRequirement.codeFilter.valueSet") "https://build.fhir.org/datatypes.html#DataRequirement.codeFilter.valueSet" 'element))
(register-element! "DataRequirement.codeFilter.code" (fhir-spec (string->symbol "DataRequirement.codeFilter.code") "https://build.fhir.org/datatypes.html#DataRequirement.codeFilter.code" 'element))

(register-type! 'DataRequirementDateFilter (fhir-spec 'DataRequirementDateFilter "https://build.fhir.org/datatypes.html#DataRequirement.dateFilter" 'type)
  #:schema (type-schema 'DataRequirementDateFilter #f 'BackboneElement "https://build.fhir.org/datatypes.html#DataRequirement.dateFilter"
             (list
    (schema-field 'path 0 1 (vector 'prim "string") #f "https://build.fhir.org/datatypes.html#DataRequirement.dateFilter.path" #f)
    (schema-field 'searchParam 0 1 (vector 'prim "string") #f "https://build.fhir.org/datatypes.html#DataRequirement.dateFilter.searchParam" #f)
    (schema-field 'valueDateTime 0 1 (vector 'prim "dateTime") 'value "https://build.fhir.org/datatypes.html#DataRequirement.dateFilter.value[x]" #f)
    (schema-field 'valuePeriod 0 1 (vector 'type 'Period) 'value "https://build.fhir.org/datatypes.html#DataRequirement.dateFilter.value[x]" #f)
    (schema-field 'valueDuration 0 1 (vector 'type 'Duration) 'value "https://build.fhir.org/datatypes.html#DataRequirement.dateFilter.value[x]" #f)
             ) #f #f))
(register-element! "DataRequirement.dateFilter.path" (fhir-spec (string->symbol "DataRequirement.dateFilter.path") "https://build.fhir.org/datatypes.html#DataRequirement.dateFilter.path" 'element))
(register-element! "DataRequirement.dateFilter.searchParam" (fhir-spec (string->symbol "DataRequirement.dateFilter.searchParam") "https://build.fhir.org/datatypes.html#DataRequirement.dateFilter.searchParam" 'element))
(register-element! "DataRequirement.dateFilter.value[x]" (fhir-spec (string->symbol "DataRequirement.dateFilter.value[x]") "https://build.fhir.org/datatypes.html#DataRequirement.dateFilter.value[x]" 'element))
(register-element! "DataRequirement.dateFilter.value[x]" (fhir-spec (string->symbol "DataRequirement.dateFilter.value[x]") "https://build.fhir.org/datatypes.html#DataRequirement.dateFilter.value[x]" 'element))
(register-element! "DataRequirement.dateFilter.value[x]" (fhir-spec (string->symbol "DataRequirement.dateFilter.value[x]") "https://build.fhir.org/datatypes.html#DataRequirement.dateFilter.value[x]" 'element))

(register-type! 'DataRequirementValueFilter (fhir-spec 'DataRequirementValueFilter "https://build.fhir.org/datatypes.html#DataRequirement.valueFilter" 'type)
  #:schema (type-schema 'DataRequirementValueFilter #f 'BackboneElement "https://build.fhir.org/datatypes.html#DataRequirement.valueFilter"
             (list
    (schema-field 'path 0 1 (vector 'prim "string") #f "https://build.fhir.org/datatypes.html#DataRequirement.valueFilter.path" #f)
    (schema-field 'searchParam 0 1 (vector 'prim "string") #f "https://build.fhir.org/datatypes.html#DataRequirement.valueFilter.searchParam" #f)
    (schema-field 'comparator 0 1 (vector 'prim "code") #f "https://build.fhir.org/datatypes.html#DataRequirement.valueFilter.comparator" #f)
    (schema-field 'valueDateTime 0 1 (vector 'prim "dateTime") 'value "https://build.fhir.org/datatypes.html#DataRequirement.valueFilter.value[x]" #f)
    (schema-field 'valuePeriod 0 1 (vector 'type 'Period) 'value "https://build.fhir.org/datatypes.html#DataRequirement.valueFilter.value[x]" #f)
    (schema-field 'valueDuration 0 1 (vector 'type 'Duration) 'value "https://build.fhir.org/datatypes.html#DataRequirement.valueFilter.value[x]" #f)
             ) #f #f))
(register-element! "DataRequirement.valueFilter.path" (fhir-spec (string->symbol "DataRequirement.valueFilter.path") "https://build.fhir.org/datatypes.html#DataRequirement.valueFilter.path" 'element))
(register-element! "DataRequirement.valueFilter.searchParam" (fhir-spec (string->symbol "DataRequirement.valueFilter.searchParam") "https://build.fhir.org/datatypes.html#DataRequirement.valueFilter.searchParam" 'element))
(register-element! "DataRequirement.valueFilter.comparator" (fhir-spec (string->symbol "DataRequirement.valueFilter.comparator") "https://build.fhir.org/datatypes.html#DataRequirement.valueFilter.comparator" 'element))
(register-element! "DataRequirement.valueFilter.value[x]" (fhir-spec (string->symbol "DataRequirement.valueFilter.value[x]") "https://build.fhir.org/datatypes.html#DataRequirement.valueFilter.value[x]" 'element))
(register-element! "DataRequirement.valueFilter.value[x]" (fhir-spec (string->symbol "DataRequirement.valueFilter.value[x]") "https://build.fhir.org/datatypes.html#DataRequirement.valueFilter.value[x]" 'element))
(register-element! "DataRequirement.valueFilter.value[x]" (fhir-spec (string->symbol "DataRequirement.valueFilter.value[x]") "https://build.fhir.org/datatypes.html#DataRequirement.valueFilter.value[x]" 'element))

(register-type! 'DataRequirementSort (fhir-spec 'DataRequirementSort "https://build.fhir.org/datatypes.html#DataRequirement.sort" 'type)
  #:schema (type-schema 'DataRequirementSort #f 'BackboneElement "https://build.fhir.org/datatypes.html#DataRequirement.sort"
             (list
    (schema-field 'path 1 1 (vector 'prim "string") #f "https://build.fhir.org/datatypes.html#DataRequirement.sort.path" #f)
    (schema-field 'direction 1 1 (vector 'prim "code") #f "https://build.fhir.org/datatypes.html#DataRequirement.sort.direction" #f)
             ) #f #f))
(register-element! "DataRequirement.sort.path" (fhir-spec (string->symbol "DataRequirement.sort.path") "https://build.fhir.org/datatypes.html#DataRequirement.sort.path" 'element))
(register-element! "DataRequirement.sort.direction" (fhir-spec (string->symbol "DataRequirement.sort.direction") "https://build.fhir.org/datatypes.html#DataRequirement.sort.direction" 'element))

