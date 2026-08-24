#lang racket/base
;;; GENERATED — DO NOT EDIT (verified by raco fhir check).
;; The package's OperationDefinitions as data + scaffold constructors: each
;; <code>-operation takes ONLY the handler `(in req) -> node` and yields the
;; operation-entry list for build-app's #:operations (levels/targets from the OD).
(require json (only-in fhir/capability/runtime operation-entry))
(provide operation-definitions
         ActivityDefinition-apply-definition ActivityDefinition-apply-operation
         ChargeItemDefinition-apply-definition ChargeItemDefinition-apply-operation
         PlanDefinition-apply-definition PlanDefinition-apply-operation
         care-gaps-definition care-gaps-operation
         closure-definition closure-operation
         collect-data-definition collect-data-operation
         conforms-definition conforms-operation
         convert-definition convert-operation
         ActivityDefinition-data-requirements-definition ActivityDefinition-data-requirements-operation
         Library-data-requirements-definition Library-data-requirements-operation
         Measure-data-requirements-definition Measure-data-requirements-operation
         PlanDefinition-data-requirements-definition PlanDefinition-data-requirements-operation
         document-definition document-operation
         evaluate-measure-definition evaluate-measure-operation
         Encounter-everything-definition Encounter-everything-operation
         Group-everything-definition Group-everything-operation
         MedicinalProduct-everything-definition MedicinalProduct-everything-operation
         Patient-everything-definition Patient-everything-operation
         expand-definition expand-operation
         find-matches-definition find-matches-operation
         find-definition find-operation
         graph-definition graph-operation
         graphql-definition graphql-operation
         implements-definition implements-operation
         lastn-definition lastn-operation
         lookup-definition lookup-operation
         match-definition match-operation
         meta-add-definition meta-add-operation
         meta-delete-definition meta-delete-operation
         meta-definition meta-operation
         populate-definition populate-operation
         preferred-id-definition preferred-id-operation
         process-message-definition process-message-operation
         questionnaire-definition questionnaire-operation
         snapshot-definition snapshot-operation
         stats-definition stats-operation
         submit-data-definition submit-data-operation
         Claim-submit-definition Claim-submit-operation
         CoverageEligibilityRequest-submit-definition CoverageEligibilityRequest-submit-operation
         subset-definition subset-operation
         subsumes-definition subsumes-operation
         transform-definition transform-operation
         translate-definition translate-operation
         CodeSystem-validate-code-definition CodeSystem-validate-code-operation
         ValueSet-validate-code-definition ValueSet-validate-code-operation
         validate-definition validate-operation
         versions-definition versions-operation)
(define ActivityDefinition-apply-definition
  (string->jsexpr
   "{
  \"code\": \"apply\",
  \"comment\": \"The result of invoking this operation is a resource of the type specified by the activity definition, with all the definitions resolved as appropriate for the type of resource. Any dynamicValue elements will be evaluated (in the order in which they appear in the resource) and the results applied to the returned resource.  If the ActivityDefinition includes library references, those libraries will be available to the evaluated expressions. If those libraries have parameters, those parameters will be bound by name to the parameters given to the operation. In addition, parameters to the $apply operation are available within dynamicValue expressions as context variables, accessible by the name of the parameter, prefixed with a percent (%) symbol. For a more detailed description, refer to the ActivityDefinition resource\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://hl7.org/fhir\"
        },
        {
          \"system\": \"email\",
          \"value\": \"fhir@lists.hl7.org\"
        }
      ]
    }
  ],
  \"date\": \"2019-11-01T09:29:23+11:00\",
  \"description\": \"The apply operation applies a definition in a specific context\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 2
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"trial-use\"
    }
  ],
  \"id\": \"ActivityDefinition-apply\",
  \"instance\": true,
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2019-11-01T09:29:23.356+11:00\"
  },
  \"name\": \"Apply\",
  \"parameter\": [
    {
      \"documentation\": \"The activity definition to apply. If the operation is invoked on an instance, this parameter is not allowed. If the operation is invoked at the type level, this parameter is required\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"activityDefinition\",
      \"type\": \"ActivityDefinition\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The subject(s) that is/are the target of the activity definition to be applied. The subject may be a Patient, Practitioner, Organization, Location, Device, or Group. Subjects provided in this parameter will be resolved as the subject of the PlanDefinition based on the type of the subject. If multiple subjects of the same type are provided, the behavior is implementation-defined\",
      \"max\": \"*\",
      \"min\": 1,
      \"name\": \"subject\",
      \"searchType\": \"reference\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The encounter in context, if any\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"encounter\",
      \"searchType\": \"reference\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The practitioner in context\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"practitioner\",
      \"searchType\": \"reference\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The organization in context\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"organization\",
      \"searchType\": \"reference\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The type of user initiating the request, e.g. patient, healthcare provider, or specific type of healthcare provider (physician, nurse, etc.)\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"userType\",
      \"type\": \"CodeableConcept\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Preferred language of the person using the system\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"userLanguage\",
      \"type\": \"CodeableConcept\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The task the system user is performing, e.g. laboratory results review, medication list review, etc. This information can be used to tailor decision support outputs, such as recommended information resources\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"userTaskContext\",
      \"type\": \"CodeableConcept\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The current setting of the request (inpatient, outpatient, etc.)\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"setting\",
      \"type\": \"CodeableConcept\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Additional detail about the setting of the request, if any\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"settingContext\",
      \"type\": \"CodeableConcept\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The resource that is the result of applying the definition\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"return\",
      \"type\": \"Any\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"ActivityDefinition\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/ActivityDefinition-apply\",
  \"version\": \"4.0.1\"
}"))
(define (ActivityDefinition-apply-operation handler)
  (define code "apply")
  (list (operation-entry 'type code "ActivityDefinition" handler)
        (operation-entry 'instance code "ActivityDefinition" handler)))
(define ChargeItemDefinition-apply-definition
  (string->jsexpr
   "{
  \"code\": \"apply\",
  \"comment\": \"The result of invoking this operation is a resource of the type specified by the activity definition, with all the definitions resolved as appropriate for the type of resource. Any dynamicValue elements will be evaluated (in the order in which they appear in the resource) and the results applied to the returned resource.  If the ActivityDefinition includes library references, those libraries will be available to the evaluated expressions. If those libraries have parameters, those parameters will be bound by name to the parameters given to the operation. For a more detailed description, refer to the ActivityDefinition resource\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://hl7.org/fhir\"
        },
        {
          \"system\": \"email\",
          \"value\": \"fhir@lists.hl7.org\"
        }
      ]
    }
  ],
  \"date\": \"2019-11-01T09:29:23+11:00\",
  \"description\": \"The apply operation applies a definition in a specific context\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 0
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"trial-use\"
    }
  ],
  \"id\": \"ChargeItemDefinition-apply\",
  \"instance\": true,
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2019-11-01T09:29:23.356+11:00\"
  },
  \"name\": \"Apply\",
  \"parameter\": [
    {
      \"documentation\": \"The ChargeItem on which the definition is to ba applies\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"chargeItem\",
      \"targetProfile\": [
        \"http://hl7.org/fhir/StructureDefinition/ChargeItem\"
      ],
      \"type\": \"Reference\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The account in context, if any\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"account\",
      \"targetProfile\": [
        \"http://hl7.org/fhir/StructureDefinition/Account\"
      ],
      \"type\": \"Reference\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The resource that is the result of applying the definition\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"return\",
      \"type\": \"Any\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"ChargeItemDefinition\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/ChargeItemDefinition-apply\",
  \"version\": \"4.0.1\"
}"))
(define (ChargeItemDefinition-apply-operation handler)
  (define code "apply")
  (list (operation-entry 'instance code "ChargeItemDefinition" handler)))
(define PlanDefinition-apply-definition
  (string->jsexpr
   "{
  \"code\": \"apply\",
  \"comment\": \"The result of this operation is a CarePlan resource with a single activity represented by a RequestGroup. The RequestGroup will have actions for each of the applicable actions in the plan based on evaluating the applicability condition in context. For each applicable action, the definition is applied as described in the $apply operation of the ActivityDefinition resource, and the resulting resource is added as an activity to the CarePlan. If the ActivityDefinition includes library references, those libraries will be available to the evaluated expressions. If those libraries have parameters, those parameters will be bound by name to the parameters given to the operation. In addition, parameters to the $apply operation are available within dynamicValue expressions as context variables, accessible by the name of the parameter, prefixed with a percent (%) symbol. For a more detailed description, refer to the PlanDefinition and ActivityDefinition resource documentation\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://hl7.org/fhir\"
        },
        {
          \"system\": \"email\",
          \"value\": \"fhir@lists.hl7.org\"
        }
      ]
    }
  ],
  \"date\": \"2019-11-01T09:29:23+11:00\",
  \"description\": \"The apply operation applies a PlanDefinition to a given context\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 2
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"trial-use\"
    }
  ],
  \"id\": \"PlanDefinition-apply\",
  \"instance\": true,
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2019-11-01T09:29:23.356+11:00\"
  },
  \"name\": \"Apply\",
  \"parameter\": [
    {
      \"documentation\": \"The plan definition to be applied. If the operation is invoked at the instance level, this parameter is not allowed; if the operation is invoked at the type level, this parameter is required\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"planDefinition\",
      \"type\": \"PlanDefinition\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The subject(s) that is/are the target of the plan to be applied. The subject may be a Patient, Practitioner, Organization, Location, Device, or Group. Subjects provided in this parameter will be resolved as the subject of the PlanDefinition based on the type of the subject. If multiple subjects of the same type are provided, the behavior is implementation-defined\",
      \"max\": \"*\",
      \"min\": 1,
      \"name\": \"subject\",
      \"searchType\": \"reference\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The encounter in context, if any\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"encounter\",
      \"searchType\": \"reference\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The practitioner applying the plan definition\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"practitioner\",
      \"searchType\": \"reference\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The organization applying the plan definition\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"organization\",
      \"searchType\": \"reference\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The type of user initiating the request, e.g. patient, healthcare provider, or specific type of healthcare provider (physician, nurse, etc.)\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"userType\",
      \"type\": \"CodeableConcept\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Preferred language of the person using the system\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"userLanguage\",
      \"type\": \"CodeableConcept\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The task the system user is performing, e.g. laboratory results review, medication list review, etc. This information can be used to tailor decision support outputs, such as recommended information resources\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"userTaskContext\",
      \"type\": \"CodeableConcept\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The current setting of the request (inpatient, outpatient, etc.)\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"setting\",
      \"type\": \"CodeableConcept\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Additional detail about the setting of the request, if any\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"settingContext\",
      \"type\": \"CodeableConcept\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The CarePlan that is the result of applying the plan definition\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"return\",
      \"type\": \"CarePlan\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"PlanDefinition\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/PlanDefinition-apply\",
  \"version\": \"4.0.1\"
}"))
(define (PlanDefinition-apply-operation handler)
  (define code "apply")
  (list (operation-entry 'type code "PlanDefinition" handler)
        (operation-entry 'instance code "PlanDefinition" handler)))
(define care-gaps-definition
  (string->jsexpr
   "{
  \"code\": \"care-gaps\",
  \"comment\": \"The effect of invoking this operation is to calculate a set of measures for a particular topic (e.g. Preventive Care and Screening) and return a document describing the results of each measure for the given subject. Note that it is up to the server to determine whether or not the generated care gaps report is persisted. If the server does not persist the results, the operation does not affect state and can be invoked with a GET\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://hl7.org/fhir\"
        },
        {
          \"system\": \"email\",
          \"value\": \"fhir@lists.hl7.org\"
        }
      ]
    }
  ],
  \"date\": \"2019-11-01T09:29:23+11:00\",
  \"description\": \"The care-gaps operation is used to determine gaps-in-care based on the results of quality measures\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 2
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"trial-use\"
    }
  ],
  \"id\": \"Measure-care-gaps\",
  \"instance\": false,
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2019-11-01T09:29:23.356+11:00\"
  },
  \"name\": \"Care Gaps\",
  \"parameter\": [
    {
      \"documentation\": \"The start of the measurement period. In keeping with the semantics of the date parameter used in the FHIR search operation, the period will start at the beginning of the period implied by the supplied timestamp. E.g. a value of 2014 would set the period s\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"periodStart\",
      \"type\": \"date\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The end of the measurement period. The period will end at the end of the period implied by the supplied timestamp. E.g. a value of 2014 would set the period end to be 2014-12-31T23:59:59 inclusive\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"periodEnd\",
      \"type\": \"date\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The topic to be used to determine which measures are considered for the care gaps report. Any measure with the given topic will be included in the report\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"topic\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Subject for which the care gaps report will be produced\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"subject\",
      \"searchType\": \"reference\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The result of the care gaps report will be returned as a document bundle with a MeasureReport entry for each included measure\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"return\",
      \"type\": \"Bundle\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"Measure\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Measure-care-gaps\",
  \"version\": \"4.0.1\"
}"))
(define (care-gaps-operation handler)
  (define code "care-gaps")
  (list (operation-entry 'type code "Measure" handler)))
(define closure-definition
  (string->jsexpr
   "{
  \"code\": \"closure\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://hl7.org/fhir\"
        },
        {
          \"system\": \"email\",
          \"value\": \"fhir@lists.hl7.org\"
        }
      ]
    }
  ],
  \"date\": \"2019-11-01T09:29:23+11:00\",
  \"description\": \"This operation provides support for ongoing maintenance of a client-side [transitive closure table](https://en.wikipedia.org/wiki/Transitive_closure#In_graph_theory) based on server-side terminological logic. For details of how this is used, see [Maintaining a Closure Table](terminology-service.html#closure)\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 3
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"trial-use\"
    }
  ],
  \"id\": \"ConceptMap-closure\",
  \"instance\": false,
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2019-11-01T09:29:23.356+11:00\"
  },
  \"name\": \"Closure Table Maintenance\",
  \"parameter\": [
    {
      \"documentation\": \"The name that defines the particular context for the subsumption based closure table\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"name\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Concepts to add to the closure table\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"concept\",
      \"type\": \"Coding\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"A request to resynchronise - request to send all new entries since the nominated version was sent by the server\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"version\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"A list of new entries (code / system --> code/system) that the client should add to its closure table. The only kind of entry mapping equivalences that can be returned are equal, specializes, subsumes and unmatched\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"return\",
      \"type\": \"ConceptMap\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"ConceptMap\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": true,
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/ConceptMap-closure\",
  \"version\": \"4.0.1\"
}"))
(define (closure-operation handler)
  (define code "closure")
  (list (operation-entry 'system code #f handler)))
(define collect-data-definition
  (string->jsexpr
   "{
  \"code\": \"collect-data\",
  \"comment\": \"The effect of invoking this operation is to gather the data required to perform an evaluation of the measure. If the lastReceivedOn parameter is supplied, only data that is new or has been changed since the lastReceivedOn date is included in the response. Note that the resulting MeasureReport is a transient resource\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://hl7.org/fhir\"
        },
        {
          \"system\": \"email\",
          \"value\": \"fhir@lists.hl7.org\"
        }
      ]
    }
  ],
  \"date\": \"2019-11-01T09:29:23+11:00\",
  \"description\": \"The collect-data operation is used to collect the data-of-interest for the given measure.\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 2
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"trial-use\"
    }
  ],
  \"id\": \"Measure-collect-data\",
  \"instance\": true,
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2019-11-01T09:29:23.356+11:00\"
  },
  \"name\": \"Collect Data\",
  \"parameter\": [
    {
      \"documentation\": \"The start of the measurement period. In keeping with the semantics of the date parameter used in the FHIR search operation, the period will start at the beginning of the period implied by the supplied timestamp. E.g. a value of 2014 would set the period s\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"periodStart\",
      \"type\": \"date\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The end of the measurement period. The period will end at the end of the period implied by the supplied timestamp. E.g. a value of 2014 would set the period end to be 2014-12-31T23:59:59 inclusive\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"periodEnd\",
      \"type\": \"date\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The measure to evaluate. This parameter is only required when the operation is invoked on the resource type, it is not used when invoking the operation on a Measure instance\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"measure\",
      \"searchType\": \"reference\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Subject for which the measure will be collected. If not specified, measure data will be collected for all subjects that meet the requirements of the measure. If specified, the measure will only be calculated for the referenced subject(s)\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"subject\",
      \"searchType\": \"reference\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Practitioner for which the measure will be collected. If specified, measure data will be collected only for subjects that have a primary relationship to the identified practitioner\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"practitioner\",
      \"searchType\": \"reference\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The date the results of this measure were last received. This parameter used to indicate when the last time data for this measure was collected. This information is used to support incremental data collection scenarios\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"lastReceivedOn\",
      \"type\": \"dateTime\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"A MeasureReport of type data-collection detailing the results of the operation\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"measureReport\",
      \"type\": \"MeasureReport\",
      \"use\": \"out\"
    },
    {
      \"documentation\": \"The result resources that make up the data-of-interest for the measure\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"resource\",
      \"type\": \"Resource\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"Measure\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Measure-collect-data\",
  \"version\": \"4.0.1\"
}"))
(define (collect-data-operation handler)
  (define code "collect-data")
  (list (operation-entry 'type code "Measure" handler)
        (operation-entry 'instance code "Measure" handler)))
(define conforms-definition
  (string->jsexpr
   "{
  \"code\": \"conforms\",
  \"comment\": \"The operation performs a full comparison of the functionality described by the two capability statements, including the profiles and value sets they reference, and also including concept maps and structure maps.     \\n\\nThe full execution of this operation is still a matter of research, but it is intended to support comparison of systems to see if they will interoperate    \\n\\nIf the capability statements can be successfully compared, then the return value is a 200 OK with an OperationOutcome along with intersection and union capability statements. The operation outcome can contain errors relating to differences between the capability statements. If the capability statements cannot be compared, because dependencies cannot be located, the return value is a 4xx error, with an OperationOutcome with at least one issue with severity >= error\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://hl7.org/fhir\"
        },
        {
          \"system\": \"email\",
          \"value\": \"fhir@lists.hl7.org\"
        }
      ]
    }
  ],
  \"date\": \"2019-11-01T09:29:23+11:00\",
  \"description\": \"This operation asks the server to check that it implements all the resources, interactions, search parameters, and operations that the client provides in its capability statement. The client provides both capability statements by reference, and must ensure that all the referenced resources are available to the conformance server\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 5
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"trial-use\"
    }
  ],
  \"id\": \"CapabilityStatement-conforms\",
  \"instance\": false,
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2019-11-01T09:29:23.356+11:00\"
  },
  \"name\": \"Test if a server implements a client's required operations\",
  \"parameter\": [
    {
      \"documentation\": \"A canonical reference to the left-hand system's capability statement\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"left\",
      \"type\": \"canonical\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"A canonical reference to the right-hand system's capability statement\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"right\",
      \"type\": \"canonical\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"What kind of comparison to perform - server to server, or client to server (use the codes 'server/server' or 'client/server')\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"mode\",
      \"type\": \"code\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Outcome of the CapabilityStatement test\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"issues\",
      \"type\": \"OperationOutcome\",
      \"use\": \"out\"
    },
    {
      \"documentation\": \"The intersection of the functionality described by the CapabilityStatement resources\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"union\",
      \"type\": \"CapabilityStatement\",
      \"use\": \"out\"
    },
    {
      \"documentation\": \"The union of the functionality described by the CapabilityStatement resources\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"intersection\",
      \"type\": \"CapabilityStatement\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"CapabilityStatement\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/CapabilityStatement-conforms\",
  \"version\": \"4.0.1\"
}"))
(define (conforms-operation handler)
  (define code "conforms")
  (list (operation-entry 'type code "CapabilityStatement" handler)))
(define convert-definition
  (string->jsexpr
   "{
  \"code\": \"convert\",
  \"comment\": \"While the primary use of this operation is simple - converting a resource from one format to another, there are many potential uses including:\\n\\n* converting resources from one version to another\\n* restructuring information in a resource (e.g. moving method into/out of Observation.code)\\n* extracting data from a questionnaire\\n* converting CDA documents or v2 messages (as a binary resource) to a bundle (or vice versa) (or even openEHR or openMHealth). \\n\\nThese variants would all be associated with parameters that define and control these kind of conversions, though such parameters are not defined at this time. In the absence of any parameters, simple format conversion is all that will occur.\\n\\nFor this reason, implementers should be aware that:\\n\\n* the output resource type may be different from the input resource (particularly, it might be a bundle)\\n* binary resources may be represented directly using some other content-type (i.e. just post the content directly)\\n\\nImplementers are encouraged to provide feedback to HL7 about their use of this operation\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://hl7.org/fhir\"
        },
        {
          \"system\": \"email\",
          \"value\": \"fhir@lists.hl7.org\"
        }
      ]
    }
  ],
  \"date\": \"2019-11-01T09:29:23+11:00\",
  \"description\": \"This operation takes a resource in one form, and returns to in another form. Both input and output are a single resource. The primary use of this operation is to convert between formats (e.g. (XML -> JSON or vice versa)\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 1
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"draft\"
    }
  ],
  \"id\": \"Resource-convert\",
  \"instance\": false,
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2019-11-01T09:29:23.356+11:00\"
  },
  \"name\": \"Convert from one form to another\",
  \"parameter\": [
    {
      \"documentation\": \"The resource that is to be converted\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"input\",
      \"type\": \"Resource\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The resource after conversion\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"output\",
      \"type\": \"Resource\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"Resource\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": true,
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Resource-convert\",
  \"version\": \"4.0.1\"
}"))
(define (convert-operation handler)
  (define code "convert")
  (list (operation-entry 'system code #f handler)))
(define ActivityDefinition-data-requirements-definition
  (string->jsexpr
   "{
  \"code\": \"data-requirements\",
  \"comment\": \"The effect of invoking this operation is to determine the aggregate set of data requirements and dependencies for the activity definition. The result is a Library resource with a type of module-definition that contains all the parameter definitions and data requirements of the activity definition and any libraries referenced by it. Implementations SHOULD aggregate data requirements intelligently (i.e. by collapsing overlapping data requirements)\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://hl7.org/fhir\"
        },
        {
          \"system\": \"email\",
          \"value\": \"fhir@lists.hl7.org\"
        }
      ]
    }
  ],
  \"date\": \"2019-11-01T09:29:23+11:00\",
  \"description\": \"The data-requirements operation aggregates and returns the parameters and data requirements for the activity definition and all its dependencies as a single module definition library\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 2
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"trial-use\"
    }
  ],
  \"id\": \"ActivityDefinition-data-requirements\",
  \"instance\": true,
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2019-11-01T09:29:23.356+11:00\"
  },
  \"name\": \"Data Requirements\",
  \"parameter\": [
    {
      \"documentation\": \"The result of the requirements gathering represented as a module-definition Library that describes the aggregate parameters, data requirements, and dependencies of the activity definition\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"return\",
      \"type\": \"Library\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"ActivityDefinition\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/ActivityDefinition-data-requirements\",
  \"version\": \"4.0.1\"
}"))
(define (ActivityDefinition-data-requirements-operation handler)
  (define code "data-requirements")
  (list (operation-entry 'instance code "ActivityDefinition" handler)))
(define Library-data-requirements-definition
  (string->jsexpr
   "{
  \"code\": \"data-requirements\",
  \"comment\": \"The effect of invoking this operation is to determine the aggregate set of data requirements and dependencies for a given target resource. The result is a Library resource with a type of module-definition that contains all the parameter definitions and data requirements of the target resource and any libraries referenced by it. Implementations SHOULD aggregate data requirements intelligently (i.e. by collapsing overlapping data requirements)\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://hl7.org/fhir\"
        },
        {
          \"system\": \"email\",
          \"value\": \"fhir@lists.hl7.org\"
        }
      ]
    }
  ],
  \"date\": \"2019-11-01T09:29:23+11:00\",
  \"description\": \"The data-requirements operation aggregates and returns the parameters and data requirements for a resource and all its dependencies as a single module definition\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 2
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"trial-use\"
    }
  ],
  \"id\": \"Library-data-requirements\",
  \"instance\": true,
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2019-11-01T09:29:23.356+11:00\"
  },
  \"name\": \"Data Requirements\",
  \"parameter\": [
    {
      \"documentation\": \"The target of the data requirements operation\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"target\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The result of the requirements gathering\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"return\",
      \"type\": \"Library\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"Library\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": true,
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Library-data-requirements\",
  \"version\": \"4.0.1\"
}"))
(define (Library-data-requirements-operation handler)
  (define code "data-requirements")
  (list (operation-entry 'system code #f handler)
        (operation-entry 'instance code "Library" handler)))
(define Measure-data-requirements-definition
  (string->jsexpr
   "{
  \"code\": \"data-requirements\",
  \"comment\": \"The effect of invoking this operation is to determine the aggregate set of data requirements and dependencies for the measure. The result is a Library resource with a type of module-definition that contains all the parameter definitions and data requirements of the libraries referenced by the measures. Implementations SHOULD aggregate data requirements intelligently (i.e. by collapsing overlapping data requirements). This operation defines what resources are subsequently referenced in the evaluatedResources element of the MeasureReport when submitting measure data\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://hl7.org/fhir\"
        },
        {
          \"system\": \"email\",
          \"value\": \"fhir@lists.hl7.org\"
        }
      ]
    }
  ],
  \"date\": \"2019-11-01T09:29:23+11:00\",
  \"description\": \"The data-requirements operation aggregates and returns the parameters and data requirements for the measure and all its dependencies as a single module definition\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 2
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"trial-use\"
    }
  ],
  \"id\": \"Measure-data-requirements\",
  \"instance\": true,
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2019-11-01T09:29:23.356+11:00\"
  },
  \"name\": \"Data Requirements\",
  \"parameter\": [
    {
      \"documentation\": \"The start of the measurement period. In keeping with the semantics of the date parameter used in the FHIR search operation, the period will start at the beginning of the period implied by the supplied timestamp. E.g. a value of 2014 would set the period start to be 2014-01-01T00:00:00 inclusive\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"periodStart\",
      \"type\": \"date\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The end of the measurement period. The period will end at the end of the period implied by the supplied timestamp. E.g. a value of 2014 would set the period end to be 2014-12-31T23:59:59 inclusive\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"periodEnd\",
      \"type\": \"date\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The result of the requirements gathering is a module-definition Library that describes the aggregate parameters, data requirements, and dependencies of the measure\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"return\",
      \"type\": \"Library\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"Measure\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Measure-data-requirements\",
  \"version\": \"4.0.1\"
}"))
(define (Measure-data-requirements-operation handler)
  (define code "data-requirements")
  (list (operation-entry 'instance code "Measure" handler)))
(define PlanDefinition-data-requirements-definition
  (string->jsexpr
   "{
  \"code\": \"data-requirements\",
  \"comment\": \"The effect of invoking this operation is to determine the aggregate set of data requirements and dependencies for the plan definition. The result is a Library resource with a type of module-definition that contains all the parameter definitions and data requirements of the plan definition and any libraries referenced by it. Implementations SHOULD aggregate data requirements intelligently (i.e. by collapsing overlapping data requirements)\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://hl7.org/fhir\"
        },
        {
          \"system\": \"email\",
          \"value\": \"fhir@lists.hl7.org\"
        }
      ]
    }
  ],
  \"date\": \"2019-11-01T09:29:23+11:00\",
  \"description\": \"The data-requirements operation aggregates and returns the parameters and data requirements for the plan definition and all its dependencies as a single module definition library\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 2
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"trial-use\"
    }
  ],
  \"id\": \"PlanDefinition-data-requirements\",
  \"instance\": true,
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2019-11-01T09:29:23.356+11:00\"
  },
  \"name\": \"Data Requirements\",
  \"parameter\": [
    {
      \"documentation\": \"The result of the requirements gathering is a module-definition Library that describes the aggregate parameters, data requirements, and dependencies of the plan definition\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"return\",
      \"type\": \"Library\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"PlanDefinition\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/PlanDefinition-data-requirements\",
  \"version\": \"4.0.1\"
}"))
(define (PlanDefinition-data-requirements-operation handler)
  (define code "data-requirements")
  (list (operation-entry 'instance code "PlanDefinition" handler)))
(define document-definition
  (string->jsexpr
   "{
  \"code\": \"document\",
  \"comment\": \"Note: this operation definition does not resolve the question how document signatures are created. This is an open issue during the period of trial use, and feedback is requested regarding this question\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://hl7.org/fhir\"
        },
        {
          \"system\": \"email\",
          \"value\": \"fhir@lists.hl7.org\"
        }
      ]
    }
  ],
  \"date\": \"2019-11-01T09:29:23+11:00\",
  \"description\": \"A client can ask a server to generate a fully bundled document from a composition resource. The server takes the composition resource, locates all the referenced resources and other additional resources as configured or requested and either returns a full document bundle, or returns an error. Note that since this is a search operation, the document bundle is  wrapped inside the search bundle.  If some of the resources are located on other servers, it is at the discretion of the  server whether to retrieve them or return an error. If the correct version of the document  that would be generated already exists, then the server can return the existing one.\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 2
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"trial-use\"
    }
  ],
  \"id\": \"Composition-document\",
  \"instance\": true,
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2019-11-01T09:29:23.356+11:00\"
  },
  \"name\": \"Generate a Document\",
  \"parameter\": [
    {
      \"documentation\": \"Identifies the composition to use. This can either be a simple id, which identifies a composition, or it can be a full URL, which identifies a composition on another server. \\n\\nNotes: \\n\\n* GET [base]/Composition/[id]/$document is identical in meaning to GET [base]/Composition/$document?id=[id]\\n* the id parameter SHALL NOT be used if the operation is requested on a particular composition (e.g.  GET [base]/Composition/[id]/$document?id=[id] is not allowed)\\n* Servers are not required to support generating documents on Compositions located on another server\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"id\",
      \"type\": \"uri\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Whether to store the document at the bundle end-point (/Bundle) or not once it is generated. Value = true or false (default is for the server to decide). If the document is stored, it's location can be inferred from the Bundle.id, but it SHOULD be provided explicitly in the HTTP Location header in the response\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"persist\",
      \"type\": \"boolean\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Canonical reference to a GraphDefinition. If a URL is provided, it is the canonical reference to a [GraphDefinition](graphdefinition.html) that it controls what resources are to be added to the bundle when building the document. The GraphDefinition can also specify profiles that apply to the various resources\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"graph\",
      \"type\": \"uri\",
      \"use\": \"in\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"Composition\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Composition-document\",
  \"version\": \"4.0.1\"
}"))
(define (document-operation handler)
  (define code "document")
  (list (operation-entry 'type code "Composition" handler)
        (operation-entry 'instance code "Composition" handler)))
(define evaluate-measure-definition
  (string->jsexpr
   "{
  \"code\": \"evaluate-measure\",
  \"comment\": \"The effect of invoking this operation is to calculate the measure for the given subject, or all subjects if no subject is supplied, and return the results as a MeasureReport resource of the appropriate type. Note that whether or not this operation affects the state of the server depends on whether the server persists the generated MeasureReport. If the MeasureReport is not persisted, this operation can be invoked with GET\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://hl7.org/fhir\"
        },
        {
          \"system\": \"email\",
          \"value\": \"fhir@lists.hl7.org\"
        }
      ]
    }
  ],
  \"date\": \"2019-11-01T09:29:23+11:00\",
  \"description\": \"The evaluate-measure operation is used to calculate an eMeasure and obtain the results\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 2
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"trial-use\"
    }
  ],
  \"id\": \"Measure-evaluate-measure\",
  \"instance\": true,
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2019-11-01T09:29:23.356+11:00\"
  },
  \"name\": \"Evaluate Measure\",
  \"parameter\": [
    {
      \"documentation\": \"The start of the measurement period. In keeping with the semantics of the date parameter used in the FHIR search operation, the period will start at the beginning of the period implied by the supplied timestamp. E.g. a value of 2014 would set the period start to be 2014-01-01T00:00:00 inclusive\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"periodStart\",
      \"type\": \"date\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The end of the measurement period. The period will end at the end of the period implied by the supplied timestamp. E.g. a value of 2014 would set the period end to be 2014-12-31T23:59:59 inclusive\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"periodEnd\",
      \"type\": \"date\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The measure to evaluate. This parameter is only required when the operation is invoked on the resource type, it is not used when invoking the operation on a Measure instance\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"measure\",
      \"searchType\": \"reference\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The type of measure report: subject, subject-list, or population. If not specified, a default value of subject will be used if the subject parameter is supplied, otherwise, population will be used\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"reportType\",
      \"type\": \"code\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Subject for which the measure will be calculated. If not specified, the measure will be calculated for all subjects that meet the requirements of the measure. If specified, the measure will only be calculated for the referenced subject(s)\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"subject\",
      \"searchType\": \"reference\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Practitioner for which the measure will be calculated. If specified, the measure will be calculated only for subjects that have a primary relationship to the identified practitioner\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"practitioner\",
      \"searchType\": \"reference\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The date the results of this measure were last received. This parameter is only valid for patient-level reports and is used to indicate when the last time a result for this patient was received. This information can be used to limit the set of resources returned for a patient-level report\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"lastReceivedOn\",
      \"type\": \"dateTime\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The results of the measure calculation. See the MeasureReport resource for a complete description of the output of this operation. Note that implementations may choose to return a MeasureReport with a status of pending to indicate that the report is still being generated. In this case, the client can use a polling method to continually request the MeasureReport until the status is updated to complete\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"return\",
      \"type\": \"MeasureReport\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"Measure\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Measure-evaluate-measure\",
  \"version\": \"4.0.1\"
}"))
(define (evaluate-measure-operation handler)
  (define code "evaluate-measure")
  (list (operation-entry 'type code "Measure" handler)
        (operation-entry 'instance code "Measure" handler)))
(define Encounter-everything-definition
  (string->jsexpr
   "{
  \"code\": \"everything\",
  \"comment\": \"The key differences between this operation and simply searching the encounter compartment are:  \\n\\n* unless the client requests otherwise, the server returns the entire result set in a single bundle (rather than using paging) \\n* the server is responsible for determining what resources to return as included resources (rather than the client specifying which ones)\\n\\nThis frees the client from needing to determine what it could or should ask for, particularly with regard to included resources. Servers should consider returning appropriate Provenance and AuditTrail on the returned resources, even though these are not directly part of the patient compartment. \\n\\nIt is assumed that the server has identified and secured the context appropriately, and can either associate the authorization context with a single encounter, or determine whether the context has the rights to the nominated encounter, if there is one, or can determine an appropriate list of encouners to provide data for from the context of the request.  If there is no nominated encounter (GET /Encounter/$everything) and the context is not associated with a single encounter record, the actual list of encounters is all encounters that the user associated with the request has access to. In such cases, the server may choose to return an error rather than all the records. Specifying the relationship between the context, a user and encounter records is outside the scope of this specification (though see [The Smart App Launch Implementation Guide](http://hl7.org/fhir/smart-app-launch).   \\n\\nWhen this operation is used to access multiple encounter records at once, the return bundle could be rather a lot of data; servers may choose to require that such requests are made [asynchronously](async.html), and associated with [bulk data formats](formats.html#bulk). Alternatively, clients may choose to page through the result set (or servers may require this). Paging through the results is done the same as for [Searching](http.html#paging), using the [_count](search.html#count) parameter, and Bundle links. Implementers should note that paging will be slower than simply returning all the results at once (more network traffic, multiple latency delays) but may be required in order not to exhaust available memory reading or writing the whole response in a single package. Unlike searching, there is no inherent user-display order for the $everything operation. Servers might consider sorting the returned resources in descending order of last record update, but are not required to do so. Servers should consider returning appropriate Provenance and AuditTrail on the returned resources, even though these are not directly part of the patient compartment.\\n\\nThe _since parameter is provided to support periodic queries to get additional information that has changed about the encounter since the last query. This means that the _since parameter is based on record time. The value of the _since parameter should be set to the time from the server. If using direct response, this is the timestamp in the response header. If using the async interface, this is the transaction timestamp in the json response. Servers should ensure that the timestamps a managed such that the client does not miss any changes. Clients should be able to handle getting the same response more than once in the case that the transaction falls on a time boundary. Clients should ensure that the other query parameters are constant to ensure a coherent set of records when doing periodic queries.\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://hl7.org/fhir\"
        },
        {
          \"system\": \"email\",
          \"value\": \"fhir@lists.hl7.org\"
        }
      ]
    }
  ],
  \"date\": \"2019-11-01T09:29:23+11:00\",
  \"description\": \"This operation is used to return all the information related to an encounter described in the resource on which this operation is invoked. The response is a bundle of type \\\"searchset\\\". At a minimum, the encounter resource itself is returned, along with any other resources that the server has available for the given encounter for the user. The server also returns whatever resources are needed to support the records - e.g. linked practitioners, locations, organizations etc. The principle intended use for this operation is to provide a patient with access to their record, or to allow a client to retrieve everything for an encounter for efficient display).\\r\\rThe server SHOULD return all resources it has that:\\r\\r* are included in the encounter compartment for the identified encounter (have a reference to the encounter)\\r* are referenced by the standard extenstion for associating an encounter (where no reference element exists) http://hl7.org/fhir/StructureDefinition/encounter-associatedEncounter\\r* the server believes are relevant to the context of the encounter for any other reason (internally defined/decided)\\r* any resource referenced by the above, including binaries and attachments (to make a more complete package)\\r\\rIn the US Realm, at a mimimum, the resources returned SHALL include all the data covered by the meaningful use common data elements (see [DAF](http://hl7.org/fhir/us/daf) for further guidance). Other applicable implementation guides may make additional rules about the information that is returned.   Note that for many resources, the exact nature of the link to encounter can be ambiguous (e.g. for a DiagnosticReport, is it the encounter when it was initiated, or when it was reported?)\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 2
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"trial-use\"
    }
  ],
  \"id\": \"Encounter-everything\",
  \"instance\": true,
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2019-11-01T09:29:23.356+11:00\"
  },
  \"name\": \"Fetch Encounter Record\",
  \"parameter\": [
    {
      \"documentation\": \"Resources updated after this period will be included in the response. The intent of this parameter is to allow a client to request only records that have changed since the last request, based on either the return header time, or or (for asynchronous use), the transaction time\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"_since\",
      \"type\": \"instant\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"One or more parameters, each containing one or more comma-delimited FHIR resource types to include in the return resources. In the absense of any specified types, the server returns all resource types\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"_type\",
      \"type\": \"code\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"See discussion below on the utility of paging through the results of the $everything operation\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"_count\",
      \"type\": \"integer\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The bundle type is \\\"searchset\\\"\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"return\",
      \"type\": \"Bundle\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"Encounter\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Encounter-everything\",
  \"version\": \"4.0.1\"
}"))
(define (Encounter-everything-operation handler)
  (define code "everything")
  (list (operation-entry 'instance code "Encounter" handler)))
(define Group-everything-definition
  (string->jsexpr
   "{
  \"code\": \"everything\",
  \"comment\": \"The key differences between this operation and simply searching the group's patients compartment are:    \\n\\n* unless the client requests otherwise, the server returns the entire result set in a single bundle (rather than using paging)  \\n* the server is responsible for determining what resources to return as included resources (rather than the client specifying which ones). \\n\\nThis frees the client from needing to determine what it could or should ask for, particularly with regard to included resources.  \\n\\nIt is assumed that the server has identified and secured the context appropriately, and can either associate the authorization context with a particular group, or determine whether the context has the rights to the nominated group, if there is one, or can determine an appropriate list of groups to provide data for from the context of the request.   If there is no nominated group (GET /Group/$everything) and the context is not associated with a single group record, the actual list of groups is all groups that the user associated with the request has access to. In such cases, the server may choose to return an error rather than all the records (and is likely to do so, but not required to).  Specifying the relationship between the context, a user and groups is outside the scope of this specification (though see [The Smart App Launch Implementation Guide](http://hl7.org/fhir/smart-app-launch). \\n\\nThe return bundle from this operation is usually rather a lot of data; servers typically choose to require that such requests are made [asynchronously](async.html), and associated with [bulk data formats](formats.html#bulk). Alternatively, clients may choose to page through the result set (or servers may require this). Paging through the results is done the same as for [Searching](http.html#paging), using the [_count](search.html#count) parameter, and Bundle links. Implementers should note that paging will be slower than simply returning all the results at once (more network traffic, multiple latency delays) but may be required in order not to exhaust available memory reading or writing the whole response in a single package. Unlike searching, there is no inherent user-display order for the $everything operation. Servers might consider sorting the returned resources in descending order of last record update, but are not required to do so.\\n\\nThe _since parameter is provided to support periodic queries to get additional information that has changed about the group since the last query. This means that the _since parameter is based on record time. The value of the _since parameter should be set to the time from the server. If using direct response, this is the timestamp in the response header. If using the async interface, this is the transaction timestamp in the json response. Servers should ensure that the timestamps a managed such that the client does not miss any changes. Clients should be able to handle getting the same response more than once in the case that the transaction falls on a time boundary. Clients should ensure that the other query parameters are constant to ensure a coherent set of records when doing periodic queries.\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://hl7.org/fhir\"
        },
        {
          \"system\": \"email\",
          \"value\": \"fhir@lists.hl7.org\"
        }
      ]
    }
  ],
  \"date\": \"2019-11-01T09:29:23+11:00\",
  \"description\": \"This operation is used to return all the information related to one or more patients that are part of the group on which this operation is invoked. The response is a bundle of type \\\"searchset\\\". At a minimum, the patient resource(s) itself is returned, along with any other resources that the server has that are related to the patient(s), and that are available for the given user. The server also returns whatever resources are needed to support the records - e.g. linked practitioners, medications, locations, organizations etc.   The intended use for this operation is for a provider or other user to perform a bulk data download.  The server SHOULD return at least all resources that it has that are in the patient compartment for the identified patient(s), and any resource referenced from those, including binaries and attachments. In the US Realm, at a mimimum, the resources returned SHALL include all the data covered by the meaningful use common data elements as defined in [US-Core](http://hl7.org/fhir/us/coref). Other applicable implementation guides may make additional rules about how much information that is returned.\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 1
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"trial-use\"
    }
  ],
  \"id\": \"Group-everything\",
  \"instance\": true,
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2019-11-01T09:29:23.356+11:00\"
  },
  \"name\": \"Fetch a group of Patient Records\",
  \"parameter\": [
    {
      \"documentation\": \"The date range relates to care dates, not record currency dates - e.g. all records relating to care provided in a certain date range. If no start date is provided, all records prior to the end date are in scope.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"start\",
      \"type\": \"date\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The date range relates to care dates, not record currency dates - e.g. all records relating to care provided in a certain date range. If no end date is provided, all records subsequent to the start date are in scope.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"end\",
      \"type\": \"date\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Resources updated after this period will be included in the response. The intent of this parameter is to allow a client to request only records that have changed since the last request, based on either the return header time, or or (for asynchronous use), the transaction time\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"_since\",
      \"type\": \"instant\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"One or more parameters, each containing one or more comma-delimited FHIR resource types to include in the return resources. In the absense of any specified types, the server returns all resource types\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"_type\",
      \"type\": \"code\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"See discussion below on the utility of paging through the results of the $everything operation\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"_count\",
      \"type\": \"integer\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The bundle type is \\\"searchset\\\"\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"return\",
      \"type\": \"Bundle\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"Group\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Group-everything\",
  \"version\": \"4.0.1\"
}"))
(define (Group-everything-operation handler)
  (define code "everything")
  (list (operation-entry 'instance code "Group" handler)))
(define MedicinalProduct-everything-definition
  (string->jsexpr
   "{
  \"code\": \"everything\",
  \"comment\": \"The key differences between this operation and simply performing a search and using _include and _revinclude are:    \\n\\n* unless the client requests otherwise, the server returns the entire result set in a single bundle (rather than using paging)  \\n* the server is responsible for determining what resources to return as included resources (rather than the client specifying which ones). \\n\\nThis frees the client from needing to determine what it could or should ask for, particularly with regard to included resources. It also makes for a much shorter and easier to construct query string. Servers should consider returning appropriate Provenance and AuditTrail on the returned resources, even though these are not directly part of the product data. \\n\\nWhen this operation is used to access multiple product records at once, the return bundle could be rather a lot of data; servers may choose to require that such requests are made [asynchronously](async.html), and associated with [bulk data formats](formats.html#bulk). Alternatively, clients may choose to page through the result set (or servers may require this). Paging through the results is done the same as for [Searching](http.html#paging), using the [_count](search.html#count) parameter, and Bundle links. Implementers should note that paging will be slower than simply returning all the results at once (more network traffic, multiple latency delays) but may be required in order not to exhaust available memory reading or writing the whole response in a single package. Unlike searching, there is no inherent user-display order for the $everything operation. Servers might consider sorting the returned resources in descending order of last record update, but are not required to do so.\\n\\nThe _since parameter is provided to support periodic queries to get additional information that has changed about the product since the last query. This means that the _since parameter is based on record time. The value of the _since parameter should be set to the time from the server. If using direct response, this is the timestamp in the response header. If using the async interface, this is the transaction timestamp in the json response. Servers should ensure that the timestamps a managed such that the client does not miss any changes. Clients should be able to handle getting the same response more than once in the case that the transaction falls on a time boundary. Clients should ensure that the other query parameters are constant to ensure a coherent set of records when doing periodic queries.\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://hl7.org/fhir\"
        },
        {
          \"system\": \"email\",
          \"value\": \"fhir@lists.hl7.org\"
        }
      ]
    }
  ],
  \"date\": \"2019-11-01T09:29:23+11:00\",
  \"description\": \"This operation is used to return all the information related to one or more products described in the resource or context on which this operation is invoked. The response is a bundle of type \\\"searchset\\\". At a minimum, the product resource(s) itself is returned, along with any other resources that the server has that are related to the products(s), and that are available for the given user. This is typically the marketing authorisations, ingredients, packages, therapeutic indications and so on. The server also returns whatever resources are needed to support the records - e.g. linked organizations, document references etc.\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 0
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"trial-use\"
    }
  ],
  \"id\": \"MedicinalProduct-everything\",
  \"instance\": true,
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2019-11-01T09:29:23.356+11:00\"
  },
  \"name\": \"Fetch Product Record\",
  \"parameter\": [
    {
      \"documentation\": \"Resources updated after this period will be included in the response. The intent of this parameter is to allow a client to request only records that have changed since the last request, based on either the return header time, or or (for asynchronous use), the transaction time\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"_since\",
      \"type\": \"instant\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"See discussion below on the utility of paging through the results of the $everything operation\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"_count\",
      \"type\": \"integer\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The bundle type is \\\"searchset\\\"\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"return\",
      \"type\": \"Bundle\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"MedicinalProduct\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/MedicinalProduct-everything\",
  \"version\": \"4.0.1\"
}"))
(define (MedicinalProduct-everything-operation handler)
  (define code "everything")
  (list (operation-entry 'type code "MedicinalProduct" handler)
        (operation-entry 'instance code "MedicinalProduct" handler)))
(define Patient-everything-definition
  (string->jsexpr
   "{
  \"code\": \"everything\",
  \"comment\": \"The key differences between this operation and simply searching the patient compartment are:    \\n\\n* unless the client requests otherwise, the server returns the entire result set in a single bundle (rather than using paging)  \\n* the server is responsible for determining what resources to return as included resources (rather than the client specifying which ones). \\n\\nThis frees the client from needing to determine what it could or should ask for, particularly with regard to included resources. Servers should consider returning appropriate Provenance and AuditTrail on the returned resources, even though these are not directly part of the patient compartment. \\n\\nIt is assumed that the server has identified and secured the context appropriately, and can either associate the authorization context with a single patient, or determine whether the context has the rights to the nominated patient, if there is one, or can determine an appropriate list of patients to provide data for from the context of the request.   If there is no nominated patient (GET /Patient/$everything) and the context is not associated with a single patient record, the actual list of patients is all patients that the user associated with the request has access to. This may be all patients in the family that the patient has access to, or it may be all patients that a care provider has access to, or all patients on the entire record system. In such cases, the server may choose to return an error rather than all the records.  Specifying the relationship between the context, a user and patient records is outside the scope of this specification (though see [The Smart App Launch Implementation Guide](http://hl7.org/fhir/smart-app-launch). \\n\\nWhen this operation is used to access multiple patient records at once, the return bundle could be rather a lot of data; servers may choose to require that such requests are made [asynchronously](async.html), and associated with [bulk data formats](formats.html#bulk). Alternatively, clients may choose to page through the result set (or servers may require this). Paging through the results is done the same as for [Searching](http.html#paging), using the [_count](search.html#count) parameter, and Bundle links. Implementers should note that paging will be slower than simply returning all the results at once (more network traffic, multiple latency delays) but may be required in order not to exhaust available memory reading or writing the whole response in a single package. Unlike searching, there is no inherent user-display order for the $everything operation. Servers might consider sorting the returned resources in descending order of last record update, but are not required to do so.\\n\\nThe _since parameter is provided to support periodic queries to get additional information that has changed about the patient since the last query. This means that the _since parameter is based on record time. The value of the _since parameter should be set to the time from the server. If using direct response, this is the timestamp in the response header. If using the async interface, this is the transaction timestamp in the json response. Servers should ensure that the timestamps a managed such that the client does not miss any changes. Clients should be able to handle getting the same response more than once in the case that the transaction falls on a time boundary. Clients should ensure that the other query parameters are constant to ensure a coherent set of records when doing periodic queries.\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://hl7.org/fhir\"
        },
        {
          \"system\": \"email\",
          \"value\": \"fhir@lists.hl7.org\"
        }
      ]
    }
  ],
  \"date\": \"2019-11-01T09:29:23+11:00\",
  \"description\": \"This operation is used to return all the information related to one or more patients described in the resource or context on which this operation is invoked. The response is a bundle of type \\\"searchset\\\". At a minimum, the patient resource(s) itself is returned, along with any other resources that the server has that are related to the patient(s), and that are available for the given user. The server also returns whatever resources are needed to support the records - e.g. linked practitioners, medications, locations, organizations etc.   \\n\\nThe intended use for this operation is to provide a patient with access to their entire record (e.g. \\\"Blue Button\\\"), or for provider or other user to perform a bulk data download.  The server SHOULD return at least all resources that it has that are in the patient compartment for the identified patient(s), and any resource referenced from those, including binaries and attachments. In the US Realm, at a minimum, the resources returned SHALL include all the data covered by the meaningful use common data elements as defined in the US Core Implementation Guide. Other applicable implementation guides may make additional rules about how much information that is returned.\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 5
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"trial-use\"
    }
  ],
  \"id\": \"Patient-everything\",
  \"instance\": true,
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2019-11-01T09:29:23.356+11:00\"
  },
  \"name\": \"Fetch Patient Record\",
  \"parameter\": [
    {
      \"documentation\": \"The date range relates to care dates, not record currency dates - e.g. all records relating to care provided in a certain date range. If no start date is provided, all records prior to the end date are in scope.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"start\",
      \"type\": \"date\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The date range relates to care dates, not record currency dates - e.g. all records relating to care provided in a certain date range. If no end date is provided, all records subsequent to the start date are in scope.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"end\",
      \"type\": \"date\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Resources updated after this period will be included in the response. The intent of this parameter is to allow a client to request only records that have changed since the last request, based on either the return header time, or or (for asynchronous use), the transaction time\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"_since\",
      \"type\": \"instant\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"One or more parameters, each containing one or more comma-delimited FHIR resource types to include in the return resources. In the absence of any specified types, the server returns all resource types\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"_type\",
      \"type\": \"code\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"See discussion below on the utility of paging through the results of the $everything operation\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"_count\",
      \"type\": \"integer\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The bundle type is \\\"searchset\\\"\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"return\",
      \"type\": \"Bundle\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"Patient\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Patient-everything\",
  \"version\": \"4.0.1\"
}"))
(define (Patient-everything-operation handler)
  (define code "everything")
  (list (operation-entry 'type code "Patient" handler)
        (operation-entry 'instance code "Patient" handler)))
(define expand-definition
  (string->jsexpr
   "{
  \"code\": \"expand\",
  \"comment\": \"The value set expansion returned by this query should be treated as a transient result that will change over time (whether it does or not depends on how the value set is specified), so applications should repeat the operation each time the value set is used.  \\n\\nIf the expansion is too large (at the discretion of the server), the server MAY return an error (OperationOutcome with code too-costly). Clients can work through large flat expansions in a set of pages (partial views of the full expansion) instead of just getting the full expansion in a single exchange by using offset and count parameters, or use the count parameter to request a subset of the expansion for limited purposes. Servers are not obliged to support paging, but if they do, SHALL support both the offset and count parameters. Hierarchical expansions are not subject to paging and servers simply return the entire expansion.  \\n\\nDifferent servers may return different results from expanding a value set for the following reasons:  \\n\\n* The underlying code systems are different (e.g. different versions, possibly with different defined behavior) \\n* The server optimizes filter includes differently, such as sorting by code frequency \\n* Servers introduce arbitrary groups to assist a user to navigate the lists based either on extensions in the definition, or additional knowledge available to the server\\n\\nWhen a server cannot correctly expand a value set because it does not fully understand the code systems (e.g. it has the wrong version, or incomplete definitions) then it SHALL return an error. If the value set itself is unbounded due to the inclusion of post-coordinated value sets (e.g. SNOMED CT, UCUM), then the extension [http://hl7.org/fhir/StructureDefinition/valueset-unclosed](extension-valueset-unclosed.html) can be used to indicate that the expansion is incomplete\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://hl7.org/fhir\"
        },
        {
          \"system\": \"email\",
          \"value\": \"fhir@lists.hl7.org\"
        }
      ]
    }
  ],
  \"date\": \"2019-11-01T09:29:23+11:00\",
  \"description\": \"The definition of a value set is used to create a simple collection of codes suitable for use for data entry or validation. \\n\\nIf the operation is not called at the instance level, one of the in parameters url, context or valueSet must be provided.  An expanded value set will be returned, or an OperationOutcome with an error message.\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 5
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"normative\"
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-normative-version\",
      \"valueCode\": \"4.0.1\"
    }
  ],
  \"id\": \"ValueSet-expand\",
  \"instance\": true,
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2019-11-01T09:29:23.356+11:00\"
  },
  \"name\": \"Value Set Expansion\",
  \"parameter\": [
    {
      \"documentation\": \"A canonical reference to a value set. The server must know the value set (e.g. it is defined explicitly in the server's value sets, or it is defined implicitly by some code system known to the server\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"url\",
      \"type\": \"uri\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The value set is provided directly as part of the request. Servers may choose not to accept value sets in this fashion\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"valueSet\",
      \"type\": \"ValueSet\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The identifier that is used to identify a specific version of the value set to be used when generating the expansion. This is an arbitrary value managed by the value set author and is not expected to be globally unique. For example, it might be a timestamp (e.g. yyyymmdd) if a managed version is not available.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"valueSetVersion\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The context of the value set, so that the server can resolve this to a value set to expand. The recommended format for this URI is [Structure Definition URL]#[name or path into structure definition] e.g. http://hl7.org/fhir/StructureDefinition/observation-hspc-height-hspcheight#Observation.interpretation. Other forms may be used but are not defined. This form is only usable if the terminology server also has access to the conformance registry that the server is using, but can be used to delegate the mapping from an application context to a binding at run-time\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"context\",
      \"type\": \"uri\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"If a context is provided, a context direction may also be provided. Valid values are: \\n\\n* 'incoming': the codes a client can use for PUT/POST operations,  and \\n* 'outgoing', the codes a client might receive from the server.\\n\\nThe purpose is to inform the server whether to use the value set associated with the context for reading or writing purposes (note: for most elements, this is the same value set, but there are a few elements where the reading and writing value sets are different)\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"contextDirection\",
      \"type\": \"code\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"A text filter that is applied to restrict the codes that are returned (this is useful in a UI context). The interpretation of this is delegated to the server in order to allow to determine the most optimal search approach for the context. The server can document the way this parameter works in [TerminologyCapabilities](terminologycapabilities.html)..expansion.textFilter. Typical usage of this parameter includes functionality like:\\n\\n* using left matching e.g. \\\"acut ast\\\"\\n* allowing for wild cards such as %, &, ?\\n* searching on definition as well as display(s)\\n* allowing for search conditions (and / or / exclusions)\\n\\nText Search engines such as Lucene or Solr, long with their considerable functionality, might also be used. The optional text search might also be code system specific, and servers might have different implementations for different code systems\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"filter\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The date for which the expansion should be generated.  if a date is provided, it means that the server should use the value set / code system definitions as they were on the given date, or return an error if this is not possible.  Normally, the date is the current conditions (which is the default value) but under some circumstances, systems need to generate an expansion as it would have been in the past. A typical example of this would be where code selection is constrained to the set of codes that were available when the patient was treated, not when the record is being edited. Note that which date is appropriate is a matter for implementation policy.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"date\",
      \"type\": \"dateTime\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Paging support - where to start if a subset is desired (default = 0). Offset is number of records (not number of pages)\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"offset\",
      \"type\": \"integer\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Paging support - how many codes should be provided in a partial page view. Paging only applies to flat expansions - servers ignore paging if the expansion is not flat.  If count = 0, the client is asking how large the expansion is. Servers SHOULD honor this request for hierarchical expansions as well, and simply return the overall count\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"count\",
      \"type\": \"integer\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Controls whether concept designations are to be included or excluded in value set expansions\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"includeDesignations\",
      \"type\": \"boolean\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"A [token](search.html#token) that specifies a system+code that is either a use or a language. Designations that match by language or use are included in the expansion. If no designation is specified, it is at the server discretion which designations to return\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"designation\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Controls whether the value set definition is included or excluded in value set expansions\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"includeDefinition\",
      \"type\": \"boolean\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Controls whether inactive concepts are included or excluded in value set expansions. Note that if the value set explicitly specifies that inactive codes are included, this parameter can still remove them from a specific expansion, but this parameter cannot include them if the value set excludes them\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"activeOnly\",
      \"type\": \"boolean\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Controls whether or not the value set expansion nests codes or not (i.e. ValueSet.expansion.contains.contains)\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"excludeNested\",
      \"type\": \"boolean\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Controls whether or not the value set expansion is assembled for a user interface use or not. Value sets intended for User Interface might include ['abstract' codes](codesystem.html#status) or have nested contains with items with no code or abstract = true, with the sole purpose of helping a user navigate through the list efficiently, where as a value set not generated for UI use might be flat, and only contain the selectable codes in the value set. The exact implications of 'for UI' depend on the code system, and what properties it exposes for a terminology server to use. In the FHIR Specification itself, the value set expansions are generated with excludeNotForUI = false, and the expansions used when generated schema / code etc, or performing validation, are all excludeNotForUI = true.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"excludeNotForUI\",
      \"type\": \"boolean\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Controls whether or not the value set expansion includes post coordinated codes\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"excludePostCoordinated\",
      \"type\": \"boolean\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Specifies the language to be used for description in the expansions i.e. the language to be used for ValueSet.expansion.contains.display\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"displayLanguage\",
      \"type\": \"code\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Code system, or a particular version of a code system to be excluded from the value set expansion. The format is the same as a canonical URL: [system]|[version] - e.g. http://loinc.org|2.56\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"exclude-system\",
      \"type\": \"canonical\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Specifies a version to use for a system, if the value set does not specify which one to use. The format is the same as a canonical URL: [system]|[version] - e.g. http://loinc.org|2.56\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"system-version\",
      \"type\": \"canonical\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Edge Case: Specifies a version to use for a system. If a value set specifies a different version, an error is returned instead of the expansion. The format is the same as a canonical URL: [system]|[version] - e.g. http://loinc.org|2.56\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"check-system-version\",
      \"type\": \"canonical\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Edge Case: Specifies a version to use for a system. This parameter overrides any specified version in the value set (and any it depends on). The format is the same as a canonical URL: [system]|[version] - e.g. http://loinc.org|2.56. Note that this has obvious safety issues, in that it may result in a value set expansion giving a different list of codes that is both wrong and unsafe, and implementers should only use this capability reluctantly. It primarily exists to deal with situations where specifications have fallen into decay as time passes. If the value is override, the version used SHALL explicitly be represented in the expansion parameters\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"force-system-version\",
      \"type\": \"canonical\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The result of the expansion. Servers generating expansions SHOULD ensure that all the parameters that affect the contents of the expansion are recorded in the ValueSet.expansion.parameter list\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"return\",
      \"type\": \"ValueSet\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"ValueSet\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/ValueSet-expand\",
  \"version\": \"4.0.1\"
}"))
(define (expand-operation handler)
  (define code "expand")
  (list (operation-entry 'type code "ValueSet" handler)
        (operation-entry 'instance code "ValueSet" handler)))
(define find-matches-definition
  (string->jsexpr
   "{
  \"code\": \"find-matches\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://hl7.org/fhir\"
        },
        {
          \"system\": \"email\",
          \"value\": \"fhir@lists.hl7.org\"
        }
      ]
    }
  ],
  \"date\": \"2019-11-01T09:29:23+11:00\",
  \"description\": \"Given a set of properties (and text), return one or more possible matching codes\\n\\nThis operation takes a set of properties, and examines the code system looking for codes in the code system that match a set of known properties. \\n\\nWhen looking for matches, there are 3 possible types of match:\\n* a complete match - a code that represents all the provided properties correctly\\n* a partial match - a code that represents some of the provided properties correctly, and not others \\n* a possible match - a code that may represent the provided properties closely, but may capture less or more precise information for some of the properties\\n\\nThe $find-matches operation can be called in one of 2 modes:\\n* By a human, looking for the best match for a set of properties. In this mode, the server returns a list of complete, possible or partial matches (possibly with comments), so that the user can choose (or not) the most appropriate code\\n* By a machine (typically in a system interface performing a transformation). In this mode, the server returns only a list of complete and partial matches, but no possible matches. The machine can choose a code from the list (or not) based on what properties are not coded\\n\\nThese modes are differentiated by the 'exact' parameter, so the client can indicate whether it only wants exact matches (including partial matches) or whether potential matches based on text matching are desired\\n \\nThe find-matches operation is still preliminary. The interface can be expected to change as more experience is gained from implementations.\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 0
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"trial-use\"
    }
  ],
  \"id\": \"CodeSystem-find-matches\",
  \"instance\": true,
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2019-11-01T09:29:23.356+11:00\"
  },
  \"name\": \"Finding codes based on supplied properties\",
  \"parameter\": [
    {
      \"documentation\": \"The system in which composition is to be performed. This must be provided unless the operation is invoked on a code system instance\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"system\",
      \"type\": \"uri\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The version of the system for the inferencing to be performed\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"version\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"One or more properties that contain information to be composed into the code\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"property\",
      \"part\": [
        {
          \"documentation\": \"Identifies the property provided\",
          \"max\": \"1\",
          \"min\": 1,
          \"name\": \"code\",
          \"type\": \"code\",
          \"use\": \"in\"
        },
        {
          \"documentation\": \"The value of the property provided\",
          \"extension\": [
            {
              \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
              \"valueUri\": \"code\"
            },
            {
              \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
              \"valueUri\": \"Coding\"
            },
            {
              \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
              \"valueUri\": \"string\"
            },
            {
              \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
              \"valueUri\": \"integer\"
            },
            {
              \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
              \"valueUri\": \"boolean\"
            },
            {
              \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
              \"valueUri\": \"dateTime\"
            }
          ],
          \"max\": \"1\",
          \"min\": 0,
          \"name\": \"value\",
          \"type\": \"Element\",
          \"use\": \"in\"
        },
        {
          \"documentation\": \"Nested Properties (mainly used for SNOMED CT composition, for relationship Groups)\",
          \"max\": \"*\",
          \"min\": 0,
          \"name\": \"subproperty\",
          \"part\": [
            {
              \"documentation\": \"Identifies the sub-property provided\",
              \"max\": \"1\",
              \"min\": 1,
              \"name\": \"code\",
              \"type\": \"code\",
              \"use\": \"in\"
            },
            {
              \"documentation\": \"The value of the sub-property provided\",
              \"extension\": [
                {
                  \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                  \"valueUri\": \"code\"
                },
                {
                  \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                  \"valueUri\": \"Coding\"
                },
                {
                  \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                  \"valueUri\": \"string\"
                },
                {
                  \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                  \"valueUri\": \"integer\"
                },
                {
                  \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                  \"valueUri\": \"boolean\"
                },
                {
                  \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                  \"valueUri\": \"dateTime\"
                }
              ],
              \"max\": \"1\",
              \"min\": 1,
              \"name\": \"value\",
              \"type\": \"Element\",
              \"use\": \"in\"
            }
          ],
          \"use\": \"in\"
        }
      ],
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Whether the operation is being used by a human ('false'), or a machine ('true'). If the operation is being used by a human, the terminology server can return a list of possible matches, with commentary. For a machine, the server returns complete or partial matches, not possible matches. The default value is 'false'\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"exact\",
      \"type\": \"boolean\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Post-coordinated expressions are allowed to be returned in the matching codes (mainly for SNOMED CT). Default = false\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"compositional\",
      \"type\": \"boolean\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Concepts returned by the server as a result of the inferencing operation\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"match\",
      \"part\": [
        {
          \"documentation\": \"A code that matches the properties provided\",
          \"max\": \"1\",
          \"min\": 1,
          \"name\": \"code\",
          \"type\": \"Coding\",
          \"use\": \"out\"
        },
        {
          \"documentation\": \"One or more properties that contain properties that could not be matched into the code\",
          \"max\": \"*\",
          \"min\": 0,
          \"name\": \"unmatched\",
          \"part\": [
            {
              \"documentation\": \"Identifies the property provided\",
              \"max\": \"1\",
              \"min\": 1,
              \"name\": \"code\",
              \"type\": \"code\",
              \"use\": \"out\"
            },
            {
              \"documentation\": \"The value of the property provided\",
              \"extension\": [
                {
                  \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                  \"valueUri\": \"code\"
                },
                {
                  \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                  \"valueUri\": \"Coding\"
                },
                {
                  \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                  \"valueUri\": \"string\"
                },
                {
                  \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                  \"valueUri\": \"integer\"
                },
                {
                  \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                  \"valueUri\": \"boolean\"
                },
                {
                  \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                  \"valueUri\": \"dateTime\"
                }
              ],
              \"max\": \"1\",
              \"min\": 1,
              \"name\": \"value\",
              \"type\": \"Element\",
              \"use\": \"out\"
            },
            {
              \"documentation\": \"Nested Properties (mainly used for SNOMED CT composition, for relationship Groups)\",
              \"max\": \"*\",
              \"min\": 0,
              \"name\": \"property\",
              \"part\": [
                {
                  \"documentation\": \"Identifies the sub-property provided\",
                  \"max\": \"1\",
                  \"min\": 1,
                  \"name\": \"code\",
                  \"type\": \"code\",
                  \"use\": \"out\"
                },
                {
                  \"documentation\": \"The value of the sub-property provided\",
                  \"extension\": [
                    {
                      \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                      \"valueUri\": \"code\"
                    },
                    {
                      \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                      \"valueUri\": \"Coding\"
                    },
                    {
                      \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                      \"valueUri\": \"string\"
                    },
                    {
                      \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                      \"valueUri\": \"integer\"
                    },
                    {
                      \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                      \"valueUri\": \"boolean\"
                    },
                    {
                      \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                      \"valueUri\": \"dateTime\"
                    }
                  ],
                  \"max\": \"1\",
                  \"min\": 1,
                  \"name\": \"value\",
                  \"type\": \"Element\",
                  \"use\": \"out\"
                }
              ],
              \"use\": \"out\"
            }
          ],
          \"use\": \"out\"
        },
        {
          \"documentation\": \"Information about the quality of the match, if operation is for a human\",
          \"max\": \"1\",
          \"min\": 0,
          \"name\": \"comment\",
          \"type\": \"string\",
          \"use\": \"out\"
        }
      ],
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"CodeSystem\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/CodeSystem-find-matches\",
  \"version\": \"4.0.1\"
}"))
(define (find-matches-operation handler)
  (define code "find-matches")
  (list (operation-entry 'type code "CodeSystem" handler)
        (operation-entry 'instance code "CodeSystem" handler)))
(define find-definition
  (string->jsexpr
   "{
  \"code\": \"find\",
  \"comment\": \"Note that servers may support searching by a functional list, and not support this operation that allows clients to find the list directly\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://hl7.org/fhir\"
        },
        {
          \"system\": \"email\",
          \"value\": \"fhir@lists.hl7.org\"
        }
      ]
    }
  ],
  \"date\": \"2019-11-01T09:29:23+11:00\",
  \"description\": \"This operation allows a client to find an identified list for a particular function by its function. The operation takes two parameters, the identity of a patient, and the name of a functional list.     The list of defined functional lists can be found at [Current Resource Lists](lifecycle.html#lists). Applications are not required to support all the lists, and may define additional lists of their own.   If the system is able to locate a list that serves the identified purpose, it returns it as the body of the response with a 200 OK status. If the resource cannot be located, the server returns a 404 not found (optionally with an OperationOutcome resource)\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 1
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"trial-use\"
    }
  ],
  \"id\": \"List-find\",
  \"instance\": false,
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2019-11-01T09:29:23.356+11:00\"
  },
  \"name\": \"Find a functional list\",
  \"parameter\": [
    {
      \"documentation\": \"The id of a patient resource located on the server on which this operation is executed\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"patient\",
      \"type\": \"id\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The code for the functional list that is being found\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"name\",
      \"type\": \"code\",
      \"use\": \"in\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"List\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/List-find\",
  \"version\": \"4.0.1\"
}"))
(define (find-operation handler)
  (define code "find")
  (list (operation-entry 'type code "List" handler)))
(define graph-definition
  (string->jsexpr
   "{
  \"code\": \"graph\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://hl7.org/fhir\"
        },
        {
          \"system\": \"email\",
          \"value\": \"fhir@lists.hl7.org\"
        }
      ]
    }
  ],
  \"date\": \"2019-11-01T09:29:23+11:00\",
  \"description\": \"Return an entire graph of resources based on a [GraphDefinition](graphdefinition.html). The operation is invoked on a specific instance of a resource, and the graph definition tells the server what other resources to return in the same packaage\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 1
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"trial-use\"
    }
  ],
  \"id\": \"Resource-graph\",
  \"instance\": true,
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2019-11-01T09:29:23.356+11:00\"
  },
  \"name\": \"Return a graph of resources\",
  \"parameter\": [
    {
      \"documentation\": \"Servers MAY choose to allow any graph definition to be specified, but MAY require that the client choose a graph definition from a specific list of known supported definitions. The server is not required to support a formal definition of the graph on the end point\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"graph\",
      \"type\": \"uri\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The set of resources that were in the graph based on the provided definition\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"result\",
      \"type\": \"Bundle\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"Resource\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Resource-graph\",
  \"version\": \"4.0.1\"
}"))
(define (graph-operation handler)
  (define code "graph")
  (list (operation-entry 'instance code "Resource" handler)))
(define graphql-definition
  (string->jsexpr
   "{
  \"code\": \"graphql\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://hl7.org/fhir\"
        },
        {
          \"system\": \"email\",
          \"value\": \"fhir@lists.hl7.org\"
        }
      ]
    }
  ],
  \"date\": \"2019-11-01T09:29:23+11:00\",
  \"description\": \"Execute a graphql statement on a since resource or against the entire system. See the [Using GraphQL with FHIR](graphql.html) page for further details.\\n\\nFor the purposes of graphQL compatibility, this operation can also be invoked using a POST with the graphQL as the body, or a JSON body (see [graphQL spec](http://graphql.org/) for details)\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 1
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"trial-use\"
    }
  ],
  \"id\": \"Resource-graphql\",
  \"instance\": true,
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2019-11-01T09:29:23.356+11:00\"
  },
  \"name\": \"Execute a graphql statement\",
  \"parameter\": [
    {
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"query\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The content is always returned as application/json; this SHOULD be specified in the Accept header\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"result\",
      \"type\": \"Binary\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"Resource\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": true,
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Resource-graphql\",
  \"version\": \"4.0.1\"
}"))
(define (graphql-operation handler)
  (define code "graphql")
  (list (operation-entry 'system code #f handler)
        (operation-entry 'instance code "Resource" handler)))
(define implements-definition
  (string->jsexpr
   "{
  \"code\": \"implements\",
  \"comment\": \"The operation does not perform a full conformance check; in particular it does not check that the profiles align. It merely checks that the behaviors the client wishes to use are provided    Technically, this operation is implemented as follows:   \\n\\n* The server's capability statement must have an entry for each resource in the client's capability statement    \\n* The server's resource support must have matching flags for updateCreate, conditionalCreate, conditionalRead, conditionalUpdate, conditionalDelete, searchInclude, searchRevInclude   \\n* The server's capability statement must have a matching interaction for each interaction in the client capability statement (whether or not it is on a resource)   \\n* The server's capability statement must have a search parameter with matching name and definition for any search parameters in the client capability statement   \\n* The server must have an operation definition with a matching reference for any operations in the client capability statement   \\n\\nIf the capability statements match by these rules, then the return value is a 200 OK with an operation outcome that contains no issues with severity >= error. If the capability statement doesn't match, the return value is a 4xx error, with an OperationOutcome with at least one issue with severity >= error\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://hl7.org/fhir\"
        },
        {
          \"system\": \"email\",
          \"value\": \"fhir@lists.hl7.org\"
        }
      ]
    }
  ],
  \"date\": \"2019-11-01T09:29:23+11:00\",
  \"description\": \"This operation asks the server to check that it implements all the resources, interactions, search parameters, and operations that the client provides in its capability statement. The client provides its capability statement inline, or by referring the server to the canonical URL of its capability statement\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 5
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"trial-use\"
    }
  ],
  \"id\": \"CapabilityStatement-implements\",
  \"instance\": true,
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2019-11-01T09:29:23.356+11:00\"
  },
  \"name\": \"Test if a server implements a client's required operations\",
  \"parameter\": [
    {
      \"documentation\": \"A canonical reference to the server capability statement - use this if the implements is not invoked on an instance (or on the /metadata end-point)\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"server\",
      \"type\": \"canonical\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"A canonical reference to the client capability statement - use this if the implements is not invoked on an instance (or on the /metadata end-point)\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"client\",
      \"type\": \"canonical\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The client capability statement, provided inline\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"resource\",
      \"type\": \"CapabilityStatement\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Outcome of the CapabilityStatement test\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"return\",
      \"type\": \"OperationOutcome\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"CapabilityStatement\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/CapabilityStatement-implements\",
  \"version\": \"4.0.1\"
}"))
(define (implements-operation handler)
  (define code "implements")
  (list (operation-entry 'type code "CapabilityStatement" handler)
        (operation-entry 'instance code "CapabilityStatement" handler)))
(define lastn-definition
  (string->jsexpr
   "{
  \"code\": \"lastn\",
  \"comment\": \"The key differences between this query operation and simply searching Observation using the combination of `_count` and `_sort` parameters are:\\r\\r* The *lastn* query returns **only** the last N resource grouped by code.  Using the _count query method doesn't restrict the total matches so you may need to page through several \\\"A\\\" Observations  before getting to Observation \\\"B\\\".\\r* The server is responsible for grouping the observations by codes.  This frees the client from needing to determine which codes she should ask for.\\r\\rThis operation cannot be performed on observations that the user is not authorized to see.  It is assumed that the server has identified and secured the context appropriately, and can either associate the authorization context with a single patient, or determine whether the context has the rights to the nominated patient, if there is one. If there is no nominated patient (e.g. the operation is invoked at the system level) and the context is not associated with a single patient record, then the server should return an error. Specifying the relationship between the context, a user and patient records is outside the scope of this specification.\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://hl7.org/fhir\"
        },
        {
          \"system\": \"email\",
          \"value\": \"fhir@lists.hl7.org\"
        }
      ]
    }
  ],
  \"date\": \"2019-11-01T09:29:23+11:00\",
  \"description\": \"The *lastn query* meets the common need for searching for the most recent or last n=number of observations for a subject. For example, retrieving the last 5 temperatures for a patient to view trends or fetching the most recent laboratory results or vitals signs. To ask a server to return the last n=number of observations, the *lastn* query uses the [normal search parameters](observation.html#search) defined for the Observation resource.  However, rather than their normal use, they are interpreted as inputs - i.e.. instead of requiring that the resources literally contain the search parameters, they are passed to a server algorithm of some kind that uses them to determine the most appropriate matches.\\n\\nThe request for a lastn query SHALL include:\\n\\n* A `$lastn` operation parameter\\n*  A subject using either the `patient` or `subject`  search parameter\\n*  A `category` parameter and/or a search parameter that contains a code element in its FHIRpath expression.  ( e.g., `code` or `code-value-concept`)\\n\\nThe request for a lastn query MAY include:\\n\\n* Other Observation search parameters and modifiers\\n\\nThe response from a lastn query is a set of observations:\\n\\n*  Filtered by additional parameters\\n   * If not explicitly filtered by status then will include statuses of 'entered-in-error'\\n* 'GROUP BY' `Observation.code`\\n   * Codes SHALL be considered equivalent if the `coding.value` *and* `coding.system` are the same.\\n   * Text only codes SHALL be treated and grouped based on the text.\\n   * For codes with translations (multiple codings), the code translations are assumed to be equal and the grouping by code SHALL follow the transitive property of equality.\\n\\nfor example:\\n\\n|Observation.code for observation a|Observation.code for observation b|Observation.code for observation c|number of groups [codes/text in each group]|    \\n|---|---|---|---|     \\n|a|b|c | 3 [a],[b],[c]|    \\n|a|b|a,c | 2 [a.c],[b]|     \\n|a|b|a,b | 1 [a,b]|    \\n|'textM'|'Text'|'t e x t'|3 ['text'],['Text'],['t e x t']|\\n\\n* Sorted from most recent to the oldest\\n* Limited to the number of requested responses per group specified by the optional *max* query parameter\\n  * In case of a tie - when the effective times for >1 Observations are equal - both will be returned.  Therefore, more Observations may be returned than is specified in *max*.  For example, 4 Observations instead of 3 if the 3rd and 4th most recent observation had the same effective time.\\n* If no maximum number is given then only the most recent Observation in each group is returned.\\n\\nThe set of returned observations should represent distinct real world observations and not the same observation with changes in status or versions. If there are no matches, the *lastn* query SHALL return an empty search set with no error, but may include an operation outcome with further advice.\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 3
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"trial-use\"
    }
  ],
  \"id\": \"Observation-lastn\",
  \"instance\": false,
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2019-11-01T09:29:23.356+11:00\"
  },
  \"name\": \"Last N Observations Query\",
  \"parameter\": [
    {
      \"documentation\": \"`max` is  an optional input parameter to the *lastn* query operation.  It is used to specify the maximum number of Observations to return from each group. For example for the query \\\"Fetch the last 3 results for all vitals for a patient\\\" `max` = 3.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"max\",
      \"type\": \"positiveInt\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The set of most recent N Observations that match the *lastn* query search criteria.\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"return\",
      \"type\": \"Bundle\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"Observation\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Observation-lastn\",
  \"version\": \"4.0.1\"
}"))
(define (lastn-operation handler)
  (define code "lastn")
  (list (operation-entry 'type code "Observation" handler)))
(define lookup-definition
  (string->jsexpr
   "{
  \"code\": \"lookup\",
  \"comment\": \"Note that the $lookup operation is more than just a code system search  - the server finds the concept, and gathers the return information from the underlying code system definitions.\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://hl7.org/fhir\"
        },
        {
          \"system\": \"email\",
          \"value\": \"fhir@lists.hl7.org\"
        }
      ]
    }
  ],
  \"date\": \"2019-11-01T09:29:23+11:00\",
  \"description\": \"Given a code/system, or a Coding, get additional details about the concept, including definition, status, designations, and properties. One of the products of this operation is a full decomposition of a code from a structured terminology.\\n\\nWhen invoking this operation, a client SHALL provide both a system and a code, either using the system+code parameters, or in the coding parameter. Other parameters are optional\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 5
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"normative\"
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-normative-version\",
      \"valueCode\": \"4.0.1\"
    }
  ],
  \"id\": \"CodeSystem-lookup\",
  \"instance\": false,
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2019-11-01T09:29:23.356+11:00\"
  },
  \"name\": \"Concept Look Up & Decomposition\",
  \"parameter\": [
    {
      \"documentation\": \"The code that is to be located. If a code is provided, a system must be provided\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"code\",
      \"type\": \"code\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The system for the code that is to be located\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"system\",
      \"type\": \"uri\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The version of the system, if one was provided in the source data\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"version\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"A coding to look up\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"coding\",
      \"type\": \"Coding\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The date for which the information should be returned. Normally, this is the current conditions (which is the default value) but under some circumstances, systems need to acccess this information as it would have been in the past. A typical example of this would be where code selection is constrained to the set of codes that were available when the patient was treated, not when the record is being edited. Note that which date is appropriate is a matter for implementation policy.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"date\",
      \"type\": \"dateTime\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The requested language for display (see $expand.displayLanguage)\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"displayLanguage\",
      \"type\": \"code\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"A property that the client wishes to be returned in the output. If no properties are specified, the server chooses what to return. The following properties are defined for all code systems: url, name, version (code system info) and code information: display, definition, designation, parent and child, and for designations, lang.X where X is a designation language code. Some of the properties are returned explicit in named parameters (when the names match), and the rest (except for lang.X) in the property parameter group\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"property\",
      \"type\": \"code\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"A display name for the code system\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"name\",
      \"type\": \"string\",
      \"use\": \"out\"
    },
    {
      \"documentation\": \"The version that these details are based on\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"version\",
      \"type\": \"string\",
      \"use\": \"out\"
    },
    {
      \"documentation\": \"The preferred display for this concept\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"display\",
      \"type\": \"string\",
      \"use\": \"out\"
    },
    {
      \"documentation\": \"Additional representations for this concept\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"designation\",
      \"part\": [
        {
          \"documentation\": \"The language this designation is defined for\",
          \"max\": \"1\",
          \"min\": 0,
          \"name\": \"language\",
          \"type\": \"code\",
          \"use\": \"out\"
        },
        {
          \"documentation\": \"A code that details how this designation would be used\",
          \"max\": \"1\",
          \"min\": 0,
          \"name\": \"use\",
          \"type\": \"Coding\",
          \"use\": \"out\"
        },
        {
          \"documentation\": \"The text value for this designation\",
          \"max\": \"1\",
          \"min\": 1,
          \"name\": \"value\",
          \"type\": \"string\",
          \"use\": \"out\"
        }
      ],
      \"use\": \"out\"
    },
    {
      \"documentation\": \"One or more properties that contain additional information about the code, including status. For complex terminologies (e.g. SNOMED CT, LOINC, medications), these properties serve to decompose the code\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"property\",
      \"part\": [
        {
          \"documentation\": \"Identifies the property returned\",
          \"max\": \"1\",
          \"min\": 1,
          \"name\": \"code\",
          \"type\": \"code\",
          \"use\": \"out\"
        },
        {
          \"documentation\": \"The value of the property returned\",
          \"extension\": [
            {
              \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
              \"valueUri\": \"code\"
            },
            {
              \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
              \"valueUri\": \"Coding\"
            },
            {
              \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
              \"valueUri\": \"string\"
            },
            {
              \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
              \"valueUri\": \"integer\"
            },
            {
              \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
              \"valueUri\": \"boolean\"
            },
            {
              \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
              \"valueUri\": \"dateTime\"
            },
            {
              \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
              \"valueUri\": \"decimal\"
            }
          ],
          \"max\": \"1\",
          \"min\": 0,
          \"name\": \"value\",
          \"type\": \"Element\",
          \"use\": \"out\"
        },
        {
          \"documentation\": \"Human Readable representation of the property value (e.g. display for a code)\",
          \"max\": \"1\",
          \"min\": 0,
          \"name\": \"description\",
          \"type\": \"string\",
          \"use\": \"out\"
        },
        {
          \"documentation\": \"Nested Properties (mainly used for SNOMED CT decomposition, for relationship Groups)\",
          \"max\": \"*\",
          \"min\": 0,
          \"name\": \"subproperty\",
          \"part\": [
            {
              \"documentation\": \"Identifies the sub-property returned\",
              \"max\": \"1\",
              \"min\": 1,
              \"name\": \"code\",
              \"type\": \"code\",
              \"use\": \"out\"
            },
            {
              \"documentation\": \"The value of the sub-property returned\",
              \"extension\": [
                {
                  \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                  \"valueUri\": \"code\"
                },
                {
                  \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                  \"valueUri\": \"Coding\"
                },
                {
                  \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                  \"valueUri\": \"string\"
                },
                {
                  \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                  \"valueUri\": \"integer\"
                },
                {
                  \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                  \"valueUri\": \"boolean\"
                },
                {
                  \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                  \"valueUri\": \"dateTime\"
                },
                {
                  \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                  \"valueUri\": \"decimal\"
                }
              ],
              \"max\": \"1\",
              \"min\": 1,
              \"name\": \"value\",
              \"type\": \"Element\",
              \"use\": \"out\"
            },
            {
              \"documentation\": \"Human Readable representation of the property value (e.g. display for a code)\",
              \"max\": \"1\",
              \"min\": 0,
              \"name\": \"description\",
              \"type\": \"string\",
              \"use\": \"out\"
            }
          ],
          \"use\": \"out\"
        }
      ],
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"CodeSystem\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/CodeSystem-lookup\",
  \"version\": \"4.0.1\"
}"))
(define (lookup-operation handler)
  (define code "lookup")
  (list (operation-entry 'type code "CodeSystem" handler)))
(define match-definition
  (string->jsexpr
   "{
  \"code\": \"match\",
  \"comment\": \"The response from an \\\"mpi\\\" query is a bundle containing patient records, ordered from most likely to least likely. If there are no patient matches, the MPI SHALL return an empty search set with no error, but may include an operation outcome with further advice regarding patient selection. All patient records SHALL have a search score from 0 to 1, where 1 is the most certain match, along with an extension \\\"[match-grade](extension-match-grade.html)\\\" that indicates the MPI's position on the match quality.\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://hl7.org/fhir\"
        },
        {
          \"system\": \"email\",
          \"value\": \"fhir@lists.hl7.org\"
        }
      ]
    }
  ],
  \"date\": \"2019-11-01T09:29:23+11:00\",
  \"description\": \"A Master Patient Index ([MPI](http://en.wikipedia.org/wiki/Enterprise_master_patient_index) ) is a service used to manage patient identification in a context where multiple patient databases exist. Healthcare applications and middleware use the MPI to match patients between the databases, and to store new patient details as they are encountered. MPIs are highly specialized applications, often tailored extensively to the institution's particular mix of patients. MPIs can also be run on a regional and national basis.  \\n\\nTo ask an MPI to match a patient, clients use the \\\"$match\\\" operation, which accepts a patient resource which may be only partially complete. The data provided is interpreted as an MPI input and processed by an algorithm of some kind that uses the data to determine the most appropriate matches in the patient set.  Note that different MPI matching algorithms have different required inputs. The generic $match operation does not specify any particular algorithm, nor a minimum set of information that must be provided when asking for an MPI match operation to be performed, but many implementations will have a set of minimum information, which may be declared in their definition of the $match operation by specifying a profile on the resource parameter, indicating which properties are required in the search.  The patient resource submitted to the operation does not have to be complete, nor does it need to pass validation (i.e. mandatory fields don't need to be populated), but it does have to be a valid instance, as it is used as the reference data to match against.\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 5
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"trial-use\"
    }
  ],
  \"id\": \"Patient-match\",
  \"instance\": false,
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2019-11-01T09:29:23.356+11:00\"
  },
  \"name\": \"Find patient matches using MPI based logic\",
  \"parameter\": [
    {
      \"documentation\": \"Use this to provide an entire set of patient details for the MPI to match against (e.g. POST a patient record to Patient/$match).\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"resource\",
      \"type\": \"Resource\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"If there are multiple potential matches, then the match should not return the results with this flag set to true.  When false, the server may return multiple results with each result graded accordingly.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"onlyCertainMatches\",
      \"type\": \"boolean\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The maximum number of records to return. If no value is provided, the server decides how many matches to return. Note that clients should be careful when using this, as it may prevent probable - and valid - matches from being returned\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"count\",
      \"type\": \"integer\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"A bundle contain a set of Patient records that represent possible matches, optionally it may also contain an OperationOutcome with further information about the search results (such as warnings or information messages, such as a count of records that were close but eliminated)  If the operation was unsuccessful, then an OperationOutcome may be returned along with a BadRequest status Code (e.g. security issue, or insufficient properties in patient fragment - check against profile)\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"return\",
      \"type\": \"Bundle\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"Patient\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Patient-match\",
  \"version\": \"4.0.1\"
}"))
(define (match-operation handler)
  (define code "match")
  (list (operation-entry 'type code "Patient" handler)))
(define meta-add-definition
  (string->jsexpr
   "{
  \"code\": \"meta-add\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://hl7.org/fhir\"
        },
        {
          \"system\": \"email\",
          \"value\": \"fhir@lists.hl7.org\"
        }
      ]
    }
  ],
  \"date\": \"2019-11-01T09:29:23+11:00\",
  \"description\": \"This operation takes a meta, and adds the profiles, tags, and security labels found in it to the nominated resource\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 3
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"trial-use\"
    }
  ],
  \"id\": \"Resource-meta-add\",
  \"instance\": true,
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2019-11-01T09:29:23.356+11:00\"
  },
  \"name\": \"Add profiles, tags, and security labels to a resource\",
  \"parameter\": [
    {
      \"documentation\": \"Profiles, tags, and security labels to add to the existing resource. Note that profiles, tags, and security labels are sets, and duplicates are not created.  The identity of a tag or security label is the system+code. When matching existing tags during adding, version and display are ignored. For profiles, matching is based on the full URL\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"meta\",
      \"type\": \"Meta\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Resulting meta for the resource\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"return\",
      \"type\": \"Meta\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"Resource\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Resource-meta-add\",
  \"version\": \"4.0.1\"
}"))
(define (meta-add-operation handler)
  (define code "meta-add")
  (list (operation-entry 'instance code "Resource" handler)))
(define meta-delete-definition
  (string->jsexpr
   "{
  \"code\": \"meta-delete\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://hl7.org/fhir\"
        },
        {
          \"system\": \"email\",
          \"value\": \"fhir@lists.hl7.org\"
        }
      ]
    }
  ],
  \"date\": \"2019-11-01T09:29:23+11:00\",
  \"description\": \"This operation takes a meta, and deletes the profiles, tags, and security labels found in it from the nominated resource\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 3
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"trial-use\"
    }
  ],
  \"id\": \"Resource-meta-delete\",
  \"instance\": true,
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2019-11-01T09:29:23.356+11:00\"
  },
  \"name\": \"Delete profiles, tags, and security labels for a resource\",
  \"parameter\": [
    {
      \"documentation\": \"Profiles, tags, and security labels to delete from the existing resource. It is not an error if these tags, profiles, and labels do not exist.  The identity of a tag or security label is the system+code. When matching existing tags during deletion, version and display are ignored. For profiles, matching is based on the full URL\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"meta\",
      \"type\": \"Meta\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Resulting meta for the resource\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"return\",
      \"type\": \"Meta\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"Resource\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Resource-meta-delete\",
  \"version\": \"4.0.1\"
}"))
(define (meta-delete-operation handler)
  (define code "meta-delete")
  (list (operation-entry 'instance code "Resource" handler)))
(define meta-definition
  (string->jsexpr
   "{
  \"code\": \"meta\",
  \"comment\": \"At the system and type levels, the $meta operation is used to get a summary of all the labels that are in use across the system. The principal use for this operation is to support search e.g. what tags can be searched for. At these levels, the meta will not contain versionId, lastUpdated etc. Systems are not obligated to implement the operation at this level (and should return a 4xx error if they don't). At the resource and historical entry level, the $meta operation returns the same meta as would be returned by accessing the resource directly. This can be used to allow a system to get access to the meta-information for the resource without accessing the resource itself, e.g. for security reasons\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://hl7.org/fhir\"
        },
        {
          \"system\": \"email\",
          \"value\": \"fhir@lists.hl7.org\"
        }
      ]
    }
  ],
  \"date\": \"2019-11-01T09:29:23+11:00\",
  \"description\": \"This operation retrieves a summary of the profiles, tags, and security labels for the given scope; e.g. for each scope:  \\n\\n* system-wide: a list of all profiles, tags and security labels in use by the system \\n* resource-type level: A list of all profiles, tags, and security labels for the resource type \\n* individual resource level: A list of all profiles, tags, and security labels for the current version of the resource.  Also, as a special case, this operation (and other meta operations) can be performed on a historical version of a resource)\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 3
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"trial-use\"
    }
  ],
  \"id\": \"Resource-meta\",
  \"instance\": true,
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2019-11-01T09:29:23.356+11:00\"
  },
  \"name\": \"Access a list of profiles, tags, and security labels\",
  \"parameter\": [
    {
      \"documentation\": \"The meta returned by the operation\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"return\",
      \"type\": \"Meta\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"Resource\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": true,
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Resource-meta\",
  \"version\": \"4.0.1\"
}"))
(define (meta-operation handler)
  (define code "meta")
  (list (operation-entry 'system code #f handler)
        (operation-entry 'type code "Resource" handler)
        (operation-entry 'instance code "Resource" handler)))
(define populate-definition
  (string->jsexpr
   "{
  \"base\": \"OperationDefinition/Questionnaire-populate\",
  \"code\": \"populate\",
  \"comment\": \"Only implemented for Labs and Medications so far\",
  \"contact\": [
    {
      \"name\": \"System Administrator\",
      \"telecom\": [
        {
          \"system\": \"email\",
          \"value\": \"beep@coyote.acme.com\"
        }
      ]
    }
  ],
  \"date\": \"2015-08-04\",
  \"description\": \"Limited implementation of the Populate Questionnaire implementation\",
  \"id\": \"example\",
  \"instance\": true,
  \"jurisdiction\": [
    {
      \"coding\": [
        {
          \"code\": \"GB\",
          \"display\": \"United Kingdom of Great Britain and Northern Ireland (the)\",
          \"system\": \"urn:iso:std:iso:3166\"
        }
      ]
    }
  ],
  \"kind\": \"operation\",
  \"name\": \"Populate Questionnaire\",
  \"overload\": [
    {
      \"parameterName\": [
        \"subject\",
        \"local\"
      ]
    },
    {
      \"comment\": \"local defaults to false when not passed as a parameter\",
      \"parameterName\": [
        \"subject\"
      ]
    }
  ],
  \"parameter\": [
    {
      \"documentation\": \"The resource that is to be the *QuestionnaireResponse.subject*. The [[[QuestionnaireResponse]]]      instance will reference the provided subject.  In addition, if the *local* parameter is      set to true, server information about the specified subject will be used to populate the      instance.\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"subject\",
      \"type\": \"Reference\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"If the *local* parameter is set to true, server information about the specified subject will be used to populate the instance.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"local\",
      \"type\": \"Reference\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The partially (or fully)-populated set of answers for the specified Questionnaire\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"return\",
      \"type\": \"QuestionnaireResponse\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"Acme Healthcare Services\",
  \"resource\": [
    \"Questionnaire\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"type\": false,
  \"url\": \"http://h7.org/fhir/OperationDefinition/example\",
  \"useContext\": [
    {
      \"code\": {
        \"code\": \"venue\",
        \"display\": \"Clinical Venue\",
        \"system\": \"http://build.fhir.org/codesystem-usage-context-type\"
      },
      \"valueCodeableConcept\": {
        \"coding\": [
          {
            \"code\": \"IMP\",
            \"display\": \"inpatient encounter\",
            \"system\": \"http://terminology.hl7.org/CodeSystem/v3-ActCode\"
          }
        ]
      }
    }
  ],
  \"version\": \"B\"
}"))
(define (populate-operation handler)
  (define code "populate")
  (list (operation-entry 'instance code "Questionnaire" handler)))
(define preferred-id-definition
  (string->jsexpr
   "{
  \"code\": \"preferred-id\",
  \"comment\": \"Servers handle this request by finding the provided identifier in their known naming systems, and returning the requested identifier type ([NamingSystem.uniqueId.type](namingsystem-definitions.html#NamingSystem.uniqueId.type)). If there are multiple possible identifiers of the specified type (e.g. multiple OIDs) the server returns an error.    \\n\\nIf the server wishes, it can also look through all code systems and value sets it knows about when attempting to find the requested identifier\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://hl7.org/fhir\"
        },
        {
          \"system\": \"email\",
          \"value\": \"fhir@lists.hl7.org\"
        }
      ]
    }
  ],
  \"date\": \"2019-11-01T09:29:23+11:00\",
  \"description\": \"This operation returns the preferred identifiers for identifiers, and terminologies. The operation takes 2 parameters:     \\n\\n* a system identifier - either a URI, an OID, or a v2 table 0396 (other) code  \\n* a code for what kind of identifier is desired (URI, OID, v2 table 0396 identifier)    \\n\\nand returns either the requested identifier, or an HTTP errors response with an OperationOutcome because either the provided identifier was not recognized, or the requested identiifer type is not known.    \\n\\nThe principle use of this operation is when converting between v2, CDA and FHIR Identifier/CX/II and CodeableConcepts/C(N/W)E/CD but the operation may also find use when converting metadata such as profiles.\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 1
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"trial-use\"
    }
  ],
  \"id\": \"NamingSystem-preferred-id\",
  \"instance\": false,
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2019-11-01T09:29:23.356+11:00\"
  },
  \"name\": \"Fetch Preferred it\",
  \"parameter\": [
    {
      \"documentation\": \"The server parses the provided id to see what type it is (mary a URI, an OID as a URI, a plain OID, or a v2 table 0396 code). If the server can't tell what type of identifier it is, it can try it as multiple types. It is an error if more than one system matches the provided identifier\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"id\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"binding\": {
        \"strength\": \"required\",
        \"valueSet\": \"http://hl7.org/fhir/ValueSet/namingsystem-identifier-type|4.0.1\"
      },
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"type\",
      \"type\": \"code\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"OIDs are return as plain OIDs (not the URI form).\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"result\",
      \"type\": \"string\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"NamingSystem\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/NamingSystem-preferred-id\",
  \"version\": \"4.0.1\"
}"))
(define (preferred-id-operation handler)
  (define code "preferred-id")
  (list (operation-entry 'type code "NamingSystem" handler)))
(define process-message-definition
  (string->jsexpr
   "{
  \"code\": \"process-message\",
  \"comment\": \"This operation does not use the parameters resource; the parameters \\\"async\\\" and \\\"response-url\\\" always go in the URL, if they are used, and the \\\"content\\\" parameter is always the body of the HTTP message.\\n\\nWhen processing messages, a server may return one of several status codes:\\n* **200 OK**: Indicates that the message has been fully processed.  If an application-level response is expected for the submitted message, that response SHALL be returned as the body of the 200 response.\\n* **202 Accepted**: Indicates that the receiving system has accepted custody of the message\\n* **204 No Content**: Indicates that the message has been fully processed and would normally have had an application-level response, but because of instructions from the sender (e.g. the [messageheader-response-request](extension-messageheader-response-request.html) extension), no response is being provided\\n* **300+**: Indicates that the message was not successfully processed.  The server MAY return an [OperationOutcome](operationoutcome.html) with additional information, and SHOULD do so if the response code is 400 or greater.<br/>\\n    The client SHALL interpret a 4xx response to indicate that there is no point resubmitting the unaltered message, and a 5xx response to indicate an unexpected error occurred on the part of the server, with the implication that it may be appropriate to resubmit the original message. Doing so SHOULD NOT result in a duplicate message response. Repeated failures indicate either a fatal problem with the submission or a problem with the receiving application.\\n\\nThe following rules apply when using $process-message:\\n\\n* The operation only accepts POST transactions - any other HTTP method will result in an HTTP error\\n* The request content type submitted is always [Bundle](bundle.html) with type \\\"message\\\" containing a [Message Header](messageheader.html) resource as the first resource\\n* The response content type returned is always [Bundle](bundle.html) with type \\\"message\\\" containing a [Message Header](messageheader.html) resource as the first resource, or an HTTP error\\n* If the response is an error, the body SHOULD be an [Errors &mp; Warning](operationoutcome.html) resource with full details\\n* The mailbox may be authenticated using standard HTTP authentication methods, including OAuth\\n\\nThe $process-message operation can be used by any HTTP end-point that accepts FHIR messages, not just FHIR RESTful servers.\\n\\nIn order to ensure consistency of processing, the [logical rules regarding processing of Bundle.id and message id](messaging.html#reliable) SHALL be followed when messages are processed using this operation.\\n\\nThe $process-message operation may be used synchronously, or asynchronously.\\n\\nThe following rules apply when using the $process-message operation synchronously:\\n\\n* The URL (http://server/base/$process-message) has no parameters\\n* It is an error if the sender POSTs a message that requires multiple response messages\\n* Servers SHALL accept multiple concurrent message submissions and process them correctly (they are allowed to process them sequentially internally, but multiple concurrent submissions is not an error in its own right)\\n\\nThe following rules apply when using the $process-message operation asynchronously:\\n\\n* The URL has at least one parameter: http://server/base/$process-message?async=true\\n* The server acknowledges the message with a 200 OK with no body, or returns an HTTP error if the message cannot be processed\\n* Accepting the message means that the server has understood the message enough to know where to respond\\n* An [OperationOutcome](operationoutcome.html) SHOULD be returned in either case\\n* By default, the server responds by invoking the $process-message using the sender's stated end-point in the message: POST [MessageHeader.source.endpoint]/$process-messages]\\n* Since the source end-point may be manipulated by message transfer engines, an alternative response address may be specified using the parameter \\\"response-url\\\": http://server/base/$process-message?async=true&amp;response-url=http://server2.com/base/anything.  The endpoint at the specified URL SHALL implement the signature of the $process-message operation (parameter async=true, accept a Bundle, return a 200 OK or an error)\\n* The server submits response messages to the appropriate end-point with the parameter async=true. There is no response message for the response messages\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://hl7.org/fhir\"
        },
        {
          \"system\": \"email\",
          \"value\": \"fhir@lists.hl7.org\"
        }
      ]
    }
  ],
  \"date\": \"2019-11-01T09:29:23+11:00\",
  \"description\": \"This operation accepts a message, processes it according to the definition of the event in the message header, and returns one or more response messages.  \\n\\nIn addition to processing the message event, a server may choose to retain all or some the resources and make them available on a RESTful interface, but is not required to do so.\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 4
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"trial-use\"
    }
  ],
  \"id\": \"MessageHeader-process-message\",
  \"instance\": false,
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2019-11-01T09:29:23.356+11:00\"
  },
  \"name\": \"Process Message\",
  \"parameter\": [
    {
      \"documentation\": \"The message to process (or, if using asynchronous messaging, it may be a response message to accept)\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"content\",
      \"type\": \"Bundle\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"If 'true' the message is processed using the asynchronous messaging pattern\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"async\",
      \"type\": \"boolean\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"A URL to submit response messages to, if asynchronous messaging is being used, and if the MessageHeader.source.endpoint is not the appropriate place to submit responses\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"response-url\",
      \"type\": \"url\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"A response message, if synchronous messaging is being used (mandatory in this case). For asynchronous messaging, there is no return value\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"return\",
      \"type\": \"Bundle\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"MessageHeader\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": true,
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/MessageHeader-process-message\",
  \"version\": \"4.0.1\"
}"))
(define (process-message-operation handler)
  (define code "process-message")
  (list (operation-entry 'system code #f handler)))
(define questionnaire-definition
  (string->jsexpr
   "{
  \"code\": \"questionnaire\",
  \"comment\": \"**Open Issue**: Ideally, extensions should be populated in the generated [Questionnaire](questionnaire.html) that will support taking [QuestionnaireResponse](questionnaireresponse.html) resources generated from the Questionnaire and turning them back into the appropriate resources.\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://hl7.org/fhir\"
        },
        {
          \"system\": \"email\",
          \"value\": \"fhir@lists.hl7.org\"
        }
      ]
    }
  ],
  \"date\": \"2019-11-01T09:29:23+11:00\",
  \"description\": \"Generates a [Questionnaire](questionnaire.html) instance  based on a specified [StructureDefinition](structuredefinition.html), creating questions for each core element or extension element found in the [StructureDefinition](structuredefinition.html).    \\n\\nIf the operation is not called at the instance level, one of the *identifier*, *profile* or *url* 'in' parameters must be provided. If more than one is specified, servers may raise an error or may resolve with the parameter of their choice. If called at the instance level, these parameters will be ignored. The response will contain a [Questionnaire](questionnaire.html) instance based on the specified [StructureDefinition](structuredefinition.html) and/or an [OperationOutcome](operationoutcome.html) resource with errors or warnings.  Nested groups are used to handle complex structures and data types.  If the 'supportedOnly' parameter is set to true, only those elements marked as \\\"must support\\\" will be included.  \\n\\nThis operation is intended to enable auto-generation of simple interfaces for arbitrary profiles.  The 'questionnaire' approach to data entry has limitations that will make it less optimal than custom-defined interfaces.  However, this function may be useful for simple applications or for systems that wish to support \\\"non-core\\\" resources with minimal development effort.\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 5
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"trial-use\"
    }
  ],
  \"id\": \"StructureDefinition-questionnaire\",
  \"instance\": true,
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2019-11-01T09:29:23.356+11:00\"
  },
  \"name\": \"Build Questionnaire\",
  \"parameter\": [
    {
      \"documentation\": \"A logical identifier (i.e. 'StructureDefinition.identifier''). The server must know the StructureDefinition or be able to retrieve it from other known repositories.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"identifier\",
      \"targetProfile\": [
        \"http://hl7.org/fhir/StructureDefinition/StructureDefinition\"
      ],
      \"type\": \"canonical\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The [StructureDefinition](structuredefinition.html) is provided directly as part of the request. Servers may choose not to accept profiles in this fashion\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"profile\",
      \"searchType\": \"token\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The StructureDefinition's official URL (i.e. 'StructureDefinition.url'). The server must know the StructureDefinition or be able to retrieve it from other known repositories.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"url\",
      \"targetProfile\": [
        \"http://hl7.org/fhir/StructureDefinition/StructureDefinition\"
      ],
      \"type\": \"canonical\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"If true, the questionnaire will only include those elements marked as \\\"mustSupport='true'\\\" in the StructureDefinition.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"supportedOnly\",
      \"type\": \"boolean\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The questionnaire form generated based on the StructureDefinition.\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"return\",
      \"type\": \"Questionnaire\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"StructureDefinition\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/StructureDefinition-questionnaire\",
  \"version\": \"4.0.1\"
}"))
(define (questionnaire-operation handler)
  (define code "questionnaire")
  (list (operation-entry 'type code "StructureDefinition" handler)
        (operation-entry 'instance code "StructureDefinition" handler)))
(define snapshot-definition
  (string->jsexpr
   "{
  \"code\": \"snapshot\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://hl7.org/fhir\"
        },
        {
          \"system\": \"email\",
          \"value\": \"fhir@lists.hl7.org\"
        }
      ]
    }
  ],
  \"date\": \"2019-11-01T09:29:23+11:00\",
  \"description\": \"Generates a [StructureDefinition](structuredefinition.html) instance  with  a snapshot, based on a differential in a specified [StructureDefinition](structuredefinition.html).   \\n\\nIf the operation is not called at the instance level, either *definition* or *url* 'in' parameters must be provided. If more than one is specified, servers may raise an error or may resolve with the parameter of their choice. If called at the instance level, these parameters will be ignored.\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 5
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"trial-use\"
    }
  ],
  \"id\": \"StructureDefinition-snapshot\",
  \"instance\": true,
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2019-11-01T09:29:23.356+11:00\"
  },
  \"name\": \"Generate Snapshot\",
  \"parameter\": [
    {
      \"documentation\": \"The [StructureDefinition](structuredefinition.html) is provided directly as part of the request. Servers may choose not to accept profiles in this fashion\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"definition\",
      \"type\": \"StructureDefinition\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The StructureDefinition's canonical URL (i.e. 'StructureDefinition.url'). The server must know the structure definition, or be able to retrieve it from other known repositories.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"url\",
      \"searchType\": \"token\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The structure definition with a snapshot\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"return\",
      \"type\": \"StructureDefinition\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"StructureDefinition\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/StructureDefinition-snapshot\",
  \"version\": \"4.0.1\"
}"))
(define (snapshot-operation handler)
  (define code "snapshot")
  (list (operation-entry 'type code "StructureDefinition" handler)
        (operation-entry 'instance code "StructureDefinition" handler)))
(define stats-definition
  (string->jsexpr
   "{
  \"code\": \"stats\",
  \"comment\": \"If [modifier extensions](extensibility.html#modifierExtension) are present in the Observation, they must be accounted for by implementers.  A modifier extension may affect the observation.value in a way that it should be excluded from the from the calculations.\\r\\rThis operation cannot be performed on observations that the user is not authorized to see.  It is assumed that the server has identified and secured the context appropriately, and can either associate the authorization context with a single patient, or determine whether the context has the rights to the nominated patient, if there is one. If there is no nominated patient (e.g. the operation is invoked at the system level) and the context is not associated with a single patient record, then the server should return an error. Specifying the relationship between the context, a user and patient records is outside the scope of this specification.\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://hl7.org/fhir\"
        },
        {
          \"system\": \"email\",
          \"value\": \"fhir@lists.hl7.org\"
        }
      ]
    }
  ],
  \"date\": \"2019-11-01T09:29:23+11:00\",
  \"description\": \"The Statistics operation performs a set of statistical calculations on a set of clinical measurements such as a blood pressure as stored on the server.  This operation evaluates [Observation](observation.html) resources having valueQuantity elements that have UCUM unit codes. Observations with a status of 'entered-in-error' will be excluded from the calculations.  \\r\\rThe set of Observations is defined by 4 parameters:\\r\\r*  the subject of the observations for which the statistics are being generated (`subject`)\\r* which observations to generate statistics for (`code` and `system`, or `coding`)\\r* the time period over which to generate statistics 'duration` or `period`)\\r* the set of statistical analyses to return (`statistic`)\\r\\rPossible statistical analyses (see [StatisticsCode](valueset-observation-statistics.html)):\\r\\r - **average** (\\\"Average\\\"): The [mean](https://en.wikipedia.org/wiki/Arithmetic_mean) of N measurements over the stated period.\\r\\n - **maximum** (\\\"Maximum\\\"): The [maximum](https://en.wikipedia.org/wiki/Maximal_element) value of N measurements over the stated period.\\r\\n - **minimum** (\\\"Minimum\\\"): The [minimum](https://en.wikipedia.org/wiki/Minimal_element) value of N measurements over the stated period.\\r\\n - **count** (\\\"Count\\\"): The [number] of valid measurements over the stated period that contributed to the other statistical outputs.\\r\\n - **total-count** (\\\"Total Count\\\"): The total [number] of valid measurements over the stated period, including observations that were ignored because they did not contain valid result values.\\r\\n - **median** (\\\"Median\\\"): The [median](https://en.wikipedia.org/wiki/Median) of N measurements over the stated period.\\r\\n - **std-dev** (\\\"Standard Deviation\\\"): The [standard deviation](https://en.wikipedia.org/wiki/Standard_deviation) of N measurements over the stated period.\\r\\n - **sum** (\\\"Sum\\\"): The [sum](https://en.wikipedia.org/wiki/Summation) of N measurements over the stated period.\\r\\n - **variance** (\\\"Variance\\\"): The [variance](https://en.wikipedia.org/wiki/Variance) of N measurements over the stated period.\\r\\n - **20-percent** (\\\"20th Percentile\\\"): The 20th [Percentile](https://en.wikipedia.org/wiki/Percentile) of N measurements over the stated period.\\r\\n - **80-percent** (\\\"80th Percentile\\\"): The 80th [Percentile](https://en.wikipedia.org/wiki/Percentile) of N measurements over the stated period.\\r\\n - **4-lower** (\\\"Lower Quartile\\\"): The lower [Quartile](https://en.wikipedia.org/wiki/Quartile) Boundary of N measurements over the stated period.\\r\\n - **4-upper** (\\\"Upper Quartile\\\"): The upper [Quartile](https://en.wikipedia.org/wiki/Quartile) Boundary of N measurements over the stated period.\\r\\n - **4-dev** (\\\"Quartile Deviation\\\"): The difference between the upper and lower [Quartiles](https://en.wikipedia.org/wiki/Quartile) is called the Interquartile range. (IQR = Q3-Q1) Quartile deviation or Semi-interquartile range is one-half the difference between the first and the third quartiles.\\r\\n - **5-1** (\\\"1st Quintile\\\"): The lowest of four values that divide the N measurements into a frequency distribution of five classes with each containing one fifth of the total population.\\r\\n - **5-2** (\\\"2nd Quintile\\\"): The second of four values that divide the N measurements into a frequency distribution of five classes with each containing one fifth of the total population.\\r\\n - **5-3** (\\\"3rd Quintile\\\"): The third of four values that divide the N measurements into a frequency distribution of five classes with each containing one fifth of the total population.\\r\\n - **5-4** (\\\"4th Quintile\\\"): The fourth of four values that divide the N measurements into a frequency distribution of five classes with each containing one fifth of the total population.\\r\\n - **skew** (\\\"Skew\\\"): Skewness is a measure of the asymmetry of the probability distribution of a real-valued random variable about its mean. The skewness value can be positive or negative, or even undefined.  Source: [Wikipedia](https://en.wikipedia.org/wiki/Skewness).\\r\\n - **kurtosis** (\\\"Kurtosis\\\"): Kurtosis  is a measure of the \\\"tailedness\\\" of the probability distribution of a real-valued random variable.   Source: [Wikipedia](https://en.wikipedia.org/wiki/Kurtosis).\\r\\n - **regression** (\\\"Regression\\\"): Linear regression is an approach for modeling two-dimensional sample points with one independent variable and one dependent variable (conventionally, the x and y coordinates in a Cartesian coordinate system) and finds a linear function (a non-vertical straight line) that, as accurately as possible, predicts the dependent variable values as a function of the independent variables. Source: [Wikipedia](https://en.wikipedia.org/wiki/Simple_linear_regression)  This Statistic code will return both a gradient and an intercept value.\\r\\n\\r\\rIf successful, the operation returns an Observation resource for each code with the results of the statistical calculations as component value pairs where the component code = the statistical code. The Observation also contains the input parameters `patient`,`code` and `duration` parameters. If unsuccessful, an [OperationOutcome](operationoutcome.html) with an error message will be returned.\\r\\rThe client can request that all the observations on which the statistics are based be returned as well, using the include parameter. If an include parameter is specified, a limit may also be specified; the sources observations are subsetted at the server's discretion if count > limit. This functionality is included with the intent of supporting graphical presentation\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 3
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"trial-use\"
    }
  ],
  \"id\": \"Observation-stats\",
  \"instance\": false,
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2019-11-01T09:29:23.356+11:00\"
  },
  \"name\": \"Observation Statistics\",
  \"parameter\": [
    {
      \"documentation\": \"The subject of the relevant Observations, which has the value of the Observation.subject.reference. E.g. 'Patient/123'. Reference can be to an absolute URL, but servers only perform stats on their own observations\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"subject\",
      \"type\": \"uri\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The test code(s) upon which the statistics are being performed. Provide along with a system, or as a coding. For example, the LOINC code  = \\r2339-0 (Glucose [Mass/​volume] in Blood) will evaluate all relevant Observations with this code in `Observation.code` and `Observation.component.code`. For LOINC codes that are panels, e.g., 85354-9(Blood pressure panel with all children optional), the stats operation returns statistics for each of the individual panel measurements.  That means it will include and evaluate all values grouped by code for all the individual observations that are: 1) referenced in   `.related` for `.related.type` = 'has-member'  and 2) component observations in `Observation.component`.\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"code\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The system for the code(s). Or provide a coding instead\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"system\",
      \"type\": \"uri\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The test code upon which the statistics are being performed, as a Coding\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"coding\",
      \"type\": \"Coding\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The time period of interest given as hours.  For example, the duration = \\\"1\\\" represents the last hour - the time period from on hour ago to now\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"duration\",
      \"type\": \"decimal\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The time period over which the calculations to be performed, if a duration is not provided\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"period\",
      \"type\": \"Period\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"average|max|min|count  The statistical operations to be performed on the relevant operations. Multiple statistics operations can be specified. These codes are defined [here](valueset-observation-statistics.html)\",
      \"max\": \"*\",
      \"min\": 1,
      \"name\": \"statistic\",
      \"type\": \"code\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Whether to return the observations on which the statistics are based\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"include\",
      \"type\": \"boolean\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"If an include parameter is specified, a limit may also be specified to limit the number of source Observations returned.  If the include paramter is absent or equal to \\\"false\\\" the limit parameter SHALL be ignored by the server\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"limit\",
      \"type\": \"positiveInt\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"A set of observations, one observation for each code, each containing one component for each statistic. The Observation.component.code contains the statistic, and is relative to the Observation.code and cannot be interpreted independently.  The Observation will also contain a subject, effectivePeriod, and code reflecting the input parameters.  The status is fixed to `final`.\",
      \"max\": \"*\",
      \"min\": 1,
      \"name\": \"statistics\",
      \"type\": \"Observation\",
      \"use\": \"out\"
    },
    {
      \"documentation\": \"Source observations on which the statistics are based\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"source\",
      \"type\": \"Observation\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"Observation\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Observation-stats\",
  \"version\": \"4.0.1\"
}"))
(define (stats-operation handler)
  (define code "stats")
  (list (operation-entry 'type code "Observation" handler)))
(define submit-data-definition
  (string->jsexpr
   "{
  \"code\": \"submit-data\",
  \"comment\": \"The effect of invoking this operation is that the submitted data is posted to the receiving system and can be used for subsequent calculation of the relevant quality measure. The data-of-interest for a measure can be determined by examining the measure definition, or by invoking the $data-requirements operation\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://hl7.org/fhir\"
        },
        {
          \"system\": \"email\",
          \"value\": \"fhir@lists.hl7.org\"
        }
      ]
    }
  ],
  \"date\": \"2019-11-01T09:29:23+11:00\",
  \"description\": \"The submit-data operation is used to submit data-of-interest for a measure. There is no expectation that the submitted data represents all the data-of-interest, only that all the data submitted is relevant to the calculation of the measure for a particular subject or population\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 2
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"trial-use\"
    }
  ],
  \"id\": \"Measure-submit-data\",
  \"instance\": true,
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2019-11-01T09:29:23.356+11:00\"
  },
  \"name\": \"Submit Data\",
  \"parameter\": [
    {
      \"documentation\": \"The measure report being submitted\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"measureReport\",
      \"type\": \"MeasureReport\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The individual resources that make up the data-of-interest being submitted\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"resource\",
      \"type\": \"Resource\",
      \"use\": \"in\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"Measure\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Measure-submit-data\",
  \"version\": \"4.0.1\"
}"))
(define (submit-data-operation handler)
  (define code "submit-data")
  (list (operation-entry 'type code "Measure" handler)
        (operation-entry 'instance code "Measure" handler)))
(define Claim-submit-definition
  (string->jsexpr
   "{
  \"code\": \"submit\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://hl7.org/fhir\"
        },
        {
          \"system\": \"email\",
          \"value\": \"fhir@lists.hl7.org\"
        }
      ]
    }
  ],
  \"date\": \"2019-11-01T09:29:23+11:00\",
  \"description\": \"This operation is used to submit a Claim, Pre-Authorization or Pre-Determination (all instances of Claim resources) for adjudication either as a single Claim resource instance or as a Bundle containing the Claim and other referenced resources, or Bundle containing a batch of Claim resources, either as single Claims resources or Bundle resources, for processing. The only input parameter is the single Claim or Bundle resource and the only output is a single ClaimResponse, Bundle of ClaimResponses or an OperationOutcome resource.\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 2
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"trial-use\"
    }
  ],
  \"id\": \"Claim-submit\",
  \"instance\": false,
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2019-11-01T09:29:23.356+11:00\"
  },
  \"name\": \"Submit a Claim resource for adjudication\",
  \"parameter\": [
    {
      \"documentation\": \"A Claim resource or Bundle of claims, either as individual Claim resources or as Bundles each containing a single Claim plus referenced resources.\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"resource\",
      \"type\": \"Resource\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"A ClaimResponse resource or Bundle of claim responses, either as individual ClaimResponse resources or as Bundles each containing a single ClaimResponse plus referenced resources.\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"return\",
      \"type\": \"Resource\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"Claim\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Claim-submit\",
  \"version\": \"4.0.1\"
}"))
(define (Claim-submit-operation handler)
  (define code "submit")
  (list (operation-entry 'type code "Claim" handler)))
(define CoverageEligibilityRequest-submit-definition
  (string->jsexpr
   "{
  \"code\": \"submit\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://hl7.org/fhir\"
        },
        {
          \"system\": \"email\",
          \"value\": \"fhir@lists.hl7.org\"
        }
      ]
    }
  ],
  \"date\": \"2019-11-01T09:29:23+11:00\",
  \"description\": \"This operation is used to submit an EligibilityRequest for assessment either as a single EligibilityRequest resource instance or as a Bundle containing the EligibilityRequest and other referenced resources, or Bundle containing a batch of EligibilityRequest resources, either as single EligibilityRequests resources or Bundle resources, for processing. The only input parameter is the single EligibilityRequest or Bundle resource and the only output is a single EligibilityResponse, Bundle of EligibilityResponses or an OperationOutcome resource.\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 2
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"trial-use\"
    }
  ],
  \"id\": \"CoverageEligibilityRequest-submit\",
  \"instance\": false,
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2019-11-01T09:29:23.356+11:00\"
  },
  \"name\": \"Submit an EligibilityRequest resource for assessment\",
  \"parameter\": [
    {
      \"documentation\": \"An EligibilityRequest resource or Bundle of EligibilityRequests, either as individual EligibilityRequest resources or as Bundles each containing a single EligibilityRequest plus referenced resources.\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"resource\",
      \"type\": \"Resource\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"An EligibilityResponse resource or Bundle of EligibilityResponse responses, either as individual EligibilityResponse resources or as Bundles each containing a single EligibilityResponse plus referenced resources.\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"return\",
      \"type\": \"Resource\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"CoverageEligibilityRequest\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/CoverageEligibilityRequest-submit\",
  \"version\": \"4.0.1\"
}"))
(define (CoverageEligibilityRequest-submit-operation handler)
  (define code "submit")
  (list (operation-entry 'type code "CoverageEligibilityRequest" handler)))
(define subset-definition
  (string->jsexpr
   "{
  \"code\": \"subset\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://hl7.org/fhir\"
        },
        {
          \"system\": \"email\",
          \"value\": \"fhir@lists.hl7.org\"
        }
      ]
    }
  ],
  \"date\": \"2019-11-01T09:29:23+11:00\",
  \"description\": \"This operation asks the server to return a subset of the CapabilityStatement resource - just the REST parts that relate to a set of nominated resources - the resources that the client is interested in\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 5
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"trial-use\"
    }
  ],
  \"id\": \"CapabilityStatement-subset\",
  \"instance\": true,
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2019-11-01T09:29:23.356+11:00\"
  },
  \"name\": \"Fetch a subset of the CapabilityStatement resource\",
  \"parameter\": [
    {
      \"documentation\": \"The canonical URL - use this if the subset is not invoked on an instance (or on the /metadata end-point)\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"server\",
      \"type\": \"uri\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"A resource that the client would like to include in the return\",
      \"max\": \"*\",
      \"min\": 1,
      \"name\": \"resource\",
      \"type\": \"code\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The subsetted CapabilityStatement resource that is returned. This should be tagged with the SUBSETTED code\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"return\",
      \"type\": \"CapabilityStatement\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"CapabilityStatement\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/CapabilityStatement-subset\",
  \"version\": \"4.0.1\"
}"))
(define (subset-operation handler)
  (define code "subset")
  (list (operation-entry 'type code "CapabilityStatement" handler)
        (operation-entry 'instance code "CapabilityStatement" handler)))
(define subsumes-definition
  (string->jsexpr
   "{
  \"code\": \"subsumes\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://hl7.org/fhir\"
        },
        {
          \"system\": \"email\",
          \"value\": \"fhir@lists.hl7.org\"
        }
      ]
    }
  ],
  \"date\": \"2019-11-01T09:29:23+11:00\",
  \"description\": \"Test the subsumption relationship between code/Coding A and code/Coding B given the semantics of subsumption in the underlying code system (see [hierarchyMeaning](codesystem-definitions.html#CodeSystem.hierarchyMeaning)).\\n\\nWhen invoking this operation, a client SHALL provide both a and codes, either as code or Coding parameters. The system parameter is required unless the operation is invoked on an instance of a code system resource. Other parameters are optional\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 5
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"normative\"
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-normative-version\",
      \"valueCode\": \"4.0.1\"
    }
  ],
  \"id\": \"CodeSystem-subsumes\",
  \"instance\": true,
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2019-11-01T09:29:23.356+11:00\"
  },
  \"name\": \"Subsumption Testing\",
  \"parameter\": [
    {
      \"documentation\": \"The \\\"A\\\" code that is to be tested. If a code is provided, a system must be provided\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"codeA\",
      \"type\": \"code\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The \\\"B\\\" code that is to be tested. If a code is provided, a system must be provided\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"codeB\",
      \"type\": \"code\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The code system in which subsumption testing is to be performed. This must be provided unless the operation is invoked on a code system instance\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"system\",
      \"type\": \"uri\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The version of the code system, if one was provided in the source data\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"version\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The \\\"A\\\" Coding that is to be tested. The code system does not have to match the specified subsumption code system, but the relationships between the code systems must be well established\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"codingA\",
      \"type\": \"Coding\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The \\\"B\\\" Coding that is to be tested. The code system does not have to match the specified subsumption code system, but the relationships between the code systems must be well established\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"codingB\",
      \"type\": \"Coding\",
      \"use\": \"in\"
    },
    {
      \"binding\": {
        \"strength\": \"required\",
        \"valueSet\": \"http://hl7.org/fhir/ValueSet/concept-subsumption-outcome|4.0.1\"
      },
      \"documentation\": \"The subsumption relationship between code/Coding \\\"A\\\" and code/Coding \\\"B\\\". There are 4 possible codes to be returned (equivalent, subsumes, subsumed-by, and not-subsumed) as defined in the concept-subsumption-outcome value set.  If the server is unable to determine the relationship between the codes/Codings, then it returns an error response with an OperationOutcome.\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"outcome\",
      \"type\": \"code\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"CodeSystem\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/CodeSystem-subsumes\",
  \"version\": \"4.0.1\"
}"))
(define (subsumes-operation handler)
  (define code "subsumes")
  (list (operation-entry 'type code "CodeSystem" handler)
        (operation-entry 'instance code "CodeSystem" handler)))
(define transform-definition
  (string->jsexpr
   "{
  \"code\": \"transform\",
  \"comment\": \"The input and return are specified as 'Resources'. In most usage of the $transform operation, either the input or return content is not a valid FHIR resource. In these cases, the return type is actually a [Binary](binary.html) resource. For this operation, the Binary resources may be encoded directly, using a mime-type, as shown in the example. Note: this specification does not yet address the means by which the servers may know the correct mime types for the various content involved\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://hl7.org/fhir\"
        },
        {
          \"system\": \"email\",
          \"value\": \"fhir@lists.hl7.org\"
        }
      ]
    }
  ],
  \"date\": \"2019-11-01T09:29:23+11:00\",
  \"description\": \"The transform operation takes input content, applies a structure map transform, and then returns the output.\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 2
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"trial-use\"
    }
  ],
  \"id\": \"StructureMap-transform\",
  \"instance\": true,
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2019-11-01T09:29:23.356+11:00\"
  },
  \"name\": \"Model Instance Transformation\",
  \"parameter\": [
    {
      \"documentation\": \"The structure map to apply. This is only needed if the operation is invoked at the resource level. If the $transform operation is invoked on a particular structure map, this will be ignored by the server\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"source\",
      \"type\": \"uri\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The logical content to transform\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"content\",
      \"type\": \"Resource\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The result of the transform\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"return\",
      \"type\": \"Resource\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"StructureMap\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/StructureMap-transform\",
  \"version\": \"4.0.1\"
}"))
(define (transform-operation handler)
  (define code "transform")
  (list (operation-entry 'type code "StructureMap" handler)
        (operation-entry 'instance code "StructureMap" handler)))
(define translate-definition
  (string->jsexpr
   "{
  \"code\": \"translate\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://hl7.org/fhir\"
        },
        {
          \"system\": \"email\",
          \"value\": \"fhir@lists.hl7.org\"
        }
      ]
    }
  ],
  \"date\": \"2019-11-01T09:29:23+11:00\",
  \"description\": \"Translate a code from one value set to another, based on the existing value set and concept maps resources, and/or other additional knowledge available to the server. \\r\\n\\r\\n One (and only one) of the in parameters (code, coding, codeableConcept) must be provided, to identify the code that is to be translated.  \\r\\n\\r\\n The operation returns a set of parameters including a 'result' for whether there is an acceptable match, and a list of possible matches. Note that the list of matches may include notes of codes for which mapping is specifically excluded, so implementers have to check the match.equivalence for each match\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 3
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"trial-use\"
    }
  ],
  \"id\": \"ConceptMap-translate\",
  \"instance\": true,
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2019-11-01T09:29:23.356+11:00\"
  },
  \"name\": \"Concept Translation\",
  \"parameter\": [
    {
      \"documentation\": \"A canonical URL for a concept map. The server must know the concept map (e.g. it is defined explicitly in the server's concept maps, or it is defined implicitly by some code system known to the server.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"url\",
      \"type\": \"uri\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The concept map is provided directly as part of the request. Servers may choose not to accept concept maps in this fashion.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"conceptMap\",
      \"type\": \"ConceptMap\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The identifier that is used to identify a specific version of the concept map to be used for the translation. This is an arbitrary value managed by the concept map author and is not expected to be globally unique. For example, it might be a timestamp (e.g. yyyymmdd) if a managed version is not available.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"conceptMapVersion\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The code that is to be translated. If a code is provided, a system must be provided\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"code\",
      \"type\": \"code\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The system for the code that is to be translated\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"system\",
      \"type\": \"uri\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The version of the system, if one was provided in the source data\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"version\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Identifies the value set used when the concept (system/code pair) was chosen. May be a logical id, or an absolute or relative location. The source value set is an optional parameter because in some cases, the client cannot know what the source value set is. However, without a source value set, the server may be unable to safely identify an applicable concept map, and would return an error. For this reason, a source value set SHOULD always be provided. Note that servers may be able to identify an appropriate concept map without a source value set if there is a full mapping for the entire code system in the concept map, or by manual intervention\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"source\",
      \"type\": \"uri\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"A coding to translate\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"coding\",
      \"type\": \"Coding\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"A full codeableConcept to validate. The server can translate any of the coding values (e.g. existing translations) as it chooses\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"codeableConcept\",
      \"type\": \"CodeableConcept\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Identifies the value set in which a translation is sought. May be a logical id, or an absolute or relative location. If there's no target specified, the server should return all known translations, along with their source\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"target\",
      \"type\": \"uri\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"identifies a target code system in which a mapping is sought. This parameter is an alternative to the target parameter - only one is required. Searching for any translation to a target code system irrespective of the context (e.g. target valueset) may lead to unsafe results, and it is at the discretion of the server to decide when to support this operation\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"targetsystem\",
      \"type\": \"uri\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Another element that may help produce the correct mapping\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"dependency\",
      \"part\": [
        {
          \"documentation\": \"The element for this dependency\",
          \"max\": \"1\",
          \"min\": 0,
          \"name\": \"element\",
          \"type\": \"uri\",
          \"use\": \"in\"
        },
        {
          \"documentation\": \"The value for this dependency\",
          \"max\": \"1\",
          \"min\": 0,
          \"name\": \"concept\",
          \"type\": \"CodeableConcept\",
          \"use\": \"in\"
        }
      ],
      \"use\": \"in\"
    },
    {
      \"documentation\": \"if this is true, then the operation should return all the codes that might be mapped to this code. This parameter reverses the meaning of the source and target parameters\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"reverse\",
      \"type\": \"boolean\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"True if the concept could be translated successfully. The value can only be true if at least one returned match has an equivalence which is not  unmatched or disjoint\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"result\",
      \"type\": \"boolean\",
      \"use\": \"out\"
    },
    {
      \"documentation\": \"Error details, for display to a human. If this is provided when result = true, the message carries hints and warnings (e.g. a note that the matches could be improved by providing additional detail)\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"message\",
      \"type\": \"string\",
      \"use\": \"out\"
    },
    {
      \"documentation\": \"A concept in the target value set with an equivalence. Note that there may be multiple matches of equal or differing equivalence, and the matches may include equivalence values that mean that there is no match\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"match\",
      \"part\": [
        {
          \"documentation\": \"A code indicating the equivalence of the translation, using values from [ConceptMapEquivalence](valueset-concept-map-equivalence.html)\",
          \"max\": \"1\",
          \"min\": 0,
          \"name\": \"equivalence\",
          \"type\": \"code\",
          \"use\": \"out\"
        },
        {
          \"documentation\": \"The translation outcome. Note that this would never have userSelected = true, since the process of translations implies that the user is not selecting the code (and only the client could know differently)\",
          \"max\": \"1\",
          \"min\": 0,
          \"name\": \"concept\",
          \"type\": \"Coding\",
          \"use\": \"out\"
        },
        {
          \"documentation\": \"Another element that is the product of this mapping\",
          \"max\": \"*\",
          \"min\": 0,
          \"name\": \"product\",
          \"part\": [
            {
              \"documentation\": \"The element for this product\",
              \"max\": \"1\",
              \"min\": 0,
              \"name\": \"element\",
              \"type\": \"uri\",
              \"use\": \"out\"
            },
            {
              \"documentation\": \"The value for this product\",
              \"max\": \"1\",
              \"min\": 0,
              \"name\": \"concept\",
              \"type\": \"Coding\",
              \"use\": \"out\"
            }
          ],
          \"use\": \"out\"
        },
        {
          \"documentation\": \"The canonical reference to the concept map from which this mapping comes from\",
          \"max\": \"1\",
          \"min\": 0,
          \"name\": \"source\",
          \"type\": \"uri\",
          \"use\": \"out\"
        }
      ],
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"ConceptMap\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/ConceptMap-translate\",
  \"version\": \"4.0.1\"
}"))
(define (translate-operation handler)
  (define code "translate")
  (list (operation-entry 'type code "ConceptMap" handler)
        (operation-entry 'instance code "ConceptMap" handler)))
(define CodeSystem-validate-code-definition
  (string->jsexpr
   "{
  \"code\": \"validate-code\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://hl7.org/fhir\"
        },
        {
          \"system\": \"email\",
          \"value\": \"fhir@lists.hl7.org\"
        }
      ]
    }
  ],
  \"date\": \"2019-11-01T09:29:23+11:00\",
  \"description\": \"Validate that a coded value is in the code system. If the operation is not called at the instance level, one of the parameters \\\"url\\\" or \\\"codeSystem\\\" must be provided. The operation returns a result (true / false), an error message, and the recommended display for the code.\\n\\nWhen invoking this operation, a client SHALL provide one (and only one) of the parameters (code+system, coding, or codeableConcept). Other parameters (including version and display) are optional\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 5
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"normative\"
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-normative-version\",
      \"valueCode\": \"4.0.1\"
    }
  ],
  \"id\": \"CodeSystem-validate-code\",
  \"instance\": true,
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2019-11-01T09:29:23.356+11:00\"
  },
  \"name\": \"Code System based Validation\",
  \"parameter\": [
    {
      \"documentation\": \"CodeSystem URL. The server must know the code system (e.g. it is defined explicitly in the server'scode systems, or it is known implicitly by the server\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"url\",
      \"type\": \"uri\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The codeSystem is provided directly as part of the request. Servers may choose not to accept code systems in this fashion. This parameter is used when the client wants the server to check against a code system that is not stored on the server\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"codeSystem\",
      \"type\": \"CodeSystem\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The code that is to be validated\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"code\",
      \"type\": \"code\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The version of the code system, if one was provided in the source data\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"version\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The display associated with the code, if provided. If a display is provided a code must be provided. If no display is provided, the server cannot validate the display value, but may choose to return a recommended display name in an extension in the outcome. Whether displays are case sensitive is code system dependent\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"display\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"A coding to validate. The system must match the specified code system\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"coding\",
      \"type\": \"Coding\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"A full codeableConcept to validate. The server returns true if one of the coding values is in the code system, and may also validate that the codings are not in conflict with each other if more than one is present\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"codeableConcept\",
      \"type\": \"CodeableConcept\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The date for which the validation should be checked. Normally, this is the current conditions (which is the default values) but under some circumstances, systems need to validate that a correct code was used at some point in the past. A typical example of this would be where code selection is constrained to the set of codes that were available when the patient was treated, not when the record is being edited. Note that which date is appropriate is a matter for implementation policy.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"date\",
      \"type\": \"dateTime\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"If this parameter has a value of true, the client is stating that the validation is being performed in a context where a concept designated as 'abstract' is appropriate/allowed to be used, and the server should regard abstract codes as valid. If this parameter is false, abstract codes are not considered to be valid.\\n\\nNote that. 'abstract' is a property defined by many HL7 code systems that indicates that the concept is a logical grouping concept that is not intended to be used asa 'concrete' concept to in an actual patient/care/process record. This language is borrowed from Object Orienated theory where 'asbtract' objects are never instantiated. However in the general record and terminology eco-system, there are many contexts where it is appropraite to use these codes e.g. as decision making criterion, or when editing value sets themselves. This parameter allows a client to indicate to the server that it is working in such a context.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"abstract\",
      \"type\": \"boolean\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Specifies the language to be used for description when validating the display property\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"displayLanguage\",
      \"type\": \"code\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"True if the concept details supplied are valid\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"result\",
      \"type\": \"boolean\",
      \"use\": \"out\"
    },
    {
      \"documentation\": \"Error details, if result = false. If this is provided when result = true, the message carries hints and warnings\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"message\",
      \"type\": \"string\",
      \"use\": \"out\"
    },
    {
      \"documentation\": \"A valid display for the concept if the system wishes to display this to a user\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"display\",
      \"type\": \"string\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"CodeSystem\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/CodeSystem-validate-code\",
  \"version\": \"4.0.1\"
}"))
(define (CodeSystem-validate-code-operation handler)
  (define code "validate-code")
  (list (operation-entry 'type code "CodeSystem" handler)
        (operation-entry 'instance code "CodeSystem" handler)))
(define ValueSet-validate-code-definition
  (string->jsexpr
   "{
  \"code\": \"validate-code\",
  \"comment\": \"Note: the correct behaviour of validation with regard to language for Coding.display items is currently undefined, and further development and testing may lead to specific requirements or recommendations in subsequent releases\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://hl7.org/fhir\"
        },
        {
          \"system\": \"email\",
          \"value\": \"fhir@lists.hl7.org\"
        }
      ]
    }
  ],
  \"date\": \"2019-11-01T09:29:23+11:00\",
  \"description\": \"Validate that a coded value is in the set of codes allowed by a value set.\\n\\nIf the operation is not called at the instance level, one of the in parameters url, context or  valueSet must be provided.  One (and only one) of the in parameters code, coding, or codeableConcept must be provided.  The operation returns a result (true / false), an error message, and the recommended display for the code\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 5
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"normative\"
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-normative-version\",
      \"valueCode\": \"4.0.1\"
    }
  ],
  \"id\": \"ValueSet-validate-code\",
  \"instance\": true,
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2019-11-01T09:29:23.356+11:00\"
  },
  \"name\": \"Value Set based Validation\",
  \"parameter\": [
    {
      \"documentation\": \"Value set Canonical URL. The server must know the value set (e.g. it is defined explicitly in the server's value sets, or it is defined implicitly by some code system known to the server\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"url\",
      \"type\": \"uri\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The context of the value set, so that the server can resolve this to a value set to validate against. The recommended format for this URI is [Structure Definition URL]#[name or path into structure definition] e.g. http://hl7.org/fhir/StructureDefinition/observation-hspc-height-hspcheight#Observation.interpretation. Other forms may be used but are not defined. This form is only usable if the terminology server also has access to the conformance registry that the server is using, but can be used to delegate the mapping from an application context to a binding at run-time\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"context\",
      \"type\": \"uri\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The value set is provided directly as part of the request. Servers may choose not to accept value sets in this fashion. This parameter is used when the client wants the server to expand a value set that is not stored on the server\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"valueSet\",
      \"type\": \"ValueSet\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The identifier that is used to identify a specific version of the value set to be used when validating the code. This is an arbitrary value managed by the value set author and is not expected to be globally unique. For example, it might be a timestamp (e.g. yyyymmdd) if a managed version is not available.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"valueSetVersion\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The code that is to be validated. If a code is provided, a system or a context must be provided (if a context is provided, then the server SHALL ensure that the code is not ambiguous without a system)\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"code\",
      \"type\": \"code\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The system for the code that is to be validated\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"system\",
      \"type\": \"uri\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The version of the system, if one was provided in the source data\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"systemVersion\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The display associated with the code, if provided. If a display is provided a code must be provided. If no display is provided, the server cannot validate the display value, but may choose to return a recommended display name using the display parameter in the outcome. Whether displays are case sensitive is code system dependent\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"display\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"A coding to validate\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"coding\",
      \"type\": \"Coding\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"A full codeableConcept to validate. The server returns true if one of the coding values is in the value set, and may also validate that the codings are not in conflict with each other if more than one is present\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"codeableConcept\",
      \"type\": \"CodeableConcept\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The date for which the validation should be checked. Normally, this is the current conditions (which is the default values) but under some circumstances, systems need to validate that a correct code was used at some point in the past. A typical example of this would be where code selection is constrained to the set of codes that were available when the patient was treated, not when the record is being edited. Note that which date is appropriate is a matter for implementation policy.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"date\",
      \"type\": \"dateTime\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"If this parameter has a value of true, the client is stating that the validation is being performed in a context where a concept designated as 'abstract' is appropriate/allowed to be used, and the server should regard abstract codes as valid. If this parameter is false, abstract codes are not considered to be valid.\\n\\nNote that. 'abstract' is a property defined by many HL7 code systems that indicates that the concept is a logical grouping concept that is not intended to be used asa 'concrete' concept to in an actual patient/care/process record. This language is borrowed from Object Orienated theory where 'asbtract' objects are never instantiated. However in the general record and terminology eco-system, there are many contexts where it is appropraite to use these codes e.g. as decision making criterion, or when editing value sets themselves. This parameter allows a client to indicate to the server that it is working in such a context.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"abstract\",
      \"type\": \"boolean\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Specifies the language to be used for description when validating the display property\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"displayLanguage\",
      \"type\": \"code\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"True if the concept details supplied are valid\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"result\",
      \"type\": \"boolean\",
      \"use\": \"out\"
    },
    {
      \"documentation\": \"Error details, if result = false. If this is provided when result = true, the message carries hints and warnings\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"message\",
      \"type\": \"string\",
      \"use\": \"out\"
    },
    {
      \"documentation\": \"A valid display for the concept if the system wishes to display this to a user\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"display\",
      \"type\": \"string\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"ValueSet\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/ValueSet-validate-code\",
  \"version\": \"4.0.1\"
}"))
(define (ValueSet-validate-code-operation handler)
  (define code "validate-code")
  (list (operation-entry 'type code "ValueSet" handler)
        (operation-entry 'instance code "ValueSet" handler)))
(define validate-definition
  (string->jsexpr
   "{
  \"code\": \"validate\",
  \"comment\": \"This operation may be used during design and development to validate application design. It can also be used at run-time. One possible use might be that a client asks the server whether a proposed update is valid as the user is editing a dialog and displays an updated error to the user. The operation can be used as part of a light-weight two phase commit protocol but there is no expectation that the server will hold the content of the resource after this operation is used, or that the server guarantees to successfully perform an actual create, update or delete after the validation operation completes.\\n\\nThis operation returns a 200 OK whether or not the resource is valid. A 4xx or 5xx error means that the validation itself could not be performed, and it is unknown whether the resource is valid or not.\\n\\nNote: the correct behaviour of validation with regard to language (especially for Coding.display) is currently undefined, and further development and testing may lead to specific requirements or recommendations in subsequent releases\\n\\nFuture versions of this specifcation may add additional validation parameters. A candidate list is maintained with the [FHIR Validator Documentation](https://confluence.hl7.org/display/FHIR/Using+the+FHIR+Validator)\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://hl7.org/fhir\"
        },
        {
          \"system\": \"email\",
          \"value\": \"fhir@lists.hl7.org\"
        }
      ]
    }
  ],
  \"date\": \"2019-11-01T09:29:23+11:00\",
  \"description\": \"The validate operation checks whether the attached content would be acceptable either generally, as a create, an update or as a delete to an existing resource.  The action the server takes depends on the mode parameter:  \\n\\n* [mode not provided]: The server checks the content of the resource against any schema, constraint rules, and other general terminology rules \\n* create: The server checks the content, and then checks that the content would be acceptable as a create (e.g. that the content would not violate any uniqueness constraints) \\n* update: The server checks the content, and then checks that it would accept it as an update against the nominated specific resource (e.g. that there are no changes to immutable fields the server does not allow to change, and checking version integrity if appropriate) \\n* delete: The server ignores the content, and checks that the nominated resource is allowed to be deleted (e.g. checking referential integrity rules)  \\n\\nModes update and delete can only be used when the operation is invoked at the resource instance level.   The return from this operation is an [OperationOutcome](operationoutcome.html)\\n\\nNote that this operation is not the only way to validate resources - see [Validating Resources](validation.html) for further information.\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 5
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"normative\"
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-normative-version\",
      \"valueCode\": \"4.0.1\"
    }
  ],
  \"id\": \"Resource-validate\",
  \"instance\": true,
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2019-11-01T09:29:23.356+11:00\"
  },
  \"name\": \"Validate a resource\",
  \"parameter\": [
    {
      \"documentation\": \"Must be present unless the mode is \\\"delete\\\"\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"resource\",
      \"type\": \"Resource\",
      \"use\": \"in\"
    },
    {
      \"binding\": {
        \"strength\": \"required\",
        \"valueSet\": \"http://hl7.org/fhir/ValueSet/resource-validation-mode|4.0.1\"
      },
      \"documentation\": \"Default is 'no action'; (e.g. general validation)\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"mode\",
      \"type\": \"code\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"If this is nominated, then the resource is validated against this specific profile. If a profile is nominated, and the server cannot validate against the nominated profile, it SHALL return an error\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"profile\",
      \"type\": \"uri\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"If the operation outcome does not list any errors, and a mode was specified, then this is an indication that the operation would be expected to succeed (excepting for transactional integrity issues, see below)\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"return\",
      \"type\": \"OperationOutcome\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"Resource\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Resource-validate\",
  \"version\": \"4.0.1\"
}"))
(define (validate-operation handler)
  (define code "validate")
  (list (operation-entry 'type code "Resource" handler)
        (operation-entry 'instance code "Resource" handler)))
(define versions-definition
  (string->jsexpr
   "{
  \"code\": \"versions\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://hl7.org/fhir\"
        },
        {
          \"system\": \"email\",
          \"value\": \"fhir@lists.hl7.org\"
        }
      ]
    }
  ],
  \"date\": \"2019-11-01T09:29:23+11:00\",
  \"description\": \"Using the [FHIR Version Mime Type Parameter](http.html#version-parameter), a server can support [multiple versions on the same end-point](versioning.html#mt-version). The only way for client to find out what versions a server supports in this fashion is the $versions operation. The client invokes the operation with no parameters. and the server returns the list of supported versions, along with the default version it will use if no fhirVersion parameter is present\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 5
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"trial-use\"
    }
  ],
  \"id\": \"CapabilityStatement-versions\",
  \"instance\": false,
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2019-11-01T09:29:23.356+11:00\"
  },
  \"name\": \"Discover what versions a server supports\",
  \"parameter\": [
    {
      \"documentation\": \"A version supported by the server. Use the major.minor version like 3.0\",
      \"max\": \"*\",
      \"min\": 1,
      \"name\": \"version\",
      \"type\": \"code\",
      \"use\": \"out\"
    },
    {
      \"documentation\": \"The default version for the server. Use the major.minor version like 3.0\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"default\",
      \"type\": \"code\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"CapabilityStatement\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": true,
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/CapabilityStatement-versions\",
  \"version\": \"4.0.1\"
}"))
(define (versions-operation handler)
  (define code "versions")
  (list (operation-entry 'system code #f handler)))
(define operation-definitions
  (list ActivityDefinition-apply-definition ChargeItemDefinition-apply-definition PlanDefinition-apply-definition care-gaps-definition closure-definition collect-data-definition conforms-definition convert-definition ActivityDefinition-data-requirements-definition Library-data-requirements-definition Measure-data-requirements-definition PlanDefinition-data-requirements-definition document-definition evaluate-measure-definition Encounter-everything-definition Group-everything-definition MedicinalProduct-everything-definition Patient-everything-definition expand-definition find-matches-definition find-definition graph-definition graphql-definition implements-definition lastn-definition lookup-definition match-definition meta-add-definition meta-delete-definition meta-definition populate-definition preferred-id-definition process-message-definition questionnaire-definition snapshot-definition stats-definition submit-data-definition Claim-submit-definition CoverageEligibilityRequest-submit-definition subset-definition subsumes-definition transform-definition translate-definition CodeSystem-validate-code-definition ValueSet-validate-code-definition validate-definition versions-definition))
