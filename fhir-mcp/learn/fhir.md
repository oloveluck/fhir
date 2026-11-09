# FHIR for agents

FHIR (HL7 Fast Healthcare Interoperability Resources) holds health information as **resources**: JSON
objects with a `resourceType`, an `id`, and the elements the specification defines for that type. A
workspace works in R4 (4.0.1, what most systems exchange) or R5 (5.0.0), as `workspace.yaml` says.

## Official references
- The specification: https://hl7.org/fhir/R4/ (R5: https://hl7.org/fhir/R5/)
- Every resource type: https://hl7.org/fhir/R4/resourcelist.html
- The data types (Coding, Quantity, Reference, …): https://hl7.org/fhir/R4/datatypes.html
- Search: https://hl7.org/fhir/R4/search.html
- US Core, the US profiles most servers follow: https://hl7.org/fhir/us/core/

## Which resource holds which fact
| Fact | Resource | Elements to fill |
|---|---|---|
| who the patient is | Patient | name, gender, birthDate, identifier |
| a measurement: lab result, vital sign, score, answer | Observation | status, code, subject, effective[x], value[x] or component |
| a problem or diagnosis | Condition | clinicalStatus, code, subject, onset[x] |
| a prescription | MedicationRequest | status, intent, medication[x], subject, dosageInstruction |
| what the patient takes | MedicationStatement | status, medication[x], subject |
| a visit or stay | Encounter | status, class, subject, period |
| something done to the patient | Procedure | status, code, subject, performed[x] |
| an allergy | AllergyIntolerance | code, patient, criticality |
| a vaccination | Immunization | status, vaccineCode, patient, occurrence[x] |
| a report grouping results | DiagnosticReport | status, code, subject, result (references to Observations) |
| answers to a form | QuestionnaireResponse | status, item.linkId, item.answer.value[x] |
| several resources together | Bundle | type, entry.resource |

`describe("Observation")` lists a type's elements with their cardinality and types;
`describe("Observation.component")` one element.

## The shapes that recur
- **A code** is a Coding `{system, code, display}`; a CodeableConcept holds codings and/or `text`.
  The usual systems: LOINC `http://loinc.org` (what was observed), SNOMED CT `http://snomed.info/sct`
  (conditions, procedures, findings), RxNorm `http://www.nlm.nih.gov/research/umls/rxnorm`
  (medications), ICD-10-CM `http://hl7.org/fhir/sid/icd-10-cm`, UCUM `http://unitsofmeasure.org` (units).
- **A quantity** is `{value, unit, system: "http://unitsofmeasure.org", code}`: `code` is the UCUM
  unit (`mm[Hg]`, `%`, `kg`, `mg/dL`), `unit` how it is shown.
- **A reference** is `{"reference": "Patient/ann"}`: the type and id of another resource.
- **A choice element** `value[x]` is written with its type in the name: `valueQuantity`,
  `valueCodeableConcept`, `valueString`; `effective[x]` is `effectiveDateTime` or `effectivePeriod`.
- **Dates** are `2025-03-01` or `2025-03-01T09:30:00Z`; a partial date (`2025`, `2025-03`) is valid.
- **status** is required on most clinical resources, from a fixed set of codes (`final`, `active`, …).
- **Profiles**: an Implementation Guide (US Core, IPS, mCODE) constrains resources for a use; a
  resource claims one in `meta.profile` and is validated against it. Add an IG under `packages` in
  workspace.yaml and its profiles, value sets and search parameters are in context.

## One blood pressure reading
In FSH, one line per element, a coding or a quantity in one value:

```fsh
Instance: bp-example
InstanceOf: Observation
* status = #final
* category = http://terminology.hl7.org/CodeSystem/observation-category#vital-signs
* code = http://loinc.org#85354-9 "Blood pressure panel"
* subject = Reference(Patient/ann)
* effectiveDateTime = "2025-03-01"
* component[0].code = http://loinc.org#8480-6 "Systolic blood pressure"
* component[0].valueQuantity = 150 'mm[Hg]' "mmHg"
* component[1].code = http://loinc.org#8462-4 "Diastolic blood pressure"
* component[1].valueQuantity = 95 'mm[Hg]' "mmHg"
```

It compiles to the JSON FHIR exchanges (`"valueQuantity": {"value": 150, "unit": "mmHg", "system":
"http://unitsofmeasure.org", "code": "mm[Hg]"}`). The systolic value, in FHIRPath:

```fhirpath
Observation.component.where(code.coding.code = '8480-6').value.ofType(Quantity).value
```

## Doing things with FHIR here
| To | Use |
|---|---|
| create resources | `stage(fsh: "Instance: …")`, then `commit` |
| find resources | `query("search", "Observation?code=http://loinc.org|85354-9&subject=Patient/ann")` |
| read a value inside a resource | FHIRPath (`learn://fhirpath`) |
| decide something per patient, or a cohort | CQL (`learn://cql`) |
| a table of the data, then statistics | a ViewDefinition (`learn://sql-on-fhir`), then `query("sql", "SELECT …")` |
| a set of codes | VCL (`learn://vcl`); `apply("$expand")`, `apply("$lookup")`, `apply("$validate-code")` |
| check data against a profile | a `.json` file (its problems on write), or `apply("$validate")` |
| define profiles, extensions, value sets | FSH (`learn://fsh`) |
| convert one structure to another | FML (`learn://fml`) |
| serve FHIR, with operations of your own | a capability app (`learn://capability`) |
| keep the data | the workspace's `fhir.db`: SQLite, every resource as JSONB |
| rules the data must keep | a profile in FSH, named in workspace.yaml `profiles` (`learn://workspace`) |
| who changed what, when, why | `describe("Type/id/_history")`; Provenance, AuditEvent and `history` in SQL |
