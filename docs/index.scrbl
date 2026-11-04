#lang scribble/manual

@title{fhir: FHIR as a family of Racket languages}

FHIR's specifications (profiles, value sets, invariants, measures, maps) as Racket @hash-lang[]s and
the tools that check them. This repository holds four packages; the languages are repositories of
their own.

@itemlist[
@item{@hyperlink["fhir/index.html"]{fhir}: the foundation. The typed node model, primitives, JSON,
the R4, R5 and R6 towers and @hash-lang[] @tt{fhir/r6}, StructureDefinition tooling, FHIR operations
as procedures, diagnostics, @tt{raco fhir}.}
@item{@tt{fhir-spec}: the vendored HL7 packages (core R4, R5, R6 and the IGs the tests use). Data only.}
@item{@hyperlink["fhir-validation/index.html"]{fhir-validation}: the validator and the terminology
service, @tt{raco fhir-validate}.}
@item{@hyperlink["fhir-server/index.html"]{fhir-server}: @hash-lang[] @tt{fhir/capability}, the HTTP
server and SQLite store, servers generated from Implementation Guides, @tt{raco fhir-server}.}]

The languages: @hyperlink["https://oloveluck.github.io/fhirpath/"]{fhirpath},
@hyperlink["https://oloveluck.github.io/cql/"]{cql}, @hyperlink["https://oloveluck.github.io/fsh/"]{fsh},
@hyperlink["https://oloveluck.github.io/vcl/"]{vcl}, @hyperlink["https://oloveluck.github.io/fml/"]{fml},
@hyperlink["https://oloveluck.github.io/sql-on-fhir/"]{sql-on-fhir}; and
@hyperlink["https://oloveluck.github.io/fhir-examples/"]{fhir-examples}, the worked examples and the
spec-driven benchmark. Source: @hyperlink["https://github.com/oloveluck/fhir"]{github.com/oloveluck/fhir}.
