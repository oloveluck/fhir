#lang racket/base
;;; GENERATED — DO NOT EDIT (verified by raco fhir check).
(require "terminology.rkt" (for-syntax "terminology.rkt"))
(require "schema/Account.rkt"
         "schema/ActivityDefinition.rkt"
         "schema/ActorDefinition.rkt"
         "schema/Address.rkt"
         "schema/AdministrableProductDefinition.rkt"
         "schema/AdverseEvent.rkt"
         "schema/Age.rkt"
         "schema/AllergyIntolerance.rkt"
         "schema/Annotation.rkt"
         "schema/Appointment.rkt"
         "schema/AppointmentResponse.rkt"
         "schema/ArtifactAssessment.rkt"
         "schema/Attachment.rkt"
         "schema/AuditEvent.rkt"
         "schema/Availability.rkt"
         "schema/Basic.rkt"
         "schema/Binary.rkt"
         "schema/BiologicallyDerivedProduct.rkt"
         "schema/BodyStructure.rkt"
         "schema/Bundle.rkt"
         "schema/CapabilityStatement.rkt"
         "schema/CarePlan.rkt"
         "schema/CareTeam.rkt"
         "schema/Claim.rkt"
         "schema/ClaimResponse.rkt"
         "schema/ClinicalUseDefinition.rkt"
         "schema/CodeSystem.rkt"
         "schema/CodeableConcept.rkt"
         "schema/CodeableReference.rkt"
         "schema/Coding.rkt"
         "schema/Communication.rkt"
         "schema/CommunicationRequest.rkt"
         "schema/CompartmentDefinition.rkt"
         "schema/Composition.rkt"
         "schema/ConceptMap.rkt"
         "schema/Condition.rkt"
         "schema/Consent.rkt"
         "schema/ContactDetail.rkt"
         "schema/ContactPoint.rkt"
         "schema/Contract.rkt"
         "schema/Count.rkt"
         "schema/Coverage.rkt"
         "schema/CoverageEligibilityRequest.rkt"
         "schema/CoverageEligibilityResponse.rkt"
         "schema/DataRequirement.rkt"
         "schema/DetectedIssue.rkt"
         "schema/Device.rkt"
         "schema/DeviceAlert.rkt"
         "schema/DeviceAssociation.rkt"
         "schema/DeviceDefinition.rkt"
         "schema/DeviceMetric.rkt"
         "schema/DeviceRequest.rkt"
         "schema/DiagnosticReport.rkt"
         "schema/Distance.rkt"
         "schema/DocumentReference.rkt"
         "schema/Dosage.rkt"
         "schema/DosageCondition.rkt"
         "schema/DosageDetails.rkt"
         "schema/DosageSafety.rkt"
         "schema/Duration.rkt"
         "schema/ElementDefinition.rkt"
         "schema/Encounter.rkt"
         "schema/Endpoint.rkt"
         "schema/EnrollmentRequest.rkt"
         "schema/EnrollmentResponse.rkt"
         "schema/EpisodeOfCare.rkt"
         "schema/EventDefinition.rkt"
         "schema/Evidence.rkt"
         "schema/EvidenceVariable.rkt"
         "schema/ExampleScenario.rkt"
         "schema/ExplanationOfBenefit.rkt"
         "schema/Expression.rkt"
         "schema/ExtendedContactDetail.rkt"
         "schema/Extension.rkt"
         "schema/FamilyMemberHistory.rkt"
         "schema/Flag.rkt"
         "schema/Goal.rkt"
         "schema/Group.rkt"
         "schema/GuidanceResponse.rkt"
         "schema/HealthcareService.rkt"
         "schema/HumanName.rkt"
         "schema/Identifier.rkt"
         "schema/ImagingSelection.rkt"
         "schema/ImagingStudy.rkt"
         "schema/Immunization.rkt"
         "schema/ImplementationGuide.rkt"
         "schema/Ingredient.rkt"
         "schema/InsurancePlan.rkt"
         "schema/InsuranceProduct.rkt"
         "schema/Invoice.rkt"
         "schema/Library.rkt"
         "schema/List.rkt"
         "schema/Location.rkt"
         "schema/ManufacturedItemDefinition.rkt"
         "schema/MarketingStatus.rkt"
         "schema/Measure.rkt"
         "schema/MeasureReport.rkt"
         "schema/Medication.rkt"
         "schema/MedicationAdministration.rkt"
         "schema/MedicationDispense.rkt"
         "schema/MedicationRequest.rkt"
         "schema/MedicationStatement.rkt"
         "schema/MedicinalProductDefinition.rkt"
         "schema/MessageDefinition.rkt"
         "schema/MessageHeader.rkt"
         "schema/Meta.rkt"
         "schema/MonetaryComponent.rkt"
         "schema/Money.rkt"
         "schema/NamingSystem.rkt"
         "schema/Narrative.rkt"
         "schema/NutritionIntake.rkt"
         "schema/NutritionOrder.rkt"
         "schema/NutritionProduct.rkt"
         "schema/Observation.rkt"
         "schema/ObservationDefinition.rkt"
         "schema/OperationDefinition.rkt"
         "schema/OperationOutcome.rkt"
         "schema/Organization.rkt"
         "schema/OrganizationAffiliation.rkt"
         "schema/PackagedProductDefinition.rkt"
         "schema/ParameterDefinition.rkt"
         "schema/Parameters.rkt"
         "schema/Patient.rkt"
         "schema/PaymentNotice.rkt"
         "schema/PaymentReconciliation.rkt"
         "schema/Period.rkt"
         "schema/Person.rkt"
         "schema/PlanDefinition.rkt"
         "schema/Practitioner.rkt"
         "schema/PractitionerRole.rkt"
         "schema/Procedure.rkt"
         "schema/ProductShelfLife.rkt"
         "schema/Provenance.rkt"
         "schema/Quantity.rkt"
         "schema/Questionnaire.rkt"
         "schema/QuestionnaireResponse.rkt"
         "schema/Range.rkt"
         "schema/Ratio.rkt"
         "schema/RatioRange.rkt"
         "schema/Reference.rkt"
         "schema/RegulatedAuthorization.rkt"
         "schema/RelatedArtifact.rkt"
         "schema/RelatedPerson.rkt"
         "schema/RelativeTime.rkt"
         "schema/RequestOrchestration.rkt"
         "schema/Requirements.rkt"
         "schema/ResearchStudy.rkt"
         "schema/ResearchSubject.rkt"
         "schema/RiskAssessment.rkt"
         "schema/SampledData.rkt"
         "schema/Schedule.rkt"
         "schema/SearchParameter.rkt"
         "schema/ServiceRequest.rkt"
         "schema/Signature.rkt"
         "schema/Slot.rkt"
         "schema/Specimen.rkt"
         "schema/SpecimenDefinition.rkt"
         "schema/StructureDefinition.rkt"
         "schema/StructureMap.rkt"
         "schema/Subscription.rkt"
         "schema/SubscriptionStatus.rkt"
         "schema/SubscriptionTopic.rkt"
         "schema/Substance.rkt"
         "schema/SubstanceDefinition.rkt"
         "schema/Task.rkt"
         "schema/TerminologyCapabilities.rkt"
         "schema/Timing.rkt"
         "schema/TriggerDefinition.rkt"
         "schema/UsageContext.rkt"
         "schema/ValueSet.rkt"
         "schema/VirtualServiceDetail.rkt"
         "schema/VisionPrescription.rkt"
         "resources/Account.rkt"
         "resources/ActivityDefinition.rkt"
         "resources/ActorDefinition.rkt"
         "datatypes/Address.rkt"
         "resources/AdministrableProductDefinition.rkt"
         "resources/AdverseEvent.rkt"
         "datatypes/Age.rkt"
         "resources/AllergyIntolerance.rkt"
         "datatypes/Annotation.rkt"
         "resources/Appointment.rkt"
         "resources/AppointmentResponse.rkt"
         "resources/ArtifactAssessment.rkt"
         "datatypes/Attachment.rkt"
         "resources/AuditEvent.rkt"
         "datatypes/Availability.rkt"
         "resources/Basic.rkt"
         "resources/Binary.rkt"
         "resources/BiologicallyDerivedProduct.rkt"
         "resources/BodyStructure.rkt"
         "resources/Bundle.rkt"
         "resources/CapabilityStatement.rkt"
         "resources/CarePlan.rkt"
         "resources/CareTeam.rkt"
         "resources/Claim.rkt"
         "resources/ClaimResponse.rkt"
         "resources/ClinicalUseDefinition.rkt"
         "resources/CodeSystem.rkt"
         "datatypes/CodeableConcept.rkt"
         "datatypes/CodeableReference.rkt"
         "datatypes/Coding.rkt"
         "resources/Communication.rkt"
         "resources/CommunicationRequest.rkt"
         "resources/CompartmentDefinition.rkt"
         "resources/Composition.rkt"
         "resources/ConceptMap.rkt"
         "resources/Condition.rkt"
         "resources/Consent.rkt"
         "datatypes/ContactDetail.rkt"
         "datatypes/ContactPoint.rkt"
         "resources/Contract.rkt"
         "datatypes/Count.rkt"
         "resources/Coverage.rkt"
         "resources/CoverageEligibilityRequest.rkt"
         "resources/CoverageEligibilityResponse.rkt"
         "datatypes/DataRequirement.rkt"
         "resources/DetectedIssue.rkt"
         "resources/Device.rkt"
         "resources/DeviceAlert.rkt"
         "resources/DeviceAssociation.rkt"
         "resources/DeviceDefinition.rkt"
         "resources/DeviceMetric.rkt"
         "resources/DeviceRequest.rkt"
         "resources/DiagnosticReport.rkt"
         "datatypes/Distance.rkt"
         "resources/DocumentReference.rkt"
         "datatypes/Dosage.rkt"
         "datatypes/DosageCondition.rkt"
         "datatypes/DosageDetails.rkt"
         "datatypes/DosageSafety.rkt"
         "datatypes/Duration.rkt"
         "datatypes/ElementDefinition.rkt"
         "resources/Encounter.rkt"
         "resources/Endpoint.rkt"
         "resources/EnrollmentRequest.rkt"
         "resources/EnrollmentResponse.rkt"
         "resources/EpisodeOfCare.rkt"
         "resources/EventDefinition.rkt"
         "resources/Evidence.rkt"
         "resources/EvidenceVariable.rkt"
         "resources/ExampleScenario.rkt"
         "resources/ExplanationOfBenefit.rkt"
         "datatypes/Expression.rkt"
         "datatypes/ExtendedContactDetail.rkt"
         "datatypes/Extension.rkt"
         "resources/FamilyMemberHistory.rkt"
         "resources/Flag.rkt"
         "resources/Goal.rkt"
         "resources/Group.rkt"
         "resources/GuidanceResponse.rkt"
         "resources/HealthcareService.rkt"
         "datatypes/HumanName.rkt"
         "datatypes/Identifier.rkt"
         "resources/ImagingSelection.rkt"
         "resources/ImagingStudy.rkt"
         "resources/Immunization.rkt"
         "resources/ImplementationGuide.rkt"
         "resources/Ingredient.rkt"
         "resources/InsurancePlan.rkt"
         "resources/InsuranceProduct.rkt"
         "resources/Invoice.rkt"
         "resources/Library.rkt"
         "resources/List.rkt"
         "resources/Location.rkt"
         "resources/ManufacturedItemDefinition.rkt"
         "datatypes/MarketingStatus.rkt"
         "resources/Measure.rkt"
         "resources/MeasureReport.rkt"
         "resources/Medication.rkt"
         "resources/MedicationAdministration.rkt"
         "resources/MedicationDispense.rkt"
         "resources/MedicationRequest.rkt"
         "resources/MedicationStatement.rkt"
         "resources/MedicinalProductDefinition.rkt"
         "resources/MessageDefinition.rkt"
         "resources/MessageHeader.rkt"
         "datatypes/Meta.rkt"
         "datatypes/MonetaryComponent.rkt"
         "datatypes/Money.rkt"
         "resources/NamingSystem.rkt"
         "datatypes/Narrative.rkt"
         "resources/NutritionIntake.rkt"
         "resources/NutritionOrder.rkt"
         "resources/NutritionProduct.rkt"
         "resources/Observation.rkt"
         "resources/ObservationDefinition.rkt"
         "resources/OperationDefinition.rkt"
         "resources/OperationOutcome.rkt"
         "resources/Organization.rkt"
         "resources/OrganizationAffiliation.rkt"
         "resources/PackagedProductDefinition.rkt"
         "datatypes/ParameterDefinition.rkt"
         "resources/Parameters.rkt"
         "resources/Patient.rkt"
         "resources/PaymentNotice.rkt"
         "resources/PaymentReconciliation.rkt"
         "datatypes/Period.rkt"
         "resources/Person.rkt"
         "resources/PlanDefinition.rkt"
         "resources/Practitioner.rkt"
         "resources/PractitionerRole.rkt"
         "resources/Procedure.rkt"
         "datatypes/ProductShelfLife.rkt"
         "resources/Provenance.rkt"
         "datatypes/Quantity.rkt"
         "resources/Questionnaire.rkt"
         "resources/QuestionnaireResponse.rkt"
         "datatypes/Range.rkt"
         "datatypes/Ratio.rkt"
         "datatypes/RatioRange.rkt"
         "datatypes/Reference.rkt"
         "resources/RegulatedAuthorization.rkt"
         "datatypes/RelatedArtifact.rkt"
         "resources/RelatedPerson.rkt"
         "datatypes/RelativeTime.rkt"
         "resources/RequestOrchestration.rkt"
         "resources/Requirements.rkt"
         "resources/ResearchStudy.rkt"
         "resources/ResearchSubject.rkt"
         "resources/RiskAssessment.rkt"
         "datatypes/SampledData.rkt"
         "resources/Schedule.rkt"
         "resources/SearchParameter.rkt"
         "resources/ServiceRequest.rkt"
         "datatypes/Signature.rkt"
         "resources/Slot.rkt"
         "resources/Specimen.rkt"
         "resources/SpecimenDefinition.rkt"
         "resources/StructureDefinition.rkt"
         "resources/StructureMap.rkt"
         "resources/Subscription.rkt"
         "resources/SubscriptionStatus.rkt"
         "resources/SubscriptionTopic.rkt"
         "resources/Substance.rkt"
         "resources/SubstanceDefinition.rkt"
         "resources/Task.rkt"
         "resources/TerminologyCapabilities.rkt"
         "datatypes/Timing.rkt"
         "datatypes/TriggerDefinition.rkt"
         "datatypes/UsageContext.rkt"
         "resources/ValueSet.rkt"
         "datatypes/VirtualServiceDetail.rkt"
         "resources/VisionPrescription.rkt")
(provide (all-from-out "resources/Account.rkt")
         (all-from-out "resources/ActivityDefinition.rkt")
         (all-from-out "resources/ActorDefinition.rkt")
         (all-from-out "datatypes/Address.rkt")
         (all-from-out "resources/AdministrableProductDefinition.rkt")
         (all-from-out "resources/AdverseEvent.rkt")
         (all-from-out "datatypes/Age.rkt")
         (all-from-out "resources/AllergyIntolerance.rkt")
         (all-from-out "datatypes/Annotation.rkt")
         (all-from-out "resources/Appointment.rkt")
         (all-from-out "resources/AppointmentResponse.rkt")
         (all-from-out "resources/ArtifactAssessment.rkt")
         (all-from-out "datatypes/Attachment.rkt")
         (all-from-out "resources/AuditEvent.rkt")
         (all-from-out "datatypes/Availability.rkt")
         (all-from-out "resources/Basic.rkt")
         (all-from-out "resources/Binary.rkt")
         (all-from-out "resources/BiologicallyDerivedProduct.rkt")
         (all-from-out "resources/BodyStructure.rkt")
         (all-from-out "resources/Bundle.rkt")
         (all-from-out "resources/CapabilityStatement.rkt")
         (all-from-out "resources/CarePlan.rkt")
         (all-from-out "resources/CareTeam.rkt")
         (all-from-out "resources/Claim.rkt")
         (all-from-out "resources/ClaimResponse.rkt")
         (all-from-out "resources/ClinicalUseDefinition.rkt")
         (all-from-out "resources/CodeSystem.rkt")
         (all-from-out "datatypes/CodeableConcept.rkt")
         (all-from-out "datatypes/CodeableReference.rkt")
         (all-from-out "datatypes/Coding.rkt")
         (all-from-out "resources/Communication.rkt")
         (all-from-out "resources/CommunicationRequest.rkt")
         (all-from-out "resources/CompartmentDefinition.rkt")
         (all-from-out "resources/Composition.rkt")
         (all-from-out "resources/ConceptMap.rkt")
         (all-from-out "resources/Condition.rkt")
         (all-from-out "resources/Consent.rkt")
         (all-from-out "datatypes/ContactDetail.rkt")
         (all-from-out "datatypes/ContactPoint.rkt")
         (all-from-out "resources/Contract.rkt")
         (all-from-out "datatypes/Count.rkt")
         (all-from-out "resources/Coverage.rkt")
         (all-from-out "resources/CoverageEligibilityRequest.rkt")
         (all-from-out "resources/CoverageEligibilityResponse.rkt")
         (all-from-out "datatypes/DataRequirement.rkt")
         (all-from-out "resources/DetectedIssue.rkt")
         (all-from-out "resources/Device.rkt")
         (all-from-out "resources/DeviceAlert.rkt")
         (all-from-out "resources/DeviceAssociation.rkt")
         (all-from-out "resources/DeviceDefinition.rkt")
         (all-from-out "resources/DeviceMetric.rkt")
         (all-from-out "resources/DeviceRequest.rkt")
         (all-from-out "resources/DiagnosticReport.rkt")
         (all-from-out "datatypes/Distance.rkt")
         (all-from-out "resources/DocumentReference.rkt")
         (all-from-out "datatypes/Dosage.rkt")
         (all-from-out "datatypes/DosageCondition.rkt")
         (all-from-out "datatypes/DosageDetails.rkt")
         (all-from-out "datatypes/DosageSafety.rkt")
         (all-from-out "datatypes/Duration.rkt")
         (all-from-out "datatypes/ElementDefinition.rkt")
         (all-from-out "resources/Encounter.rkt")
         (all-from-out "resources/Endpoint.rkt")
         (all-from-out "resources/EnrollmentRequest.rkt")
         (all-from-out "resources/EnrollmentResponse.rkt")
         (all-from-out "resources/EpisodeOfCare.rkt")
         (all-from-out "resources/EventDefinition.rkt")
         (all-from-out "resources/Evidence.rkt")
         (all-from-out "resources/EvidenceVariable.rkt")
         (all-from-out "resources/ExampleScenario.rkt")
         (all-from-out "resources/ExplanationOfBenefit.rkt")
         (all-from-out "datatypes/Expression.rkt")
         (all-from-out "datatypes/ExtendedContactDetail.rkt")
         (all-from-out "datatypes/Extension.rkt")
         (all-from-out "resources/FamilyMemberHistory.rkt")
         (all-from-out "resources/Flag.rkt")
         (all-from-out "resources/Goal.rkt")
         (all-from-out "resources/Group.rkt")
         (all-from-out "resources/GuidanceResponse.rkt")
         (all-from-out "resources/HealthcareService.rkt")
         (all-from-out "datatypes/HumanName.rkt")
         (all-from-out "datatypes/Identifier.rkt")
         (all-from-out "resources/ImagingSelection.rkt")
         (all-from-out "resources/ImagingStudy.rkt")
         (all-from-out "resources/Immunization.rkt")
         (all-from-out "resources/ImplementationGuide.rkt")
         (all-from-out "resources/Ingredient.rkt")
         (all-from-out "resources/InsurancePlan.rkt")
         (all-from-out "resources/InsuranceProduct.rkt")
         (all-from-out "resources/Invoice.rkt")
         (all-from-out "resources/Library.rkt")
         (all-from-out "resources/List.rkt")
         (all-from-out "resources/Location.rkt")
         (all-from-out "resources/ManufacturedItemDefinition.rkt")
         (all-from-out "datatypes/MarketingStatus.rkt")
         (all-from-out "resources/Measure.rkt")
         (all-from-out "resources/MeasureReport.rkt")
         (all-from-out "resources/Medication.rkt")
         (all-from-out "resources/MedicationAdministration.rkt")
         (all-from-out "resources/MedicationDispense.rkt")
         (all-from-out "resources/MedicationRequest.rkt")
         (all-from-out "resources/MedicationStatement.rkt")
         (all-from-out "resources/MedicinalProductDefinition.rkt")
         (all-from-out "resources/MessageDefinition.rkt")
         (all-from-out "resources/MessageHeader.rkt")
         (all-from-out "datatypes/Meta.rkt")
         (all-from-out "datatypes/MonetaryComponent.rkt")
         (all-from-out "datatypes/Money.rkt")
         (all-from-out "resources/NamingSystem.rkt")
         (all-from-out "datatypes/Narrative.rkt")
         (all-from-out "resources/NutritionIntake.rkt")
         (all-from-out "resources/NutritionOrder.rkt")
         (all-from-out "resources/NutritionProduct.rkt")
         (all-from-out "resources/Observation.rkt")
         (all-from-out "resources/ObservationDefinition.rkt")
         (all-from-out "resources/OperationDefinition.rkt")
         (all-from-out "resources/OperationOutcome.rkt")
         (all-from-out "resources/Organization.rkt")
         (all-from-out "resources/OrganizationAffiliation.rkt")
         (all-from-out "resources/PackagedProductDefinition.rkt")
         (all-from-out "datatypes/ParameterDefinition.rkt")
         (all-from-out "resources/Parameters.rkt")
         (all-from-out "resources/Patient.rkt")
         (all-from-out "resources/PaymentNotice.rkt")
         (all-from-out "resources/PaymentReconciliation.rkt")
         (all-from-out "datatypes/Period.rkt")
         (all-from-out "resources/Person.rkt")
         (all-from-out "resources/PlanDefinition.rkt")
         (all-from-out "resources/Practitioner.rkt")
         (all-from-out "resources/PractitionerRole.rkt")
         (all-from-out "resources/Procedure.rkt")
         (all-from-out "datatypes/ProductShelfLife.rkt")
         (all-from-out "resources/Provenance.rkt")
         (all-from-out "datatypes/Quantity.rkt")
         (all-from-out "resources/Questionnaire.rkt")
         (all-from-out "resources/QuestionnaireResponse.rkt")
         (all-from-out "datatypes/Range.rkt")
         (all-from-out "datatypes/Ratio.rkt")
         (all-from-out "datatypes/RatioRange.rkt")
         (all-from-out "datatypes/Reference.rkt")
         (all-from-out "resources/RegulatedAuthorization.rkt")
         (all-from-out "datatypes/RelatedArtifact.rkt")
         (all-from-out "resources/RelatedPerson.rkt")
         (all-from-out "datatypes/RelativeTime.rkt")
         (all-from-out "resources/RequestOrchestration.rkt")
         (all-from-out "resources/Requirements.rkt")
         (all-from-out "resources/ResearchStudy.rkt")
         (all-from-out "resources/ResearchSubject.rkt")
         (all-from-out "resources/RiskAssessment.rkt")
         (all-from-out "datatypes/SampledData.rkt")
         (all-from-out "resources/Schedule.rkt")
         (all-from-out "resources/SearchParameter.rkt")
         (all-from-out "resources/ServiceRequest.rkt")
         (all-from-out "datatypes/Signature.rkt")
         (all-from-out "resources/Slot.rkt")
         (all-from-out "resources/Specimen.rkt")
         (all-from-out "resources/SpecimenDefinition.rkt")
         (all-from-out "resources/StructureDefinition.rkt")
         (all-from-out "resources/StructureMap.rkt")
         (all-from-out "resources/Subscription.rkt")
         (all-from-out "resources/SubscriptionStatus.rkt")
         (all-from-out "resources/SubscriptionTopic.rkt")
         (all-from-out "resources/Substance.rkt")
         (all-from-out "resources/SubstanceDefinition.rkt")
         (all-from-out "resources/Task.rkt")
         (all-from-out "resources/TerminologyCapabilities.rkt")
         (all-from-out "datatypes/Timing.rkt")
         (all-from-out "datatypes/TriggerDefinition.rkt")
         (all-from-out "datatypes/UsageContext.rkt")
         (all-from-out "resources/ValueSet.rkt")
         (all-from-out "datatypes/VirtualServiceDetail.rkt")
         (all-from-out "resources/VisionPrescription.rkt"))
