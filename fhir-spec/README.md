# fhir-spec

The vendored HL7 FHIR NPM packages read by the `fhir` codegen (`raco fhir regen`), snapshot
generation, the terminology service and the conformance suites: R4 4.0.1, R5 5.0.0 and R6 core,
US Core, IPS, SQL-on-FHIR, FHIR-to-OMOP and the tx-ecosystem test package. Pure data (about 50 MB),
located from Racket with `(require fhir/spec-package)`:

```racket
(spec-package-path "hl7.fhir.r5.core.tgz")                 ; path, or an "install fhir-spec" error
(spec-package-path "hl7.fhir.r5.core.tgz" #:optional? #t)  ; path or #f
```

Install only when you need it: `raco pkg install fhir-spec`. Provenance and terms: `SOURCE-*.txt`
(every package declares CC0-1.0; this packaging is MIT).
