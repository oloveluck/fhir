#lang racket/base
;;; GENERATED — DO NOT EDIT (verified by raco fhir check).
;; The package's OperationDefinitions as data + scaffold constructors: each
;; <code>-operation takes ONLY the handler `(in req) -> node` and yields the
;; operation-entry list for build-app's #:operations (levels/targets from the OD).
(require json (only-in fhir/capability/runtime operation-entry))
(provide operation-definitions
         ActivityDefinition-apply-definition ActivityDefinition-apply-operation
         PlanDefinition-apply-definition PlanDefinition-apply-operation
         care-gaps-definition care-gaps-operation
         collect-data-definition collect-data-operation
         convert-definition convert-operation
         current-canonical-definition current-canonical-operation
         ActivityDefinition-data-requirements-definition ActivityDefinition-data-requirements-operation
         Library-data-requirements-definition Library-data-requirements-operation
         Measure-data-requirements-definition Measure-data-requirements-operation
         PlanDefinition-data-requirements-definition PlanDefinition-data-requirements-operation
         docref-definition docref-operation
         document-definition document-operation
         evaluate-measure-definition evaluate-measure-operation
         evaluate-definition evaluate-operation
         events-definition events-operation
         Group-everything-definition Group-everything-operation
         MedicinalProductDefinition-everything-definition MedicinalProductDefinition-everything-operation
         example-query-high-risk-definition example-query-high-risk-operation
         expand-definition expand-operation
         graphql-definition graphql-operation
         lastn-definition lastn-operation
         lookup-definition lookup-operation
         match-definition match-operation
         populate-definition populate-operation
         preferred-id-definition preferred-id-operation
         process-message-definition process-message-operation
         Group-purge-definition Group-purge-operation
         Patient-purge-definition Patient-purge-operation
         snapshot-definition snapshot-operation
         stats-definition stats-operation
         status-definition status-operation
         submit-data-definition submit-data-operation
         Claim-submit-definition Claim-submit-operation
         CoverageEligibilityRequest-submit-definition CoverageEligibilityRequest-submit-operation
         subsumes-definition subsumes-operation
         transform-definition transform-operation
         translate-id-definition translate-id-operation
         translate-definition translate-operation
         CodeSystem-validate-code-definition CodeSystem-validate-code-operation
         ValueSet-validate-code-definition ValueSet-validate-code-operation
         validate-definition validate-operation
         versions-definition versions-operation)
(define ActivityDefinition-apply-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
  \"code\": \"apply\",
  \"comment\": \"The result of invoking this operation is a resource of the type specified by the activity definition, with all the definitions resolved as appropriate for the type of resource. Any dynamicValue elements will be evaluated (in the order in which they appear in the resource) and the results applied to the returned resource.  If the ActivityDefinition includes library references, those libraries will be available to the evaluated expressions. If those libraries have parameters, those parameters will be bound by name to the parameters given to the operation. In addition, parameters to the $apply operation are available within dynamicValue expressions as context variables, accessible by the name of the parameter, prefixed with a percent (%) symbol. For a more detailed description, refer to the ActivityDefinition resource. Note that result of this operation is transient (i.e. none of the resources created by the operation are persisted in the server, they are all returned as contained resources in the result). The result effectively represents a proposed set of activities, and it is up to the caller to determine whether and how those activities are actually carried out.\",
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
    },
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://www.hl7.org/Special/committees/dss\"
        }
      ]
    }
  ],
  \"date\": \"2026-05-28T22:17:06+00:00\",
  \"description\": \"The apply operation applies a definition in a specific context\",
  \"experimental\": false,
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 3
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"normative\"
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-wg\",
      \"valueCode\": \"cds\"
    }
  ],
  \"id\": \"ActivityDefinition-apply\",
  \"instance\": true,
  \"jurisdiction\": [
    {
      \"coding\": [
        {
          \"code\": \"001\",
          \"display\": \"World\",
          \"system\": \"http://unstats.un.org/unsd/methods/m49/m49.htm\"
        }
      ]
    }
  ],
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2026-05-28T22:17:06.960+00:00\"
  },
  \"name\": \"Apply\",
  \"parameter\": [
    {
      \"documentation\": \"The activity definition to apply. If the operation is invoked on an instance, this parameter is not allowed. If the operation is invoked at the type level, this parameter is required\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"activityDefinition\",
      \"scope\": [
        \"type\"
      ],
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
      \"type\": \"Resource\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 International / Clinical Decision Support\",
  \"resource\": [
    \"ActivityDefinition\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"active\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p class=\\\"res-header-id\\\">\\n              <b>Generated Narrative: OperationDefinition ActivityDefinition-apply</b>\\n            </p>\\n            <a name=\\\"ActivityDefinition-apply\\\"> </a>\\n            <a name=\\\"hcActivityDefinition-apply\\\"> </a>\\n            <p>URL: [base]/ActivityDefinition/$apply</p>\\n            <p>URL: [base]/ActivityDefinition/[id]/$apply</p>\\n            <h3>Parameters</h3>\\n\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>activityDefinition</td>\\n\\n                <td>type</td>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"activitydefinition.html\\\">ActivityDefinition</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The activity definition to apply. If the operation is invoked on an instance, this parameter is not allowed. If the operation is invoked at the type level, this parameter is required</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>subject</td>\\n\\n                <td/>\\n\\n                <td>1..*</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                  <br/>(\\n                  <a href=\\\"search.html#reference\\\">reference</a>)\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The subject(s) that is/are the target of the activity definition to be applied. The subject may be a Patient, Practitioner, Organization, Location, Device, or Group. Subjects provided in this parameter will be resolved as the subject of the PlanDefinition based on the type of the subject. If multiple subjects of the same type are provided, the behavior is implementation-defined</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>encounter</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                  <br/>(\\n                  <a href=\\\"search.html#reference\\\">reference</a>)\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The encounter in context, if any</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>practitioner</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                  <br/>(\\n                  <a href=\\\"search.html#reference\\\">reference</a>)\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The practitioner in context</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>organization</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                  <br/>(\\n                  <a href=\\\"search.html#reference\\\">reference</a>)\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The organization in context</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>userType</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#CodeableConcept\\\">CodeableConcept</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The type of user initiating the request, e.g. patient, healthcare provider, or specific type of healthcare provider (physician, nurse, etc.)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>userLanguage</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#CodeableConcept\\\">CodeableConcept</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Preferred language of the person using the system</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>userTaskContext</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#CodeableConcept\\\">CodeableConcept</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The task the system user is performing, e.g. laboratory results review, medication list review, etc. This information can be used to tailor decision support outputs, such as recommended information resources</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>setting</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#CodeableConcept\\\">CodeableConcept</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The current setting of the request (inpatient, outpatient, etc.)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>settingContext</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#CodeableConcept\\\">CodeableConcept</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Additional detail about the setting of the request, if any</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>return</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"resource.html\\\">Resource</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The resource that is the result of applying the definition</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n\\n            <div>\\n              <p>The result of invoking this operation is a resource of the type specified by the activity definition, with all the definitions resolved as appropriate for the type of resource. Any dynamicValue elements will be evaluated (in the order in which they appear in the resource) and the results applied to the returned resource.  If the ActivityDefinition includes library references, those libraries will be available to the evaluated expressions. If those libraries have parameters, those parameters will be bound by name to the parameters given to the operation. In addition, parameters to the $apply operation are available within dynamicValue expressions as context variables, accessible by the name of the parameter, prefixed with a percent (%) symbol. For a more detailed description, refer to the ActivityDefinition resource. Note that result of this operation is transient (i.e. none of the resources created by the operation are persisted in the server, they are all returned as contained resources in the result). The result effectively represents a proposed set of activities, and it is up to the caller to determine whether and how those activities are actually carried out.</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"generated\"
  },
  \"title\": \"Apply\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/ActivityDefinition-apply\",
  \"version\": \"6.0.0-ballot4\"
}"))
(define (ActivityDefinition-apply-operation handler)
  (define code "apply")
  (list (operation-entry 'type code "ActivityDefinition" handler)
        (operation-entry 'instance code "ActivityDefinition" handler)))
(define PlanDefinition-apply-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
  \"code\": \"apply\",
  \"comment\": \"The result of this operation is a Bundle for each subject, where the Bundle contains Request resources that are the direct result of applying the PlanDefinition to that subject. The Bundle will have entries for each of the applicable actions in the PlanDefinition based on evaluating the applicability condition in context, and producing Request resources based on the definition element for each applicable action.\\n\\nFor each applicable action, the definition is applied as described in the $apply operation of the ActivityDefinition resource, and the resulting resource is added as an entry to the Bundle. The resulting Bundle may be any combination of Request resources, including CarePlan, RequestOrchestration, and individual Request resources such as ServiceRequest and MedicationRequest.\\n\\nNote that to preserve the structure of the PlanDefinition, systems may choose to return the results in a RequestOrchestration. In this case, the individual request resources will have an intent of `option`, meaning the their intent is governed by the RequestOrchestraiont.\\n\\nIf the ActivityDefinition includes library references, those libraries will be available to the evaluated expressions. If those libraries have parameters, those parameters will be bound by name to the parameters given to the operation. In addition, parameters to the $apply operation are available within dynamicValue expressions as context variables, accessible by the name of the parameter, prefixed with a percent (%) symbol.\\n\\nFor a more detailed description, refer to the PlanDefinition and ActivityDefinition resource documentation. Note that result of this operation is transient (i.e. none of the resources created by the operation are persisted in the server, they are all returned as entries in the result Bundle(s)). The result effectively represents a proposed set of activities, and it is up to the caller to determine whether and how those activities are actually carried out and/or persisted.\",
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
    },
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://www.hl7.org/Special/committees/dss\"
        }
      ]
    }
  ],
  \"date\": \"2026-05-28T22:17:06+00:00\",
  \"description\": \"The apply operation applies a PlanDefinition to a given subject or group of subjects, instantiating applicable actions and returning the results as bundles of request resources.\",
  \"experimental\": false,
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 3
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"normative\"
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-wg\",
      \"valueCode\": \"cds\"
    }
  ],
  \"id\": \"PlanDefinition-apply\",
  \"instance\": true,
  \"jurisdiction\": [
    {
      \"coding\": [
        {
          \"code\": \"001\",
          \"display\": \"World\",
          \"system\": \"http://unstats.un.org/unsd/methods/m49/m49.htm\"
        }
      ]
    }
  ],
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2026-05-28T22:17:06.960+00:00\"
  },
  \"name\": \"Apply\",
  \"parameter\": [
    {
      \"documentation\": \"The plan definition to be applied. If the operation is invoked at the instance level, this parameter is not allowed; if the operation is invoked at the type level, this parameter is required, or a url (and optionally version) must be supplied\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"planDefinition\",
      \"scope\": [
        \"type\"
      ],
      \"type\": \"PlanDefinition\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The url of the plan definition to be applied. If the operation is invoked at the instance level, this parameter is not allowed; if the operation is invoked at the type level, this parameter (and optionally the version), or the planDefinition parameter must be supplied\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"url\",
      \"scope\": [
        \"type\"
      ],
      \"targetProfile\": [
        \"http://hl7.org/fhir/StructureDefinition/PlanDefinition\"
      ],
      \"type\": \"canonical\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The version of the plan definition to be applied. If the operation is invoked at the instance level, this parameter is not allowed; if the operation is invoked at the type level, this parameter may only be used if the url parameter is supplied.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"version\",
      \"scope\": [
        \"type\"
      ],
      \"type\": \"string\",
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
      \"documentation\": \"A Bundle for each input subject that is the result of applying the plan definition to that subject. Note that even though there is a single parameter named return of type Bundle, it is a multi-cardinality parameter, and so will still be returned using a Parameters resource, as described in the general operations framework (https://hl7.org/fhir/R4/operations.html#response).\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"return\",
      \"type\": \"Bundle\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 International / Clinical Decision Support\",
  \"resource\": [
    \"PlanDefinition\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"active\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p class=\\\"res-header-id\\\">\\n              <b>Generated Narrative: OperationDefinition PlanDefinition-apply</b>\\n            </p>\\n            <a name=\\\"PlanDefinition-apply\\\"> </a>\\n            <a name=\\\"hcPlanDefinition-apply\\\"> </a>\\n            <p>URL: [base]/PlanDefinition/$apply</p>\\n            <p>URL: [base]/PlanDefinition/[id]/$apply</p>\\n            <h3>Parameters</h3>\\n\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>planDefinition</td>\\n\\n                <td>type</td>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"plandefinition.html\\\">PlanDefinition</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The plan definition to be applied. If the operation is invoked at the instance level, this parameter is not allowed; if the operation is invoked at the type level, this parameter is required, or a url (and optionally version) must be supplied</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>url</td>\\n\\n                <td>type</td>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a> (\\n                  <a href=\\\"plandefinition.html\\\" title=\\\"http://hl7.org/fhir/StructureDefinition/PlanDefinition\\\">PlanDefinition</a>)\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The url of the plan definition to be applied. If the operation is invoked at the instance level, this parameter is not allowed; if the operation is invoked at the type level, this parameter (and optionally the version), or the planDefinition parameter must be supplied</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>version</td>\\n\\n                <td>type</td>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The version of the plan definition to be applied. If the operation is invoked at the instance level, this parameter is not allowed; if the operation is invoked at the type level, this parameter may only be used if the url parameter is supplied.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>subject</td>\\n\\n                <td/>\\n\\n                <td>1..*</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                  <br/>(\\n                  <a href=\\\"search.html#reference\\\">reference</a>)\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The subject(s) that is/are the target of the plan to be applied. The subject may be a Patient, Practitioner, Organization, Location, Device, or Group. Subjects provided in this parameter will be resolved as the subject of the PlanDefinition based on the type of the subject. If multiple subjects of the same type are provided, the behavior is implementation-defined</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>encounter</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                  <br/>(\\n                  <a href=\\\"search.html#reference\\\">reference</a>)\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The encounter in context, if any</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>practitioner</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                  <br/>(\\n                  <a href=\\\"search.html#reference\\\">reference</a>)\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The practitioner applying the plan definition</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>organization</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                  <br/>(\\n                  <a href=\\\"search.html#reference\\\">reference</a>)\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The organization applying the plan definition</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>userType</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#CodeableConcept\\\">CodeableConcept</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The type of user initiating the request, e.g. patient, healthcare provider, or specific type of healthcare provider (physician, nurse, etc.)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>userLanguage</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#CodeableConcept\\\">CodeableConcept</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Preferred language of the person using the system</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>userTaskContext</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#CodeableConcept\\\">CodeableConcept</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The task the system user is performing, e.g. laboratory results review, medication list review, etc. This information can be used to tailor decision support outputs, such as recommended information resources</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>setting</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#CodeableConcept\\\">CodeableConcept</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The current setting of the request (inpatient, outpatient, etc.)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>settingContext</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#CodeableConcept\\\">CodeableConcept</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Additional detail about the setting of the request, if any</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>return</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"bundle.html\\\">Bundle</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>A Bundle for each input subject that is the result of applying the plan definition to that subject. Note that even though there is a single parameter named return of type Bundle, it is a multi-cardinality parameter, and so will still be returned using a Parameters resource, as described in the general operations framework (https://hl7.org/fhir/R4/operations.html#response).</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n\\n            <div>\\n              <p>The result of this operation is a Bundle for each subject, where the Bundle contains Request resources that are the direct result of applying the PlanDefinition to that subject. The Bundle will have entries for each of the applicable actions in the PlanDefinition based on evaluating the applicability condition in context, and producing Request resources based on the definition element for each applicable action.</p>\\n\\n              <p>For each applicable action, the definition is applied as described in the $apply operation of the ActivityDefinition resource, and the resulting resource is added as an entry to the Bundle. The resulting Bundle may be any combination of Request resources, including CarePlan, RequestOrchestration, and individual Request resources such as ServiceRequest and MedicationRequest.</p>\\n\\n              <p>Note that to preserve the structure of the PlanDefinition, systems may choose to return the results in a RequestOrchestration. In this case, the individual request resources will have an intent of \\n                <code>option</code>, meaning the their intent is governed by the RequestOrchestraiont.\\n              </p>\\n\\n              <p>If the ActivityDefinition includes library references, those libraries will be available to the evaluated expressions. If those libraries have parameters, those parameters will be bound by name to the parameters given to the operation. In addition, parameters to the $apply operation are available within dynamicValue expressions as context variables, accessible by the name of the parameter, prefixed with a percent (%) symbol.</p>\\n\\n              <p>For a more detailed description, refer to the PlanDefinition and ActivityDefinition resource documentation. Note that result of this operation is transient (i.e. none of the resources created by the operation are persisted in the server, they are all returned as entries in the result Bundle(s)). The result effectively represents a proposed set of activities, and it is up to the caller to determine whether and how those activities are actually carried out and/or persisted.</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"generated\"
  },
  \"title\": \"Apply\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/PlanDefinition-apply\",
  \"version\": \"6.0.0-ballot4\"
}"))
(define (PlanDefinition-apply-operation handler)
  (define code "apply")
  (list (operation-entry 'type code "PlanDefinition" handler)
        (operation-entry 'instance code "PlanDefinition" handler)))
(define care-gaps-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
  \"code\": \"care-gaps\",
  \"comment\": \"The effect of invoking this operation is to calculate the gaps in care for one or more measures and to return one or more Bundles describing the gaps in care results of each measure for the specified gaps through period and for the given subject. Because more than one Bundle may be returned, the result of the operation must be returned using the Parameter resource even if the result is a single Bundle. Note that it is up to the server to determine whether or not the generated care gaps report is persisted. If the server does not persist the results, the operation does not affect state and can be invoked with a GET.\",
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
    },
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://www.hl7.org/Special/committees/cqi\"
        }
      ]
    }
  ],
  \"date\": \"2026-05-28T22:17:06+00:00\",
  \"description\": \"The care-gaps operation is used to determine gaps-in-care based on the results of quality measures\",
  \"experimental\": false,
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 3
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"normative\"
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-wg\",
      \"valueCode\": \"cqi\"
    }
  ],
  \"id\": \"Measure-care-gaps\",
  \"instance\": false,
  \"jurisdiction\": [
    {
      \"coding\": [
        {
          \"code\": \"001\",
          \"display\": \"World\",
          \"system\": \"http://unstats.un.org/unsd/methods/m49/m49.htm\"
        }
      ]
    }
  ],
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2026-05-28T22:17:06.960+00:00\"
  },
  \"name\": \"CareGaps\",
  \"parameter\": [
    {
      \"documentation\": \"The URL of a measure for which the gaps in care report will be created. A measure URL is specified in the [url](https://www.hl7.org/fhir/measure-definitions.html#Measure.url) element of the Measure resource. The measure URL remains the same when the measure is stored on different servers.\",
      \"max\": \"*\",
      \"min\": 1,
      \"name\": \"measureUrl\",
      \"type\": \"canonical\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The start of a gaps through period. This may be the start of the measurement period defined by a measure, or a customized desired performance period start date determined by a payer, a provider, a measure program, and etc.\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"periodStart\",
      \"type\": \"date\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The end of a gaps through period (the gaps through date). The gaps through date could be a past date or a future date. For example, today's date is 2020-06-18, 1) if periodEnd date is 2020-09-30, it returns gaps through 2020-09-30, and 2) if the periodEnd date is 2020-05-31, it returns gaps through 2020-05-31.\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"periodEnd\",
      \"type\": \"date\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Subject(s) for which the care gaps report will be produced. The subject may be a Patient, Practitioner, PractitionerRole, Organization, Location, Device, or Group. Subjects provided in this parameter SHALL match the subjectType of the measure being evaluated (e.g. if the Measure.group.subjectType is Patient, the subject SHALL be a reference to a Patient or a Group of Patients). If no subject is provided, what subjects are evaluated is up to the server. This parameter cannot be used with the subjectGroup parameter.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"subject\",
      \"searchType\": \"reference\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Subject for which the gaps in care report will be created is provided as a Group resource. Subjects provided in this parameter SHALL match the subjectType of the measure being evaluated.  (e.g. if the Measure.group.subjectType is Patient, the subject SHALL be a reference to a Patient or a Group of Patients). If no subject is provided, what subjects are evaluated is up to the server. This parameter cannot be used with the subject parameter.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"subjectGroup\",
      \"type\": \"Group\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Reference to a [Practitioner](practitioner.html) for which the gaps in care report will be created. For a practitioner focused gaps in care report, this is a required In Parameter. The Server needs to make sure that practitioner is authorized to get the gaps in care report for and know what measures the practitioner are eligible or qualified.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"practitioner\",
      \"searchType\": \"reference\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The location(s) for which the gaps in care report will be run. This parameter is reflected in the location element of the resulting MeasureReport(s).\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"location\",
      \"searchType\": \"reference\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The provider for which the report will be run. This may be a reference to a Practitioner, PractitionerRole, or Organization. If specified, systems MAY use this information to determine subjects for which the measure will be calculated, but how subjects are determined is implementation-specific. This parameter is reflected in the reporter element of the resulting MeasureReport(s). This parameter cannot be used with the reporterResource parameter.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"reporter\",
      \"searchType\": \"reference\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The provider for which the report will be run, provided as a Practitioner, PractitionerRole, or Organization resource. This is intended to support the use case in which the organization information is not on the server performing the evaluation, for example an [ad-hoc group of practitioners](clinicalreasoning-quality-reporting.html#ad-hoc-organizations) that are part of a provider group. This parameter is reflected in the reporter element of the resulting MeasureReport(s). This parameter cannot be used with the reporter parameter.\",
      \"extension\": [
        {
          \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
          \"valueUri\": \"Practitioner\"
        },
        {
          \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
          \"valueUri\": \"PractitionerRole\"
        },
        {
          \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
          \"valueUri\": \"Organization\"
        }
      ],
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"reporterResource\",
      \"searchType\": \"reference\",
      \"type\": \"Element\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Indicates status of a care gap. For all [open, closed, and prospective gaps], three seperate status parameters must be provided. For a positive proportion measure, gap means the patient is not in the numerator. For an inverse (negative) proportion measure (e.g., Diabetes: Hemoglobin A1c (HbA1c) Poor Control (> 9%)), gap means the patient is in the numerator.\",
      \"max\": \"*\",
      \"min\": 1,
      \"name\": \"status\",
      \"type\": \"code\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The isDocument parameter controls whether a Gaps in Care Composition is returned in the Bundle (i.e. if the Bundle is of type 'Document'). When 'true,' the returned Bundles contain the Gaps in Care Composition. This parameter defaults to 'true.'\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"isDocument\",
      \"type\": \"boolean\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Any input parameters for the evaluation. Parameters defined in this input will be made available by name to the CQL expression. Parameter types are mapped to CQL as specified in the [Using CQL with FHIR](https://hl7.org/fhir/uv/cql/) implementation guide. If a parameter appears more than once in the input Parameters resource, it is represented with a List in the input CQL. If a parameter has parts, it is represented as a Tuple in the input CQL.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"parameters\",
      \"type\": \"Parameters\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Specifies an asset-collection library that provides dependency version resolution and expansion rules for the operation. See the version manifest discussion in the [Canonical Resource Management Infrastructure IG](http://hl7.org/fhir/uv/crmi/version-manifest.html) for a complete description of how manifest values are used to provide defaults for dependency version resolution and expansion parameters. Parameters specified directly in the operation override behaviors specified by the manifest parameter. In general, if this parameter is supplied, it is expected to be used in nested operation calls. For example, in evaluating a measure, if the expansion of a value set is required, this parameter SHALL be supplied to that expansion.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"manifest\",
      \"targetProfile\": [
        \"http://hl7.org/fhir/StructureDefinition/Library\"
      ],
      \"type\": \"canonical\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The $care-gaps operation returns zero or more document Bundles, one for each input subject. Consistent with FHIR Documents generally, each Bundle SHALL have a Composition as the first entry in the document Bundle, and that Composition SHALL be limited to a single subject. See the [guidance on Bundle structure](https://build.fhir.org/clinicalreasoning-quality-reporting.html#bundles-organized-by-subject) for discussion about the Bundle content and organization.\\\\n\\\\nNote that even though there is a single parameter named return of type Bundle, it is a multi-cardinality parameter, and so will still be returned using a Parameters resource, as described in the general operations framework [response](operations.html#response).\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"return\",
      \"type\": \"Bundle\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 International / Clinical Quality Information\",
  \"resource\": [
    \"Measure\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"active\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p class=\\\"res-header-id\\\">\\n              <b>Generated Narrative: OperationDefinition Measure-care-gaps</b>\\n            </p>\\n            <a name=\\\"Measure-care-gaps\\\"> </a>\\n            <a name=\\\"hcMeasure-care-gaps\\\"> </a>\\n            <p>URL: [base]/Measure/$care-gaps</p>\\n            <h3>Parameters</h3>\\n\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>measureUrl</td>\\n\\n                <td/>\\n\\n                <td>1..*</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The URL of a measure for which the gaps in care report will be created. A measure URL is specified in the \\n                      <a href=\\\"https://www.hl7.org/fhir/measure-definitions.html#Measure.url\\\">url</a> element of the Measure resource. The measure URL remains the same when the measure is stored on different servers.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>periodStart</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#date\\\">date</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The start of a gaps through period. This may be the start of the measurement period defined by a measure, or a customized desired performance period start date determined by a payer, a provider, a measure program, and etc.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>periodEnd</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#date\\\">date</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The end of a gaps through period (the gaps through date). The gaps through date could be a past date or a future date. For example, today's date is 2020-06-18, 1) if periodEnd date is 2020-09-30, it returns gaps through 2020-09-30, and 2) if the periodEnd date is 2020-05-31, it returns gaps through 2020-05-31.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>subject</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                  <br/>(\\n                  <a href=\\\"search.html#reference\\\">reference</a>)\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Subject(s) for which the care gaps report will be produced. The subject may be a Patient, Practitioner, PractitionerRole, Organization, Location, Device, or Group. Subjects provided in this parameter SHALL match the subjectType of the measure being evaluated (e.g. if the Measure.group.subjectType is Patient, the subject SHALL be a reference to a Patient or a Group of Patients). If no subject is provided, what subjects are evaluated is up to the server. This parameter cannot be used with the subjectGroup parameter.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>subjectGroup</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"group.html\\\">Group</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Subject for which the gaps in care report will be created is provided as a Group resource. Subjects provided in this parameter SHALL match the subjectType of the measure being evaluated.  (e.g. if the Measure.group.subjectType is Patient, the subject SHALL be a reference to a Patient or a Group of Patients). If no subject is provided, what subjects are evaluated is up to the server. This parameter cannot be used with the subject parameter.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>practitioner</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                  <br/>(\\n                  <a href=\\\"search.html#reference\\\">reference</a>)\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Reference to a \\n                      <a href=\\\"practitioner.html\\\">Practitioner</a> for which the gaps in care report will be created. For a practitioner focused gaps in care report, this is a required In Parameter. The Server needs to make sure that practitioner is authorized to get the gaps in care report for and know what measures the practitioner are eligible or qualified.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>location</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                  <br/>(\\n                  <a href=\\\"search.html#reference\\\">reference</a>)\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The location(s) for which the gaps in care report will be run. This parameter is reflected in the location element of the resulting MeasureReport(s).</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>reporter</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                  <br/>(\\n                  <a href=\\\"search.html#reference\\\">reference</a>)\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The provider for which the report will be run. This may be a reference to a Practitioner, PractitionerRole, or Organization. If specified, systems MAY use this information to determine subjects for which the measure will be calculated, but how subjects are determined is implementation-specific. This parameter is reflected in the reporter element of the resulting MeasureReport(s). This parameter cannot be used with the reporterResource parameter.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>reporterResource</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"practitioner.html\\\">Practitioner</a> | \\n                  <a href=\\\"practitionerrole.html\\\">PractitionerRole</a> | \\n                  <a href=\\\"organization.html\\\">Organization</a>\\n                  <br/>(\\n                  <a href=\\\"search.html#reference\\\">reference</a>)\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The provider for which the report will be run, provided as a Practitioner, PractitionerRole, or Organization resource. This is intended to support the use case in which the organization information is not on the server performing the evaluation, for example an \\n                      <a href=\\\"clinicalreasoning-quality-reporting.html#ad-hoc-organizations\\\">ad-hoc group of practitioners</a> that are part of a provider group. This parameter is reflected in the reporter element of the resulting MeasureReport(s). This parameter cannot be used with the reporter parameter.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>status</td>\\n\\n                <td/>\\n\\n                <td>1..*</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Indicates status of a care gap. For all [open, closed, and prospective gaps], three seperate status parameters must be provided. For a positive proportion measure, gap means the patient is not in the numerator. For an inverse (negative) proportion measure (e.g., Diabetes: Hemoglobin A1c (HbA1c) Poor Control (&gt; 9%)), gap means the patient is in the numerator.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>isDocument</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The isDocument parameter controls whether a Gaps in Care Composition is returned in the Bundle (i.e. if the Bundle is of type 'Document'). When 'true,' the returned Bundles contain the Gaps in Care Composition. This parameter defaults to 'true.'</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>parameters</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"parameters.html\\\">Parameters</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Any input parameters for the evaluation. Parameters defined in this input will be made available by name to the CQL expression. Parameter types are mapped to CQL as specified in the \\n                      <a href=\\\"https://hl7.org/fhir/uv/cql/\\\">Using CQL with FHIR</a> implementation guide. If a parameter appears more than once in the input Parameters resource, it is represented with a List in the input CQL. If a parameter has parts, it is represented as a Tuple in the input CQL.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>manifest</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a> (\\n                  <a href=\\\"library.html\\\" title=\\\"http://hl7.org/fhir/StructureDefinition/Library\\\">Library</a>)\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Specifies an asset-collection library that provides dependency version resolution and expansion rules for the operation. See the version manifest discussion in the \\n                      <a href=\\\"http://hl7.org/fhir/uv/crmi/version-manifest.html\\\">Canonical Resource Management Infrastructure IG</a> for a complete description of how manifest values are used to provide defaults for dependency version resolution and expansion parameters. Parameters specified directly in the operation override behaviors specified by the manifest parameter. In general, if this parameter is supplied, it is expected to be used in nested operation calls. For example, in evaluating a measure, if the expansion of a value set is required, this parameter SHALL be supplied to that expansion.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>return</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"bundle.html\\\">Bundle</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The $care-gaps operation returns zero or more document Bundles, one for each input subject. Consistent with FHIR Documents generally, each Bundle SHALL have a Composition as the first entry in the document Bundle, and that Composition SHALL be limited to a single subject. See the \\n                      <a href=\\\"https://build.fhir.org/clinicalreasoning-quality-reporting.html#bundles-organized-by-subject\\\">guidance on Bundle structure</a> for discussion about the Bundle content and organization.\\\\n\\\\nNote that even though there is a single parameter named return of type Bundle, it is a multi-cardinality parameter, and so will still be returned using a Parameters resource, as described in the general operations framework \\n                      <a href=\\\"operations.html#response\\\">response</a>.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n\\n            <div>\\n              <p>The effect of invoking this operation is to calculate the gaps in care for one or more measures and to return one or more Bundles describing the gaps in care results of each measure for the specified gaps through period and for the given subject. Because more than one Bundle may be returned, the result of the operation must be returned using the Parameter resource even if the result is a single Bundle. Note that it is up to the server to determine whether or not the generated care gaps report is persisted. If the server does not persist the results, the operation does not affect state and can be invoked with a GET.</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"generated\"
  },
  \"title\": \"Care Gaps\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Measure-care-gaps\",
  \"version\": \"6.0.0-ballot4\"
}"))
(define (care-gaps-operation handler)
  (define code "care-gaps")
  (list (operation-entry 'type code "Measure" handler)))
(define collect-data-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
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
    },
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://www.hl7.org/Special/committees/cqi\"
        }
      ]
    }
  ],
  \"date\": \"2026-05-28T22:17:06+00:00\",
  \"description\": \"The collect-data operation is used to collect the data-of-interest for the given measure. Note that the use of the [X-Provenance header data](provenance.html#header) with data that establishes provenance being submitted/collected **SHOULD** be supported.  This provides the capability for associating the provider with the data submitted through the $collect-data transaction. If the X-Provenance header is used it should be consistent with the `reporter` element in the DEQM Data Exchange MeasureReport Profile.\",
  \"experimental\": false,
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 3
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"normative\"
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-wg\",
      \"valueCode\": \"cqi\"
    }
  ],
  \"id\": \"Measure-collect-data\",
  \"instance\": false,
  \"jurisdiction\": [
    {
      \"coding\": [
        {
          \"code\": \"001\",
          \"display\": \"World\",
          \"system\": \"http://unstats.un.org/unsd/methods/m49/m49.htm\"
        }
      ]
    }
  ],
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2026-05-28T22:17:06.960+00:00\"
  },
  \"name\": \"CollectData\",
  \"parameter\": [
    {
      \"documentation\": \"This the the URL of a measure for which the data-of-interest will be collected. A measure URL is specified in the url element of the Measure resource. The measure URL remains the same when the measure is stored on different servers.\",
      \"max\": \"*\",
      \"min\": 1,
      \"name\": \"measureUrl\",
      \"type\": \"canonical\",
      \"use\": \"in\"
    },
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
      \"documentation\": \"Subject(s) for which the data-of-interest for the measure will be collected. The subject may be a Patient, Practitioner, PractitionerRole, Organization, Location, Device, or Group. Subjects provided in this parameter SHALL match the subjectType of the measure for which data is being collected (e.g. if the Measure.group.subjectType is Patient, the subject SHALL be a reference to a Patient or a Group of Patients). If no subject is provided, subjects for which data is collected is up to the server. This parameter cannot be used with the subjectGroup parameter.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"subject\",
      \"searchType\": \"reference\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Subjects for which the data-of-interest for the measure will be collected, provided as a Group resource. Subjects provided in this parameter SHALL match the subjectType of the measure for which data is being collected. (e.g. if the Measure.group.subjectType is Patient, the subject SHALL be a reference to a Patient or a Group of Patients). If no subject is provided, subjects for which data is collected is up to the server. This parameter cannot be used with the subject parameter.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"subjectGroup\",
      \"type\": \"Group\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The provider for which the data-of-interest will be collected. This may be a reference to a Practitioner, PractitionerRole, or Organization. If specified, systems MAY use this information to determine subjects for which the data-of-interest will be calculated, but how subjects are determined is implementation-specific. This parameter is reflected in the reporter element of the resulting MeasureReport(s). This parameter cannot be used with the reporterResource parameter.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"reporter\",
      \"searchType\": \"reference\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The provider for which the report will be run, provided as a Practitioner, PractitionerRole, or Organization resource. This is intended to support the use case in which the organization information is not on the server performing the evaluation, for example an [ad-hoc group of practitioners](clinicalreasoning-quality-reporting.html#ad-hoc-organizations) that are part of a provider group. This parameter is reflected in the reporter element of the resulting MeasureReport(s). This parameter cannot be used with the reporter parameter.\",
      \"extension\": [
        {
          \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
          \"valueUri\": \"Practitioner\"
        },
        {
          \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
          \"valueUri\": \"PractitionerRole\"
        },
        {
          \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
          \"valueUri\": \"Organization\"
        }
      ],
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"reporterResource\",
      \"searchType\": \"reference\",
      \"type\": \"Element\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The location(s) for which the data-of-interest will be collected. This parameter is reflected in the location element of the resulting MeasureReport(s).\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"location\",
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
      \"documentation\": \"Any input parameters for the evaluation. Parameters defined in this input will be made available by name to the CQL expression. Parameter types are mapped to CQL as specified in the [Using CQL with FHIR](https://hl7.org/fhir/uv/cql/) implementation guide. If a parameter appears more than once in the input Parameters resource, it is represented with a List in the input CQL. If a parameter has parts, it is represented as a Tuple in the input CQL.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"parameters\",
      \"type\": \"Parameters\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Specifies an asset-collection library that provides dependency version resolution and expansion rules for the operation. See the version manifest discussion in the [Canonical Resource Management Infrastructure IG](http://hl7.org/fhir/uv/crmi/version-manifest.html) for a complete description of how manifest values are used to provide defaults for dependency version resolution and expansion parameters. Parameters specified directly in the operation override behaviors specified by the manifest parameter. In general, if this parameter is supplied, it is expected to be used in nested operation calls. For example, in evaluating a measure, if the expansion of a value set is required, this parameter SHALL be supplied to that expansion.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"manifest\",
      \"targetProfile\": [
        \"http://hl7.org/fhir/StructureDefinition/Library\"
      ],
      \"type\": \"canonical\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Indicates whether data collected conform to the appropriate profiles as specified by the measure.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"validateResources\",
      \"type\": \"boolean\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The results of the data collection, returned as a Bundle for each input subject. The first entries in each Bundle are MeasureReport(s) corresponding to the measures for which data was collected. The MeasureReport resources SHALL have a type of data-exchange. Subsequent entries in each Bundle are resources representing the data-of-interest for the measures, and referenced from the evaluatedResource element of the corresponding MeasureReport resources. See the [guidance](clinicalreasoning-quality-reporting.html#bundles-organized-by-subject) on Bundle structure for discussion about the Bundle content and organization.\\\\n\\\\nNote that even though there is a single parameter named return of type Bundle, it is a multi-cardinality parameter, and so will still be returned using a Parameters resource, as described in the general operations framework [response](operations.html#response).\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"return\",
      \"type\": \"Bundle\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 International / Clinical Quality Information\",
  \"resource\": [
    \"Measure\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"active\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p class=\\\"res-header-id\\\">\\n              <b>Generated Narrative: OperationDefinition Measure-collect-data</b>\\n            </p>\\n            <a name=\\\"Measure-collect-data\\\"> </a>\\n            <a name=\\\"hcMeasure-collect-data\\\"> </a>\\n            <p>URL: [base]/Measure/$collect-data</p>\\n            <h3>Parameters</h3>\\n\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>measureUrl</td>\\n\\n                <td/>\\n\\n                <td>1..*</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>This the the URL of a measure for which the data-of-interest will be collected. A measure URL is specified in the url element of the Measure resource. The measure URL remains the same when the measure is stored on different servers.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>periodStart</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#date\\\">date</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The start of the measurement period. In keeping with the semantics of the date parameter used in the FHIR search operation, the period will start at the beginning of the period implied by the supplied timestamp. E.g. a value of 2014 would set the period start to be 2014-01-01T00:00:00 inclusive</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>periodEnd</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#date\\\">date</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The end of the measurement period. The period will end at the end of the period implied by the supplied timestamp. E.g. a value of 2014 would set the period end to be 2014-12-31T23:59:59 inclusive</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>subject</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                  <br/>(\\n                  <a href=\\\"search.html#reference\\\">reference</a>)\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Subject(s) for which the data-of-interest for the measure will be collected. The subject may be a Patient, Practitioner, PractitionerRole, Organization, Location, Device, or Group. Subjects provided in this parameter SHALL match the subjectType of the measure for which data is being collected (e.g. if the Measure.group.subjectType is Patient, the subject SHALL be a reference to a Patient or a Group of Patients). If no subject is provided, subjects for which data is collected is up to the server. This parameter cannot be used with the subjectGroup parameter.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>subjectGroup</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"group.html\\\">Group</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Subjects for which the data-of-interest for the measure will be collected, provided as a Group resource. Subjects provided in this parameter SHALL match the subjectType of the measure for which data is being collected. (e.g. if the Measure.group.subjectType is Patient, the subject SHALL be a reference to a Patient or a Group of Patients). If no subject is provided, subjects for which data is collected is up to the server. This parameter cannot be used with the subject parameter.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>reporter</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                  <br/>(\\n                  <a href=\\\"search.html#reference\\\">reference</a>)\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The provider for which the data-of-interest will be collected. This may be a reference to a Practitioner, PractitionerRole, or Organization. If specified, systems MAY use this information to determine subjects for which the data-of-interest will be calculated, but how subjects are determined is implementation-specific. This parameter is reflected in the reporter element of the resulting MeasureReport(s). This parameter cannot be used with the reporterResource parameter.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>reporterResource</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"practitioner.html\\\">Practitioner</a> | \\n                  <a href=\\\"practitionerrole.html\\\">PractitionerRole</a> | \\n                  <a href=\\\"organization.html\\\">Organization</a>\\n                  <br/>(\\n                  <a href=\\\"search.html#reference\\\">reference</a>)\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The provider for which the report will be run, provided as a Practitioner, PractitionerRole, or Organization resource. This is intended to support the use case in which the organization information is not on the server performing the evaluation, for example an \\n                      <a href=\\\"clinicalreasoning-quality-reporting.html#ad-hoc-organizations\\\">ad-hoc group of practitioners</a> that are part of a provider group. This parameter is reflected in the reporter element of the resulting MeasureReport(s). This parameter cannot be used with the reporter parameter.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>location</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                  <br/>(\\n                  <a href=\\\"search.html#reference\\\">reference</a>)\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The location(s) for which the data-of-interest will be collected. This parameter is reflected in the location element of the resulting MeasureReport(s).</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>lastReceivedOn</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#dateTime\\\">dateTime</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The date the results of this measure were last received. This parameter used to indicate when the last time data for this measure was collected. This information is used to support incremental data collection scenarios</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>parameters</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"parameters.html\\\">Parameters</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Any input parameters for the evaluation. Parameters defined in this input will be made available by name to the CQL expression. Parameter types are mapped to CQL as specified in the \\n                      <a href=\\\"https://hl7.org/fhir/uv/cql/\\\">Using CQL with FHIR</a> implementation guide. If a parameter appears more than once in the input Parameters resource, it is represented with a List in the input CQL. If a parameter has parts, it is represented as a Tuple in the input CQL.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>manifest</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a> (\\n                  <a href=\\\"library.html\\\" title=\\\"http://hl7.org/fhir/StructureDefinition/Library\\\">Library</a>)\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Specifies an asset-collection library that provides dependency version resolution and expansion rules for the operation. See the version manifest discussion in the \\n                      <a href=\\\"http://hl7.org/fhir/uv/crmi/version-manifest.html\\\">Canonical Resource Management Infrastructure IG</a> for a complete description of how manifest values are used to provide defaults for dependency version resolution and expansion parameters. Parameters specified directly in the operation override behaviors specified by the manifest parameter. In general, if this parameter is supplied, it is expected to be used in nested operation calls. For example, in evaluating a measure, if the expansion of a value set is required, this parameter SHALL be supplied to that expansion.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>validateResources</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Indicates whether data collected conform to the appropriate profiles as specified by the measure.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>return</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"bundle.html\\\">Bundle</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The results of the data collection, returned as a Bundle for each input subject. The first entries in each Bundle are MeasureReport(s) corresponding to the measures for which data was collected. The MeasureReport resources SHALL have a type of data-exchange. Subsequent entries in each Bundle are resources representing the data-of-interest for the measures, and referenced from the evaluatedResource element of the corresponding MeasureReport resources. See the \\n                      <a href=\\\"clinicalreasoning-quality-reporting.html#bundles-organized-by-subject\\\">guidance</a> on Bundle structure for discussion about the Bundle content and organization.\\\\n\\\\nNote that even though there is a single parameter named return of type Bundle, it is a multi-cardinality parameter, and so will still be returned using a Parameters resource, as described in the general operations framework \\n                      <a href=\\\"operations.html#response\\\">response</a>.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n\\n            <div>\\n              <p>The effect of invoking this operation is to gather the data required to perform an evaluation of the measure. If the lastReceivedOn parameter is supplied, only data that is new or has been changed since the lastReceivedOn date is included in the response. Note that the resulting MeasureReport is a transient resource</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"generated\"
  },
  \"title\": \"Collect Data\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Measure-collect-data\",
  \"version\": \"6.0.0-ballot4\"
}"))
(define (collect-data-operation handler)
  (define code "collect-data")
  (list (operation-entry 'type code "Measure" handler)))
(define convert-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
  \"code\": \"convert\",
  \"comment\": \"While the primary use of this operation is simple - converting a resource from one format to another, there are many potential uses including:\\n\\n* converting resources from one version to another\\n* restructuring information in a resource (e.g. moving method into/out of Observation.code)\\n* extracting data from a questionnaire\\n* converting CDA documents or v2 messages (as a binary resource) to a bundle (or vice versa) (or even openEHR or openMHealth). \\n\\nThese variants would all be associated with parameters that define and control these kind of conversions, though such parameters are not defined at this time. In the absence of any parameters, simple format conversion is all that will occur.\\n\\nFor this reason, implementers should be aware that:\\n\\n* the `return` resource type may be different from the `resource` parameter resource type (for example, it might be a bundle)\\n* binary resources may be represented directly using some other content-type (in other words, just post the content directly)\\n\\nImplementers are encouraged to provide feedback to HL7 about their use of this operation\",
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
    },
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://www.hl7.org/Special/committees/fiwg\"
        }
      ]
    }
  ],
  \"date\": \"2026-05-28T22:17:06+00:00\",
  \"description\": \"This operation takes a resource in one form, and returns to in another form. Both the `resource` and `return` parameters are a single resource. The primary use of this operation is to convert between formats (e.g. (XML -> JSON or vice versa)\",
  \"experimental\": false,
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 1
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"draft\"
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-wg\",
      \"valueCode\": \"fhir\"
    }
  ],
  \"id\": \"Resource-convert\",
  \"instance\": false,
  \"jurisdiction\": [
    {
      \"coding\": [
        {
          \"code\": \"001\",
          \"display\": \"World\",
          \"system\": \"http://unstats.un.org/unsd/methods/m49/m49.htm\"
        }
      ]
    }
  ],
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2026-05-28T22:17:06.960+00:00\"
  },
  \"name\": \"Convert\",
  \"parameter\": [
    {
      \"documentation\": \"The resource that is to be converted\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"resource\",
      \"type\": \"Resource\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The resource after conversion\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"return\",
      \"type\": \"Resource\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 International / FHIR Infrastructure\",
  \"resource\": [
    \"Resource\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": true,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p class=\\\"res-header-id\\\">\\n              <b>Generated Narrative: OperationDefinition Resource-convert</b>\\n            </p>\\n            <a name=\\\"Resource-convert\\\"> </a>\\n            <a name=\\\"hcResource-convert\\\"> </a>\\n            <p>URL: [base]/$convert</p>\\n            <h3>Parameters</h3>\\n\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>resource</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"resource.html\\\">Resource</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The resource that is to be converted</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>return</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"resource.html\\\">Resource</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The resource after conversion</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n\\n            <div>\\n              <p>While the primary use of this operation is simple - converting a resource from one format to another, there are many potential uses including:</p>\\n\\n              <ul>\\n\\n                <li>converting resources from one version to another</li>\\n\\n                <li>restructuring information in a resource (e.g. moving method into/out of Observation.code)</li>\\n\\n                <li>extracting data from a questionnaire</li>\\n\\n                <li>converting CDA documents or v2 messages (as a binary resource) to a bundle (or vice versa) (or even openEHR or openMHealth).</li>\\n\\n              </ul>\\n\\n              <p>These variants would all be associated with parameters that define and control these kind of conversions, though such parameters are not defined at this time. In the absence of any parameters, simple format conversion is all that will occur.</p>\\n\\n              <p>For this reason, implementers should be aware that:</p>\\n\\n              <ul>\\n\\n                <li>the \\n                  <code>return</code> resource type may be different from the \\n                  <code>resource</code> parameter resource type (for example, it might be a bundle)\\n                </li>\\n\\n                <li>binary resources may be represented directly using some other content-type (in other words, just post the content directly)</li>\\n\\n              </ul>\\n\\n              <p>Implementers are encouraged to provide feedback to HL7 about their use of this operation</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"generated\"
  },
  \"title\": \"Convert from one form to another\",
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Resource-convert\",
  \"version\": \"6.0.0-ballot4\"
}"))
(define (convert-operation handler)
  (define code "convert")
  (list (operation-entry 'system code #f handler)))
(define current-canonical-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
  \"code\": \"current-canonical\",
  \"comment\": \"If none of the instances define the versionAlgorithm to use, a server may  dynamically attempt to determine which versioning system is implied by the data.\\r\\rIf the instances found with the provided canonical URL define different versionAlgorithm values the server may return an error.\\r\\rNote that the *CanonicalResource* is an interface and not an actual resource type, as such the operation is actually called on the canonical resource types such as CodeSystem, Questionnaire etc.\",
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
    },
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://www.hl7.org/Special/committees/fiwg\"
        }
      ]
    }
  ],
  \"date\": \"2026-05-28T22:17:06+00:00\",
  \"description\": \"Returns the most current version of the canonical resource with the specified url available on the server.  It optionally also allows filtering to only expose the most current version with a particular status or set of statuses.\\r\\rNote that 'current' is determined by comparing version values using the specified versionAlgorithm, NOT by looking at lastUpdated.\",
  \"experimental\": false,
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 1
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"normative\"
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-wg\",
      \"valueCode\": \"fhir\"
    }
  ],
  \"id\": \"CanonicalResource-current-canonical\",
  \"instance\": false,
  \"jurisdiction\": [
    {
      \"coding\": [
        {
          \"code\": \"001\",
          \"display\": \"World\",
          \"system\": \"http://unstats.un.org/unsd/methods/m49/m49.htm\"
        }
      ]
    }
  ],
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2026-05-28T22:17:06.960+00:00\"
  },
  \"name\": \"CurrentCanonical\",
  \"parameter\": [
    {
      \"documentation\": \"This is the canonical URL (with no version declared)\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"url\",
      \"type\": \"uri\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The statuses to allow to be returned. If no status codes are provided, then any status is ok\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"status\",
      \"type\": \"code\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"If no resources can be found, will return nothing.  If multiple resources are found for the specified statuses and 'most current' can't be determined by comparing the versions, the operation will fail with an operation outcome.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"result\",
      \"type\": \"CanonicalResource\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 International / FHIR Infrastructure\",
  \"resource\": [
    \"CanonicalResource\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"active\",
  \"system\": true,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p class=\\\"res-header-id\\\">\\n              <b>Generated Narrative: OperationDefinition CanonicalResource-current-canonical</b>\\n            </p>\\n            <a name=\\\"CanonicalResource-current-canonical\\\"> </a>\\n            <a name=\\\"hcCanonicalResource-current-canonical\\\"> </a>\\n            <p>URL: [base]/$current-canonical</p>\\n            <p>URL: [base]/CanonicalResource/$current-canonical</p>\\n            <h3>Parameters</h3>\\n\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>url</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>This is the canonical URL (with no version declared)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>status</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The statuses to allow to be returned. If no status codes are provided, then any status is ok</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>result</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"canonicalresource.html\\\">CanonicalResource</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>If no resources can be found, will return nothing.  If multiple resources are found for the specified statuses and 'most current' can't be determined by comparing the versions, the operation will fail with an operation outcome.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n\\n            <div>\\n              <p>If none of the instances define the versionAlgorithm to use, a server may  dynamically attempt to determine which versioning system is implied by the data.</p>\\n\\n              <p>If the instances found with the provided canonical URL define different versionAlgorithm values the server may return an error.</p>\\n\\n              <p>Note that the \\n                <em>CanonicalResource</em> is an interface and not an actual resource type, as such the operation is actually called on the canonical resource types such as CodeSystem, Questionnaire etc.\\n              </p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"generated\"
  },
  \"title\": \"Fetch the current version of a canonical resource (based on canonical versioning)\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/CanonicalResource-current-canonical\",
  \"version\": \"6.0.0-ballot4\"
}"))
(define (current-canonical-operation handler)
  (define code "current-canonical")
  (list (operation-entry 'system code #f handler)
        (operation-entry 'type code "CanonicalResource" handler)))
(define ActivityDefinition-data-requirements-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
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
    },
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://www.hl7.org/Special/committees/dss\"
        }
      ]
    }
  ],
  \"date\": \"2026-05-28T22:17:06+00:00\",
  \"description\": \"The data-requirements operation aggregates and returns the parameters and data requirements for the activity definition and all its dependencies as a single module definition library\",
  \"experimental\": false,
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 3
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"normative\"
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-wg\",
      \"valueCode\": \"cds\"
    }
  ],
  \"id\": \"ActivityDefinition-data-requirements\",
  \"instance\": true,
  \"jurisdiction\": [
    {
      \"coding\": [
        {
          \"code\": \"001\",
          \"display\": \"World\",
          \"system\": \"http://unstats.un.org/unsd/methods/m49/m49.htm\"
        }
      ]
    }
  ],
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2026-05-28T22:17:06.960+00:00\"
  },
  \"name\": \"DataRequirements\",
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
  \"publisher\": \"HL7 International / Clinical Decision Support\",
  \"resource\": [
    \"ActivityDefinition\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"active\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p class=\\\"res-header-id\\\">\\n              <b>Generated Narrative: OperationDefinition ActivityDefinition-data-requirements</b>\\n            </p>\\n            <a name=\\\"ActivityDefinition-data-requirements\\\"> </a>\\n            <a name=\\\"hcActivityDefinition-data-requirements\\\"> </a>\\n            <p>URL: [base]/ActivityDefinition/[id]/$data-requirements</p>\\n            <h3>Parameters</h3>\\n\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>return</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"library.html\\\">Library</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The result of the requirements gathering represented as a module-definition Library that describes the aggregate parameters, data requirements, and dependencies of the activity definition</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n\\n            <div>\\n              <p>The effect of invoking this operation is to determine the aggregate set of data requirements and dependencies for the activity definition. The result is a Library resource with a type of module-definition that contains all the parameter definitions and data requirements of the activity definition and any libraries referenced by it. Implementations SHOULD aggregate data requirements intelligently (i.e. by collapsing overlapping data requirements)</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"generated\"
  },
  \"title\": \"Data Requirements\",
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/ActivityDefinition-data-requirements\",
  \"version\": \"6.0.0-ballot4\"
}"))
(define (ActivityDefinition-data-requirements-operation handler)
  (define code "data-requirements")
  (list (operation-entry 'instance code "ActivityDefinition" handler)))
(define Library-data-requirements-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
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
    },
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://www.hl7.org/Special/committees/dss\"
        }
      ]
    }
  ],
  \"date\": \"2026-05-28T22:17:06+00:00\",
  \"description\": \"The data-requirements operation aggregates and returns the parameters and data requirements for a resource and all its dependencies as a single module definition\",
  \"experimental\": false,
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 3
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"normative\"
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-wg\",
      \"valueCode\": \"cds\"
    }
  ],
  \"id\": \"Library-data-requirements\",
  \"instance\": true,
  \"jurisdiction\": [
    {
      \"coding\": [
        {
          \"code\": \"001\",
          \"display\": \"World\",
          \"system\": \"http://unstats.un.org/unsd/methods/m49/m49.htm\"
        }
      ]
    }
  ],
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2026-05-28T22:17:06.960+00:00\"
  },
  \"name\": \"DataRequirements\",
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
  \"publisher\": \"HL7 International / Clinical Decision Support\",
  \"resource\": [
    \"Library\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"active\",
  \"system\": true,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p class=\\\"res-header-id\\\">\\n              <b>Generated Narrative: OperationDefinition Library-data-requirements</b>\\n            </p>\\n            <a name=\\\"Library-data-requirements\\\"> </a>\\n            <a name=\\\"hcLibrary-data-requirements\\\"> </a>\\n            <p>URL: [base]/$data-requirements</p>\\n            <p>URL: [base]/Library/[id]/$data-requirements</p>\\n            <h3>Parameters</h3>\\n\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>target</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The target of the data requirements operation</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>return</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"library.html\\\">Library</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The result of the requirements gathering</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n\\n            <div>\\n              <p>The effect of invoking this operation is to determine the aggregate set of data requirements and dependencies for a given target resource. The result is a Library resource with a type of module-definition that contains all the parameter definitions and data requirements of the target resource and any libraries referenced by it. Implementations SHOULD aggregate data requirements intelligently (i.e. by collapsing overlapping data requirements)</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"generated\"
  },
  \"title\": \"Data Requirements\",
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Library-data-requirements\",
  \"version\": \"6.0.0-ballot4\"
}"))
(define (Library-data-requirements-operation handler)
  (define code "data-requirements")
  (list (operation-entry 'system code #f handler)
        (operation-entry 'instance code "Library" handler)))
(define Measure-data-requirements-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
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
    },
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://www.hl7.org/Special/committees/cqi\"
        }
      ]
    }
  ],
  \"date\": \"2026-05-28T22:17:06+00:00\",
  \"description\": \"The data-requirements operation aggregates and returns the parameters and data requirements for the measure and all its dependencies as a single module definition\",
  \"experimental\": false,
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 3
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"normative\"
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-wg\",
      \"valueCode\": \"cqi\"
    }
  ],
  \"id\": \"Measure-data-requirements\",
  \"instance\": true,
  \"jurisdiction\": [
    {
      \"coding\": [
        {
          \"code\": \"001\",
          \"display\": \"World\",
          \"system\": \"http://unstats.un.org/unsd/methods/m49/m49.htm\"
        }
      ]
    }
  ],
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2026-05-28T22:17:06.960+00:00\"
  },
  \"name\": \"DataRequirements\",
  \"parameter\": [
    {
      \"documentation\": \"The start of the measurement period. In keeping with the semantics of the date parameter used in the FHIR search operation, the period will start at the beginning of the period implied by the supplied timestamp. E.g. a value of 2014 would set the period start to be 2014-01-01T00:00:00 inclusive\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"periodStart\",
      \"type\": \"date\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The end of the measurement period. The period will end at the end of the period implied by the supplied timestamp. E.g. a value of 2014 would set the period end to be 2014-12-31T23:59:59 inclusive\",
      \"max\": \"1\",
      \"min\": 0,
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
  \"publisher\": \"HL7 International / Clinical Quality Information\",
  \"resource\": [
    \"Measure\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"active\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p class=\\\"res-header-id\\\">\\n              <b>Generated Narrative: OperationDefinition Measure-data-requirements</b>\\n            </p>\\n            <a name=\\\"Measure-data-requirements\\\"> </a>\\n            <a name=\\\"hcMeasure-data-requirements\\\"> </a>\\n            <p>URL: [base]/Measure/[id]/$data-requirements</p>\\n            <h3>Parameters</h3>\\n\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>periodStart</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#date\\\">date</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The start of the measurement period. In keeping with the semantics of the date parameter used in the FHIR search operation, the period will start at the beginning of the period implied by the supplied timestamp. E.g. a value of 2014 would set the period start to be 2014-01-01T00:00:00 inclusive</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>periodEnd</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#date\\\">date</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The end of the measurement period. The period will end at the end of the period implied by the supplied timestamp. E.g. a value of 2014 would set the period end to be 2014-12-31T23:59:59 inclusive</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>return</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"library.html\\\">Library</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The result of the requirements gathering is a module-definition Library that describes the aggregate parameters, data requirements, and dependencies of the measure</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n\\n            <div>\\n              <p>The effect of invoking this operation is to determine the aggregate set of data requirements and dependencies for the measure. The result is a Library resource with a type of module-definition that contains all the parameter definitions and data requirements of the libraries referenced by the measures. Implementations SHOULD aggregate data requirements intelligently (i.e. by collapsing overlapping data requirements). This operation defines what resources are subsequently referenced in the evaluatedResources element of the MeasureReport when submitting measure data</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"generated\"
  },
  \"title\": \"Data Requirements\",
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Measure-data-requirements\",
  \"version\": \"6.0.0-ballot4\"
}"))
(define (Measure-data-requirements-operation handler)
  (define code "data-requirements")
  (list (operation-entry 'instance code "Measure" handler)))
(define PlanDefinition-data-requirements-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
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
    },
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://www.hl7.org/Special/committees/dss\"
        }
      ]
    }
  ],
  \"date\": \"2026-05-28T22:17:06+00:00\",
  \"description\": \"The data-requirements operation aggregates and returns the parameters and data requirements for the plan definition and all its dependencies as a single module definition library\",
  \"experimental\": false,
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 3
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"normative\"
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-wg\",
      \"valueCode\": \"cds\"
    }
  ],
  \"id\": \"PlanDefinition-data-requirements\",
  \"instance\": true,
  \"jurisdiction\": [
    {
      \"coding\": [
        {
          \"code\": \"001\",
          \"display\": \"World\",
          \"system\": \"http://unstats.un.org/unsd/methods/m49/m49.htm\"
        }
      ]
    }
  ],
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2026-05-28T22:17:06.960+00:00\"
  },
  \"name\": \"DataRequirements\",
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
  \"publisher\": \"HL7 International / Clinical Decision Support\",
  \"resource\": [
    \"PlanDefinition\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"active\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p class=\\\"res-header-id\\\">\\n              <b>Generated Narrative: OperationDefinition PlanDefinition-data-requirements</b>\\n            </p>\\n            <a name=\\\"PlanDefinition-data-requirements\\\"> </a>\\n            <a name=\\\"hcPlanDefinition-data-requirements\\\"> </a>\\n            <p>URL: [base]/PlanDefinition/[id]/$data-requirements</p>\\n            <h3>Parameters</h3>\\n\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>return</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"library.html\\\">Library</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The result of the requirements gathering is a module-definition Library that describes the aggregate parameters, data requirements, and dependencies of the plan definition</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n\\n            <div>\\n              <p>The effect of invoking this operation is to determine the aggregate set of data requirements and dependencies for the plan definition. The result is a Library resource with a type of module-definition that contains all the parameter definitions and data requirements of the plan definition and any libraries referenced by it. Implementations SHOULD aggregate data requirements intelligently (i.e. by collapsing overlapping data requirements)</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"generated\"
  },
  \"title\": \"Data Requirements\",
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/PlanDefinition-data-requirements\",
  \"version\": \"6.0.0-ballot4\"
}"))
(define (PlanDefinition-data-requirements-operation handler)
  (define code "data-requirements")
  (list (operation-entry 'instance code "PlanDefinition" handler)))
(define docref-definition
  (string->jsexpr
   "{
  \"affectsState\": true,
  \"code\": \"docref\",
  \"comment\": \"The server either returns a search result Bundle containing at least one DocumentReference, \\nor it returns an error.\",
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
    },
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://www.hl7.org/Special/committees/orders\"
        }
      ]
    }
  ],
  \"date\": \"2026-05-28T22:17:06+00:00\",
  \"description\": \"This operation is used to return all the references to documents related to a patient. \\n\\n The operation requires a patient id and takes the optional input parameters: \\n  - start date\\n  - end date\\n  - document type \\n\\n  - on demand \\n\\n  - profile \\n\\n and returns a [Bundle](bundle.html) of type \\\"searchset\\\" containing [DocumentReference](documentreference.html) resources for the patient. If the server has or can create documents that are related to the patient, and that are available for the given user, the server returns the DocumentReference resources needed to support the records.  The principle intended use for this operation is to provide a provider or patient with access to their available document information. \\n\\n This operation is *different* from a search by patient and type and date range because: \\n\\n 1. It is used to request a server to *generate* a document based on the specified parameters. \\n\\n 1. If no parameters are specified, the server SHALL return a DocumentReference to the patient's most current summary \\n\\n 1. If the server cannot *generate* a document based on the specified parameters, the operation will return an empty search bundle. \\n\\n Unless the client indicates they are only interested in 'on-demand' documents using the on-demand parameter, the server SHOULD return DocumentReference instances for existing documents that meet the request parameters. In this regard, this operation is similar to a FHIR RESTful query.\",
  \"experimental\": false,
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 3
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"normative\"
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-wg\",
      \"valueCode\": \"oo\"
    }
  ],
  \"id\": \"DocumentReference-docref\",
  \"instance\": false,
  \"jurisdiction\": [
    {
      \"coding\": [
        {
          \"code\": \"001\",
          \"display\": \"World\",
          \"system\": \"http://unstats.un.org/unsd/methods/m49/m49.htm\"
        }
      ]
    }
  ],
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2026-05-28T22:17:06.960+00:00\"
  },
  \"name\": \"Docref\",
  \"parameter\": [
    {
      \"documentation\": \"The id of the patient resource located on the server on which this operation is executed.  If there is no match, an empty Bundle is returned\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"patient\",
      \"type\": \"id\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The date range relates to care dates, not record currency dates - e.g. all records relating to care provided in a certain date range. If no start date is provided, all documents prior to the end date are in scope.  If neither a start date nor an end date is provided, the most recent or current document is in scope.  The client **SHOULD** provide values precise to the second + time offset.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"start\",
      \"type\": \"dateTime\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The date range relates to care dates, not record currency dates - e.g. all records relating to care provided in a certain date range. If no end date is provided, all documents subsequent to the start date are in scope. If neither a start date nor an end date is provided, the most recent or current document is in scope.  The client **SHOULD** provide values precise to the second + time offset.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"end\",
      \"type\": \"dateTime\",
      \"use\": \"in\"
    },
    {
      \"binding\": {
        \"extension\": [
          {
            \"url\": \"http://hl7.org/fhir/StructureDefinition/elementdefinition-bindingName\",
            \"valueString\": \"??\"
          }
        ],
        \"strength\": \"required\",
        \"valueSet\": \"http://hl7.org/fhir/ValueSet/doc-typecodes|6.0.0-ballot4\"
      },
      \"documentation\": \" The type relates to document type e.g. C-CDA Clinical Summary of Care (CCD) = LOINC 34133-9: Summary of episode note, and International Patient Summary (IPS) = LOINC 60591-5: Patient summary document.  If no type is provided, the summary document, if available, SHALL be in scope, and all other document types MAY be in scope. It is at the server's discretion how to respond if multiple types are provided. The server MAY return documents to any of the specified types. The server's CapabilityStatement should document its behavior and what types it supports\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"type\",
      \"type\": \"CodeableConcept\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"This on-demand parameter allows client to dictate whether they are requesting only 'on-demand' or both 'on-demand' and 'stable' documents (or delayed/deferred assembly) that meet the query parameters\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"on-demand\",
      \"type\": \"boolean\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"This parameter allows the client to request documents according to a specific profile using the profile's canonical reference. It is at the server's discretion how to respond if multiple profiles are provided. The server MAY return documents to any of the specified profiles. The server's CapabilityStatement should document its behavior and what profiles it supports.\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"profile\",
      \"type\": \"canonical\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The bundle type is \\\"searchset\\\"containing [DocumentReference](documentreference.html) resources.\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"return\",
      \"type\": \"Bundle\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 International / Orders and Observations\",
  \"resource\": [
    \"DocumentReference\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"active\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p class=\\\"res-header-id\\\">\\n              <b>Generated Narrative: OperationDefinition DocumentReference-docref</b>\\n            </p>\\n            <a name=\\\"DocumentReference-docref\\\"> </a>\\n            <a name=\\\"hcDocumentReference-docref\\\"> </a>\\n            <p>URL: [base]/DocumentReference/$docref</p>\\n            <h3>Parameters</h3>\\n\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>patient</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#id\\\">id</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The id of the patient resource located on the server on which this operation is executed.  If there is no match, an empty Bundle is returned</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>start</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#dateTime\\\">dateTime</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The date range relates to care dates, not record currency dates - e.g. all records relating to care provided in a certain date range. If no start date is provided, all documents prior to the end date are in scope.  If neither a start date nor an end date is provided, the most recent or current document is in scope.  The client \\n                      <strong>SHOULD</strong> provide values precise to the second + time offset.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>end</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#dateTime\\\">dateTime</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The date range relates to care dates, not record currency dates - e.g. all records relating to care provided in a certain date range. If no end date is provided, all documents subsequent to the start date are in scope. If neither a start date nor an end date is provided, the most recent or current document is in scope.  The client \\n                      <strong>SHOULD</strong> provide values precise to the second + time offset.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>type</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#CodeableConcept\\\">CodeableConcept</a>\\n                </td>\\n\\n                <td>\\n                  <a href=\\\"valueset-doc-typecodes.html\\\">FHIR Document Type Codes</a> (Required)\\n                </td>\\n\\n                <td>\\n                  <div>\\n                    <p>The type relates to document type e.g. C-CDA Clinical Summary of Care (CCD) = LOINC 34133-9: Summary of episode note, and International Patient Summary (IPS) = LOINC 60591-5: Patient summary document.  If no type is provided, the summary document, if available, SHALL be in scope, and all other document types MAY be in scope. It is at the server's discretion how to respond if multiple types are provided. The server MAY return documents to any of the specified types. The server's CapabilityStatement should document its behavior and what types it supports</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>on-demand</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>This on-demand parameter allows client to dictate whether they are requesting only 'on-demand' or both 'on-demand' and 'stable' documents (or delayed/deferred assembly) that meet the query parameters</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>profile</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>This parameter allows the client to request documents according to a specific profile using the profile's canonical reference. It is at the server's discretion how to respond if multiple profiles are provided. The server MAY return documents to any of the specified profiles. The server's CapabilityStatement should document its behavior and what profiles it supports.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>return</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"bundle.html\\\">Bundle</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The bundle type is &quot;searchset&quot;containing \\n                      <a href=\\\"documentreference.html\\\">DocumentReference</a> resources.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n\\n            <div>\\n              <p>The server either returns a search result Bundle containing at least one DocumentReference,\\nor it returns an error.</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"generated\"
  },
  \"title\": \"Fetch DocumentReference\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/DocumentReference-docref\",
  \"version\": \"6.0.0-ballot4\"
}"))
(define (docref-operation handler)
  (define code "docref")
  (list (operation-entry 'type code "DocumentReference" handler)))
(define document-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
  \"code\": \"document\",
  \"comment\": \"Notes:\\n\\n* The server implementing the operation SHOULD determine a 'high-level water-mark' for the document security tags ([Bundle.meta.security](resource.html#Meta))) as a whole, based on an analysis of the resources contained within the document\\n* this operation definition does not resolve the question how document signatures are created. This is an open issue during the period of trial use, and feedback is requested regarding this question\",
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
    },
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://www.hl7.org/Special/committees/structure\"
        }
      ]
    }
  ],
  \"date\": \"2026-05-28T22:17:06+00:00\",
  \"description\": \"A client can ask a server to generate a fully bundled document from a composition resource. The server takes the composition resource, locates all the referenced resources and other additional resources as configured or requested and either returns a full document bundle, or returns an error. If some of the resources are located on other servers, it is at the discretion of the  server whether to retrieve them or return an error. If the correct version of the document  that would be generated already exists, then the server can return the existing one.\",
  \"experimental\": false,
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 2
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"normative\"
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-wg\",
      \"valueCode\": \"sd\"
    }
  ],
  \"id\": \"Composition-document\",
  \"instance\": true,
  \"jurisdiction\": [
    {
      \"coding\": [
        {
          \"code\": \"001\",
          \"display\": \"World\",
          \"system\": \"http://unstats.un.org/unsd/methods/m49/m49.htm\"
        }
      ]
    }
  ],
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2026-05-28T22:17:06.960+00:00\"
  },
  \"name\": \"Document\",
  \"parameter\": [
    {
      \"documentation\": \"Whether to store the document at the bundle end-point (/Bundle) or not once it is generated. Value = true or false (default is for the server to decide). If the document is stored, its location can be inferred from the Bundle.id, but it SHOULD be provided explicitly in the HTTP Location header in the response\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"persist\",
      \"type\": \"boolean\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Canonical reference to a GraphDefinition. If a URL is provided, it is the canonical reference to a [GraphDefinition](http://build.fhir.org/HL7/api-incubator/StructureDefinition-GraphDefinition) that it controls what resources are to be added to the bundle when building the document. The GraphDefinition can also specify profiles that apply to the various resources\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"graph\",
      \"type\": \"uri\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The bundle containing the composition and resources associated with it. See [FHIR Documents](documents.html) for information on resources that may be included in the bundle.\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"return\",
      \"type\": \"Bundle\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 International / Structured Documents\",
  \"resource\": [
    \"Composition\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"active\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p class=\\\"res-header-id\\\">\\n              <b>Generated Narrative: OperationDefinition Composition-document</b>\\n            </p>\\n            <a name=\\\"Composition-document\\\"> </a>\\n            <a name=\\\"hcComposition-document\\\"> </a>\\n            <p>URL: [base]/Composition/[id]/$document</p>\\n            <h3>Parameters</h3>\\n\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>persist</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Whether to store the document at the bundle end-point (/Bundle) or not once it is generated. Value = true or false (default is for the server to decide). If the document is stored, its location can be inferred from the Bundle.id, but it SHOULD be provided explicitly in the HTTP Location header in the response</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>graph</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Canonical reference to a GraphDefinition. If a URL is provided, it is the canonical reference to a \\n                      <a href=\\\"http://build.fhir.org/HL7/api-incubator/StructureDefinition-GraphDefinition\\\">GraphDefinition</a> that it controls what resources are to be added to the bundle when building the document. The GraphDefinition can also specify profiles that apply to the various resources\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>return</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"bundle.html\\\">Bundle</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The bundle containing the composition and resources associated with it. See \\n                      <a href=\\\"documents.html\\\">FHIR Documents</a> for information on resources that may be included in the bundle.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n\\n            <div>\\n              <p>Notes:</p>\\n\\n              <ul>\\n\\n                <li>The server implementing the operation SHOULD determine a 'high-level water-mark' for the document security tags (\\n                  <a href=\\\"resource.html#Meta\\\">Bundle.meta.security</a>)) as a whole, based on an analysis of the resources contained within the document\\n                </li>\\n\\n                <li>this operation definition does not resolve the question how document signatures are created. This is an open issue during the period of trial use, and feedback is requested regarding this question</li>\\n\\n              </ul>\\n\\n            </div>\\n          </div>\",
    \"status\": \"generated\"
  },
  \"title\": \"Generate a Document\",
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Composition-document\",
  \"version\": \"6.0.0-ballot4\"
}"))
(define (document-operation handler)
  (define code "document")
  (list (operation-entry 'instance code "Composition" handler)))
(define evaluate-measure-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
  \"code\": \"evaluate-measure\",
  \"comment\": \"The effect of invoking this operation is to calculate the measure for the given subject(s), or all subjects if no subject is supplied. For individual and subject-list reports, the result is a set of Bundles, one for each evaluated subject, where the first entry in each bundle is a MeasureReport resource, and subsequent entries in the Bundle are resources evaluated or created as part of the measure evaluation. For the summary report, the result of this operation is a single bundle with a single MeasureReport of type summary. Note that whether or not this operation affects the state of the server depends on whether the server persists the generated MeasureReport. If the MeasureReport is not persisted, this operation can be invoked with GET\",
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
    },
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://www.hl7.org/Special/committees/cqi\"
        }
      ]
    }
  ],
  \"date\": \"2026-05-28T22:17:06+00:00\",
  \"description\": \"The evaluate-measure operation is used to calculate an eMeasure and obtain the results\",
  \"experimental\": false,
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 3
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"deprecated\"
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-wg\",
      \"valueCode\": \"cqi\"
    }
  ],
  \"id\": \"Measure-evaluate-measure\",
  \"instance\": true,
  \"jurisdiction\": [
    {
      \"coding\": [
        {
          \"code\": \"001\",
          \"display\": \"World\",
          \"system\": \"http://unstats.un.org/unsd/methods/m49/m49.htm\"
        }
      ]
    }
  ],
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2026-05-28T22:17:06.960+00:00\"
  },
  \"name\": \"EvaluateMeasure\",
  \"parameter\": [
    {
      \"documentation\": \"The measure to evaluate. If the operation is invoked at the instance level, this parameter is not allowed; if the operation is invoked at the type level, this parameter is required, or a url (and optionally version) must be supplied.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"measure\",
      \"scope\": [
        \"type\"
      ],
      \"type\": \"Measure\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The url of the measure to be applied. If the operation is invoked at the instance level, this parameter is not allowed; if the operation is invoked at the type level, this parameter (and optionally the version), or the measure parameter must be supplied\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"url\",
      \"scope\": [
        \"type\"
      ],
      \"targetProfile\": [
        \"http://hl7.org/fhir/StructureDefinition/Measure\"
      ],
      \"type\": \"canonical\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The version of the measure to be applied. If the operation is invoked at the instance level, this parameter is not allowed; if the operation is invoked at the type level, this parameter may only be used if the url parameter is supplied, and the version is not supplied with it.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"version\",
      \"scope\": [
        \"type\"
      ],
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Subject for which the measure will be calculated. The subject must be an instance of a type that is consistent with the subjectType of the Measure being evaluated (e.g. Patient, Practitioner, Location...). The subject may be a Patient, Practitioner, PractitionerRole, Organization, Location, Device, or Group. If the subject is a Group, it must be an actual Group, not a definitional one. Subjects provided in this parameter SHALL match the subjectType of the measure being evaluated (i.e. if the Measure.subjectType is Patient, the subject SHALL be a reference to a Patient or a Group of Patients). If no subject is provided, the evaluation will be performed for all subjects appropriate to the Measure.subjectType (possibly constrained further by the provider parameter).\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"subject\",
      \"searchType\": \"reference\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
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
      \"binding\": {
        \"strength\": \"required\",
        \"valueSet\": \"http://hl7.org/fhir/ValueSet/measure-report-evaluation-type|6.0.0-ballot4\"
      },
      \"documentation\": \"The type of measure report: individual, subject-list, or summary. If not specified, a default value of subject will be used if the subject parameter is supplied and is not a Group, otherwise, summary will be used. NOTE: Implementations should support the use of `subject` for individual and `population` for summary for backwards compatibility with existing implementations.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"reportType\",
      \"type\": \"code\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The provider for which the report will be run. This may be a reference to a Practitioner, PractitionerRole, or Organization. If specified, the measure will be calculated for subjects that have a primary relationship to the identified provider. How this relationship is determined is implementation-specific.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"provider\",
      \"searchType\": \"reference\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The location for which the report will be run.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"location\",
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
      \"documentation\": \"Any input parameters for the evaluation. Parameters defined in this input will be made available by name to the CQL expression. Parameter types are mapped to CQL as specified in the [Using CQL with FHIR](https://hl7.org/fhir/uv/cql/) implementation guide. If a parameter appears more than once in the input Parameters resource, it is represented with a List in the input CQL. If a parameter has parts, it is represented as a Tuple in the input CQL.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"parameters\",
      \"type\": \"Parameters\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The results of the measure calculation. The result of this operation will be a Bundle for each input subject, where the first entry of the Bundle is a MeasureReport representing the results of the calculation, and subsequent entries in the Bundle are resources created and/or evaluated as part of the calculation. See the MeasureReport resource for a complete description of the output of this operation. Note that implementations may choose to return a MeasureReport with a status of pending to indicate that the report is still being generated. In this case, the client can use a polling method to continually request the MeasureReport until the status is updated to complete\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"return\",
      \"type\": \"Bundle\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 International / Clinical Quality Information\",
  \"resource\": [
    \"Measure\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p class=\\\"res-header-id\\\">\\n              <b>Generated Narrative: OperationDefinition Measure-evaluate-measure</b>\\n            </p>\\n            <a name=\\\"Measure-evaluate-measure\\\"> </a>\\n            <a name=\\\"hcMeasure-evaluate-measure\\\"> </a>\\n            <p>URL: [base]/Measure/$evaluate-measure</p>\\n            <p>URL: [base]/Measure/[id]/$evaluate-measure</p>\\n            <h3>Parameters</h3>\\n\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>measure</td>\\n\\n                <td>type</td>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"measure.html\\\">Measure</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The measure to evaluate. If the operation is invoked at the instance level, this parameter is not allowed; if the operation is invoked at the type level, this parameter is required, or a url (and optionally version) must be supplied.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>url</td>\\n\\n                <td>type</td>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a> (\\n                  <a href=\\\"measure.html\\\" title=\\\"http://hl7.org/fhir/StructureDefinition/Measure\\\">Measure</a>)\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The url of the measure to be applied. If the operation is invoked at the instance level, this parameter is not allowed; if the operation is invoked at the type level, this parameter (and optionally the version), or the measure parameter must be supplied</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>version</td>\\n\\n                <td>type</td>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The version of the measure to be applied. If the operation is invoked at the instance level, this parameter is not allowed; if the operation is invoked at the type level, this parameter may only be used if the url parameter is supplied, and the version is not supplied with it.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>subject</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                  <br/>(\\n                  <a href=\\\"search.html#reference\\\">reference</a>)\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Subject for which the measure will be calculated. The subject must be an instance of a type that is consistent with the subjectType of the Measure being evaluated (e.g. Patient, Practitioner, Location...). The subject may be a Patient, Practitioner, PractitionerRole, Organization, Location, Device, or Group. If the subject is a Group, it must be an actual Group, not a definitional one. Subjects provided in this parameter SHALL match the subjectType of the measure being evaluated (i.e. if the Measure.subjectType is Patient, the subject SHALL be a reference to a Patient or a Group of Patients). If no subject is provided, the evaluation will be performed for all subjects appropriate to the Measure.subjectType (possibly constrained further by the provider parameter).</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>periodStart</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#date\\\">date</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The start of the measurement period. In keeping with the semantics of the date parameter used in the FHIR search operation, the period will start at the beginning of the period implied by the supplied timestamp. E.g. a value of 2014 would set the period start to be 2014-01-01T00:00:00 inclusive</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>periodEnd</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#date\\\">date</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The end of the measurement period. The period will end at the end of the period implied by the supplied timestamp. E.g. a value of 2014 would set the period end to be 2014-12-31T23:59:59 inclusive</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>reportType</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n\\n                <td>\\n                  <a href=\\\"valueset-measure-report-evaluation-type.html\\\">Measure Report Evaluation Type</a> (Required)\\n                </td>\\n\\n                <td>\\n                  <div>\\n                    <p>The type of measure report: individual, subject-list, or summary. If not specified, a default value of subject will be used if the subject parameter is supplied and is not a Group, otherwise, summary will be used. NOTE: Implementations should support the use of \\n                      <code>subject</code> for individual and \\n                      <code>population</code> for summary for backwards compatibility with existing implementations.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>provider</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                  <br/>(\\n                  <a href=\\\"search.html#reference\\\">reference</a>)\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The provider for which the report will be run. This may be a reference to a Practitioner, PractitionerRole, or Organization. If specified, the measure will be calculated for subjects that have a primary relationship to the identified provider. How this relationship is determined is implementation-specific.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>location</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                  <br/>(\\n                  <a href=\\\"search.html#reference\\\">reference</a>)\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The location for which the report will be run.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>lastReceivedOn</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#dateTime\\\">dateTime</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The date the results of this measure were last received. This parameter is only valid for patient-level reports and is used to indicate when the last time a result for this patient was received. This information can be used to limit the set of resources returned for a patient-level report</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>parameters</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"parameters.html\\\">Parameters</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Any input parameters for the evaluation. Parameters defined in this input will be made available by name to the CQL expression. Parameter types are mapped to CQL as specified in the \\n                      <a href=\\\"https://hl7.org/fhir/uv/cql/\\\">Using CQL with FHIR</a> implementation guide. If a parameter appears more than once in the input Parameters resource, it is represented with a List in the input CQL. If a parameter has parts, it is represented as a Tuple in the input CQL.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>return</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"bundle.html\\\">Bundle</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The results of the measure calculation. The result of this operation will be a Bundle for each input subject, where the first entry of the Bundle is a MeasureReport representing the results of the calculation, and subsequent entries in the Bundle are resources created and/or evaluated as part of the calculation. See the MeasureReport resource for a complete description of the output of this operation. Note that implementations may choose to return a MeasureReport with a status of pending to indicate that the report is still being generated. In this case, the client can use a polling method to continually request the MeasureReport until the status is updated to complete</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n\\n            <div>\\n              <p>The effect of invoking this operation is to calculate the measure for the given subject(s), or all subjects if no subject is supplied. For individual and subject-list reports, the result is a set of Bundles, one for each evaluated subject, where the first entry in each bundle is a MeasureReport resource, and subsequent entries in the Bundle are resources evaluated or created as part of the measure evaluation. For the summary report, the result of this operation is a single bundle with a single MeasureReport of type summary. Note that whether or not this operation affects the state of the server depends on whether the server persists the generated MeasureReport. If the MeasureReport is not persisted, this operation can be invoked with GET</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"generated\"
  },
  \"title\": \"Evaluate Measure\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Measure-evaluate-measure\",
  \"version\": \"6.0.0-ballot4\"
}"))
(define (evaluate-measure-operation handler)
  (define code "evaluate-measure")
  (list (operation-entry 'type code "Measure" handler)
        (operation-entry 'instance code "Measure" handler)))
(define evaluate-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
  \"code\": \"evaluate\",
  \"comment\": \"The effect of invoking this operation is to calculate the specified measure(s) for the given subject(s), or a server-determined set of subjects if no subject is supplied. For `individual` and `subject-list` reports, the result is a set of Bundles, one for each evaluated subject, where the first entries in each bundle are MeasureReport resources, and subsequent entries in the Bundle are resources evaluated or created as part of the measure evaluation. For the summary report, the result of this operation is a single bundle with a MeasureReport for each calculated measure with a type of `summary`. Note that whether or not this operation affects the state of the server depends on whether the server persists the generated MeasureReport. If the MeasureReport is not persisted, this operation can be invoked with GET.\",
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
    },
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://www.hl7.org/Special/committees/cqi\"
        }
      ]
    }
  ],
  \"date\": \"2026-05-28T22:17:06+00:00\",
  \"description\": \"The evaluate operation processes the given Measure(s) to produce the corresponding MeasureReport(s). This operation expects that Measure resources used have a computable representation. The value of title elements in the resulting [MeasureReport](clinicalreasoning-quality-reporting.html#measure-report) should be copied from the corresponding elements on the Measure.\",
  \"experimental\": false,
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 3
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"normative\"
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-wg\",
      \"valueCode\": \"cqi\"
    }
  ],
  \"id\": \"Measure-evaluate\",
  \"instance\": false,
  \"jurisdiction\": [
    {
      \"coding\": [
        {
          \"code\": \"001\",
          \"display\": \"World\",
          \"system\": \"http://unstats.un.org/unsd/methods/m49/m49.htm\"
        }
      ]
    }
  ],
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2026-05-28T22:17:06.960+00:00\"
  },
  \"name\": \"Evaluate\",
  \"parameter\": [
    {
      \"documentation\": \"The URL of the measure(s) to be evaluated. A measure URL is specified in the url element of the Measure resource. The measure URL remains the same when the measure is stored on different servers.\",
      \"max\": \"*\",
      \"min\": 1,
      \"name\": \"measureUrl\",
      \"type\": \"canonical\",
      \"use\": \"in\"
    },
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
      \"documentation\": \"Subject(s) for which the measure will be calculated. Subjects provided in this parameter SHALL match the subjectType of the measure being evaluated (e.g. if the Measure.group.subjectType is Patient, the subject SHALL be a reference to a Patient or a Group of Patients). This parameter cannot be used with the subjectGroup parameter. If no subject or subjectGroup is provided, what subjects are evaluated is up to the server.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"subject\",
      \"searchType\": \"reference\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Subjects for which the measure will be evaluated, provided as a Group resource. Subjects provided in this parameter SHALL match the subjectType of the measure being evaluated. (e.g. if the Measure.group.subjectType is Patient, the subject SHALL be a reference to a Patient or a Group of Patients). This parameter cannot be used with the subject parameter. If no subject or subjectGroup is provided, what subjects are evaluated is up to the server.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"subjectGroup\",
      \"type\": \"Group\",
      \"use\": \"in\"
    },
    {
      \"binding\": {
        \"strength\": \"required\",
        \"valueSet\": \"http://hl7.org/fhir/ValueSet/measure-report-evaluation-type|6.0.0-ballot4\"
      },
      \"documentation\": \"The type of measure report: `individual`, `subject-list`, or `summary`. If not specified, a default value of `summary` will be used if the subject parameter is supplied and is a `Group` resource; a default value of `individual` will be used if the subject parameter is supplied and is not a `Group` resource; otherwise, a default value of `summary` will be used. NOTE: Implementations should support the use of `subject` for `individual` and `population` for `summary` for backwards compatibility with existing implementations.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"reportType\",
      \"type\": \"code\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The provider for which the report will be run. This may be a reference to a Practitioner, PractitionerRole, or Organization. If specified, systems MAY use this information to determine subjects for which the measure will be calculated, but how subjects are determined is implementation-specific. This parameter is reflected in the reporter element of the resulting MeasureReport(s). This parameter cannot be used with the reporterResource parameter.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"reporter\",
      \"searchType\": \"reference\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The provider for which the report will be run, provided as a Practitioner, PractitionerRole, or Organization resource. This is intended to support the use case in which the organization information is not on the server performing the evaluation, for example an [ad-hoc group of practitioners](clinicalreasoning-quality-reporting.html#ad-hoc-organizations) that are part of a provider group. This parameter is reflected in the reporter element of the resulting MeasureReport(s). This parameter cannot be used with the reporter parameter.\",
      \"extension\": [
        {
          \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
          \"valueUri\": \"Practitioner\"
        },
        {
          \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
          \"valueUri\": \"PractitionerRole\"
        },
        {
          \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
          \"valueUri\": \"Organization\"
        }
      ],
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"reporterResource\",
      \"searchType\": \"reference\",
      \"type\": \"Element\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The location(s) for which the report will be run. This parameter is reflected in the location element of the resulting MeasureReport(s).\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"location\",
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
      \"documentation\": \"Any input parameters for the evaluation. Parameters defined in this input will be made available by name to the CQL expression. Parameter types are mapped to CQL as specified in the [Using CQL with FHIR](https://hl7.org/fhir/uv/cql/) implementation guide. If a parameter appears more than once in the input Parameters resource, it is represented with a List in the input CQL. If a parameter has parts, it is represented as a Tuple in the input CQL.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"parameters\",
      \"type\": \"Parameters\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Specifies an asset-collection library that provides dependency version resolution and expansion rules for the operation. See the version manifest discussion in the [Canonical Resource Management Infrastructure IG](http://hl7.org/fhir/uv/crmi/version-manifest.html) for a complete description of how manifest values are used to provide defaults for dependency version resolution and expansion parameters. Parameters specified directly in the operation override behaviors specified by the manifest parameter. In general, if this parameter is supplied, it is expected to be used in nested operation calls. For example, in evaluating a measure, if the expansion of a value set is required, this parameter SHALL be supplied to that expansion.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"manifest\",
      \"targetProfile\": [
        \"http://hl7.org/fhir/StructureDefinition/Library\"
      ],
      \"type\": \"canonical\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Additional stratifier criteria for the measure. The resulting MeasureReport will contain this additional stratifier information as well as any stratifiers defined in the Measure being reported.\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"stratifier\",
      \"part\": [
        {
          \"documentation\": \"If the evaluate operation is for multiple measures, this parameter may be used to specify which measures the additional stratifier should be reported on. If not specified, the stratifier will be reported on all the measures. Note that if this results in a stratifier definition that cannot be interpreted correctly for the measure being reported, the behavior is at server discretion; it may throw an error, or simply ignore the additional stratifier definition.\",
          \"max\": \"*\",
          \"min\": 0,
          \"name\": \"measureUrl\",
          \"type\": \"canonical\",
          \"use\": \"in\"
        },
        {
          \"documentation\": \"If the measure being evaluated has multiple groups, this parameter may be used to specify which groups the additional stratifier should be reported on. If not specified, the stratifier will be reported on all groups in the measure being reported. Note that if this results in a stratifier definition that cannot be interpreted correctly for the measure group being reported, the behavior is at server discretion; it may throw an error, or simply ignore the additional stratifier definition.\",
          \"max\": \"*\",
          \"min\": 0,
          \"name\": \"groupId\",
          \"type\": \"string\",
          \"use\": \"in\"
        },
        {
          \"documentation\": \"One or more components of the stratifier definition. Additional stratifiers are reported in the MeasureReport in the same way as stratifiers defined in the Measure.\",
          \"max\": \"*\",
          \"min\": 1,
          \"name\": \"component\",
          \"part\": [
            {
              \"binding\": {
                \"strength\": \"example\",
                \"valueSet\": \"http://hl7.org/fhir/ValueSet/measure-stratifier-type-example\"
              },
              \"documentation\": \"Meaning of the stratifier component.\",
              \"max\": \"1\",
              \"min\": 0,
              \"name\": \"code\",
              \"type\": \"code\",
              \"use\": \"in\"
            },
            {
              \"documentation\": \"Human readable description of the stratifier component\",
              \"max\": \"1\",
              \"min\": 0,
              \"name\": \"description\",
              \"type\": \"markdown\",
              \"use\": \"in\"
            },
            {
              \"documentation\": \"An expression that returns the value of this component of the stratifier for a member of the population. This is typically the name of an expression defined within a referenced library, but it may also be a path to a stratifier element, evaluated from the perspective of the measure subject. If this is a non-subject-based measure, the expression may be a reference to a function that takes an argument of the type of the measure basis, allowing the stratifier value to be determined for each member of the population. Criteria-based stratifiers allow for inclusion in multiple strata (i.e. strata are not mutually exclusive). When a value-based criterium returns multiple values, each value separately indicates inclusion in a stratrum and does NOT indicate a new stratum that is a combination of the values.\",
              \"max\": \"1\",
              \"min\": 1,
              \"name\": \"criteria\",
              \"type\": \"Expression\",
              \"use\": \"in\"
            },
            {
              \"documentation\": \"A value set defining possible stratifier values. If both expression and valueset are specified, they SHALL be consistent (i.e. the expression SHALL evaluate to a code that is a member of the specified valueset).\",
              \"max\": \"1\",
              \"min\": 0,
              \"name\": \"valueSet\",
              \"targetProfile\": [
                \"http://hl7.org/fhir/StructureDefinition/ValueSet\"
              ],
              \"type\": \"canonical\",
              \"use\": \"in\"
            },
            {
              \"documentation\": \"Indicates what units, if any, stratifier values are expected to be expressed in. This element SHOULD be specified in UCUM units or calendar units. This information SHOULD be provided if it cannot be inferred from the stsratifier expression directly.\",
              \"max\": \"1\",
              \"min\": 0,
              \"name\": \"unit\",
              \"type\": \"string\",
              \"use\": \"in\"
            }
          ],
          \"use\": \"in\"
        }
      ],
      \"use\": \"in\"
    },
    {
      \"documentation\": \"What additional supplemental data should be reported with the measure. This additional data is specified in the same was as supplemental data in the Measure resource, and is reported in the same way in the MeasureReport.\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"supplementalData\",
      \"part\": [
        {
          \"documentation\": \"If the evaluate operation is for multiple measures, this parameter may be used to specify which measures the additional supplemental data should be reported on. If not specified, the stratifier will be reported on all the measures. Note that if this results in a stratifier definition that cannot be interpreted correctly for the measure being reported, the behavior is at server discretion; it may throw an error, or simply ignore the additional stratifier definition.\",
          \"max\": \"*\",
          \"min\": 0,
          \"name\": \"measureUrl\",
          \"type\": \"canonical\",
          \"use\": \"in\"
        },
        {
          \"binding\": {
            \"strength\": \"example\",
            \"valueSet\": \"http://hl7.org/fhir/ValueSet/measure-supplemental-data-example\"
          },
          \"documentation\": \"Meaning of the supplemental data.\",
          \"max\": \"1\",
          \"min\": 0,
          \"name\": \"code\",
          \"type\": \"CodeableConcept\",
          \"use\": \"in\"
        },
        {
          \"binding\": {
            \"strength\": \"extensible\",
            \"valueSet\": \"http://terminology.hl7.org/ValueSet/measure-data-usage\"
          },
          \"documentation\": \"supplemental-data | risk-adjustment | factor\",
          \"max\": \"*\",
          \"min\": 0,
          \"name\": \"usage\",
          \"type\": \"CodeableConcept\",
          \"use\": \"in\"
        },
        {
          \"documentation\": \"Human readable description of this supplemental data element\",
          \"max\": \"1\",
          \"min\": 0,
          \"name\": \"description\",
          \"type\": \"markdown\",
          \"use\": \"in\"
        },
        {
          \"documentation\": \"Expression describing the additional data to be reported. This may be the name of an expression in a library, or it may be a path to a specific data element, reachable from the subject being evaluated.\",
          \"max\": \"1\",
          \"min\": 1,
          \"name\": \"criteria\",
          \"type\": \"Expression\",
          \"use\": \"in\"
        }
      ],
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The results of the measure evaluation, returned as a Bundle for each input subject. The first entries in each Bundle are MeasureReport(s) corresponding to the measures that were calculated. Subsequent entries in each Bundle are resources representing the data that was created or referenced during the calculation of the measures, and referenced from the appropriate element of the corresponding MeasureReport resources. See the [guidance](clinicalreasoning-quality-reporting.html#bundles-organized-by-subject) on Bundle structure for discussion about the Bundle content and organization.\\\\n\\\\nNote that even though there is a single parameter named return of type Bundle, it is a multi-cardinality parameter, and so will still be returned using a Parameters resource, as described in the general operations framework [response](operations.html#response).\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"return\",
      \"type\": \"Bundle\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 International / Clinical Quality Information\",
  \"resource\": [
    \"Measure\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"active\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p class=\\\"res-header-id\\\">\\n              <b>Generated Narrative: OperationDefinition Measure-evaluate</b>\\n            </p>\\n            <a name=\\\"Measure-evaluate\\\"> </a>\\n            <a name=\\\"hcMeasure-evaluate\\\"> </a>\\n            <p>URL: [base]/Measure/$evaluate</p>\\n            <h3>Parameters</h3>\\n\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>measureUrl</td>\\n\\n                <td/>\\n\\n                <td>1..*</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The URL of the measure(s) to be evaluated. A measure URL is specified in the url element of the Measure resource. The measure URL remains the same when the measure is stored on different servers.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>periodStart</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#date\\\">date</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The start of the measurement period. In keeping with the semantics of the date parameter used in the FHIR search operation, the period will start at the beginning of the period implied by the supplied timestamp. E.g. a value of 2014 would set the period start to be 2014-01-01T00:00:00 inclusive</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>periodEnd</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#date\\\">date</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The end of the measurement period. The period will end at the end of the period implied by the supplied timestamp. E.g. a value of 2014 would set the period end to be 2014-12-31T23:59:59 inclusive</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>subject</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                  <br/>(\\n                  <a href=\\\"search.html#reference\\\">reference</a>)\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Subject(s) for which the measure will be calculated. Subjects provided in this parameter SHALL match the subjectType of the measure being evaluated (e.g. if the Measure.group.subjectType is Patient, the subject SHALL be a reference to a Patient or a Group of Patients). This parameter cannot be used with the subjectGroup parameter. If no subject or subjectGroup is provided, what subjects are evaluated is up to the server.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>subjectGroup</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"group.html\\\">Group</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Subjects for which the measure will be evaluated, provided as a Group resource. Subjects provided in this parameter SHALL match the subjectType of the measure being evaluated. (e.g. if the Measure.group.subjectType is Patient, the subject SHALL be a reference to a Patient or a Group of Patients). This parameter cannot be used with the subject parameter. If no subject or subjectGroup is provided, what subjects are evaluated is up to the server.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>reportType</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n\\n                <td>\\n                  <a href=\\\"valueset-measure-report-evaluation-type.html\\\">Measure Report Evaluation Type</a> (Required)\\n                </td>\\n\\n                <td>\\n                  <div>\\n                    <p>The type of measure report: \\n                      <code>individual</code>, \\n                      <code>subject-list</code>, or \\n                      <code>summary</code>. If not specified, a default value of \\n                      <code>summary</code> will be used if the subject parameter is supplied and is a \\n                      <code>Group</code> resource; a default value of \\n                      <code>individual</code> will be used if the subject parameter is supplied and is not a \\n                      <code>Group</code> resource; otherwise, a default value of \\n                      <code>summary</code> will be used. NOTE: Implementations should support the use of \\n                      <code>subject</code> for \\n                      <code>individual</code> and \\n                      <code>population</code> for \\n                      <code>summary</code> for backwards compatibility with existing implementations.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>reporter</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                  <br/>(\\n                  <a href=\\\"search.html#reference\\\">reference</a>)\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The provider for which the report will be run. This may be a reference to a Practitioner, PractitionerRole, or Organization. If specified, systems MAY use this information to determine subjects for which the measure will be calculated, but how subjects are determined is implementation-specific. This parameter is reflected in the reporter element of the resulting MeasureReport(s). This parameter cannot be used with the reporterResource parameter.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>reporterResource</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"practitioner.html\\\">Practitioner</a> | \\n                  <a href=\\\"practitionerrole.html\\\">PractitionerRole</a> | \\n                  <a href=\\\"organization.html\\\">Organization</a>\\n                  <br/>(\\n                  <a href=\\\"search.html#reference\\\">reference</a>)\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The provider for which the report will be run, provided as a Practitioner, PractitionerRole, or Organization resource. This is intended to support the use case in which the organization information is not on the server performing the evaluation, for example an \\n                      <a href=\\\"clinicalreasoning-quality-reporting.html#ad-hoc-organizations\\\">ad-hoc group of practitioners</a> that are part of a provider group. This parameter is reflected in the reporter element of the resulting MeasureReport(s). This parameter cannot be used with the reporter parameter.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>location</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                  <br/>(\\n                  <a href=\\\"search.html#reference\\\">reference</a>)\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The location(s) for which the report will be run. This parameter is reflected in the location element of the resulting MeasureReport(s).</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>lastReceivedOn</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#dateTime\\\">dateTime</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The date the results of this measure were last received. This parameter is only valid for patient-level reports and is used to indicate when the last time a result for this patient was received. This information can be used to limit the set of resources returned for a patient-level report</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>parameters</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"parameters.html\\\">Parameters</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Any input parameters for the evaluation. Parameters defined in this input will be made available by name to the CQL expression. Parameter types are mapped to CQL as specified in the \\n                      <a href=\\\"https://hl7.org/fhir/uv/cql/\\\">Using CQL with FHIR</a> implementation guide. If a parameter appears more than once in the input Parameters resource, it is represented with a List in the input CQL. If a parameter has parts, it is represented as a Tuple in the input CQL.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>manifest</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a> (\\n                  <a href=\\\"library.html\\\" title=\\\"http://hl7.org/fhir/StructureDefinition/Library\\\">Library</a>)\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Specifies an asset-collection library that provides dependency version resolution and expansion rules for the operation. See the version manifest discussion in the \\n                      <a href=\\\"http://hl7.org/fhir/uv/crmi/version-manifest.html\\\">Canonical Resource Management Infrastructure IG</a> for a complete description of how manifest values are used to provide defaults for dependency version resolution and expansion parameters. Parameters specified directly in the operation override behaviors specified by the manifest parameter. In general, if this parameter is supplied, it is expected to be used in nested operation calls. For example, in evaluating a measure, if the expansion of a value set is required, this parameter SHALL be supplied to that expansion.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>stratifier</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td/>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Additional stratifier criteria for the measure. The resulting MeasureReport will contain this additional stratifier information as well as any stratifiers defined in the Measure being reported.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>stratifier.measureUrl</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>If the evaluate operation is for multiple measures, this parameter may be used to specify which measures the additional stratifier should be reported on. If not specified, the stratifier will be reported on all the measures. Note that if this results in a stratifier definition that cannot be interpreted correctly for the measure being reported, the behavior is at server discretion; it may throw an error, or simply ignore the additional stratifier definition.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>stratifier.groupId</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>If the measure being evaluated has multiple groups, this parameter may be used to specify which groups the additional stratifier should be reported on. If not specified, the stratifier will be reported on all groups in the measure being reported. Note that if this results in a stratifier definition that cannot be interpreted correctly for the measure group being reported, the behavior is at server discretion; it may throw an error, or simply ignore the additional stratifier definition.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>stratifier.component</td>\\n\\n                <td/>\\n\\n                <td>1..*</td>\\n\\n                <td/>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>One or more components of the stratifier definition. Additional stratifiers are reported in the MeasureReport in the same way as stratifiers defined in the Measure.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>stratifier.component.code</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n\\n                <td>\\n                  <a href=\\\"valueset-measure-stratifier-type-example.html\\\">Measure Stratifier Type Example</a> (Example)\\n                </td>\\n\\n                <td>\\n                  <div>\\n                    <p>Meaning of the stratifier component.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>stratifier.component.description</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#markdown\\\">markdown</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Human readable description of the stratifier component</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>stratifier.component.criteria</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"metadatatypes.html#Expression\\\">Expression</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>An expression that returns the value of this component of the stratifier for a member of the population. This is typically the name of an expression defined within a referenced library, but it may also be a path to a stratifier element, evaluated from the perspective of the measure subject. If this is a non-subject-based measure, the expression may be a reference to a function that takes an argument of the type of the measure basis, allowing the stratifier value to be determined for each member of the population. Criteria-based stratifiers allow for inclusion in multiple strata (i.e. strata are not mutually exclusive). When a value-based criterium returns multiple values, each value separately indicates inclusion in a stratrum and does NOT indicate a new stratum that is a combination of the values.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>stratifier.component.valueSet</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a> (\\n                  <a href=\\\"valueset.html\\\" title=\\\"http://hl7.org/fhir/StructureDefinition/ValueSet\\\">ValueSet</a>)\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>A value set defining possible stratifier values. If both expression and valueset are specified, they SHALL be consistent (i.e. the expression SHALL evaluate to a code that is a member of the specified valueset).</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>stratifier.component.unit</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Indicates what units, if any, stratifier values are expected to be expressed in. This element SHOULD be specified in UCUM units or calendar units. This information SHOULD be provided if it cannot be inferred from the stsratifier expression directly.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>supplementalData</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td/>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>What additional supplemental data should be reported with the measure. This additional data is specified in the same was as supplemental data in the Measure resource, and is reported in the same way in the MeasureReport.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>supplementalData.measureUrl</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>If the evaluate operation is for multiple measures, this parameter may be used to specify which measures the additional supplemental data should be reported on. If not specified, the stratifier will be reported on all the measures. Note that if this results in a stratifier definition that cannot be interpreted correctly for the measure being reported, the behavior is at server discretion; it may throw an error, or simply ignore the additional stratifier definition.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>supplementalData.code</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#CodeableConcept\\\">CodeableConcept</a>\\n                </td>\\n\\n                <td>\\n                  <a href=\\\"valueset-measure-supplemental-data-example.html\\\">Measure Supplemental Data Example</a> (Example)\\n                </td>\\n\\n                <td>\\n                  <div>\\n                    <p>Meaning of the supplemental data.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>supplementalData.usage</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#CodeableConcept\\\">CodeableConcept</a>\\n                </td>\\n\\n                <td>\\n                  <a href=\\\"http://terminology.hl7.org/7.1.0/ValueSet-measure-data-usage.html\\\">MeasureDataUsage</a> (Extensible)\\n                </td>\\n\\n                <td>\\n                  <div>\\n                    <p>supplemental-data | risk-adjustment | factor</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>supplementalData.description</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#markdown\\\">markdown</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Human readable description of this supplemental data element</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>supplementalData.criteria</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"metadatatypes.html#Expression\\\">Expression</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Expression describing the additional data to be reported. This may be the name of an expression in a library, or it may be a path to a specific data element, reachable from the subject being evaluated.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>return</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"bundle.html\\\">Bundle</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The results of the measure evaluation, returned as a Bundle for each input subject. The first entries in each Bundle are MeasureReport(s) corresponding to the measures that were calculated. Subsequent entries in each Bundle are resources representing the data that was created or referenced during the calculation of the measures, and referenced from the appropriate element of the corresponding MeasureReport resources. See the \\n                      <a href=\\\"clinicalreasoning-quality-reporting.html#bundles-organized-by-subject\\\">guidance</a> on Bundle structure for discussion about the Bundle content and organization.\\\\n\\\\nNote that even though there is a single parameter named return of type Bundle, it is a multi-cardinality parameter, and so will still be returned using a Parameters resource, as described in the general operations framework \\n                      <a href=\\\"operations.html#response\\\">response</a>.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n\\n            <div>\\n              <p>The effect of invoking this operation is to calculate the specified measure(s) for the given subject(s), or a server-determined set of subjects if no subject is supplied. For \\n                <code>individual</code> and \\n                <code>subject-list</code> reports, the result is a set of Bundles, one for each evaluated subject, where the first entries in each bundle are MeasureReport resources, and subsequent entries in the Bundle are resources evaluated or created as part of the measure evaluation. For the summary report, the result of this operation is a single bundle with a MeasureReport for each calculated measure with a type of \\n                <code>summary</code>. Note that whether or not this operation affects the state of the server depends on whether the server persists the generated MeasureReport. If the MeasureReport is not persisted, this operation can be invoked with GET.\\n              </p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"generated\"
  },
  \"title\": \"Evaluate\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Measure-evaluate\",
  \"version\": \"6.0.0-ballot4\"
}"))
(define (evaluate-operation handler)
  (define code "evaluate")
  (list (operation-entry 'type code "Measure" handler)))
(define events-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
  \"code\": \"events\",
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
    },
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://www.hl7.org/Special/committees/fiwg\"
        }
      ]
    }
  ],
  \"date\": \"2026-05-28T22:17:06+00:00\",
  \"description\": \"This operation is used to search for and return notifications that have been previously triggered by a topic-based Subscription.\",
  \"experimental\": false,
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 0
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"normative\"
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-wg\",
      \"valueCode\": \"fhir\"
    }
  ],
  \"id\": \"Subscription-events\",
  \"instance\": true,
  \"jurisdiction\": [
    {
      \"coding\": [
        {
          \"code\": \"001\",
          \"display\": \"World\",
          \"system\": \"http://unstats.un.org/unsd/methods/m49/m49.htm\"
        }
      ]
    }
  ],
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2026-05-28T22:17:06.960+00:00\"
  },
  \"name\": \"Events\",
  \"parameter\": [
    {
      \"documentation\": \"The lowest event number to be included in the response (lower bound, inclusive).\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"eventsSinceNumber\",
      \"type\": \"integer64\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The highest event number to be included in the response (upper bound, inclusive).\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"eventsUntilNumber\",
      \"type\": \"integer64\",
      \"use\": \"in\"
    },
    {
      \"binding\": {
        \"strength\": \"required\",
        \"valueSet\": \"http://hl7.org/fhir/ValueSet/subscription-payload-content|6.0.0-ballot4\"
      },
      \"documentation\": \"Requested content style of returned data. Codes from backport-content-value-set (e.g., empty, id-only, full-resource). This is a hint to the server what a client would prefer, and MAY be ignored.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"content\",
      \"type\": \"code\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The operation returns a valid notification bundle, with the first entry being a SubscriptionStatus resource. The bundle type is \\\"subscription-notification\\\".\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"return\",
      \"type\": \"Bundle\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 International / FHIR Infrastructure\",
  \"resource\": [
    \"Subscription\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"active\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p class=\\\"res-header-id\\\">\\n              <b>Generated Narrative: OperationDefinition Subscription-events</b>\\n            </p>\\n            <a name=\\\"Subscription-events\\\"> </a>\\n            <a name=\\\"hcSubscription-events\\\"> </a>\\n            <p>URL: [base]/Subscription/[id]/$events</p>\\n            <h3>Parameters</h3>\\n\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>eventsSinceNumber</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#integer64\\\">integer64</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The lowest event number to be included in the response (lower bound, inclusive).</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>eventsUntilNumber</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#integer64\\\">integer64</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The highest event number to be included in the response (upper bound, inclusive).</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>content</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n\\n                <td>\\n                  <a href=\\\"valueset-subscription-payload-content.html\\\">Subscription Payload Content</a> (Required)\\n                </td>\\n\\n                <td>\\n                  <div>\\n                    <p>Requested content style of returned data. Codes from backport-content-value-set (e.g., empty, id-only, full-resource). This is a hint to the server what a client would prefer, and MAY be ignored.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>return</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"bundle.html\\\">Bundle</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The operation returns a valid notification bundle, with the first entry being a SubscriptionStatus resource. The bundle type is &quot;subscription-notification&quot;.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n          </div>\",
    \"status\": \"generated\"
  },
  \"title\": \"Search and retrieve prior events for a Subscription\",
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Subscription-events\",
  \"version\": \"6.0.0-ballot4\"
}"))
(define (events-operation handler)
  (define code "events")
  (list (operation-entry 'instance code "Subscription" handler)))
(define Group-everything-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
  \"code\": \"everything\",
  \"comment\": \"The key differences between this operation and simply searching the group's patients compartment are:    \\n\\n* unless the client requests otherwise, the server returns the entire result set in a single bundle (rather than using paging)  \\n* the server is responsible for determining what resources to return as included resources (rather than the client specifying which ones). \\n\\nThis frees the client from needing to determine what it could or should ask for, particularly with regard to included resources.  \\n\\nIt is assumed that the server has identified and secured the context appropriately, and can either associate the authorization context with a particular group, or determine whether the context has the rights to the nominated group, if there is one, or can determine an appropriate list of groups to provide data for from the context of the request.   If there is no nominated group (GET /[base]/Group/$everything) and the context is not associated with a single group record, the actual list of groups is all groups that the user associated with the request has access to. In such cases, the server may choose to return an error rather than all the records (and is likely to do so, but not required to).  Specifying the relationship between the context, a user and groups is outside the scope of this specification (though see [The SMART App Launch Implementation Guide](http://hl7.org/fhir/smart-app-launch)). \\n\\nThe return bundle from this operation is usually rather a lot of data; servers typically choose to require that such requests are made [asynchronously](async.html), and associated with [bulk data formats](resource-formats.html#bulk). Alternatively, clients may choose to page through the result set (or servers may require this). Paging through the results is done the same as for [Searching](http.html#paging), using the [_count](search.html#count) parameter, and Bundle links. Implementers should note that paging will be slower than simply returning all the results at once (more network traffic, multiple latency delays) but may be required in order not to exhaust available memory reading or writing the whole response in a single package. Unlike searching, there is no inherent user-display order for the $everything operation. Servers might consider sorting the returned resources in descending order of last record update, but are not required to do so.\\n\\nThe _since parameter is provided to support periodic queries to get additional information that has changed about the group since the last query. This means that the _since parameter is based on record time. The value of the _since parameter should be set to the time from the server. If using direct response, this is the timestamp in the response header. If using the async interface, this is the transaction timestamp in the json response. Servers should ensure that the timestamps a managed such that the client does not miss any changes. Clients should be able to handle getting the same response more than once in the case that the transaction falls on a time boundary. Clients should ensure that the other query parameters are constant to ensure a coherent set of records when doing periodic queries.\",
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
    },
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://www.hl7.org/Special/committees/fiwg\"
        }
      ]
    }
  ],
  \"date\": \"2026-05-28T22:17:06+00:00\",
  \"description\": \"This operation is used to return all the information related to one or more patients that are part of the group on which this operation is invoked. The response is a bundle of type \\\"searchset\\\". At a minimum, the patient resource(s) itself is returned, along with any other resources that the server has that are related to the patient(s), and that are available for the given user. The server also returns whatever resources are needed to support the records - e.g. linked practitioners, medications, locations, organizations etc.   The intended use for this operation is for a provider or other user to perform a bulk data download.  The server SHOULD return at least all resources that it has that are in the patient compartment for the identified patient(s), and any resource referenced from those, including binaries and attachments. In the US Realm, at a mimimum, the resources returned SHALL include all the data covered by the meaningful use common data elements as defined in [US-Core](http://hl7.org/fhir/us/core). Other applicable implementation guides may make additional rules about how much information that is returned.\",
  \"experimental\": false,
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 0
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"normative\"
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-wg\",
      \"valueCode\": \"fhir\"
    }
  ],
  \"id\": \"Group-everything\",
  \"instance\": true,
  \"jurisdiction\": [
    {
      \"coding\": [
        {
          \"code\": \"001\",
          \"display\": \"World\",
          \"system\": \"http://unstats.un.org/unsd/methods/m49/m49.htm\"
        }
      ]
    }
  ],
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2026-05-28T22:17:06.960+00:00\"
  },
  \"name\": \"Everything\",
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
  \"publisher\": \"HL7 International / FHIR Infrastructure\",
  \"resource\": [
    \"Group\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"active\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p class=\\\"res-header-id\\\">\\n              <b>Generated Narrative: OperationDefinition Group-everything</b>\\n            </p>\\n            <a name=\\\"Group-everything\\\"> </a>\\n            <a name=\\\"hcGroup-everything\\\"> </a>\\n            <p>URL: [base]/Group/[id]/$everything</p>\\n            <h3>Parameters</h3>\\n\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>start</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#date\\\">date</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The date range relates to care dates, not record currency dates - e.g. all records relating to care provided in a certain date range. If no start date is provided, all records prior to the end date are in scope.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>end</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#date\\\">date</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The date range relates to care dates, not record currency dates - e.g. all records relating to care provided in a certain date range. If no end date is provided, all records subsequent to the start date are in scope.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>_since</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#instant\\\">instant</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Resources updated after this period will be included in the response. The intent of this parameter is to allow a client to request only records that have changed since the last request, based on either the return header time, or or (for asynchronous use), the transaction time</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>_type</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>One or more parameters, each containing one or more comma-delimited FHIR resource types to include in the return resources. In the absense of any specified types, the server returns all resource types</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>_count</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#integer\\\">integer</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>See discussion below on the utility of paging through the results of the $everything operation</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>return</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"bundle.html\\\">Bundle</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The bundle type is &quot;searchset&quot;</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n\\n            <div>\\n              <p>The key differences between this operation and simply searching the group's patients compartment are:</p>\\n\\n              <ul>\\n\\n                <li>unless the client requests otherwise, the server returns the entire result set in a single bundle (rather than using paging)</li>\\n\\n                <li>the server is responsible for determining what resources to return as included resources (rather than the client specifying which ones).</li>\\n\\n              </ul>\\n\\n              <p>This frees the client from needing to determine what it could or should ask for, particularly with regard to included resources.</p>\\n\\n              <p>It is assumed that the server has identified and secured the context appropriately, and can either associate the authorization context with a particular group, or determine whether the context has the rights to the nominated group, if there is one, or can determine an appropriate list of groups to provide data for from the context of the request.   If there is no nominated group (GET /[base]/Group/$everything) and the context is not associated with a single group record, the actual list of groups is all groups that the user associated with the request has access to. In such cases, the server may choose to return an error rather than all the records (and is likely to do so, but not required to).  Specifying the relationship between the context, a user and groups is outside the scope of this specification (though see \\n                <a href=\\\"http://hl7.org/fhir/smart-app-launch\\\">The SMART App Launch Implementation Guide</a>).\\n              </p>\\n\\n              <p>The return bundle from this operation is usually rather a lot of data; servers typically choose to require that such requests are made \\n                <a href=\\\"async.html\\\">asynchronously</a>, and associated with \\n                <a href=\\\"resource-formats.html#bulk\\\">bulk data formats</a>. Alternatively, clients may choose to page through the result set (or servers may require this). Paging through the results is done the same as for \\n                <a href=\\\"http.html#paging\\\">Searching</a>, using the \\n                <a href=\\\"search.html#count\\\">_count</a> parameter, and Bundle links. Implementers should note that paging will be slower than simply returning all the results at once (more network traffic, multiple latency delays) but may be required in order not to exhaust available memory reading or writing the whole response in a single package. Unlike searching, there is no inherent user-display order for the $everything operation. Servers might consider sorting the returned resources in descending order of last record update, but are not required to do so.\\n              </p>\\n\\n              <p>The _since parameter is provided to support periodic queries to get additional information that has changed about the group since the last query. This means that the _since parameter is based on record time. The value of the _since parameter should be set to the time from the server. If using direct response, this is the timestamp in the response header. If using the async interface, this is the transaction timestamp in the json response. Servers should ensure that the timestamps a managed such that the client does not miss any changes. Clients should be able to handle getting the same response more than once in the case that the transaction falls on a time boundary. Clients should ensure that the other query parameters are constant to ensure a coherent set of records when doing periodic queries.</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"generated\"
  },
  \"title\": \"Fetch a group of Patient Records\",
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Group-everything\",
  \"version\": \"6.0.0-ballot4\"
}"))
(define (Group-everything-operation handler)
  (define code "everything")
  (list (operation-entry 'instance code "Group" handler)))
(define MedicinalProductDefinition-everything-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
  \"code\": \"everything\",
  \"comment\": \"The key differences between this operation and simply performing a search and using _include and _revinclude are:    \\n\\n* unless the client requests otherwise, the server returns the entire result set in a single bundle (rather than using paging)  \\n* the server is responsible for determining what resources to return as included resources (rather than the client specifying which ones). \\n\\nThis frees the client from needing to determine what it could or should ask for, particularly with regard to included resources. It also makes for a much shorter and easier to construct query string. Servers should consider returning appropriate Provenance and AuditTrail on the returned resources, even though these are not directly part of the product data. \\n\\nWhen this operation is used to access multiple product records at once, the return bundle could be rather a lot of data; servers may choose to require that such requests are made [asynchronously](async.html), and associated with [bulk data formats](resource-formats.html#bulk). Alternatively, clients may choose to page through the result set (or servers may require this). Paging through the results is done the same as for [Searching](http.html#paging), using the [_count](search.html#count) parameter, and Bundle links. Implementers should note that paging will be slower than simply returning all the results at once (more network traffic, multiple latency delays) but may be required in order not to exhaust available memory reading or writing the whole response in a single package. Unlike searching, there is no inherent user-display order for the $everything operation. Servers might consider sorting the returned resources in descending order of last record update, but are not required to do so.\\n\\nThe _since parameter is provided to support periodic queries to get additional information that has changed about the product since the last query. This means that the _since parameter is based on record time. The value of the _since parameter should be set to the time from the server. If using direct response, this is the timestamp in the response header. If using the async interface, this is the transaction timestamp in the json response. Servers should ensure that the timestamps a managed such that the client does not miss any changes. Clients should be able to handle getting the same response more than once in the case that the transaction falls on a time boundary. Clients should ensure that the other query parameters are constant to ensure a coherent set of records when doing periodic queries.\",
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
    },
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://www.hl7.org/Special/committees/rcrim\"
        }
      ]
    }
  ],
  \"date\": \"2026-05-28T22:17:06+00:00\",
  \"description\": \"This operation is used to return all the information related to one or more products described in the resource or context on which this operation is invoked. The response is a bundle of type \\\"searchset\\\". At a minimum, the product resource(s) itself is returned, along with any other resources that the server has that are related to the products(s), and that are available for the given user. This is typically the marketing authorizations, ingredients, packages, therapeutic indications and so on. The server also returns whatever resources are needed to support the records - e.g. linked organizations, document references etc.\",
  \"experimental\": false,
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 1
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"normative\"
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-wg\",
      \"valueCode\": \"brr\"
    }
  ],
  \"id\": \"MedicinalProductDefinition-everything\",
  \"instance\": true,
  \"jurisdiction\": [
    {
      \"coding\": [
        {
          \"code\": \"001\",
          \"display\": \"World\",
          \"system\": \"http://unstats.un.org/unsd/methods/m49/m49.htm\"
        }
      ]
    }
  ],
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2026-05-28T22:17:06.960+00:00\"
  },
  \"name\": \"Everything\",
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
  \"publisher\": \"HL7 International / Biomedical Research and Regulation\",
  \"resource\": [
    \"MedicinalProductDefinition\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"active\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p class=\\\"res-header-id\\\">\\n              <b>Generated Narrative: OperationDefinition MedicinalProductDefinition-everything</b>\\n            </p>\\n            <a name=\\\"MedicinalProductDefinition-everything\\\"> </a>\\n            <a name=\\\"hcMedicinalProductDefinition-everything\\\"> </a>\\n            <p>URL: [base]/MedicinalProductDefinition/$everything</p>\\n            <p>URL: [base]/MedicinalProductDefinition/[id]/$everything</p>\\n            <h3>Parameters</h3>\\n\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>_since</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#instant\\\">instant</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Resources updated after this period will be included in the response. The intent of this parameter is to allow a client to request only records that have changed since the last request, based on either the return header time, or or (for asynchronous use), the transaction time</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>_count</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#integer\\\">integer</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>See discussion below on the utility of paging through the results of the $everything operation</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>return</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"bundle.html\\\">Bundle</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The bundle type is &quot;searchset&quot;</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n\\n            <div>\\n              <p>The key differences between this operation and simply performing a search and using _include and _revinclude are:</p>\\n\\n              <ul>\\n\\n                <li>unless the client requests otherwise, the server returns the entire result set in a single bundle (rather than using paging)</li>\\n\\n                <li>the server is responsible for determining what resources to return as included resources (rather than the client specifying which ones).</li>\\n\\n              </ul>\\n\\n              <p>This frees the client from needing to determine what it could or should ask for, particularly with regard to included resources. It also makes for a much shorter and easier to construct query string. Servers should consider returning appropriate Provenance and AuditTrail on the returned resources, even though these are not directly part of the product data.</p>\\n\\n              <p>When this operation is used to access multiple product records at once, the return bundle could be rather a lot of data; servers may choose to require that such requests are made \\n                <a href=\\\"async.html\\\">asynchronously</a>, and associated with \\n                <a href=\\\"resource-formats.html#bulk\\\">bulk data formats</a>. Alternatively, clients may choose to page through the result set (or servers may require this). Paging through the results is done the same as for \\n                <a href=\\\"http.html#paging\\\">Searching</a>, using the \\n                <a href=\\\"search.html#count\\\">_count</a> parameter, and Bundle links. Implementers should note that paging will be slower than simply returning all the results at once (more network traffic, multiple latency delays) but may be required in order not to exhaust available memory reading or writing the whole response in a single package. Unlike searching, there is no inherent user-display order for the $everything operation. Servers might consider sorting the returned resources in descending order of last record update, but are not required to do so.\\n              </p>\\n\\n              <p>The _since parameter is provided to support periodic queries to get additional information that has changed about the product since the last query. This means that the _since parameter is based on record time. The value of the _since parameter should be set to the time from the server. If using direct response, this is the timestamp in the response header. If using the async interface, this is the transaction timestamp in the json response. Servers should ensure that the timestamps a managed such that the client does not miss any changes. Clients should be able to handle getting the same response more than once in the case that the transaction falls on a time boundary. Clients should ensure that the other query parameters are constant to ensure a coherent set of records when doing periodic queries.</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"generated\"
  },
  \"title\": \"Fetch Product Record\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/MedicinalProductDefinition-everything\",
  \"version\": \"6.0.0-ballot4\"
}"))
(define (MedicinalProductDefinition-everything-operation handler)
  (define code "everything")
  (list (operation-entry 'type code "MedicinalProductDefinition" handler)
        (operation-entry 'instance code "MedicinalProductDefinition" handler)))
(define example-query-high-risk-definition
  (string->jsexpr
   "{
  \"code\": \"example-query-high-risk\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://www.hl7.org/Special/committees/fiwg\"
        }
      ]
    }
  ],
  \"description\": \"Example Named Query of Patients based on risk assessments\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-wg\",
      \"valueCode\": \"fhir\"
    }
  ],
  \"id\": \"example-query-high-risk\",
  \"instance\": false,
  \"kind\": \"query\",
  \"name\": \"ExampleOfHighRiskPatientQuery\",
  \"parameter\": [
    {
      \"documentation\": \"Ward filters to apply to patient locations\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"ward\",
      \"searchType\": \"reference\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Searchset bundle\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"result\",
      \"type\": \"Bundle\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 International / FHIR Infrastructure\",
  \"resource\": [
    \"Patient\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"title\": \"Example of High-Risk Patient Query\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/example-query-high-risk\",
  \"version\": \"0.0.1\"
}"))
(define (example-query-high-risk-operation handler)
  (define code "example-query-high-risk")
  (list (operation-entry 'type code "Patient" handler)))
(define expand-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
  \"code\": \"expand\",
  \"comment\": \"The value set expansion returned by this query should be treated as a transient result that will change over time (whether it does or not depends on how the value set is specified), so applications should repeat the operation each time the value set is used.  \\n\\nWhen available, ValueSet.status and ValueSet.version from the ValueSet resource instance which contains the definition SHALL be persisted to the ValueSet resource instance which contains the expansion.   \\n\\nIf the expansion is too large (at the discretion of the server), the server MAY return an error (OperationOutcome with code too-costly). Clients can work through large flat expansions in a set of pages (partial views of the full expansion) instead of just getting the full expansion in a single exchange by using offset and count parameters, or use the count parameter to request a subset of the expansion for limited purposes. Servers are not obliged to support paging, but if they do, SHALL support both the offset and count parameters. Hierarchical expansions are not subject to paging and servers simply return the entire expansion.  \\n\\nDifferent servers may return different results from expanding a value set for the following reasons:  \\n\\n* The underlying code systems are different (e.g. different versions, possibly with different defined behavior) \\n* The server optimizes filter includes differently, such as sorting by code frequency \\n* Servers introduce arbitrary groups to assist a user to navigate the lists based either on extensions in the definition, or additional knowledge available to the server\\n\\nWhen a server cannot correctly expand a value set because it does not fully understand the code systems (e.g. it has the wrong version, or incomplete definitions) then it SHALL return an error. If the value set itself is unbounded due to the inclusion of post-coordinated value sets (e.g. SNOMED CT, UCUM), then the extension [http://hl7.org/fhir/StructureDefinition/valueset-unclosed](https://build.fhir.org/ig/HL7/fhir-extensions/StructureDefinition-valueset-unclosed.html) can be used to indicate that the expansion is incomplete\",
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
    },
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://www.hl7.org/Special/committees/Vocab\"
        }
      ]
    }
  ],
  \"date\": \"2026-05-28T22:17:06+00:00\",
  \"description\": \"The definition of a value set is used to create a simple collection of codes suitable for use for data entry or validation. \\n\\nIf the operation is not called at the instance level, one of the in parameters url, context or valueSet must be provided.  An expanded value set will be returned, or an OperationOutcome with an error message.\",
  \"experimental\": false,
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
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-wg\",
      \"valueCode\": \"vocab\"
    }
  ],
  \"id\": \"ValueSet-expand\",
  \"instance\": true,
  \"jurisdiction\": [
    {
      \"coding\": [
        {
          \"code\": \"001\",
          \"display\": \"World\",
          \"system\": \"http://unstats.un.org/unsd/methods/m49/m49.htm\"
        }
      ]
    }
  ],
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2026-05-28T22:17:06.960+00:00\"
  },
  \"name\": \"Expand\",
  \"parameter\": [
    {
      \"documentation\": \"A reference to the canonical URL of a value set. The server must know the value set (e.g. it is defined explicitly in the server's value sets, or it is defined implicitly by some code system known to the server\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"url\",
      \"scope\": [
        \"type\"
      ],
      \"type\": \"uri\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The value set is provided directly as part of the request. Servers may choose not to accept value sets in this fashion\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"valueSet\",
      \"scope\": [
        \"type\"
      ],
      \"type\": \"ValueSet\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The identifier that is used to identify a specific version of the value set to be used when generating the expansion. This is an arbitrary value managed by the value set author and is not expected to be globally unique. For example, it might be a timestamp (e.g. yyyymmdd) if a managed version is not available.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"valueSetVersion\",
      \"scope\": [
        \"type\"
      ],
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
      \"documentation\": \"A text filter that is applied to restrict the codes that are returned (this is useful in a UI context). The interpretation of this is delegated to the server in order to allow to determine the most optimal search approach for the context. The server can document the way this parameter works in [TerminologyCapabilities](terminologycapabilities.html)..expansion.textFilter. Typical usage of this parameter includes functionality like:\\n\\n* using left matching e.g. \\\"acut ast\\\"\\n* allowing for wild cards such as %, &, ?\\n* searching on definition, designations and display(s)\\n* allowing for search conditions (and / or / exclusions)\\n\\nText Search engines such as Lucene or Solr, long with their considerable functionality, might also be used. The optional text search might also be code system specific, and servers might have different implementations for different code systems\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"filter\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Properties to be considered when matching against the filter text in addition to display, definition and designations, etc. The properties must have a string representation, e.g. string, code, or url, though the search is always text based irrespective of the property type.\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"filterProperty\",
      \"type\": \"code\",
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
      \"documentation\": \"Controls whether the value set definition is included or excluded in value set expansions. This includes all elements of the ValueSet, including extensions, with the exception that the `id` and `meta` elements would be specific to the expansion, not to the definition value set, and the expansion itself is filled out.\",
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
      \"documentation\": \"The supplement must be used when performing an expansion. Use of this parameter should result in $expand behaving the same way as if the supplements were included in the value set definition using the [http://hl7.org/fhir/StructureDefinition/valueset-supplement](https://build.fhir.org/ig/HL7/fhir-extensions/StructureDefinition-valueset-supplement.html)\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"useSupplement\",
      \"type\": \"canonical\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Controls whether or not the value set expansion may nest codes or not (i.e. ValueSet.expansion.contains.contains). If excludeNested is set to true, the expansion MUST be flat (no nesting). If excludeNested is set to false (default),  however, nesting is possible but not required\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"excludeNested\",
      \"type\": \"boolean\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Controls whether or not the value set expansion might include\\r\\n\\r\\n* codes from the CodeSystem with a notSelectable property set to true as specified in [status](codesystem.html#status) and in [Concept Properties](codesystem-concept-properties.html)\\r\\n* nested contains with no code (see [Contains](valueset-definitions.html#ValueSet.expansion.contains.code))\\r\\n* nested contains in the ValueSet with [abstract = true](valueset-definitions.html#ValueSet.expansion.contains.abstract)\\r\\n\\r\\nOne purpose of such concepts is helping a user navigate through the list efficiently. If excludeNotForUI is set to true, the concepts as described above will be excluded from the expansion. If excludeNotForUI is set to false (default), all concepts as described above may be part of the expansion. In the FHIR Specification itself, the value set expansions are generated with excludeNotForUI = false, and the expansions used when generating schema / code etc., or performing validation, are all excludeNotForUI = true.\",
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
      \"documentation\": \"A request to return a particular property in the expansion. The returned property may include subproperties. May be either a code from the code system definition (convenient) or a the formal URI that refers to the property. Note that property names can clash, so using a URI is recommended. The special value '*' means all properties and their sub-properties known to the server\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"property\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"If true this asserts that you will correctly handle an unclosed expansion and the returned expansion SHALL include the valueset-unclosed extension if the value set is unclosed.  If handle-unclosed-expansion is set to false the server SHALL return an error if the value set is unclosed.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"handle-unclosed-expansion\",
      \"type\": \"boolean\",
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
      \"documentation\": \"Edge Case: Specifies a version to use for a system. This parameter overrides any specified version in the value set (and any it depends on). The format is the same as a canonical URL: [system]|[version] - e.g. http://loinc.org|2.56. Note that this has obvious safety issues, in that it may result in a value set expansion giving a different list of codes that is both wrong and unsafe, and implementers should only use this capability reluctantly. It primarily exists to deal with situations where specifications have fallen into decay as time passes. If the value is overridden, the version used SHALL explicitly be represented in the expansion parameters\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"force-system-version\",
      \"type\": \"canonical\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Specifies a version to use for a valueset, if the reference to the value set does not specify which version to use. The format is the same as a canonical URL: [system]|[version] - e.g. http://example.org/ValueSet/example|1.0.0. Note that this is similar to the force-system-version parameter but applied to valuesets\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"default-valueset-version\",
      \"type\": \"canonical\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Edge Case: Specifies a version to use for a valueset. If a reference to a value set specifies a different version, an error is returned instead of the expansion. The format is the same as a canonical URL: [system]|[version] - e.g. http://example.org/ValueSet/example|1.0.0. Note that this is similar to the force-system-version parameter but applied to valuesets\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"check-valueset-version\",
      \"type\": \"canonical\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Edge Case: Specifies a version to use for a valueset. This parameter overrides any specified version in the reference to the value set (and any it depends on). The format is the same as a canonical URL: [system]|[version] - e.g. http://example.org/ValueSet/example|1.0.0. Note that this has obvious safety issues, in that it may result in a value set expansion giving a different list of codes that is both wrong and unsafe, and implementers should only use this capability reluctantly. It primarily exists to deal with situations where specifications have fallen into decay as time passes. If the value is overridden, the version used SHALL explicitly be represented in the expansion parameters. Note that this is similar to the force-system-version parameter but applied to valuesets.\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"force-valueset-version\",
      \"type\": \"canonical\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Specifies an library that provides expansion rules for the operation. The library has an extension expansionParameters that references a contained Parameters resource that contains additional $expand parameters. See the [CRMI specification description of manifests]https://hl7.org/fhir/uv/crmi/STU1/StructureDefinition-crmi-manifestlibrary.html) and [CRMI expansion rules](https://hl7.org/fhir/uv/crmi/STU1/artifact-terminology-service.html#expansion-rules) for a complete description of how manifest values are used to provide defaults for expansion parameters. Parameters specified directly in an $expand operation override behaviors specified by the manifest parameter.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"manifest\",
      \"targetProfile\": [
        \"http://hl7.org/fhir/StructureDefinition/Library\"
      ],
      \"type\": \"canonical\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"One or more additional resources that are referred to from the value set provided with the $expand or $validate-code invocation. These may be additional value sets or code systems that the client believes will or may be necessary to perform the operation. Resources provided in this fashion are used preferentially to those known to the system, though servers may return an error if these resources are already known to the server (by URL and version) but differ from that information on the server.\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"tx-resource\",
      \"type\": \"Resource\",
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
  \"publisher\": \"HL7 International / Terminology Infrastructure\",
  \"resource\": [
    \"ValueSet\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"active\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p class=\\\"res-header-id\\\">\\n              <b>Generated Narrative: OperationDefinition ValueSet-expand</b>\\n            </p>\\n            <a name=\\\"ValueSet-expand\\\"> </a>\\n            <a name=\\\"hcValueSet-expand\\\"> </a>\\n            <p>URL: [base]/ValueSet/$expand</p>\\n            <p>URL: [base]/ValueSet/[id]/$expand</p>\\n            <h3>Parameters</h3>\\n\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>url</td>\\n\\n                <td>type</td>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>A reference to the canonical URL of a value set. The server must know the value set (e.g. it is defined explicitly in the server's value sets, or it is defined implicitly by some code system known to the server</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>valueSet</td>\\n\\n                <td>type</td>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"valueset.html\\\">ValueSet</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The value set is provided directly as part of the request. Servers may choose not to accept value sets in this fashion</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>valueSetVersion</td>\\n\\n                <td>type</td>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The identifier that is used to identify a specific version of the value set to be used when generating the expansion. This is an arbitrary value managed by the value set author and is not expected to be globally unique. For example, it might be a timestamp (e.g. yyyymmdd) if a managed version is not available.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>context</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The context of the value set, so that the server can resolve this to a value set to expand. The recommended format for this URI is [Structure Definition URL]#[name or path into structure definition] e.g. http://hl7.org/fhir/StructureDefinition/observation-hspc-height-hspcheight#Observation.interpretation. Other forms may be used but are not defined. This form is only usable if the terminology server also has access to the conformance registry that the server is using, but can be used to delegate the mapping from an application context to a binding at run-time</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>contextDirection</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>If a context is provided, a context direction may also be provided. Valid values are:</p>\\n\\n                    <ul>\\n\\n                      <li>'incoming': the codes a client can use for PUT/POST operations,  and</li>\\n\\n                      <li>'outgoing', the codes a client might receive from the server.</li>\\n\\n                    </ul>\\n\\n                    <p>The purpose is to inform the server whether to use the value set associated with the context for reading or writing purposes (note: for most elements, this is the same value set, but there are a few elements where the reading and writing value sets are different)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>filter</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>A text filter that is applied to restrict the codes that are returned (this is useful in a UI context). The interpretation of this is delegated to the server in order to allow to determine the most optimal search approach for the context. The server can document the way this parameter works in \\n                      <a href=\\\"terminologycapabilities.html\\\">TerminologyCapabilities</a>..expansion.textFilter. Typical usage of this parameter includes functionality like:\\n                    </p>\\n\\n                    <ul>\\n\\n                      <li>using left matching e.g. &quot;acut ast&quot;</li>\\n\\n                      <li>allowing for wild cards such as %, &amp;, ?</li>\\n\\n                      <li>searching on definition, designations and display(s)</li>\\n\\n                      <li>allowing for search conditions (and / or / exclusions)</li>\\n\\n                    </ul>\\n\\n                    <p>Text Search engines such as Lucene or Solr, long with their considerable functionality, might also be used. The optional text search might also be code system specific, and servers might have different implementations for different code systems</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>filterProperty</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Properties to be considered when matching against the filter text in addition to display, definition and designations, etc. The properties must have a string representation, e.g. string, code, or url, though the search is always text based irrespective of the property type.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>date</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#dateTime\\\">dateTime</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The date for which the expansion should be generated.  if a date is provided, it means that the server should use the value set / code system definitions as they were on the given date, or return an error if this is not possible.  Normally, the date is the current conditions (which is the default value) but under some circumstances, systems need to generate an expansion as it would have been in the past. A typical example of this would be where code selection is constrained to the set of codes that were available when the patient was treated, not when the record is being edited. Note that which date is appropriate is a matter for implementation policy.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>offset</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#integer\\\">integer</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Paging support - where to start if a subset is desired (default = 0). Offset is number of records (not number of pages)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>count</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#integer\\\">integer</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Paging support - how many codes should be provided in a partial page view. Paging only applies to flat expansions - servers ignore paging if the expansion is not flat.  If count = 0, the client is asking how large the expansion is. Servers SHOULD honor this request for hierarchical expansions as well, and simply return the overall count</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>includeDesignations</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Controls whether concept designations are to be included or excluded in value set expansions</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>designation</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>A \\n                      <a href=\\\"search.html#token\\\">token</a> that specifies a system+code that is either a use or a language. Designations that match by language or use are included in the expansion. If no designation is specified, it is at the server discretion which designations to return\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>includeDefinition</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Controls whether the value set definition is included or excluded in value set expansions. This includes all elements of the ValueSet, including extensions, with the exception that the \\n                      <code>id</code> and \\n                      <code>meta</code> elements would be specific to the expansion, not to the definition value set, and the expansion itself is filled out.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>activeOnly</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Controls whether inactive concepts are included or excluded in value set expansions. Note that if the value set explicitly specifies that inactive codes are included, this parameter can still remove them from a specific expansion, but this parameter cannot include them if the value set excludes them</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>useSupplement</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The supplement must be used when performing an expansion. Use of this parameter should result in $expand behaving the same way as if the supplements were included in the value set definition using the \\n                      <a href=\\\"https://build.fhir.org/ig/HL7/fhir-extensions/StructureDefinition-valueset-supplement.html\\\">http://hl7.org/fhir/StructureDefinition/valueset-supplement</a>\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>excludeNested</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Controls whether or not the value set expansion may nest codes or not (i.e. ValueSet.expansion.contains.contains). If excludeNested is set to true, the expansion MUST be flat (no nesting). If excludeNested is set to false (default),  however, nesting is possible but not required</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>excludeNotForUI</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Controls whether or not the value set expansion might include</p>\\n\\n                    <ul>\\n\\n                      <li>codes from the CodeSystem with a notSelectable property set to true as specified in \\n                        <a href=\\\"codesystem.html#status\\\">status</a> and in \\n                        <a href=\\\"codesystem-concept-properties.html\\\">Concept Properties</a>\\n                      </li>\\n\\n                      <li>nested contains with no code (see \\n                        <a href=\\\"valueset-definitions.html#ValueSet.expansion.contains.code\\\">Contains</a>)\\n                      </li>\\n\\n                      <li>nested contains in the ValueSet with \\n                        <a href=\\\"valueset-definitions.html#ValueSet.expansion.contains.abstract\\\">abstract = true</a>\\n                      </li>\\n\\n                    </ul>\\n\\n                    <p>One purpose of such concepts is helping a user navigate through the list efficiently. If excludeNotForUI is set to true, the concepts as described above will be excluded from the expansion. If excludeNotForUI is set to false (default), all concepts as described above may be part of the expansion. In the FHIR Specification itself, the value set expansions are generated with excludeNotForUI = false, and the expansions used when generating schema / code etc., or performing validation, are all excludeNotForUI = true.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>excludePostCoordinated</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Controls whether or not the value set expansion includes post coordinated codes</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>displayLanguage</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Specifies the language to be used for description in the expansions i.e. the language to be used for ValueSet.expansion.contains.display</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>property</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>A request to return a particular property in the expansion. The returned property may include subproperties. May be either a code from the code system definition (convenient) or a the formal URI that refers to the property. Note that property names can clash, so using a URI is recommended. The special value '*' means all properties and their sub-properties known to the server</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>handle-unclosed-expansion</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>If true this asserts that you will correctly handle an unclosed expansion and the returned expansion SHALL include the valueset-unclosed extension if the value set is unclosed.  If handle-unclosed-expansion is set to false the server SHALL return an error if the value set is unclosed.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>exclude-system</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Code system, or a particular version of a code system to be excluded from the value set expansion. The format is the same as a canonical URL: [system]|[version] - e.g. http://loinc.org|2.56</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>system-version</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Specifies a version to use for a system, if the value set does not specify which one to use. The format is the same as a canonical URL: [system]|[version] - e.g. http://loinc.org|2.56</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>check-system-version</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Edge Case: Specifies a version to use for a system. If a value set specifies a different version, an error is returned instead of the expansion. The format is the same as a canonical URL: [system]|[version] - e.g. http://loinc.org|2.56</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>force-system-version</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Edge Case: Specifies a version to use for a system. This parameter overrides any specified version in the value set (and any it depends on). The format is the same as a canonical URL: [system]|[version] - e.g. http://loinc.org|2.56. Note that this has obvious safety issues, in that it may result in a value set expansion giving a different list of codes that is both wrong and unsafe, and implementers should only use this capability reluctantly. It primarily exists to deal with situations where specifications have fallen into decay as time passes. If the value is overridden, the version used SHALL explicitly be represented in the expansion parameters</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>default-valueset-version</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Specifies a version to use for a valueset, if the reference to the value set does not specify which version to use. The format is the same as a canonical URL: [system]|[version] - e.g. http://example.org/ValueSet/example|1.0.0. Note that this is similar to the force-system-version parameter but applied to valuesets</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>check-valueset-version</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Edge Case: Specifies a version to use for a valueset. If a reference to a value set specifies a different version, an error is returned instead of the expansion. The format is the same as a canonical URL: [system]|[version] - e.g. http://example.org/ValueSet/example|1.0.0. Note that this is similar to the force-system-version parameter but applied to valuesets</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>force-valueset-version</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Edge Case: Specifies a version to use for a valueset. This parameter overrides any specified version in the reference to the value set (and any it depends on). The format is the same as a canonical URL: [system]|[version] - e.g. http://example.org/ValueSet/example|1.0.0. Note that this has obvious safety issues, in that it may result in a value set expansion giving a different list of codes that is both wrong and unsafe, and implementers should only use this capability reluctantly. It primarily exists to deal with situations where specifications have fallen into decay as time passes. If the value is overridden, the version used SHALL explicitly be represented in the expansion parameters. Note that this is similar to the force-system-version parameter but applied to valuesets.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>manifest</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a> (\\n                  <a href=\\\"library.html\\\" title=\\\"http://hl7.org/fhir/StructureDefinition/Library\\\">Library</a>)\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Specifies an library that provides expansion rules for the operation. The library has an extension expansionParameters that references a contained Parameters resource that contains additional $expand parameters. See the [CRMI specification description of manifests]https://hl7.org/fhir/uv/crmi/STU1/StructureDefinition-crmi-manifestlibrary.html) and \\n                      <a href=\\\"https://hl7.org/fhir/uv/crmi/STU1/artifact-terminology-service.html#expansion-rules\\\">CRMI expansion rules</a> for a complete description of how manifest values are used to provide defaults for expansion parameters. Parameters specified directly in an $expand operation override behaviors specified by the manifest parameter.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>tx-resource</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"resource.html\\\">Resource</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>One or more additional resources that are referred to from the value set provided with the $expand or $validate-code invocation. These may be additional value sets or code systems that the client believes will or may be necessary to perform the operation. Resources provided in this fashion are used preferentially to those known to the system, though servers may return an error if these resources are already known to the server (by URL and version) but differ from that information on the server.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>return</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"valueset.html\\\">ValueSet</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The result of the expansion. Servers generating expansions SHOULD ensure that all the parameters that affect the contents of the expansion are recorded in the ValueSet.expansion.parameter list</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n\\n            <div>\\n              <p>The value set expansion returned by this query should be treated as a transient result that will change over time (whether it does or not depends on how the value set is specified), so applications should repeat the operation each time the value set is used.</p>\\n\\n              <p>When available, ValueSet.status and ValueSet.version from the ValueSet resource instance which contains the definition SHALL be persisted to the ValueSet resource instance which contains the expansion.</p>\\n\\n              <p>If the expansion is too large (at the discretion of the server), the server MAY return an error (OperationOutcome with code too-costly). Clients can work through large flat expansions in a set of pages (partial views of the full expansion) instead of just getting the full expansion in a single exchange by using offset and count parameters, or use the count parameter to request a subset of the expansion for limited purposes. Servers are not obliged to support paging, but if they do, SHALL support both the offset and count parameters. Hierarchical expansions are not subject to paging and servers simply return the entire expansion.</p>\\n\\n              <p>Different servers may return different results from expanding a value set for the following reasons:</p>\\n\\n              <ul>\\n\\n                <li>The underlying code systems are different (e.g. different versions, possibly with different defined behavior)</li>\\n\\n                <li>The server optimizes filter includes differently, such as sorting by code frequency</li>\\n\\n                <li>Servers introduce arbitrary groups to assist a user to navigate the lists based either on extensions in the definition, or additional knowledge available to the server</li>\\n\\n              </ul>\\n\\n              <p>When a server cannot correctly expand a value set because it does not fully understand the code systems (e.g. it has the wrong version, or incomplete definitions) then it SHALL return an error. If the value set itself is unbounded due to the inclusion of post-coordinated value sets (e.g. SNOMED CT, UCUM), then the extension \\n                <a href=\\\"https://build.fhir.org/ig/HL7/fhir-extensions/StructureDefinition-valueset-unclosed.html\\\">http://hl7.org/fhir/StructureDefinition/valueset-unclosed</a> can be used to indicate that the expansion is incomplete\\n              </p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"generated\"
  },
  \"title\": \"Value Set Expansion\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/ValueSet-expand\",
  \"version\": \"6.0.0-ballot4\"
}"))
(define (expand-operation handler)
  (define code "expand")
  (list (operation-entry 'type code "ValueSet" handler)
        (operation-entry 'instance code "ValueSet" handler)))
(define graphql-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
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
    },
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://www.hl7.org/Special/committees/fiwg\"
        }
      ]
    }
  ],
  \"date\": \"2026-05-28T22:17:06+00:00\",
  \"description\": \"Execute a graphql statement on a since resource or against the entire system. See the [Using GraphQL with FHIR](graphql.html) page for further details.\\n\\nFor the purposes of graphQL compatibility, this operation can also be invoked using a POST with the graphQL as the body, or a JSON body (see [graphQL spec](http://graphql.org/) for details)\",
  \"experimental\": false,
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 1
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"normative\"
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-wg\",
      \"valueCode\": \"fhir\"
    }
  ],
  \"id\": \"Resource-graphql\",
  \"instance\": true,
  \"jurisdiction\": [
    {
      \"coding\": [
        {
          \"code\": \"001\",
          \"display\": \"World\",
          \"system\": \"http://unstats.un.org/unsd/methods/m49/m49.htm\"
        }
      ]
    }
  ],
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2026-05-28T22:17:06.960+00:00\"
  },
  \"name\": \"Graphql\",
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
  \"publisher\": \"HL7 International / FHIR Infrastructure\",
  \"resource\": [
    \"Resource\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"active\",
  \"system\": true,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p class=\\\"res-header-id\\\">\\n              <b>Generated Narrative: OperationDefinition Resource-graphql</b>\\n            </p>\\n            <a name=\\\"Resource-graphql\\\"> </a>\\n            <a name=\\\"hcResource-graphql\\\"> </a>\\n            <p>URL: [base]/$graphql</p>\\n            <p>URL: [base]/Resource/[id]/$graphql</p>\\n            <h3>Parameters</h3>\\n\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>query</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td/>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>result</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"binary.html\\\">Binary</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The content is always returned as application/json; this SHOULD be specified in the Accept header</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n          </div>\",
    \"status\": \"generated\"
  },
  \"title\": \"Execute a graphql statement\",
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Resource-graphql\",
  \"version\": \"6.0.0-ballot4\"
}"))
(define (graphql-operation handler)
  (define code "graphql")
  (list (operation-entry 'system code #f handler)
        (operation-entry 'instance code "Resource" handler)))
(define lastn-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
  \"code\": \"lastn\",
  \"comment\": \"The key differences between this query operation and simply searching Observation using the combination of `_count` and `_sort` parameters are:\\r\\r* The *lastn* query returns **only** the last N resource grouped by code. Using the _count query method doesn't restrict the total matches so you may need to page through several \\\"A\\\" Observations before getting to Observation \\\"B\\\".\\r* The server is responsible for grouping the observations by codes. This frees the client from needing to determine which codes she should ask for.\\r\\rThis operation cannot be performed on observations that the user is not authorized to see. It is assumed that the server has identified and secured the context appropriately, and can either associate the authorization context with a single patient, or determine whether the context has the rights to the nominated patient, if there is one. If there is no nominated patient (e.g. the operation is invoked at the system level) and the context is not associated with a single patient record, then the server should return an error. Specifying the relationship between the context, a user and patient records is outside the scope of this specification.\",
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
    },
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://www.hl7.org/Special/committees/orders\"
        }
      ]
    }
  ],
  \"date\": \"2026-05-28T22:17:06+00:00\",
  \"description\": \"The *lastn query* meets the common need for searching for the most recent or last n=number of observations for a subject. For example, retrieving the last 5 temperatures for a patient to view trends or fetching the most recent laboratory results or vitals signs. To ask a server to return the last n=number of observations, the *lastn* query uses the [normal search parameters](observation.html#search) defined for the Observation resource. However, rather than their normal use, they are interpreted as inputs - i.e.. instead of requiring that the resources literally contain the search parameters, they are passed to a server algorithm of some kind that uses them to determine the most appropriate matches.\\n\\nThe request for a lastn query SHALL include:\\n\\n* A `$lastn` operation parameter\\n* A subject using either the `patient` or `subject` search parameter\\n* A `category` parameter and/or a search parameter that contains a code element in its FHIRpath expression. ( e.g., `code` or `code-value-concept`)\\n\\nThe request for a lastn query MAY include:\\n\\n* Other Observation search parameters and modifiers\\n\\nThe response from a lastn query is a set of observations:\\n\\n* Filtered by additional parameters\\n   * If not explicitly filtered by status then will include statuses of 'entered-in-error'\\n* Ordered first by “equivalent” `Observation.code` value\\n   * Codes SHALL be considered equivalent if the `coding.value` *and* `coding.system` are the same.\\n   * Text only codes SHALL be treated and grouped based on the text.\\n   * For codes with translations (multiple codings), the code translations are assumed to be equal and the grouping by code SHALL follow the transitive property of equality. For example:\\n\\n  |Observation.code for observation a|Observation.code for observation b|Observation.code for observation c|number of groups [codes/text in each group]|\\n  |---|---|---|---|\\n  |a|b|c | 3 [a],[b],[c]|\\n  |a|b|a,c | 2 [a.c],[b]|\\n  |a|b|a,b | 1 [a,b]|\\n  |'textM'|'Text'|'t e x t'|3 ['text'],['Text'],['t e x t']|\\n\\n* The ordering of the “equivalent” code groups is not specified.\\n* Ordered secondly (within each code group) from most recent effective time to the oldest effective time. For further guidance, refer here on [sorting](https://www.hl7.org/fhir/search.html#_sort).\\n* Limited to the number of requested responses per group specified by the optional *max* query parameter\\n  * In case of a tie—when the effective times for more than one Observation in the same code group—both will be returned. Therefore, more Observations may be returned than is specified in *max*. For example, 4 Observations instead of 3 if the 3rd and 4th most recent observation had the same effective time.\\n* If no maximum number is given then only the most recent Observation in each group is returned.\\n\\nNote that the individual Observation.code values used for grouping might not be explicit in the request, for example if a category of Observations is requested, or if a code is specified with the `:below` modifier.\\n\\nThe set of returned observations should represent distinct real-world observations and not the same observation with changes in status or versions. If there are no matches, the *lastn* query SHALL return an empty search set with no error, but may include an operation outcome with further advice.\",
  \"experimental\": false,
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 3
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"normative\"
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-wg\",
      \"valueCode\": \"oo\"
    }
  ],
  \"id\": \"Observation-lastn\",
  \"instance\": false,
  \"jurisdiction\": [
    {
      \"coding\": [
        {
          \"code\": \"001\",
          \"display\": \"World\",
          \"system\": \"http://unstats.un.org/unsd/methods/m49/m49.htm\"
        }
      ]
    }
  ],
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2026-05-28T22:17:06.960+00:00\"
  },
  \"name\": \"Lastn\",
  \"parameter\": [
    {
      \"documentation\": \"`max` is an optional input parameter to the *lastn* query operation. It is used to specify the maximum number of Observations to return from each group. For example for the query \\\"Fetch the last 3 results for all vitals for a patient\\\" `max` = 3.\",
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
  \"publisher\": \"HL7 International / Orders and Observations\",
  \"resource\": [
    \"Observation\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"active\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p class=\\\"res-header-id\\\">\\n              <b>Generated Narrative: OperationDefinition Observation-lastn</b>\\n            </p>\\n            <a name=\\\"Observation-lastn\\\"> </a>\\n            <a name=\\\"hcObservation-lastn\\\"> </a>\\n            <p>URL: [base]/Observation/$lastn</p>\\n            <h3>Parameters</h3>\\n\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>max</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#positiveInt\\\">positiveInt</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>\\n                      <code>max</code> is an optional input parameter to the \\n                      <em>lastn</em> query operation. It is used to specify the maximum number of Observations to return from each group. For example for the query &quot;Fetch the last 3 results for all vitals for a patient&quot; \\n                      <code>max</code> = 3.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>return</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"bundle.html\\\">Bundle</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The set of most recent N Observations that match the \\n                      <em>lastn</em> query search criteria.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n\\n            <div>\\n              <p>The key differences between this query operation and simply searching Observation using the combination of \\n                <code>_count</code> and \\n                <code>_sort</code> parameters are:\\n              </p>\\n\\n              <ul>\\n\\n                <li>The \\n                  <em>lastn</em> query returns \\n                  <strong>only</strong> the last N resource grouped by code. Using the _count query method doesn't restrict the total matches so you may need to page through several &quot;A&quot; Observations before getting to Observation &quot;B&quot;.\\n                </li>\\n\\n                <li>The server is responsible for grouping the observations by codes. This frees the client from needing to determine which codes she should ask for.</li>\\n\\n              </ul>\\n\\n              <p>This operation cannot be performed on observations that the user is not authorized to see. It is assumed that the server has identified and secured the context appropriately, and can either associate the authorization context with a single patient, or determine whether the context has the rights to the nominated patient, if there is one. If there is no nominated patient (e.g. the operation is invoked at the system level) and the context is not associated with a single patient record, then the server should return an error. Specifying the relationship between the context, a user and patient records is outside the scope of this specification.</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"generated\"
  },
  \"title\": \"Last N Observations Query\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Observation-lastn\",
  \"version\": \"6.0.0-ballot4\"
}"))
(define (lastn-operation handler)
  (define code "lastn")
  (list (operation-entry 'type code "Observation" handler)))
(define lookup-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
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
    },
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://www.hl7.org/Special/committees/Vocab\"
        }
      ]
    }
  ],
  \"date\": \"2026-05-28T22:17:06+00:00\",
  \"description\": \"Given a code/system, or a Coding, get additional details about the concept, including definition, status, designations, and properties. One of the products of this operation is a full decomposition of a code from a structured terminology.\\n\\nWhen invoking this operation, a client SHALL provide both a system and a code, either using the system+code parameters, or in the coding parameter. Other parameters are optional\",
  \"experimental\": false,
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
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-wg\",
      \"valueCode\": \"vocab\"
    }
  ],
  \"id\": \"CodeSystem-lookup\",
  \"instance\": true,
  \"jurisdiction\": [
    {
      \"coding\": [
        {
          \"code\": \"001\",
          \"display\": \"World\",
          \"system\": \"http://unstats.un.org/unsd/methods/m49/m49.htm\"
        }
      ]
    }
  ],
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2026-05-28T22:17:06.960+00:00\"
  },
  \"name\": \"Lookup\",
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
      \"scope\": [
        \"type\"
      ],
      \"type\": \"uri\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The version of the system, if one was provided in the source data\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"version\",
      \"scope\": [
        \"type\"
      ],
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
      \"documentation\": \"The requested language for display (see CodeSystem.concept.designation.language)\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"displayLanguage\",
      \"type\": \"code\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"A property that the client wishes to be returned in the output. If no properties are specified, the server chooses what to return. The following properties are defined for all code systems: name, version (code system info) and code information: display, designation, and lang.X where X is a designation language code. These properties are returned explicitly in named out parameters with matching names, or in designations. In addition, any property codes defined by [this specification](codesystem.html#defined-props) or by the CodeSystem ([CodeSystem.property.code](codesystem-definitions.html#CodeSystem.property)) are allowed, and these are returned in the out parameter ```property```\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"property\",
      \"type\": \"code\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Supplements to take into account when performing the $lookup operation. The supplements must be for the same CodeSystem. By default, supplements for the code system are not automatically included except where they provide additional designations that may be indicated by, for example, the displayLanguage parameter\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"useSupplement\",
      \"type\": \"canonical\",
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
      \"documentation\": \"A statement of the meaning of the concept from the code system\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"definition\",
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
          \"documentation\": \"Additional codes that detail how this designation would be used (if there is more than one)\",
          \"max\": \"*\",
          \"min\": 0,
          \"name\": \"additionalUse\",
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
          \"documentation\": \"If information from a supplement is included as a property (e.g. any additional property or property value), then this parameter must assert the url of the supplement.\",
          \"max\": \"1\",
          \"min\": 0,
          \"name\": \"source\",
          \"type\": \"canonical\",
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
              \"max\": \"1\",
              \"min\": 1,
              \"name\": \"value\",
              \"type\": \"Element\",
              \"use\": \"out\"
            },
            {
              \"documentation\": \"Human Readable representation of the sub-property value (e.g. display for a code)\",
              \"max\": \"1\",
              \"min\": 0,
              \"name\": \"description\",
              \"type\": \"string\",
              \"use\": \"out\"
            },
            {
              \"documentation\": \"If information from a supplement is included as a subproperty (e.g. any additional subproperty or subproperty value), then this parameter must assert the url of the supplement.\",
              \"max\": \"1\",
              \"min\": 0,
              \"name\": \"source\",
              \"type\": \"canonical\",
              \"use\": \"out\"
            }
          ],
          \"use\": \"out\"
        }
      ],
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 International / Terminology Infrastructure\",
  \"resource\": [
    \"CodeSystem\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"active\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p class=\\\"res-header-id\\\">\\n              <b>Generated Narrative: OperationDefinition CodeSystem-lookup</b>\\n            </p>\\n            <a name=\\\"CodeSystem-lookup\\\"> </a>\\n            <a name=\\\"hcCodeSystem-lookup\\\"> </a>\\n            <p>URL: [base]/CodeSystem/$lookup</p>\\n            <p>URL: [base]/CodeSystem/[id]/$lookup</p>\\n            <h3>Parameters</h3>\\n\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>code</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The code that is to be located. If a code is provided, a system must be provided</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>system</td>\\n\\n                <td>type</td>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The system for the code that is to be located</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>version</td>\\n\\n                <td>type</td>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The version of the system, if one was provided in the source data</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>coding</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#Coding\\\">Coding</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>A coding to look up</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>date</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#dateTime\\\">dateTime</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The date for which the information should be returned. Normally, this is the current conditions (which is the default value) but under some circumstances, systems need to acccess this information as it would have been in the past. A typical example of this would be where code selection is constrained to the set of codes that were available when the patient was treated, not when the record is being edited. Note that which date is appropriate is a matter for implementation policy.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>displayLanguage</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The requested language for display (see CodeSystem.concept.designation.language)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>property</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>A property that the client wishes to be returned in the output. If no properties are specified, the server chooses what to return. The following properties are defined for all code systems: name, version (code system info) and code information: display, designation, and lang.X where X is a designation language code. These properties are returned explicitly in named out parameters with matching names, or in designations. In addition, any property codes defined by \\n                      <a href=\\\"codesystem.html#defined-props\\\">this specification</a> or by the CodeSystem (\\n                      <a href=\\\"codesystem-definitions.html#CodeSystem.property\\\">CodeSystem.property.code</a>) are allowed, and these are returned in the out parameter \\n                      <code>property</code>\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>useSupplement</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Supplements to take into account when performing the $lookup operation. The supplements must be for the same CodeSystem. By default, supplements for the code system are not automatically included except where they provide additional designations that may be indicated by, for example, the displayLanguage parameter</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>name</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>A display name for the code system</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>version</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The version that these details are based on</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>display</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The preferred display for this concept</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>definition</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>A statement of the meaning of the concept from the code system</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>designation</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td/>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Additional representations for this concept</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>designation.language</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The language this designation is defined for</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>designation.use</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#Coding\\\">Coding</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>A code that details how this designation would be used</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>designation.additionalUse</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#Coding\\\">Coding</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Additional codes that detail how this designation would be used (if there is more than one)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>designation.value</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The text value for this designation</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>property</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td/>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>One or more properties that contain additional information about the code, including status. For complex terminologies (e.g. SNOMED CT, LOINC, medications), these properties serve to decompose the code</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>property.code</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Identifies the property returned</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>property.value</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"types.html#Element\\\">Element</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The value of the property returned</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>property.description</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Human Readable representation of the property value (e.g. display for a code)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>property.source</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>If information from a supplement is included as a property (e.g. any additional property or property value), then this parameter must assert the url of the supplement.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>property.subproperty</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td/>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Nested Properties (mainly used for SNOMED CT decomposition, for relationship Groups)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>property.subproperty.code</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Identifies the sub-property returned</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>property.subproperty.value</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"types.html#Element\\\">Element</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The value of the sub-property returned</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>property.subproperty.description</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Human Readable representation of the sub-property value (e.g. display for a code)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>property.subproperty.source</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>If information from a supplement is included as a subproperty (e.g. any additional subproperty or subproperty value), then this parameter must assert the url of the supplement.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n\\n            <div>\\n              <p>Note that the $lookup operation is more than just a code system search  - the server finds the concept, and gathers the return information from the underlying code system definitions.</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"generated\"
  },
  \"title\": \"Concept Look Up & Decomposition\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/CodeSystem-lookup\",
  \"version\": \"6.0.0-ballot4\"
}"))
(define (lookup-operation handler)
  (define code "lookup")
  (list (operation-entry 'type code "CodeSystem" handler)
        (operation-entry 'instance code "CodeSystem" handler)))
(define match-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
  \"code\": \"match\",
  \"comment\": \"The response from an \\\"mpi\\\" query is a bundle containing patient records, ordered from most likely to least likely. If there are no patient matches, the MPI SHALL return an empty search set with no error, but may include an operation outcome with further advice regarding patient selection. All patient records SHALL have a search score from 0 to 1, where 1 is the most certain match, along with an extension \\\"[http://hl7.org/fhir/StructureDefinition/match-grade](https://build.fhir.org/ig/HL7/fhir-extensions/StructureDefinition-match-grade.html)\\\" that indicates the MPI's position on the match quality.\",
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
    },
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://www.hl7.org/Special/committees/pafm\"
        }
      ]
    }
  ],
  \"date\": \"2026-05-28T22:17:06+00:00\",
  \"description\": \"A Master Patient Index ([MPI](http://en.wikipedia.org/wiki/Enterprise_master_patient_index) ) is a service used to manage patient identification in a context where multiple patient databases exist. Healthcare applications and middleware use the MPI to match patients between the databases, and to store new patient details as they are encountered. MPIs are highly specialized applications, often tailored extensively to the institution's particular mix of patients. MPIs can also be run on a regional and national basis.  \\n\\nTo ask an MPI to match a patient, clients use the \\\"$match\\\" operation, which accepts a patient resource which may be only partially complete. The data provided is interpreted as an MPI input and processed by an algorithm of some kind that uses the data to determine the most appropriate matches in the patient set.  Note that different MPI matching algorithms have different required inputs. Consult with the vendor implementing the $match operation as to its specific behaviors.\\r\\r  The generic $match operation does not specify any particular algorithm, nor a minimum set of information that must be provided when asking for an MPI match operation to be performed, but many implementations will have a set of minimum information, which may be declared in their definition of the $match operation by specifying a profile on the resource parameter, indicating which properties are required in the search.\\r\\rThe patient resource submitted to the operation does not have to be complete, nor does it need to pass validation (i.e. mandatory fields don't need to be populated), but it does have to be a valid instance, as it is used as the reference data to match against.\\r\\r  Implementers of the $match algorithm should consider the relevance of returning inactive patients, particularly ones associated with patient merges.\\r\\rE.g. If an inactive patient is \\\"matched\\\" and its merged target resource will be included, then the inactive one may be excluded, however if a patient was just marked as inactive for other reasons, it could be included in the results.\\r\\r(any specific MPI algorithm may or might not behave as in these examples)\",
  \"experimental\": false,
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
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-wg\",
      \"valueCode\": \"pa\"
    }
  ],
  \"id\": \"Patient-match\",
  \"instance\": false,
  \"jurisdiction\": [
    {
      \"coding\": [
        {
          \"code\": \"001\",
          \"display\": \"World\",
          \"system\": \"http://unstats.un.org/unsd/methods/m49/m49.htm\"
        }
      ]
    }
  ],
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2026-05-28T22:17:06.960+00:00\"
  },
  \"name\": \"Match\",
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
      \"documentation\": \"If there are multiple potential matches, the server should identify the single most appropriate match that should be used with future interactions with the server (for example, as part of a subsequent create interaction).\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"onlySingleMatch\",
      \"type\": \"boolean\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"If there are multiple potential matches, the server should be certain that each of the records are for the same patients.  This could happen if the records are duplicates, are the same person for the purpose of data segregation, or other reasons.  When false, the server may return multiple results with each result graded accordingly.\",
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
      \"documentation\": \"The bundle type is \\\"searchset\\\"\\r\\rA bundle contain a set of Patient records that represent possible matches, optionally it may also contain an OperationOutcome with further information about the search results (such as warnings or information messages, such as a count of records that were close but eliminated)  If the operation was unsuccessful, then an OperationOutcome may be returned along with a BadRequest status Code (e.g. security issue, or insufficient properties in patient fragment - check against profile)\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"return\",
      \"type\": \"Bundle\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 International / Patient Administration\",
  \"resource\": [
    \"Patient\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"active\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p class=\\\"res-header-id\\\">\\n              <b>Generated Narrative: OperationDefinition Patient-match</b>\\n            </p>\\n            <a name=\\\"Patient-match\\\"> </a>\\n            <a name=\\\"hcPatient-match\\\"> </a>\\n            <p>URL: [base]/Patient/$match</p>\\n            <h3>Parameters</h3>\\n\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>resource</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"resource.html\\\">Resource</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Use this to provide an entire set of patient details for the MPI to match against (e.g. POST a patient record to Patient/$match).</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>onlySingleMatch</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>If there are multiple potential matches, the server should identify the single most appropriate match that should be used with future interactions with the server (for example, as part of a subsequent create interaction).</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>onlyCertainMatches</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>If there are multiple potential matches, the server should be certain that each of the records are for the same patients.  This could happen if the records are duplicates, are the same person for the purpose of data segregation, or other reasons.  When false, the server may return multiple results with each result graded accordingly.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>count</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#integer\\\">integer</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The maximum number of records to return. If no value is provided, the server decides how many matches to return. Note that clients should be careful when using this, as it may prevent probable - and valid - matches from being returned</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>return</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"bundle.html\\\">Bundle</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The bundle type is &quot;searchset&quot;</p>\\n\\n                    <p>A bundle contain a set of Patient records that represent possible matches, optionally it may also contain an OperationOutcome with further information about the search results (such as warnings or information messages, such as a count of records that were close but eliminated)  If the operation was unsuccessful, then an OperationOutcome may be returned along with a BadRequest status Code (e.g. security issue, or insufficient properties in patient fragment - check against profile)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n\\n            <div>\\n              <p>The response from an &quot;mpi&quot; query is a bundle containing patient records, ordered from most likely to least likely. If there are no patient matches, the MPI SHALL return an empty search set with no error, but may include an operation outcome with further advice regarding patient selection. All patient records SHALL have a search score from 0 to 1, where 1 is the most certain match, along with an extension &quot;\\n                <a href=\\\"https://build.fhir.org/ig/HL7/fhir-extensions/StructureDefinition-match-grade.html\\\">http://hl7.org/fhir/StructureDefinition/match-grade</a>&quot; that indicates the MPI's position on the match quality.\\n              </p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"generated\"
  },
  \"title\": \"Find patient matches using MPI based logic\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Patient-match\",
  \"version\": \"6.0.0-ballot4\"
}"))
(define (match-operation handler)
  (define code "match")
  (list (operation-entry 'type code "Patient" handler)))
(define populate-definition
  (string->jsexpr
   "{
  \"base\": \"http://hl7.org/fhir/OperationDefinition/Questionnaire-populate\",
  \"code\": \"populate\",
  \"comment\": \"Only implemented for Labs and Medications so far\",
  \"contact\": [
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://www.hl7.org/Special/committees/fiwg\"
        }
      ]
    }
  ],
  \"date\": \"2015-08-04\",
  \"description\": \"Limited implementation of the Populate Questionnaire implementation\",
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-wg\",
      \"valueCode\": \"fhir\"
    }
  ],
  \"id\": \"example\",
  \"instance\": true,
  \"jurisdiction\": [
    {
      \"coding\": [
        {
          \"code\": \"GB\",
          \"display\": \"United Kingdom of Great Britain and Northern Ireland\",
          \"system\": \"urn:iso:std:iso:3166\"
        }
      ]
    }
  ],
  \"kind\": \"operation\",
  \"name\": \"PopulateQuestionnaire\",
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
  \"publisher\": \"HL7 International / FHIR Infrastructure\",
  \"resource\": [
    \"Questionnaire\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"title\": \"Populate Questionnaire\",
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/example\",
  \"useContext\": [
    {
      \"code\": {
        \"code\": \"venue\",
        \"display\": \"Clinical Venue\",
        \"system\": \"http://terminology.hl7.org/CodeSystem/usage-context-type\"
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
  \"affectsState\": false,
  \"code\": \"preferred-id\",
  \"comment\": \"Servers handle this request by finding the provided identifier in their known naming systems, and returning the requested identifier type ([NamingSystem.uniqueId.type](namingsystem-definitions.html#NamingSystem.uniqueId.type)). If there is more than one identifier of the specified type (for the specified date), then the 'preferred' identifier will be returned.  If there is only one identifier, that identifier will be returned even if it is not preferred.  If there are multiple preferred identifiers or multiple identifiers with none marked as preferred, the system MAY return an error or may list all identifiers applicable for that date and period.  \\n\\nIf the server wishes, it can also look through all code systems and value sets it knows about when attempting to find the requested identifier.\",
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
    },
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://www.hl7.org/Special/committees/Vocab\"
        }
      ]
    }
  ],
  \"date\": \"2026-05-28T22:17:06+00:00\",
  \"description\": \"This operation returns the preferred identifiers for identifiers, and terminologies. The operation takes 2 parameters:     \\n\\n* a system identifier - either a URI, an OID, or a v2 table 0396 (other) code  \\n* a code for what kind of identifier is desired (URI, OID, v2 table 0396 identifier)    \\n\\nand returns either the requested identifier, or an HTTP errors response with an OperationOutcome because either the provided identifier was not recognized, or the requested identiifer type is not known.    \\n\\nThe principle use of this operation is when converting between v2, CDA and FHIR Identifier/CX/II and CodeableConcepts/C(N/W)E/CD but the operation may also find use when converting metadata such as profiles.\",
  \"experimental\": false,
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 1
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"normative\"
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-wg\",
      \"valueCode\": \"vocab\"
    }
  ],
  \"id\": \"NamingSystem-preferred-id\",
  \"instance\": false,
  \"jurisdiction\": [
    {
      \"coding\": [
        {
          \"code\": \"001\",
          \"display\": \"World\",
          \"system\": \"http://unstats.un.org/unsd/methods/m49/m49.htm\"
        }
      ]
    }
  ],
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2026-05-28T22:17:06.960+00:00\"
  },
  \"name\": \"PreferredId\",
  \"parameter\": [
    {
      \"documentation\": \"The server parses the provided identifier to see what type it is (e.g. a URI, an OID as a URI, a plain OID, or a v2 table 0396 code). If the server can't tell what type of identifier it is, it can try it as multiple types. It is an error if more than one system matches the provided identifier\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"id\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"binding\": {
        \"extension\": [
          {
            \"url\": \"http://hl7.org/fhir/StructureDefinition/elementdefinition-bindingName\",
            \"valueString\": \"NamingSystemIdentifierType\"
          }
        ],
        \"strength\": \"required\",
        \"valueSet\": \"http://hl7.org/fhir/ValueSet/namingsystem-identifier-type|6.0.0-ballot4\"
      },
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"type\",
      \"type\": \"code\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"If specified, the operation will indicate what the preferred identifier was on the specified date.  If not specified, the operation will provide the preferred identifier as of 'now'\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"date\",
      \"type\": \"dateTime\",
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
  \"publisher\": \"HL7 International / Terminology Infrastructure\",
  \"resource\": [
    \"NamingSystem\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"active\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p class=\\\"res-header-id\\\">\\n              <b>Generated Narrative: OperationDefinition NamingSystem-preferred-id</b>\\n            </p>\\n            <a name=\\\"NamingSystem-preferred-id\\\"> </a>\\n            <a name=\\\"hcNamingSystem-preferred-id\\\"> </a>\\n            <p>URL: [base]/NamingSystem/$preferred-id</p>\\n            <h3>Parameters</h3>\\n\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>id</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The server parses the provided identifier to see what type it is (e.g. a URI, an OID as a URI, a plain OID, or a v2 table 0396 code). If the server can't tell what type of identifier it is, it can try it as multiple types. It is an error if more than one system matches the provided identifier</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>type</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n\\n                <td>\\n                  <a href=\\\"valueset-namingsystem-identifier-type.html\\\">Naming System Identifier Type</a> (Required)\\n                </td>\\n\\n                <td/>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>date</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#dateTime\\\">dateTime</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>If specified, the operation will indicate what the preferred identifier was on the specified date.  If not specified, the operation will provide the preferred identifier as of 'now'</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>result</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>OIDs are return as plain OIDs (not the URI form).</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n\\n            <div>\\n              <p>Servers handle this request by finding the provided identifier in their known naming systems, and returning the requested identifier type (\\n                <a href=\\\"namingsystem-definitions.html#NamingSystem.uniqueId.type\\\">NamingSystem.uniqueId.type</a>). If there is more than one identifier of the specified type (for the specified date), then the 'preferred' identifier will be returned.  If there is only one identifier, that identifier will be returned even if it is not preferred.  If there are multiple preferred identifiers or multiple identifiers with none marked as preferred, the system MAY return an error or may list all identifiers applicable for that date and period.\\n              </p>\\n\\n              <p>If the server wishes, it can also look through all code systems and value sets it knows about when attempting to find the requested identifier.</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"generated\"
  },
  \"title\": \"Fetch Preferred id\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/NamingSystem-preferred-id\",
  \"version\": \"6.0.0-ballot4\"
}"))
(define (preferred-id-operation handler)
  (define code "preferred-id")
  (list (operation-entry 'type code "NamingSystem" handler)))
(define process-message-definition
  (string->jsexpr
   "{
  \"affectsState\": true,
  \"code\": \"process-message\",
  \"comment\": \"This operation does not use the parameters resource; the parameters \\\"async\\\" and \\\"response-url\\\" always go in the URL, if they are used, and the \\\"content\\\" parameter is always the body of the HTTP message.\\n\\nWhen processing messages, a server may return one of several status codes:\\n* **200 OK**: Indicates that the message has been fully processed.  If an application-level response is expected for the submitted message, that response SHALL be returned as the body of the 200 response.\\n* **202 Accepted**: Indicates that the receiving system has accepted custody of the message\\n* **204 No Content**: Indicates that the message has been fully processed and would normally have had an application-level response, but because of instructions from the sender (e.g. the [http://hl7.org/fhir/StructureDefinition/messageheader-response-request](https://build.fhir.org/ig/HL7/fhir-extensions/StructureDefinition-messageheader-response-request.html) extension), no response is being provided\\n* **300+**: Indicates that the message was not successfully processed.  The server MAY return an [OperationOutcome](operationoutcome.html) with additional information, and SHOULD do so if the response code is 400 or greater. The client SHALL interpret a 4xx response to indicate that there is no point resubmitting the unaltered message, and a 5xx response to indicate an unexpected error occurred on the part of the server, with the implication that it may be appropriate to resubmit the original message. Doing so SHOULD NOT result in a duplicate message response. Repeated failures indicate either a fatal problem with the submission or a problem with the receiving application.\\n\\nThe following rules apply when using $process-message:\\n\\n* The operation only accepts POST transactions - any other HTTP method will result in an HTTP error\\n* The request content type submitted is always [Bundle](bundle.html) with type \\\"message\\\" containing a [Message Header](messageheader.html) resource as the first resource\\n* The response content type returned, if not empty, is always [Bundle](bundle.html) with type \\\"message\\\" containing a [Message Header](messageheader.html) resource as the first resource, or an HTTP error\\n* If the response is an error, the body SHOULD be an [OperationOutcome](operationoutcome.html) resource with full details of the Errors &mp; Warning\\n* The mailbox may be authenticated using standard HTTP authentication methods, including OAuth\\n\\nThe $process-message operation can be used by any HTTP end-point that accepts FHIR messages, not just FHIR RESTful servers.\\n\\nIn order to ensure consistency of processing, the [logical rules regarding processing of Bundle.id and message id](messaging.html#reliable) SHALL be followed when messages are processed using this operation.\\n\\nThe $process-message operation may be used synchronously, or asynchronously.\\n\\nThe following rules apply when using the $process-message operation synchronously:\\n\\n* The URL (http://server/base/$process-message) has no parameters\\n* It is an error if the sender POSTs a message that requires multiple response messages\\n* Servers SHALL accept multiple concurrent message submissions and process them correctly (they are allowed to process them sequentially internally, but multiple concurrent submissions is not an error in its own right)\\n\\nThe following rules apply when using the $process-message operation asynchronously:\\n\\n* The URL has at least one parameter: http://server/base/$process-message?async=true\\n* The server acknowledges the message with a 200 OK with no body, or returns an HTTP error if the message cannot be processed\\n* Accepting the message means that the server has understood the message enough to know where to respond\\n* An [OperationOutcome](operationoutcome.html) SHOULD be returned in either case\\n* By default, the server responds by invoking the $process-message using the sender's stated end-point in the message: POST [MessageHeader.source.endpoint]/$process-message]\\n* Since the source end-point may be manipulated by message transfer engines, an alternative response address may be specified using the parameter \\\"response-url\\\": http://server/base/$process-message?async=true&amp;response-url=http://server2.com/base/anything.  The endpoint at the specified URL SHALL implement the signature of the $process-message operation (parameter async=true, accept a Bundle, return a 200 OK or an error)\\n* The server submits response messages to the appropriate end-point with the parameter async=true. There is no response message for the response messages\",
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
    },
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://www.hl7.org/Special/committees/inm\"
        }
      ]
    }
  ],
  \"date\": \"2026-05-28T22:17:06+00:00\",
  \"description\": \"This operation accepts a message, processes it according to the definition of the event in the message header, and returns one or more response messages.  \\n\\nIn addition to processing the message event, a server may choose to retain all or some the resources and make them available on a RESTful interface, but is not required to do so.\",
  \"experimental\": false,
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 4
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"normative\"
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-wg\",
      \"valueCode\": \"inm\"
    }
  ],
  \"id\": \"MessageHeader-process-message\",
  \"instance\": false,
  \"jurisdiction\": [
    {
      \"coding\": [
        {
          \"code\": \"001\",
          \"display\": \"World\",
          \"system\": \"http://unstats.un.org/unsd/methods/m49/m49.htm\"
        }
      ]
    }
  ],
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2026-05-28T22:17:06.960+00:00\"
  },
  \"name\": \"ProcessMessage\",
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
  \"publisher\": \"HL7 International / Infrastructure And Messaging\",
  \"resource\": [
    \"MessageHeader\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"active\",
  \"system\": true,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p class=\\\"res-header-id\\\">\\n              <b>Generated Narrative: OperationDefinition MessageHeader-process-message</b>\\n            </p>\\n            <a name=\\\"MessageHeader-process-message\\\"> </a>\\n            <a name=\\\"hcMessageHeader-process-message\\\"> </a>\\n            <p>URL: [base]/$process-message</p>\\n            <h3>Parameters</h3>\\n\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>content</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"bundle.html\\\">Bundle</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The message to process (or, if using asynchronous messaging, it may be a response message to accept)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>async</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>If 'true' the message is processed using the asynchronous messaging pattern</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>response-url</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#url\\\">url</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>A URL to submit response messages to, if asynchronous messaging is being used, and if the MessageHeader.source.endpoint is not the appropriate place to submit responses</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>return</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"bundle.html\\\">Bundle</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>A response message, if synchronous messaging is being used (mandatory in this case). For asynchronous messaging, there is no return value</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n\\n            <div>\\n              <p>This operation does not use the parameters resource; the parameters &quot;async&quot; and &quot;response-url&quot; always go in the URL, if they are used, and the &quot;content&quot; parameter is always the body of the HTTP message.</p>\\n\\n              <p>When processing messages, a server may return one of several status codes:</p>\\n\\n              <ul>\\n\\n                <li>\\n                  <strong>200 OK</strong>: Indicates that the message has been fully processed.  If an application-level response is expected for the submitted message, that response SHALL be returned as the body of the 200 response.\\n                </li>\\n\\n                <li>\\n                  <strong>202 Accepted</strong>: Indicates that the receiving system has accepted custody of the message\\n                </li>\\n\\n                <li>\\n                  <strong>204 No Content</strong>: Indicates that the message has been fully processed and would normally have had an application-level response, but because of instructions from the sender (e.g. the \\n                  <a href=\\\"https://build.fhir.org/ig/HL7/fhir-extensions/StructureDefinition-messageheader-response-request.html\\\">http://hl7.org/fhir/StructureDefinition/messageheader-response-request</a> extension), no response is being provided\\n                </li>\\n\\n                <li>\\n                  <strong>300+</strong>: Indicates that the message was not successfully processed.  The server MAY return an \\n                  <a href=\\\"operationoutcome.html\\\">OperationOutcome</a> with additional information, and SHOULD do so if the response code is 400 or greater. The client SHALL interpret a 4xx response to indicate that there is no point resubmitting the unaltered message, and a 5xx response to indicate an unexpected error occurred on the part of the server, with the implication that it may be appropriate to resubmit the original message. Doing so SHOULD NOT result in a duplicate message response. Repeated failures indicate either a fatal problem with the submission or a problem with the receiving application.\\n                </li>\\n\\n              </ul>\\n\\n              <p>The following rules apply when using $process-message:</p>\\n\\n              <ul>\\n\\n                <li>The operation only accepts POST transactions - any other HTTP method will result in an HTTP error</li>\\n\\n                <li>The request content type submitted is always \\n                  <a href=\\\"bundle.html\\\">Bundle</a> with type &quot;message&quot; containing a \\n                  <a href=\\\"messageheader.html\\\">Message Header</a> resource as the first resource\\n                </li>\\n\\n                <li>The response content type returned, if not empty, is always \\n                  <a href=\\\"bundle.html\\\">Bundle</a> with type &quot;message&quot; containing a \\n                  <a href=\\\"messageheader.html\\\">Message Header</a> resource as the first resource, or an HTTP error\\n                </li>\\n\\n                <li>If the response is an error, the body SHOULD be an \\n                  <a href=\\\"operationoutcome.html\\\">OperationOutcome</a> resource with full details of the Errors ∓ Warning\\n                </li>\\n\\n                <li>The mailbox may be authenticated using standard HTTP authentication methods, including OAuth</li>\\n\\n              </ul>\\n\\n              <p>The $process-message operation can be used by any HTTP end-point that accepts FHIR messages, not just FHIR RESTful servers.</p>\\n\\n              <p>In order to ensure consistency of processing, the \\n                <a href=\\\"messaging.html#reliable\\\">logical rules regarding processing of Bundle.id and message id</a> SHALL be followed when messages are processed using this operation.\\n              </p>\\n\\n              <p>The $process-message operation may be used synchronously, or asynchronously.</p>\\n\\n              <p>The following rules apply when using the $process-message operation synchronously:</p>\\n\\n              <ul>\\n\\n                <li>The URL (http://server/base/$process-message) has no parameters</li>\\n\\n                <li>It is an error if the sender POSTs a message that requires multiple response messages</li>\\n\\n                <li>Servers SHALL accept multiple concurrent message submissions and process them correctly (they are allowed to process them sequentially internally, but multiple concurrent submissions is not an error in its own right)</li>\\n\\n              </ul>\\n\\n              <p>The following rules apply when using the $process-message operation asynchronously:</p>\\n\\n              <ul>\\n\\n                <li>The URL has at least one parameter: http://server/base/$process-message?async=true</li>\\n\\n                <li>The server acknowledges the message with a 200 OK with no body, or returns an HTTP error if the message cannot be processed</li>\\n\\n                <li>Accepting the message means that the server has understood the message enough to know where to respond</li>\\n\\n                <li>An \\n                  <a href=\\\"operationoutcome.html\\\">OperationOutcome</a> SHOULD be returned in either case\\n                </li>\\n\\n                <li>By default, the server responds by invoking the $process-message using the sender's stated end-point in the message: POST [MessageHeader.source.endpoint]/$process-message]</li>\\n\\n                <li>Since the source end-point may be manipulated by message transfer engines, an alternative response address may be specified using the parameter &quot;response-url&quot;: http://server/base/$process-message?async=true&amp;response-url=http://server2.com/base/anything.  The endpoint at the specified URL SHALL implement the signature of the $process-message operation (parameter async=true, accept a Bundle, return a 200 OK or an error)</li>\\n\\n                <li>The server submits response messages to the appropriate end-point with the parameter async=true. There is no response message for the response messages</li>\\n\\n              </ul>\\n\\n            </div>\\n          </div>\",
    \"status\": \"generated\"
  },
  \"title\": \"Process Message\",
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/MessageHeader-process-message\",
  \"version\": \"6.0.0-ballot4\"
}"))
(define (process-message-operation handler)
  (define code "process-message")
  (list (operation-entry 'system code #f handler)))
(define Group-purge-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
  \"code\": \"purge\",
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
    },
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://www.hl7.org/Special/committees/fiwg\"
        }
      ]
    }
  ],
  \"date\": \"2026-05-28T22:17:06+00:00\",
  \"description\": \"This operation is used to request the removal of all current and historical versions for all resources in a Group of patient compartments.  The result will be an OperationOutcome with results and/or details about execution.\\n\\nFollowing are some common `issue-type` values:\\n- `success` the request has been completed to the server's satisfaction - the patient and associated resources are no longer accessible\\n- `incomplete` the request is partially complete, but additional processing will continue (e.g., the server is continuing to clean out resources)\\n\\nWhen supported, it is recommended (though not required) to support an [Asynchronous Request Pattern](async.html).\\n\\nNote that the deletion of resources typically involves many policy decisions.  Implementers are expected to use this operation in conjunction with their policies for such a request - e.g., soft vs. hard delete, audibility/traceability, evaluation of referential integrity, etc.\",
  \"experimental\": false,
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 2
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"normative\"
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-wg\",
      \"valueCode\": \"fhir\"
    }
  ],
  \"id\": \"Group-purge\",
  \"instance\": true,
  \"jurisdiction\": [
    {
      \"coding\": [
        {
          \"code\": \"001\",
          \"display\": \"World\",
          \"system\": \"http://unstats.un.org/unsd/methods/m49/m49.htm\"
        }
      ]
    }
  ],
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2026-05-28T22:17:06.960+00:00\"
  },
  \"name\": \"Purge\",
  \"parameter\": [
    {
      \"documentation\": \"Status and/or results of the purge request\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"return\",
      \"type\": \"OperationOutcome\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 International / FHIR Infrastructure\",
  \"resource\": [
    \"Group\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"active\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p class=\\\"res-header-id\\\">\\n              <b>Generated Narrative: OperationDefinition Group-purge</b>\\n            </p>\\n            <a name=\\\"Group-purge\\\"> </a>\\n            <a name=\\\"hcGroup-purge\\\"> </a>\\n            <p>URL: [base]/Group/[id]/$purge</p>\\n            <h3>Parameters</h3>\\n\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>return</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"operationoutcome.html\\\">OperationOutcome</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Status and/or results of the purge request</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n          </div>\",
    \"status\": \"generated\"
  },
  \"title\": \"Purge Group Record\",
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Group-purge\",
  \"version\": \"6.0.0-ballot4\"
}"))
(define (Group-purge-operation handler)
  (define code "purge")
  (list (operation-entry 'instance code "Group" handler)))
(define Patient-purge-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
  \"code\": \"purge\",
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
    },
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://www.hl7.org/Special/committees/pafm\"
        }
      ]
    }
  ],
  \"date\": \"2026-05-28T22:17:06+00:00\",
  \"description\": \"This operation is used to request the removal of all current and historical versions for all resources in a patient compartment.  The result will be an OperationOutcome with results and/or details about execution.\\n\\nFollowing are some common `issue-type` values:\\n- `success` the request has been completed to the server's satisfaction - the patient and associated resources are no longer accessible\\n- `incomplete` the request is partially complete, but additional processing will continue (e.g., the server is continuing to clean out resources)\\n\\nWhen supported, it is recommended (though not required) to support an [Asynchronous Request Pattern](async.html).\\n\\nNote that the deletion of resources typically involves many policy decisions.  Implementers are expected to use this operation in conjunction with their policies for such a request - e.g., soft vs. hard delete, audibility/traceability, evaluation of referential integrity, etc.\",
  \"experimental\": false,
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 2
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"normative\"
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-wg\",
      \"valueCode\": \"pa\"
    }
  ],
  \"id\": \"Patient-purge\",
  \"instance\": true,
  \"jurisdiction\": [
    {
      \"coding\": [
        {
          \"code\": \"001\",
          \"display\": \"World\",
          \"system\": \"http://unstats.un.org/unsd/methods/m49/m49.htm\"
        }
      ]
    }
  ],
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2026-05-28T22:17:06.960+00:00\"
  },
  \"name\": \"Purge\",
  \"parameter\": [
    {
      \"documentation\": \"Status and/or results of the purge request\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"return\",
      \"type\": \"OperationOutcome\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 International / Patient Administration\",
  \"resource\": [
    \"Patient\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"active\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p class=\\\"res-header-id\\\">\\n              <b>Generated Narrative: OperationDefinition Patient-purge</b>\\n            </p>\\n            <a name=\\\"Patient-purge\\\"> </a>\\n            <a name=\\\"hcPatient-purge\\\"> </a>\\n            <p>URL: [base]/Patient/[id]/$purge</p>\\n            <h3>Parameters</h3>\\n\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>return</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"operationoutcome.html\\\">OperationOutcome</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Status and/or results of the purge request</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n          </div>\",
    \"status\": \"generated\"
  },
  \"title\": \"Purge Patient Record\",
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Patient-purge\",
  \"version\": \"6.0.0-ballot4\"
}"))
(define (Patient-purge-operation handler)
  (define code "purge")
  (list (operation-entry 'instance code "Patient" handler)))
(define snapshot-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
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
    },
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://www.hl7.org/Special/committees/fiwg\"
        }
      ]
    }
  ],
  \"date\": \"2026-05-28T22:17:06+00:00\",
  \"description\": \"Generates a [StructureDefinition](structuredefinition.html) instance  with  a snapshot, based on a differential in a specified [StructureDefinition](structuredefinition.html).   \\n\\nIf the operation is not called at the instance level, either *definition* or *url* 'in' parameters must be provided. If more than one is specified, servers may raise an error or may resolve with the parameter of their choice. If called at the instance level, these parameters will be ignored. Snapshot generation is dependent on profiles that are referenced - if those profiles change, the snapshot can change. For a frozen package, $snapshot is idempotent.\",
  \"experimental\": false,
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
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-wg\",
      \"valueCode\": \"fhir\"
    }
  ],
  \"id\": \"StructureDefinition-snapshot\",
  \"instance\": true,
  \"jurisdiction\": [
    {
      \"coding\": [
        {
          \"code\": \"001\",
          \"display\": \"World\",
          \"system\": \"http://unstats.un.org/unsd/methods/m49/m49.htm\"
        }
      ]
    }
  ],
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2026-05-28T22:17:06.960+00:00\"
  },
  \"name\": \"Snapshot\",
  \"parameter\": [
    {
      \"documentation\": \"The [StructureDefinition](structuredefinition.html) is provided directly as part of the request. Servers may choose not to accept profiles in this fashion\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"definition\",
      \"scope\": [
        \"type\"
      ],
      \"type\": \"StructureDefinition\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The StructureDefinition's canonical URL (i.e. 'StructureDefinition.url'). The server must know the structure definition, or be able to retrieve it from other known repositories.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"url\",
      \"scope\": [
        \"type\"
      ],
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
  \"publisher\": \"HL7 International / FHIR Infrastructure\",
  \"resource\": [
    \"StructureDefinition\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"active\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p class=\\\"res-header-id\\\">\\n              <b>Generated Narrative: OperationDefinition StructureDefinition-snapshot</b>\\n            </p>\\n            <a name=\\\"StructureDefinition-snapshot\\\"> </a>\\n            <a name=\\\"hcStructureDefinition-snapshot\\\"> </a>\\n            <p>URL: [base]/StructureDefinition/$snapshot</p>\\n            <p>URL: [base]/StructureDefinition/[id]/$snapshot</p>\\n            <h3>Parameters</h3>\\n\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>definition</td>\\n\\n                <td>type</td>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"structuredefinition.html\\\">StructureDefinition</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The \\n                      <a href=\\\"structuredefinition.html\\\">StructureDefinition</a> is provided directly as part of the request. Servers may choose not to accept profiles in this fashion\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>url</td>\\n\\n                <td>type</td>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                  <br/>(\\n                  <a href=\\\"search.html#token\\\">token</a>)\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The StructureDefinition's canonical URL (i.e. 'StructureDefinition.url'). The server must know the structure definition, or be able to retrieve it from other known repositories.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>return</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"structuredefinition.html\\\">StructureDefinition</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The structure definition with a snapshot</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n          </div>\",
    \"status\": \"generated\"
  },
  \"title\": \"Generate Snapshot\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/StructureDefinition-snapshot\",
  \"version\": \"6.0.0-ballot4\"
}"))
(define (snapshot-operation handler)
  (define code "snapshot")
  (list (operation-entry 'type code "StructureDefinition" handler)
        (operation-entry 'instance code "StructureDefinition" handler)))
(define stats-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
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
    },
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://www.hl7.org/Special/committees/orders\"
        }
      ]
    }
  ],
  \"date\": \"2026-05-28T22:17:06+00:00\",
  \"description\": \"The Statistics operation performs a set of statistical calculations on a set of clinical measurements such as a blood pressure as stored on the server.  This operation evaluates [Observation](observation.html) resources having valueQuantity elements that have UCUM unit codes.      \\r\\rAlternatively, the [measure workflow pattern](measure.html) should be used when defining a quality measure (e.g. a description of how to calculate a particular measurement or set of measurements) as part of a workflow. \\r\\rThe set of Observations is defined by 4 parameters:\\r\\r*  the subject of the observations for which the statistics are being generated (`subject`)\\r* which observations to generate statistics for (`code` and `system`, or `coding`)\\r* the time period over which to generate statistics 'duration` or `period`)\\r* the set of statistical analyses to return (`statistic`)\\r\\rPossible statistical analyses (see [StatisticsCode](valueset-observation-statistics.html)):\\r\\r - **average** (\\\"Average\\\"): The [mean](https://en.wikipedia.org/wiki/Arithmetic_mean) of N measurements over the stated period.\\r\\n - **maximum** (\\\"Maximum\\\"): The [maximum](https://en.wikipedia.org/wiki/Maximal_element) value of N measurements over the stated period.\\r\\n - **minimum** (\\\"Minimum\\\"): The [minimum](https://en.wikipedia.org/wiki/Minimal_element) value of N measurements over the stated period.\\r\\n - **count** (\\\"Count\\\"): The [number] of valid measurements over the stated period that contributed to the other statistical outputs.\\r\\n - **total-count** (\\\"Total Count\\\"): The total [number] of valid measurements over the stated period, including observations that were ignored because they did not contain valid result values.\\r\\n - **median** (\\\"Median\\\"): The [median](https://en.wikipedia.org/wiki/Median) of N measurements over the stated period.\\r\\n - **std-dev** (\\\"Standard Deviation\\\"): The [standard deviation](https://en.wikipedia.org/wiki/Standard_deviation) of N measurements over the stated period.\\r\\n - **sum** (\\\"Sum\\\"): The [sum](https://en.wikipedia.org/wiki/Summation) of N measurements over the stated period.\\r\\n - **variance** (\\\"Variance\\\"): The [variance](https://en.wikipedia.org/wiki/Variance) of N measurements over the stated period.\\r\\n - **20-percent** (\\\"20th Percentile\\\"): The 20th [Percentile](https://en.wikipedia.org/wiki/Percentile) of N measurements over the stated period.\\r\\n - **80-percent** (\\\"80th Percentile\\\"): The 80th [Percentile](https://en.wikipedia.org/wiki/Percentile) of N measurements over the stated period.\\r\\n - **4-lower** (\\\"Lower Quartile\\\"): The lower [Quartile](https://en.wikipedia.org/wiki/Quartile) Boundary of N measurements over the stated period.\\r\\n - **4-upper** (\\\"Upper Quartile\\\"): The upper [Quartile](https://en.wikipedia.org/wiki/Quartile) Boundary of N measurements over the stated period.\\r\\n - **4-dev** (\\\"Quartile Deviation\\\"): The difference between the upper and lower [Quartiles](https://en.wikipedia.org/wiki/Quartile) is called the Interquartile range. (IQR = Q3-Q1) Quartile deviation or Semi-interquartile range is one-half the difference between the first and the third quartiles.\\r\\n - **5-1** (\\\"1st Quintile\\\"): The lowest of four values that divide the N measurements into a frequency distribution of five classes with each containing one fifth of the total population.\\r\\n - **5-2** (\\\"2nd Quintile\\\"): The second of four values that divide the N measurements into a frequency distribution of five classes with each containing one fifth of the total population.\\r\\n - **5-3** (\\\"3rd Quintile\\\"): The third of four values that divide the N measurements into a frequency distribution of five classes with each containing one fifth of the total population.\\r\\n - **5-4** (\\\"4th Quintile\\\"): The fourth of four values that divide the N measurements into a frequency distribution of five classes with each containing one fifth of the total population.\\r\\n - **skew** (\\\"Skew\\\"): Skewness is a measure of the asymmetry of the probability distribution of a real-valued random variable about its mean. The skewness value can be positive or negative, or even undefined.  Source: [Wikipedia](https://en.wikipedia.org/wiki/Skewness).\\r\\n - **kurtosis** (\\\"Kurtosis\\\"): Kurtosis  is a measure of the \\\"tailedness\\\" of the probability distribution of a real-valued random variable.   Source: [Wikipedia](https://en.wikipedia.org/wiki/Kurtosis).\\r\\n - **regression** (\\\"Regression\\\"): Linear regression is an approach for modeling two-dimensional sample points with one independent variable and one dependent variable (conventionally, the x and y coordinates in a Cartesian coordinate system) and finds a linear function (a non-vertical straight line) that, as accurately as possible, predicts the dependent variable values as a function of the independent variables. Source: [Wikipedia](https://en.wikipedia.org/wiki/Simple_linear_regression)  This Statistic code will return both a gradient and an intercept value.\\r\\n\\r\\rIf successful, the operation returns an Observation resource for each code with the results of the statistical calculations as component value pairs where the component code = the statistical code. The Observation also contains the input parameters `patient`,`code` and `duration` parameters. If unsuccessful, an [OperationOutcome](operationoutcome.html) with an error message will be returned.\\r\\rThe client can request that all the observations on which the statistics are based be returned as well, using the include parameter. If an include parameter is specified, a limit may also be specified; the sources observations are subsetted at the server's discretion if count > limit. This functionality is included with the intent of supporting graphical presentation\",
  \"experimental\": false,
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 3
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"normative\"
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-wg\",
      \"valueCode\": \"oo\"
    }
  ],
  \"id\": \"Observation-stats\",
  \"instance\": false,
  \"jurisdiction\": [
    {
      \"coding\": [
        {
          \"code\": \"001\",
          \"display\": \"World\",
          \"system\": \"http://unstats.un.org/unsd/methods/m49/m49.htm\"
        }
      ]
    }
  ],
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2026-05-28T22:17:06.960+00:00\"
  },
  \"name\": \"Stats\",
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
      \"binding\": {
        \"extension\": [
          {
            \"url\": \"http://hl7.org/fhir/StructureDefinition/elementdefinition-bindingName\",
            \"valueString\": \"ObservationStatsCode\"
          }
        ],
        \"strength\": \"required\",
        \"valueSet\": \"http://hl7.org/fhir/ValueSet/observation-statistics|6.0.0-ballot4\"
      },
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
      \"documentation\": \"If an include parameter is specified, a limit may also be specified to limit the number of source Observations returned.  If the include parameter is absent or equal to \\\"false\\\" the limit parameter SHALL be ignored by the server\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"limit\",
      \"type\": \"positiveInt\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"This parameter is used to specify inclusion of observations in the response based on Observation.status by including the Observation instances with a status listed in this parameter. When the parameter is absent, the default is to include all values except `entered-in-error`\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"include-statuses\",
      \"type\": \"code\",
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
  \"publisher\": \"HL7 International / Orders and Observations\",
  \"resource\": [
    \"Observation\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"active\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p class=\\\"res-header-id\\\">\\n              <b>Generated Narrative: OperationDefinition Observation-stats</b>\\n            </p>\\n            <a name=\\\"Observation-stats\\\"> </a>\\n            <a name=\\\"hcObservation-stats\\\"> </a>\\n            <p>URL: [base]/Observation/$stats</p>\\n            <h3>Parameters</h3>\\n\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>subject</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The subject of the relevant Observations, which has the value of the Observation.subject.reference. E.g. 'Patient/123'. Reference can be to an absolute URL, but servers only perform stats on their own observations</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>code</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The test code(s) upon which the statistics are being performed. Provide along with a system, or as a coding. For example, the LOINC code  =\\n2339-0 (Glucose [Mass/​volume] in Blood) will evaluate all relevant Observations with this code in \\n                      <code>Observation.code</code> and \\n                      <code>Observation.component.code</code>. For LOINC codes that are panels, e.g., 85354-9(Blood pressure panel with all children optional), the stats operation returns statistics for each of the individual panel measurements.  That means it will include and evaluate all values grouped by code for all the individual observations that are: 1) referenced in   \\n                      <code>.related</code> for \\n                      <code>.related.type</code> = 'has-member'  and 2) component observations in \\n                      <code>Observation.component</code>.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>system</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The system for the code(s). Or provide a coding instead</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>coding</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#Coding\\\">Coding</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The test code upon which the statistics are being performed, as a Coding</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>duration</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#decimal\\\">decimal</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The time period of interest given as hours.  For example, the duration = &quot;1&quot; represents the last hour - the time period from on hour ago to now</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>period</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#Period\\\">Period</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The time period over which the calculations to be performed, if a duration is not provided</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>statistic</td>\\n\\n                <td/>\\n\\n                <td>1..*</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n\\n                <td>\\n                  <a href=\\\"valueset-observation-statistics.html\\\">Statistics Code</a> (Required)\\n                </td>\\n\\n                <td>\\n                  <div>\\n                    <p>average|max|min|count  The statistical operations to be performed on the relevant operations. Multiple statistics operations can be specified. These codes are defined \\n                      <a href=\\\"valueset-observation-statistics.html\\\">here</a>\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>include</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Whether to return the observations on which the statistics are based</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>limit</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#positiveInt\\\">positiveInt</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>If an include parameter is specified, a limit may also be specified to limit the number of source Observations returned.  If the include parameter is absent or equal to &quot;false&quot; the limit parameter SHALL be ignored by the server</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>include-statuses</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>This parameter is used to specify inclusion of observations in the response based on Observation.status by including the Observation instances with a status listed in this parameter. When the parameter is absent, the default is to include all values except \\n                      <code>entered-in-error</code>\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>statistics</td>\\n\\n                <td/>\\n\\n                <td>1..*</td>\\n\\n                <td>\\n                  <a href=\\\"observation.html\\\">Observation</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>A set of observations, one observation for each code, each containing one component for each statistic. The Observation.component.code contains the statistic, and is relative to the Observation.code and cannot be interpreted independently.  The Observation will also contain a subject, effectivePeriod, and code reflecting the input parameters.  The status is fixed to \\n                      <code>final</code>.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>source</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"observation.html\\\">Observation</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Source observations on which the statistics are based</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n\\n            <div>\\n              <p>If \\n                <a href=\\\"extensibility.html#modifierExtension\\\">modifier extensions</a> are present in the Observation, they must be accounted for by implementers.  A modifier extension may affect the observation.value in a way that it should be excluded from the from the calculations.\\n              </p>\\n\\n              <p>This operation cannot be performed on observations that the user is not authorized to see.  It is assumed that the server has identified and secured the context appropriately, and can either associate the authorization context with a single patient, or determine whether the context has the rights to the nominated patient, if there is one. If there is no nominated patient (e.g. the operation is invoked at the system level) and the context is not associated with a single patient record, then the server should return an error. Specifying the relationship between the context, a user and patient records is outside the scope of this specification.</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"generated\"
  },
  \"title\": \"Observation Statistics\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Observation-stats\",
  \"version\": \"6.0.0-ballot4\"
}"))
(define (stats-operation handler)
  (define code "stats")
  (list (operation-entry 'type code "Observation" handler)))
(define status-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
  \"code\": \"status\",
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
    },
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://www.hl7.org/Special/committees/fiwg\"
        }
      ]
    }
  ],
  \"date\": \"2026-05-28T22:17:06+00:00\",
  \"description\": \"This operation is used to get current status information about one or more topic-based Subscriptions, each described by a SubscriptionStatus resource.\",
  \"experimental\": false,
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 2
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"normative\"
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-wg\",
      \"valueCode\": \"fhir\"
    }
  ],
  \"id\": \"Subscription-status\",
  \"instance\": true,
  \"jurisdiction\": [
    {
      \"coding\": [
        {
          \"code\": \"001\",
          \"display\": \"World\",
          \"system\": \"http://unstats.un.org/unsd/methods/m49/m49.htm\"
        }
      ]
    }
  ],
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2026-05-28T22:17:06.960+00:00\"
  },
  \"name\": \"Status\",
  \"parameter\": [
    {
      \"documentation\": \"At the Instance level, this parameter is ignored. At the Resource level, one or more FHIR ids to Subscription resources to get status information for. In the absence of any specified ids, the server returns the status for all Subscriptions available to the caller. Multiple values are joined via OR (e.g., \\\"id1\\\" OR \\\"id2\\\").\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"id\",
      \"scope\": [
        \"type\"
      ],
      \"type\": \"id\",
      \"use\": \"in\"
    },
    {
      \"binding\": {
        \"strength\": \"required\",
        \"valueSet\": \"http://hl7.org/fhir/ValueSet/subscription-status|6.0.0-ballot4\"
      },
      \"documentation\": \"At the Instance level, this parameter is ignored. At the Resource level, a Subscription status code to filter by (e.g., \\\"active\\\"). In the absence of any specified status values, the server does not filter contents based on the status. Multiple values are joined via OR (e.g., \\\"error\\\" OR \\\"off\\\").\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"status\",
      \"scope\": [
        \"type\"
      ],
      \"type\": \"code\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The operation returns a bundle containing zero or more SubscriptionStatus resources, one per Subscription in the request that was found. The Bundle type is \\\"searchset\\\".\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"return\",
      \"type\": \"Bundle\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 International / FHIR Infrastructure\",
  \"resource\": [
    \"Subscription\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"active\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p class=\\\"res-header-id\\\">\\n              <b>Generated Narrative: OperationDefinition Subscription-status</b>\\n            </p>\\n            <a name=\\\"Subscription-status\\\"> </a>\\n            <a name=\\\"hcSubscription-status\\\"> </a>\\n            <p>URL: [base]/Subscription/$status</p>\\n            <p>URL: [base]/Subscription/[id]/$status</p>\\n            <h3>Parameters</h3>\\n\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>id</td>\\n\\n                <td>type</td>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#id\\\">id</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>At the Instance level, this parameter is ignored. At the Resource level, one or more FHIR ids to Subscription resources to get status information for. In the absence of any specified ids, the server returns the status for all Subscriptions available to the caller. Multiple values are joined via OR (e.g., &quot;id1&quot; OR &quot;id2&quot;).</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>status</td>\\n\\n                <td>type</td>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n\\n                <td>\\n                  <a href=\\\"valueset-subscription-status.html\\\">Subscription Status</a> (Required)\\n                </td>\\n\\n                <td>\\n                  <div>\\n                    <p>At the Instance level, this parameter is ignored. At the Resource level, a Subscription status code to filter by (e.g., &quot;active&quot;). In the absence of any specified status values, the server does not filter contents based on the status. Multiple values are joined via OR (e.g., &quot;error&quot; OR &quot;off&quot;).</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>return</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"bundle.html\\\">Bundle</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The operation returns a bundle containing zero or more SubscriptionStatus resources, one per Subscription in the request that was found. The Bundle type is &quot;searchset&quot;.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n          </div>\",
    \"status\": \"generated\"
  },
  \"title\": \"Get Current Subscription Status for One or More Subscriptions\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Subscription-status\",
  \"version\": \"6.0.0-ballot4\"
}"))
(define (status-operation handler)
  (define code "status")
  (list (operation-entry 'type code "Subscription" handler)
        (operation-entry 'instance code "Subscription" handler)))
(define submit-data-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
  \"code\": \"submit-data\",
  \"comment\": \"The effect of invoking this operation is that the submitted data is posted to the receiving system and can be used for subsequent calculation of the relevant quality measure. The data-of-interest for a measure can be determined by examining the measure definition, or by invoking the $data-requirements operation.\",
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
    },
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://www.hl7.org/Special/committees/cqi\"
        }
      ]
    }
  ],
  \"date\": \"2026-05-28T22:17:06+00:00\",
  \"description\": \"The submit-data operation is used to submit data-of-interest for one or more measures for one or more subjects. Each submitted Bundle **SHOULD** contain resources for a single subject and **SHOULD** contain all of the MeasureReports and data of interest related to that subject. There is no expectation that the submitted data represents all the data-of-interest, only that all the data submitted is relevant to the calculation of the measure for a particular subject or population. The dataUpdateType element of the MeasureReport resource is used to indicate whether the data being submitted is a snapshot or incremental update. Additional guidance about data exchange for quality reporting can be found in the Data Exchange for Quality Measures implementation guide. Note that the use of the [X-Provenance header data](https://hl7.org/fhir/6.0.0-ballot4/provenance.html#header) with data that establishes provenance being submitted/collected **SHOULD** be supported. This provides the capability for associating the provider with the data submitted through the $submit-data transaction. If the X-Provenance header is used it should be consistent with the reporter element in the DEQM Data Exchange MeasureReport Profile. This operation is purposefully not allowed on a Measure instance because the MeasureReport included in the Bundle specifies the measure.\\\\n\\\\nNOTE: This operation is being deprecated in favor of just posting the bundles to the root of the server, either as collection or transaction bundles.\",
  \"experimental\": false,
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 3
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"deprecated\"
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-wg\",
      \"valueCode\": \"cqi\"
    }
  ],
  \"id\": \"Measure-submit-data\",
  \"instance\": false,
  \"jurisdiction\": [
    {
      \"coding\": [
        {
          \"code\": \"001\",
          \"display\": \"World\",
          \"system\": \"http://unstats.un.org/unsd/methods/m49/m49.htm\"
        }
      ]
    }
  ],
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2026-05-28T22:17:06.960+00:00\"
  },
  \"name\": \"SubmitData\",
  \"parameter\": [
    {
      \"documentation\": \"Bundles for each subject, containing a MeasureReport resource for each Measure being submitted, followed by entries for the data-of-interest for that subject.\",
      \"max\": \"*\",
      \"min\": 1,
      \"name\": \"bundle\",
      \"type\": \"MeasureReport\",
      \"use\": \"in\"
    }
  ],
  \"publisher\": \"HL7 International / Clinical Quality Information\",
  \"resource\": [
    \"Measure\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p class=\\\"res-header-id\\\">\\n              <b>Generated Narrative: OperationDefinition Measure-submit-data</b>\\n            </p>\\n            <a name=\\\"Measure-submit-data\\\"> </a>\\n            <a name=\\\"hcMeasure-submit-data\\\"> </a>\\n            <p>URL: [base]/Measure/$submit-data</p>\\n            <h3>Parameters</h3>\\n\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>bundle</td>\\n\\n                <td/>\\n\\n                <td>1..*</td>\\n\\n                <td>\\n                  <a href=\\\"measurereport.html\\\">MeasureReport</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Bundles for each subject, containing a MeasureReport resource for each Measure being submitted, followed by entries for the data-of-interest for that subject.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n\\n            <div>\\n              <p>The effect of invoking this operation is that the submitted data is posted to the receiving system and can be used for subsequent calculation of the relevant quality measure. The data-of-interest for a measure can be determined by examining the measure definition, or by invoking the $data-requirements operation.</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"generated\"
  },
  \"title\": \"Submit Data\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Measure-submit-data\",
  \"version\": \"6.0.0-ballot4\"
}"))
(define (submit-data-operation handler)
  (define code "submit-data")
  (list (operation-entry 'type code "Measure" handler)))
(define Claim-submit-definition
  (string->jsexpr
   "{
  \"affectsState\": true,
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
    },
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://www.hl7.org/Special/committees/fm\"
        }
      ]
    }
  ],
  \"date\": \"2026-05-28T22:17:06+00:00\",
  \"description\": \"This operation is used to submit a Claim, Pre-Authorization or Pre-Determination (all instances of Claim resources) for adjudication either as a single Claim resource instance or as a Bundle containing the Claim and other referenced resources, or Bundle containing a batch of Claim resources, either as single Claims resources or Bundle resources, for processing. The only input parameter is the single Claim or Bundle resource and the only output is a single ClaimResponse, Bundle of ClaimResponses or an OperationOutcome resource.\",
  \"experimental\": false,
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 2
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"normative\"
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-wg\",
      \"valueCode\": \"fm\"
    }
  ],
  \"id\": \"Claim-submit\",
  \"instance\": false,
  \"jurisdiction\": [
    {
      \"coding\": [
        {
          \"code\": \"001\",
          \"display\": \"World\",
          \"system\": \"http://unstats.un.org/unsd/methods/m49/m49.htm\"
        }
      ]
    }
  ],
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2026-05-28T22:17:06.960+00:00\"
  },
  \"name\": \"Submit\",
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
  \"publisher\": \"HL7 International / Financial Management\",
  \"resource\": [
    \"Claim\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"active\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p class=\\\"res-header-id\\\">\\n              <b>Generated Narrative: OperationDefinition Claim-submit</b>\\n            </p>\\n            <a name=\\\"Claim-submit\\\"> </a>\\n            <a name=\\\"hcClaim-submit\\\"> </a>\\n            <p>URL: [base]/Claim/$submit</p>\\n            <h3>Parameters</h3>\\n\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>resource</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"resource.html\\\">Resource</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>A Claim resource or Bundle of claims, either as individual Claim resources or as Bundles each containing a single Claim plus referenced resources.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>return</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"resource.html\\\">Resource</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>A ClaimResponse resource or Bundle of claim responses, either as individual ClaimResponse resources or as Bundles each containing a single ClaimResponse plus referenced resources.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n          </div>\",
    \"status\": \"generated\"
  },
  \"title\": \"Submit a Claim resource for adjudication\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Claim-submit\",
  \"version\": \"6.0.0-ballot4\"
}"))
(define (Claim-submit-operation handler)
  (define code "submit")
  (list (operation-entry 'type code "Claim" handler)))
(define CoverageEligibilityRequest-submit-definition
  (string->jsexpr
   "{
  \"affectsState\": true,
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
    },
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://www.hl7.org/Special/committees/fm\"
        }
      ]
    }
  ],
  \"date\": \"2026-05-28T22:17:06+00:00\",
  \"description\": \"This operation is used to submit an EligibilityRequest for assessment either as a single EligibilityRequest resource instance or as a Bundle containing the EligibilityRequest and other referenced resources, or Bundle containing a batch of EligibilityRequest resources, either as single EligibilityRequests resources or Bundle resources, for processing. The only input parameter is the single EligibilityRequest or Bundle resource and the only output is a single EligibilityResponse, Bundle of EligibilityResponses or an OperationOutcome resource.\",
  \"experimental\": false,
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 2
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"normative\"
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-wg\",
      \"valueCode\": \"fm\"
    }
  ],
  \"id\": \"CoverageEligibilityRequest-submit\",
  \"instance\": false,
  \"jurisdiction\": [
    {
      \"coding\": [
        {
          \"code\": \"001\",
          \"display\": \"World\",
          \"system\": \"http://unstats.un.org/unsd/methods/m49/m49.htm\"
        }
      ]
    }
  ],
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2026-05-28T22:17:06.960+00:00\"
  },
  \"name\": \"Submit\",
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
  \"publisher\": \"HL7 International / Financial Management\",
  \"resource\": [
    \"CoverageEligibilityRequest\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"active\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p class=\\\"res-header-id\\\">\\n              <b>Generated Narrative: OperationDefinition CoverageEligibilityRequest-submit</b>\\n            </p>\\n            <a name=\\\"CoverageEligibilityRequest-submit\\\"> </a>\\n            <a name=\\\"hcCoverageEligibilityRequest-submit\\\"> </a>\\n            <p>URL: [base]/CoverageEligibilityRequest/$submit</p>\\n            <h3>Parameters</h3>\\n\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>resource</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"resource.html\\\">Resource</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>An EligibilityRequest resource or Bundle of EligibilityRequests, either as individual EligibilityRequest resources or as Bundles each containing a single EligibilityRequest plus referenced resources.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>return</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"resource.html\\\">Resource</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>An EligibilityResponse resource or Bundle of EligibilityResponse responses, either as individual EligibilityResponse resources or as Bundles each containing a single EligibilityResponse plus referenced resources.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n          </div>\",
    \"status\": \"generated\"
  },
  \"title\": \"Submit an EligibilityRequest resource for assessment\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/CoverageEligibilityRequest-submit\",
  \"version\": \"6.0.0-ballot4\"
}"))
(define (CoverageEligibilityRequest-submit-operation handler)
  (define code "submit")
  (list (operation-entry 'type code "CoverageEligibilityRequest" handler)))
(define subsumes-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
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
    },
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://www.hl7.org/Special/committees/Vocab\"
        }
      ]
    }
  ],
  \"date\": \"2026-05-28T22:17:06+00:00\",
  \"description\": \"Test the subsumption relationship between code/Coding A and code/Coding B given the semantics of subsumption in the underlying code system (see [hierarchyMeaning](codesystem-definitions.html#CodeSystem.hierarchyMeaning)).\\n\\nWhen invoking this operation, a client SHALL provide both A and B codes, either as code or Coding parameters. The system parameter is required unless the operation is invoked on an instance of a code system resource. Other parameters are optional\",
  \"experimental\": false,
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
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-wg\",
      \"valueCode\": \"vocab\"
    }
  ],
  \"id\": \"CodeSystem-subsumes\",
  \"instance\": true,
  \"jurisdiction\": [
    {
      \"coding\": [
        {
          \"code\": \"001\",
          \"display\": \"World\",
          \"system\": \"http://unstats.un.org/unsd/methods/m49/m49.htm\"
        }
      ]
    }
  ],
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2026-05-28T22:17:06.960+00:00\"
  },
  \"name\": \"Subsumes\",
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
      \"scope\": [
        \"type\"
      ],
      \"type\": \"uri\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The version of the code system, if one was provided in the source data\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"version\",
      \"scope\": [
        \"type\"
      ],
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
        \"extension\": [
          {
            \"url\": \"http://hl7.org/fhir/StructureDefinition/elementdefinition-bindingName\",
            \"valueString\": \"ConceptSubsumptionOutcome\"
          }
        ],
        \"strength\": \"required\",
        \"valueSet\": \"http://hl7.org/fhir/ValueSet/concept-subsumption-outcome|6.0.0-ballot4\"
      },
      \"documentation\": \"The subsumption relationship between code/Coding \\\"A\\\" and code/Coding \\\"B\\\". There are 4 possible codes to be returned (equivalent, subsumes, subsumed-by, and not-subsumed) as defined in the concept-subsumption-outcome value set.  If the server is unable to determine the relationship between the codes/Codings, then it returns an error response with an OperationOutcome.\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"outcome\",
      \"type\": \"code\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 International / Terminology Infrastructure\",
  \"resource\": [
    \"CodeSystem\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"active\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p class=\\\"res-header-id\\\">\\n              <b>Generated Narrative: OperationDefinition CodeSystem-subsumes</b>\\n            </p>\\n            <a name=\\\"CodeSystem-subsumes\\\"> </a>\\n            <a name=\\\"hcCodeSystem-subsumes\\\"> </a>\\n            <p>URL: [base]/CodeSystem/$subsumes</p>\\n            <p>URL: [base]/CodeSystem/[id]/$subsumes</p>\\n            <h3>Parameters</h3>\\n\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>codeA</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The &quot;A&quot; code that is to be tested. If a code is provided, a system must be provided</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>codeB</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The &quot;B&quot; code that is to be tested. If a code is provided, a system must be provided</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>system</td>\\n\\n                <td>type</td>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The code system in which subsumption testing is to be performed. This must be provided unless the operation is invoked on a code system instance</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>version</td>\\n\\n                <td>type</td>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The version of the code system, if one was provided in the source data</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>codingA</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#Coding\\\">Coding</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The &quot;A&quot; Coding that is to be tested. The code system does not have to match the specified subsumption code system, but the relationships between the code systems must be well established</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>codingB</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#Coding\\\">Coding</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The &quot;B&quot; Coding that is to be tested. The code system does not have to match the specified subsumption code system, but the relationships between the code systems must be well established</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>outcome</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n\\n                <td>\\n                  <a href=\\\"valueset-concept-subsumption-outcome.html\\\">Concept Subsumption Outcome</a> (Required)\\n                </td>\\n\\n                <td>\\n                  <div>\\n                    <p>The subsumption relationship between code/Coding &quot;A&quot; and code/Coding &quot;B&quot;. There are 4 possible codes to be returned (equivalent, subsumes, subsumed-by, and not-subsumed) as defined in the concept-subsumption-outcome value set.  If the server is unable to determine the relationship between the codes/Codings, then it returns an error response with an OperationOutcome.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n          </div>\",
    \"status\": \"generated\"
  },
  \"title\": \"Subsumption Testing\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/CodeSystem-subsumes\",
  \"version\": \"6.0.0-ballot4\"
}"))
(define (subsumes-operation handler)
  (define code "subsumes")
  (list (operation-entry 'type code "CodeSystem" handler)
        (operation-entry 'instance code "CodeSystem" handler)))
(define transform-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
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
    },
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://www.hl7.org/Special/committees/fiwg\"
        }
      ]
    }
  ],
  \"date\": \"2026-05-28T22:17:06+00:00\",
  \"description\": \"The transform operation takes input content, applies a structure map transform, and then returns the output.\",
  \"experimental\": false,
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 2
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"normative\"
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-wg\",
      \"valueCode\": \"fhir\"
    }
  ],
  \"id\": \"StructureMap-transform\",
  \"instance\": true,
  \"jurisdiction\": [
    {
      \"coding\": [
        {
          \"code\": \"001\",
          \"display\": \"World\",
          \"system\": \"http://unstats.un.org/unsd/methods/m49/m49.htm\"
        }
      ]
    }
  ],
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2026-05-28T22:17:06.960+00:00\"
  },
  \"name\": \"Transform\",
  \"parameter\": [
    {
      \"documentation\": \"The structure map to apply. This is only needed if the operation is invoked at the resource level and no structureMap has been provided. If the $transform operation is invoked on a particular structure map, this will be ignored by the server\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"source\",
      \"scope\": [
        \"type\"
      ],
      \"type\": \"uri\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The structure map to apply. This is only needed when the operation is invoked at the resource level and no URI has been provided.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"sourceMap\",
      \"type\": \"StructureMap\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"StructureMap resources that support the source map. If a source URL is provided, the map can be provided in this parameter (or it can be provided as sourceMap).\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"supportingMap\",
      \"type\": \"StructureMap\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The same as structureMap, but the resource is provided in the mapping language rather than as a structureMap.\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"srcMap\",
      \"type\": \"string\",
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
  \"publisher\": \"HL7 International / FHIR Infrastructure\",
  \"resource\": [
    \"StructureMap\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"active\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p class=\\\"res-header-id\\\">\\n              <b>Generated Narrative: OperationDefinition StructureMap-transform</b>\\n            </p>\\n            <a name=\\\"StructureMap-transform\\\"> </a>\\n            <a name=\\\"hcStructureMap-transform\\\"> </a>\\n            <p>URL: [base]/StructureMap/$transform</p>\\n            <p>URL: [base]/StructureMap/[id]/$transform</p>\\n            <h3>Parameters</h3>\\n\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>source</td>\\n\\n                <td>type</td>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The structure map to apply. This is only needed if the operation is invoked at the resource level and no structureMap has been provided. If the $transform operation is invoked on a particular structure map, this will be ignored by the server</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>sourceMap</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"structuremap.html\\\">StructureMap</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The structure map to apply. This is only needed when the operation is invoked at the resource level and no URI has been provided.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>supportingMap</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"structuremap.html\\\">StructureMap</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>StructureMap resources that support the source map. If a source URL is provided, the map can be provided in this parameter (or it can be provided as sourceMap).</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>srcMap</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The same as structureMap, but the resource is provided in the mapping language rather than as a structureMap.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>content</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"resource.html\\\">Resource</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The logical content to transform</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>return</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"resource.html\\\">Resource</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The result of the transform</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n\\n            <div>\\n              <p>The input and return are specified as 'Resources'. In most usage of the $transform operation, either the input or return content is not a valid FHIR resource. In these cases, the return type is actually a \\n                <a href=\\\"binary.html\\\">Binary</a> resource. For this operation, the Binary resources may be encoded directly, using a mime-type, as shown in the example. Note: this specification does not yet address the means by which the servers may know the correct mime types for the various content involved\\n              </p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"generated\"
  },
  \"title\": \"Model Instance Transformation\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/StructureMap-transform\",
  \"version\": \"6.0.0-ballot4\"
}"))
(define (transform-operation handler)
  (define code "transform")
  (list (operation-entry 'type code "StructureMap" handler)
        (operation-entry 'instance code "StructureMap" handler)))
(define translate-id-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
  \"code\": \"translate-id\",
  \"comment\": \"Servers handle this request by finding the provided identifier in their known naming systems, and returning the requested identifier type ([NamingSystem.uniqueId.type](namingsystem-definitions.html#NamingSystem.uniqueId.type)).  \\n\\nIf the server wishes, it can also look through all code systems and value sets it knows about when attempting to find the requested identifier\",
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
    },
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://www.hl7.org/Special/committees/Vocab\"
        }
      ]
    }
  ],
  \"date\": \"2026-05-28T22:17:06+00:00\",
  \"description\": \"This operation returns an identifier of the target type. The operation takes 5 parameters:     \\n\\n* a source identifier value - either a URI, an OID, or a v2 table 0396 (other) code  \\n*  a code for what type of identifier the source identifier is     \\n\\n* a code for what kind of identifier is desired (URI, OID, v2 table 0396 identifier)     \\n\\n* an optional parameter preferredOnly for whether only the preferred identifier is desired     \\n\\n* an optional date to return only identifiers that have a validity period that includes that date   \\n\\nand returns either the requested identifier(s), or an HTTP errors response with an OperationOutcome because either the provided identifier was not recognized, or the requested identiifer type is not known.\",
  \"experimental\": false,
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 1
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"normative\"
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-wg\",
      \"valueCode\": \"vocab\"
    }
  ],
  \"id\": \"NamingSystem-translate-id\",
  \"instance\": false,
  \"jurisdiction\": [
    {
      \"coding\": [
        {
          \"code\": \"001\",
          \"display\": \"World\",
          \"system\": \"http://unstats.un.org/unsd/methods/m49/m49.htm\"
        }
      ]
    }
  ],
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2026-05-28T22:17:06.960+00:00\"
  },
  \"name\": \"TranslateId\",
  \"parameter\": [
    {
      \"documentation\": \"The server parses the provided identifier to see what type it is (e.g. a URI, an OID as a URI, a plain OID, or a v2 table 0396 code). If the server can't tell what type of identifier it is, it can try it as multiple types. It is an error if more than one system matches the provided identifier\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"id\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"binding\": {
        \"extension\": [
          {
            \"url\": \"http://hl7.org/fhir/StructureDefinition/elementdefinition-bindingName\",
            \"valueString\": \"NamingSystemIdentifierType\"
          }
        ],
        \"strength\": \"required\",
        \"valueSet\": \"http://hl7.org/fhir/ValueSet/namingsystem-identifier-type|6.0.0-ballot4\"
      },
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"sourceType\",
      \"type\": \"code\",
      \"use\": \"in\"
    },
    {
      \"binding\": {
        \"extension\": [
          {
            \"url\": \"http://hl7.org/fhir/StructureDefinition/elementdefinition-bindingName\",
            \"valueString\": \"NamingSystemIdentifierType\"
          }
        ],
        \"strength\": \"required\",
        \"valueSet\": \"http://hl7.org/fhir/ValueSet/namingsystem-identifier-type|6.0.0-ballot4\"
      },
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"targetType\",
      \"type\": \"code\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"If preferredOnly = true then return only the preferred identifier, or if preferredOnly = false then return all available ids.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"preferredOnly\",
      \"type\": \"boolean\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"If 'date' is supplied return only ids that have a validity period that includes that date.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"date\",
      \"type\": \"dateTime\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"True if the identifier could be translated successfully.\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"result\",
      \"type\": \"boolean\",
      \"use\": \"out\"
    },
    {
      \"documentation\": \"The target identifer(s) of the requested type\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"targetIdentifier\",
      \"type\": \"string\",
      \"use\": \"out\"
    },
    {
      \"documentation\": \"Whether the target identifier is preferred.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"targetIdentifer.preferred\",
      \"type\": \"boolean\",
      \"use\": \"out\"
    },
    {
      \"documentation\": \"The perioid when the target identifier is valid.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"targetIdentifier.period\",
      \"type\": \"Period\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 International / Terminology Infrastructure\",
  \"resource\": [
    \"NamingSystem\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"active\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p class=\\\"res-header-id\\\">\\n              <b>Generated Narrative: OperationDefinition NamingSystem-translate-id</b>\\n            </p>\\n            <a name=\\\"NamingSystem-translate-id\\\"> </a>\\n            <a name=\\\"hcNamingSystem-translate-id\\\"> </a>\\n            <p>URL: [base]/NamingSystem/$translate-id</p>\\n            <h3>Parameters</h3>\\n\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>id</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The server parses the provided identifier to see what type it is (e.g. a URI, an OID as a URI, a plain OID, or a v2 table 0396 code). If the server can't tell what type of identifier it is, it can try it as multiple types. It is an error if more than one system matches the provided identifier</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>sourceType</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n\\n                <td>\\n                  <a href=\\\"valueset-namingsystem-identifier-type.html\\\">Naming System Identifier Type</a> (Required)\\n                </td>\\n\\n                <td/>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>targetType</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n\\n                <td>\\n                  <a href=\\\"valueset-namingsystem-identifier-type.html\\\">Naming System Identifier Type</a> (Required)\\n                </td>\\n\\n                <td/>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>preferredOnly</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>If preferredOnly = true then return only the preferred identifier, or if preferredOnly = false then return all available ids.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>date</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#dateTime\\\">dateTime</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>If 'date' is supplied return only ids that have a validity period that includes that date.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>result</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>True if the identifier could be translated successfully.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>targetIdentifier</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The target identifer(s) of the requested type</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>targetIdentifer.preferred</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Whether the target identifier is preferred.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>targetIdentifier.period</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#Period\\\">Period</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The perioid when the target identifier is valid.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n\\n            <div>\\n              <p>Servers handle this request by finding the provided identifier in their known naming systems, and returning the requested identifier type (\\n                <a href=\\\"namingsystem-definitions.html#NamingSystem.uniqueId.type\\\">NamingSystem.uniqueId.type</a>).\\n              </p>\\n\\n              <p>If the server wishes, it can also look through all code systems and value sets it knows about when attempting to find the requested identifier</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"generated\"
  },
  \"title\": \"Translate id\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/NamingSystem-translate-id\",
  \"version\": \"6.0.0-ballot4\"
}"))
(define (translate-id-operation handler)
  (define code "translate-id")
  (list (operation-entry 'type code "NamingSystem" handler)))
(define translate-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
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
    },
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://www.hl7.org/Special/committees/Vocab\"
        }
      ]
    }
  ],
  \"date\": \"2026-05-28T22:17:06+00:00\",
  \"description\": \"Translate a code from one value set to another, based on the specified ConceptMap resource. If no ConceptMap resource is specified, then other additional knowledge available to the server may be used. \\r\\n\\r\\n One (and only one) of the in parameters (sourceCode, sourceCoding, sourceCodeableConcept, targetCode, targetCoding, or targetCodeableConcept) SHALL be provided, to identify the code that is to be translated.  \\r\\n\\r\\n The operation returns a set of parameters including a 'result' for whether there is an acceptable match, and a list of possible matches. Note that the list of matches may include notes of codes for which mapping is specifically excluded (i.e. 'not-related-to'), so implementers have to check the target.relationship for each match. If a source* parameter is provided, the $translate operation will return all matches whereby the provided source concept is the source of a mapping relationship (in a specified ConceptMap or otherwise known to the server). If a target* parameter is provided, the $translate operation will return all matches whereby the provided target concept is the target of a mapping relationship (in a specified ConceptMap or otherwise known to the server). Note: The source value set is an optional parameter because in some cases, the client cannot know what the source value set is. However, without a source value set, the server may be unable to safely identify an applicable concept map, and would return an error. For this reason, a source value set SHOULD always be provided. Note that servers may be able to identify an appropriate concept map without a source value set if there is a full mapping for the entire code system in the concept map, or by manual intervention.\",
  \"experimental\": false,
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 1
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"normative\"
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-wg\",
      \"valueCode\": \"vocab\"
    }
  ],
  \"id\": \"ConceptMap-translate\",
  \"instance\": true,
  \"jurisdiction\": [
    {
      \"coding\": [
        {
          \"code\": \"001\",
          \"display\": \"World\",
          \"system\": \"http://unstats.un.org/unsd/methods/m49/m49.htm\"
        }
      ]
    }
  ],
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2026-05-28T22:17:06.960+00:00\"
  },
  \"name\": \"Translate\",
  \"parameter\": [
    {
      \"documentation\": \"A canonical URL for a concept map. The server must know the concept map (e.g. it is defined explicitly in the server's concept maps, or it is defined implicitly by some code system known to the server.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"url\",
      \"scope\": [
        \"type\"
      ],
      \"type\": \"uri\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The concept map is provided directly as part of the request. Servers may choose not to accept concept maps in this fashion.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"conceptMap\",
      \"scope\": [
        \"type\"
      ],
      \"type\": \"ConceptMap\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The identifier that is used to identify a specific version of the concept map to be used for the translation. This is an arbitrary value managed by the concept map author and is not expected to be globally unique. For example, it might be a timestamp (e.g. yyyymmdd) if a managed version is not available.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"conceptMapVersion\",
      \"scope\": [
        \"type\"
      ],
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The code that is to be translated. If a code is provided, a system must be provided\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"sourceCode\",
      \"type\": \"code\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The system for the sourceCode to be translated. Note: the previous name of this input parameter was `system`, and servers MAY choose to still accept that name\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"sourceSystem\",
      \"type\": \"uri\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The version for the system of the sourceCode to be translated. Note: the previous name of this input parameter was `version`, and servers MAY choose to still accept that name.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"sourceVersion\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Limits the scope of the $translate operation to source codes (ConceptMap.group.element.code) that are members of this value set.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"sourceScope\",
      \"type\": \"uri\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"A coding to translate\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"sourceCoding\",
      \"type\": \"Coding\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"A full codeableConcept to validate. The server can translate any of the coding values (e.g. existing translations) as it chooses\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"sourceCodeableConcept\",
      \"type\": \"CodeableConcept\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The target code that is to be translated to. If a code is provided, a system must be provided\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"targetCode\",
      \"type\": \"code\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"A target coding to translate to\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"targetCoding\",
      \"type\": \"Coding\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"A full codeableConcept to validate. The server can translate any of the coding values (e.g. existing translations) as it chooses\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"targetCodeableConcept\",
      \"type\": \"CodeableConcept\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Limits the scope of the $translate operation to target codes (ConceptMap.group.element.target.code) that are members of this value set.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"targetScope\",
      \"type\": \"uri\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"identifies a target code system in which a mapping is sought. This parameter is an alternative to the targetScope parameter - only one is required. Searching for any translation to a target code system irrespective of the context (e.g. target valueset) may lead to unsafe results, and it is at the discretion of the server to decide when to support this operation\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"targetSystem\",
      \"type\": \"uri\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Data from another attribute that may help produce the correct mapping\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"dependency\",
      \"part\": [
        {
          \"documentation\": \"The attribute for this dependency\",
          \"max\": \"1\",
          \"min\": 0,
          \"name\": \"attribute\",
          \"type\": \"uri\",
          \"use\": \"in\"
        },
        {
          \"documentation\": \"The data value for this dependency\",
          \"max\": \"1\",
          \"min\": 0,
          \"name\": \"value\",
          \"type\": \"Element\",
          \"use\": \"in\"
        }
      ],
      \"use\": \"in\"
    },
    {
      \"documentation\": \"True if the concept could be translated successfully. The value can only be true if at least one returned match has a relationship other than 'not-related-to'.\",
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
      \"documentation\": \"A concept in the target value set with a relationship. Note that there may be multiple matches of equal or differing relationships, and the matches may include the 'not-related-to' relationship value which means that there is no translation\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"match\",
      \"part\": [
        {
          \"documentation\": \"A code indicating the relationship (e.g., equivalent) of the translation, using values from [ConceptMapRelationship](valueset-concept-map-relationship.html)\",
          \"max\": \"1\",
          \"min\": 0,
          \"name\": \"relationship\",
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
          \"documentation\": \"A property of this mapping (may be used to supply for example, mapping priority, provenance, presentation hints, flag as experimental, and additional documentation)\",
          \"max\": \"*\",
          \"min\": 0,
          \"name\": \"property\",
          \"part\": [
            {
              \"documentation\": \"The uri that identifies the property\",
              \"max\": \"1\",
              \"min\": 1,
              \"name\": \"uri\",
              \"type\": \"uri\",
              \"use\": \"out\"
            },
            {
              \"documentation\": \"The value of the property\",
              \"max\": \"1\",
              \"min\": 1,
              \"name\": \"value\",
              \"type\": \"Element\",
              \"use\": \"out\"
            }
          ],
          \"use\": \"out\"
        },
        {
          \"documentation\": \"A data value to go in an attribute that is the product of this mapping\",
          \"max\": \"*\",
          \"min\": 0,
          \"name\": \"product\",
          \"part\": [
            {
              \"documentation\": \"The attribute for this product\",
              \"max\": \"1\",
              \"min\": 1,
              \"name\": \"attribute\",
              \"type\": \"uri\",
              \"use\": \"out\"
            },
            {
              \"documentation\": \"The value for this product\",
              \"max\": \"1\",
              \"min\": 1,
              \"name\": \"value\",
              \"type\": \"Element\",
              \"use\": \"out\"
            }
          ],
          \"use\": \"out\"
        },
        {
          \"documentation\": \"An data value in an additional attribute that this mapping depends on\",
          \"max\": \"*\",
          \"min\": 0,
          \"name\": \"dependsOn\",
          \"part\": [
            {
              \"documentation\": \"The attribute that this mapping depends on\",
              \"max\": \"1\",
              \"min\": 1,
              \"name\": \"attribute\",
              \"type\": \"uri\",
              \"use\": \"out\"
            },
            {
              \"documentation\": \"The value of the attribute that this mapping depends on\",
              \"max\": \"1\",
              \"min\": 1,
              \"name\": \"value\",
              \"type\": \"Element\",
              \"use\": \"out\"
            }
          ],
          \"use\": \"out\"
        },
        {
          \"documentation\": \"The canonical reference to the concept map from which this mapping comes from\",
          \"max\": \"1\",
          \"min\": 0,
          \"name\": \"originMap\",
          \"type\": \"uri\",
          \"use\": \"out\"
        }
      ],
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 International / Terminology Infrastructure\",
  \"resource\": [
    \"ConceptMap\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"active\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p class=\\\"res-header-id\\\">\\n              <b>Generated Narrative: OperationDefinition ConceptMap-translate</b>\\n            </p>\\n            <a name=\\\"ConceptMap-translate\\\"> </a>\\n            <a name=\\\"hcConceptMap-translate\\\"> </a>\\n            <p>URL: [base]/ConceptMap/$translate</p>\\n            <p>URL: [base]/ConceptMap/[id]/$translate</p>\\n            <h3>Parameters</h3>\\n\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>url</td>\\n\\n                <td>type</td>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>A canonical URL for a concept map. The server must know the concept map (e.g. it is defined explicitly in the server's concept maps, or it is defined implicitly by some code system known to the server.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>conceptMap</td>\\n\\n                <td>type</td>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"conceptmap.html\\\">ConceptMap</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The concept map is provided directly as part of the request. Servers may choose not to accept concept maps in this fashion.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>conceptMapVersion</td>\\n\\n                <td>type</td>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The identifier that is used to identify a specific version of the concept map to be used for the translation. This is an arbitrary value managed by the concept map author and is not expected to be globally unique. For example, it might be a timestamp (e.g. yyyymmdd) if a managed version is not available.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>sourceCode</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The code that is to be translated. If a code is provided, a system must be provided</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>sourceSystem</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The system for the sourceCode to be translated. Note: the previous name of this input parameter was \\n                      <code>system</code>, and servers MAY choose to still accept that name\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>sourceVersion</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The version for the system of the sourceCode to be translated. Note: the previous name of this input parameter was \\n                      <code>version</code>, and servers MAY choose to still accept that name.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>sourceScope</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Limits the scope of the $translate operation to source codes (ConceptMap.group.element.code) that are members of this value set.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>sourceCoding</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#Coding\\\">Coding</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>A coding to translate</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>sourceCodeableConcept</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#CodeableConcept\\\">CodeableConcept</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>A full codeableConcept to validate. The server can translate any of the coding values (e.g. existing translations) as it chooses</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>targetCode</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The target code that is to be translated to. If a code is provided, a system must be provided</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>targetCoding</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#Coding\\\">Coding</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>A target coding to translate to</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>targetCodeableConcept</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#CodeableConcept\\\">CodeableConcept</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>A full codeableConcept to validate. The server can translate any of the coding values (e.g. existing translations) as it chooses</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>targetScope</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Limits the scope of the $translate operation to target codes (ConceptMap.group.element.target.code) that are members of this value set.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>targetSystem</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>identifies a target code system in which a mapping is sought. This parameter is an alternative to the targetScope parameter - only one is required. Searching for any translation to a target code system irrespective of the context (e.g. target valueset) may lead to unsafe results, and it is at the discretion of the server to decide when to support this operation</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>dependency</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td/>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Data from another attribute that may help produce the correct mapping</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>dependency.attribute</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The attribute for this dependency</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>dependency.value</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"types.html#Element\\\">Element</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The data value for this dependency</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>result</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>True if the concept could be translated successfully. The value can only be true if at least one returned match has a relationship other than 'not-related-to'.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>message</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Error details, for display to a human. If this is provided when result = true, the message carries hints and warnings (e.g. a note that the matches could be improved by providing additional detail)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>match</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td/>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>A concept in the target value set with a relationship. Note that there may be multiple matches of equal or differing relationships, and the matches may include the 'not-related-to' relationship value which means that there is no translation</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>match.relationship</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>A code indicating the relationship (e.g., equivalent) of the translation, using values from \\n                      <a href=\\\"valueset-concept-map-relationship.html\\\">ConceptMapRelationship</a>\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>match.concept</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#Coding\\\">Coding</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The translation outcome. Note that this would never have userSelected = true, since the process of translations implies that the user is not selecting the code (and only the client could know differently)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>match.property</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td/>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>A property of this mapping (may be used to supply for example, mapping priority, provenance, presentation hints, flag as experimental, and additional documentation)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>match.property.uri</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The uri that identifies the property</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>match.property.value</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"types.html#Element\\\">Element</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The value of the property</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>match.product</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td/>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>A data value to go in an attribute that is the product of this mapping</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>match.product.attribute</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The attribute for this product</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>match.product.value</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"types.html#Element\\\">Element</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The value for this product</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>match.dependsOn</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td/>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>An data value in an additional attribute that this mapping depends on</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>match.dependsOn.attribute</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The attribute that this mapping depends on</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>match.dependsOn.value</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"types.html#Element\\\">Element</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The value of the attribute that this mapping depends on</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>match.originMap</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The canonical reference to the concept map from which this mapping comes from</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n          </div>\",
    \"status\": \"generated\"
  },
  \"title\": \"Concept Translation\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/ConceptMap-translate\",
  \"version\": \"6.0.0-ballot4\"
}"))
(define (translate-operation handler)
  (define code "translate")
  (list (operation-entry 'type code "ConceptMap" handler)
        (operation-entry 'instance code "ConceptMap" handler)))
(define CodeSystem-validate-code-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
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
    },
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://www.hl7.org/Special/committees/Vocab\"
        }
      ]
    }
  ],
  \"date\": \"2026-05-28T22:17:06+00:00\",
  \"description\": \"Validate that a coded value is in the code system. If the operation is not called at the instance level, one of the parameters \\\"url\\\" or \\\"codeSystem\\\" must be provided. The operation returns a result (true / false), an error message, and the recommended display for the code.\\n\\nWhen invoking this operation, a client **SHALL** provide one (and only one) of the parameters (code+system, coding, or codeableConcept). Other parameters (including version and display) are optional. When validating a code or a coding, then the code, system and version output parameters **SHOULD** be populated when possible. When a validating a CodeableConcept, then the codeableConcept output parameter **SHOULD** be populated when possible.\",
  \"experimental\": false,
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
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-wg\",
      \"valueCode\": \"vocab\"
    }
  ],
  \"id\": \"CodeSystem-validate-code\",
  \"instance\": true,
  \"jurisdiction\": [
    {
      \"coding\": [
        {
          \"code\": \"001\",
          \"display\": \"World\",
          \"system\": \"http://unstats.un.org/unsd/methods/m49/m49.htm\"
        }
      ]
    }
  ],
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2026-05-28T22:17:06.960+00:00\"
  },
  \"name\": \"ValidateCode\",
  \"parameter\": [
    {
      \"documentation\": \"CodeSystem URL. The server must know the code system (e.g. it is defined explicitly in the server'scode systems, or it is known implicitly by the server\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"url\",
      \"scope\": [
        \"type\"
      ],
      \"type\": \"uri\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The codeSystem is provided directly as part of the request. Servers may choose not to accept code systems in this fashion. This parameter is used when the client wants the server to check against a code system that is not stored on the server\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"codeSystem\",
      \"scope\": [
        \"type\"
      ],
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
      \"scope\": [
        \"type\"
      ],
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
      \"documentation\": \"If this parameter has a value of true, the client is stating that the validation is being performed in a context where a concept designated as 'abstract' is appropriate/allowed to be used, and the server should regard abstract codes as valid. If this parameter is false, abstract codes are not considered to be valid.\\n\\nNote that 'abstract' is a property defined by many HL7 code systems that indicates that the concept is a logical grouping concept that is not intended to be used asa 'concrete' concept to in an actual patient/care/process record. This language is borrowed from Object Orienated theory where 'abstract' objects are never instantiated. However in the general record and terminology eco-system, there are many contexts where it is appropraite to use these codes e.g. as decision making criterion, or when editing value sets themselves. This parameter allows a client to indicate to the server that it is working in such a context.\",
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
    },
    {
      \"documentation\": \"The code that was validated\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"code\",
      \"type\": \"code\",
      \"use\": \"out\"
    },
    {
      \"documentation\": \"The system for the code that was validated\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"system\",
      \"type\": \"uri\",
      \"use\": \"out\"
    },
    {
      \"documentation\": \"The version of the system of the code that was validated\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"version\",
      \"type\": \"string\",
      \"use\": \"out\"
    },
    {
      \"documentation\": \"A codeableConcept containing codings for all the validated codes\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"codeableConcept\",
      \"type\": \"CodeableConcept\",
      \"use\": \"out\"
    },
    {
      \"documentation\": \"List of itemised issues with paths constrained to simple FHIRPath. Examples are CodeableConcept, CodeableConcept.coding[0], CodeableConcept.coding[1].display, or Coding.display\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"issues\",
      \"type\": \"OperationOutcome\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 International / Terminology Infrastructure\",
  \"resource\": [
    \"CodeSystem\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"active\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p class=\\\"res-header-id\\\">\\n              <b>Generated Narrative: OperationDefinition CodeSystem-validate-code</b>\\n            </p>\\n            <a name=\\\"CodeSystem-validate-code\\\"> </a>\\n            <a name=\\\"hcCodeSystem-validate-code\\\"> </a>\\n            <p>URL: [base]/CodeSystem/$validate-code</p>\\n            <p>URL: [base]/CodeSystem/[id]/$validate-code</p>\\n            <h3>Parameters</h3>\\n\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>url</td>\\n\\n                <td>type</td>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>CodeSystem URL. The server must know the code system (e.g. it is defined explicitly in the server'scode systems, or it is known implicitly by the server</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>codeSystem</td>\\n\\n                <td>type</td>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"codesystem.html\\\">CodeSystem</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The codeSystem is provided directly as part of the request. Servers may choose not to accept code systems in this fashion. This parameter is used when the client wants the server to check against a code system that is not stored on the server</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>code</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The code that is to be validated</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>version</td>\\n\\n                <td>type</td>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The version of the code system, if one was provided in the source data</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>display</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The display associated with the code, if provided. If a display is provided a code must be provided. If no display is provided, the server cannot validate the display value, but may choose to return a recommended display name in an extension in the outcome. Whether displays are case sensitive is code system dependent</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>coding</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#Coding\\\">Coding</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>A coding to validate. The system must match the specified code system</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>codeableConcept</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#CodeableConcept\\\">CodeableConcept</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>A full codeableConcept to validate. The server returns true if one of the coding values is in the code system, and may also validate that the codings are not in conflict with each other if more than one is present</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>date</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#dateTime\\\">dateTime</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The date for which the validation should be checked. Normally, this is the current conditions (which is the default values) but under some circumstances, systems need to validate that a correct code was used at some point in the past. A typical example of this would be where code selection is constrained to the set of codes that were available when the patient was treated, not when the record is being edited. Note that which date is appropriate is a matter for implementation policy.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>abstract</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>If this parameter has a value of true, the client is stating that the validation is being performed in a context where a concept designated as 'abstract' is appropriate/allowed to be used, and the server should regard abstract codes as valid. If this parameter is false, abstract codes are not considered to be valid.</p>\\n\\n                    <p>Note that 'abstract' is a property defined by many HL7 code systems that indicates that the concept is a logical grouping concept that is not intended to be used asa 'concrete' concept to in an actual patient/care/process record. This language is borrowed from Object Orienated theory where 'abstract' objects are never instantiated. However in the general record and terminology eco-system, there are many contexts where it is appropraite to use these codes e.g. as decision making criterion, or when editing value sets themselves. This parameter allows a client to indicate to the server that it is working in such a context.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>displayLanguage</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Specifies the language to be used for description when validating the display property</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>result</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>True if the concept details supplied are valid</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>message</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Error details, if result = false. If this is provided when result = true, the message carries hints and warnings</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>display</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>A valid display for the concept if the system wishes to display this to a user</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>code</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The code that was validated</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>system</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The system for the code that was validated</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>version</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The version of the system of the code that was validated</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>codeableConcept</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#CodeableConcept\\\">CodeableConcept</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>A codeableConcept containing codings for all the validated codes</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>issues</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"operationoutcome.html\\\">OperationOutcome</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>List of itemised issues with paths constrained to simple FHIRPath. Examples are CodeableConcept, CodeableConcept.coding[0], CodeableConcept.coding[1].display, or Coding.display</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n          </div>\",
    \"status\": \"generated\"
  },
  \"title\": \"Code System based Validation\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/CodeSystem-validate-code\",
  \"version\": \"6.0.0-ballot4\"
}"))
(define (CodeSystem-validate-code-operation handler)
  (define code "validate-code")
  (list (operation-entry 'type code "CodeSystem" handler)
        (operation-entry 'instance code "CodeSystem" handler)))
(define ValueSet-validate-code-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
  \"code\": \"validate-code\",
  \"comment\": \"Note: the correct behavior of validation with regard to language for Coding.display items is currently undefined, and further development and testing may lead to specific requirements or recommendations in subsequent releases\",
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
    },
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://www.hl7.org/Special/committees/Vocab\"
        }
      ]
    }
  ],
  \"date\": \"2026-05-28T22:17:06+00:00\",
  \"description\": \"Validate that a coded value is in the set of codes allowed by a value set.\\n\\nIf the operation is not called at the instance level, one of the in parameters url, context or valueSet must be provided.  One (and only one) of the in parameters code, coding, or codeableConcept must be provided. If a code is provided, either a system or inferSystem **SHOULD** be provided. The operation returns a result (true / false), an error message, and the recommended display for the code. When validating a code or a coding, then the code, system and version output parameters **SHOULD** be populated when possible. When a validating a CodeableConcept, then the codeableConcept output parameter **SHOULD** be populated when possible.\",
  \"experimental\": false,
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
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-wg\",
      \"valueCode\": \"vocab\"
    }
  ],
  \"id\": \"ValueSet-validate-code\",
  \"instance\": true,
  \"jurisdiction\": [
    {
      \"coding\": [
        {
          \"code\": \"001\",
          \"display\": \"World\",
          \"system\": \"http://unstats.un.org/unsd/methods/m49/m49.htm\"
        }
      ]
    }
  ],
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2026-05-28T22:17:06.960+00:00\"
  },
  \"name\": \"ValidateCode\",
  \"parameter\": [
    {
      \"documentation\": \"Value set Canonical URL. The server must know the value set (e.g. it is defined explicitly in the server's value sets, or it is defined implicitly by some code system known to the server\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"url\",
      \"scope\": [
        \"type\"
      ],
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
      \"scope\": [
        \"type\"
      ],
      \"type\": \"ValueSet\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The identifier that is used to identify a specific version of the value set to be used when validating the code. This is an arbitrary value managed by the value set author and is not expected to be globally unique. For example, it might be a timestamp (e.g. yyyymmdd) if a managed version is not available\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"valueSetVersion\",
      \"scope\": [
        \"type\"
      ],
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
      \"documentation\": \"The version of the system, if one was provided in the source data. Note that this is a different parameter to system-version\",
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
      \"documentation\": \"If this parameter has a value of true or the parameter is omitted, the client is stating that the validation is being performed in a context where a concept designated as 'abstract' is appropriate/allowed to be used, and the server should regard abstract codes as valid. If this parameter is false, abstract codes are not considered to be valid.\\n\\nNote that 'abstract' is a property defined by many HL7 code systems that indicates that the concept is a logical grouping concept that is not intended to be used as a 'concrete' concept to in an actual patient/care/process record. This language is borrowed from object-orientated theory where 'abstract' entities are never instantiated. However in the general record and terminology eco-system, there are many contexts where it is appropriate to use these codes e.g. as decision making criterion, or when editing value sets themselves. This parameter allows a client to indicate to the server that it is working in such a context.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"abstract\",
      \"type\": \"boolean\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Specifies the language for display validation.  Note: the display value only needs to match 1 displayLanguage in order for the validate operation to return true.\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"displayLanguage\",
      \"type\": \"code\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The supplement must be used when validating the code. Use of this parameter should result in $validate-code behaving the same way as if the supplements were included in the value set definition using the [http://hl7.org/fhir/StructureDefinition/valueset-supplement](https://build.fhir.org/ig/HL7/fhir-extensions/StructureDefinition-valueset-supplement.html)\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"useSupplement\",
      \"type\": \"canonical\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"When the 'lenient-display-validation' parameter is true, an invalid display string will not cause the 'result' output parameter to be 'false'. If the 'lenient-display-validation' parameter is false or absent, then an invalid display will cause the 'result' output parameter to be 'false', i.e. the validation will fail.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"lenient-display-validation\",
      \"type\": \"boolean\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"When 'true', the server will not perform the additional validation tasks beyond validating membership in the value set (e.g. the server won't check displays, etc.)\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"valueset-membership-only\",
      \"type\": \"boolean\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"If true, the terminology server is required to infer the system from evaluation of the value set definition. The inferSystem parameter is only to be used with the code parameter, and not with the coding nor codeableConcept parameters.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"inferSystem\",
      \"type\": \"boolean\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Specifies a version to use for a system, if the value set does not specify which one to use. The format is the same as a canonical URL: [system]|[version] - e.g. http://loinc.org|2.56. Note that this is a different parameter to systemVersion\",
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
      \"documentation\": \"Specifies a version to use for a valueset, if the reference to the value set does not specify which version to use. The format is the same as a canonical URL: [system]|[version] - e.g. http://example.org/ValueSet/example|1.0.0. Note that this is similar to the force-system-version parameter but applied to valuesets\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"default-valueset-version\",
      \"type\": \"canonical\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Edge Case: Specifies a version to use for a valueset. If a reference to a value set specifies a different version, an error is returned instead of the expansion. The format is the same as a canonical URL: [system]|[version] - e.g. http://example.org/ValueSet/example|1.0.0. Note that this is similar to the force-system-version parameter but applied to valuesets\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"check-valueset-version\",
      \"type\": \"canonical\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Edge Case: Specifies a version to use for a valueset. This parameter overrides any specified version in the reference to the value set (and any it depends on). The format is the same as a canonical URL: [system]|[version] - e.g. http://example.org/ValueSet/example|1.0.0. Note that this has obvious safety issues, in that it may result in a value set expansion giving a different list of codes that is both wrong and unsafe, and implementers should only use this capability reluctantly. It primarily exists to deal with situations where specifications have fallen into decay as time passes. If the value is overridden, the version used SHALL explicitly be represented in the expansion parameters. Note that this is similar to the force-system-version parameter but applied to valuesets.\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"force-valueset-version\",
      \"type\": \"canonical\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Specifies an library that provides expansion rules for the operation. The library has an extension expansionParameters that references a contained Parameters resource that contains additional $expand parameters. See the [CRMI specification description of manifests]https://hl7.org/fhir/uv/crmi/STU1/StructureDefinition-crmi-manifestlibrary.html) and [CRMI expansion rules](https://hl7.org/fhir/uv/crmi/STU1/artifact-terminology-service.html#expansion-rules) for a complete description of how manifest values are used to provide defaults for expansion parameters. Parameters specified directly in an $expand operation override behaviors specified by the manifest parameter.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"manifest\",
      \"targetProfile\": [
        \"http://hl7.org/fhir/StructureDefinition/Library\"
      ],
      \"type\": \"canonical\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"One or more additional resources that are referred to from the value set provided with the $expand or $validate-code invocation. These may be additional value sets or code systems that the client believes will or may be necessary to perform the operation. Resources provided in this fashion are used preferentially to those known to the system, though servers may return an error if these resources are already known to the server (by URL and version) but differ from that information on the server.\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"tx-resource\",
      \"type\": \"Resource\",
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
    },
    {
      \"documentation\": \"The code that was validated\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"code\",
      \"type\": \"code\",
      \"use\": \"out\"
    },
    {
      \"documentation\": \"The system for the code that was validated\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"system\",
      \"type\": \"uri\",
      \"use\": \"out\"
    },
    {
      \"documentation\": \"The version of the system of the code that was validated\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"version\",
      \"type\": \"string\",
      \"use\": \"out\"
    },
    {
      \"documentation\": \"A codeableConcept containing codings for all the validated codes\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"codeableConcept\",
      \"type\": \"CodeableConcept\",
      \"use\": \"out\"
    },
    {
      \"documentation\": \"List of itemised issues with paths constrained to simple FHIRPath. Examples are CodeableConcept, CodeableConcept.coding[0], CodeableConcept.coding[1].display, or Coding.display\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"issues\",
      \"type\": \"OperationOutcome\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 International / Terminology Infrastructure\",
  \"resource\": [
    \"ValueSet\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"active\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p class=\\\"res-header-id\\\">\\n              <b>Generated Narrative: OperationDefinition ValueSet-validate-code</b>\\n            </p>\\n            <a name=\\\"ValueSet-validate-code\\\"> </a>\\n            <a name=\\\"hcValueSet-validate-code\\\"> </a>\\n            <p>URL: [base]/ValueSet/$validate-code</p>\\n            <p>URL: [base]/ValueSet/[id]/$validate-code</p>\\n            <h3>Parameters</h3>\\n\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>url</td>\\n\\n                <td>type</td>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Value set Canonical URL. The server must know the value set (e.g. it is defined explicitly in the server's value sets, or it is defined implicitly by some code system known to the server</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>context</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The context of the value set, so that the server can resolve this to a value set to validate against. The recommended format for this URI is [Structure Definition URL]#[name or path into structure definition] e.g. http://hl7.org/fhir/StructureDefinition/observation-hspc-height-hspcheight#Observation.interpretation. Other forms may be used but are not defined. This form is only usable if the terminology server also has access to the conformance registry that the server is using, but can be used to delegate the mapping from an application context to a binding at run-time</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>valueSet</td>\\n\\n                <td>type</td>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"valueset.html\\\">ValueSet</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The value set is provided directly as part of the request. Servers may choose not to accept value sets in this fashion. This parameter is used when the client wants the server to expand a value set that is not stored on the server</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>valueSetVersion</td>\\n\\n                <td>type</td>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The identifier that is used to identify a specific version of the value set to be used when validating the code. This is an arbitrary value managed by the value set author and is not expected to be globally unique. For example, it might be a timestamp (e.g. yyyymmdd) if a managed version is not available</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>code</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The code that is to be validated. If a code is provided, a system or a context must be provided (if a context is provided, then the server SHALL ensure that the code is not ambiguous without a system)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>system</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The system for the code that is to be validated</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>systemVersion</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The version of the system, if one was provided in the source data. Note that this is a different parameter to system-version</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>display</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The display associated with the code, if provided. If a display is provided a code must be provided. If no display is provided, the server cannot validate the display value, but may choose to return a recommended display name using the display parameter in the outcome. Whether displays are case sensitive is code system dependent</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>coding</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#Coding\\\">Coding</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>A coding to validate</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>codeableConcept</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#CodeableConcept\\\">CodeableConcept</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>A full codeableConcept to validate. The server returns true if one of the coding values is in the value set, and may also validate that the codings are not in conflict with each other if more than one is present</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>date</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#dateTime\\\">dateTime</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The date for which the validation should be checked. Normally, this is the current conditions (which is the default values) but under some circumstances, systems need to validate that a correct code was used at some point in the past. A typical example of this would be where code selection is constrained to the set of codes that were available when the patient was treated, not when the record is being edited. Note that which date is appropriate is a matter for implementation policy.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>abstract</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>If this parameter has a value of true or the parameter is omitted, the client is stating that the validation is being performed in a context where a concept designated as 'abstract' is appropriate/allowed to be used, and the server should regard abstract codes as valid. If this parameter is false, abstract codes are not considered to be valid.</p>\\n\\n                    <p>Note that 'abstract' is a property defined by many HL7 code systems that indicates that the concept is a logical grouping concept that is not intended to be used as a 'concrete' concept to in an actual patient/care/process record. This language is borrowed from object-orientated theory where 'abstract' entities are never instantiated. However in the general record and terminology eco-system, there are many contexts where it is appropriate to use these codes e.g. as decision making criterion, or when editing value sets themselves. This parameter allows a client to indicate to the server that it is working in such a context.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>displayLanguage</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Specifies the language for display validation.  Note: the display value only needs to match 1 displayLanguage in order for the validate operation to return true.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>useSupplement</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The supplement must be used when validating the code. Use of this parameter should result in $validate-code behaving the same way as if the supplements were included in the value set definition using the \\n                      <a href=\\\"https://build.fhir.org/ig/HL7/fhir-extensions/StructureDefinition-valueset-supplement.html\\\">http://hl7.org/fhir/StructureDefinition/valueset-supplement</a>\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>lenient-display-validation</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>When the 'lenient-display-validation' parameter is true, an invalid display string will not cause the 'result' output parameter to be 'false'. If the 'lenient-display-validation' parameter is false or absent, then an invalid display will cause the 'result' output parameter to be 'false', i.e. the validation will fail.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>valueset-membership-only</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>When 'true', the server will not perform the additional validation tasks beyond validating membership in the value set (e.g. the server won't check displays, etc.)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>inferSystem</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>If true, the terminology server is required to infer the system from evaluation of the value set definition. The inferSystem parameter is only to be used with the code parameter, and not with the coding nor codeableConcept parameters.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>system-version</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Specifies a version to use for a system, if the value set does not specify which one to use. The format is the same as a canonical URL: [system]|[version] - e.g. http://loinc.org|2.56. Note that this is a different parameter to systemVersion</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>check-system-version</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Edge Case: Specifies a version to use for a system. If a value set specifies a different version, an error is returned instead of the expansion. The format is the same as a canonical URL: [system]|[version] - e.g. http://loinc.org|2.56</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>default-valueset-version</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Specifies a version to use for a valueset, if the reference to the value set does not specify which version to use. The format is the same as a canonical URL: [system]|[version] - e.g. http://example.org/ValueSet/example|1.0.0. Note that this is similar to the force-system-version parameter but applied to valuesets</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>check-valueset-version</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Edge Case: Specifies a version to use for a valueset. If a reference to a value set specifies a different version, an error is returned instead of the expansion. The format is the same as a canonical URL: [system]|[version] - e.g. http://example.org/ValueSet/example|1.0.0. Note that this is similar to the force-system-version parameter but applied to valuesets</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>force-valueset-version</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Edge Case: Specifies a version to use for a valueset. This parameter overrides any specified version in the reference to the value set (and any it depends on). The format is the same as a canonical URL: [system]|[version] - e.g. http://example.org/ValueSet/example|1.0.0. Note that this has obvious safety issues, in that it may result in a value set expansion giving a different list of codes that is both wrong and unsafe, and implementers should only use this capability reluctantly. It primarily exists to deal with situations where specifications have fallen into decay as time passes. If the value is overridden, the version used SHALL explicitly be represented in the expansion parameters. Note that this is similar to the force-system-version parameter but applied to valuesets.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>manifest</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a> (\\n                  <a href=\\\"library.html\\\" title=\\\"http://hl7.org/fhir/StructureDefinition/Library\\\">Library</a>)\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Specifies an library that provides expansion rules for the operation. The library has an extension expansionParameters that references a contained Parameters resource that contains additional $expand parameters. See the [CRMI specification description of manifests]https://hl7.org/fhir/uv/crmi/STU1/StructureDefinition-crmi-manifestlibrary.html) and \\n                      <a href=\\\"https://hl7.org/fhir/uv/crmi/STU1/artifact-terminology-service.html#expansion-rules\\\">CRMI expansion rules</a> for a complete description of how manifest values are used to provide defaults for expansion parameters. Parameters specified directly in an $expand operation override behaviors specified by the manifest parameter.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>tx-resource</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"resource.html\\\">Resource</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>One or more additional resources that are referred to from the value set provided with the $expand or $validate-code invocation. These may be additional value sets or code systems that the client believes will or may be necessary to perform the operation. Resources provided in this fashion are used preferentially to those known to the system, though servers may return an error if these resources are already known to the server (by URL and version) but differ from that information on the server.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>result</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>True if the concept details supplied are valid</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>message</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Error details, if result = false. If this is provided when result = true, the message carries hints and warnings</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>display</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>A valid display for the concept if the system wishes to display this to a user</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>code</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The code that was validated</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>system</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The system for the code that was validated</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>version</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The version of the system of the code that was validated</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>codeableConcept</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#CodeableConcept\\\">CodeableConcept</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>A codeableConcept containing codings for all the validated codes</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>issues</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"operationoutcome.html\\\">OperationOutcome</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>List of itemised issues with paths constrained to simple FHIRPath. Examples are CodeableConcept, CodeableConcept.coding[0], CodeableConcept.coding[1].display, or Coding.display</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n\\n            <div>\\n              <p>Note: the correct behavior of validation with regard to language for Coding.display items is currently undefined, and further development and testing may lead to specific requirements or recommendations in subsequent releases</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"generated\"
  },
  \"title\": \"Value Set based Validation\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/ValueSet-validate-code\",
  \"version\": \"6.0.0-ballot4\"
}"))
(define (ValueSet-validate-code-operation handler)
  (define code "validate-code")
  (list (operation-entry 'type code "ValueSet" handler)
        (operation-entry 'instance code "ValueSet" handler)))
(define validate-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
  \"code\": \"validate\",
  \"comment\": \"This operation may be used during design and development to validate application design. It can also be used at run-time. One possible use might be that a client asks the server whether a proposed update is valid as the user is editing a dialog and displays an updated error to the user. The operation can be used as part of a light-weight two phase commit protocol but there is no expectation that the server will hold the content of the resource after this operation is used, or that the server guarantees to successfully perform an actual create, update or delete after the validation operation completes.\\n\\nThis operation returns a 200 Ok provided that it was possible to perform validation, irrespective of whether validation issues were found.  However, it is possible that certain errors in the validated content (e.g. invalid character set, broken JSON, etc.) may cause the overall validation operation to fail with a 4xx or 5xx series response.\\n\\nNote: the correct behavior of validation with regard to language (especially for Coding.display) is currently undefined, and further development and testing may lead to specific requirements or recommendations in subsequent releases\\n\\nFuture versions of this specifcation may add additional validation parameters. A candidate list is maintained with the [FHIR Validator Documentation](https://confluence.hl7.org/display/FHIR/Using+the+FHIR+Validator)\",
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
    },
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://www.hl7.org/Special/committees/fiwg\"
        }
      ]
    }
  ],
  \"date\": \"2026-05-28T22:17:06+00:00\",
  \"description\": \"The validate operation checks whether the attached content would be acceptable either generally, as a create, an update or as a delete to an existing resource.  The action the server takes depends on the mode parameter:  \\n\\n* [mode not provided]: The server checks the content of the resource against any schema, constraint rules, and other general terminology rules \\n* create: The server checks the content, and then checks that the content would be acceptable as a create (e.g. that the content would not violate any uniqueness constraints) \\n* update: The server checks the content, and then checks that it would accept it as an update against the nominated specific resource (e.g. that there are no changes to immutable fields the server does not allow to change, and checking version integrity if appropriate) \\n* delete: The server ignores the content, and checks that the nominated resource is allowed to be deleted (e.g. checking referential integrity rules)  \\n\\nModes update and delete can only be used when the operation is invoked at the resource instance level.   The return from this operation is an [OperationOutcome](operationoutcome.html)\\n\\nNote that this operation is not the only way to validate resources - see [Validating Resources](validation.html) for further information.\",
  \"experimental\": false,
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
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-wg\",
      \"valueCode\": \"fhir\"
    }
  ],
  \"id\": \"Resource-validate\",
  \"instance\": true,
  \"jurisdiction\": [
    {
      \"coding\": [
        {
          \"code\": \"001\",
          \"display\": \"World\",
          \"system\": \"http://unstats.un.org/unsd/methods/m49/m49.htm\"
        }
      ]
    }
  ],
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2026-05-28T22:17:06.960+00:00\"
  },
  \"name\": \"Validate\",
  \"parameter\": [
    {
      \"documentation\": \"Must be present unless the mode is \\\"delete\\\" or the operation is invoked at the instance level\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"resource\",
      \"type\": \"Resource\",
      \"use\": \"in\"
    },
    {
      \"binding\": {
        \"extension\": [
          {
            \"url\": \"http://hl7.org/fhir/StructureDefinition/elementdefinition-bindingName\",
            \"valueString\": \"ResourceValidationMode\"
          }
        ],
        \"strength\": \"required\",
        \"valueSet\": \"http://hl7.org/fhir/ValueSet/resource-validation-mode|6.0.0-ballot4\"
      },
      \"documentation\": \"Default is 'no action'; (e.g. general validation). If the mode is `create`, the operation cannot be invoked on a particular resource.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"mode\",
      \"type\": \"code\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"If this is nominated, then the resource is validated against this specific profile. If a profile is nominated, and the server cannot validate against the nominated profile, it SHALL return an error. The profile parameter is required for mode=profile, and may be present in other modes\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"profile\",
      \"targetProfile\": [
        \"http://hl7.org/fhir/StructureDefinition/StructureDefinition\"
      ],
      \"type\": \"canonical\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Indicates that the referenced resource should be treated as the 'root' as the specified graph, validating all references for the resource to ensure they follow the rules. This parameter is not widely supported.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"graph\",
      \"targetProfile\": [
        \"http://hl7.org/fhir/StructureDefinition/GraphDefinition\"
      ],
      \"type\": \"canonical\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Indicates an implementation context that applies to this validation.  Influences which [additionalBindings](terminologies.html#binding) are relevant.  NOTE: Expectations around subsumption testing, etc. are not yet defined and may be server-specific.\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"usageContext\",
      \"type\": \"UsageContext\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"One or more language codes (W3C Language tags, with sub-tags). This has the same format as the HTTP accept header, and defaults to the value of the header\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"language\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"binding\": {
        \"strength\": \"extensible\",
        \"valueSet\": \"http://terminology.hl7.org/ValueSet/jurisdiction\"
      },
      \"documentation\": \"The jurisdiction is used for validating in some profiles where country specific bindings are defined. The default jurisdiction is at the discretion of the server. If you want to specify No jurisdiction, this is functionally equivalent to a jurisdiction of the 'the whole world', which is jurisdiction=uv\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"jurisdiction\",
      \"type\": \"code\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"In some cases (e.g. when creating examples for implementation guides or when checking for potential interoperability issues with a new communication partner), it can be useful to know when data elements are present in an instance when those elements are not `mustSupport` in the profile(s) the instance is being validated against. Identifying situations where this occurs might drive a change to the profile or cause a designer to drop an element from the instance. In other cases, the presence of the element can be fine and the information message ignored.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"hintAboutNonMustSupport\",
      \"type\": \"boolean\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The extension parameter controls how extensions are validated. It allows extensions from the specified domain (by matching the URL for the extension), and also has the special values 'any' and 'none'. It is up to the server to choose default settings for this parameter\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"extension\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Whether to validate the questionnaire in QuestionnaireResponse. Values: `none` - ignore, `check` - validate if a questionnaire is specified, and `require` - a questionnaire must be specified, and will be checked.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"questionnaire\",
      \"type\": \"code\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"When the validator encounters a code that is not part of an extensible binding, add a warning to suggest that the code be reviewed. This turns the warning on or off. It's up to the server to decide what the default is.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"extensible-binding-warnings\",
      \"type\": \"boolean\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Whether it's an error or just a warning when the validator encounters a coding or CodeableConcept where the display value isn't consistent with the display(s) defined by the code systems. It's up to the server to decide what the default is.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"display-issues-are-warnings\",
      \"type\": \"boolean\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Whether it's an error or just a warning when the validator encounters a unknown CodeSystem. It's up to the server to decide what the default is.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"unknown-codesystems-cause-errors\",
      \"type\": \"boolean\",
      \"use\": \"in\"
    },
    {
      \"binding\": {
        \"strength\": \"required\",
        \"valueSet\": \"http://hl7.org/fhir/ValueSet/issue-severity|6.0.0-ballot4\"
      },
      \"documentation\": \"The minimum level to report issues - e.g. ignore hints and warnings. By default, all issues are returned\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"level\",
      \"type\": \"code\",
      \"use\": \"in\"
    },
    {
      \"binding\": {
        \"strength\": \"required\",
        \"valueSet\": \"http://hl7.org/fhir/ValueSet/issue-severity|6.0.0-ballot4\"
      },
      \"documentation\": \"The level to treat best-practice invariants etc as. By default these are treated as warnings\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"best-practice\",
      \"type\": \"code\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"If this is true, additional bindings marked as 'current' will also be enforced\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"current\",
      \"type\": \"boolean\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"If this is true, additional validation regarding suitability for 'publishing' are also enforced. Note that HL7 defines a set of rules, but the meaning and use of 'publishing' is at the discretion of the server.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"forPublication\",
      \"type\": \"boolean\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"What to do when HTML is found in markdown fields. Values = ignore, warning, and error. It's server discretion what the default is, and servers may choose to ignore turning this off (for security consideration reasons)\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"html-in-markdown\",
      \"type\": \"code\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Whether the existence of hidden bidi control characters is treated as a warning or an error. See [CVE-2021-42574](https://nvd.nist.gov/vuln/detail/CVE-2021-42574).  Server discretion for the default value, and servers can ignore this setting.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"no_unicode_bidi_control_chars\",
      \"type\": \"boolean\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Turns on verbose output, which servers may use to provide explanation of the validation process (e.g. slicing decisions).\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"verbose-mode\",
      \"type\": \"boolean\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Allow references in resources to refer to example.org, which are understood to be example URLs. Server discretion for the default value\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"allow-example-urls\",
      \"type\": \"boolean\",
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
  \"publisher\": \"HL7 International / FHIR Infrastructure\",
  \"resource\": [
    \"Resource\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"active\",
  \"system\": true,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p class=\\\"res-header-id\\\">\\n              <b>Generated Narrative: OperationDefinition Resource-validate</b>\\n            </p>\\n            <a name=\\\"Resource-validate\\\"> </a>\\n            <a name=\\\"hcResource-validate\\\"> </a>\\n            <p>URL: [base]/$validate</p>\\n            <p>URL: [base]/Resource/$validate</p>\\n            <p>URL: [base]/Resource/[id]/$validate</p>\\n            <h3>Parameters</h3>\\n\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>resource</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"resource.html\\\">Resource</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Must be present unless the mode is &quot;delete&quot; or the operation is invoked at the instance level</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>mode</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n\\n                <td>\\n                  <a href=\\\"valueset-resource-validation-mode.html\\\">Resource Validation Mode</a> (Required)\\n                </td>\\n\\n                <td>\\n                  <div>\\n                    <p>Default is 'no action'; (e.g. general validation). If the mode is \\n                      <code>create</code>, the operation cannot be invoked on a particular resource.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>profile</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a> (\\n                  <a href=\\\"structuredefinition.html\\\" title=\\\"http://hl7.org/fhir/StructureDefinition/StructureDefinition\\\">StructureDefinition</a>)\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>If this is nominated, then the resource is validated against this specific profile. If a profile is nominated, and the server cannot validate against the nominated profile, it SHALL return an error. The profile parameter is required for mode=profile, and may be present in other modes</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>graph</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a> (\\n                  <code>http://hl7.org/fhir/StructureDefinition/GraphDefinition</code>)\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Indicates that the referenced resource should be treated as the 'root' as the specified graph, validating all references for the resource to ensure they follow the rules. This parameter is not widely supported.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>usageContext</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"metadatatypes.html#UsageContext\\\">UsageContext</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Indicates an implementation context that applies to this validation.  Influences which \\n                      <a href=\\\"terminologies.html#binding\\\">additionalBindings</a> are relevant.  NOTE: Expectations around subsumption testing, etc. are not yet defined and may be server-specific.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>language</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>One or more language codes (W3C Language tags, with sub-tags). This has the same format as the HTTP accept header, and defaults to the value of the header</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>jurisdiction</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n\\n                <td>\\n                  <a href=\\\"http://terminology.hl7.org/7.1.0/ValueSet-jurisdiction.html\\\">Jurisdiction ValueSet</a> (Extensible)\\n                </td>\\n\\n                <td>\\n                  <div>\\n                    <p>The jurisdiction is used for validating in some profiles where country specific bindings are defined. The default jurisdiction is at the discretion of the server. If you want to specify No jurisdiction, this is functionally equivalent to a jurisdiction of the 'the whole world', which is jurisdiction=uv</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>hintAboutNonMustSupport</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>In some cases (e.g. when creating examples for implementation guides or when checking for potential interoperability issues with a new communication partner), it can be useful to know when data elements are present in an instance when those elements are not \\n                      <code>mustSupport</code> in the profile(s) the instance is being validated against. Identifying situations where this occurs might drive a change to the profile or cause a designer to drop an element from the instance. In other cases, the presence of the element can be fine and the information message ignored.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>extension</td>\\n\\n                <td/>\\n\\n                <td>0..*</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>The extension parameter controls how extensions are validated. It allows extensions from the specified domain (by matching the URL for the extension), and also has the special values 'any' and 'none'. It is up to the server to choose default settings for this parameter</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>questionnaire</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Whether to validate the questionnaire in QuestionnaireResponse. Values: \\n                      <code>none</code> - ignore, \\n                      <code>check</code> - validate if a questionnaire is specified, and \\n                      <code>require</code> - a questionnaire must be specified, and will be checked.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>extensible-binding-warnings</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>When the validator encounters a code that is not part of an extensible binding, add a warning to suggest that the code be reviewed. This turns the warning on or off. It's up to the server to decide what the default is.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>display-issues-are-warnings</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Whether it's an error or just a warning when the validator encounters a coding or CodeableConcept where the display value isn't consistent with the display(s) defined by the code systems. It's up to the server to decide what the default is.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>unknown-codesystems-cause-errors</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Whether it's an error or just a warning when the validator encounters a unknown CodeSystem. It's up to the server to decide what the default is.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>level</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n\\n                <td>\\n                  <a href=\\\"valueset-issue-severity.html\\\">Issue Severity</a> (Required)\\n                </td>\\n\\n                <td>\\n                  <div>\\n                    <p>The minimum level to report issues - e.g. ignore hints and warnings. By default, all issues are returned</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>best-practice</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n\\n                <td>\\n                  <a href=\\\"valueset-issue-severity.html\\\">Issue Severity</a> (Required)\\n                </td>\\n\\n                <td>\\n                  <div>\\n                    <p>The level to treat best-practice invariants etc as. By default these are treated as warnings</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>current</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>If this is true, additional bindings marked as 'current' will also be enforced</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>forPublication</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>If this is true, additional validation regarding suitability for 'publishing' are also enforced. Note that HL7 defines a set of rules, but the meaning and use of 'publishing' is at the discretion of the server.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>html-in-markdown</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>What to do when HTML is found in markdown fields. Values = ignore, warning, and error. It's server discretion what the default is, and servers may choose to ignore turning this off (for security consideration reasons)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>no_unicode_bidi_control_chars</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Whether the existence of hidden bidi control characters is treated as a warning or an error. See \\n                      <a href=\\\"https://nvd.nist.gov/vuln/detail/CVE-2021-42574\\\">CVE-2021-42574</a>.  Server discretion for the default value, and servers can ignore this setting.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>verbose-mode</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Turns on verbose output, which servers may use to provide explanation of the validation process (e.g. slicing decisions).</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>IN</td>\\n\\n                <td>allow-example-urls</td>\\n\\n                <td/>\\n\\n                <td>0..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>Allow references in resources to refer to example.org, which are understood to be example URLs. Server discretion for the default value</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>return</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"operationoutcome.html\\\">OperationOutcome</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>If the operation outcome does not list any errors, and a mode was specified, then this is an indication that the operation would be expected to succeed (excepting for transactional integrity issues, see below)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n\\n            <div>\\n              <p>This operation may be used during design and development to validate application design. It can also be used at run-time. One possible use might be that a client asks the server whether a proposed update is valid as the user is editing a dialog and displays an updated error to the user. The operation can be used as part of a light-weight two phase commit protocol but there is no expectation that the server will hold the content of the resource after this operation is used, or that the server guarantees to successfully perform an actual create, update or delete after the validation operation completes.</p>\\n\\n              <p>This operation returns a 200 Ok provided that it was possible to perform validation, irrespective of whether validation issues were found.  However, it is possible that certain errors in the validated content (e.g. invalid character set, broken JSON, etc.) may cause the overall validation operation to fail with a 4xx or 5xx series response.</p>\\n\\n              <p>Note: the correct behavior of validation with regard to language (especially for Coding.display) is currently undefined, and further development and testing may lead to specific requirements or recommendations in subsequent releases</p>\\n\\n              <p>Future versions of this specifcation may add additional validation parameters. A candidate list is maintained with the \\n                <a href=\\\"https://confluence.hl7.org/display/FHIR/Using+the+FHIR+Validator\\\">FHIR Validator Documentation</a>\\n              </p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"generated\"
  },
  \"title\": \"Validate a resource\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Resource-validate\",
  \"version\": \"6.0.0-ballot4\"
}"))
(define (validate-operation handler)
  (define code "validate")
  (list (operation-entry 'system code #f handler)
        (operation-entry 'type code "Resource" handler)
        (operation-entry 'instance code "Resource" handler)))
(define versions-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
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
    },
    {
      \"telecom\": [
        {
          \"system\": \"url\",
          \"value\": \"http://www.hl7.org/Special/committees/fiwg\"
        }
      ]
    }
  ],
  \"date\": \"2026-05-28T22:17:06+00:00\",
  \"description\": \"Using the [FHIR Version Mime Type Parameter](http.html#version-parameter), a server can support [multiple versions on the same end-point](versioning.html#mt-version). The only way for client to find out what versions a server supports in this fashion is the $versions operation. The client invokes the operation with no parameters. and the server returns the list of supported versions, along with the default version it will use if no fhirVersion parameter is present\",
  \"experimental\": false,
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
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-wg\",
      \"valueCode\": \"fhir\"
    }
  ],
  \"id\": \"CapabilityStatement-versions\",
  \"instance\": false,
  \"jurisdiction\": [
    {
      \"coding\": [
        {
          \"code\": \"001\",
          \"display\": \"World\",
          \"system\": \"http://unstats.un.org/unsd/methods/m49/m49.htm\"
        }
      ]
    }
  ],
  \"kind\": \"operation\",
  \"meta\": {
    \"lastUpdated\": \"2026-05-28T22:17:06.960+00:00\"
  },
  \"name\": \"Versions\",
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
      \"binding\": {
        \"strength\": \"required\",
        \"valueSet\": \"http://hl7.org/fhir/ValueSet/FHIR-version|6.0.0-ballot4\"
      },
      \"documentation\": \"The default version for the server. Use the major.minor version like 3.0\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"default\",
      \"type\": \"code\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 International / FHIR Infrastructure\",
  \"resource\": [
    \"CapabilityStatement\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"active\",
  \"system\": true,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p class=\\\"res-header-id\\\">\\n              <b>Generated Narrative: OperationDefinition CapabilityStatement-versions</b>\\n            </p>\\n            <a name=\\\"CapabilityStatement-versions\\\"> </a>\\n            <a name=\\\"hcCapabilityStatement-versions\\\"> </a>\\n            <p>URL: [base]/$versions</p>\\n            <h3>Parameters</h3>\\n\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>version</td>\\n\\n                <td/>\\n\\n                <td>1..*</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n\\n                <td/>\\n\\n                <td>\\n                  <div>\\n                    <p>A version supported by the server. Use the major.minor version like 3.0</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n\\n              <tr>\\n                <td>OUT</td>\\n\\n                <td>default</td>\\n\\n                <td/>\\n\\n                <td>1..1</td>\\n\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n\\n                <td>\\n                  <a href=\\\"valueset-FHIR-version.html\\\">FHIRVersion</a> (Required)\\n                </td>\\n\\n                <td>\\n                  <div>\\n                    <p>The default version for the server. Use the major.minor version like 3.0</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n          </div>\",
    \"status\": \"generated\"
  },
  \"title\": \"Discover what versions a server supports\",
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/CapabilityStatement-versions\",
  \"version\": \"6.0.0-ballot4\"
}"))
(define (versions-operation handler)
  (define code "versions")
  (list (operation-entry 'system code #f handler)))
(define operation-definitions
  (list ActivityDefinition-apply-definition PlanDefinition-apply-definition care-gaps-definition collect-data-definition convert-definition current-canonical-definition ActivityDefinition-data-requirements-definition Library-data-requirements-definition Measure-data-requirements-definition PlanDefinition-data-requirements-definition docref-definition document-definition evaluate-measure-definition evaluate-definition events-definition Group-everything-definition MedicinalProductDefinition-everything-definition example-query-high-risk-definition expand-definition graphql-definition lastn-definition lookup-definition match-definition populate-definition preferred-id-definition process-message-definition Group-purge-definition Patient-purge-definition snapshot-definition stats-definition status-definition submit-data-definition Claim-submit-definition CoverageEligibilityRequest-submit-definition subsumes-definition transform-definition translate-id-definition translate-definition CodeSystem-validate-code-definition ValueSet-validate-code-definition validate-definition versions-definition))
