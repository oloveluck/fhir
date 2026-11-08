# FHIR Mapping Language (FML) in the workspace

FML converts data from one structure to another, such as a QuestionnaireResponse into a Patient, or
a logical model into FHIR resources. `run` transforms every resource of the map's source type in the
data and validates each result. `explain` transforms one source resource and traces each problem in
the result to the rule that wrote it. Staging a run's results is how a transform's output is written
to the data.

## Official references
- FHIR Mapping Language: https://hl7.org/fhir/R5/mapping-language.html
- The StructureMap resource it compiles to: https://hl7.org/fhir/R5/structuremap.html

## Cheat sheet
```
map "http://example.org/StructureMap/qr2patient" = "QR2Patient"
uses "http://hl7.org/fhir/StructureDefinition/QuestionnaireResponse" as source
uses "http://hl7.org/fhir/StructureDefinition/Patient" as target

group main(source src : QuestionnaireResponse, target tgt : Patient) {
  src.item as item where linkId = 'gender' -> tgt.gender = (item.answer.value.code);
  src.item as item where linkId = 'birth' then {
    item.answer as a -> tgt.birthDate = (a.value);
  };
}
```
A rule reads `source -> target`. `where` filters, `then` nests rules or calls a group, and
`create('Type')` makes a new element. FHIRPath appears in brackets.

## Worked example
```fml
map "http://example.org/StructureMap/obs-status" = "ObsStatus"
uses "http://hl7.org/fhir/StructureDefinition/Observation" as source
uses "http://hl7.org/fhir/StructureDefinition/Observation" as target

group main(source src : Observation, target tgt : Observation) {
  src.status as s -> tgt.status = s;
  src.code as c -> tgt.code = c;
}
```

## Common problems
- An element the target lacks: the checker names it at the rule.
- A result fails validation: explain the source resource. The problem names the rule that wrote the
  element.
