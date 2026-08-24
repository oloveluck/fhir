#lang racket/base
;;; GENERATED — DO NOT EDIT (verified by raco fhir check).
;; REQUIRED-bound ValueSets expanded OFFLINE from this package's own CodeSystems. Required
;; both normally and for-syntax by the tower index, so form macros enforce these at compile
;; time and runtime consumers can read the same catalogue. Absent urls fail open.
(require fhir/model/binding)
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/FHIR-version"
  '("0.0.80" "0.0.81" "0.0.82" "0.01" "0.05" "0.06" "0.11" "0.4.0" "0.5.0" "1.0.0" "1.0.1" "1.0.2" "1.1.0" "1.4.0" "1.6.0" "1.8.0" "3.0.0" "3.0.1" "3.3.0" "3.5.0" "4.0.0" "4.0.1"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/account-status"
  '("active" "entered-in-error" "inactive" "on-hold" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/action-cardinality-behavior"
  '("multiple" "single"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/action-condition-kind"
  '("applicability" "start" "stop"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/action-grouping-behavior"
  '("logical-group" "sentence-group" "visual-group"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/action-participant-type"
  '("device" "patient" "practitioner" "related-person"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/action-precheck-behavior"
  '("no" "yes"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/action-relationship-type"
  '("after" "after-end" "after-start" "before" "before-end" "before-start" "concurrent" "concurrent-with-end" "concurrent-with-start"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/action-required-behavior"
  '("could" "must" "must-unless-documented"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/action-selection-behavior"
  '("all" "all-or-none" "any" "at-most-one" "exactly-one" "one-or-more"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/address-type"
  '("both" "physical" "postal"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/address-use"
  '("billing" "home" "old" "temp" "work"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/administrative-gender"
  '("female" "male" "other" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/adverse-event-actuality"
  '("actual" "potential"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/all-types"
  '("Account" "ActivityDefinition" "Address" "AdverseEvent" "Age" "AllergyIntolerance" "Annotation" "Any" "Appointment" "AppointmentResponse" "Attachment" "AuditEvent" "BackboneElement" "Basic" "Binary" "BiologicallyDerivedProduct" "BodyStructure" "Bundle" "CapabilityStatement" "CarePlan" "CareTeam" "CatalogEntry" "ChargeItem" "ChargeItemDefinition" "Claim" "ClaimResponse" "ClinicalImpression" "CodeSystem" "CodeableConcept" "Coding" "Communication" "CommunicationRequest" "CompartmentDefinition" "Composition" "ConceptMap" "Condition" "Consent" "ContactDetail" "ContactPoint" "Contract" "Contributor" "Count" "Coverage" "CoverageEligibilityRequest" "CoverageEligibilityResponse" "DataRequirement" "DetectedIssue" "Device" "DeviceDefinition" "DeviceMetric" "DeviceRequest" "DeviceUseStatement" "DiagnosticReport" "Distance" "DocumentManifest" "DocumentReference" "DomainResource" "Dosage" "Duration" "EffectEvidenceSynthesis" "Element" "ElementDefinition" "Encounter" "Endpoint" "EnrollmentRequest" "EnrollmentResponse" "EpisodeOfCare" "EventDefinition" "Evidence" "EvidenceVariable" "ExampleScenario" "ExplanationOfBenefit" "Expression" "Extension" "FamilyMemberHistory" "Flag" "Goal" "GraphDefinition" "Group" "GuidanceResponse" "HealthcareService" "HumanName" "Identifier" "ImagingStudy" "Immunization" "ImmunizationEvaluation" "ImmunizationRecommendation" "ImplementationGuide" "InsurancePlan" "Invoice" "Library" "Linkage" "List" "Location" "MarketingStatus" "Measure" "MeasureReport" "Media" "Medication" "MedicationAdministration" "MedicationDispense" "MedicationKnowledge" "MedicationRequest" "MedicationStatement" "MedicinalProduct" "MedicinalProductAuthorization" "MedicinalProductContraindication" "MedicinalProductIndication" "MedicinalProductIngredient" "MedicinalProductInteraction" "MedicinalProductManufactured" "MedicinalProductPackaged" "MedicinalProductPharmaceutical" "MedicinalProductUndesirableEffect" "MessageDefinition" "MessageHeader" "Meta" "MolecularSequence" "Money" "MoneyQuantity" "NamingSystem" "Narrative" "NutritionOrder" "Observation" "ObservationDefinition" "OperationDefinition" "OperationOutcome" "Organization" "OrganizationAffiliation" "ParameterDefinition" "Parameters" "Patient" "PaymentNotice" "PaymentReconciliation" "Period" "Person" "PlanDefinition" "Population" "Practitioner" "PractitionerRole" "Procedure" "ProdCharacteristic" "ProductShelfLife" "Provenance" "Quantity" "Questionnaire" "QuestionnaireResponse" "Range" "Ratio" "Reference" "RelatedArtifact" "RelatedPerson" "RequestGroup" "ResearchDefinition" "ResearchElementDefinition" "ResearchStudy" "ResearchSubject" "Resource" "RiskAssessment" "RiskEvidenceSynthesis" "SampledData" "Schedule" "SearchParameter" "ServiceRequest" "Signature" "SimpleQuantity" "Slot" "Specimen" "SpecimenDefinition" "StructureDefinition" "StructureMap" "Subscription" "Substance" "SubstanceAmount" "SubstanceNucleicAcid" "SubstancePolymer" "SubstanceProtein" "SubstanceReferenceInformation" "SubstanceSourceMaterial" "SubstanceSpecification" "SupplyDelivery" "SupplyRequest" "Task" "TerminologyCapabilities" "TestReport" "TestScript" "Timing" "TriggerDefinition" "Type" "UsageContext" "ValueSet" "VerificationResult" "VisionPrescription" "base64Binary" "boolean" "canonical" "code" "date" "dateTime" "decimal" "id" "instant" "integer" "markdown" "oid" "positiveInt" "string" "time" "unsignedInt" "uri" "url" "uuid" "xhtml"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/allergy-intolerance-category"
  '("biologic" "environment" "food" "medication"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/allergy-intolerance-criticality"
  '("high" "low" "unable-to-assess"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/allergy-intolerance-type"
  '("allergy" "intolerance"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/appointmentstatus"
  '("arrived" "booked" "cancelled" "checked-in" "entered-in-error" "fulfilled" "noshow" "pending" "proposed" "waitlist"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/assert-direction-codes"
  '("request" "response"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/assert-operator-codes"
  '("contains" "empty" "equals" "eval" "greaterThan" "in" "lessThan" "notContains" "notEmpty" "notEquals" "notIn"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/assert-response-code-types"
  '("bad" "conflict" "created" "forbidden" "gone" "methodNotAllowed" "noContent" "notFound" "notModified" "okay" "preconditionFailed" "unprocessable"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/audit-event-action"
  '("C" "D" "E" "R" "U"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/audit-event-outcome"
  '("0" "12" "4" "8"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/binding-strength"
  '("example" "extensible" "preferred" "required"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/bundle-type"
  '("batch" "batch-response" "collection" "document" "history" "message" "searchset" "transaction" "transaction-response"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/capability-statement-kind"
  '("capability" "instance" "requirements"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/care-plan-activity-kind"
  '("Appointment" "CommunicationRequest" "DeviceRequest" "MedicationRequest" "NutritionOrder" "ServiceRequest" "Task" "VisionPrescription"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/care-plan-activity-status"
  '("cancelled" "completed" "entered-in-error" "in-progress" "not-started" "on-hold" "scheduled" "stopped" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/care-plan-intent"
  '("option" "order" "plan" "proposal"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/care-team-status"
  '("active" "entered-in-error" "inactive" "proposed" "suspended"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/chargeitem-status"
  '("aborted" "billable" "billed" "entered-in-error" "not-billable" "planned" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/claim-use"
  '("claim" "preauthorization" "predetermination"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/clinicalimpression-status"
  '("completed" "entered-in-error" "in-progress"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/code-search-support"
  '("all" "explicit"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/codesystem-content-mode"
  '("complete" "example" "fragment" "not-present" "supplement"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/codesystem-hierarchy-meaning"
  '("classified-with" "grouped-by" "is-a" "part-of"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/compartment-type"
  '("Device" "Encounter" "Patient" "Practitioner" "RelatedPerson"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/composition-attestation-mode"
  '("legal" "official" "personal" "professional"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/composition-status"
  '("amended" "entered-in-error" "final" "preliminary"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/concept-map-equivalence"
  '("disjoint" "equal" "equivalent" "inexact" "narrower" "relatedto" "specializes" "subsumes" "unmatched" "wider"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/concept-property-type"
  '("Coding" "boolean" "code" "dateTime" "decimal" "integer" "string"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/conceptmap-unmapped-mode"
  '("fixed" "other-map" "provided"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/conditional-delete-status"
  '("multiple" "not-supported" "single"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/conditional-read-status"
  '("full-support" "modified-since" "not-match" "not-supported"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/consent-data-meaning"
  '("authoredby" "dependents" "instance" "related"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/consent-provision-type"
  '("deny" "permit"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/consent-state-codes"
  '("active" "draft" "entered-in-error" "inactive" "proposed" "rejected"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/constraint-severity"
  '("error" "warning"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/contact-point-system"
  '("email" "fax" "other" "pager" "phone" "sms" "url"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/contact-point-use"
  '("home" "mobile" "old" "temp" "work"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/contract-publicationstatus"
  '("amended" "appended" "cancelled" "disputed" "entered-in-error" "executable" "executed" "negotiable" "offered" "policy" "rejected" "renewed" "resolved" "revoked" "terminated"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/contract-status"
  '("amended" "appended" "cancelled" "disputed" "entered-in-error" "executable" "executed" "negotiable" "offered" "policy" "rejected" "renewed" "resolved" "revoked" "terminated"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/contributor-type"
  '("author" "editor" "endorser" "reviewer"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/days-of-week"
  '("fri" "mon" "sat" "sun" "thu" "tue" "wed"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/defined-types"
  '("Account" "ActivityDefinition" "Address" "AdverseEvent" "Age" "AllergyIntolerance" "Annotation" "Appointment" "AppointmentResponse" "Attachment" "AuditEvent" "BackboneElement" "Basic" "Binary" "BiologicallyDerivedProduct" "BodyStructure" "Bundle" "CapabilityStatement" "CarePlan" "CareTeam" "CatalogEntry" "ChargeItem" "ChargeItemDefinition" "Claim" "ClaimResponse" "ClinicalImpression" "CodeSystem" "CodeableConcept" "Coding" "Communication" "CommunicationRequest" "CompartmentDefinition" "Composition" "ConceptMap" "Condition" "Consent" "ContactDetail" "ContactPoint" "Contract" "Contributor" "Count" "Coverage" "CoverageEligibilityRequest" "CoverageEligibilityResponse" "DataRequirement" "DetectedIssue" "Device" "DeviceDefinition" "DeviceMetric" "DeviceRequest" "DeviceUseStatement" "DiagnosticReport" "Distance" "DocumentManifest" "DocumentReference" "DomainResource" "Dosage" "Duration" "EffectEvidenceSynthesis" "Element" "ElementDefinition" "Encounter" "Endpoint" "EnrollmentRequest" "EnrollmentResponse" "EpisodeOfCare" "EventDefinition" "Evidence" "EvidenceVariable" "ExampleScenario" "ExplanationOfBenefit" "Expression" "Extension" "FamilyMemberHistory" "Flag" "Goal" "GraphDefinition" "Group" "GuidanceResponse" "HealthcareService" "HumanName" "Identifier" "ImagingStudy" "Immunization" "ImmunizationEvaluation" "ImmunizationRecommendation" "ImplementationGuide" "InsurancePlan" "Invoice" "Library" "Linkage" "List" "Location" "MarketingStatus" "Measure" "MeasureReport" "Media" "Medication" "MedicationAdministration" "MedicationDispense" "MedicationKnowledge" "MedicationRequest" "MedicationStatement" "MedicinalProduct" "MedicinalProductAuthorization" "MedicinalProductContraindication" "MedicinalProductIndication" "MedicinalProductIngredient" "MedicinalProductInteraction" "MedicinalProductManufactured" "MedicinalProductPackaged" "MedicinalProductPharmaceutical" "MedicinalProductUndesirableEffect" "MessageDefinition" "MessageHeader" "Meta" "MolecularSequence" "Money" "MoneyQuantity" "NamingSystem" "Narrative" "NutritionOrder" "Observation" "ObservationDefinition" "OperationDefinition" "OperationOutcome" "Organization" "OrganizationAffiliation" "ParameterDefinition" "Parameters" "Patient" "PaymentNotice" "PaymentReconciliation" "Period" "Person" "PlanDefinition" "Population" "Practitioner" "PractitionerRole" "Procedure" "ProdCharacteristic" "ProductShelfLife" "Provenance" "Quantity" "Questionnaire" "QuestionnaireResponse" "Range" "Ratio" "Reference" "RelatedArtifact" "RelatedPerson" "RequestGroup" "ResearchDefinition" "ResearchElementDefinition" "ResearchStudy" "ResearchSubject" "Resource" "RiskAssessment" "RiskEvidenceSynthesis" "SampledData" "Schedule" "SearchParameter" "ServiceRequest" "Signature" "SimpleQuantity" "Slot" "Specimen" "SpecimenDefinition" "StructureDefinition" "StructureMap" "Subscription" "Substance" "SubstanceAmount" "SubstanceNucleicAcid" "SubstancePolymer" "SubstanceProtein" "SubstanceReferenceInformation" "SubstanceSourceMaterial" "SubstanceSpecification" "SupplyDelivery" "SupplyRequest" "Task" "TerminologyCapabilities" "TestReport" "TestScript" "Timing" "TriggerDefinition" "UsageContext" "ValueSet" "VerificationResult" "VisionPrescription" "base64Binary" "boolean" "canonical" "code" "date" "dateTime" "decimal" "id" "instant" "integer" "markdown" "oid" "positiveInt" "string" "time" "unsignedInt" "uri" "url" "uuid" "xhtml"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/detectedissue-severity"
  '("high" "low" "moderate"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/device-nametype"
  '("manufacturer-name" "model-name" "other" "patient-reported-name" "udi-label-name" "user-friendly-name"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/device-statement-status"
  '("active" "completed" "entered-in-error" "intended" "on-hold" "stopped"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/device-status"
  '("active" "entered-in-error" "inactive" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/diagnostic-report-status"
  '("amended" "appended" "cancelled" "corrected" "entered-in-error" "final" "partial" "preliminary" "registered" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/discriminator-type"
  '("exists" "pattern" "profile" "type" "value"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/document-mode"
  '("consumer" "producer"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/document-reference-status"
  '("current" "entered-in-error" "superseded"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/document-relationship-type"
  '("appends" "replaces" "signs" "transforms"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/eligibilityrequest-purpose"
  '("auth-requirements" "benefits" "discovery" "validation"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/eligibilityresponse-purpose"
  '("auth-requirements" "benefits" "discovery" "validation"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/encounter-location-status"
  '("active" "completed" "planned" "reserved"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/encounter-status"
  '("arrived" "cancelled" "entered-in-error" "finished" "in-progress" "onleave" "planned" "triaged" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/endpoint-status"
  '("active" "entered-in-error" "error" "off" "suspended" "test"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/episode-of-care-status"
  '("active" "cancelled" "entered-in-error" "finished" "onhold" "planned" "waitlist"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/event-capability-mode"
  '("receiver" "sender"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/event-status"
  '("completed" "entered-in-error" "in-progress" "not-done" "on-hold" "preparation" "stopped" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/event-timing"
  '("AC" "ACD" "ACM" "ACV" "AFT" "AFT.early" "AFT.late" "C" "CD" "CM" "CV" "EVE" "EVE.early" "EVE.late" "HS" "MORN" "MORN.early" "MORN.late" "NIGHT" "NOON" "PC" "PCD" "PCM" "PCV" "PHS" "WAKE"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/examplescenario-actor-type"
  '("entity" "person"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/explanationofbenefit-status"
  '("active" "cancelled" "draft" "entered-in-error"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/exposure-state"
  '("exposure" "exposure-alternative"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/extension-context-type"
  '("element" "extension" "fhirpath"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/filter-operator"
  '("=" "descendent-of" "exists" "generalizes" "in" "is-a" "is-not-a" "not-in" "regex"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/flag-status"
  '("active" "entered-in-error" "inactive"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/fm-status"
  '("active" "cancelled" "draft" "entered-in-error"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/goal-status"
  '("accepted" "active" "cancelled" "completed" "entered-in-error" "on-hold" "planned" "proposed" "rejected"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/graph-compartment-rule"
  '("custom" "different" "identical" "matching"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/graph-compartment-use"
  '("condition" "requirement"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/group-measure"
  '("mean" "mean-of-mean" "mean-of-median" "median" "median-of-mean" "median-of-median"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/group-type"
  '("animal" "device" "medication" "person" "practitioner" "substance"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/guidance-response-status"
  '("data-requested" "data-required" "entered-in-error" "failure" "in-progress" "success"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/guide-page-generation"
  '("generated" "html" "markdown" "xml"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/guide-parameter-code"
  '("apply" "expansion-parameter" "generate-json" "generate-turtle" "generate-xml" "html-template" "path-pages" "path-resource" "path-tx-cache" "rule-broken-links"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/history-status"
  '("completed" "entered-in-error" "health-unknown" "partial"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/http-operations"
  '("delete" "get" "head" "options" "patch" "post" "put"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/http-verb"
  '("DELETE" "GET" "HEAD" "PATCH" "POST" "PUT"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/identifier-use"
  '("official" "old" "secondary" "temp" "usual"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/identity-assuranceLevel"
  '("level1" "level2" "level3" "level4"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/imagingstudy-status"
  '("available" "cancelled" "entered-in-error" "registered" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/immunization-evaluation-status"
  '("completed" "entered-in-error"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/immunization-status"
  '("completed" "entered-in-error" "not-done"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/invoice-priceComponentType"
  '("base" "deduction" "discount" "informational" "surcharge" "tax"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/invoice-status"
  '("balanced" "cancelled" "draft" "entered-in-error" "issued"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/issue-severity"
  '("error" "fatal" "information" "warning"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/issue-type"
  '("business-rule" "code-invalid" "conflict" "deleted" "duplicate" "exception" "expired" "extension" "forbidden" "incomplete" "informational" "invalid" "invariant" "lock-error" "login" "multiple-matches" "no-store" "not-found" "not-supported" "processing" "required" "security" "structure" "suppressed" "throttled" "timeout" "too-costly" "too-long" "transient" "unknown" "value"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/item-type"
  '("attachment" "boolean" "choice" "date" "dateTime" "decimal" "display" "group" "integer" "open-choice" "quantity" "question" "reference" "string" "text" "time" "url"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/link-type"
  '("refer" "replaced-by" "replaces" "seealso"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/linkage-type"
  '("alternate" "historical" "source"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/list-mode"
  '("changes" "snapshot" "working"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/list-status"
  '("current" "entered-in-error" "retired"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/location-mode"
  '("instance" "kind"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/location-status"
  '("active" "inactive" "suspended"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/map-context-type"
  '("type" "variable"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/map-group-type-mode"
  '("none" "type-and-types" "types"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/map-input-mode"
  '("source" "target"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/map-model-mode"
  '("produced" "queried" "source" "target"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/map-source-list-mode"
  '("first" "last" "not_first" "not_last" "only_one"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/map-target-list-mode"
  '("collate" "first" "last" "share"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/map-transform"
  '("append" "c" "cast" "cc" "copy" "cp" "create" "dateOp" "escape" "evaluate" "id" "pointer" "qty" "reference" "translate" "truncate" "uuid"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/measure-report-status"
  '("complete" "error" "pending"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/measure-report-type"
  '("data-collection" "individual" "subject-list" "summary"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/medication-admin-status"
  '("completed" "entered-in-error" "in-progress" "not-done" "on-hold" "stopped" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/medication-statement-status"
  '("active" "completed" "entered-in-error" "intended" "not-taken" "on-hold" "stopped" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/medication-status"
  '("active" "entered-in-error" "inactive"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/medicationdispense-status"
  '("cancelled" "completed" "declined" "entered-in-error" "in-progress" "on-hold" "preparation" "stopped" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/medicationknowledge-status"
  '("active" "entered-in-error" "inactive"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/medicationrequest-intent"
  '("filler-order" "instance-order" "option" "order" "original-order" "plan" "proposal" "reflex-order"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/medicationrequest-status"
  '("active" "cancelled" "completed" "draft" "entered-in-error" "on-hold" "stopped" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/message-significance-category"
  '("consequence" "currency" "notification"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/messageheader-response-request"
  '("always" "never" "on-error" "on-success"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/metric-calibration-state"
  '("calibrated" "calibration-required" "not-calibrated" "unspecified"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/metric-calibration-type"
  '("gain" "offset" "two-point" "unspecified"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/metric-category"
  '("calculation" "measurement" "setting" "unspecified"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/metric-color"
  '("black" "blue" "cyan" "green" "magenta" "red" "white" "yellow"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/metric-operational-status"
  '("entered-in-error" "off" "on" "standby"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/name-use"
  '("anonymous" "maiden" "nickname" "official" "old" "temp" "usual"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/namingsystem-identifier-type"
  '("oid" "other" "uri" "uuid"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/namingsystem-type"
  '("codesystem" "identifier" "root"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/narrative-status"
  '("additional" "empty" "extensions" "generated"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/network-type"
  '("1" "2" "3" "4" "5"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/note-type"
  '("display" "print" "printoper"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/observation-range-category"
  '("absolute" "critical" "reference"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/observation-status"
  '("amended" "cancelled" "corrected" "entered-in-error" "final" "preliminary" "registered" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/operation-kind"
  '("operation" "query"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/operation-parameter-use"
  '("in" "out"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/orientation-type"
  '("antisense" "sense"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/participantrequired"
  '("information-only" "optional" "required"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/participationstatus"
  '("accepted" "declined" "needs-action" "tentative"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/permitted-data-type"
  '("CodeableConcept" "Period" "Quantity" "Range" "Ratio" "SampledData" "boolean" "dateTime" "integer" "string" "time"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/product-category"
  '("biologicalAgent" "cells" "fluid" "organ" "tissue"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/product-status"
  '("available" "unavailable"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/product-storage-scale"
  '("celsius" "farenheit" "kelvin"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/property-representation"
  '("cdaText" "typeAttr" "xhtml" "xmlAttr" "xmlText"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/provenance-entity-role"
  '("derivation" "quotation" "removal" "revision" "source"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/publication-status"
  '("active" "draft" "retired" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/quality-type"
  '("indel" "snp" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/quantity-comparator"
  '("<" "<=" ">" ">="))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/questionnaire-answers-status"
  '("amended" "completed" "entered-in-error" "in-progress" "stopped"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/questionnaire-enable-behavior"
  '("all" "any"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/questionnaire-enable-operator"
  '("!=" "<" "<=" "=" ">" ">=" "exists"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/reaction-event-severity"
  '("mild" "moderate" "severe"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/reference-handling-policy"
  '("enforced" "literal" "local" "logical" "resolves"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/reference-version-rules"
  '("either" "independent" "specific"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/related-artifact-type"
  '("citation" "composed-of" "depends-on" "derived-from" "documentation" "justification" "predecessor" "successor"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/relation-type"
  '("is-replaced-by" "triggers"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/remittance-outcome"
  '("complete" "error" "partial" "queued"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/report-action-result-codes"
  '("error" "fail" "pass" "skip" "warning"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/report-participant-type"
  '("client" "server" "test-engine"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/report-result-codes"
  '("fail" "pass" "pending"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/report-status-codes"
  '("completed" "entered-in-error" "in-progress" "stopped" "waiting"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/repository-type"
  '("directlink" "login" "oauth" "openapi" "other"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/request-intent"
  '("directive" "filler-order" "instance-order" "option" "order" "original-order" "plan" "proposal" "reflex-order"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/request-priority"
  '("asap" "routine" "stat" "urgent"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/request-resource-types"
  '("Appointment" "AppointmentResponse" "CarePlan" "Claim" "CommunicationRequest" "Contract" "DeviceRequest" "EnrollmentRequest" "ImmunizationRecommendation" "MedicationRequest" "NutritionOrder" "ServiceRequest" "SupplyRequest" "Task" "VisionPrescription"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/request-status"
  '("active" "completed" "draft" "entered-in-error" "on-hold" "revoked" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/research-element-type"
  '("exposure" "outcome" "population"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/research-study-status"
  '("active" "administratively-completed" "approved" "closed-to-accrual" "closed-to-accrual-and-intervention" "completed" "disapproved" "in-review" "temporarily-closed-to-accrual" "temporarily-closed-to-accrual-and-intervention" "withdrawn"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/research-subject-status"
  '("candidate" "eligible" "follow-up" "ineligible" "not-registered" "off-study" "on-study" "on-study-intervention" "on-study-observation" "pending-on-study" "potential-candidate" "screening" "withdrawn"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/resource-aggregation-mode"
  '("bundled" "contained" "referenced"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/resource-slicing-rules"
  '("closed" "open" "openAtEnd"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/resource-types"
  '("Account" "ActivityDefinition" "AdverseEvent" "AllergyIntolerance" "Appointment" "AppointmentResponse" "AuditEvent" "Basic" "Binary" "BiologicallyDerivedProduct" "BodyStructure" "Bundle" "CapabilityStatement" "CarePlan" "CareTeam" "CatalogEntry" "ChargeItem" "ChargeItemDefinition" "Claim" "ClaimResponse" "ClinicalImpression" "CodeSystem" "Communication" "CommunicationRequest" "CompartmentDefinition" "Composition" "ConceptMap" "Condition" "Consent" "Contract" "Coverage" "CoverageEligibilityRequest" "CoverageEligibilityResponse" "DetectedIssue" "Device" "DeviceDefinition" "DeviceMetric" "DeviceRequest" "DeviceUseStatement" "DiagnosticReport" "DocumentManifest" "DocumentReference" "DomainResource" "EffectEvidenceSynthesis" "Encounter" "Endpoint" "EnrollmentRequest" "EnrollmentResponse" "EpisodeOfCare" "EventDefinition" "Evidence" "EvidenceVariable" "ExampleScenario" "ExplanationOfBenefit" "FamilyMemberHistory" "Flag" "Goal" "GraphDefinition" "Group" "GuidanceResponse" "HealthcareService" "ImagingStudy" "Immunization" "ImmunizationEvaluation" "ImmunizationRecommendation" "ImplementationGuide" "InsurancePlan" "Invoice" "Library" "Linkage" "List" "Location" "Measure" "MeasureReport" "Media" "Medication" "MedicationAdministration" "MedicationDispense" "MedicationKnowledge" "MedicationRequest" "MedicationStatement" "MedicinalProduct" "MedicinalProductAuthorization" "MedicinalProductContraindication" "MedicinalProductIndication" "MedicinalProductIngredient" "MedicinalProductInteraction" "MedicinalProductManufactured" "MedicinalProductPackaged" "MedicinalProductPharmaceutical" "MedicinalProductUndesirableEffect" "MessageDefinition" "MessageHeader" "MolecularSequence" "NamingSystem" "NutritionOrder" "Observation" "ObservationDefinition" "OperationDefinition" "OperationOutcome" "Organization" "OrganizationAffiliation" "Parameters" "Patient" "PaymentNotice" "PaymentReconciliation" "Person" "PlanDefinition" "Practitioner" "PractitionerRole" "Procedure" "Provenance" "Questionnaire" "QuestionnaireResponse" "RelatedPerson" "RequestGroup" "ResearchDefinition" "ResearchElementDefinition" "ResearchStudy" "ResearchSubject" "Resource" "RiskAssessment" "RiskEvidenceSynthesis" "Schedule" "SearchParameter" "ServiceRequest" "Slot" "Specimen" "SpecimenDefinition" "StructureDefinition" "StructureMap" "Subscription" "Substance" "SubstanceNucleicAcid" "SubstancePolymer" "SubstanceProtein" "SubstanceReferenceInformation" "SubstanceSourceMaterial" "SubstanceSpecification" "SupplyDelivery" "SupplyRequest" "Task" "TerminologyCapabilities" "TestReport" "TestScript" "ValueSet" "VerificationResult" "VisionPrescription"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/response-code"
  '("fatal-error" "ok" "transient-error"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/restful-capability-mode"
  '("client" "server"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/search-comparator"
  '("ap" "eb" "eq" "ge" "gt" "le" "lt" "ne" "sa"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/search-entry-mode"
  '("include" "match" "outcome"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/search-modifier-code"
  '("above" "below" "contains" "exact" "identifier" "in" "missing" "not" "not-in" "ofType" "text" "type"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/search-param-type"
  '("composite" "date" "number" "quantity" "reference" "special" "string" "token" "uri"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/search-xpath-usage"
  '("distance" "nearby" "normal" "other" "phonetic"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/sequence-type"
  '("aa" "dna" "rna"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/slotstatus"
  '("busy" "busy-tentative" "busy-unavailable" "entered-in-error" "free"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/sort-direction"
  '("ascending" "descending"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/spdx-license"
  '("0BSD" "AAL" "ADSL" "AFL-1.1" "AFL-1.2" "AFL-2.0" "AFL-2.1" "AFL-3.0" "AGPL-1.0-only" "AGPL-1.0-or-later" "AGPL-3.0-only" "AGPL-3.0-or-later" "AMDPLPA" "AML" "AMPAS" "ANTLR-PD" "APAFML" "APL-1.0" "APSL-1.0" "APSL-1.1" "APSL-1.2" "APSL-2.0" "Abstyles" "Adobe-2006" "Adobe-Glyph" "Afmparse" "Aladdin" "Apache-1.0" "Apache-1.1" "Apache-2.0" "Artistic-1.0" "Artistic-1.0-Perl" "Artistic-1.0-cl8" "Artistic-2.0" "BSD-1-Clause" "BSD-2-Clause" "BSD-2-Clause-FreeBSD" "BSD-2-Clause-NetBSD" "BSD-2-Clause-Patent" "BSD-3-Clause" "BSD-3-Clause-Attribution" "BSD-3-Clause-Clear" "BSD-3-Clause-LBNL" "BSD-3-Clause-No-Nuclear-License" "BSD-3-Clause-No-Nuclear-License-2014" "BSD-3-Clause-No-Nuclear-Warranty" "BSD-4-Clause" "BSD-4-Clause-UC" "BSD-Protection" "BSD-Source-Code" "BSL-1.0" "Bahyph" "Barr" "Beerware" "BitTorrent-1.0" "BitTorrent-1.1" "Borceux" "CATOSL-1.1" "CC-BY-1.0" "CC-BY-2.0" "CC-BY-2.5" "CC-BY-3.0" "CC-BY-4.0" "CC-BY-NC-1.0" "CC-BY-NC-2.0" "CC-BY-NC-2.5" "CC-BY-NC-3.0" "CC-BY-NC-4.0" "CC-BY-NC-ND-1.0" "CC-BY-NC-ND-2.0" "CC-BY-NC-ND-2.5" "CC-BY-NC-ND-3.0" "CC-BY-NC-ND-4.0" "CC-BY-NC-SA-1.0" "CC-BY-NC-SA-2.0" "CC-BY-NC-SA-2.5" "CC-BY-NC-SA-3.0" "CC-BY-NC-SA-4.0" "CC-BY-ND-1.0" "CC-BY-ND-2.0" "CC-BY-ND-2.5" "CC-BY-ND-3.0" "CC-BY-ND-4.0" "CC-BY-SA-1.0" "CC-BY-SA-2.0" "CC-BY-SA-2.5" "CC-BY-SA-3.0" "CC-BY-SA-4.0" "CC0-1.0" "CDDL-1.0" "CDDL-1.1" "CDLA-Permissive-1.0" "CDLA-Sharing-1.0" "CECILL-1.0" "CECILL-1.1" "CECILL-2.0" "CECILL-2.1" "CECILL-B" "CECILL-C" "CNRI-Jython" "CNRI-Python" "CNRI-Python-GPL-Compatible" "CPAL-1.0" "CPL-1.0" "CPOL-1.02" "CUA-OPL-1.0" "Caldera" "ClArtistic" "Condor-1.1" "Crossword" "CrystalStacker" "Cube" "D-FSL-1.0" "DOC" "DSDP" "Dotseqn" "ECL-1.0" "ECL-2.0" "EFL-1.0" "EFL-2.0" "EPL-1.0" "EPL-2.0" "EUDatagrid" "EUPL-1.0" "EUPL-1.1" "EUPL-1.2" "Entessa" "ErlPL-1.1" "Eurosym" "FSFAP" "FSFUL" "FSFULLR" "FTL" "Fair" "Frameworx-1.0" "FreeImage" "GFDL-1.1-only" "GFDL-1.1-or-later" "GFDL-1.2-only" "GFDL-1.2-or-later" "GFDL-1.3-only" "GFDL-1.3-or-later" "GL2PS" "GPL-1.0-only" "GPL-1.0-or-later" "GPL-2.0-only" "GPL-2.0-or-later" "GPL-3.0-only" "GPL-3.0-or-later" "Giftware" "Glide" "Glulxe" "HPND" "HaskellReport" "IBM-pibs" "ICU" "IJG" "IPA" "IPL-1.0" "ISC" "ImageMagick" "Imlib2" "Info-ZIP" "Intel" "Intel-ACPI" "Interbase-1.0" "JSON" "JasPer-2.0" "LAL-1.2" "LAL-1.3" "LGPL-2.0-only" "LGPL-2.0-or-later" "LGPL-2.1-only" "LGPL-2.1-or-later" "LGPL-3.0-only" "LGPL-3.0-or-later" "LGPLLR" "LPL-1.0" "LPL-1.02" "LPPL-1.0" "LPPL-1.1" "LPPL-1.2" "LPPL-1.3a" "LPPL-1.3c" "Latex2e" "Leptonica" "LiLiQ-P-1.1" "LiLiQ-R-1.1" "LiLiQ-Rplus-1.1" "Libpng" "Linux-OpenIB" "MIT" "MIT-0" "MIT-CMU" "MIT-advertising" "MIT-enna" "MIT-feh" "MITNFA" "MPL-1.0" "MPL-1.1" "MPL-2.0" "MPL-2.0-no-copyleft-exception" "MS-PL" "MS-RL" "MTLL" "MakeIndex" "MirOS" "Motosoto" "Multics" "Mup" "NASA-1.3" "NBPL-1.0" "NCSA" "NGPL" "NLOD-1.0" "NLPL" "NOSL" "NPL-1.0" "NPL-1.1" "NPOSL-3.0" "NRL" "NTP" "Naumen" "Net-SNMP" "NetCDF" "Newsletr" "Nokia" "Noweb" "OCCT-PL" "OCLC-2.0" "ODbL-1.0" "OFL-1.0" "OFL-1.1" "OGTSL" "OLDAP-1.1" "OLDAP-1.2" "OLDAP-1.3" "OLDAP-1.4" "OLDAP-2.0" "OLDAP-2.0.1" "OLDAP-2.1" "OLDAP-2.2" "OLDAP-2.2.1" "OLDAP-2.2.2" "OLDAP-2.3" "OLDAP-2.4" "OLDAP-2.5" "OLDAP-2.6" "OLDAP-2.7" "OLDAP-2.8" "OML" "OPL-1.0" "OSET-PL-2.1" "OSL-1.0" "OSL-1.1" "OSL-2.0" "OSL-2.1" "OSL-3.0" "OpenSSL" "PDDL-1.0" "PHP-3.0" "PHP-3.01" "Plexus" "PostgreSQL" "Python-2.0" "QPL-1.0" "Qhull" "RHeCos-1.1" "RPL-1.1" "RPL-1.5" "RPSL-1.0" "RSA-MD" "RSCPL" "Rdisc" "Ruby" "SAX-PD" "SCEA" "SGI-B-1.0" "SGI-B-1.1" "SGI-B-2.0" "SISSL" "SISSL-1.2" "SMLNJ" "SMPPL" "SNIA" "SPL-1.0" "SWL" "Saxpath" "Sendmail" "SimPL-2.0" "Sleepycat" "Spencer-86" "Spencer-94" "Spencer-99" "SugarCRM-1.1.3" "TCL" "TCP-wrappers" "TMate" "TORQUE-1.1" "TOSL" "UPL-1.0" "Unicode-DFS-2015" "Unicode-DFS-2016" "Unicode-TOU" "Unlicense" "VOSTROM" "VSL-1.0" "Vim" "W3C" "W3C-19980720" "W3C-20150513" "WTFPL" "Watcom-1.0" "Wsuipa" "X11" "XFree86-1.1" "XSkat" "Xerox" "Xnet" "YPL-1.0" "YPL-1.1" "ZPL-1.1" "ZPL-2.0" "ZPL-2.1" "Zed" "Zend-2.0" "Zimbra-1.3" "Zimbra-1.4" "Zlib" "bzip2-1.0.5" "bzip2-1.0.6" "curl" "diffmark" "dvipdfm" "eGenix" "gSOAP-1.3b" "gnuplot" "iMatix" "libtiff" "mpich2" "not-open-source" "psfrag" "psutils" "xinetd" "xpp" "zlib-acknowledgement"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/specimen-contained-preference"
  '("alternate" "preferred"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/specimen-status"
  '("available" "entered-in-error" "unavailable" "unsatisfactory"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/strand-type"
  '("crick" "watson"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/structure-definition-kind"
  '("complex-type" "logical" "primitive-type" "resource"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/subscription-channel-type"
  '("email" "message" "rest-hook" "sms" "websocket"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/subscription-status"
  '("active" "error" "off" "requested"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/substance-status"
  '("active" "entered-in-error" "inactive"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/supplydelivery-status"
  '("abandoned" "completed" "entered-in-error" "in-progress"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/supplyrequest-status"
  '("active" "cancelled" "completed" "draft" "entered-in-error" "suspended" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/system-restful-interaction"
  '("batch" "history-system" "search-system" "transaction"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/task-intent"
  '("filler-order" "instance-order" "option" "order" "original-order" "plan" "proposal" "reflex-order" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/task-status"
  '("accepted" "cancelled" "completed" "draft" "entered-in-error" "failed" "in-progress" "on-hold" "ready" "received" "rejected" "requested"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/trigger-type"
  '("data-access-ended" "data-accessed" "data-added" "data-changed" "data-modified" "data-removed" "named-event" "periodic"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/type-derivation-rule"
  '("constraint" "specialization"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/type-restful-interaction"
  '("create" "delete" "history-instance" "history-type" "patch" "read" "search-type" "update" "vread"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/udi-entry-type"
  '("barcode" "card" "manual" "rfid" "self-reported" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/units-of-time"
  '("a" "d" "h" "min" "mo" "s" "wk"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/variable-type"
  '("continuous" "descriptive" "dichotomous"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/verificationresult-status"
  '("attested" "in-process" "req-revalid" "reval-fail" "val-fail" "validated"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/versioning-policy"
  '("no-version" "versioned" "versioned-update"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/vision-base-codes"
  '("down" "in" "out" "up"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/vision-eye-codes"
  '("left" "right"))
(register-binding-expansion! "http://terminology.hl7.org/ValueSet/v3-ConfidentialityClassification"
  '("L" "M" "N" "R" "U" "V"))
