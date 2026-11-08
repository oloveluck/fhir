# fhir-spec

The vendored HL7 FHIR NPM packages read by the `fhir` codegen (`raco fhir regen`), snapshot
generation, the terminology service and the conformance suites: R4 4.0.1, R5 5.0.0 and R6 core,
US Core (9.0.0, 8.0.0, 6.1.0), IPS, mCODE 4.0.0 with Genomics Reporting 2.0.0,
CQF Measures 5.0.0 and the tx-ecosystem test package. Pure data (about 53 MB). An IG's dependency is
found by name as `<id>-<version>.tgz` (fsh's sushi-config.yaml reader uses this),
located from Racket with `(require fhir/spec-package)`:

```racket
(spec-package-path "hl7.fhir.r5.core.tgz")                 ; path, or an "install fhir-spec" error
(spec-package-path "hl7.fhir.r5.core.tgz" #:optional? #t)  ; path or #f
```

Install only when you need it: `raco pkg install fhir-spec`. Packages are also looked for in the
directories named by `FHIR_PACKAGE_PATH` (searched first), and in `share/fhir-packages` beside a
standalone build of the command-line tools, which `build-tools.sh` fills from this package. Provenance and terms: `SOURCE-*.txt`
(every package declares CC0-1.0; this packaging is MIT).
