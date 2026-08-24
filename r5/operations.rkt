#lang racket/base
;;; GENERATED — DO NOT EDIT (verified by raco fhir check).
;; The package's OperationDefinitions as data + scaffold constructors: each
;; <code>-operation takes ONLY the handler `(in req) -> node` and yields the
;; operation-entry list for build-app's #:operations (levels/targets from the OD).
(require json (only-in fhir/capability/runtime operation-entry))
(provide operation-definitions
         add-definition add-operation
         ActivityDefinition-apply-definition ActivityDefinition-apply-operation
         ChargeItemDefinition-apply-definition ChargeItemDefinition-apply-operation
         PlanDefinition-apply-definition PlanDefinition-apply-operation
         SpecimenDefinition-apply-definition SpecimenDefinition-apply-operation
         care-gaps-definition care-gaps-operation
         closure-definition closure-operation
         collect-data-definition collect-data-operation
         conforms-definition conforms-operation
         convert-definition convert-operation
         current-canonical-definition current-canonical-operation
         ActivityDefinition-data-requirements-definition ActivityDefinition-data-requirements-operation
         Library-data-requirements-definition Library-data-requirements-operation
         Measure-data-requirements-definition Measure-data-requirements-operation
         PlanDefinition-data-requirements-definition PlanDefinition-data-requirements-operation
         docref-definition docref-operation
         document-definition document-operation
         evaluate-measure-definition evaluate-measure-operation
         events-definition events-operation
         Encounter-everything-definition Encounter-everything-operation
         EpisodeOfCare-everything-definition EpisodeOfCare-everything-operation
         Group-everything-definition Group-everything-operation
         MedicinalProductDefinition-everything-definition MedicinalProductDefinition-everything-operation
         Patient-everything-definition Patient-everything-operation
         example-query-high-risk-definition example-query-high-risk-operation
         expand-definition expand-operation
         filter-definition filter-operation
         find-matches-definition find-matches-operation
         find-definition find-operation
         generate-definition generate-operation
         get-ws-binding-token-definition get-ws-binding-token-operation
         graph-definition graph-operation
         graphql-definition graphql-operation
         implements-definition implements-operation
         lastn-definition lastn-operation
         lookup-definition lookup-operation
         match-definition match-operation
         merge-definition merge-operation
         meta-add-definition meta-add-operation
         meta-delete-definition meta-delete-operation
         meta-definition meta-operation
         populate-definition populate-operation
         preferred-id-definition preferred-id-operation
         process-message-definition process-message-operation
         questionnaire-definition questionnaire-operation
         remove-definition remove-operation
         snapshot-definition snapshot-operation
         stats-definition stats-operation
         status-definition status-operation
         submit-data-definition submit-data-operation
         Claim-submit-definition Claim-submit-operation
         CoverageEligibilityRequest-submit-definition CoverageEligibilityRequest-submit-operation
         subset-definition subset-operation
         subsumes-definition subsumes-operation
         transform-definition transform-operation
         translate-id-definition translate-id-operation
         translate-definition translate-operation
         CodeSystem-validate-code-definition CodeSystem-validate-code-operation
         ValueSet-validate-code-definition ValueSet-validate-code-operation
         validate-definition validate-operation
         versions-definition versions-operation)
(define add-definition
  (string->jsexpr
   "{
  \"affectsState\": true,
  \"code\": \"add\",
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
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"Add content to an array in a large resource such as List or Group. See [Operations for Large Resources](operations-for-large-resources.html).\",
  \"experimental\": false,
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
  \"id\": \"Resource-add\",
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
  },
  \"name\": \"Add\",
  \"parameter\": [
    {
      \"documentation\": \"Resource containing content to add. See [Operations for Large Resources](operations-for-large-resources.html).\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"additions\",
      \"type\": \"Resource\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Resource containing content added. See [Operations for Large Resources](operations-for-large-resources.html).\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"return\",
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
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/Resource/[id]/$add</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>additions</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"resource.html\\\">Resource</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Resource containing content to add. See \\n                      <a href=\\\"operations-for-large-resources.html\\\">Operations for Large Resources</a>.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>return</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"resource.html\\\">Resource</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Resource containing content added. See \\n                      <a href=\\\"operations-for-large-resources.html\\\">Operations for Large Resources</a>.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Add to an array in a large resource\",
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Resource-add\",
  \"version\": \"5.0.0\"
}"))
(define (add-operation handler)
  (define code "add")
  (list (operation-entry 'instance code "Resource" handler)))
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
    }
  ],
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"The apply operation applies a definition in a specific context\",
  \"experimental\": false,
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
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
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"ActivityDefinition\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/ActivityDefinition/$apply</p>\\n            <p>URL: [base]/ActivityDefinition/[id]/$apply</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>activityDefinition</td>\\n                <td>type</td>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"activitydefinition.html\\\">ActivityDefinition</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The activity definition to apply. If the operation is invoked on an instance, this parameter is not allowed. If the operation is invoked at the type level, this parameter is required</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>subject</td>\\n                <td/>\\n                <td>1..*</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                  <br/>(\\n                  <a href=\\\"search.html#reference\\\">reference</a>)\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The subject(s) that is/are the target of the activity definition to be applied. The subject may be a Patient, Practitioner, Organization, Location, Device, or Group. Subjects provided in this parameter will be resolved as the subject of the PlanDefinition based on the type of the subject. If multiple subjects of the same type are provided, the behavior is implementation-defined</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>encounter</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                  <br/>(\\n                  <a href=\\\"search.html#reference\\\">reference</a>)\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The encounter in context, if any</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>practitioner</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                  <br/>(\\n                  <a href=\\\"search.html#reference\\\">reference</a>)\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The practitioner in context</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>organization</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                  <br/>(\\n                  <a href=\\\"search.html#reference\\\">reference</a>)\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The organization in context</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>userType</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#CodeableConcept\\\">CodeableConcept</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The type of user initiating the request, e.g. patient, healthcare provider, or specific type of healthcare provider (physician, nurse, etc.)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>userLanguage</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#CodeableConcept\\\">CodeableConcept</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Preferred language of the person using the system</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>userTaskContext</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#CodeableConcept\\\">CodeableConcept</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The task the system user is performing, e.g. laboratory results review, medication list review, etc. This information can be used to tailor decision support outputs, such as recommended information resources</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>setting</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#CodeableConcept\\\">CodeableConcept</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The current setting of the request (inpatient, outpatient, etc.)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>settingContext</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#CodeableConcept\\\">CodeableConcept</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Additional detail about the setting of the request, if any</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>return</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"resource.html\\\">Resource</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The resource that is the result of applying the definition</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n            <div>\\n              <p>The result of invoking this operation is a resource of the type specified by the activity definition, with all the definitions resolved as appropriate for the type of resource. Any dynamicValue elements will be evaluated (in the order in which they appear in the resource) and the results applied to the returned resource.  If the ActivityDefinition includes library references, those libraries will be available to the evaluated expressions. If those libraries have parameters, those parameters will be bound by name to the parameters given to the operation. In addition, parameters to the $apply operation are available within dynamicValue expressions as context variables, accessible by the name of the parameter, prefixed with a percent (%) symbol. For a more detailed description, refer to the ActivityDefinition resource. Note that result of this operation is transient (i.e. none of the resources created by the operation are persisted in the server, they are all returned as contained resources in the result). The result effectively represents a proposed set of activities, and it is up to the caller to determine whether and how those activities are actually carried out.</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Apply\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/ActivityDefinition-apply\",
  \"version\": \"5.0.0\"
}"))
(define (ActivityDefinition-apply-operation handler)
  (define code "apply")
  (list (operation-entry 'type code "ActivityDefinition" handler)
        (operation-entry 'instance code "ActivityDefinition" handler)))
(define ChargeItemDefinition-apply-definition
  (string->jsexpr
   "{
  \"affectsState\": true,
  \"code\": \"apply\",
  \"comment\": \"The result of invoking this operation is a resource of the type specified by the activity definition, with all the definitions resolved as appropriate for the type of resource. Any dynamicValue elements will be evaluated (in the order in which they appear in the resource) and the results applied to the returned resource.  If the ChargetItemDefinition includes library references, those libraries will be available to the evaluated expressions. If those libraries have parameters, those parameters will be bound by name to the parameters given to the operation. For a more detailed description, refer to the ChargetItemDefinition resource\",
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
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"The apply operation applies a definition in a specific context\",
  \"experimental\": false,
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
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
      \"type\": \"Resource\",
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
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/ChargeItemDefinition/[id]/$apply</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>chargeItem</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"references.html#Reference\\\">Reference</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The ChargeItem on which the definition is to ba applies</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>account</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"references.html#Reference\\\">Reference</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The account in context, if any</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>return</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"resource.html\\\">Resource</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The resource that is the result of applying the definition</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n            <div>\\n              <p>The result of invoking this operation is a resource of the type specified by the activity definition, with all the definitions resolved as appropriate for the type of resource. Any dynamicValue elements will be evaluated (in the order in which they appear in the resource) and the results applied to the returned resource.  If the ChargetItemDefinition includes library references, those libraries will be available to the evaluated expressions. If those libraries have parameters, those parameters will be bound by name to the parameters given to the operation. For a more detailed description, refer to the ChargetItemDefinition resource</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Apply\",
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/ChargeItemDefinition-apply\",
  \"version\": \"5.0.0\"
}"))
(define (ChargeItemDefinition-apply-operation handler)
  (define code "apply")
  (list (operation-entry 'instance code "ChargeItemDefinition" handler)))
(define PlanDefinition-apply-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
  \"code\": \"apply\",
  \"comment\": \"The result of this operation is a Bundle for each subject, where the Bundle contains as its first entry a RequestOrchestration that is the direct result of applying the PlanDefinition to that subject, and any subsequent entries in the Bundle are resources that were created or updated as part of that process. The RequestOrchestration will have actions for each of the applicable actions in the plan based on evaluating the applicability condition in context. For each applicable action, the definition is applied as described in the $apply operation of the ActivityDefinition resource, and the resulting resource is added as an entry to the Bundle. If the ActivityDefinition includes library references, those libraries will be available to the evaluated expressions. If those libraries have parameters, those parameters will be bound by name to the parameters given to the operation. In addition, parameters to the $apply operation are available within dynamicValue expressions as context variables, accessible by the name of the parameter, prefixed with a percent (%) symbol. For a more detailed description, refer to the PlanDefinition and ActivityDefinition resource documentation. Note that result of this operation is transient (i.e. none of the resources created by the operation are persisted in the server, they are all returned as entries in the result Bundle(s)). The result effectively represents a proposed set of activities, and it is up to the caller to determine whether and how those activities are actually carried out and/or persisted.\",
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
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"The apply operation applies a PlanDefinition to a given subject\",
  \"experimental\": false,
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
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
      \"documentation\": \"A Bundle for each input subject that is the result of applying the plan definition to that subject\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"return\",
      \"type\": \"Bundle\",
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
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/PlanDefinition/$apply</p>\\n            <p>URL: [base]/PlanDefinition/[id]/$apply</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>planDefinition</td>\\n                <td>type</td>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"plandefinition.html\\\">PlanDefinition</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The plan definition to be applied. If the operation is invoked at the instance level, this parameter is not allowed; if the operation is invoked at the type level, this parameter is required, or a url (and optionally version) must be supplied</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>url</td>\\n                <td>type</td>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The url of the plan definition to be applied. If the operation is invoked at the instance level, this parameter is not allowed; if the operation is invoked at the type level, this parameter (and optionally the version), or the planDefinition parameter must be supplied</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>version</td>\\n                <td>type</td>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The version of the plan definition to be applied. If the operation is invoked at the instance level, this parameter is not allowed; if the operation is invoked at the type level, this parameter may only be used if the url parameter is supplied.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>subject</td>\\n                <td/>\\n                <td>1..*</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                  <br/>(\\n                  <a href=\\\"search.html#reference\\\">reference</a>)\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The subject(s) that is/are the target of the plan to be applied. The subject may be a Patient, Practitioner, Organization, Location, Device, or Group. Subjects provided in this parameter will be resolved as the subject of the PlanDefinition based on the type of the subject. If multiple subjects of the same type are provided, the behavior is implementation-defined</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>encounter</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                  <br/>(\\n                  <a href=\\\"search.html#reference\\\">reference</a>)\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The encounter in context, if any</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>practitioner</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                  <br/>(\\n                  <a href=\\\"search.html#reference\\\">reference</a>)\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The practitioner applying the plan definition</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>organization</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                  <br/>(\\n                  <a href=\\\"search.html#reference\\\">reference</a>)\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The organization applying the plan definition</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>userType</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#CodeableConcept\\\">CodeableConcept</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The type of user initiating the request, e.g. patient, healthcare provider, or specific type of healthcare provider (physician, nurse, etc.)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>userLanguage</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#CodeableConcept\\\">CodeableConcept</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Preferred language of the person using the system</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>userTaskContext</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#CodeableConcept\\\">CodeableConcept</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The task the system user is performing, e.g. laboratory results review, medication list review, etc. This information can be used to tailor decision support outputs, such as recommended information resources</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>setting</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#CodeableConcept\\\">CodeableConcept</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The current setting of the request (inpatient, outpatient, etc.)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>settingContext</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#CodeableConcept\\\">CodeableConcept</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Additional detail about the setting of the request, if any</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>return</td>\\n                <td/>\\n                <td>0..*</td>\\n                <td>\\n                  <a href=\\\"bundle.html\\\">Bundle</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>A Bundle for each input subject that is the result of applying the plan definition to that subject</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n            <div>\\n              <p>The result of this operation is a Bundle for each subject, where the Bundle contains as its first entry a RequestOrchestration that is the direct result of applying the PlanDefinition to that subject, and any subsequent entries in the Bundle are resources that were created or updated as part of that process. The RequestOrchestration will have actions for each of the applicable actions in the plan based on evaluating the applicability condition in context. For each applicable action, the definition is applied as described in the $apply operation of the ActivityDefinition resource, and the resulting resource is added as an entry to the Bundle. If the ActivityDefinition includes library references, those libraries will be available to the evaluated expressions. If those libraries have parameters, those parameters will be bound by name to the parameters given to the operation. In addition, parameters to the $apply operation are available within dynamicValue expressions as context variables, accessible by the name of the parameter, prefixed with a percent (%) symbol. For a more detailed description, refer to the PlanDefinition and ActivityDefinition resource documentation. Note that result of this operation is transient (i.e. none of the resources created by the operation are persisted in the server, they are all returned as entries in the result Bundle(s)). The result effectively represents a proposed set of activities, and it is up to the caller to determine whether and how those activities are actually carried out and/or persisted.</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Apply\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/PlanDefinition-apply\",
  \"version\": \"5.0.0\"
}"))
(define (PlanDefinition-apply-operation handler)
  (define code "apply")
  (list (operation-entry 'type code "PlanDefinition" handler)
        (operation-entry 'instance code "PlanDefinition" handler)))
(define SpecimenDefinition-apply-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
  \"code\": \"apply\",
  \"comment\": \"The result of this operation is a Specimen resource based on the definition of the specimen as described in the SpecimenDefinition resource and the supplied parameters.\",
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
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"The apply operation applies a SpecimenDefinition in a given context to create a Specimen resource instance\",
  \"experimental\": false,
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
  \"id\": \"SpecimenDefinition-apply\",
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
  },
  \"name\": \"Apply\",
  \"parameter\": [
    {
      \"documentation\": \"The specimen definition to be applied. If the operation is invoked at the instance level, this parameter is not allowed; if the operation is invoked at the type level, this parameter is required\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"specimenDefinition\",
      \"scope\": [
        \"type\"
      ],
      \"type\": \"SpecimenDefinition\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The subject(s) that is/are the target of the Specimen instance to be created. The subject may be a Patient, Group, Device, Substance or Location. Subjects provided in this parameter will be resolved as the subject of the Specimen based on the type of the subject. If multiple subjects of the same type are provided, the behavior is implementation-defined\",
      \"max\": \"*\",
      \"min\": 1,
      \"name\": \"subject\",
      \"searchType\": \"reference\",
      \"type\": \"string\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The practitioner (or practitioner role) that is collecting the specimen\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"collector\",
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
      \"documentation\": \"The Specimen resource that is the result of applying the specimen definition\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"return\",
      \"type\": \"Specimen\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"SpecimenDefinition\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/SpecimenDefinition/$apply</p>\\n            <p>URL: [base]/SpecimenDefinition/[id]/$apply</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>specimenDefinition</td>\\n                <td>type</td>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"specimendefinition.html\\\">SpecimenDefinition</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The specimen definition to be applied. If the operation is invoked at the instance level, this parameter is not allowed; if the operation is invoked at the type level, this parameter is required</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>subject</td>\\n                <td/>\\n                <td>1..*</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                  <br/>(\\n                  <a href=\\\"search.html#reference\\\">reference</a>)\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The subject(s) that is/are the target of the Specimen instance to be created. The subject may be a Patient, Group, Device, Substance or Location. Subjects provided in this parameter will be resolved as the subject of the Specimen based on the type of the subject. If multiple subjects of the same type are provided, the behavior is implementation-defined</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>collector</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                  <br/>(\\n                  <a href=\\\"search.html#reference\\\">reference</a>)\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The practitioner (or practitioner role) that is collecting the specimen</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>userType</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#CodeableConcept\\\">CodeableConcept</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The type of user initiating the request, e.g. patient, healthcare provider, or specific type of healthcare provider (physician, nurse, etc.)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>userLanguage</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#CodeableConcept\\\">CodeableConcept</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Preferred language of the person using the system</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>userTaskContext</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#CodeableConcept\\\">CodeableConcept</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The task the system user is performing, e.g. laboratory results review, medication list review, etc. This information can be used to tailor decision support outputs, such as recommended information resources</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>setting</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#CodeableConcept\\\">CodeableConcept</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The current setting of the request (inpatient, outpatient, etc.)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>settingContext</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#CodeableConcept\\\">CodeableConcept</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Additional detail about the setting of the request, if any</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>return</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"specimen.html\\\">Specimen</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The Specimen resource that is the result of applying the specimen definition</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n            <div>\\n              <p>The result of this operation is a Specimen resource based on the definition of the specimen as described in the SpecimenDefinition resource and the supplied parameters.</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Apply\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/SpecimenDefinition-apply\",
  \"version\": \"5.0.0\"
}"))
(define (SpecimenDefinition-apply-operation handler)
  (define code "apply")
  (list (operation-entry 'type code "SpecimenDefinition" handler)
        (operation-entry 'instance code "SpecimenDefinition" handler)))
(define care-gaps-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
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
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"The care-gaps operation is used to determine gaps-in-care based on the results of quality measures\",
  \"experimental\": false,
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
  },
  \"name\": \"CareGaps\",
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
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/Measure/$care-gaps</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>periodStart</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#date\\\">date</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The start of the measurement period. In keeping with the semantics of the date parameter used in the FHIR search operation, the period will start at the beginning of the period implied by the supplied timestamp. E.g. a value of 2014 would set the period s</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>periodEnd</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#date\\\">date</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The end of the measurement period. The period will end at the end of the period implied by the supplied timestamp. E.g. a value of 2014 would set the period end to be 2014-12-31T23:59:59 inclusive</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>topic</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The topic to be used to determine which measures are considered for the care gaps report. Any measure with the given topic will be included in the report</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>subject</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                  <br/>(\\n                  <a href=\\\"search.html#reference\\\">reference</a>)\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Subject for which the care gaps report will be produced</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>return</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"bundle.html\\\">Bundle</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The result of the care gaps report will be returned as a document bundle with a MeasureReport entry for each included measure</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n            <div>\\n              <p>The effect of invoking this operation is to calculate a set of measures for a particular topic (e.g. Preventive Care and Screening) and return a document describing the results of each measure for the given subject. Note that it is up to the server to determine whether or not the generated care gaps report is persisted. If the server does not persist the results, the operation does not affect state and can be invoked with a GET</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Care Gaps\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Measure-care-gaps\",
  \"version\": \"5.0.0\"
}"))
(define (care-gaps-operation handler)
  (define code "care-gaps")
  (list (operation-entry 'type code "Measure" handler)))
(define closure-definition
  (string->jsexpr
   "{
  \"affectsState\": true,
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
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"This operation provides support for ongoing maintenance of a client-side [transitive closure table](https://en.wikipedia.org/wiki/Transitive_closure#In_graph_theory) based on server-side terminological logic. For details of how this is used, see [Maintaining a Closure Table](terminology-service.html#closure)\",
  \"experimental\": false,
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
  \"id\": \"ConceptMap-closure\",
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
  },
  \"name\": \"Closure\",
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
      \"documentation\": \"A list of new entries (code / system --> code/system) that the client should add to its closure table. The only kind of entry mapping relationships that can be returned are equivalent, source-is-broader-than-target and source-is-narrower-than-target.\",
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
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/$closure</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>name</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The name that defines the particular context for the subsumption based closure table</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>concept</td>\\n                <td/>\\n                <td>0..*</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#Coding\\\">Coding</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Concepts to add to the closure table</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>version</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>A request to resynchronise - request to send all new entries since the nominated version was sent by the server</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>return</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"conceptmap.html\\\">ConceptMap</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>A list of new entries (code / system --&gt; code/system) that the client should add to its closure table. The only kind of entry mapping relationships that can be returned are equivalent, source-is-broader-than-target and source-is-narrower-than-target.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Closure Table Maintenance\",
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/ConceptMap-closure\",
  \"version\": \"5.0.0\"
}"))
(define (closure-operation handler)
  (define code "closure")
  (list (operation-entry 'system code #f handler)))
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
    }
  ],
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"The collect-data operation is used to collect the data-of-interest for the given measure.\",
  \"experimental\": false,
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
  \"id\": \"Measure-collect-data\",
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
  },
  \"name\": \"CollectData\",
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
      \"scope\": [
        \"type\"
      ],
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
      \"documentation\": \"A MeasureReport of type data-exchange detailing the results of the operation\",
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
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/Measure/$collect-data</p>\\n            <p>URL: [base]/Measure/[id]/$collect-data</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>periodStart</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#date\\\">date</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The start of the measurement period. In keeping with the semantics of the date parameter used in the FHIR search operation, the period will start at the beginning of the period implied by the supplied timestamp. E.g. a value of 2014 would set the period s</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>periodEnd</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#date\\\">date</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The end of the measurement period. The period will end at the end of the period implied by the supplied timestamp. E.g. a value of 2014 would set the period end to be 2014-12-31T23:59:59 inclusive</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>measure</td>\\n                <td>type</td>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                  <br/>(\\n                  <a href=\\\"search.html#reference\\\">reference</a>)\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The measure to evaluate. This parameter is only required when the operation is invoked on the resource type, it is not used when invoking the operation on a Measure instance</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>subject</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                  <br/>(\\n                  <a href=\\\"search.html#reference\\\">reference</a>)\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Subject for which the measure will be collected. If not specified, measure data will be collected for all subjects that meet the requirements of the measure. If specified, the measure will only be calculated for the referenced subject(s)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>practitioner</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                  <br/>(\\n                  <a href=\\\"search.html#reference\\\">reference</a>)\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Practitioner for which the measure will be collected. If specified, measure data will be collected only for subjects that have a primary relationship to the identified practitioner</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>lastReceivedOn</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#dateTime\\\">dateTime</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The date the results of this measure were last received. This parameter used to indicate when the last time data for this measure was collected. This information is used to support incremental data collection scenarios</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>measureReport</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"measurereport.html\\\">MeasureReport</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>A MeasureReport of type data-exchange detailing the results of the operation</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>resource</td>\\n                <td/>\\n                <td>0..*</td>\\n                <td>\\n                  <a href=\\\"resource.html\\\">Resource</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The result resources that make up the data-of-interest for the measure</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n            <div>\\n              <p>The effect of invoking this operation is to gather the data required to perform an evaluation of the measure. If the lastReceivedOn parameter is supplied, only data that is new or has been changed since the lastReceivedOn date is included in the response. Note that the resulting MeasureReport is a transient resource</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Collect Data\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Measure-collect-data\",
  \"version\": \"5.0.0\"
}"))
(define (collect-data-operation handler)
  (define code "collect-data")
  (list (operation-entry 'type code "Measure" handler)
        (operation-entry 'instance code "Measure" handler)))
(define conforms-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
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
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"This operation asks the server to check that it implements all the resources, interactions, search parameters, and operations that the client provides in its capability statement. The client provides both capability statements by reference, and must ensure that all the referenced resources are available to the conformance server\",
  \"experimental\": false,
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
  },
  \"name\": \"Conforms\",
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
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/CapabilityStatement/$conforms</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>left</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>A canonical reference to the left-hand system's capability statement</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>right</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>A canonical reference to the right-hand system's capability statement</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>mode</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>What kind of comparison to perform - server to server, or client to server (use the codes 'server/server' or 'client/server')</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>issues</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"operationoutcome.html\\\">OperationOutcome</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Outcome of the CapabilityStatement test</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>union</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"capabilitystatement.html\\\">CapabilityStatement</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The intersection of the functionality described by the CapabilityStatement resources</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>intersection</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"capabilitystatement.html\\\">CapabilityStatement</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The union of the functionality described by the CapabilityStatement resources</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n            <div>\\n              <p>The operation performs a full comparison of the functionality described by the two capability statements, including the profiles and value sets they reference, and also including concept maps and structure maps.</p>\\n\\n              <p>The full execution of this operation is still a matter of research, but it is intended to support comparison of systems to see if they will interoperate</p>\\n\\n              <p>If the capability statements can be successfully compared, then the return value is a 200 OK with an OperationOutcome along with intersection and union capability statements. The operation outcome can contain errors relating to differences between the capability statements. If the capability statements cannot be compared, because dependencies cannot be located, the return value is a 4xx error, with an OperationOutcome with at least one issue with severity &gt;= error</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Test if a server implements a client's required operations\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/CapabilityStatement-conforms\",
  \"version\": \"5.0.0\"
}"))
(define (conforms-operation handler)
  (define code "conforms")
  (list (operation-entry 'type code "CapabilityStatement" handler)))
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
    }
  ],
  \"date\": \"2023-03-26T15:21:02+11:00\",
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
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
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"Resource\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": true,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/$convert</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>resource</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"resource.html\\\">Resource</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The resource that is to be converted</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>return</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"resource.html\\\">Resource</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The resource after conversion</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n            <div>\\n              <p>While the primary use of this operation is simple - converting a resource from one format to another, there are many potential uses including:</p>\\n\\n              <ul>\\n\\n                <li>converting resources from one version to another</li>\\n\\n                <li>restructuring information in a resource (e.g. moving method into/out of Observation.code)</li>\\n\\n                <li>extracting data from a questionnaire</li>\\n\\n                <li>converting CDA documents or v2 messages (as a binary resource) to a bundle (or vice versa) (or even openEHR or openMHealth).</li>\\n\\n              </ul>\\n\\n              <p>These variants would all be associated with parameters that define and control these kind of conversions, though such parameters are not defined at this time. In the absence of any parameters, simple format conversion is all that will occur.</p>\\n\\n              <p>For this reason, implementers should be aware that:</p>\\n\\n              <ul>\\n\\n                <li>the \\n                  <code>return</code> resource type may be different from the \\n                  <code>resource</code> parameter resource type (for example, it might be a bundle)\\n                </li>\\n\\n                <li>binary resources may be represented directly using some other content-type (in other words, just post the content directly)</li>\\n\\n              </ul>\\n\\n              <p>Implementers are encouraged to provide feedback to HL7 about their use of this operation</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Convert from one form to another\",
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Resource-convert\",
  \"version\": \"5.0.0\"
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
    }
  ],
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"Returns the most current version of the canonical resource with the specified url available on the server.  It optionally also allows filtering to only expose the most current version with a particular status or set of statuses.\\r\\rNote that 'current' is determined by comparing version values using the specified versionAlgorithm, NOT by looking at lastUpdated.\",
  \"experimental\": false,
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
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
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"CanonicalResource\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": true,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/$current-canonical</p>\\n            <p>URL: [base]/CanonicalResource/$current-canonical</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>url</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>This is the canonical URL (with no version declared)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>status</td>\\n                <td/>\\n                <td>0..*</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The statuses to allow to be returned. If no status codes are provided, then any status is ok</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>result</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"canonicalresource.html\\\">CanonicalResource</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>If no resources can be found, will return nothing.  If multiple resources are found for the specified statuses and 'most current' can't be determined by comparing the versions, the operation will fail with an operation outcome.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n            <div>\\n              <p>If none of the instances define the versionAlgorithm to use, a server may  dynamically attempt to determine which versioning system is implied by the data.</p>\\n\\n              <p>If the instances found with the provided canonical URL define different versionAlgorithm values the server may return an error.</p>\\n\\n              <p>Note that the \\n                <em>CanonicalResource</em> is an interface and not an actual resource type, as such the operation is actually called on the canonical resource types such as CodeSystem, Questionnaire etc.\\n              </p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Fetch the current version of a canonical resource (based on canonical versioning)\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/CanonicalResource-current-canonical\",
  \"version\": \"5.0.0\"
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
    }
  ],
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"The data-requirements operation aggregates and returns the parameters and data requirements for the activity definition and all its dependencies as a single module definition library\",
  \"experimental\": false,
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
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
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"ActivityDefinition\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/ActivityDefinition/[id]/$data-requirements</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>return</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"library.html\\\">Library</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The result of the requirements gathering represented as a module-definition Library that describes the aggregate parameters, data requirements, and dependencies of the activity definition</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n            <div>\\n              <p>The effect of invoking this operation is to determine the aggregate set of data requirements and dependencies for the activity definition. The result is a Library resource with a type of module-definition that contains all the parameter definitions and data requirements of the activity definition and any libraries referenced by it. Implementations SHOULD aggregate data requirements intelligently (i.e. by collapsing overlapping data requirements)</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Data Requirements\",
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/ActivityDefinition-data-requirements\",
  \"version\": \"5.0.0\"
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
    }
  ],
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"The data-requirements operation aggregates and returns the parameters and data requirements for a resource and all its dependencies as a single module definition\",
  \"experimental\": false,
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
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
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"Library\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": true,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/$data-requirements</p>\\n            <p>URL: [base]/Library/[id]/$data-requirements</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>target</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The target of the data requirements operation</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>return</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"library.html\\\">Library</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The result of the requirements gathering</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n            <div>\\n              <p>The effect of invoking this operation is to determine the aggregate set of data requirements and dependencies for a given target resource. The result is a Library resource with a type of module-definition that contains all the parameter definitions and data requirements of the target resource and any libraries referenced by it. Implementations SHOULD aggregate data requirements intelligently (i.e. by collapsing overlapping data requirements)</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Data Requirements\",
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Library-data-requirements\",
  \"version\": \"5.0.0\"
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
    }
  ],
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"The data-requirements operation aggregates and returns the parameters and data requirements for the measure and all its dependencies as a single module definition\",
  \"experimental\": false,
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
  },
  \"name\": \"DataRequirements\",
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
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/Measure/[id]/$data-requirements</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>periodStart</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#date\\\">date</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The start of the measurement period. In keeping with the semantics of the date parameter used in the FHIR search operation, the period will start at the beginning of the period implied by the supplied timestamp. E.g. a value of 2014 would set the period start to be 2014-01-01T00:00:00 inclusive</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>periodEnd</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#date\\\">date</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The end of the measurement period. The period will end at the end of the period implied by the supplied timestamp. E.g. a value of 2014 would set the period end to be 2014-12-31T23:59:59 inclusive</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>return</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"library.html\\\">Library</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The result of the requirements gathering is a module-definition Library that describes the aggregate parameters, data requirements, and dependencies of the measure</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n            <div>\\n              <p>The effect of invoking this operation is to determine the aggregate set of data requirements and dependencies for the measure. The result is a Library resource with a type of module-definition that contains all the parameter definitions and data requirements of the libraries referenced by the measures. Implementations SHOULD aggregate data requirements intelligently (i.e. by collapsing overlapping data requirements). This operation defines what resources are subsequently referenced in the evaluatedResources element of the MeasureReport when submitting measure data</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Data Requirements\",
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Measure-data-requirements\",
  \"version\": \"5.0.0\"
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
    }
  ],
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"The data-requirements operation aggregates and returns the parameters and data requirements for the plan definition and all its dependencies as a single module definition library\",
  \"experimental\": false,
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
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
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"PlanDefinition\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/PlanDefinition/[id]/$data-requirements</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>return</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"library.html\\\">Library</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The result of the requirements gathering is a module-definition Library that describes the aggregate parameters, data requirements, and dependencies of the plan definition</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n            <div>\\n              <p>The effect of invoking this operation is to determine the aggregate set of data requirements and dependencies for the plan definition. The result is a Library resource with a type of module-definition that contains all the parameter definitions and data requirements of the plan definition and any libraries referenced by it. Implementations SHOULD aggregate data requirements intelligently (i.e. by collapsing overlapping data requirements)</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Data Requirements\",
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/PlanDefinition-data-requirements\",
  \"version\": \"5.0.0\"
}"))
(define (PlanDefinition-data-requirements-operation handler)
  (define code "data-requirements")
  (list (operation-entry 'instance code "PlanDefinition" handler)))
(define docref-definition
  (string->jsexpr
   "{
  \"affectsState\": true,
  \"code\": \"docref\",
  \"comment\": \"The server either returns a search result containing a single DocumentReference, \\nor it returns an error.\",
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
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"This operation is used to return all the references to documents related to a patient. \\n\\n The operation requires a patient id and takes the optional input parameters: \\n  - start date\\n  - end date\\n  - document type \\n\\n and returns a [Bundle](bundle.html) of type \\\"searchset\\\" containing [DocumentReference](documentreference.html) resources for the patient. If the server has or can create documents that are related to the patient, and that are available for the given user, the server returns the DocumentReference resources needed to support the records.  The principle intended use for this operation is to provide a provider or patient with access to their available document information. \\n\\n This operation is *different* from a search by patient and type and date range because: \\n\\n 1. It is used to request a server to *generate* a document based on the specified parameters. \\n\\n 1. If no parameters are specified, the server SHALL return a DocumentReference to the patient's most current CCD \\n\\n 1. If the server cannot *generate* a document based on the specified parameters, the operation will return an empty search bundle. \\n\\n This operation is the *same* as a FHIR RESTful search by patient, type and date range because: \\n\\n 1. References for *existing* documents that meet the requirements of the request SHOULD also be returned unless the client indicates they are only interested in 'on-demand' documents using the *on-demand* parameter.\",
  \"experimental\": false,
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
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
        \"strength\": \"required\",
        \"valueSet\": \"http://hl7.org/fhir/ValueSet/doc-typecodes|5.0.0\"
      },
      \"documentation\": \"The type relates to document type e.g. for the LOINC code for a C-CDA Clinical Summary of Care (CCD) is 34133-9 (Summary of episode note). If no type is provided, the CCD document, if available, SHALL be in scope and all other document types MAY be in scope\",
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
      \"documentation\": \"The bundle type is \\\"searchset\\\"containing [DocumentReference](documentreference.html) resources.\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"return\",
      \"type\": \"Bundle\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"DocumentReference\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/DocumentReference/$docref</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>patient</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#id\\\">id</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The id of the patient resource located on the server on which this operation is executed.  If there is no match, an empty Bundle is returned</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>start</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#dateTime\\\">dateTime</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The date range relates to care dates, not record currency dates - e.g. all records relating to care provided in a certain date range. If no start date is provided, all documents prior to the end date are in scope.  If neither a start date nor an end date is provided, the most recent or current document is in scope.  The client \\n                      <strong>SHOULD</strong> provide values precise to the second + time offset.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>end</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#dateTime\\\">dateTime</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The date range relates to care dates, not record currency dates - e.g. all records relating to care provided in a certain date range. If no end date is provided, all documents subsequent to the start date are in scope. If neither a start date nor an end date is provided, the most recent or current document is in scope.  The client \\n                      <strong>SHOULD</strong> provide values precise to the second + time offset.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>type</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#CodeableConcept\\\">CodeableConcept</a>\\n                </td>\\n                <td>\\n                  <a href=\\\"valueset-doc-typecodes.html\\\">FHIR Document Type Codes</a> (Required)\\n                </td>\\n                <td>\\n                  <div>\\n                    <p>The type relates to document type e.g. for the LOINC code for a C-CDA Clinical Summary of Care (CCD) is 34133-9 (Summary of episode note). If no type is provided, the CCD document, if available, SHALL be in scope and all other document types MAY be in scope</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>on-demand</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>This on-demand parameter allows client to dictate whether they are requesting only 'on-demand' or both 'on-demand' and 'stable' documents (or delayed/deferred assembly) that meet the query parameters</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>return</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"bundle.html\\\">Bundle</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The bundle type is &quot;searchset&quot;containing \\n                      <a href=\\\"documentreference.html\\\">DocumentReference</a> resources.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n            <div>\\n              <p>The server either returns a search result containing a single DocumentReference,\\nor it returns an error.</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Fetch DocumentReference\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/DocumentReference-docref\",
  \"version\": \"5.0.0\"
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
    }
  ],
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"A client can ask a server to generate a fully bundled document from a composition resource. The server takes the composition resource, locates all the referenced resources and other additional resources as configured or requested and either returns a full document bundle, or returns an error. If some of the resources are located on other servers, it is at the discretion of the  server whether to retrieve them or return an error. If the correct version of the document  that would be generated already exists, then the server can return the existing one.\",
  \"experimental\": false,
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
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
      \"documentation\": \"Canonical reference to a GraphDefinition. If a URL is provided, it is the canonical reference to a [GraphDefinition](graphdefinition.html) that it controls what resources are to be added to the bundle when building the document. The GraphDefinition can also specify profiles that apply to the various resources\",
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
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"Composition\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/Composition/[id]/$document</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>persist</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Whether to store the document at the bundle end-point (/Bundle) or not once it is generated. Value = true or false (default is for the server to decide). If the document is stored, its location can be inferred from the Bundle.id, but it SHOULD be provided explicitly in the HTTP Location header in the response</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>graph</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Canonical reference to a GraphDefinition. If a URL is provided, it is the canonical reference to a \\n                      <a href=\\\"graphdefinition.html\\\">GraphDefinition</a> that it controls what resources are to be added to the bundle when building the document. The GraphDefinition can also specify profiles that apply to the various resources\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>return</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"bundle.html\\\">Bundle</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The bundle containing the composition and resources associated with it. See \\n                      <a href=\\\"documents.html\\\">FHIR Documents</a> for information on resources that may be included in the bundle.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n            <div>\\n              <p>Notes:</p>\\n\\n              <ul>\\n\\n                <li>The server implementing the operation SHOULD determine a 'high-level water-mark' for the document security tags (\\n                  <a href=\\\"resource.html#Meta\\\">Bundle.meta.security</a>)) as a whole, based on an analysis of the resources contained within the document\\n                </li>\\n\\n                <li>this operation definition does not resolve the question how document signatures are created. This is an open issue during the period of trial use, and feedback is requested regarding this question</li>\\n\\n              </ul>\\n\\n            </div>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Generate a Document\",
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Composition-document\",
  \"version\": \"5.0.0\"
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
    }
  ],
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"The evaluate-measure operation is used to calculate an eMeasure and obtain the results\",
  \"experimental\": false,
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
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
      \"documentation\": \"The url of the plan measure to be applied. If the operation is invoked at the instance level, this parameter is not allowed; if the operation is invoked at the type level, this parameter (and optionally the version), or the measure parameter must be supplied\",
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
      \"documentation\": \"The version of the measure to be applied. If the operation is invoked at the instance level, this parameter is not allowed; if the operation is invoked at the type level, this parameter may only be used if the url parameter is supplied.\",
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
      \"documentation\": \"Subject for which the measure will be calculated. The subject may be a Patient, Practitioner, PractitionerRole, Organization, Location, Device, or Group. Subjects provided in this parameter will be resolved as the subject of the measure based on the type of the subject. If multiple subjects of the same type are provided, the behavior is implementation-defined\",
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
      \"documentation\": \"The type of measure report: individual, subject-list, or summary. If not specified, a default value of individual will be used if the subject parameter is supplied, otherwise, summary will be used. NOTE: Implementations should support the use of `subject` for individual and `population` for summary for backwards compatibility with existing implementations.\",
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
      \"documentation\": \"Any input parameters for the evaluation. Parameters defined in this input will be made available by name to the CQL expression. Parameter types are mapped to CQL as specified in the Using CQL topic of the Clinical Reasoning Module. If a parameter appears more than once in the input Parameters resource, it is represented with a List in the input CQL. If a parameter has parts, it is represented as a Tuple in the input CQL.\",
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
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"Measure\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/Measure/$evaluate-measure</p>\\n            <p>URL: [base]/Measure/[id]/$evaluate-measure</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>measure</td>\\n                <td>type</td>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"measure.html\\\">Measure</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The measure to evaluate. If the operation is invoked at the instance level, this parameter is not allowed; if the operation is invoked at the type level, this parameter is required, or a url (and optionally version) must be supplied.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>url</td>\\n                <td>type</td>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The url of the plan measure to be applied. If the operation is invoked at the instance level, this parameter is not allowed; if the operation is invoked at the type level, this parameter (and optionally the version), or the measure parameter must be supplied</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>version</td>\\n                <td>type</td>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The version of the measure to be applied. If the operation is invoked at the instance level, this parameter is not allowed; if the operation is invoked at the type level, this parameter may only be used if the url parameter is supplied.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>subject</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                  <br/>(\\n                  <a href=\\\"search.html#reference\\\">reference</a>)\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Subject for which the measure will be calculated. The subject may be a Patient, Practitioner, PractitionerRole, Organization, Location, Device, or Group. Subjects provided in this parameter will be resolved as the subject of the measure based on the type of the subject. If multiple subjects of the same type are provided, the behavior is implementation-defined</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>periodStart</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#date\\\">date</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The start of the measurement period. In keeping with the semantics of the date parameter used in the FHIR search operation, the period will start at the beginning of the period implied by the supplied timestamp. E.g. a value of 2014 would set the period start to be 2014-01-01T00:00:00 inclusive</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>periodEnd</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#date\\\">date</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The end of the measurement period. The period will end at the end of the period implied by the supplied timestamp. E.g. a value of 2014 would set the period end to be 2014-12-31T23:59:59 inclusive</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>reportType</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The type of measure report: individual, subject-list, or summary. If not specified, a default value of individual will be used if the subject parameter is supplied, otherwise, summary will be used. NOTE: Implementations should support the use of \\n                      <code>subject</code> for individual and \\n                      <code>population</code> for summary for backwards compatibility with existing implementations.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>provider</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                  <br/>(\\n                  <a href=\\\"search.html#reference\\\">reference</a>)\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The provider for which the report will be run. This may be a reference to a Practitioner, PractitionerRole, or Organization. If specified, the measure will be calculated for subjects that have a primary relationship to the identified provider. How this relationship is determined is implementation-specific.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>location</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                  <br/>(\\n                  <a href=\\\"search.html#reference\\\">reference</a>)\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The location for which the report will be run.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>lastReceivedOn</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#dateTime\\\">dateTime</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The date the results of this measure were last received. This parameter is only valid for patient-level reports and is used to indicate when the last time a result for this patient was received. This information can be used to limit the set of resources returned for a patient-level report</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>parameters</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"parameters.html\\\">Parameters</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Any input parameters for the evaluation. Parameters defined in this input will be made available by name to the CQL expression. Parameter types are mapped to CQL as specified in the Using CQL topic of the Clinical Reasoning Module. If a parameter appears more than once in the input Parameters resource, it is represented with a List in the input CQL. If a parameter has parts, it is represented as a Tuple in the input CQL.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>return</td>\\n                <td/>\\n                <td>0..*</td>\\n                <td>\\n                  <a href=\\\"bundle.html\\\">Bundle</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The results of the measure calculation. The result of this operation will be a Bundle for each input subject, where the first entry of the Bundle is a MeasureReport representing the results of the calculation, and subsequent entries in the Bundle are resources created and/or evaluated as part of the calculation. See the MeasureReport resource for a complete description of the output of this operation. Note that implementations may choose to return a MeasureReport with a status of pending to indicate that the report is still being generated. In this case, the client can use a polling method to continually request the MeasureReport until the status is updated to complete</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n            <div>\\n              <p>The effect of invoking this operation is to calculate the measure for the given subject(s), or all subjects if no subject is supplied. For individual and subject-list reports, the result is a set of Bundles, one for each evaluated subject, where the first entry in each bundle is a MeasureReport resource, and subsequent entries in the Bundle are resources evaluated or created as part of the measure evaluation. For the summary report, the result of this operation is a single bundle with a single MeasureReport of type summary. Note that whether or not this operation affects the state of the server depends on whether the server persists the generated MeasureReport. If the MeasureReport is not persisted, this operation can be invoked with GET</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Evaluate Measure\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Measure-evaluate-measure\",
  \"version\": \"5.0.0\"
}"))
(define (evaluate-measure-operation handler)
  (define code "evaluate-measure")
  (list (operation-entry 'type code "Measure" handler)
        (operation-entry 'instance code "Measure" handler)))
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
    }
  ],
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"This operation is used to search for and return notifications that have been previously triggered by a topic-based Subscription.\",
  \"experimental\": false,
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
  },
  \"name\": \"Events\",
  \"parameter\": [
    {
      \"documentation\": \"The starting event number, inclusive of this event (lower bound).\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"eventsSinceNumber\",
      \"type\": \"integer64\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The ending event number, inclusive of this event (upper bound).\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"eventsUntilNumber\",
      \"type\": \"integer64\",
      \"use\": \"in\"
    },
    {
      \"binding\": {
        \"strength\": \"required\",
        \"valueSet\": \"http://hl7.org/fhir/ValueSet/subscription-payload-content|5.0.0\"
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
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"Subscription\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/Subscription/[id]/$events</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>eventsSinceNumber</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#integer64\\\">integer64</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The starting event number, inclusive of this event (lower bound).</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>eventsUntilNumber</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#integer64\\\">integer64</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The ending event number, inclusive of this event (upper bound).</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>content</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n                <td>\\n                  <a href=\\\"valueset-subscription-payload-content.html\\\">Subscription Payload Content</a> (Required)\\n                </td>\\n                <td>\\n                  <div>\\n                    <p>Requested content style of returned data. Codes from backport-content-value-set (e.g., empty, id-only, full-resource). This is a hint to the server what a client would prefer, and MAY be ignored.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>return</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"bundle.html\\\">Bundle</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The operation returns a valid notification bundle, with the first entry being a SubscriptionStatus resource. The bundle type is &quot;subscription-notification&quot;.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Search and retrieve prior events for a Subscription\",
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Subscription-events\",
  \"version\": \"5.0.0\"
}"))
(define (events-operation handler)
  (define code "events")
  (list (operation-entry 'instance code "Subscription" handler)))
(define Encounter-everything-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
  \"code\": \"everything\",
  \"comment\": \"The key differences between this operation and simply searching the encounter compartment are:  \\n\\n* unless the client requests otherwise, the server returns the entire result set in a single bundle (rather than using paging) \\n* the server is responsible for determining what resources to return as included resources (rather than the client specifying which ones)\\n\\nThis frees the client from needing to determine what it could or should ask for, particularly with regard to included resources. Servers should consider returning appropriate Provenance and AuditTrail on the returned resources, even though these are not directly part of the patient compartment. \\n\\nIt is assumed that the server has identified and secured the context appropriately, and can either associate the authorization context with a single encounter, or determine whether the context has the rights to the nominated encounter, if there is one, or can determine an appropriate list of encouners to provide data for from the context of the request.  If there is no nominated encounter (GET /[base]/Encounter/$everything) and the context is not associated with a single encounter record, the actual list of encounters is all encounters that the user associated with the request has access to. In such cases, the server may choose to return an error rather than all the records. Specifying the relationship between the context, a user and encounter records is outside the scope of this specification (though see [The Smart App Launch Implementation Guide](http://hl7.org/fhir/smart-app-launch).   \\n\\nWhen this operation is used to access multiple encounter records at once, the return bundle could be rather a lot of data; servers may choose to require that such requests are made [asynchronously](async.html), and associated with [bulk data formats](resource-formats.html#bulk). Alternatively, clients may choose to page through the result set (or servers may require this). Paging through the results is done the same as for [Searching](http.html#paging), using the [_count](search.html#count) parameter, and Bundle links. Implementers should note that paging will be slower than simply returning all the results at once (more network traffic, multiple latency delays) but may be required in order not to exhaust available memory reading or writing the whole response in a single package. Unlike searching, there is no inherent user-display order for the $everything operation. Servers might consider sorting the returned resources in descending order of last record update, but are not required to do so. Servers should consider returning appropriate Provenance and AuditTrail on the returned resources, even though these are not directly part of the patient compartment.\\n\\nThe _since parameter is provided to support periodic queries to get additional information that has changed about the encounter since the last query. This means that the _since parameter is based on record time. The value of the _since parameter should be set to the time from the server. If using direct response, this is the timestamp in the response header. If using the async interface, this is the transaction timestamp in the json response. Servers should ensure that the timestamps a managed such that the client does not miss any changes. Clients should be able to handle getting the same response more than once in the case that the transaction falls on a time boundary. Clients should ensure that the other query parameters are constant to ensure a coherent set of records when doing periodic queries.\",
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
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"This operation is used to return all the information related to an encounter described in the resource on which this operation is invoked. The response is a bundle of type \\\"searchset\\\". At a minimum, the encounter resource itself is returned, along with any other resources that the server has available for the given encounter for the user. The server also returns whatever resources are needed to support the records - e.g. linked practitioners, locations, organizations etc. The principle intended use for this operation is to provide a patient with access to their record, or to allow a client to retrieve everything for an encounter for efficient display).\\r\\rThe server SHOULD return all resources it has that:\\r\\r* are included in the encounter compartment for the identified encounter (have a reference to the encounter)\\r* are referenced by the standard extenstion for associating an encounter (where no reference element exists) http://hl7.org/fhir/StructureDefinition/encounter-associatedEncounter\\r* the server believes are relevant to the context of the encounter for any other reason (internally defined/decided)\\r* any resource referenced by the above, including binaries and attachments (to make a more complete package)\\r\\rIn the US Realm, at a mimimum, the resources returned SHALL include all the data covered by the meaningful use common data elements (see [DAF](http://hl7.org/fhir/us/daf) for further guidance). Other applicable implementation guides may make additional rules about the information that is returned.   Note that for many resources, the exact nature of the link to encounter can be ambiguous (e.g. for a DiagnosticReport, is it the encounter when it was initiated, or when it was reported?)\",
  \"experimental\": false,
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
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
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/Encounter/[id]/$everything</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>_since</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#instant\\\">instant</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Resources updated after this period will be included in the response. The intent of this parameter is to allow a client to request only records that have changed since the last request, based on either the return header time, or or (for asynchronous use), the transaction time</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>_type</td>\\n                <td/>\\n                <td>0..*</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>One or more parameters, each containing one or more comma-delimited FHIR resource types to include in the return resources. In the absense of any specified types, the server returns all resource types</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>_count</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#integer\\\">integer</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>See discussion below on the utility of paging through the results of the $everything operation</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>return</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"bundle.html\\\">Bundle</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The bundle type is &quot;searchset&quot;</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n            <div>\\n              <p>The key differences between this operation and simply searching the encounter compartment are:</p>\\n\\n              <ul>\\n\\n                <li>unless the client requests otherwise, the server returns the entire result set in a single bundle (rather than using paging)</li>\\n\\n                <li>the server is responsible for determining what resources to return as included resources (rather than the client specifying which ones)</li>\\n\\n              </ul>\\n\\n              <p>This frees the client from needing to determine what it could or should ask for, particularly with regard to included resources. Servers should consider returning appropriate Provenance and AuditTrail on the returned resources, even though these are not directly part of the patient compartment.</p>\\n\\n              <p>It is assumed that the server has identified and secured the context appropriately, and can either associate the authorization context with a single encounter, or determine whether the context has the rights to the nominated encounter, if there is one, or can determine an appropriate list of encouners to provide data for from the context of the request.  If there is no nominated encounter (GET /[base]/Encounter/$everything) and the context is not associated with a single encounter record, the actual list of encounters is all encounters that the user associated with the request has access to. In such cases, the server may choose to return an error rather than all the records. Specifying the relationship between the context, a user and encounter records is outside the scope of this specification (though see \\n                <a href=\\\"http://hl7.org/fhir/smart-app-launch\\\">The Smart App Launch Implementation Guide</a>.\\n              </p>\\n\\n              <p>When this operation is used to access multiple encounter records at once, the return bundle could be rather a lot of data; servers may choose to require that such requests are made \\n                <a href=\\\"async.html\\\">asynchronously</a>, and associated with \\n                <a href=\\\"resource-formats.html#bulk\\\">bulk data formats</a>. Alternatively, clients may choose to page through the result set (or servers may require this). Paging through the results is done the same as for \\n                <a href=\\\"http.html#paging\\\">Searching</a>, using the \\n                <a href=\\\"search.html#count\\\">_count</a> parameter, and Bundle links. Implementers should note that paging will be slower than simply returning all the results at once (more network traffic, multiple latency delays) but may be required in order not to exhaust available memory reading or writing the whole response in a single package. Unlike searching, there is no inherent user-display order for the $everything operation. Servers might consider sorting the returned resources in descending order of last record update, but are not required to do so. Servers should consider returning appropriate Provenance and AuditTrail on the returned resources, even though these are not directly part of the patient compartment.\\n              </p>\\n\\n              <p>The _since parameter is provided to support periodic queries to get additional information that has changed about the encounter since the last query. This means that the _since parameter is based on record time. The value of the _since parameter should be set to the time from the server. If using direct response, this is the timestamp in the response header. If using the async interface, this is the transaction timestamp in the json response. Servers should ensure that the timestamps a managed such that the client does not miss any changes. Clients should be able to handle getting the same response more than once in the case that the transaction falls on a time boundary. Clients should ensure that the other query parameters are constant to ensure a coherent set of records when doing periodic queries.</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Fetch Encounter Record\",
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Encounter-everything\",
  \"version\": \"5.0.0\"
}"))
(define (Encounter-everything-operation handler)
  (define code "everything")
  (list (operation-entry 'instance code "Encounter" handler)))
(define EpisodeOfCare-everything-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
  \"code\": \"everything\",
  \"comment\": \"The key differences between this operation and simply searching the episodeofcare compartment are:  \\n\\n* unless the client requests otherwise, the server returns the entire result set in a single bundle (rather than using paging) \\n* the server is responsible for determining what resources to return as included resources (rather than the client specifying which ones)\\n\\nThis frees the client from needing to determine what it could or should ask for, particularly with regard to included resources. Servers should consider returning appropriate Provenance and AuditTrail on the returned resources, even though these are not directly part of the patient compartment. \\n\\nIt is assumed that the server has identified and secured the context appropriately, and can either associate the authorization context with a single episodeofcare, or determine whether the context has the rights to the nominated episodeofcare, if there is one, or can determine an appropriate list of episodeofcares to provide data for from the context of the request.  If there is no nominated episodeofcare (GET /[base]/EpisodeOfCare/$everything) and the context is not associated with a single episodeofcare record, the actual list of episodeofcares is all episodeofcares that the user associated with the request has access to. In such cases, the server may choose to return an error rather than all the records. Specifying the relationship between the context, a user and episodeofcare records is outside the scope of this specification (though see [The Smart App Launch Implementation Guide](http://hl7.org/fhir/smart-app-launch).   \\n\\nWhen this operation is used to access multiple episodeofcare records at once, the return bundle could be rather a lot of data; servers may choose to require that such requests are made [asynchronously](async.html), and associated with [bulk data formats](resource-formats.html#bulk). Alternatively, clients may choose to page through the result set (or servers may require this). Paging through the results is done the same as for [Searching](http.html#paging), using the [_count](search.html#count) parameter, and Bundle links. Implementers should note that paging will be slower than simply returning all the results at once (more network traffic, multiple latency delays) but may be required in order not to exhaust available memory reading or writing the whole response in a single package. Unlike searching, there is no inherent user-display order for the $everything operation. Servers might consider sorting the returned resources in descending order of last record update, but are not required to do so. Servers should consider returning appropriate Provenance and AuditTrail on the returned resources, even though these are not directly part of the patient compartment.\\n\\nThe _since parameter is provided to support periodic queries to get additional information that has changed about the episodeofcare since the last query. This means that the _since parameter is based on record time. The value of the _since parameter should be set to the time from the server. If using direct response, this is the timestamp in the response header. If using the async interface, this is the transaction timestamp in the json response. Servers should ensure that the timestamps a managed such that the client does not miss any changes. Clients should be able to handle getting the same response more than once in the case that the transaction falls on a time boundary. Clients should ensure that the other query parameters are constant to ensure a coherent set of records when doing periodic queries.\",
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
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"This operation is used to return all the information related to an episodeofcare described in the resource on which this operation is invoked. The response is a bundle of type \\\"searchset\\\". At a minimum, the episodeofcare resource itself is returned, along with any other resources that the server has available for the given episodeofcare for the user. The server also returns whatever resources are needed to support the records - e.g. linked practitioners, locations, organizations etc. The principle intended use for this operation is to provide a patient with access to their record, or to allow a client to retrieve everything for an episodeofcare for efficient display).\\r\\rThe server SHOULD return all resources it has that:\\r\\r* are included in the episodeofcare compartment for the identified episodeofcare (have a reference to the episodeofcare)\\r* are referenced by the standard extension for associating an episodeofcare (where no reference element exists) http://hl7.org/fhir/StructureDefinition/workflow-episodeOfCare\\r* the server believes are relevant to the context of the episodeofcare for any other reason (internally defined/decided)\\r* any resource referenced by the above, including binaries and attachments (to make a more complete package)\",
  \"experimental\": false,
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
  \"id\": \"EpisodeOfCare-everything\",
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
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
    \"EpisodeOfCare\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/EpisodeOfCare/[id]/$everything</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>_since</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#instant\\\">instant</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Resources updated after this period will be included in the response. The intent of this parameter is to allow a client to request only records that have changed since the last request, based on either the return header time, or or (for asynchronous use), the transaction time</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>_type</td>\\n                <td/>\\n                <td>0..*</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>One or more parameters, each containing one or more comma-delimited FHIR resource types to include in the return resources. In the absense of any specified types, the server returns all resource types</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>_count</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#integer\\\">integer</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>See discussion below on the utility of paging through the results of the $everything operation</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>return</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"bundle.html\\\">Bundle</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The bundle type is &quot;searchset&quot;</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n            <div>\\n              <p>The key differences between this operation and simply searching the episodeofcare compartment are:</p>\\n\\n              <ul>\\n\\n                <li>unless the client requests otherwise, the server returns the entire result set in a single bundle (rather than using paging)</li>\\n\\n                <li>the server is responsible for determining what resources to return as included resources (rather than the client specifying which ones)</li>\\n\\n              </ul>\\n\\n              <p>This frees the client from needing to determine what it could or should ask for, particularly with regard to included resources. Servers should consider returning appropriate Provenance and AuditTrail on the returned resources, even though these are not directly part of the patient compartment.</p>\\n\\n              <p>It is assumed that the server has identified and secured the context appropriately, and can either associate the authorization context with a single episodeofcare, or determine whether the context has the rights to the nominated episodeofcare, if there is one, or can determine an appropriate list of episodeofcares to provide data for from the context of the request.  If there is no nominated episodeofcare (GET /[base]/EpisodeOfCare/$everything) and the context is not associated with a single episodeofcare record, the actual list of episodeofcares is all episodeofcares that the user associated with the request has access to. In such cases, the server may choose to return an error rather than all the records. Specifying the relationship between the context, a user and episodeofcare records is outside the scope of this specification (though see \\n                <a href=\\\"http://hl7.org/fhir/smart-app-launch\\\">The Smart App Launch Implementation Guide</a>.\\n              </p>\\n\\n              <p>When this operation is used to access multiple episodeofcare records at once, the return bundle could be rather a lot of data; servers may choose to require that such requests are made \\n                <a href=\\\"async.html\\\">asynchronously</a>, and associated with \\n                <a href=\\\"resource-formats.html#bulk\\\">bulk data formats</a>. Alternatively, clients may choose to page through the result set (or servers may require this). Paging through the results is done the same as for \\n                <a href=\\\"http.html#paging\\\">Searching</a>, using the \\n                <a href=\\\"search.html#count\\\">_count</a> parameter, and Bundle links. Implementers should note that paging will be slower than simply returning all the results at once (more network traffic, multiple latency delays) but may be required in order not to exhaust available memory reading or writing the whole response in a single package. Unlike searching, there is no inherent user-display order for the $everything operation. Servers might consider sorting the returned resources in descending order of last record update, but are not required to do so. Servers should consider returning appropriate Provenance and AuditTrail on the returned resources, even though these are not directly part of the patient compartment.\\n              </p>\\n\\n              <p>The _since parameter is provided to support periodic queries to get additional information that has changed about the episodeofcare since the last query. This means that the _since parameter is based on record time. The value of the _since parameter should be set to the time from the server. If using direct response, this is the timestamp in the response header. If using the async interface, this is the transaction timestamp in the json response. Servers should ensure that the timestamps a managed such that the client does not miss any changes. Clients should be able to handle getting the same response more than once in the case that the transaction falls on a time boundary. Clients should ensure that the other query parameters are constant to ensure a coherent set of records when doing periodic queries.</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Fetch EpisodeOfCare Record\",
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/EpisodeOfCare-everything\",
  \"version\": \"5.0.0\"
}"))
(define (EpisodeOfCare-everything-operation handler)
  (define code "everything")
  (list (operation-entry 'instance code "EpisodeOfCare" handler)))
(define Group-everything-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
  \"code\": \"everything\",
  \"comment\": \"The key differences between this operation and simply searching the group's patients compartment are:    \\n\\n* unless the client requests otherwise, the server returns the entire result set in a single bundle (rather than using paging)  \\n* the server is responsible for determining what resources to return as included resources (rather than the client specifying which ones). \\n\\nThis frees the client from needing to determine what it could or should ask for, particularly with regard to included resources.  \\n\\nIt is assumed that the server has identified and secured the context appropriately, and can either associate the authorization context with a particular group, or determine whether the context has the rights to the nominated group, if there is one, or can determine an appropriate list of groups to provide data for from the context of the request.   If there is no nominated group (GET /[base]/Group/$everything) and the context is not associated with a single group record, the actual list of groups is all groups that the user associated with the request has access to. In such cases, the server may choose to return an error rather than all the records (and is likely to do so, but not required to).  Specifying the relationship between the context, a user and groups is outside the scope of this specification (though see [The Smart App Launch Implementation Guide](http://hl7.org/fhir/smart-app-launch). \\n\\nThe return bundle from this operation is usually rather a lot of data; servers typically choose to require that such requests are made [asynchronously](async.html), and associated with [bulk data formats](resource-formats.html#bulk). Alternatively, clients may choose to page through the result set (or servers may require this). Paging through the results is done the same as for [Searching](http.html#paging), using the [_count](search.html#count) parameter, and Bundle links. Implementers should note that paging will be slower than simply returning all the results at once (more network traffic, multiple latency delays) but may be required in order not to exhaust available memory reading or writing the whole response in a single package. Unlike searching, there is no inherent user-display order for the $everything operation. Servers might consider sorting the returned resources in descending order of last record update, but are not required to do so.\\n\\nThe _since parameter is provided to support periodic queries to get additional information that has changed about the group since the last query. This means that the _since parameter is based on record time. The value of the _since parameter should be set to the time from the server. If using direct response, this is the timestamp in the response header. If using the async interface, this is the transaction timestamp in the json response. Servers should ensure that the timestamps a managed such that the client does not miss any changes. Clients should be able to handle getting the same response more than once in the case that the transaction falls on a time boundary. Clients should ensure that the other query parameters are constant to ensure a coherent set of records when doing periodic queries.\",
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
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"This operation is used to return all the information related to one or more patients that are part of the group on which this operation is invoked. The response is a bundle of type \\\"searchset\\\". At a minimum, the patient resource(s) itself is returned, along with any other resources that the server has that are related to the patient(s), and that are available for the given user. The server also returns whatever resources are needed to support the records - e.g. linked practitioners, medications, locations, organizations etc.   The intended use for this operation is for a provider or other user to perform a bulk data download.  The server SHOULD return at least all resources that it has that are in the patient compartment for the identified patient(s), and any resource referenced from those, including binaries and attachments. In the US Realm, at a mimimum, the resources returned SHALL include all the data covered by the meaningful use common data elements as defined in [US-Core](http://hl7.org/fhir/us/core). Other applicable implementation guides may make additional rules about how much information that is returned.\",
  \"experimental\": false,
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
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
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"Group\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/Group/[id]/$everything</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>start</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#date\\\">date</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The date range relates to care dates, not record currency dates - e.g. all records relating to care provided in a certain date range. If no start date is provided, all records prior to the end date are in scope.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>end</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#date\\\">date</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The date range relates to care dates, not record currency dates - e.g. all records relating to care provided in a certain date range. If no end date is provided, all records subsequent to the start date are in scope.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>_since</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#instant\\\">instant</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Resources updated after this period will be included in the response. The intent of this parameter is to allow a client to request only records that have changed since the last request, based on either the return header time, or or (for asynchronous use), the transaction time</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>_type</td>\\n                <td/>\\n                <td>0..*</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>One or more parameters, each containing one or more comma-delimited FHIR resource types to include in the return resources. In the absense of any specified types, the server returns all resource types</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>_count</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#integer\\\">integer</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>See discussion below on the utility of paging through the results of the $everything operation</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>return</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"bundle.html\\\">Bundle</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The bundle type is &quot;searchset&quot;</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n            <div>\\n              <p>The key differences between this operation and simply searching the group's patients compartment are:</p>\\n\\n              <ul>\\n\\n                <li>unless the client requests otherwise, the server returns the entire result set in a single bundle (rather than using paging)</li>\\n\\n                <li>the server is responsible for determining what resources to return as included resources (rather than the client specifying which ones).</li>\\n\\n              </ul>\\n\\n              <p>This frees the client from needing to determine what it could or should ask for, particularly with regard to included resources.</p>\\n\\n              <p>It is assumed that the server has identified and secured the context appropriately, and can either associate the authorization context with a particular group, or determine whether the context has the rights to the nominated group, if there is one, or can determine an appropriate list of groups to provide data for from the context of the request.   If there is no nominated group (GET /[base]/Group/$everything) and the context is not associated with a single group record, the actual list of groups is all groups that the user associated with the request has access to. In such cases, the server may choose to return an error rather than all the records (and is likely to do so, but not required to).  Specifying the relationship between the context, a user and groups is outside the scope of this specification (though see \\n                <a href=\\\"http://hl7.org/fhir/smart-app-launch\\\">The Smart App Launch Implementation Guide</a>.\\n              </p>\\n\\n              <p>The return bundle from this operation is usually rather a lot of data; servers typically choose to require that such requests are made \\n                <a href=\\\"async.html\\\">asynchronously</a>, and associated with \\n                <a href=\\\"resource-formats.html#bulk\\\">bulk data formats</a>. Alternatively, clients may choose to page through the result set (or servers may require this). Paging through the results is done the same as for \\n                <a href=\\\"http.html#paging\\\">Searching</a>, using the \\n                <a href=\\\"search.html#count\\\">_count</a> parameter, and Bundle links. Implementers should note that paging will be slower than simply returning all the results at once (more network traffic, multiple latency delays) but may be required in order not to exhaust available memory reading or writing the whole response in a single package. Unlike searching, there is no inherent user-display order for the $everything operation. Servers might consider sorting the returned resources in descending order of last record update, but are not required to do so.\\n              </p>\\n\\n              <p>The _since parameter is provided to support periodic queries to get additional information that has changed about the group since the last query. This means that the _since parameter is based on record time. The value of the _since parameter should be set to the time from the server. If using direct response, this is the timestamp in the response header. If using the async interface, this is the transaction timestamp in the json response. Servers should ensure that the timestamps a managed such that the client does not miss any changes. Clients should be able to handle getting the same response more than once in the case that the transaction falls on a time boundary. Clients should ensure that the other query parameters are constant to ensure a coherent set of records when doing periodic queries.</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Fetch a group of Patient Records\",
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Group-everything\",
  \"version\": \"5.0.0\"
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
    }
  ],
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"This operation is used to return all the information related to one or more products described in the resource or context on which this operation is invoked. The response is a bundle of type \\\"searchset\\\". At a minimum, the product resource(s) itself is returned, along with any other resources that the server has that are related to the products(s), and that are available for the given user. This is typically the marketing authorizations, ingredients, packages, therapeutic indications and so on. The server also returns whatever resources are needed to support the records - e.g. linked organizations, document references etc.\",
  \"experimental\": false,
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
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
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"MedicinalProductDefinition\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/MedicinalProductDefinition/$everything</p>\\n            <p>URL: [base]/MedicinalProductDefinition/[id]/$everything</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>_since</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#instant\\\">instant</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Resources updated after this period will be included in the response. The intent of this parameter is to allow a client to request only records that have changed since the last request, based on either the return header time, or or (for asynchronous use), the transaction time</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>_count</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#integer\\\">integer</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>See discussion below on the utility of paging through the results of the $everything operation</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>return</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"bundle.html\\\">Bundle</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The bundle type is &quot;searchset&quot;</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n            <div>\\n              <p>The key differences between this operation and simply performing a search and using _include and _revinclude are:</p>\\n\\n              <ul>\\n\\n                <li>unless the client requests otherwise, the server returns the entire result set in a single bundle (rather than using paging)</li>\\n\\n                <li>the server is responsible for determining what resources to return as included resources (rather than the client specifying which ones).</li>\\n\\n              </ul>\\n\\n              <p>This frees the client from needing to determine what it could or should ask for, particularly with regard to included resources. It also makes for a much shorter and easier to construct query string. Servers should consider returning appropriate Provenance and AuditTrail on the returned resources, even though these are not directly part of the product data.</p>\\n\\n              <p>When this operation is used to access multiple product records at once, the return bundle could be rather a lot of data; servers may choose to require that such requests are made \\n                <a href=\\\"async.html\\\">asynchronously</a>, and associated with \\n                <a href=\\\"resource-formats.html#bulk\\\">bulk data formats</a>. Alternatively, clients may choose to page through the result set (or servers may require this). Paging through the results is done the same as for \\n                <a href=\\\"http.html#paging\\\">Searching</a>, using the \\n                <a href=\\\"search.html#count\\\">_count</a> parameter, and Bundle links. Implementers should note that paging will be slower than simply returning all the results at once (more network traffic, multiple latency delays) but may be required in order not to exhaust available memory reading or writing the whole response in a single package. Unlike searching, there is no inherent user-display order for the $everything operation. Servers might consider sorting the returned resources in descending order of last record update, but are not required to do so.\\n              </p>\\n\\n              <p>The _since parameter is provided to support periodic queries to get additional information that has changed about the product since the last query. This means that the _since parameter is based on record time. The value of the _since parameter should be set to the time from the server. If using direct response, this is the timestamp in the response header. If using the async interface, this is the transaction timestamp in the json response. Servers should ensure that the timestamps a managed such that the client does not miss any changes. Clients should be able to handle getting the same response more than once in the case that the transaction falls on a time boundary. Clients should ensure that the other query parameters are constant to ensure a coherent set of records when doing periodic queries.</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Fetch Product Record\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/MedicinalProductDefinition-everything\",
  \"version\": \"5.0.0\"
}"))
(define (MedicinalProductDefinition-everything-operation handler)
  (define code "everything")
  (list (operation-entry 'type code "MedicinalProductDefinition" handler)
        (operation-entry 'instance code "MedicinalProductDefinition" handler)))
(define Patient-everything-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
  \"code\": \"everything\",
  \"comment\": \"The key differences between this operation and simply searching the patient compartment are:    \\n\\n* unless the client requests otherwise, the server returns the entire result set in a single bundle (rather than using paging)  \\n* the server is responsible for determining what resources to return as included resources (rather than the client specifying which ones). \\n\\nThis frees the client from needing to determine what it could or should ask for, particularly with regard to included resources. Servers should consider returning appropriate Provenance and AuditTrail on the returned resources, even though these are not directly part of the patient compartment. \\n\\nIt is assumed that the server has identified and secured the context appropriately, and can either associate the authorization context with a single patient, or determine whether the context has the rights to the nominated patient, if there is one, or can determine an appropriate list of patients to provide data for from the context of the request.   If there is no nominated patient (GET /[base]/Patient/$everything) and the context is not associated with a single patient record, the actual list of patients is all patients that the user associated with the request has access to. This may be all patients in the family that the patient has access to, or it may be all patients that a care provider has access to, or all patients on the entire record system. In such cases, the server may choose to return an error rather than all the records.  Specifying the relationship between the context, a user and patient records is outside the scope of this specification (though see [The Smart App Launch Implementation Guide](http://hl7.org/fhir/smart-app-launch). \\n\\nWhen this operation is used to access multiple patient records at once, the return bundle could be rather a lot of data; servers may choose to require that such requests are made [asynchronously](async.html), and associated with [bulk data formats](resource-formats.html#bulk). Alternatively, clients may choose to page through the result set (or servers may require this). Paging through the results is done the same as for [Searching](http.html#paging), using the [_count](search.html#count) parameter, and Bundle links. Implementers should note that paging will be slower than simply returning all the results at once (more network traffic, multiple latency delays) but may be required in order not to exhaust available memory reading or writing the whole response in a single package. Unlike searching, there is no inherent user-display order for the $everything operation. Servers might consider sorting the returned resources in descending order of last record update, but are not required to do so.\\n\\nThe _since parameter is provided to support periodic queries to get additional information that has changed about the patient since the last query. This means that the _since parameter is based on record time. The value of the _since parameter should be set to the time from the server. If using direct response, this is the timestamp in the response header. If using the async interface, this is the transaction timestamp in the json response. Servers should ensure that the timestamps a managed such that the client does not miss any changes. Clients should be able to handle getting the same response more than once in the case that the transaction falls on a time boundary. Clients should ensure that the other query parameters are constant to ensure a coherent set of records when doing periodic queries.\",
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
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"This operation is used to return all the information related to one or more patients described in the resource or context on which this operation is invoked. The response is a bundle of type \\\"searchset\\\". At a minimum, the patient resource(s) itself is returned, along with any other resources that the server has that are related to the patient(s), and that are available for the given user. The server also returns whatever resources are needed to support the records - e.g. linked practitioners, medications, locations, organizations etc.   \\n\\nThe intended use for this operation is to provide a patient with access to their entire record (e.g. \\\"Blue Button\\\"), or for provider or other user to perform a bulk data download.  The server SHOULD return at least all resources that it has that are in the patient compartment for the identified patient(s), and any resource referenced from those, including binaries and attachments. The server SHOULD resolve version-specific references by returning the explicitly named version. In the US Realm, at a minimum, the resources returned SHALL include all the data covered by the meaningful use common data elements as defined in the US Core Implementation Guide. Other applicable implementation guides may make additional rules about how much information that is returned.\",
  \"experimental\": false,
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
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
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/Patient/$everything</p>\\n            <p>URL: [base]/Patient/[id]/$everything</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>start</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#date\\\">date</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The date range relates to care dates, not record currency dates - e.g. all records relating to care provided in a certain date range. If no start date is provided, all records prior to the end date are in scope.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>end</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#date\\\">date</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The date range relates to care dates, not record currency dates - e.g. all records relating to care provided in a certain date range. If no end date is provided, all records subsequent to the start date are in scope.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>_since</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#instant\\\">instant</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Resources updated after this period will be included in the response. The intent of this parameter is to allow a client to request only records that have changed since the last request, based on either the return header time, or or (for asynchronous use), the transaction time</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>_type</td>\\n                <td/>\\n                <td>0..*</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>One or more parameters, each containing one or more comma-delimited FHIR resource types to include in the return resources. In the absence of any specified types, the server returns all resource types</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>_count</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#integer\\\">integer</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>See discussion below on the utility of paging through the results of the $everything operation</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>return</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"bundle.html\\\">Bundle</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The bundle type is &quot;searchset&quot;</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n            <div>\\n              <p>The key differences between this operation and simply searching the patient compartment are:</p>\\n\\n              <ul>\\n\\n                <li>unless the client requests otherwise, the server returns the entire result set in a single bundle (rather than using paging)</li>\\n\\n                <li>the server is responsible for determining what resources to return as included resources (rather than the client specifying which ones).</li>\\n\\n              </ul>\\n\\n              <p>This frees the client from needing to determine what it could or should ask for, particularly with regard to included resources. Servers should consider returning appropriate Provenance and AuditTrail on the returned resources, even though these are not directly part of the patient compartment.</p>\\n\\n              <p>It is assumed that the server has identified and secured the context appropriately, and can either associate the authorization context with a single patient, or determine whether the context has the rights to the nominated patient, if there is one, or can determine an appropriate list of patients to provide data for from the context of the request.   If there is no nominated patient (GET /[base]/Patient/$everything) and the context is not associated with a single patient record, the actual list of patients is all patients that the user associated with the request has access to. This may be all patients in the family that the patient has access to, or it may be all patients that a care provider has access to, or all patients on the entire record system. In such cases, the server may choose to return an error rather than all the records.  Specifying the relationship between the context, a user and patient records is outside the scope of this specification (though see \\n                <a href=\\\"http://hl7.org/fhir/smart-app-launch\\\">The Smart App Launch Implementation Guide</a>.\\n              </p>\\n\\n              <p>When this operation is used to access multiple patient records at once, the return bundle could be rather a lot of data; servers may choose to require that such requests are made \\n                <a href=\\\"async.html\\\">asynchronously</a>, and associated with \\n                <a href=\\\"resource-formats.html#bulk\\\">bulk data formats</a>. Alternatively, clients may choose to page through the result set (or servers may require this). Paging through the results is done the same as for \\n                <a href=\\\"http.html#paging\\\">Searching</a>, using the \\n                <a href=\\\"search.html#count\\\">_count</a> parameter, and Bundle links. Implementers should note that paging will be slower than simply returning all the results at once (more network traffic, multiple latency delays) but may be required in order not to exhaust available memory reading or writing the whole response in a single package. Unlike searching, there is no inherent user-display order for the $everything operation. Servers might consider sorting the returned resources in descending order of last record update, but are not required to do so.\\n              </p>\\n\\n              <p>The _since parameter is provided to support periodic queries to get additional information that has changed about the patient since the last query. This means that the _since parameter is based on record time. The value of the _since parameter should be set to the time from the server. If using direct response, this is the timestamp in the response header. If using the async interface, this is the transaction timestamp in the json response. Servers should ensure that the timestamps a managed such that the client does not miss any changes. Clients should be able to handle getting the same response more than once in the case that the transaction falls on a time boundary. Clients should ensure that the other query parameters are constant to ensure a coherent set of records when doing periodic queries.</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Fetch Patient Record\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Patient-everything\",
  \"version\": \"5.0.0\"
}"))
(define (Patient-everything-operation handler)
  (define code "everything")
  (list (operation-entry 'type code "Patient" handler)
        (operation-entry 'instance code "Patient" handler)))
(define example-query-high-risk-definition
  (string->jsexpr
   "{
  \"code\": \"example-query-high-risk\",
  \"description\": \"Example Named Query of Patients based on risk assessments\",
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
  \"resource\": [
    \"Patient\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\"><p><b>Generated Narrative: OperationDefinition</b><a name=\\\"example-query-high-risk\\\"> </a></p><div style=\\\"display: inline-block; background-color: #d9e0e7; padding: 6px; margin: 4px; border: 1px solid #8da1b4; border-radius: 5px; line-height: 60%\\\"><p style=\\\"margin-bottom: 0px\\\">Resource OperationDefinition &quot;example-query-high-risk&quot; </p></div><p><b>url</b>: <code>http://hl7.org/fhir/OperationDefinition/example-query-high-risk</code></p><p><b>version</b>: 0.0.1</p><p><b>name</b>: ExampleOfHighRiskPatientQuery</p><p><b>title</b>: Example of High-Risk Patient Query</p><p><b>status</b>: draft</p><p><b>kind</b>: query</p><p><b>description</b>: Example Named Query of Patients based on risk assessments</p><p><b>code</b>: example-query-high-risk</p><p><b>resource</b>: Patient</p><p><b>system</b>: false</p><p><b>type</b>: true</p><p><b>instance</b>: false</p><blockquote><p><b>parameter</b></p><p><b>name</b>: ward</p><p><b>use</b>: in</p><p><b>min</b>: 0</p><p><b>max</b>: *</p><p><b>documentation</b>: Ward filters to apply to patient locations</p><p><b>type</b>: string</p><p><b>searchType</b>: reference</p></blockquote><blockquote><p><b>parameter</b></p><p><b>name</b>: result</p><p><b>use</b>: out</p><p><b>min</b>: 1</p><p><b>max</b>: 1</p><p><b>documentation</b>: Searchset bundle</p><p><b>type</b>: Bundle</p></blockquote></div>\",
    \"status\": \"generated\"
  },
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
  \"comment\": \"The value set expansion returned by this query should be treated as a transient result that will change over time (whether it does or not depends on how the value set is specified), so applications should repeat the operation each time the value set is used.  \\n\\nWhen available, ValueSet.status and ValueSet.version from the ValueSet resource instance which contains the definition SHALL be persisted to the ValueSet resource instance which contains the expansion.   \\n\\nIf the expansion is too large (at the discretion of the server), the server MAY return an error (OperationOutcome with code too-costly). Clients can work through large flat expansions in a set of pages (partial views of the full expansion) instead of just getting the full expansion in a single exchange by using offset and count parameters, or use the count parameter to request a subset of the expansion for limited purposes. Servers are not obliged to support paging, but if they do, SHALL support both the offset and count parameters. Hierarchical expansions are not subject to paging and servers simply return the entire expansion.  \\n\\nDifferent servers may return different results from expanding a value set for the following reasons:  \\n\\n* The underlying code systems are different (e.g. different versions, possibly with different defined behavior) \\n* The server optimizes filter includes differently, such as sorting by code frequency \\n* Servers introduce arbitrary groups to assist a user to navigate the lists based either on extensions in the definition, or additional knowledge available to the server\\n\\nWhen a server cannot correctly expand a value set because it does not fully understand the code systems (e.g. it has the wrong version, or incomplete definitions) then it SHALL return an error. If the value set itself is unbounded due to the inclusion of post-coordinated value sets (e.g. SNOMED CT, UCUM), then the extension [http://hl7.org/fhir/StructureDefinition/valueset-unclosed](http://hl7.org/fhir/extensions/StructureDefinition-valueset-unclosed.html) can be used to indicate that the expansion is incomplete\",
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
  \"date\": \"2023-03-26T15:21:02+11:00\",
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
  },
  \"name\": \"Expand\",
  \"parameter\": [
    {
      \"documentation\": \"A canonical reference to a value set. The server must know the value set (e.g. it is defined explicitly in the server's value sets, or it is defined implicitly by some code system known to the server\",
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
      \"documentation\": \"The supplement must be used when performing an expansion. Use of this parameter should result in $expand behaving the same way as if the supplements were included in the value set definition using the [http://hl7.org/fhir/StructureDefinition/valueset-supplement](http://hl7.org/fhir/extensions/StructureDefinition-valueset-supplement.html)\",
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
      \"documentation\": \"Controls whether or not the value set expansion might include\\r\\n\\r\\n* codes from the CodeSystem with a notSelectable property set to true as specified in [status](codesystem.html#status)] and in [Concept Properties](codesystem-concept-properties.html)\\r\\n* nested contains with no code (see [Contains](valueset-definitions.html#ValueSet.expansion.contains.code))\\r\\n* nested contains in the ValueSet with [abstract = true](valueset-definitions.html#ValueSet.expansion.contains.abstract)\\r\\n\\r\\nOne purpose of such concepts is helping a user navigate through the list efficiently. If excludeNotForUI is set to true, the concepts as described above will be excluded from the expansion. If excludeNotForUI is set to false (default), all concepts as described above may be part of the expansion. In the FHIR Specification itself, the value set expansions are generated with excludeNotForUI = false, and the expansions used when generating schema / code etc., or performing validation, are all excludeNotForUI = true.\",
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
  \"status\": \"active\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/ValueSet/$expand</p>\\n            <p>URL: [base]/ValueSet/[id]/$expand</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>url</td>\\n                <td>type</td>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>A canonical reference to a value set. The server must know the value set (e.g. it is defined explicitly in the server's value sets, or it is defined implicitly by some code system known to the server</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>valueSet</td>\\n                <td>type</td>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"valueset.html\\\">ValueSet</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The value set is provided directly as part of the request. Servers may choose not to accept value sets in this fashion</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>valueSetVersion</td>\\n                <td>type</td>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The identifier that is used to identify a specific version of the value set to be used when generating the expansion. This is an arbitrary value managed by the value set author and is not expected to be globally unique. For example, it might be a timestamp (e.g. yyyymmdd) if a managed version is not available.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>context</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The context of the value set, so that the server can resolve this to a value set to expand. The recommended format for this URI is [Structure Definition URL]#[name or path into structure definition] e.g. http://hl7.org/fhir/StructureDefinition/observation-hspc-height-hspcheight#Observation.interpretation. Other forms may be used but are not defined. This form is only usable if the terminology server also has access to the conformance registry that the server is using, but can be used to delegate the mapping from an application context to a binding at run-time</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>contextDirection</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>If a context is provided, a context direction may also be provided. Valid values are:</p>\\n\\n                    <ul>\\n\\n                      <li>'incoming': the codes a client can use for PUT/POST operations,  and</li>\\n\\n                      <li>'outgoing', the codes a client might receive from the server.</li>\\n\\n                    </ul>\\n\\n                    <p>The purpose is to inform the server whether to use the value set associated with the context for reading or writing purposes (note: for most elements, this is the same value set, but there are a few elements where the reading and writing value sets are different)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>filter</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>A text filter that is applied to restrict the codes that are returned (this is useful in a UI context). The interpretation of this is delegated to the server in order to allow to determine the most optimal search approach for the context. The server can document the way this parameter works in \\n                      <a href=\\\"terminologycapabilities.html\\\">TerminologyCapabilities</a>..expansion.textFilter. Typical usage of this parameter includes functionality like:\\n                    </p>\\n\\n                    <ul>\\n\\n                      <li>using left matching e.g. &quot;acut ast&quot;</li>\\n\\n                      <li>allowing for wild cards such as %, &amp;, ?</li>\\n\\n                      <li>searching on definition as well as display(s)</li>\\n\\n                      <li>allowing for search conditions (and / or / exclusions)</li>\\n\\n                    </ul>\\n\\n                    <p>Text Search engines such as Lucene or Solr, long with their considerable functionality, might also be used. The optional text search might also be code system specific, and servers might have different implementations for different code systems</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>date</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#dateTime\\\">dateTime</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The date for which the expansion should be generated.  if a date is provided, it means that the server should use the value set / code system definitions as they were on the given date, or return an error if this is not possible.  Normally, the date is the current conditions (which is the default value) but under some circumstances, systems need to generate an expansion as it would have been in the past. A typical example of this would be where code selection is constrained to the set of codes that were available when the patient was treated, not when the record is being edited. Note that which date is appropriate is a matter for implementation policy.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>offset</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#integer\\\">integer</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Paging support - where to start if a subset is desired (default = 0). Offset is number of records (not number of pages)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>count</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#integer\\\">integer</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Paging support - how many codes should be provided in a partial page view. Paging only applies to flat expansions - servers ignore paging if the expansion is not flat.  If count = 0, the client is asking how large the expansion is. Servers SHOULD honor this request for hierarchical expansions as well, and simply return the overall count</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>includeDesignations</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Controls whether concept designations are to be included or excluded in value set expansions</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>designation</td>\\n                <td/>\\n                <td>0..*</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>A \\n                      <a href=\\\"search.html#token\\\">token</a> that specifies a system+code that is either a use or a language. Designations that match by language or use are included in the expansion. If no designation is specified, it is at the server discretion which designations to return\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>includeDefinition</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Controls whether the value set definition is included or excluded in value set expansions</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>activeOnly</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Controls whether inactive concepts are included or excluded in value set expansions. Note that if the value set explicitly specifies that inactive codes are included, this parameter can still remove them from a specific expansion, but this parameter cannot include them if the value set excludes them</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>useSupplement</td>\\n                <td/>\\n                <td>0..*</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The supplement must be used when performing an expansion. Use of this parameter should result in $expand behaving the same way as if the supplements were included in the value set definition using the \\n                      <a href=\\\"http://hl7.org/fhir/extensions/StructureDefinition-valueset-supplement.html\\\">http://hl7.org/fhir/StructureDefinition/valueset-supplement</a>\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>excludeNested</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Controls whether or not the value set expansion may nest codes or not (i.e. ValueSet.expansion.contains.contains). If excludeNested is set to true, the expansion MUST be flat (no nesting). If excludeNested is set to false (default),  however, nesting is possible but not required</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>excludeNotForUI</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Controls whether or not the value set expansion might include</p>\\n\\n                    <ul>\\n\\n                      <li>codes from the CodeSystem with a notSelectable property set to true as specified in \\n                        <a href=\\\"codesystem.html#status\\\">status</a>] and in \\n                        <a href=\\\"codesystem-concept-properties.html\\\">Concept Properties</a>\\n                      </li>\\n\\n                      <li>nested contains with no code (see \\n                        <a href=\\\"valueset-definitions.html#ValueSet.expansion.contains.code\\\">Contains</a>)\\n                      </li>\\n\\n                      <li>nested contains in the ValueSet with \\n                        <a href=\\\"valueset-definitions.html#ValueSet.expansion.contains.abstract\\\">abstract = true</a>\\n                      </li>\\n\\n                    </ul>\\n\\n                    <p>One purpose of such concepts is helping a user navigate through the list efficiently. If excludeNotForUI is set to true, the concepts as described above will be excluded from the expansion. If excludeNotForUI is set to false (default), all concepts as described above may be part of the expansion. In the FHIR Specification itself, the value set expansions are generated with excludeNotForUI = false, and the expansions used when generating schema / code etc., or performing validation, are all excludeNotForUI = true.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>excludePostCoordinated</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Controls whether or not the value set expansion includes post coordinated codes</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>displayLanguage</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Specifies the language to be used for description in the expansions i.e. the language to be used for ValueSet.expansion.contains.display</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>property</td>\\n                <td/>\\n                <td>0..*</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>A request to return a particular property in the expansion. The returned property may include subproperties. May be either a code from the code system definition (convenient) or a the formal URI that refers to the property. Note that property names can clash, so using a URI is recommended. The special value '*' means all properties and their sub-properties known to the server</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>exclude-system</td>\\n                <td/>\\n                <td>0..*</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Code system, or a particular version of a code system to be excluded from the value set expansion. The format is the same as a canonical URL: [system]|[version] - e.g. http://loinc.org|2.56</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>system-version</td>\\n                <td/>\\n                <td>0..*</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Specifies a version to use for a system, if the value set does not specify which one to use. The format is the same as a canonical URL: [system]|[version] - e.g. http://loinc.org|2.56</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>check-system-version</td>\\n                <td/>\\n                <td>0..*</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Edge Case: Specifies a version to use for a system. If a value set specifies a different version, an error is returned instead of the expansion. The format is the same as a canonical URL: [system]|[version] - e.g. http://loinc.org|2.56</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>force-system-version</td>\\n                <td/>\\n                <td>0..*</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Edge Case: Specifies a version to use for a system. This parameter overrides any specified version in the value set (and any it depends on). The format is the same as a canonical URL: [system]|[version] - e.g. http://loinc.org|2.56. Note that this has obvious safety issues, in that it may result in a value set expansion giving a different list of codes that is both wrong and unsafe, and implementers should only use this capability reluctantly. It primarily exists to deal with situations where specifications have fallen into decay as time passes. If the value is override, the version used SHALL explicitly be represented in the expansion parameters</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>return</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"valueset.html\\\">ValueSet</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The result of the expansion. Servers generating expansions SHOULD ensure that all the parameters that affect the contents of the expansion are recorded in the ValueSet.expansion.parameter list</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n            <div>\\n              <p>The value set expansion returned by this query should be treated as a transient result that will change over time (whether it does or not depends on how the value set is specified), so applications should repeat the operation each time the value set is used.</p>\\n\\n              <p>When available, ValueSet.status and ValueSet.version from the ValueSet resource instance which contains the definition SHALL be persisted to the ValueSet resource instance which contains the expansion.</p>\\n\\n              <p>If the expansion is too large (at the discretion of the server), the server MAY return an error (OperationOutcome with code too-costly). Clients can work through large flat expansions in a set of pages (partial views of the full expansion) instead of just getting the full expansion in a single exchange by using offset and count parameters, or use the count parameter to request a subset of the expansion for limited purposes. Servers are not obliged to support paging, but if they do, SHALL support both the offset and count parameters. Hierarchical expansions are not subject to paging and servers simply return the entire expansion.</p>\\n\\n              <p>Different servers may return different results from expanding a value set for the following reasons:</p>\\n\\n              <ul>\\n\\n                <li>The underlying code systems are different (e.g. different versions, possibly with different defined behavior)</li>\\n\\n                <li>The server optimizes filter includes differently, such as sorting by code frequency</li>\\n\\n                <li>Servers introduce arbitrary groups to assist a user to navigate the lists based either on extensions in the definition, or additional knowledge available to the server</li>\\n\\n              </ul>\\n\\n              <p>When a server cannot correctly expand a value set because it does not fully understand the code systems (e.g. it has the wrong version, or incomplete definitions) then it SHALL return an error. If the value set itself is unbounded due to the inclusion of post-coordinated value sets (e.g. SNOMED CT, UCUM), then the extension \\n                <a href=\\\"http://hl7.org/fhir/extensions/StructureDefinition-valueset-unclosed.html\\\">http://hl7.org/fhir/StructureDefinition/valueset-unclosed</a> can be used to indicate that the expansion is incomplete\\n              </p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Value Set Expansion\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/ValueSet-expand\",
  \"version\": \"5.0.0\"
}"))
(define (expand-operation handler)
  (define code "expand")
  (list (operation-entry 'type code "ValueSet" handler)
        (operation-entry 'instance code "ValueSet" handler)))
(define filter-definition
  (string->jsexpr
   "{
  \"affectsState\": true,
  \"code\": \"filter\",
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
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"Filter content from an array in a large resource such as List or Group. See [Operations for Large Resources](operations-for-large-resources.html).\",
  \"experimental\": false,
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
  \"id\": \"Resource-filter\",
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
  },
  \"name\": \"Filter\",
  \"parameter\": [
    {
      \"documentation\": \"Resource containing content that acts as a filter. See [Operations for Large Resources](operations-for-large-resources.html).\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"probes\",
      \"type\": \"Resource\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Resource containing content matching the filter. See [Operations for Large Resources](operations-for-large-resources.html).\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"return\",
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
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/Resource/[id]/$filter</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>probes</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"resource.html\\\">Resource</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Resource containing content that acts as a filter. See \\n                      <a href=\\\"operations-for-large-resources.html\\\">Operations for Large Resources</a>.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>return</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"resource.html\\\">Resource</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Resource containing content matching the filter. See \\n                      <a href=\\\"operations-for-large-resources.html\\\">Operations for Large Resources</a>.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Filter an array in a large resource\",
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Resource-filter\",
  \"version\": \"5.0.0\"
}"))
(define (filter-operation handler)
  (define code "filter")
  (list (operation-entry 'instance code "Resource" handler)))
(define find-matches-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
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
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"Given a set of properties (and text), return one or more possible matching codes\\n\\nThis operation takes a set of properties, and examines the code system looking for codes in the code system that match a set of known properties. \\n\\nWhen looking for matches, there are 3 possible types of match:\\n* a complete match - a code that represents all the provided properties correctly\\n* a partial match - a code that represents some of the provided properties correctly, and not others \\n* a possible match - a code that may represent the provided properties closely, but may capture less or more precise information for some of the properties\\n\\nThe $find-matches operation can be called in one of 2 modes:\\n* By a human, looking for the best match for a set of properties. In this mode, the server returns a list of complete, possible or partial matches (possibly with comments), so that the user can choose (or not) the most appropriate code\\n* By a machine (typically in a system interface performing a transformation). In this mode, the server returns only a list of complete and partial matches, but no possible matches. The machine can choose a code from the list (or not) based on what properties are not coded\\n\\nThese modes are differentiated by the 'exact' parameter, so the client can indicate whether it only wants exact matches (including partial matches) or whether potential matches based on text matching are desired\\n \\nThe find-matches operation is still preliminary. The interface can be expected to change as more experience is gained from implementations.\",
  \"experimental\": false,
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
  },
  \"name\": \"FindMatches\",
  \"parameter\": [
    {
      \"documentation\": \"The system in which composition is to be performed. This must be provided unless the operation is invoked on a code system instance\",
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
      \"documentation\": \"The version of the system for the inferencing to be performed\",
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
              \"valueUri\": \"Coding\"
            },
            {
              \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
              \"valueUri\": \"boolean\"
            },
            {
              \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
              \"valueUri\": \"code\"
            },
            {
              \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
              \"valueUri\": \"dateTime\"
            },
            {
              \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
              \"valueUri\": \"integer\"
            },
            {
              \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
              \"valueUri\": \"string\"
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
                  \"valueUri\": \"Coding\"
                },
                {
                  \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                  \"valueUri\": \"boolean\"
                },
                {
                  \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                  \"valueUri\": \"code\"
                },
                {
                  \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                  \"valueUri\": \"dateTime\"
                },
                {
                  \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                  \"valueUri\": \"integer\"
                },
                {
                  \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                  \"valueUri\": \"string\"
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
                  \"valueUri\": \"Coding\"
                },
                {
                  \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                  \"valueUri\": \"boolean\"
                },
                {
                  \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                  \"valueUri\": \"code\"
                },
                {
                  \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                  \"valueUri\": \"dateTime\"
                },
                {
                  \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                  \"valueUri\": \"integer\"
                },
                {
                  \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                  \"valueUri\": \"string\"
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
                      \"valueUri\": \"Coding\"
                    },
                    {
                      \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                      \"valueUri\": \"boolean\"
                    },
                    {
                      \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                      \"valueUri\": \"code\"
                    },
                    {
                      \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                      \"valueUri\": \"dateTime\"
                    },
                    {
                      \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                      \"valueUri\": \"integer\"
                    },
                    {
                      \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                      \"valueUri\": \"string\"
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
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/CodeSystem/$find-matches</p>\\n            <p>URL: [base]/CodeSystem/[id]/$find-matches</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>system</td>\\n                <td>type</td>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The system in which composition is to be performed. This must be provided unless the operation is invoked on a code system instance</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>version</td>\\n                <td>type</td>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The version of the system for the inferencing to be performed</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>property</td>\\n                <td/>\\n                <td>0..*</td>\\n                <td/>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>One or more properties that contain information to be composed into the code</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>property.code</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Identifies the property provided</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>property.value</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#Coding\\\">Coding</a> | \\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a> | \\n                  <a href=\\\"datatypes.html#code\\\">code</a> | \\n                  <a href=\\\"datatypes.html#dateTime\\\">dateTime</a> | \\n                  <a href=\\\"datatypes.html#integer\\\">integer</a> | \\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The value of the property provided</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>property.subproperty</td>\\n                <td/>\\n                <td>0..*</td>\\n                <td/>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Nested Properties (mainly used for SNOMED CT composition, for relationship Groups)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>property.subproperty.code</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Identifies the sub-property provided</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>property.subproperty.value</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#Coding\\\">Coding</a> | \\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a> | \\n                  <a href=\\\"datatypes.html#code\\\">code</a> | \\n                  <a href=\\\"datatypes.html#dateTime\\\">dateTime</a> | \\n                  <a href=\\\"datatypes.html#integer\\\">integer</a> | \\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The value of the sub-property provided</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>exact</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Whether the operation is being used by a human ('false'), or a machine ('true'). If the operation is being used by a human, the terminology server can return a list of possible matches, with commentary. For a machine, the server returns complete or partial matches, not possible matches. The default value is 'false'</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>compositional</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Post-coordinated expressions are allowed to be returned in the matching codes (mainly for SNOMED CT). Default = false</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>match</td>\\n                <td/>\\n                <td>0..*</td>\\n                <td/>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Concepts returned by the server as a result of the inferencing operation</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>match.code</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#Coding\\\">Coding</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>A code that matches the properties provided</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>match.unmatched</td>\\n                <td/>\\n                <td>0..*</td>\\n                <td/>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>One or more properties that contain properties that could not be matched into the code</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>match.unmatched.code</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Identifies the property provided</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>match.unmatched.value</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#Coding\\\">Coding</a> | \\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a> | \\n                  <a href=\\\"datatypes.html#code\\\">code</a> | \\n                  <a href=\\\"datatypes.html#dateTime\\\">dateTime</a> | \\n                  <a href=\\\"datatypes.html#integer\\\">integer</a> | \\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The value of the property provided</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>match.unmatched.property</td>\\n                <td/>\\n                <td>0..*</td>\\n                <td/>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Nested Properties (mainly used for SNOMED CT composition, for relationship Groups)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>match.unmatched.property.code</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Identifies the sub-property provided</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>match.unmatched.property.value</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#Coding\\\">Coding</a> | \\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a> | \\n                  <a href=\\\"datatypes.html#code\\\">code</a> | \\n                  <a href=\\\"datatypes.html#dateTime\\\">dateTime</a> | \\n                  <a href=\\\"datatypes.html#integer\\\">integer</a> | \\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The value of the sub-property provided</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>match.comment</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Information about the quality of the match, if operation is for a human</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Finding codes based on supplied properties\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/CodeSystem-find-matches\",
  \"version\": \"5.0.0\"
}"))
(define (find-matches-operation handler)
  (define code "find-matches")
  (list (operation-entry 'type code "CodeSystem" handler)
        (operation-entry 'instance code "CodeSystem" handler)))
(define find-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
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
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"This operation allows a client to find an identified list for a particular function by its function. The operation takes two parameters, the identity of a patient, and the name of a functional list.     The list of defined functional lists can be found at [Current Resource Lists](lifecycle.html#lists). Applications are not required to support all the lists, and may define additional lists of their own.   If the system is able to locate a list that serves the identified purpose, it returns it as the body of the response with a 200 OK status. If the resource cannot be located, the server returns a 404 not found (optionally with an OperationOutcome resource)\",
  \"experimental\": false,
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
  },
  \"name\": \"Find\",
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
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/List/$find</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>patient</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#id\\\">id</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The id of a patient resource located on the server on which this operation is executed</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>name</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The code for the functional list that is being found</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n            <div>\\n              <p>Note that servers may support searching by a functional list, and not support this operation that allows clients to find the list directly</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Find a functional list\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/List-find\",
  \"version\": \"5.0.0\"
}"))
(define (find-operation handler)
  (define code "find")
  (list (operation-entry 'type code "List" handler)))
(define generate-definition
  (string->jsexpr
   "{
  \"affectsState\": true,
  \"code\": \"generate\",
  \"comment\": \"The server either returns a search result containing a single document reference, \\nor it returns an error. \\nIf the URI refers to another server, it is at the discretion of the \\nserver whether to retrieve it or return an error.\",
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
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"A client can ask a server to generate a document reference from a document.\\nThe server reads the existing document and generates a matching DocumentReference\\nresource, or returns one it has previously generated. Servers may be able to \\nreturn or generate document references for the following types of content:\",
  \"experimental\": false,
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
  \"id\": \"DocumentReference-generate\",
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
  },
  \"name\": \"Generate\",
  \"parameter\": [
    {
      \"documentation\": \"The URL to the source document. This may be a general URL or a Binary or a Composition or a Bundle.\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"url\",
      \"type\": \"uri\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Whether to store the document at the document end-point (/Document) or not, once it is generated (default is for the server to decide).\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"persist\",
      \"type\": \"boolean\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The bundle type is \\\"searchset\\\"containing [DocumentReference](documentreference.html) resource and may include a Binary. If the input url refers to another server, it is at the discretion of the server whether to retrieve it or return an error.\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"return\",
      \"type\": \"Bundle\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"DocumentReference\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/DocumentReference/$generate</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>url</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The URL to the source document. This may be a general URL or a Binary or a Composition or a Bundle.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>persist</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Whether to store the document at the document end-point (/Document) or not, once it is generated (default is for the server to decide).</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>return</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"bundle.html\\\">Bundle</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The bundle type is &quot;searchset&quot;containing \\n                      <a href=\\\"documentreference.html\\\">DocumentReference</a> resource and may include a Binary. If the input url refers to another server, it is at the discretion of the server whether to retrieve it or return an error.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n            <div>\\n              <p>The server either returns a search result containing a single document reference,\\nor it returns an error.\\nIf the URI refers to another server, it is at the discretion of the\\nserver whether to retrieve it or return an error.</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Generate a DocumentReference from a document\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/DocumentReference-generate\",
  \"version\": \"5.0.0\"
}"))
(define (generate-operation handler)
  (define code "generate")
  (list (operation-entry 'type code "DocumentReference" handler)))
(define get-ws-binding-token-definition
  (string->jsexpr
   "{
  \"affectsState\": true,
  \"code\": \"get-ws-binding-token\",
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
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"This operation is used to get a token for a websocket client to use in order to bind to one or more subscriptions.\",
  \"experimental\": false,
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
  \"id\": \"Subscription-get-ws-binding-token\",
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
  },
  \"name\": \"GetWsBindingToken\",
  \"parameter\": [
    {
      \"documentation\": \"At the Instance level, this parameter is ignored. At the Resource level, one or more parameters containing a FHIR id for a Subscription to get a token for. In the absence of any specified ids, the server may either return a token for all Subscriptions available to the caller with a channel-type of websocket or fail the request.\",
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
      \"documentation\": \"An access token that a client may use to show authorization during a websocket connection. The security details of the token are implementation-dependent and beyond the scope of this operation definition.\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"token\",
      \"type\": \"string\",
      \"use\": \"out\"
    },
    {
      \"documentation\": \"The date and time this token is valid until.\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"expiration\",
      \"type\": \"dateTime\",
      \"use\": \"out\"
    },
    {
      \"documentation\": \"The subscriptions this token is valid for.\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"subscription\",
      \"type\": \"string\",
      \"use\": \"out\"
    },
    {
      \"documentation\": \"The URL the client should use to connect to Websockets.\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"websocket-url\",
      \"type\": \"url\",
      \"use\": \"out\"
    }
  ],
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"Subscription\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/Subscription/$get-ws-binding-token</p>\\n            <p>URL: [base]/Subscription/[id]/$get-ws-binding-token</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>id</td>\\n                <td>type</td>\\n                <td>0..*</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#id\\\">id</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>At the Instance level, this parameter is ignored. At the Resource level, one or more parameters containing a FHIR id for a Subscription to get a token for. In the absence of any specified ids, the server may either return a token for all Subscriptions available to the caller with a channel-type of websocket or fail the request.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>token</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>An access token that a client may use to show authorization during a websocket connection. The security details of the token are implementation-dependent and beyond the scope of this operation definition.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>expiration</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#dateTime\\\">dateTime</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The date and time this token is valid until.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>subscription</td>\\n                <td/>\\n                <td>0..*</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The subscriptions this token is valid for.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>websocket-url</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#url\\\">url</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The URL the client should use to connect to Websockets.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Get a binding token for use in a websocket connection\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Subscription-get-ws-binding-token\",
  \"version\": \"5.0.0\"
}"))
(define (get-ws-binding-token-operation handler)
  (define code "get-ws-binding-token")
  (list (operation-entry 'type code "Subscription" handler)
        (operation-entry 'instance code "Subscription" handler)))
(define graph-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
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
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"Return an entire graph of resources based on a [GraphDefinition](graphdefinition.html). The operation is invoked on a specific instance of a resource, and the graph definition tells the server what other resources to return in the same packaage\",
  \"experimental\": false,
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
  },
  \"name\": \"Graph\",
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
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/Resource/[id]/$graph</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>graph</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Servers MAY choose to allow any graph definition to be specified, but MAY require that the client choose a graph definition from a specific list of known supported definitions. The server is not required to support a formal definition of the graph on the end point</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>result</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"bundle.html\\\">Bundle</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The set of resources that were in the graph based on the provided definition</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Return a graph of resources\",
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Resource-graph\",
  \"version\": \"5.0.0\"
}"))
(define (graph-operation handler)
  (define code "graph")
  (list (operation-entry 'instance code "Resource" handler)))
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
    }
  ],
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"Execute a graphql statement on a since resource or against the entire system. See the [Using GraphQL with FHIR](graphql.html) page for further details.\\n\\nFor the purposes of graphQL compatibility, this operation can also be invoked using a POST with the graphQL as the body, or a JSON body (see [graphQL spec](http://graphql.org/) for details)\",
  \"experimental\": false,
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
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
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"Resource\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": true,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/$graphql</p>\\n            <p>URL: [base]/Resource/[id]/$graphql</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>query</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td/>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>result</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"binary.html\\\">Binary</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The content is always returned as application/json; this SHOULD be specified in the Accept header</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Execute a graphql statement\",
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Resource-graphql\",
  \"version\": \"5.0.0\"
}"))
(define (graphql-operation handler)
  (define code "graphql")
  (list (operation-entry 'system code #f handler)
        (operation-entry 'instance code "Resource" handler)))
(define implements-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
  \"code\": \"implements\",
  \"comment\": \"The operation does not perform a full conformance check; in particular it does not check that the profiles align. It merely checks that the behaviors the client wishes to use are provided    Technically, this operation is implemented as follows:   \\n\\n* The server's capability statement must have an entry for each resource in the client's capability statement    \\n* The server's resource support must have matching flags for updateCreate, conditionalCreate, conditionalRead, conditionalUpdate, conditionalPatch, conditionalDelete, searchInclude, searchRevInclude   \\n* The server's capability statement must have a matching interaction for each interaction in the client capability statement (whether or not it is on a resource)   \\n* The server's capability statement must have a search parameter with matching name and definition for any search parameters in the client capability statement   \\n* The server must have an operation definition with a matching reference for any operations in the client capability statement   \\n\\nIf the capability statements match by these rules, then the return value is a 200 OK with an operation outcome that contains no issues with severity >= error. If the capability statement doesn't match, the return value is a 4xx error, with an OperationOutcome with at least one issue with severity >= error\",
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
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"This operation asks the server to check that it implements all the resources, interactions, search parameters, and operations that the client provides in its capability statement. The client provides its capability statement inline, or by referring the server to the canonical URL of its capability statement\",
  \"experimental\": false,
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
  },
  \"name\": \"Implements\",
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
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/CapabilityStatement/$implements</p>\\n            <p>URL: [base]/CapabilityStatement/[id]/$implements</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>server</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>A canonical reference to the server capability statement - use this if the implements is not invoked on an instance (or on the /metadata end-point)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>client</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>A canonical reference to the client capability statement - use this if the implements is not invoked on an instance (or on the /metadata end-point)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>resource</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"capabilitystatement.html\\\">CapabilityStatement</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The client capability statement, provided inline</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>return</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"operationoutcome.html\\\">OperationOutcome</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Outcome of the CapabilityStatement test</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n            <div>\\n              <p>The operation does not perform a full conformance check; in particular it does not check that the profiles align. It merely checks that the behaviors the client wishes to use are provided    Technically, this operation is implemented as follows:</p>\\n\\n              <ul>\\n\\n                <li>The server's capability statement must have an entry for each resource in the client's capability statement</li>\\n\\n                <li>The server's resource support must have matching flags for updateCreate, conditionalCreate, conditionalRead, conditionalUpdate, conditionalPatch, conditionalDelete, searchInclude, searchRevInclude</li>\\n\\n                <li>The server's capability statement must have a matching interaction for each interaction in the client capability statement (whether or not it is on a resource)</li>\\n\\n                <li>The server's capability statement must have a search parameter with matching name and definition for any search parameters in the client capability statement</li>\\n\\n                <li>The server must have an operation definition with a matching reference for any operations in the client capability statement</li>\\n\\n              </ul>\\n\\n              <p>If the capability statements match by these rules, then the return value is a 200 OK with an operation outcome that contains no issues with severity &gt;= error. If the capability statement doesn't match, the return value is a 4xx error, with an OperationOutcome with at least one issue with severity &gt;= error</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Test if a server implements a client's required operations\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/CapabilityStatement-implements\",
  \"version\": \"5.0.0\"
}"))
(define (implements-operation handler)
  (define code "implements")
  (list (operation-entry 'type code "CapabilityStatement" handler)
        (operation-entry 'instance code "CapabilityStatement" handler)))
(define lastn-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
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
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"The *lastn query* meets the common need for searching for the most recent or last n=number of observations for a subject. For example, retrieving the last 5 temperatures for a patient to view trends or fetching the most recent laboratory results or vitals signs. To ask a server to return the last n=number of observations, the *lastn* query uses the [normal search parameters](observation.html#search) defined for the Observation resource.  However, rather than their normal use, they are interpreted as inputs - i.e.. instead of requiring that the resources literally contain the search parameters, they are passed to a server algorithm of some kind that uses them to determine the most appropriate matches.\\n\\nThe request for a lastn query SHALL include:\\n\\n* A `$lastn` operation parameter\\n*  A subject using either the `patient` or `subject`  search parameter\\n*  A `category` parameter and/or a search parameter that contains a code element in its FHIRpath expression.  ( e.g., `code` or `code-value-concept`)\\n\\nThe request for a lastn query MAY include:\\n\\n* Other Observation search parameters and modifiers\\n\\nThe response from a lastn query is a set of observations:\\n\\n*  Filtered by additional parameters\\n   * If not explicitly filtered by status then will include statuses of 'entered-in-error'\\n* 'GROUP BY' `Observation.code`\\n   * Codes SHALL be considered equivalent if the `coding.value` *and* `coding.system` are the same.\\n   * Text only codes SHALL be treated and grouped based on the text.\\n   * For codes with translations (multiple codings), the code translations are assumed to be equal and the grouping by code SHALL follow the transitive property of equality.\\n\\nfor example:\\n\\n|Observation.code for observation a|Observation.code for observation b|Observation.code for observation c|number of groups [codes/text in each group]|    \\n|---|---|---|---|     \\n|a|b|c | 3 [a],[b],[c]|    \\n|a|b|a,c | 2 [a.c],[b]|     \\n|a|b|a,b | 1 [a,b]|    \\n|'textM'|'Text'|'t e x t'|3 ['text'],['Text'],['t e x t']|\\n\\n* Sorted from most recent to the oldest\\n* Limited to the number of requested responses per group specified by the optional *max* query parameter\\n  * In case of a tie - when the effective times for >1 Observations are equal - both will be returned.  Therefore, more Observations may be returned than is specified in *max*.  For example, 4 Observations instead of 3 if the 3rd and 4th most recent observation had the same effective time.\\n* If no maximum number is given then only the most recent Observation in each group is returned.\\n\\nThe set of returned observations should represent distinct real-world observations and not the same observation with changes in status or versions. If there are no matches, the *lastn* query SHALL return an empty search set with no error, but may include an operation outcome with further advice.\",
  \"experimental\": false,
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
  },
  \"name\": \"Lastn\",
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
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/Observation/$lastn</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>max</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#positiveInt\\\">positiveInt</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>\\n                      <code>max</code> is  an optional input parameter to the \\n                      <em>lastn</em> query operation.  It is used to specify the maximum number of Observations to return from each group. For example for the query &quot;Fetch the last 3 results for all vitals for a patient&quot; \\n                      <code>max</code> = 3.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>return</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"bundle.html\\\">Bundle</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The set of most recent N Observations that match the \\n                      <em>lastn</em> query search criteria.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n            <div>\\n              <p>The key differences between this query operation and simply searching Observation using the combination of \\n                <code>_count</code> and \\n                <code>_sort</code> parameters are:\\n              </p>\\n\\n              <ul>\\n\\n                <li>The \\n                  <em>lastn</em> query returns \\n                  <strong>only</strong> the last N resource grouped by code.  Using the _count query method doesn't restrict the total matches so you may need to page through several &quot;A&quot; Observations  before getting to Observation &quot;B&quot;.\\n                </li>\\n\\n                <li>The server is responsible for grouping the observations by codes.  This frees the client from needing to determine which codes she should ask for.</li>\\n\\n              </ul>\\n\\n              <p>This operation cannot be performed on observations that the user is not authorized to see.  It is assumed that the server has identified and secured the context appropriately, and can either associate the authorization context with a single patient, or determine whether the context has the rights to the nominated patient, if there is one. If there is no nominated patient (e.g. the operation is invoked at the system level) and the context is not associated with a single patient record, then the server should return an error. Specifying the relationship between the context, a user and patient records is outside the scope of this specification.</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Last N Observations Query\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Observation-lastn\",
  \"version\": \"5.0.0\"
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
    }
  ],
  \"date\": \"2023-03-26T15:21:02+11:00\",
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
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
          \"extension\": [
            {
              \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
              \"valueUri\": \"Coding\"
            },
            {
              \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
              \"valueUri\": \"boolean\"
            },
            {
              \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
              \"valueUri\": \"code\"
            },
            {
              \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
              \"valueUri\": \"dateTime\"
            },
            {
              \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
              \"valueUri\": \"decimal\"
            },
            {
              \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
              \"valueUri\": \"integer\"
            },
            {
              \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
              \"valueUri\": \"string\"
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
              \"extension\": [
                {
                  \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                  \"valueUri\": \"Coding\"
                },
                {
                  \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                  \"valueUri\": \"boolean\"
                },
                {
                  \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                  \"valueUri\": \"code\"
                },
                {
                  \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                  \"valueUri\": \"dateTime\"
                },
                {
                  \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                  \"valueUri\": \"decimal\"
                },
                {
                  \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                  \"valueUri\": \"integer\"
                },
                {
                  \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                  \"valueUri\": \"string\"
                }
              ],
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
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"CodeSystem\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"active\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/CodeSystem/$lookup</p>\\n            <p>URL: [base]/CodeSystem/[id]/$lookup</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>code</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The code that is to be located. If a code is provided, a system must be provided</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>system</td>\\n                <td>type</td>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The system for the code that is to be located</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>version</td>\\n                <td>type</td>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The version of the system, if one was provided in the source data</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>coding</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#Coding\\\">Coding</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>A coding to look up</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>date</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#dateTime\\\">dateTime</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The date for which the information should be returned. Normally, this is the current conditions (which is the default value) but under some circumstances, systems need to acccess this information as it would have been in the past. A typical example of this would be where code selection is constrained to the set of codes that were available when the patient was treated, not when the record is being edited. Note that which date is appropriate is a matter for implementation policy.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>displayLanguage</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The requested language for display (see CodeSystem.concept.designation.language)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>property</td>\\n                <td/>\\n                <td>0..*</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>A property that the client wishes to be returned in the output. If no properties are specified, the server chooses what to return. The following properties are defined for all code systems: name, version (code system info) and code information: display, designation, and lang.X where X is a designation language code. These properties are returned explicitly in named out parameters with matching names, or in designations. In addition, any property codes defined by \\n                      <a href=\\\"codesystem.html#defined-props\\\">this specification</a> or by the CodeSystem (\\n                      <a href=\\\"codesystem-definitions.html#CodeSystem.property\\\">CodeSystem.property.code</a>) are allowed, and these are returned in the out parameter \\n                      <code>property</code>\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>useSupplement</td>\\n                <td/>\\n                <td>0..*</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Supplements to take into account when performing the $lookup operation. The supplements must be for the same CodeSystem. By default, supplements for the code system are not automatically included except where they provide additional designations that may be indicated by, for example, the displayLanguage parameter</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>name</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>A display name for the code system</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>version</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The version that these details are based on</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>display</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The preferred display for this concept</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>definition</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>A statement of the meaning of the concept from the code system</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>designation</td>\\n                <td/>\\n                <td>0..*</td>\\n                <td/>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Additional representations for this concept</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>designation.language</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The language this designation is defined for</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>designation.use</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#Coding\\\">Coding</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>A code that details how this designation would be used</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>designation.additionalUse</td>\\n                <td/>\\n                <td>0..*</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#Coding\\\">Coding</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Additional codes that detail how this designation would be used (if there is more than one)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>designation.value</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The text value for this designation</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>property</td>\\n                <td/>\\n                <td>0..*</td>\\n                <td/>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>One or more properties that contain additional information about the code, including status. For complex terminologies (e.g. SNOMED CT, LOINC, medications), these properties serve to decompose the code</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>property.code</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Identifies the property returned</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>property.value</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#Coding\\\">Coding</a> | \\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a> | \\n                  <a href=\\\"datatypes.html#code\\\">code</a> | \\n                  <a href=\\\"datatypes.html#dateTime\\\">dateTime</a> | \\n                  <a href=\\\"datatypes.html#decimal\\\">decimal</a> | \\n                  <a href=\\\"datatypes.html#integer\\\">integer</a> | \\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The value of the property returned</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>property.description</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Human Readable representation of the property value (e.g. display for a code)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>property.source</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>If information from a supplement is included as a property (e.g. any additional property or property value), then this parameter must assert the url of the supplement.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>property.subproperty</td>\\n                <td/>\\n                <td>0..*</td>\\n                <td/>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Nested Properties (mainly used for SNOMED CT decomposition, for relationship Groups)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>property.subproperty.code</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Identifies the sub-property returned</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>property.subproperty.value</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#Coding\\\">Coding</a> | \\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a> | \\n                  <a href=\\\"datatypes.html#code\\\">code</a> | \\n                  <a href=\\\"datatypes.html#dateTime\\\">dateTime</a> | \\n                  <a href=\\\"datatypes.html#decimal\\\">decimal</a> | \\n                  <a href=\\\"datatypes.html#integer\\\">integer</a> | \\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The value of the sub-property returned</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>property.subproperty.description</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Human Readable representation of the sub-property value (e.g. display for a code)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>property.subproperty.source</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>If information from a supplement is included as a subproperty (e.g. any additional subproperty or subproperty value), then this parameter must assert the url of the supplement.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n            <div>\\n              <p>Note that the $lookup operation is more than just a code system search  - the server finds the concept, and gathers the return information from the underlying code system definitions.</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Concept Look Up & Decomposition\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/CodeSystem-lookup\",
  \"version\": \"5.0.0\"
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
  \"comment\": \"The response from an \\\"mpi\\\" query is a bundle containing patient records, ordered from most likely to least likely. If there are no patient matches, the MPI SHALL return an empty search set with no error, but may include an operation outcome with further advice regarding patient selection. All patient records SHALL have a search score from 0 to 1, where 1 is the most certain match, along with an extension \\\"[http://hl7.org/fhir/StructureDefinition/match-grade](http://hl7.org/fhir/extensions/StructureDefinition-match-grade.html)\\\" that indicates the MPI's position on the match quality.\",
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
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"A Master Patient Index ([MPI](http://en.wikipedia.org/wiki/Enterprise_master_patient_index) ) is a service used to manage patient identification in a context where multiple patient databases exist. Healthcare applications and middleware use the MPI to match patients between the databases, and to store new patient details as they are encountered. MPIs are highly specialized applications, often tailored extensively to the institution's particular mix of patients. MPIs can also be run on a regional and national basis.  \\n\\nTo ask an MPI to match a patient, clients use the \\\"$match\\\" operation, which accepts a patient resource which may be only partially complete. The data provided is interpreted as an MPI input and processed by an algorithm of some kind that uses the data to determine the most appropriate matches in the patient set.  Note that different MPI matching algorithms have different required inputs. Consult with the vendor implementing the $match operation as to its specific behaviors.\\r\\r  The generic $match operation does not specify any particular algorithm, nor a minimum set of information that must be provided when asking for an MPI match operation to be performed, but many implementations will have a set of minimum information, which may be declared in their definition of the $match operation by specifying a profile on the resource parameter, indicating which properties are required in the search.\\r\\rThe patient resource submitted to the operation does not have to be complete, nor does it need to pass validation (i.e. mandatory fields don't need to be populated), but it does have to be a valid instance, as it is used as the reference data to match against.\\r\\r  Implementers of the $match algorithm should consider the relevance of returning inactive patients, particularly ones associated with patient merges.\\r\\rE.g. If an inactive patient is \\\"matched\\\" and its merged target resource will be included, then the inactive one may be excluded, however if a patient was just marked as inactive for other reasons, it could be included in the results.\\r\\r(any specific MPI algorithm may or might not behave as in these examples)\",
  \"experimental\": false,
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
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
      \"documentation\": \"The bundle type is \\\"searchset\\\"\\r\\rA bundle contain a set of Patient records that represent possible matches, optionally it may also contain an OperationOutcome with further information about the search results (such as warnings or information messages, such as a count of records that were close but eliminated)  If the operation was unsuccessful, then an OperationOutcome may be returned along with a BadRequest status Code (e.g. security issue, or insufficient properties in patient fragment - check against profile)\",
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
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/Patient/$match</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>resource</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"resource.html\\\">Resource</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Use this to provide an entire set of patient details for the MPI to match against (e.g. POST a patient record to Patient/$match).</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>onlyCertainMatches</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>If there are multiple potential matches, then the match should not return the results with this flag set to true.  When false, the server may return multiple results with each result graded accordingly.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>count</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#integer\\\">integer</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The maximum number of records to return. If no value is provided, the server decides how many matches to return. Note that clients should be careful when using this, as it may prevent probable - and valid - matches from being returned</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>return</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"bundle.html\\\">Bundle</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The bundle type is &quot;searchset&quot;</p>\\n\\n                    <p>A bundle contain a set of Patient records that represent possible matches, optionally it may also contain an OperationOutcome with further information about the search results (such as warnings or information messages, such as a count of records that were close but eliminated)  If the operation was unsuccessful, then an OperationOutcome may be returned along with a BadRequest status Code (e.g. security issue, or insufficient properties in patient fragment - check against profile)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n            <div>\\n              <p>The response from an &quot;mpi&quot; query is a bundle containing patient records, ordered from most likely to least likely. If there are no patient matches, the MPI SHALL return an empty search set with no error, but may include an operation outcome with further advice regarding patient selection. All patient records SHALL have a search score from 0 to 1, where 1 is the most certain match, along with an extension &quot;\\n                <a href=\\\"http://hl7.org/fhir/extensions/StructureDefinition-match-grade.html\\\">http://hl7.org/fhir/StructureDefinition/match-grade</a>&quot; that indicates the MPI's position on the match quality.\\n              </p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Find patient matches using MPI based logic\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Patient-match\",
  \"version\": \"5.0.0\"
}"))
(define (match-operation handler)
  (define code "match")
  (list (operation-entry 'type code "Patient" handler)))
(define merge-definition
  (string->jsexpr
   "{
  \"affectsState\": true,
  \"code\": \"merge\",
  \"comment\": \"There must be exactly 1 source patient, which may  be identified by either the source-patient or source-patient-identifier parameters. Similarly, there must be exactly 1 target patient, identified by either the target-patient or target-patient-identifier parameters. In both cases, either a reference to the patient or a list of identifiers that can be used to identify the patient may be provided, but not both.\\r\\rThe result-patient.id must be the same as the target patient reference (if the patient reference is provided as an input parameter).\\r\\rIf a client needs the server to create a new patient merged from the 2 patient resources, the client should create a new patient record and then call the merge operation to merge each source patient resource into the newly created patient resource.\\r\\rA server may decide to delete the source record, but this is not defined by the standard merge operation, and if this occurs then the target patient's link property will remain unchanged.\\r\",
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
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"The merge operation is used to request two patient resources be merged. One of the two patients is identified as the source and one as the target. The data from the source patient will be merged with the data of the target patient.\\r\\rThe source Patient resource will be updated to add a new Patient.link reference to the target Patient resource with a link-type of replaced-by. The source Patient will also be updated to have a status of inactive, unless the source Patient resource was deleted.\\r\\rThe target Patient resource will be updated to add a new Patient.link reference to the source Patient resource with a link-type of replaces unless the source Patient resource is deleted. The target Patient resource must be included in the result-patient parameter if used.\",
  \"experimental\": false,
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
  \"id\": \"Patient-merge\",
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
  },
  \"name\": \"Merge\",
  \"parameter\": [
    {
      \"documentation\": \"A direct resource reference to the **source** patient resource (this may include an identifier).\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"source-patient\",
      \"targetProfile\": [
        \"http://hl7.org/fhir/StructureDefinition/Patient\"
      ],
      \"type\": \"Reference\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"When source-patient-identifiers are provided, the server is expected to perform an internal lookup to identify the source patient record. The server SHALL reject the request if the provided identifiers do not resolve to a single patient record. This resolution MAY occur asynchronously, for example, as part of a review by a user.\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"source-patient-identifier\",
      \"type\": \"Identifier\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"A direct resource reference to the **target** patient resource.\\r\\rThis is the surviving patient resource, the target for the merge.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"target-patient\",
      \"targetProfile\": [
        \"http://hl7.org/fhir/StructureDefinition/Patient\"
      ],
      \"type\": \"Reference\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"When target-patient-identifiers are provided, the server is expected to perform an internal lookup to identify the target patient record. The server SHALL reject the request if the provided identifiers do not resolve to a single patient record. This resolution MAY occur asynchronously, for example, as part of a review by a user.\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"target-patient-identifier\",
      \"type\": \"Identifier\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The details of the Patient resource that is expected to be updated to complete with and must have the same patient.id and provided identifiers included.\\r\\rThis resource MUST have the link property included referencing the source patient resource.\\r\\rIt will be used to perform an update on the target patient resource.\\r\\rIn the absence of this parameter the servers should copy all identifiers from the source patient into the target patient, and include the link property (as shown in the example below).\\r\\rThis is often used when properties from the source patient are desired to be included in the target resource.\\r\\rThe receiving system may also apply other internal business rules onto the merge which may make the resource different from what is provided here.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"result-patient\",
      \"type\": \"Patient\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"If this is set to true then the merge will not be actually performed; an OperationOutcome will be returned in the Parameters response that will indicate that no merge has occurred and may include other diagnostic info if desired, such as the scale of the merge.\\r\\re.g. Issue.details.text \\\"Preview only Patient merge - no issues detected\\\"\\r\\re.g. Issue.diagnostics \\\"Merge would update: 10 years of content or 120 resources\\\"\\r\\rThe resulting target patient resource will also be returned in the result.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"preview\",
      \"type\": \"boolean\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The status of the response will be one of:\\r\\r* 200 OK - If the merge request doesn't expect any issues (although warning may be present) for a preview, or was completed without issues if not a preview\\r* 202 Accepted - The merge request has been accepted and does not expect any issues and will continue processing the merge in the background, and you can monitor the Task for completion\\r* 400 Bad Request - There are errors in the input parameters that need to corrected\\r* 422 Unprocessable Entity - Business rules prevent this merge from completing\\r\\rThe Parameters resource will include:\\r\\r* The Input parameters to the operation\\r* An OperationOutcome containing errors, warnings, and information messages\\r* The resulting merged Patient resource (or a patient reference if the patient is not committed)\\r* Optionally a Task resource to track any additional processing that was required.\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"return\",
      \"type\": \"Parameters\",
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
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/Patient/$merge</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>source-patient</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"references.html#Reference\\\">Reference</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>A direct resource reference to the \\n                      <strong>source</strong> patient resource (this may include an identifier).\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>source-patient-identifier</td>\\n                <td/>\\n                <td>0..*</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#Identifier\\\">Identifier</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>When source-patient-identifiers are provided, the server is expected to perform an internal lookup to identify the source patient record. The server SHALL reject the request if the provided identifiers do not resolve to a single patient record. This resolution MAY occur asynchronously, for example, as part of a review by a user.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>target-patient</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"references.html#Reference\\\">Reference</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>A direct resource reference to the \\n                      <strong>target</strong> patient resource.\\n                    </p>\\n\\n                    <p>This is the surviving patient resource, the target for the merge.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>target-patient-identifier</td>\\n                <td/>\\n                <td>0..*</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#Identifier\\\">Identifier</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>When target-patient-identifiers are provided, the server is expected to perform an internal lookup to identify the target patient record. The server SHALL reject the request if the provided identifiers do not resolve to a single patient record. This resolution MAY occur asynchronously, for example, as part of a review by a user.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>result-patient</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"patient.html\\\">Patient</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The details of the Patient resource that is expected to be updated to complete with and must have the same patient.id and provided identifiers included.</p>\\n\\n                    <p>This resource MUST have the link property included referencing the source patient resource.</p>\\n\\n                    <p>It will be used to perform an update on the target patient resource.</p>\\n\\n                    <p>In the absence of this parameter the servers should copy all identifiers from the source patient into the target patient, and include the link property (as shown in the example below).</p>\\n\\n                    <p>This is often used when properties from the source patient are desired to be included in the target resource.</p>\\n\\n                    <p>The receiving system may also apply other internal business rules onto the merge which may make the resource different from what is provided here.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>preview</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>If this is set to true then the merge will not be actually performed; an OperationOutcome will be returned in the Parameters response that will indicate that no merge has occurred and may include other diagnostic info if desired, such as the scale of the merge.</p>\\n\\n                    <p>e.g. Issue.details.text &quot;Preview only Patient merge - no issues detected&quot;</p>\\n\\n                    <p>e.g. Issue.diagnostics &quot;Merge would update: 10 years of content or 120 resources&quot;</p>\\n\\n                    <p>The resulting target patient resource will also be returned in the result.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>return</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"parameters.html\\\">Parameters</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The status of the response will be one of:</p>\\n\\n                    <ul>\\n\\n                      <li>200 OK - If the merge request doesn't expect any issues (although warning may be present) for a preview, or was completed without issues if not a preview</li>\\n\\n                      <li>202 Accepted - The merge request has been accepted and does not expect any issues and will continue processing the merge in the background, and you can monitor the Task for completion</li>\\n\\n                      <li>400 Bad Request - There are errors in the input parameters that need to corrected</li>\\n\\n                      <li>422 Unprocessable Entity - Business rules prevent this merge from completing</li>\\n\\n                    </ul>\\n\\n                    <p>The Parameters resource will include:</p>\\n\\n                    <ul>\\n\\n                      <li>The Input parameters to the operation</li>\\n\\n                      <li>An OperationOutcome containing errors, warnings, and information messages</li>\\n\\n                      <li>The resulting merged Patient resource (or a patient reference if the patient is not committed)</li>\\n\\n                      <li>Optionally a Task resource to track any additional processing that was required.</li>\\n\\n                    </ul>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n            <div>\\n              <p>There must be exactly 1 source patient, which may  be identified by either the source-patient or source-patient-identifier parameters. Similarly, there must be exactly 1 target patient, identified by either the target-patient or target-patient-identifier parameters. In both cases, either a reference to the patient or a list of identifiers that can be used to identify the patient may be provided, but not both.</p>\\n\\n              <p>The result-patient.id must be the same as the target patient reference (if the patient reference is provided as an input parameter).</p>\\n\\n              <p>If a client needs the server to create a new patient merged from the 2 patient resources, the client should create a new patient record and then call the merge operation to merge each source patient resource into the newly created patient resource.</p>\\n\\n              <p>A server may decide to delete the source record, but this is not defined by the standard merge operation, and if this occurs then the target patient's link property will remain unchanged.</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Patient Merge\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Patient-merge\",
  \"version\": \"5.0.0\"
}"))
(define (merge-operation handler)
  (define code "merge")
  (list (operation-entry 'type code "Patient" handler)))
(define meta-add-definition
  (string->jsexpr
   "{
  \"affectsState\": true,
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
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"This operation takes a meta, and adds the profiles, tags, and security labels found in it to the nominated resource\",
  \"experimental\": false,
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
  },
  \"name\": \"MetaAdd\",
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
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/Resource/[id]/$meta-add</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>meta</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"resource.html#Meta\\\">Meta</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Profiles, tags, and security labels to add to the existing resource. Note that profiles, tags, and security labels are sets, and duplicates are not created.  The identity of a tag or security label is the system+code. When matching existing tags during adding, version and display are ignored. For profiles, matching is based on the full URL</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>return</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"resource.html#Meta\\\">Meta</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Resulting meta for the resource</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Add profiles, tags, and security labels to a resource\",
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Resource-meta-add\",
  \"version\": \"5.0.0\"
}"))
(define (meta-add-operation handler)
  (define code "meta-add")
  (list (operation-entry 'instance code "Resource" handler)))
(define meta-delete-definition
  (string->jsexpr
   "{
  \"affectsState\": true,
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
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"This operation takes a meta, and deletes the profiles, tags, and security labels found in it from the nominated resource\",
  \"experimental\": false,
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
  },
  \"name\": \"MetaDelete\",
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
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/Resource/[id]/$meta-delete</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>meta</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"resource.html#Meta\\\">Meta</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Profiles, tags, and security labels to delete from the existing resource. It is not an error if these tags, profiles, and labels do not exist.  The identity of a tag or security label is the system+code. When matching existing tags during deletion, version and display are ignored. For profiles, matching is based on the full URL</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>return</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"resource.html#Meta\\\">Meta</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Resulting meta for the resource</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Delete profiles, tags, and security labels for a resource\",
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Resource-meta-delete\",
  \"version\": \"5.0.0\"
}"))
(define (meta-delete-operation handler)
  (define code "meta-delete")
  (list (operation-entry 'instance code "Resource" handler)))
(define meta-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
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
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"This operation retrieves a summary of the profiles, tags, and security labels for the given scope; e.g. for each scope:  \\n\\n* system-wide: a list of all profiles, tags and security labels in use by the system \\n* resource-type level: A list of all profiles, tags, and security labels for the resource type \\n* individual resource level: A list of all profiles, tags, and security labels for the current version of the resource.  Also, as a special case, this operation (and other meta operations) can be performed on a historical version of a resource)\",
  \"experimental\": false,
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
  },
  \"name\": \"Meta\",
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
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/$meta</p>\\n            <p>URL: [base]/Resource/$meta</p>\\n            <p>URL: [base]/Resource/[id]/$meta</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>return</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"resource.html#Meta\\\">Meta</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The meta returned by the operation</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n            <div>\\n              <p>At the system and type levels, the $meta operation is used to get a summary of all the labels that are in use across the system. The principal use for this operation is to support search e.g. what tags can be searched for. At these levels, the meta will not contain versionId, lastUpdated etc. Systems are not obligated to implement the operation at this level (and should return a 4xx error if they don't). At the resource and historical entry level, the $meta operation returns the same meta as would be returned by accessing the resource directly. This can be used to allow a system to get access to the meta-information for the resource without accessing the resource itself, e.g. for security reasons</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Access a list of profiles, tags, and security labels\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Resource-meta\",
  \"version\": \"5.0.0\"
}"))
(define (meta-operation handler)
  (define code "meta")
  (list (operation-entry 'system code #f handler)
        (operation-entry 'type code "Resource" handler)
        (operation-entry 'instance code "Resource" handler)))
(define populate-definition
  (string->jsexpr
   "{
  \"base\": \"http://hl7.org/fhir/OperationDefinition/Questionnaire-populate\",
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
  \"publisher\": \"Acme Healthcare Services\",
  \"resource\": [
    \"Questionnaire\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\"><p><b>Generated Narrative: OperationDefinition</b><a name=\\\"example\\\"> </a></p><div style=\\\"display: inline-block; background-color: #d9e0e7; padding: 6px; margin: 4px; border: 1px solid #8da1b4; border-radius: 5px; line-height: 60%\\\"><p style=\\\"margin-bottom: 0px\\\">Resource OperationDefinition &quot;example&quot; </p></div><p><b>url</b>: <code>http://hl7.org/fhir/OperationDefinition/example</code></p><p><b>version</b>: B</p><p><b>name</b>: PopulateQuestionnaire</p><p><b>title</b>: Populate Questionnaire</p><p><b>status</b>: draft</p><p><b>kind</b>: operation</p><p><b>date</b>: 2015-08-04</p><p><b>publisher</b>: Acme Healthcare Services</p><p><b>contact</b>: System Administrator: <a href=\\\"mailto:beep@coyote.acme.com\\\">beep@coyote.acme.com</a></p><p><b>description</b>: Limited implementation of the Populate Questionnaire implementation</p><h3>UseContexts</h3><table class=\\\"grid\\\"><tr><td>-</td><td><b>Code</b></td><td><b>Value[x]</b></td></tr><tr><td>*</td><td>Clinical Venue (Details: http://terminology.hl7.org/CodeSystem/usage-context-type code venue = 'Clinical Venue', stated as 'Clinical Venue')</td><td>inpatient encounter <span style=\\\"background: LightGoldenRodYellow; margin: 4px; border: 1px solid khaki\\\"> (<a href=\\\"http://terminology.hl7.org/5.1.0/CodeSystem-v3-ActCode.html\\\">ActCode</a>#IMP)</span></td></tr></table><p><b>jurisdiction</b>: United Kingdom of Great Britain and Northern Ireland (the) <span style=\\\"background: LightGoldenRodYellow; margin: 4px; border: 1px solid khaki\\\"> (<a href=\\\"http://terminology.hl7.org/5.1.0/CodeSystem-ISO3166Part1.html\\\">ISO 3166-1 Codes for the representation of names of countries and their subdivisions — Part 1: Country code</a>#GB)</span></p><p><b>code</b>: populate</p><p><b>comment</b>: Only implemented for Labs and Medications so far</p><p><b>base</b>: <a href=\\\"http://hl7.org/fhir/OperationDefinition/Questionnaire-populate\\\">http://hl7.org/fhir/OperationDefinition/Questionnaire-populate</a></p><p><b>resource</b>: Questionnaire</p><p><b>system</b>: false</p><p><b>type</b>: false</p><p><b>instance</b>: true</p><blockquote><p><b>parameter</b></p><p><b>name</b>: subject</p><p><b>use</b>: in</p><p><b>min</b>: 1</p><p><b>max</b>: 1</p><p><b>documentation</b>: The resource that is to be the *QuestionnaireResponse.subject*. The [[[QuestionnaireResponse]]]      instance will reference the provided subject.  In addition, if the *local* parameter is      set to true, server information about the specified subject will be used to populate the      instance.</p><p><b>type</b>: Reference</p></blockquote><blockquote><p><b>parameter</b></p><p><b>name</b>: local</p><p><b>use</b>: in</p><p><b>min</b>: 0</p><p><b>max</b>: 1</p><p><b>documentation</b>: If the *local* parameter is set to true, server information about the specified subject will be used to populate the instance.</p><p><b>type</b>: Reference</p></blockquote><blockquote><p><b>parameter</b></p><p><b>name</b>: return</p><p><b>use</b>: out</p><p><b>min</b>: 1</p><p><b>max</b>: 1</p><p><b>documentation</b>: The partially (or fully)-populated set of answers for the specified Questionnaire</p><p><b>type</b>: QuestionnaireResponse</p></blockquote><blockquote><p><b>overload</b></p><p><b>parameterName</b>: subject, local</p></blockquote><blockquote><p><b>overload</b></p><p><b>parameterName</b>: subject</p><p><b>comment</b>: local defaults to false when not passed as a parameter</p></blockquote></div>\",
    \"status\": \"generated\"
  },
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
    }
  ],
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"This operation returns the preferred identifiers for identifiers, and terminologies. The operation takes 2 parameters:     \\n\\n* a system identifier - either a URI, an OID, or a v2 table 0396 (other) code  \\n* a code for what kind of identifier is desired (URI, OID, v2 table 0396 identifier)    \\n\\nand returns either the requested identifier, or an HTTP errors response with an OperationOutcome because either the provided identifier was not recognized, or the requested identiifer type is not known.    \\n\\nThe principle use of this operation is when converting between v2, CDA and FHIR Identifier/CX/II and CodeableConcepts/C(N/W)E/CD but the operation may also find use when converting metadata such as profiles.\",
  \"experimental\": false,
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
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
        \"valueSet\": \"http://hl7.org/fhir/ValueSet/namingsystem-identifier-type|5.0.0\"
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
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"NamingSystem\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/NamingSystem/$preferred-id</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>id</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The server parses the provided identifier to see what type it is (e.g. a URI, an OID as a URI, a plain OID, or a v2 table 0396 code). If the server can't tell what type of identifier it is, it can try it as multiple types. It is an error if more than one system matches the provided identifier</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>type</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n                <td>\\n                  <a href=\\\"valueset-namingsystem-identifier-type.html\\\">Naming System Identifier Type</a> (Required)\\n                </td>\\n                <td/>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>date</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#dateTime\\\">dateTime</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>If specified, the operation will indicate what the preferred identifier was on the specified date.  If not specified, the operation will provide the preferred identifier as of 'now'</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>result</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>OIDs are return as plain OIDs (not the URI form).</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n            <div>\\n              <p>Servers handle this request by finding the provided identifier in their known naming systems, and returning the requested identifier type (\\n                <a href=\\\"namingsystem-definitions.html#NamingSystem.uniqueId.type\\\">NamingSystem.uniqueId.type</a>). If there is more than one identifier of the specified type (for the specified date), then the 'preferred' identifier will be returned.  If there is only one identifier, that identifier will be returned even if it is not preferred.  If there are multiple preferred identifiers or multiple identifiers with none marked as preferred, the system MAY return an error or may list all identifiers applicable for that date and period.\\n              </p>\\n\\n              <p>If the server wishes, it can also look through all code systems and value sets it knows about when attempting to find the requested identifier.</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Fetch Preferred id\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/NamingSystem-preferred-id\",
  \"version\": \"5.0.0\"
}"))
(define (preferred-id-operation handler)
  (define code "preferred-id")
  (list (operation-entry 'type code "NamingSystem" handler)))
(define process-message-definition
  (string->jsexpr
   "{
  \"affectsState\": true,
  \"code\": \"process-message\",
  \"comment\": \"This operation does not use the parameters resource; the parameters \\\"async\\\" and \\\"response-url\\\" always go in the URL, if they are used, and the \\\"content\\\" parameter is always the body of the HTTP message.\\n\\nWhen processing messages, a server may return one of several status codes:\\n* **200 OK**: Indicates that the message has been fully processed.  If an application-level response is expected for the submitted message, that response SHALL be returned as the body of the 200 response.\\n* **202 Accepted**: Indicates that the receiving system has accepted custody of the message\\n* **204 No Content**: Indicates that the message has been fully processed and would normally have had an application-level response, but because of instructions from the sender (e.g. the [http://hl7.org/fhir/StructureDefinition/messageheader-response-request](http://hl7.org/fhir/extensions/StructureDefinition-messageheader-response-request.html) extension), no response is being provided\\n* **300+**: Indicates that the message was not successfully processed.  The server MAY return an [OperationOutcome](operationoutcome.html) with additional information, and SHOULD do so if the response code is 400 or greater. The client SHALL interpret a 4xx response to indicate that there is no point resubmitting the unaltered message, and a 5xx response to indicate an unexpected error occurred on the part of the server, with the implication that it may be appropriate to resubmit the original message. Doing so SHOULD NOT result in a duplicate message response. Repeated failures indicate either a fatal problem with the submission or a problem with the receiving application.\\n\\nThe following rules apply when using $process-message:\\n\\n* The operation only accepts POST transactions - any other HTTP method will result in an HTTP error\\n* The request content type submitted is always [Bundle](bundle.html) with type \\\"message\\\" containing a [Message Header](messageheader.html) resource as the first resource\\n* The response content type returned, if not empoty, is always [Bundle](bundle.html) with type \\\"message\\\" containing a [Message Header](messageheader.html) resource as the first resource, or an HTTP error\\n* If the response is an error, the body SHOULD be an [OperationOutcome](operationoutcome.html) resource with full details of the Errors &mp; Warning\\n* The mailbox may be authenticated using standard HTTP authentication methods, including OAuth\\n\\nThe $process-message operation can be used by any HTTP end-point that accepts FHIR messages, not just FHIR RESTful servers.\\n\\nIn order to ensure consistency of processing, the [logical rules regarding processing of Bundle.id and message id](messaging.html#reliable) SHALL be followed when messages are processed using this operation.\\n\\nThe $process-message operation may be used synchronously, or asynchronously.\\n\\nThe following rules apply when using the $process-message operation synchronously:\\n\\n* The URL (http://server/base/$process-message) has no parameters\\n* It is an error if the sender POSTs a message that requires multiple response messages\\n* Servers SHALL accept multiple concurrent message submissions and process them correctly (they are allowed to process them sequentially internally, but multiple concurrent submissions is not an error in its own right)\\n\\nThe following rules apply when using the $process-message operation asynchronously:\\n\\n* The URL has at least one parameter: http://server/base/$process-message?async=true\\n* The server acknowledges the message with a 200 OK with no body, or returns an HTTP error if the message cannot be processed\\n* Accepting the message means that the server has understood the message enough to know where to respond\\n* An [OperationOutcome](operationoutcome.html) SHOULD be returned in either case\\n* By default, the server responds by invoking the $process-message using the sender's stated end-point in the message: POST [MessageHeader.source.endpoint]/$process-message]\\n* Since the source end-point may be manipulated by message transfer engines, an alternative response address may be specified using the parameter \\\"response-url\\\": http://server/base/$process-message?async=true&amp;response-url=http://server2.com/base/anything.  The endpoint at the specified URL SHALL implement the signature of the $process-message operation (parameter async=true, accept a Bundle, return a 200 OK or an error)\\n* The server submits response messages to the appropriate end-point with the parameter async=true. There is no response message for the response messages\",
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
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"This operation accepts a message, processes it according to the definition of the event in the message header, and returns one or more response messages.  \\n\\nIn addition to processing the message event, a server may choose to retain all or some the resources and make them available on a RESTful interface, but is not required to do so.\",
  \"experimental\": false,
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
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
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"MessageHeader\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": true,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/$process-message</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>content</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"bundle.html\\\">Bundle</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The message to process (or, if using asynchronous messaging, it may be a response message to accept)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>async</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>If 'true' the message is processed using the asynchronous messaging pattern</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>response-url</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#url\\\">url</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>A URL to submit response messages to, if asynchronous messaging is being used, and if the MessageHeader.source.endpoint is not the appropriate place to submit responses</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>return</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"bundle.html\\\">Bundle</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>A response message, if synchronous messaging is being used (mandatory in this case). For asynchronous messaging, there is no return value</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n            <div>\\n              <p>This operation does not use the parameters resource; the parameters &quot;async&quot; and &quot;response-url&quot; always go in the URL, if they are used, and the &quot;content&quot; parameter is always the body of the HTTP message.</p>\\n\\n              <p>When processing messages, a server may return one of several status codes:</p>\\n\\n              <ul>\\n\\n                <li>\\n                  <strong>200 OK</strong>: Indicates that the message has been fully processed.  If an application-level response is expected for the submitted message, that response SHALL be returned as the body of the 200 response.\\n                </li>\\n\\n                <li>\\n                  <strong>202 Accepted</strong>: Indicates that the receiving system has accepted custody of the message\\n                </li>\\n\\n                <li>\\n                  <strong>204 No Content</strong>: Indicates that the message has been fully processed and would normally have had an application-level response, but because of instructions from the sender (e.g. the \\n                  <a href=\\\"http://hl7.org/fhir/extensions/StructureDefinition-messageheader-response-request.html\\\">http://hl7.org/fhir/StructureDefinition/messageheader-response-request</a> extension), no response is being provided\\n                </li>\\n\\n                <li>\\n                  <strong>300+</strong>: Indicates that the message was not successfully processed.  The server MAY return an \\n                  <a href=\\\"operationoutcome.html\\\">OperationOutcome</a> with additional information, and SHOULD do so if the response code is 400 or greater. The client SHALL interpret a 4xx response to indicate that there is no point resubmitting the unaltered message, and a 5xx response to indicate an unexpected error occurred on the part of the server, with the implication that it may be appropriate to resubmit the original message. Doing so SHOULD NOT result in a duplicate message response. Repeated failures indicate either a fatal problem with the submission or a problem with the receiving application.\\n                </li>\\n\\n              </ul>\\n\\n              <p>The following rules apply when using $process-message:</p>\\n\\n              <ul>\\n\\n                <li>The operation only accepts POST transactions - any other HTTP method will result in an HTTP error</li>\\n\\n                <li>The request content type submitted is always \\n                  <a href=\\\"bundle.html\\\">Bundle</a> with type &quot;message&quot; containing a \\n                  <a href=\\\"messageheader.html\\\">Message Header</a> resource as the first resource\\n                </li>\\n\\n                <li>The response content type returned, if not empoty, is always \\n                  <a href=\\\"bundle.html\\\">Bundle</a> with type &quot;message&quot; containing a \\n                  <a href=\\\"messageheader.html\\\">Message Header</a> resource as the first resource, or an HTTP error\\n                </li>\\n\\n                <li>If the response is an error, the body SHOULD be an \\n                  <a href=\\\"operationoutcome.html\\\">OperationOutcome</a> resource with full details of the Errors ∓ Warning\\n                </li>\\n\\n                <li>The mailbox may be authenticated using standard HTTP authentication methods, including OAuth</li>\\n\\n              </ul>\\n\\n              <p>The $process-message operation can be used by any HTTP end-point that accepts FHIR messages, not just FHIR RESTful servers.</p>\\n\\n              <p>In order to ensure consistency of processing, the \\n                <a href=\\\"messaging.html#reliable\\\">logical rules regarding processing of Bundle.id and message id</a> SHALL be followed when messages are processed using this operation.\\n              </p>\\n\\n              <p>The $process-message operation may be used synchronously, or asynchronously.</p>\\n\\n              <p>The following rules apply when using the $process-message operation synchronously:</p>\\n\\n              <ul>\\n\\n                <li>The URL (http://server/base/$process-message) has no parameters</li>\\n\\n                <li>It is an error if the sender POSTs a message that requires multiple response messages</li>\\n\\n                <li>Servers SHALL accept multiple concurrent message submissions and process them correctly (they are allowed to process them sequentially internally, but multiple concurrent submissions is not an error in its own right)</li>\\n\\n              </ul>\\n\\n              <p>The following rules apply when using the $process-message operation asynchronously:</p>\\n\\n              <ul>\\n\\n                <li>The URL has at least one parameter: http://server/base/$process-message?async=true</li>\\n\\n                <li>The server acknowledges the message with a 200 OK with no body, or returns an HTTP error if the message cannot be processed</li>\\n\\n                <li>Accepting the message means that the server has understood the message enough to know where to respond</li>\\n\\n                <li>An \\n                  <a href=\\\"operationoutcome.html\\\">OperationOutcome</a> SHOULD be returned in either case\\n                </li>\\n\\n                <li>By default, the server responds by invoking the $process-message using the sender's stated end-point in the message: POST [MessageHeader.source.endpoint]/$process-message]</li>\\n\\n                <li>Since the source end-point may be manipulated by message transfer engines, an alternative response address may be specified using the parameter &quot;response-url&quot;: http://server/base/$process-message?async=true&amp;response-url=http://server2.com/base/anything.  The endpoint at the specified URL SHALL implement the signature of the $process-message operation (parameter async=true, accept a Bundle, return a 200 OK or an error)</li>\\n\\n                <li>The server submits response messages to the appropriate end-point with the parameter async=true. There is no response message for the response messages</li>\\n\\n              </ul>\\n\\n            </div>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Process Message\",
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/MessageHeader-process-message\",
  \"version\": \"5.0.0\"
}"))
(define (process-message-operation handler)
  (define code "process-message")
  (list (operation-entry 'system code #f handler)))
(define questionnaire-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
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
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"Generates a [Questionnaire](questionnaire.html) instance  based on a specified [StructureDefinition](structuredefinition.html), creating questions for each core element or extension element found in the [StructureDefinition](structuredefinition.html).    \\n\\nIf the operation is not called at the instance level, one of the *identifier*, *profile* or *url* 'in' parameters must be provided. If more than one is specified, servers may raise an error or may resolve with the parameter of their choice. If called at the instance level, these parameters will be ignored. The response will contain a [Questionnaire](questionnaire.html) instance based on the specified [StructureDefinition](structuredefinition.html) and/or an [OperationOutcome](operationoutcome.html) resource with errors or warnings.  Nested groups are used to handle complex structures and data types.  If the 'supportedOnly' parameter is set to true, only those elements marked as \\\"must support\\\" will be included.  \\n\\nThis operation is intended to enable auto-generation of simple interfaces for arbitrary profiles.  The 'questionnaire' approach to data entry has limitations that will make it less optimal than custom-defined interfaces.  However, this function may be useful for simple applications or for systems that wish to support \\\"non-core\\\" resources with minimal development effort.\",
  \"experimental\": false,
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
  },
  \"name\": \"Questionnaire\",
  \"parameter\": [
    {
      \"documentation\": \"A logical identifier (i.e. 'StructureDefinition.identifier''). The server must know the StructureDefinition or be able to retrieve it from other known repositories.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"identifier\",
      \"type\": \"Identifier\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The [StructureDefinition](structuredefinition.html) is provided directly as part of the request. Servers may choose not to accept profiles in this fashion\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"profile\",
      \"type\": \"StructureDefinition\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"The StructureDefinition's official URL (i.e. 'StructureDefinition.url'). The server must know the StructureDefinition or be able to retrieve it from other known repositories.\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"url\",
      \"scope\": [
        \"type\"
      ],
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
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/StructureDefinition/$questionnaire</p>\\n            <p>URL: [base]/StructureDefinition/[id]/$questionnaire</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>identifier</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#Identifier\\\">Identifier</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>A logical identifier (i.e. 'StructureDefinition.identifier''). The server must know the StructureDefinition or be able to retrieve it from other known repositories.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>profile</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"structuredefinition.html\\\">StructureDefinition</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The \\n                      <a href=\\\"structuredefinition.html\\\">StructureDefinition</a> is provided directly as part of the request. Servers may choose not to accept profiles in this fashion\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>url</td>\\n                <td>type</td>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The StructureDefinition's official URL (i.e. 'StructureDefinition.url'). The server must know the StructureDefinition or be able to retrieve it from other known repositories.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>supportedOnly</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>If true, the questionnaire will only include those elements marked as &quot;mustSupport='true'&quot; in the StructureDefinition.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>return</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"questionnaire.html\\\">Questionnaire</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The questionnaire form generated based on the StructureDefinition.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n            <div>\\n              <p>\\n                <strong>Open Issue</strong>: Ideally, extensions should be populated in the generated \\n                <a href=\\\"questionnaire.html\\\">Questionnaire</a> that will support taking \\n                <a href=\\\"questionnaireresponse.html\\\">QuestionnaireResponse</a> resources generated from the Questionnaire and turning them back into the appropriate resources.\\n              </p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Build Questionnaire\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/StructureDefinition-questionnaire\",
  \"version\": \"5.0.0\"
}"))
(define (questionnaire-operation handler)
  (define code "questionnaire")
  (list (operation-entry 'type code "StructureDefinition" handler)
        (operation-entry 'instance code "StructureDefinition" handler)))
(define remove-definition
  (string->jsexpr
   "{
  \"affectsState\": true,
  \"code\": \"remove\",
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
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"Remove content from an array in a large resource such as List or Group. See [Operations for Large Resources](operations-for-large-resources.html).\",
  \"experimental\": false,
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
  \"id\": \"Resource-remove\",
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
  },
  \"name\": \"Remove\",
  \"parameter\": [
    {
      \"documentation\": \"Resource containing content to remove. See [Operations for Large Resources](operations-for-large-resources.html).\",
      \"max\": \"1\",
      \"min\": 1,
      \"name\": \"removals\",
      \"type\": \"Resource\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Resource containing content removed. See [Operations for Large Resources](operations-for-large-resources.html).\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"return\",
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
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/Resource/[id]/$remove</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>removals</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"resource.html\\\">Resource</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Resource containing content to remove. See \\n                      <a href=\\\"operations-for-large-resources.html\\\">Operations for Large Resources</a>.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>return</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"resource.html\\\">Resource</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Resource containing content removed. See \\n                      <a href=\\\"operations-for-large-resources.html\\\">Operations for Large Resources</a>.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Remove from an array in a large resource\",
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Resource-remove\",
  \"version\": \"5.0.0\"
}"))
(define (remove-operation handler)
  (define code "remove")
  (list (operation-entry 'instance code "Resource" handler)))
(define snapshot-definition
  (string->jsexpr
   "{
  \"affectsState\": true,
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
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"Generates a [StructureDefinition](structuredefinition.html) instance  with  a snapshot, based on a differential in a specified [StructureDefinition](structuredefinition.html).   \\n\\nIf the operation is not called at the instance level, either *definition* or *url* 'in' parameters must be provided. If more than one is specified, servers may raise an error or may resolve with the parameter of their choice. If called at the instance level, these parameters will be ignored.\",
  \"experimental\": false,
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
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
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"StructureDefinition\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/StructureDefinition/$snapshot</p>\\n            <p>URL: [base]/StructureDefinition/[id]/$snapshot</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>definition</td>\\n                <td>type</td>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"structuredefinition.html\\\">StructureDefinition</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The \\n                      <a href=\\\"structuredefinition.html\\\">StructureDefinition</a> is provided directly as part of the request. Servers may choose not to accept profiles in this fashion\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>url</td>\\n                <td>type</td>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                  <br/>(\\n                  <a href=\\\"search.html#token\\\">token</a>)\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The StructureDefinition's canonical URL (i.e. 'StructureDefinition.url'). The server must know the structure definition, or be able to retrieve it from other known repositories.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>return</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"structuredefinition.html\\\">StructureDefinition</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The structure definition with a snapshot</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Generate Snapshot\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/StructureDefinition-snapshot\",
  \"version\": \"5.0.0\"
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
    }
  ],
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"The Statistics operation performs a set of statistical calculations on a set of clinical measurements such as a blood pressure as stored on the server.  This operation evaluates [Observation](observation.html) resources having valueQuantity elements that have UCUM unit codes. Observations with a status of 'entered-in-error' will be excluded from the calculations.      \\r\\rAlternatively, the [measure workflow pattern](measure.html) should be used when defining a quality measure (e.g. a description of how to calculate a particular measurement or set of measurements) as part of a workflow. \\r\\rThe set of Observations is defined by 4 parameters:\\r\\r*  the subject of the observations for which the statistics are being generated (`subject`)\\r* which observations to generate statistics for (`code` and `system`, or `coding`)\\r* the time period over which to generate statistics 'duration` or `period`)\\r* the set of statistical analyses to return (`statistic`)\\r\\rPossible statistical analyses (see [StatisticsCode](valueset-observation-statistics.html)):\\r\\r - **average** (\\\"Average\\\"): The [mean](https://en.wikipedia.org/wiki/Arithmetic_mean) of N measurements over the stated period.\\r\\n - **maximum** (\\\"Maximum\\\"): The [maximum](https://en.wikipedia.org/wiki/Maximal_element) value of N measurements over the stated period.\\r\\n - **minimum** (\\\"Minimum\\\"): The [minimum](https://en.wikipedia.org/wiki/Minimal_element) value of N measurements over the stated period.\\r\\n - **count** (\\\"Count\\\"): The [number] of valid measurements over the stated period that contributed to the other statistical outputs.\\r\\n - **total-count** (\\\"Total Count\\\"): The total [number] of valid measurements over the stated period, including observations that were ignored because they did not contain valid result values.\\r\\n - **median** (\\\"Median\\\"): The [median](https://en.wikipedia.org/wiki/Median) of N measurements over the stated period.\\r\\n - **std-dev** (\\\"Standard Deviation\\\"): The [standard deviation](https://en.wikipedia.org/wiki/Standard_deviation) of N measurements over the stated period.\\r\\n - **sum** (\\\"Sum\\\"): The [sum](https://en.wikipedia.org/wiki/Summation) of N measurements over the stated period.\\r\\n - **variance** (\\\"Variance\\\"): The [variance](https://en.wikipedia.org/wiki/Variance) of N measurements over the stated period.\\r\\n - **20-percent** (\\\"20th Percentile\\\"): The 20th [Percentile](https://en.wikipedia.org/wiki/Percentile) of N measurements over the stated period.\\r\\n - **80-percent** (\\\"80th Percentile\\\"): The 80th [Percentile](https://en.wikipedia.org/wiki/Percentile) of N measurements over the stated period.\\r\\n - **4-lower** (\\\"Lower Quartile\\\"): The lower [Quartile](https://en.wikipedia.org/wiki/Quartile) Boundary of N measurements over the stated period.\\r\\n - **4-upper** (\\\"Upper Quartile\\\"): The upper [Quartile](https://en.wikipedia.org/wiki/Quartile) Boundary of N measurements over the stated period.\\r\\n - **4-dev** (\\\"Quartile Deviation\\\"): The difference between the upper and lower [Quartiles](https://en.wikipedia.org/wiki/Quartile) is called the Interquartile range. (IQR = Q3-Q1) Quartile deviation or Semi-interquartile range is one-half the difference between the first and the third quartiles.\\r\\n - **5-1** (\\\"1st Quintile\\\"): The lowest of four values that divide the N measurements into a frequency distribution of five classes with each containing one fifth of the total population.\\r\\n - **5-2** (\\\"2nd Quintile\\\"): The second of four values that divide the N measurements into a frequency distribution of five classes with each containing one fifth of the total population.\\r\\n - **5-3** (\\\"3rd Quintile\\\"): The third of four values that divide the N measurements into a frequency distribution of five classes with each containing one fifth of the total population.\\r\\n - **5-4** (\\\"4th Quintile\\\"): The fourth of four values that divide the N measurements into a frequency distribution of five classes with each containing one fifth of the total population.\\r\\n - **skew** (\\\"Skew\\\"): Skewness is a measure of the asymmetry of the probability distribution of a real-valued random variable about its mean. The skewness value can be positive or negative, or even undefined.  Source: [Wikipedia](https://en.wikipedia.org/wiki/Skewness).\\r\\n - **kurtosis** (\\\"Kurtosis\\\"): Kurtosis  is a measure of the \\\"tailedness\\\" of the probability distribution of a real-valued random variable.   Source: [Wikipedia](https://en.wikipedia.org/wiki/Kurtosis).\\r\\n - **regression** (\\\"Regression\\\"): Linear regression is an approach for modeling two-dimensional sample points with one independent variable and one dependent variable (conventionally, the x and y coordinates in a Cartesian coordinate system) and finds a linear function (a non-vertical straight line) that, as accurately as possible, predicts the dependent variable values as a function of the independent variables. Source: [Wikipedia](https://en.wikipedia.org/wiki/Simple_linear_regression)  This Statistic code will return both a gradient and an intercept value.\\r\\n\\r\\rIf successful, the operation returns an Observation resource for each code with the results of the statistical calculations as component value pairs where the component code = the statistical code. The Observation also contains the input parameters `patient`,`code` and `duration` parameters. If unsuccessful, an [OperationOutcome](operationoutcome.html) with an error message will be returned.\\r\\rThe client can request that all the observations on which the statistics are based be returned as well, using the include parameter. If an include parameter is specified, a limit may also be specified; the sources observations are subsetted at the server's discretion if count > limit. This functionality is included with the intent of supporting graphical presentation\",
  \"experimental\": false,
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
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
        \"valueSet\": \"http://hl7.org/fhir/ValueSet/observation-statistics|5.0.0\"
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
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/Observation/$stats</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>subject</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The subject of the relevant Observations, which has the value of the Observation.subject.reference. E.g. 'Patient/123'. Reference can be to an absolute URL, but servers only perform stats on their own observations</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>code</td>\\n                <td/>\\n                <td>0..*</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The test code(s) upon which the statistics are being performed. Provide along with a system, or as a coding. For example, the LOINC code  =\\n2339-0 (Glucose [Mass/​volume] in Blood) will evaluate all relevant Observations with this code in \\n                      <code>Observation.code</code> and \\n                      <code>Observation.component.code</code>. For LOINC codes that are panels, e.g., 85354-9(Blood pressure panel with all children optional), the stats operation returns statistics for each of the individual panel measurements.  That means it will include and evaluate all values grouped by code for all the individual observations that are: 1) referenced in   \\n                      <code>.related</code> for \\n                      <code>.related.type</code> = 'has-member'  and 2) component observations in \\n                      <code>Observation.component</code>.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>system</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The system for the code(s). Or provide a coding instead</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>coding</td>\\n                <td/>\\n                <td>0..*</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#Coding\\\">Coding</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The test code upon which the statistics are being performed, as a Coding</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>duration</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#decimal\\\">decimal</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The time period of interest given as hours.  For example, the duration = &quot;1&quot; represents the last hour - the time period from on hour ago to now</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>period</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#Period\\\">Period</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The time period over which the calculations to be performed, if a duration is not provided</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>statistic</td>\\n                <td/>\\n                <td>1..*</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n                <td>\\n                  <a href=\\\"valueset-observation-statistics.html\\\">Statistics Code</a> (Required)\\n                </td>\\n                <td>\\n                  <div>\\n                    <p>average|max|min|count  The statistical operations to be performed on the relevant operations. Multiple statistics operations can be specified. These codes are defined \\n                      <a href=\\\"valueset-observation-statistics.html\\\">here</a>\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>include</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Whether to return the observations on which the statistics are based</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>limit</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#positiveInt\\\">positiveInt</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>If an include parameter is specified, a limit may also be specified to limit the number of source Observations returned.  If the include parameter is absent or equal to &quot;false&quot; the limit parameter SHALL be ignored by the server</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>statistics</td>\\n                <td/>\\n                <td>1..*</td>\\n                <td>\\n                  <a href=\\\"observation.html\\\">Observation</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>A set of observations, one observation for each code, each containing one component for each statistic. The Observation.component.code contains the statistic, and is relative to the Observation.code and cannot be interpreted independently.  The Observation will also contain a subject, effectivePeriod, and code reflecting the input parameters.  The status is fixed to \\n                      <code>final</code>.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>source</td>\\n                <td/>\\n                <td>0..*</td>\\n                <td>\\n                  <a href=\\\"observation.html\\\">Observation</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Source observations on which the statistics are based</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n            <div>\\n              <p>If \\n                <a href=\\\"extensibility.html#modifierExtension\\\">modifier extensions</a> are present in the Observation, they must be accounted for by implementers.  A modifier extension may affect the observation.value in a way that it should be excluded from the from the calculations.\\n              </p>\\n\\n              <p>This operation cannot be performed on observations that the user is not authorized to see.  It is assumed that the server has identified and secured the context appropriately, and can either associate the authorization context with a single patient, or determine whether the context has the rights to the nominated patient, if there is one. If there is no nominated patient (e.g. the operation is invoked at the system level) and the context is not associated with a single patient record, then the server should return an error. Specifying the relationship between the context, a user and patient records is outside the scope of this specification.</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Observation Statistics\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Observation-stats\",
  \"version\": \"5.0.0\"
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
    }
  ],
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"This operation is used to return the current status information about one or more topic-based Subscriptions.\",
  \"experimental\": false,
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
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
        \"valueSet\": \"http://hl7.org/fhir/ValueSet/subscription-status|5.0.0\"
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
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"Subscription\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/Subscription/$status</p>\\n            <p>URL: [base]/Subscription/[id]/$status</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>id</td>\\n                <td>type</td>\\n                <td>0..*</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#id\\\">id</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>At the Instance level, this parameter is ignored. At the Resource level, one or more FHIR ids to Subscription resources to get status information for. In the absence of any specified ids, the server returns the status for all Subscriptions available to the caller. Multiple values are joined via OR (e.g., &quot;id1&quot; OR &quot;id2&quot;).</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>status</td>\\n                <td>type</td>\\n                <td>0..*</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n                <td>\\n                  <a href=\\\"valueset-subscription-status.html\\\">Subscription Status</a> (Required)\\n                </td>\\n                <td>\\n                  <div>\\n                    <p>At the Instance level, this parameter is ignored. At the Resource level, a Subscription status code to filter by (e.g., &quot;active&quot;). In the absence of any specified status values, the server does not filter contents based on the status. Multiple values are joined via OR (e.g., &quot;error&quot; OR &quot;off&quot;).</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>return</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"bundle.html\\\">Bundle</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The operation returns a bundle containing zero or more SubscriptionStatus resources, one per Subscription in the request that was found. The Bundle type is &quot;searchset&quot;.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Get Current Subscription Status for One or More Subscriptions\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Subscription-status\",
  \"version\": \"5.0.0\"
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
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"The submit-data operation is used to submit data-of-interest for a measure. There is no expectation that the submitted data represents all the data-of-interest, only that all the data submitted is relevant to the calculation of the measure for a particular subject or population\",
  \"experimental\": false,
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
  \"id\": \"Measure-submit-data\",
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
  },
  \"name\": \"SubmitData\",
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
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/Measure/$submit-data</p>\\n            <p>URL: [base]/Measure/[id]/$submit-data</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>measureReport</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"measurereport.html\\\">MeasureReport</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The measure report being submitted</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>resource</td>\\n                <td/>\\n                <td>0..*</td>\\n                <td>\\n                  <a href=\\\"resource.html\\\">Resource</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The individual resources that make up the data-of-interest being submitted</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n            <div>\\n              <p>The effect of invoking this operation is that the submitted data is posted to the receiving system and can be used for subsequent calculation of the relevant quality measure. The data-of-interest for a measure can be determined by examining the measure definition, or by invoking the $data-requirements operation</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Submit Data\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Measure-submit-data\",
  \"version\": \"5.0.0\"
}"))
(define (submit-data-operation handler)
  (define code "submit-data")
  (list (operation-entry 'type code "Measure" handler)
        (operation-entry 'instance code "Measure" handler)))
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
    }
  ],
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"This operation is used to submit a Claim, Pre-Authorization or Pre-Determination (all instances of Claim resources) for adjudication either as a single Claim resource instance or as a Bundle containing the Claim and other referenced resources, or Bundle containing a batch of Claim resources, either as single Claims resources or Bundle resources, for processing. The only input parameter is the single Claim or Bundle resource and the only output is a single ClaimResponse, Bundle of ClaimResponses or an OperationOutcome resource.\",
  \"experimental\": false,
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
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
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"Claim\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/Claim/$submit</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>resource</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"resource.html\\\">Resource</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>A Claim resource or Bundle of claims, either as individual Claim resources or as Bundles each containing a single Claim plus referenced resources.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>return</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"resource.html\\\">Resource</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>A ClaimResponse resource or Bundle of claim responses, either as individual ClaimResponse resources or as Bundles each containing a single ClaimResponse plus referenced resources.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Submit a Claim resource for adjudication\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Claim-submit\",
  \"version\": \"5.0.0\"
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
    }
  ],
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"This operation is used to submit an EligibilityRequest for assessment either as a single EligibilityRequest resource instance or as a Bundle containing the EligibilityRequest and other referenced resources, or Bundle containing a batch of EligibilityRequest resources, either as single EligibilityRequests resources or Bundle resources, for processing. The only input parameter is the single EligibilityRequest or Bundle resource and the only output is a single EligibilityResponse, Bundle of EligibilityResponses or an OperationOutcome resource.\",
  \"experimental\": false,
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
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
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"CoverageEligibilityRequest\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/CoverageEligibilityRequest/$submit</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>resource</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"resource.html\\\">Resource</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>An EligibilityRequest resource or Bundle of EligibilityRequests, either as individual EligibilityRequest resources or as Bundles each containing a single EligibilityRequest plus referenced resources.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>return</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"resource.html\\\">Resource</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>An EligibilityResponse resource or Bundle of EligibilityResponse responses, either as individual EligibilityResponse resources or as Bundles each containing a single EligibilityResponse plus referenced resources.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Submit an EligibilityRequest resource for assessment\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/CoverageEligibilityRequest-submit\",
  \"version\": \"5.0.0\"
}"))
(define (CoverageEligibilityRequest-submit-operation handler)
  (define code "submit")
  (list (operation-entry 'type code "CoverageEligibilityRequest" handler)))
(define subset-definition
  (string->jsexpr
   "{
  \"affectsState\": false,
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
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"This operation asks the server to return a subset of the CapabilityStatement resource - just the REST parts that relate to a set of nominated resources - the resources that the client is interested in\",
  \"experimental\": false,
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
  },
  \"name\": \"Subset\",
  \"parameter\": [
    {
      \"documentation\": \"The canonical URL - use this if the subset is not invoked on an instance (or on the /metadata end-point)\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"server\",
      \"scope\": [
        \"type\",
        \"system\"
      ],
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
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/CapabilityStatement/$subset</p>\\n            <p>URL: [base]/CapabilityStatement/[id]/$subset</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>server</td>\\n                <td>type, system</td>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The canonical URL - use this if the subset is not invoked on an instance (or on the /metadata end-point)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>resource</td>\\n                <td/>\\n                <td>1..*</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>A resource that the client would like to include in the return</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>return</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"capabilitystatement.html\\\">CapabilityStatement</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The subsetted CapabilityStatement resource that is returned. This should be tagged with the SUBSETTED code</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Fetch a subset of the CapabilityStatement resource\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/CapabilityStatement-subset\",
  \"version\": \"5.0.0\"
}"))
(define (subset-operation handler)
  (define code "subset")
  (list (operation-entry 'type code "CapabilityStatement" handler)
        (operation-entry 'instance code "CapabilityStatement" handler)))
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
    }
  ],
  \"date\": \"2023-03-26T15:21:02+11:00\",
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
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
        \"valueSet\": \"http://hl7.org/fhir/ValueSet/concept-subsumption-outcome|5.0.0\"
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
  \"status\": \"active\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/CodeSystem/$subsumes</p>\\n            <p>URL: [base]/CodeSystem/[id]/$subsumes</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>codeA</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The &quot;A&quot; code that is to be tested. If a code is provided, a system must be provided</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>codeB</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The &quot;B&quot; code that is to be tested. If a code is provided, a system must be provided</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>system</td>\\n                <td>type</td>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The code system in which subsumption testing is to be performed. This must be provided unless the operation is invoked on a code system instance</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>version</td>\\n                <td>type</td>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The version of the code system, if one was provided in the source data</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>codingA</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#Coding\\\">Coding</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The &quot;A&quot; Coding that is to be tested. The code system does not have to match the specified subsumption code system, but the relationships between the code systems must be well established</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>codingB</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#Coding\\\">Coding</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The &quot;B&quot; Coding that is to be tested. The code system does not have to match the specified subsumption code system, but the relationships between the code systems must be well established</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>outcome</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n                <td>\\n                  <a href=\\\"valueset-concept-subsumption-outcome.html\\\">Concept Subsumption Outcome</a> (Required)\\n                </td>\\n                <td>\\n                  <div>\\n                    <p>The subsumption relationship between code/Coding &quot;A&quot; and code/Coding &quot;B&quot;. There are 4 possible codes to be returned (equivalent, subsumes, subsumed-by, and not-subsumed) as defined in the concept-subsumption-outcome value set.  If the server is unable to determine the relationship between the codes/Codings, then it returns an error response with an OperationOutcome.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Subsumption Testing\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/CodeSystem-subsumes\",
  \"version\": \"5.0.0\"
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
    }
  ],
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"The transform operation takes input content, applies a structure map transform, and then returns the output.\",
  \"experimental\": false,
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
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
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"StructureMap\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/StructureMap/$transform</p>\\n            <p>URL: [base]/StructureMap/[id]/$transform</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>source</td>\\n                <td>type</td>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The structure map to apply. This is only needed if the operation is invoked at the resource level and no structureMap has been provided. If the $transform operation is invoked on a particular structure map, this will be ignored by the server</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>sourceMap</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"structuremap.html\\\">StructureMap</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The structure map to apply. This is only needed when the operation is invoked at the resource level and no URI has been provided.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>supportingMap</td>\\n                <td/>\\n                <td>0..*</td>\\n                <td>\\n                  <a href=\\\"structuremap.html\\\">StructureMap</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>StructureMap resources that support the source map. If a source URL is provided, the map can be provided in this parameter (or it can be provided as sourceMap).</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>srcMap</td>\\n                <td/>\\n                <td>0..*</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The same as structureMap, but the resource is provided in the mapping language rather than as a structureMap.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>content</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"resource.html\\\">Resource</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The logical content to transform</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>return</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"resource.html\\\">Resource</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The result of the transform</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n            <div>\\n              <p>The input and return are specified as 'Resources'. In most usage of the $transform operation, either the input or return content is not a valid FHIR resource. In these cases, the return type is actually a \\n                <a href=\\\"binary.html\\\">Binary</a> resource. For this operation, the Binary resources may be encoded directly, using a mime-type, as shown in the example. Note: this specification does not yet address the means by which the servers may know the correct mime types for the various content involved\\n              </p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Model Instance Transformation\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/StructureMap-transform\",
  \"version\": \"5.0.0\"
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
    }
  ],
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"This operation returns an identifier of the target type. The operation takes 5 parameters:     \\n\\n* a source identifier value - either a URI, an OID, or a v2 table 0396 (other) code  \\n*  a code for what type of identifier the source identifier is     \\n\\n* a code for what kind of identifier is desired (URI, OID, v2 table 0396 identifier)     \\n\\n* an optional parameter preferredOnly for whether only the preferred identifier is desired     \\n\\n* an optional date to return only identifiers that have a validity period that includes that date   \\n\\nand returns either the requested identifier(s), or an HTTP errors response with an OperationOutcome because either the provided identifier was not recognized, or the requested identiifer type is not known.\",
  \"experimental\": false,
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
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
        \"valueSet\": \"http://hl7.org/fhir/ValueSet/namingsystem-identifier-type|5.0.0\"
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
        \"valueSet\": \"http://hl7.org/fhir/ValueSet/namingsystem-identifier-type|5.0.0\"
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
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"NamingSystem\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/NamingSystem/$translate-id</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>id</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The server parses the provided identifier to see what type it is (e.g. a URI, an OID as a URI, a plain OID, or a v2 table 0396 code). If the server can't tell what type of identifier it is, it can try it as multiple types. It is an error if more than one system matches the provided identifier</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>sourceType</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n                <td>\\n                  <a href=\\\"valueset-namingsystem-identifier-type.html\\\">Naming System Identifier Type</a> (Required)\\n                </td>\\n                <td/>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>targetType</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n                <td>\\n                  <a href=\\\"valueset-namingsystem-identifier-type.html\\\">Naming System Identifier Type</a> (Required)\\n                </td>\\n                <td/>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>preferredOnly</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>If preferredOnly = true then return only the preferred identifier, or if preferredOnly = false then return all available ids.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>date</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#dateTime\\\">dateTime</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>If 'date' is supplied return only ids that have a validity period that includes that date.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>result</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>True if the identifier could be translated successfully.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>targetIdentifier</td>\\n                <td/>\\n                <td>0..*</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The target identifer(s) of the requested type</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>targetIdentifer.preferred</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Whether the target identifier is preferred.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>targetIdentifier.period</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#Period\\\">Period</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The perioid when the target identifier is valid.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n            <div>\\n              <p>Servers handle this request by finding the provided identifier in their known naming systems, and returning the requested identifier type (\\n                <a href=\\\"namingsystem-definitions.html#NamingSystem.uniqueId.type\\\">NamingSystem.uniqueId.type</a>).\\n              </p>\\n\\n              <p>If the server wishes, it can also look through all code systems and value sets it knows about when attempting to find the requested identifier</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Translate id\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/NamingSystem-translate-id\",
  \"version\": \"5.0.0\"
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
    }
  ],
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"Translate a code from one value set to another, based on the specified ConceptMap resource. If no ConceptMap resource is specified, then other additional knowledge available to the server may be used. \\r\\n\\r\\n One (and only one) of the in parameters (sourceCode, sourceCoding, sourceCodeableConcept, targetCode, targetCoding, or targetCodeableConcept) SHALL be provided, to identify the code that is to be translated.  \\r\\n\\r\\n The operation returns a set of parameters including a 'result' for whether there is an acceptable match, and a list of possible matches. Note that the list of matches may include notes of codes for which mapping is specifically excluded (i.e. 'not-related-to'), so implementers have to check the target.relationship for each match. If a source* parameter is provided, the $translate operation will return all matches whereby the provided source concept is the source of a mapping relationship (in a specified ConceptMap or otherwise known to the server). If a target* parameter is provided, the $translate operation will return all matches whereby the provided target concept is the target of a mapping relationship (in a specified ConceptMap or otherwise known to the server). Note: The source value set is an optional parameter because in some cases, the client cannot know what the source value set is. However, without a source value set, the server may be unable to safely identify an applicable concept map, and would return an error. For this reason, a source value set SHOULD always be provided. Note that servers may be able to identify an appropriate concept map without a source value set if there is a full mapping for the entire code system in the concept map, or by manual intervention.\",
  \"experimental\": false,
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
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
      \"type\": \"uri\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"A target coding to translate to\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"targetCoding\",
      \"type\": \"uri\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"A full codeableConcept to validate. The server can translate any of the coding values (e.g. existing translations) as it chooses\",
      \"max\": \"1\",
      \"min\": 0,
      \"name\": \"targetCodeableConcept\",
      \"type\": \"uri\",
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
              \"valueUri\": \"boolean\"
            },
            {
              \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
              \"valueUri\": \"Quantity\"
            }
          ],
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
              \"extension\": [
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
                },
                {
                  \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                  \"valueUri\": \"code\"
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
                  \"valueUri\": \"boolean\"
                },
                {
                  \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                  \"valueUri\": \"Quantity\"
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
        },
        {
          \"documentation\": \"An data value in an additional attribute that this mapping depends on\",
          \"max\": \"*\",
          \"min\": 0,
          \"name\": \"dependsOn\",
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
                },
                {
                  \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                  \"valueUri\": \"uri\"
                },
                {
                  \"url\": \"http://hl7.org/fhir/StructureDefinition/operationdefinition-allowed-type\",
                  \"valueUri\": \"id\"
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
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"ConceptMap\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"draft\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/ConceptMap/$translate</p>\\n            <p>URL: [base]/ConceptMap/[id]/$translate</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>url</td>\\n                <td>type</td>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>A canonical URL for a concept map. The server must know the concept map (e.g. it is defined explicitly in the server's concept maps, or it is defined implicitly by some code system known to the server.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>conceptMap</td>\\n                <td>type</td>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"conceptmap.html\\\">ConceptMap</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The concept map is provided directly as part of the request. Servers may choose not to accept concept maps in this fashion.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>conceptMapVersion</td>\\n                <td>type</td>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The identifier that is used to identify a specific version of the concept map to be used for the translation. This is an arbitrary value managed by the concept map author and is not expected to be globally unique. For example, it might be a timestamp (e.g. yyyymmdd) if a managed version is not available.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>sourceCode</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The code that is to be translated. If a code is provided, a system must be provided</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>system</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The system for the code that is to be translated</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>version</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The version of the system, if one was provided in the source data</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>sourceScope</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Limits the scope of the $translate operation to source codes (ConceptMap.group.element.code) that are members of this value set.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>sourceCoding</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#Coding\\\">Coding</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>A coding to translate</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>sourceCodeableConcept</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#CodeableConcept\\\">CodeableConcept</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>A full codeableConcept to validate. The server can translate any of the coding values (e.g. existing translations) as it chooses</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>targetCode</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The target code that is to be translated to. If a code is provided, a system must be provided</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>targetCoding</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>A target coding to translate to</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>targetCodeableConcept</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>A full codeableConcept to validate. The server can translate any of the coding values (e.g. existing translations) as it chooses</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>targetScope</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Limits the scope of the $translate operation to target codes (ConceptMap.group.element.target.code) that are members of this value set.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>targetSystem</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>identifies a target code system in which a mapping is sought. This parameter is an alternative to the targetScope parameter - only one is required. Searching for any translation to a target code system irrespective of the context (e.g. target valueset) may lead to unsafe results, and it is at the discretion of the server to decide when to support this operation</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>dependency</td>\\n                <td/>\\n                <td>0..*</td>\\n                <td/>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Data from another attribute that may help produce the correct mapping</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>dependency.attribute</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The attribute for this dependency</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>dependency.value</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a> | \\n                  <a href=\\\"datatypes.html#Coding\\\">Coding</a> | \\n                  <a href=\\\"datatypes.html#string\\\">string</a> | \\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a> | \\n                  <a href=\\\"datatypes.html#Quantity\\\">Quantity</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The data value for this dependency</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>result</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>True if the concept could be translated successfully. The value can only be true if at least one returned match has a relationship other than 'not-related-to'.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>message</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Error details, for display to a human. If this is provided when result = true, the message carries hints and warnings (e.g. a note that the matches could be improved by providing additional detail)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>match</td>\\n                <td/>\\n                <td>0..*</td>\\n                <td/>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>A concept in the target value set with a relationship. Note that there may be multiple matches of equal or differing relationships, and the matches may include the 'not-related-to' relationship value which means that there is no translation</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>match.relationship</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>A code indicating the relationship (e.g., equivalent) of the translation, using values from \\n                      <a href=\\\"valueset-concept-map-relationship.html\\\">ConceptMapRelationship</a>\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>match.concept</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#Coding\\\">Coding</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The translation outcome. Note that this would never have userSelected = true, since the process of translations implies that the user is not selecting the code (and only the client could know differently)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>match.property</td>\\n                <td/>\\n                <td>0..*</td>\\n                <td/>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>A property of this mapping (may be used to supply for example, mapping priority, provenance, presentation hints, flag as experimental, and additional documentation)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>match.property.uri</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The uri that identifies the property</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>match.property.value</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#Coding\\\">Coding</a> | \\n                  <a href=\\\"datatypes.html#string\\\">string</a> | \\n                  <a href=\\\"datatypes.html#integer\\\">integer</a> | \\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a> | \\n                  <a href=\\\"datatypes.html#dateTime\\\">dateTime</a> | \\n                  <a href=\\\"datatypes.html#decimal\\\">decimal</a> | \\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The value of the property</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>match.product</td>\\n                <td/>\\n                <td>0..*</td>\\n                <td/>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>A data value to go in an attribute that is the product of this mapping</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>match.product.attribute</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The attribute for this product</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>match.product.value</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a> | \\n                  <a href=\\\"datatypes.html#Coding\\\">Coding</a> | \\n                  <a href=\\\"datatypes.html#string\\\">string</a> | \\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a> | \\n                  <a href=\\\"datatypes.html#Quantity\\\">Quantity</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The value for this product</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>match.dependsOn</td>\\n                <td/>\\n                <td>0..*</td>\\n                <td/>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>An data value in an additional attribute that this mapping depends on</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>match.dependsOn.attribute</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The attribute for this product</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>match.dependsOn.value</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a> | \\n                  <a href=\\\"datatypes.html#Coding\\\">Coding</a> | \\n                  <a href=\\\"datatypes.html#string\\\">string</a> | \\n                  <a href=\\\"datatypes.html#integer\\\">integer</a> | \\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a> | \\n                  <a href=\\\"datatypes.html#dateTime\\\">dateTime</a> | \\n                  <a href=\\\"datatypes.html#decimal\\\">decimal</a> | \\n                  <a href=\\\"datatypes.html#uri\\\">uri</a> | \\n                  <a href=\\\"datatypes.html#id\\\">id</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The value for this product</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>match.originMap</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The canonical reference to the concept map from which this mapping comes from</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Concept Translation\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/ConceptMap-translate\",
  \"version\": \"5.0.0\"
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
    }
  ],
  \"date\": \"2023-03-26T15:21:02+11:00\",
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
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
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"CodeSystem\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"active\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/CodeSystem/$validate-code</p>\\n            <p>URL: [base]/CodeSystem/[id]/$validate-code</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>url</td>\\n                <td>type</td>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>CodeSystem URL. The server must know the code system (e.g. it is defined explicitly in the server'scode systems, or it is known implicitly by the server</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>codeSystem</td>\\n                <td>type</td>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"codesystem.html\\\">CodeSystem</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The codeSystem is provided directly as part of the request. Servers may choose not to accept code systems in this fashion. This parameter is used when the client wants the server to check against a code system that is not stored on the server</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>code</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The code that is to be validated</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>version</td>\\n                <td>type</td>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The version of the code system, if one was provided in the source data</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>display</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The display associated with the code, if provided. If a display is provided a code must be provided. If no display is provided, the server cannot validate the display value, but may choose to return a recommended display name in an extension in the outcome. Whether displays are case sensitive is code system dependent</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>coding</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#Coding\\\">Coding</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>A coding to validate. The system must match the specified code system</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>codeableConcept</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#CodeableConcept\\\">CodeableConcept</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>A full codeableConcept to validate. The server returns true if one of the coding values is in the code system, and may also validate that the codings are not in conflict with each other if more than one is present</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>date</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#dateTime\\\">dateTime</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The date for which the validation should be checked. Normally, this is the current conditions (which is the default values) but under some circumstances, systems need to validate that a correct code was used at some point in the past. A typical example of this would be where code selection is constrained to the set of codes that were available when the patient was treated, not when the record is being edited. Note that which date is appropriate is a matter for implementation policy.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>abstract</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>If this parameter has a value of true, the client is stating that the validation is being performed in a context where a concept designated as 'abstract' is appropriate/allowed to be used, and the server should regard abstract codes as valid. If this parameter is false, abstract codes are not considered to be valid.</p>\\n\\n                    <p>Note that. 'abstract' is a property defined by many HL7 code systems that indicates that the concept is a logical grouping concept that is not intended to be used asa 'concrete' concept to in an actual patient/care/process record. This language is borrowed from Object Orienated theory where 'asbtract' objects are never instantiated. However in the general record and terminology eco-system, there are many contexts where it is appropraite to use these codes e.g. as decision making criterion, or when editing value sets themselves. This parameter allows a client to indicate to the server that it is working in such a context.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>displayLanguage</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Specifies the language to be used for description when validating the display property</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>result</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>True if the concept details supplied are valid</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>message</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Error details, if result = false. If this is provided when result = true, the message carries hints and warnings</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>display</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>A valid display for the concept if the system wishes to display this to a user</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>code</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The code that was validated</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>system</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The system for the code that was validated</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>version</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The version of the system of the code that was validated</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>codeableConcept</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#CodeableConcept\\\">CodeableConcept</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>A codeableConcept containing codings for all the validated codes</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>issues</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"operationoutcome.html\\\">OperationOutcome</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>List of itemised issues with paths constrained to simple FHIRPath. Examples are CodeableConcept, CodeableConcept.coding[0], CodeableConcept.coding[1].display, or Coding.display</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Code System based Validation\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/CodeSystem-validate-code\",
  \"version\": \"5.0.0\"
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
    }
  ],
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"Validate that a coded value is in the set of codes allowed by a value set.\\n\\nIf the operation is not called at the instance level, one of the in parameters url, context or valueSet must be provided.  One (and only one) of the in parameters code, coding, or codeableConcept must be provided.  The operation returns a result (true / false), an error message, and the recommended display for the code. When validating a code or a coding, then the code, system and version output parameters **SHOULD** be populated when possible. When a validating a CodeableConcept, then the codeableConcept output parameter **SHOULD** be populated when possible.\",
  \"experimental\": false,
  \"extension\": [
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-fmm\",
      \"valueInteger\": 5
    },
    {
      \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
      \"valueCode\": \"normative\"
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
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
      \"documentation\": \"The identifier that is used to identify a specific version of the value set to be used when validating the code. This is an arbitrary value managed by the value set author and is not expected to be globally unique. For example, it might be a timestamp (e.g. yyyymmdd) if a managed version is not available.\",
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
      \"documentation\": \"If this parameter has a value of true or the parametter is ommitted, the client is stating that the validation is being performed in a context where a concept designated as 'abstract' is appropriate/allowed to be used, and the server should regard abstract codes as valid. If this parameter is false, abstract codes are not considered to be valid.\\n\\nNote that. 'abstract' is a property defined by many HL7 code systems that indicates that the concept is a logical grouping concept that is not intended to be used as a 'concrete' concept to in an actual patient/care/process record. This language is borrowed from object-orientated theory where 'abstract' entities are never instantiated. However in the general record and terminology eco-system, there are many contexts where it is appropriate to use these codes e.g. as decision making criterion, or when editing value sets themselves. This parameter allows a client to indicate to the server that it is working in such a context.\",
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
      \"documentation\": \"The supplement must be used when validating the code. Use of this parameter should result in $validate-code behaving the same way as if the supplements were included in the value set definition using the [http://hl7.org/fhir/StructureDefinition/valueset-supplement](http://hl7.org/fhir/extensions/StructureDefinition-valueset-supplement.html)\",
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"useSupplement\",
      \"type\": \"canonical\",
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
  \"publisher\": \"HL7 (FHIR Project)\",
  \"resource\": [
    \"ValueSet\"
  ],
  \"resourceType\": \"OperationDefinition\",
  \"status\": \"active\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/ValueSet/$validate-code</p>\\n            <p>URL: [base]/ValueSet/[id]/$validate-code</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>url</td>\\n                <td>type</td>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Value set Canonical URL. The server must know the value set (e.g. it is defined explicitly in the server's value sets, or it is defined implicitly by some code system known to the server</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>context</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The context of the value set, so that the server can resolve this to a value set to validate against. The recommended format for this URI is [Structure Definition URL]#[name or path into structure definition] e.g. http://hl7.org/fhir/StructureDefinition/observation-hspc-height-hspcheight#Observation.interpretation. Other forms may be used but are not defined. This form is only usable if the terminology server also has access to the conformance registry that the server is using, but can be used to delegate the mapping from an application context to a binding at run-time</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>valueSet</td>\\n                <td>type</td>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"valueset.html\\\">ValueSet</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The value set is provided directly as part of the request. Servers may choose not to accept value sets in this fashion. This parameter is used when the client wants the server to expand a value set that is not stored on the server</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>valueSetVersion</td>\\n                <td>type</td>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The identifier that is used to identify a specific version of the value set to be used when validating the code. This is an arbitrary value managed by the value set author and is not expected to be globally unique. For example, it might be a timestamp (e.g. yyyymmdd) if a managed version is not available.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>code</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The code that is to be validated. If a code is provided, a system or a context must be provided (if a context is provided, then the server SHALL ensure that the code is not ambiguous without a system)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>system</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The system for the code that is to be validated</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>systemVersion</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The version of the system, if one was provided in the source data</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>display</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The display associated with the code, if provided. If a display is provided a code must be provided. If no display is provided, the server cannot validate the display value, but may choose to return a recommended display name using the display parameter in the outcome. Whether displays are case sensitive is code system dependent</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>coding</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#Coding\\\">Coding</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>A coding to validate</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>codeableConcept</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#CodeableConcept\\\">CodeableConcept</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>A full codeableConcept to validate. The server returns true if one of the coding values is in the value set, and may also validate that the codings are not in conflict with each other if more than one is present</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>date</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#dateTime\\\">dateTime</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The date for which the validation should be checked. Normally, this is the current conditions (which is the default values) but under some circumstances, systems need to validate that a correct code was used at some point in the past. A typical example of this would be where code selection is constrained to the set of codes that were available when the patient was treated, not when the record is being edited. Note that which date is appropriate is a matter for implementation policy.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>abstract</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>If this parameter has a value of true or the parametter is ommitted, the client is stating that the validation is being performed in a context where a concept designated as 'abstract' is appropriate/allowed to be used, and the server should regard abstract codes as valid. If this parameter is false, abstract codes are not considered to be valid.</p>\\n\\n                    <p>Note that. 'abstract' is a property defined by many HL7 code systems that indicates that the concept is a logical grouping concept that is not intended to be used as a 'concrete' concept to in an actual patient/care/process record. This language is borrowed from object-orientated theory where 'abstract' entities are never instantiated. However in the general record and terminology eco-system, there are many contexts where it is appropriate to use these codes e.g. as decision making criterion, or when editing value sets themselves. This parameter allows a client to indicate to the server that it is working in such a context.</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>displayLanguage</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Specifies the language to be used for description when validating the display property</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>useSupplement</td>\\n                <td/>\\n                <td>0..*</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The supplement must be used when validating the code. Use of this parameter should result in $validate-code behaving the same way as if the supplements were included in the value set definition using the \\n                      <a href=\\\"http://hl7.org/fhir/extensions/StructureDefinition-valueset-supplement.html\\\">http://hl7.org/fhir/StructureDefinition/valueset-supplement</a>\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>result</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#boolean\\\">boolean</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>True if the concept details supplied are valid</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>message</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Error details, if result = false. If this is provided when result = true, the message carries hints and warnings</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>display</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>A valid display for the concept if the system wishes to display this to a user</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>code</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The code that was validated</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>system</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#uri\\\">uri</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The system for the code that was validated</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>version</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#string\\\">string</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>The version of the system of the code that was validated</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>codeableConcept</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#CodeableConcept\\\">CodeableConcept</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>A codeableConcept containing codings for all the validated codes</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>issues</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"operationoutcome.html\\\">OperationOutcome</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>List of itemised issues with paths constrained to simple FHIRPath. Examples are CodeableConcept, CodeableConcept.coding[0], CodeableConcept.coding[1].display, or Coding.display</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n            <div>\\n              <p>Note: the correct behavior of validation with regard to language for Coding.display items is currently undefined, and further development and testing may lead to specific requirements or recommendations in subsequent releases</p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Value Set based Validation\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/ValueSet-validate-code\",
  \"version\": \"5.0.0\"
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
    }
  ],
  \"date\": \"2023-03-26T15:21:02+11:00\",
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
  },
  \"name\": \"Validate\",
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
        \"extension\": [
          {
            \"url\": \"http://hl7.org/fhir/StructureDefinition/elementdefinition-bindingName\",
            \"valueString\": \"ResourceValidationMode\"
          }
        ],
        \"strength\": \"required\",
        \"valueSet\": \"http://hl7.org/fhir/ValueSet/resource-validation-mode|5.0.0\"
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
      \"type\": \"canonical\",
      \"use\": \"in\"
    },
    {
      \"documentation\": \"Indicates an implementation context that applies to this validation.  Influences which [additionalBindings](terminologies.html#binding) are relevant.  NOTE: Expectations around subsumption testing, etc. are not yet defined and may be server-specific.\",
      \"extension\": [
        {
          \"url\": \"http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status\",
          \"valueCode\": \"trial-use\"
        }
      ],
      \"max\": \"*\",
      \"min\": 0,
      \"name\": \"usageContext\",
      \"type\": \"UsageContext\",
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
  \"status\": \"active\",
  \"system\": false,
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/Resource/$validate</p>\\n            <p>URL: [base]/Resource/[id]/$validate</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>resource</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"resource.html\\\">Resource</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Must be present unless the mode is &quot;delete&quot;</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>mode</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n                <td>\\n                  <a href=\\\"valueset-resource-validation-mode.html\\\">Resource Validation Mode</a> (Required)\\n                </td>\\n                <td>\\n                  <div>\\n                    <p>Default is 'no action'; (e.g. general validation)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>profile</td>\\n                <td/>\\n                <td>0..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#canonical\\\">canonical</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>If this is nominated, then the resource is validated against this specific profile. If a profile is nominated, and the server cannot validate against the nominated profile, it SHALL return an error</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>IN</td>\\n                <td>usageContext \\n                  <a style=\\\"padding-left: 3px; padding-right: 3px; border: 1px grey solid; font-weight: bold; color: black; background-color: #fff5e6\\\" href=\\\"versions.html#std-process\\\" title=\\\"Standards Status = Trial Use\\\">TU</a>\\n                </td>\\n                <td/>\\n                <td>0..*</td>\\n                <td>\\n                  <a href=\\\"metadatatypes.html#UsageContext\\\">UsageContext</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>Indicates an implementation context that applies to this validation.  Influences which \\n                      <a href=\\\"terminologies.html#binding\\\">additionalBindings</a> are relevant.  NOTE: Expectations around subsumption testing, etc. are not yet defined and may be server-specific.\\n                    </p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>return</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"operationoutcome.html\\\">OperationOutcome</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>If the operation outcome does not list any errors, and a mode was specified, then this is an indication that the operation would be expected to succeed (excepting for transactional integrity issues, see below)</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n            <div>\\n              <p>This operation may be used during design and development to validate application design. It can also be used at run-time. One possible use might be that a client asks the server whether a proposed update is valid as the user is editing a dialog and displays an updated error to the user. The operation can be used as part of a light-weight two phase commit protocol but there is no expectation that the server will hold the content of the resource after this operation is used, or that the server guarantees to successfully perform an actual create, update or delete after the validation operation completes.</p>\\n\\n              <p>This operation returns a 200 Ok provided that it was possible to perform validation, irrespective of whether validation issues were found.  However, it is possible that certain errors in the validated content (e.g. invalid character set, broken JSON, etc.) may cause the overall validation operation to fail with a 4xx or 5xx series response.</p>\\n\\n              <p>Note: the correct behavior of validation with regard to language (especially for Coding.display) is currently undefined, and further development and testing may lead to specific requirements or recommendations in subsequent releases</p>\\n\\n              <p>Future versions of this specifcation may add additional validation parameters. A candidate list is maintained with the \\n                <a href=\\\"https://confluence.hl7.org/display/FHIR/Using+the+FHIR+Validator\\\">FHIR Validator Documentation</a>\\n              </p>\\n\\n            </div>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Validate a resource\",
  \"type\": true,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/Resource-validate\",
  \"version\": \"5.0.0\"
}"))
(define (validate-operation handler)
  (define code "validate")
  (list (operation-entry 'type code "Resource" handler)
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
    }
  ],
  \"date\": \"2023-03-26T15:21:02+11:00\",
  \"description\": \"Using the [FHIR Version Mime Type Parameter](http.html#version-parameter), a server can support [multiple versions on the same end-point](versioning.html#mt-version). The only way for client to find out what versions a server supports in this fashion is the $versions operation. The client invokes the operation with no parameters. and the server returns the list of supported versions, along with the default version it will use if no fhirVersion parameter is present\",
  \"experimental\": false,
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
    \"lastUpdated\": \"2023-03-26T15:21:02.749+11:00\"
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
        \"valueSet\": \"http://hl7.org/fhir/ValueSet/FHIR-version|5.0.0\"
      },
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
  \"text\": {
    \"div\": \"<div xmlns=\\\"http://www.w3.org/1999/xhtml\\\">\\n            <p>URL: [base]/$versions</p>\\n            <p>Parameters</p>\\n            <table class=\\\"grid\\\">\\n              <tr>\\n                <td>\\n                  <b>Use</b>\\n                </td>\\n                <td>\\n                  <b>Name</b>\\n                </td>\\n                <td>\\n                  <b>Scope</b>\\n                </td>\\n                <td>\\n                  <b>Cardinality</b>\\n                </td>\\n                <td>\\n                  <b>Type</b>\\n                </td>\\n                <td>\\n                  <b>Binding</b>\\n                </td>\\n                <td>\\n                  <b>Documentation</b>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>version</td>\\n                <td/>\\n                <td>1..*</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n                <td/>\\n                <td>\\n                  <div>\\n                    <p>A version supported by the server. Use the major.minor version like 3.0</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n              <tr>\\n                <td>OUT</td>\\n                <td>default</td>\\n                <td/>\\n                <td>1..1</td>\\n                <td>\\n                  <a href=\\\"datatypes.html#code\\\">code</a>\\n                </td>\\n                <td>\\n                  <a href=\\\"valueset-FHIR-version.html\\\">FHIRVersion</a> (Required)\\n                </td>\\n                <td>\\n                  <div>\\n                    <p>The default version for the server. Use the major.minor version like 3.0</p>\\n\\n                  </div>\\n                </td>\\n              </tr>\\n            </table>\\n          </div>\",
    \"status\": \"extensions\"
  },
  \"title\": \"Discover what versions a server supports\",
  \"type\": false,
  \"url\": \"http://hl7.org/fhir/OperationDefinition/CapabilityStatement-versions\",
  \"version\": \"5.0.0\"
}"))
(define (versions-operation handler)
  (define code "versions")
  (list (operation-entry 'system code #f handler)))
(define operation-definitions
  (list add-definition ActivityDefinition-apply-definition ChargeItemDefinition-apply-definition PlanDefinition-apply-definition SpecimenDefinition-apply-definition care-gaps-definition closure-definition collect-data-definition conforms-definition convert-definition current-canonical-definition ActivityDefinition-data-requirements-definition Library-data-requirements-definition Measure-data-requirements-definition PlanDefinition-data-requirements-definition docref-definition document-definition evaluate-measure-definition events-definition Encounter-everything-definition EpisodeOfCare-everything-definition Group-everything-definition MedicinalProductDefinition-everything-definition Patient-everything-definition example-query-high-risk-definition expand-definition filter-definition find-matches-definition find-definition generate-definition get-ws-binding-token-definition graph-definition graphql-definition implements-definition lastn-definition lookup-definition match-definition merge-definition meta-add-definition meta-delete-definition meta-definition populate-definition preferred-id-definition process-message-definition questionnaire-definition remove-definition snapshot-definition stats-definition status-definition submit-data-definition Claim-submit-definition CoverageEligibilityRequest-submit-definition subset-definition subsumes-definition transform-definition translate-id-definition translate-definition CodeSystem-validate-code-definition ValueSet-validate-code-definition validate-definition versions-definition))
