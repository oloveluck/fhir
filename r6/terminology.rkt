#lang racket/base
;;; GENERATED — DO NOT EDIT (verified by raco fhir check).
;; REQUIRED-bound ValueSets expanded OFFLINE from this package's own CodeSystems. Required
;; both normally and for-syntax by the tower index, so form macros enforce these at compile
;; time and runtime consumers can read the same catalogue. Absent urls fail open.
(require fhir/model/binding)
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/FHIR-version"
  '("0.0" "0.0.80" "0.0.81" "0.0.82" "0.01" "0.05" "0.06" "0.11" "0.4" "0.4.0" "0.5" "0.5.0" "1.0" "1.0.0" "1.0.1" "1.0.2" "1.1" "1.1.0" "1.4" "1.4.0" "1.6" "1.6.0" "1.8" "1.8.0" "3.0" "3.0.0" "3.0.1" "3.0.2" "3.3" "3.3.0" "3.5" "3.5.0" "4.0" "4.0.0" "4.0.1" "4.1" "4.1.0" "4.2" "4.2.0" "4.3" "4.3.0" "4.3.0-cibuild" "4.3.0-snapshot1" "4.4" "4.4.0" "4.5" "4.5.0" "4.6" "4.6.0" "5.0" "5.0.0" "5.0.0-ballot" "5.0.0-cibuild" "5.0.0-draft-final" "5.0.0-snapshot1" "5.0.0-snapshot2" "5.0.0-snapshot3" "6.0" "6.0.0" "6.0.0-ballot1" "6.0.0-ballot2" "6.0.0-ballot3" "6.0.0-ballot4"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/account-status"
  '("active" "entered-in-error" "inactive" "on-hold" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/action-applicability-behavior"
  '("all" "any"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/action-cardinality-behavior"
  '("multiple" "single"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/action-condition-kind"
  '("applicability" "start" "stop"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/action-grouping-behavior"
  '("logical-group" "sentence-group" "visual-group"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/action-participant-type"
  '("careteam" "device" "group" "healthcareservice" "location" "organization" "patient" "practitioner" "practitionerrole" "relatedperson"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/action-precheck-behavior"
  '("no" "yes"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/action-relationship-type"
  '("after" "after-end" "after-start" "before" "before-end" "before-start" "concurrent" "concurrent-with-end" "concurrent-with-start"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/action-required-behavior"
  '("could" "must" "must-unless-documented"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/action-selection-behavior"
  '("all" "all-or-none" "any" "at-most-one" "exactly-one" "one-or-more"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/actordefinition-actor-type"
  '("collective" "other" "person" "system"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/additional-binding-purpose"
  '("best-practice" "candidate" "component" "current" "current-extensible" "extensible" "maximum" "minimum" "open" "preferred" "required" "starter" "ui"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/address-type"
  '("both" "physical" "postal"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/address-use"
  '("billing" "home" "old" "temp" "work"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/administrative-gender"
  '("female" "male" "other" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/adverse-event-actuality"
  '("actual" "potential" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/adverse-event-status"
  '("completed" "entered-in-error" "in-progress" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/allergy-intolerance-category"
  '("biologic" "environment" "food" "medication"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/allergy-intolerance-criticality"
  '("high" "low" "unable-to-assess"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/appointmentresponse-status"
  '("accepted" "declined" "entered-in-error" "needs-action" "tentative"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/appointmentstatus"
  '("arrived" "booked" "cancelled" "checked-in" "entered-in-error" "fulfilled" "noshow" "pending" "proposed" "waitlist"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/artifactassessment-disposition"
  '("not-persuasive" "not-persuasive-with-modification" "persuasive" "persuasive-with-modification" "unresolved"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/artifactassessment-workflow-status"
  '("applied" "deferred" "duplicate" "entered-in-error" "published" "resolved-change-required" "resolved-no-change" "submitted" "triaged" "waiting-for-input"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/audit-event-action"
  '("C" "D" "E" "R" "U"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/audit-event-severity"
  '("alert" "critical" "debug" "emergency" "error" "informational" "notice" "warning"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/binding-strength"
  '("descriptive" "example" "extensible" "preferred" "required"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/bundle-type"
  '("batch" "batch-response" "collection" "document" "history" "message" "searchset" "subscription-notification" "transaction" "transaction-response"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/capability-statement-kind"
  '("capability" "instance" "requirements"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/care-plan-intent"
  '("directive" "option" "order" "plan" "proposal"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/care-team-status"
  '("active" "entered-in-error" "inactive" "proposed" "suspended"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/claim-outcome"
  '("complete" "error" "partial" "queued"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/claim-use"
  '("claim" "preauthorization" "predetermination"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/clinical-use-definition-type"
  '("contraindication" "indication" "interaction" "undesirable-effect" "warning"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/code-search-support"
  '("in-compose" "in-compose-or-expansion" "in-expansion"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/codesystem-content-mode"
  '("complete" "example" "fragment" "not-present" "supplement"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/codesystem-hierarchy-meaning"
  '("classified-with" "grouped-by" "is-a" "part-of"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/comparison-operation"
  '("ap" "eb" "eq" "ge" "gt" "in" "le" "lt" "ne" "nin" "sa"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/compartment-type"
  '("Device" "Encounter" "EpisodeOfCare" "Patient" "Practitioner" "RelatedPerson"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/composition-status"
  '("amended" "appended" "cancelled" "corrected" "deprecated" "entered-in-error" "final" "partial" "preliminary" "registered" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/concept-map-relationship"
  '("equivalent" "not-related-to" "related-to" "source-is-broader-than-target" "source-is-narrower-than-target"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/concept-property-type"
  '("Coding" "boolean" "code" "dateTime" "decimal" "integer" "string"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/conceptmap-attribute-type"
  '("Coding" "Quantity" "boolean" "code" "string"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/conceptmap-property-type"
  '("Coding" "boolean" "code" "dateTime" "decimal" "integer" "string"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/conceptmap-unmapped-mode"
  '("fixed" "other-map" "use-source-code"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/conditional-delete-status"
  '("multiple" "not-supported" "single"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/conditional-read-status"
  '("full-support" "modified-since" "not-match" "not-supported"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/conformance-expectation"
  '("MAY" "SHALL" "SHALL-NOT" "SHOULD" "SHOULD-NOT"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/consent-data-meaning"
  '("authoredby" "dependents" "instance" "related"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/consent-provision-type"
  '("deny" "permit"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/consent-state-codes"
  '("active" "draft" "entered-in-error" "inactive" "not-done" "unknown"))
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
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/coverage-kind"
  '("insurance" "other" "self-pay"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/days-of-week"
  '("fri" "mon" "sat" "sun" "thu" "tue" "wed"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/detectedissue-status"
  '("entered-in-error" "final" "mitigated" "preliminary" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/device-correctiveactionscope"
  '("lot-numbers" "model" "serial-numbers"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/device-status"
  '("active" "entered-in-error" "inactive" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/devicealert-status"
  '("completed" "entered-in-error" "in-progress" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/deviceassociation-status"
  '("active" "entered-in-error" "inactive" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/diagnostic-report-status"
  '("amended" "appended" "cancelled" "corrected" "entered-in-error" "final" "modified" "partial" "preliminary" "registered" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/discriminator-type"
  '("exists" "pattern" "position" "profile" "type" "value"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/document-mode"
  '("consumer" "producer"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/document-reference-status"
  '("current" "entered-in-error" "superseded"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/dose-limit-scope"
  '("administration" "dosage" "lifetime" "period"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/eligibility-outcome"
  '("complete" "error" "partial" "queued"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/eligibilityrequest-purpose"
  '("auth-requirements" "benefits" "discovery" "validation"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/eligibilityresponse-purpose"
  '("auth-requirements" "benefits" "discovery" "validation"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/encounter-location-status"
  '("active" "completed" "planned" "reserved"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/encounter-status"
  '("cancelled" "completed" "discharged" "discontinued" "entered-in-error" "in-progress" "on-hold" "planned" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/endpoint-status"
  '("active" "entered-in-error" "error" "limited" "off" "suspended"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/enrollment-outcome"
  '("complete" "error" "partial" "queued"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/episode-of-care-status"
  '("active" "cancelled" "entered-in-error" "finished" "onhold" "planned" "waitlist"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/event-capability-mode"
  '("receiver" "sender"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/event-status"
  '("completed" "entered-in-error" "in-progress" "not-done" "on-hold" "preparation" "stopped" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/event-timing"
  '("AC" "ACD" "ACM" "ACV" "AFT" "AFT.early" "AFT.late" "C" "CD" "CM" "CV" "EVE" "EVE.early" "EVE.late" "HS" "IMD" "MORN" "MORN.early" "MORN.late" "NIGHT" "NOON" "PC" "PCD" "PCM" "PCV" "PHS" "WAKE"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/explanationofbenefit-status"
  '("active" "cancelled" "draft" "entered-in-error"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/extension-context-type"
  '("element" "extension" "fhirpath"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/fhir-types"
  '("Account" "ActivityDefinition" "ActorDefinition" "Address" "AdministrableProductDefinition" "AdverseEvent" "Age" "AllergyIntolerance" "Annotation" "Appointment" "AppointmentResponse" "ArtifactAssessment" "Attachment" "AuditEvent" "Availability" "BackboneElement" "BackboneType" "Base" "Basic" "Binary" "BiologicallyDerivedProduct" "BodyStructure" "Bundle" "CanonicalResource" "CapabilityStatement" "CarePlan" "CareTeam" "Claim" "ClaimResponse" "ClinicalUseDefinition" "CodeSystem" "CodeableConcept" "CodeableReference" "Coding" "Communication" "CommunicationRequest" "CompartmentDefinition" "Composition" "ConceptMap" "Condition" "Consent" "ContactDetail" "ContactPoint" "Contract" "Count" "Coverage" "CoverageEligibilityRequest" "CoverageEligibilityResponse" "DataRequirement" "DataType" "DetectedIssue" "Device" "DeviceAlert" "DeviceAssociation" "DeviceDefinition" "DeviceMetric" "DeviceRequest" "DiagnosticReport" "Distance" "DocumentReference" "DomainResource" "Dosage" "DosageCondition" "DosageDetails" "DosageSafety" "Duration" "Element" "ElementDefinition" "Encounter" "Endpoint" "EnrollmentRequest" "EnrollmentResponse" "EpisodeOfCare" "EventDefinition" "Evidence" "EvidenceVariable" "ExampleScenario" "ExplanationOfBenefit" "Expression" "ExtendedContactDetail" "Extension" "FamilyMemberHistory" "Flag" "Goal" "Group" "GuidanceResponse" "HealthcareService" "HumanName" "Identifier" "ImagingSelection" "ImagingStudy" "Immunization" "ImplementationGuide" "Ingredient" "InsurancePlan" "InsuranceProduct" "Invoice" "Library" "List" "Location" "ManufacturedItemDefinition" "MarketingStatus" "Measure" "MeasureReport" "Medication" "MedicationAdministration" "MedicationDispense" "MedicationRequest" "MedicationStatement" "MedicinalProductDefinition" "MessageDefinition" "MessageHeader" "Meta" "MetadataResource" "MonetaryComponent" "Money" "NamingSystem" "Narrative" "NutritionIntake" "NutritionOrder" "NutritionProduct" "Observation" "ObservationDefinition" "OperationDefinition" "OperationOutcome" "Organization" "OrganizationAffiliation" "PackagedProductDefinition" "ParameterDefinition" "Parameters" "Patient" "PaymentNotice" "PaymentReconciliation" "Period" "Person" "PlanDefinition" "Practitioner" "PractitionerRole" "PrimitiveType" "Procedure" "ProductShelfLife" "Provenance" "Quantity" "Questionnaire" "QuestionnaireResponse" "Range" "Ratio" "RatioRange" "Reference" "RegulatedAuthorization" "RelatedArtifact" "RelatedPerson" "RelativeTime" "RequestOrchestration" "Requirements" "ResearchStudy" "ResearchSubject" "Resource" "RiskAssessment" "SampledData" "Schedule" "SearchParameter" "ServiceRequest" "Signature" "Slot" "Specimen" "SpecimenDefinition" "StructureDefinition" "StructureMap" "Subscription" "SubscriptionStatus" "SubscriptionTopic" "Substance" "SubstanceDefinition" "Task" "TerminologyCapabilities" "Timing" "TriggerDefinition" "UsageContext" "ValueSet" "VirtualServiceDetail" "VisionPrescription" "base64Binary" "boolean" "canonical" "code" "date" "dateTime" "decimal" "id" "instant" "integer" "integer64" "markdown" "oid" "positiveInt" "string" "time" "unsignedInt" "uri" "url" "uuid" "xhtml"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/filter-operator"
  '("=" "child-of" "descendent-leaf" "descendent-of" "exists" "generalizes" "in" "is-a" "is-not-a" "not-in" "regex"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/flag-status"
  '("active" "entered-in-error" "inactive"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/fm-status"
  '("active" "cancelled" "draft" "entered-in-error"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/global-langpack-support"
  '("explicit" "implicit" "not-supported"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/goal-accept-status"
  '("agree" "disagree" "pending"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/goal-status"
  '("accepted" "active" "cancelled" "completed" "entered-in-error" "on-hold" "planned" "proposed" "rejected" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/group-characteristic-combination"
  '("all-of" "any-of" "at-least" "at-most" "except-subset"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/group-membership-basis"
  '("conceptual" "definitional" "enumerated"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/group-type"
  '("animal" "biologicallyDerivedProduct" "careteam" "device" "healthcareservice" "location" "medication" "medicinalproductdefinition" "nutritionProduct" "organization" "person" "practitioner" "relatedperson" "specimen" "substance" "substancedefinition"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/guidance-response-status"
  '("data-requested" "data-required" "entered-in-error" "failure" "in-progress" "success"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/guide-page-generation"
  '("generated" "html" "markdown" "xml"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/history-status"
  '("completed" "entered-in-error" "health-unknown" "partial"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/http-verb"
  '("DELETE" "GET" "HEAD" "PATCH" "POST" "PUT"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/iana-link-relations"
  '("P3Pv1" "about" "acl" "alternate" "amphtml" "appendix" "apple-touch-icon" "apple-touch-startup-image" "archives" "author" "blocked-by" "bookmark" "canonical" "chapter" "cite-as" "collection" "contents" "convertedFrom" "copyright" "create-form" "current" "describedby" "describes" "disclosure" "dns-prefetch" "duplicate" "edit" "edit-form" "edit-media" "enclosure" "external" "first" "glossary" "help" "hosts" "hub" "icon" "index" "intervalAfter" "intervalBefore" "intervalContains" "intervalDisjoint" "intervalDuring" "intervalEquals" "intervalFinishedBy" "intervalFinishes" "intervalIn" "intervalMeets" "intervalMetBy" "intervalOverlappedBy" "intervalOverlaps" "intervalStartedBy" "intervalStarts" "item" "last" "latest-version" "license" "linkset" "lrdd" "manifest" "mask-icon" "media-feed" "memento" "micropub" "modulepreload" "monitor" "monitor-group" "next" "next-archive" "nofollow" "noopener" "noreferrer" "opener" "openid2.local_id" "openid2.provider" "original" "payment" "pingback" "preconnect" "predecessor-version" "prefetch" "preload" "prerender" "prev" "prev-archive" "preview" "previous" "privacy-policy" "profile" "publication" "related" "replies" "restconf" "ruleinput" "search" "section" "self" "service" "service-desc" "service-doc" "service-meta" "sponsored" "start" "status" "stylesheet" "subsection" "successor-version" "sunset" "tag" "terms-of-service" "timegate" "timemap" "type" "ugc" "up" "version-history" "via" "webmention" "working-copy" "working-copy-of"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/identifier-use"
  '("official" "old" "secondary" "temp" "usual"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/identity-assuranceLevel"
  '("level1" "level2" "level3" "level4"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/imagingselection-2dgraphictype"
  '("circle" "ellipse" "multipoint" "point" "polyline" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/imagingselection-3dgraphictype"
  '("ellipse" "ellipsoid" "multipoint" "point" "polygon" "polyline" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/imagingselection-status"
  '("available" "entered-in-error" "inactive" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/imagingstudy-status"
  '("available" "cancelled" "entered-in-error" "inactive" "registered" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/immunization-status"
  '("completed" "entered-in-error" "not-done"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/ingredient-manufacturer-role"
  '("actual" "allowed" "possible"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/interaction-trigger"
  '("create" "delete" "update"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/invoice-status"
  '("balanced" "cancelled" "draft" "entered-in-error" "issued"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/issue-severity"
  '("error" "fatal" "information" "success" "warning"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/issue-type"
  '("business-rule" "code-invalid" "conflict" "deleted" "duplicate" "exception" "expired" "extension" "forbidden" "incomplete" "informational" "invalid" "invariant" "limited-filter" "lock-error" "login" "multiple-matches" "no-store" "not-found" "not-supported" "processing" "required" "security" "structure" "success" "suppressed" "throttled" "timeout" "too-costly" "too-long" "transient" "unknown" "value"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/link-type"
  '("refer" "replaced-by" "replaces" "seealso"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/list-mode"
  '("changes" "snapshot" "working"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/list-status"
  '("current" "entered-in-error" "retired"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/location-mode"
  '("instance" "kind"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/location-status"
  '("active" "inactive" "suspended"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/map-group-type-mode"
  '("type-and-types" "types"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/map-input-mode"
  '("source" "target"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/map-model-mode"
  '("produced" "queried" "source" "target"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/map-source-list-mode"
  '("first" "last" "not_first" "not_last" "only_one"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/map-target-list-mode"
  '("first" "last" "share" "single"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/map-transform"
  '("append" "c" "cast" "cc" "copy" "cp" "create" "dateOp" "escape" "evaluate" "id" "pointer" "qty" "reference" "translate" "truncate" "uuid"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/measure-report-status"
  '("complete" "error" "pending"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/measure-report-type"
  '("data-exchange" "individual" "other" "subject-list" "summary"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/medication-admin-status"
  '("completed" "entered-in-error" "in-progress" "not-done" "on-hold" "stopped" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/medication-statement-status"
  '("draft" "entered-in-error" "recorded"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/medication-status"
  '("active" "entered-in-error" "inactive"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/medicationdispense-status"
  '("cancelled" "completed" "declined" "entered-in-error" "in-progress" "on-hold" "preparation" "unfulfilled" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/medicationrequest-intent"
  '("filler-order" "instance-order" "option" "order" "original-order" "plan" "proposal" "reflex-order"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/medicationrequest-status"
  '("active" "cancelled" "completed" "draft" "ended" "entered-in-error" "on-hold" "stopped" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/message-significance-category"
  '("consequence" "currency" "notification"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/messageheader-response-request"
  '("always" "never" "on-error" "on-success"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/metric-operational-status"
  '("off" "on" "standby" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/metric-status"
  '("active" "entered-in-error" "inactive" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/name-use"
  '("anonymous" "maiden" "nickname" "official" "old" "temp" "usual"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/namingsystem-identifier-type"
  '("iri-stem" "oid" "other" "uri" "uuid" "v2csmnemonic"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/namingsystem-type"
  '("codesystem" "identifier" "root"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/narrative-status"
  '("additional" "empty" "extensions" "generated"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/note-type"
  '("display" "print" "printoper"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/nutritionproduct-status"
  '("active" "entered-in-error" "inactive"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/observation-range-category"
  '("absolute" "critical" "reference"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/observation-status"
  '("amended" "appended" "cancelled" "cannot-be-obtained" "corrected" "entered-in-error" "final" "preliminary" "registered" "specimen-in-process" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/observation-triggeredbytype"
  '("re-run" "reflex" "repeat"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/operation-kind"
  '("operation" "query"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/operation-parameter-scope"
  '("instance" "system" "type"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/operation-parameter-use"
  '("in" "out"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/participationstatus"
  '("accepted" "declined" "needs-action" "tentative"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/patchmimetypes"
  '("application/fhir+json" "application/fhir+turtle" "application/fhir+xml" "application/json-patch+json" "application/xml-patch+xml"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/payment-outcome"
  '("complete" "error" "partial" "queued"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/permitted-data-type"
  '("CodeableConcept" "Period" "Quantity" "Range" "Ratio" "SampledData" "boolean" "dateTime" "integer" "string" "time"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/price-component-type"
  '("base" "discount" "informational" "surcharge" "tax"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/property-representation"
  '("cdaText" "typeAttr" "xhtml" "xmlAttr" "xmlText"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/provenance-entity-role"
  '("instantiates" "other" "quotation" "removal" "revision" "source"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/publication-status"
  '("active" "draft" "retired" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/quantity-comparator"
  '("<" "<=" ">" ">=" "ad"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/questionnaire-answer-constraint"
  '("optionsOnly" "optionsOrString" "optionsOrType"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/questionnaire-answers-status"
  '("amended" "completed" "entered-in-error" "in-progress" "stopped"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/questionnaire-disabled-display"
  '("hidden" "protected"))
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
  '("citation" "composed-of" "depends-on" "derived-from" "documentation" "justification" "part-of" "predecessor" "successor"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/request-intent"
  '("directive" "filler-order" "instance-order" "offer-response" "option" "order" "original-order" "plan" "proposal" "reflex-order" "solicit-offer"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/request-priority"
  '("asap" "routine" "stat" "urgent"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/request-resource-types"
  '("Appointment" "CarePlan" "Claim" "CommunicationRequest" "CoverageEligibilityRequest" "DeviceRequest" "EnrollmentRequest" "MedicationRequest" "NutritionOrder" "RequestOrchestration" "ServiceRequest" "Task" "VisionPrescription"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/request-status"
  '("active" "completed" "draft" "ended" "entered-in-error" "on-hold" "revoked" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/resource-aggregation-mode"
  '("bundled" "contained" "referenced"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/resource-slicing-rules"
  '("closed" "open" "openAtEnd"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/resource-types"
  '("Account" "ActivityDefinition" "ActorDefinition" "AdministrableProductDefinition" "AdverseEvent" "AllergyIntolerance" "Appointment" "AppointmentResponse" "ArtifactAssessment" "AuditEvent" "Basic" "Binary" "BiologicallyDerivedProduct" "BodyStructure" "Bundle" "CapabilityStatement" "CarePlan" "CareTeam" "Claim" "ClaimResponse" "ClinicalUseDefinition" "CodeSystem" "Communication" "CommunicationRequest" "CompartmentDefinition" "Composition" "ConceptMap" "Condition" "Consent" "Contract" "Coverage" "CoverageEligibilityRequest" "CoverageEligibilityResponse" "DetectedIssue" "Device" "DeviceAlert" "DeviceAssociation" "DeviceDefinition" "DeviceMetric" "DeviceRequest" "DiagnosticReport" "DocumentReference" "Encounter" "Endpoint" "EnrollmentRequest" "EnrollmentResponse" "EpisodeOfCare" "EventDefinition" "Evidence" "EvidenceVariable" "ExampleScenario" "ExplanationOfBenefit" "FamilyMemberHistory" "Flag" "Goal" "Group" "GuidanceResponse" "HealthcareService" "ImagingSelection" "ImagingStudy" "Immunization" "ImplementationGuide" "Ingredient" "InsurancePlan" "InsuranceProduct" "Invoice" "Library" "List" "Location" "ManufacturedItemDefinition" "Measure" "MeasureReport" "Medication" "MedicationAdministration" "MedicationDispense" "MedicationRequest" "MedicationStatement" "MedicinalProductDefinition" "MessageDefinition" "MessageHeader" "NamingSystem" "NutritionIntake" "NutritionOrder" "NutritionProduct" "Observation" "ObservationDefinition" "OperationDefinition" "OperationOutcome" "Organization" "OrganizationAffiliation" "PackagedProductDefinition" "Parameters" "Patient" "PaymentNotice" "PaymentReconciliation" "Person" "PlanDefinition" "Practitioner" "PractitionerRole" "Procedure" "Provenance" "Questionnaire" "QuestionnaireResponse" "RegulatedAuthorization" "RelatedPerson" "RequestOrchestration" "Requirements" "ResearchStudy" "ResearchSubject" "RiskAssessment" "Schedule" "SearchParameter" "ServiceRequest" "Slot" "Specimen" "SpecimenDefinition" "StructureDefinition" "StructureMap" "Subscription" "SubscriptionStatus" "SubscriptionTopic" "Substance" "SubstanceDefinition" "Task" "TerminologyCapabilities" "ValueSet" "VisionPrescription"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/response-code"
  '("fatal-error" "ok" "transient-error"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/restful-capability-mode"
  '("client" "server"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/search-comparator"
  '("ap" "eb" "eq" "ge" "gt" "le" "lt" "ne" "sa"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/search-entry-mode"
  '("include" "match" "outcome"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/search-modifier-code"
  '("above" "below" "code-text" "contains" "exact" "identifier" "in" "iterate" "missing" "not" "not-in" "of-type" "text" "text-advanced" "type"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/search-param-type"
  '("composite" "date" "number" "quantity" "reference" "resource" "special" "string" "token" "uri"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/search-processingmode"
  '("normal" "other" "phonetic"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/slotstatus"
  '("busy" "busy-tentative" "busy-unavailable" "entered-in-error" "free"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/sort-direction"
  '("ascending" "descending"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/spdx-license"
  '("0BSD" "AAL" "ADSL" "AFL-1.1" "AFL-1.2" "AFL-2.0" "AFL-2.1" "AFL-3.0" "AGPL-1.0-only" "AGPL-1.0-or-later" "AGPL-3.0-only" "AGPL-3.0-or-later" "AMDPLPA" "AML" "AMPAS" "ANTLR-PD" "APAFML" "APL-1.0" "APSL-1.0" "APSL-1.1" "APSL-1.2" "APSL-2.0" "Abstyles" "Adobe-2006" "Adobe-Glyph" "Afmparse" "Aladdin" "Apache-1.0" "Apache-1.1" "Apache-2.0" "Artistic-1.0" "Artistic-1.0-Perl" "Artistic-1.0-cl8" "Artistic-2.0" "BSD-1-Clause" "BSD-2-Clause" "BSD-2-Clause-FreeBSD" "BSD-2-Clause-NetBSD" "BSD-2-Clause-Patent" "BSD-3-Clause" "BSD-3-Clause-Attribution" "BSD-3-Clause-Clear" "BSD-3-Clause-LBNL" "BSD-3-Clause-No-Nuclear-License" "BSD-3-Clause-No-Nuclear-License-2014" "BSD-3-Clause-No-Nuclear-Warranty" "BSD-4-Clause" "BSD-4-Clause-UC" "BSD-Protection" "BSD-Source-Code" "BSL-1.0" "Bahyph" "Barr" "Beerware" "BitTorrent-1.0" "BitTorrent-1.1" "Borceux" "CATOSL-1.1" "CC-BY-1.0" "CC-BY-2.0" "CC-BY-2.5" "CC-BY-3.0" "CC-BY-4.0" "CC-BY-NC-1.0" "CC-BY-NC-2.0" "CC-BY-NC-2.5" "CC-BY-NC-3.0" "CC-BY-NC-4.0" "CC-BY-NC-ND-1.0" "CC-BY-NC-ND-2.0" "CC-BY-NC-ND-2.5" "CC-BY-NC-ND-3.0" "CC-BY-NC-ND-4.0" "CC-BY-NC-SA-1.0" "CC-BY-NC-SA-2.0" "CC-BY-NC-SA-2.5" "CC-BY-NC-SA-3.0" "CC-BY-NC-SA-4.0" "CC-BY-ND-1.0" "CC-BY-ND-2.0" "CC-BY-ND-2.5" "CC-BY-ND-3.0" "CC-BY-ND-4.0" "CC-BY-SA-1.0" "CC-BY-SA-2.0" "CC-BY-SA-2.5" "CC-BY-SA-3.0" "CC-BY-SA-4.0" "CC0-1.0" "CDDL-1.0" "CDDL-1.1" "CDLA-Permissive-1.0" "CDLA-Sharing-1.0" "CECILL-1.0" "CECILL-1.1" "CECILL-2.0" "CECILL-2.1" "CECILL-B" "CECILL-C" "CNRI-Jython" "CNRI-Python" "CNRI-Python-GPL-Compatible" "CPAL-1.0" "CPL-1.0" "CPOL-1.02" "CUA-OPL-1.0" "Caldera" "ClArtistic" "Condor-1.1" "Crossword" "CrystalStacker" "Cube" "D-FSL-1.0" "DOC" "DSDP" "Dotseqn" "ECL-1.0" "ECL-2.0" "EFL-1.0" "EFL-2.0" "EPL-1.0" "EPL-2.0" "EUDatagrid" "EUPL-1.0" "EUPL-1.1" "EUPL-1.2" "Entessa" "ErlPL-1.1" "Eurosym" "FSFAP" "FSFUL" "FSFULLR" "FTL" "Fair" "Frameworx-1.0" "FreeImage" "GFDL-1.1-only" "GFDL-1.1-or-later" "GFDL-1.2-only" "GFDL-1.2-or-later" "GFDL-1.3-only" "GFDL-1.3-or-later" "GL2PS" "GPL-1.0-only" "GPL-1.0-or-later" "GPL-2.0-only" "GPL-2.0-or-later" "GPL-3.0-only" "GPL-3.0-or-later" "Giftware" "Glide" "Glulxe" "HPND" "HaskellReport" "IBM-pibs" "ICU" "IJG" "IPA" "IPL-1.0" "ISC" "ImageMagick" "Imlib2" "Info-ZIP" "Intel" "Intel-ACPI" "Interbase-1.0" "JSON" "JasPer-2.0" "LAL-1.2" "LAL-1.3" "LGPL-2.0-only" "LGPL-2.0-or-later" "LGPL-2.1-only" "LGPL-2.1-or-later" "LGPL-3.0-only" "LGPL-3.0-or-later" "LGPLLR" "LPL-1.0" "LPL-1.02" "LPPL-1.0" "LPPL-1.1" "LPPL-1.2" "LPPL-1.3a" "LPPL-1.3c" "Latex2e" "Leptonica" "LiLiQ-P-1.1" "LiLiQ-R-1.1" "LiLiQ-Rplus-1.1" "Libpng" "Linux-OpenIB" "MIT" "MIT-0" "MIT-CMU" "MIT-advertising" "MIT-enna" "MIT-feh" "MITNFA" "MPL-1.0" "MPL-1.1" "MPL-2.0" "MPL-2.0-no-copyleft-exception" "MS-PL" "MS-RL" "MTLL" "MakeIndex" "MirOS" "Motosoto" "Multics" "Mup" "NASA-1.3" "NBPL-1.0" "NCSA" "NGPL" "NLOD-1.0" "NLPL" "NOSL" "NPL-1.0" "NPL-1.1" "NPOSL-3.0" "NRL" "NTP" "Naumen" "Net-SNMP" "NetCDF" "Newsletr" "Nokia" "Noweb" "OCCT-PL" "OCLC-2.0" "ODbL-1.0" "OFL-1.0" "OFL-1.1" "OGTSL" "OLDAP-1.1" "OLDAP-1.2" "OLDAP-1.3" "OLDAP-1.4" "OLDAP-2.0" "OLDAP-2.0.1" "OLDAP-2.1" "OLDAP-2.2" "OLDAP-2.2.1" "OLDAP-2.2.2" "OLDAP-2.3" "OLDAP-2.4" "OLDAP-2.5" "OLDAP-2.6" "OLDAP-2.7" "OLDAP-2.8" "OML" "OPL-1.0" "OSET-PL-2.1" "OSL-1.0" "OSL-1.1" "OSL-2.0" "OSL-2.1" "OSL-3.0" "OpenSSL" "PDDL-1.0" "PHP-3.0" "PHP-3.01" "Plexus" "PostgreSQL" "Python-2.0" "QPL-1.0" "Qhull" "RHeCos-1.1" "RPL-1.1" "RPL-1.5" "RPSL-1.0" "RSA-MD" "RSCPL" "Rdisc" "Ruby" "SAX-PD" "SCEA" "SGI-B-1.0" "SGI-B-1.1" "SGI-B-2.0" "SISSL" "SISSL-1.2" "SMLNJ" "SMPPL" "SNIA" "SPL-1.0" "SWL" "Saxpath" "Sendmail" "SimPL-2.0" "Sleepycat" "Spencer-86" "Spencer-94" "Spencer-99" "SugarCRM-1.1.3" "TCL" "TCP-wrappers" "TMate" "TORQUE-1.1" "TOSL" "UPL-1.0" "Unicode-DFS-2015" "Unicode-DFS-2016" "Unicode-TOU" "Unlicense" "VOSTROM" "VSL-1.0" "Vim" "W3C" "W3C-19980720" "W3C-20150513" "WTFPL" "Watcom-1.0" "Wsuipa" "X11" "XFree86-1.1" "XSkat" "Xerox" "Xnet" "YPL-1.0" "YPL-1.1" "ZPL-1.1" "ZPL-2.0" "ZPL-2.1" "Zed" "Zend-2.0" "Zimbra-1.3" "Zimbra-1.4" "Zlib" "bzip2-1.0.5" "bzip2-1.0.6" "curl" "diffmark" "dvipdfm" "eGenix" "gSOAP-1.3b" "gnuplot" "iMatix" "libtiff" "mpich2" "not-open-source" "psfrag" "psutils" "xinetd" "xpp" "zlib-acknowledgement"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/specimen-combined"
  '("grouped" "pooled"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/specimen-contained-preference"
  '("alternate" "preferred"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/specimen-status"
  '("available" "entered-in-error" "unavailable" "unsatisfactory"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/structure-definition-kind"
  '("complex-type" "logical" "primitive-type" "resource"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/submit-data-update-type"
  '("incremental" "snapshot"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/subscription-notification-type"
  '("event-notification" "handshake" "heartbeat" "query-event" "query-status"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/subscription-payload-content"
  '("empty" "full-resource" "id-only"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/subscription-status"
  '("active" "entered-in-error" "error" "off" "requested"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/subscriptiontopic-cr-behavior"
  '("test-fails" "test-passes"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/substance-status"
  '("active" "entered-in-error" "inactive"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/synchronicity-control"
  '("asynchronous" "either" "synchronous"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/system-restful-interaction"
  '("batch" "history-system" "search-system" "transaction"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/task-intent"
  '("filler-order" "instance-order" "option" "order" "original-order" "plan" "proposal" "reflex-order" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/task-status"
  '("accepted" "cancelled" "completed" "draft" "entered-in-error" "failed" "in-progress" "on-hold" "ready" "received" "rejected" "requested" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/trigger-type"
  '("data-access-ended" "data-accessed" "data-added" "data-changed" "data-modified" "data-removed" "named-event" "periodic" "subscription-topic"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/type-derivation-rule"
  '("constraint" "specialization"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/type-restful-interaction"
  '("create" "create-conditional" "delete" "delete-conditional-multiple" "delete-conditional-single" "delete-history" "delete-history-version" "history-instance" "history-type" "patch" "patch-conditional" "read" "search-type" "update" "update-conditional" "vread"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/udi-entry-type"
  '("barcode" "card" "electronic-transmission" "manual" "rfid" "self-reported" "unknown"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/units-of-time"
  '("a" "d" "h" "min" "mo" "s" "wk"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/value-filter-comparator"
  '("eb" "eq" "ge" "gt" "le" "lt" "sa"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/variable-role"
  '("covariate" "exposure" "outcome" "population"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/versioning-policy"
  '("no-version" "versioned" "versioned-update"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/vision-base-codes"
  '("down" "in" "out" "up"))
(register-binding-expansion! "http://hl7.org/fhir/ValueSet/vision-eye-codes"
  '("left" "right"))
