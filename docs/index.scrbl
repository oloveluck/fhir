#lang scribble/manual

@title{fhir: FHIR as a family of Racket languages}

FHIR's specifications (profiles, value sets, invariants, measures, maps) as Racket @hash-lang[]s and
the tools that check them. This repository holds five packages; the languages are repositories of
their own.

@itemlist[
@item{@hyperlink["fhir/index.html"]{fhir}: the foundation. The typed node model, primitives, JSON,
the R4, R5 and R6 towers and @hash-lang[] @tt{fhir/r6}, StructureDefinition tooling, FHIR operations
as procedures, diagnostics, @tt{raco fhir}.}
@item{@tt{fhir-spec}: the vendored HL7 packages (core R4, R5, R6 and the IGs the tests use). Data only.}
@item{@hyperlink["fhir-tx/index.html"]{fhir-tx}: the terminology service (@tt{$expand},
@tt{$validate-code}, @tt{$lookup}, @tt{$translate} over FHIR packages), @tt{raco fhir-tx}.}
@item{@hyperlink["fhir-validation/index.html"]{fhir-validation}: the validator, @tt{raco fhir-validate}.}
@item{@hyperlink["fhir-server/index.html"]{fhir-server}: @hash-lang[] @tt{fhir/capability}, the HTTP
server and SQLite store, servers generated from Implementation Guides, @tt{raco fhir-server}.}]

The languages: @hyperlink["https://oloveluck.github.io/fhirpath/"]{fhirpath},
@hyperlink["https://oloveluck.github.io/cql/"]{cql}, @hyperlink["https://oloveluck.github.io/fsh/"]{fsh},
@hyperlink["https://oloveluck.github.io/vcl/"]{vcl}, @hyperlink["https://oloveluck.github.io/fml/"]{fml},
@hyperlink["https://oloveluck.github.io/sql-on-fhir/"]{sql-on-fhir}; and
@hyperlink["https://oloveluck.github.io/fhir-examples/"]{fhir-examples}, the worked examples and the
spec-driven benchmark. Source: @hyperlink["https://github.com/oloveluck/fhir"]{github.com/oloveluck/fhir}.

@section{Terminology}

Codes are checked at three times, by three mechanisms:

@itemlist[
@item{@bold{Compiling a resource form}: the towers carry the required bindings whose value sets
expand offline from their own package (202 in R6), and @tt{(gender "florp")} is a syntax error.}
@item{@bold{Validating}: the validator checks required bindings through the terminology service when
one is passed, else against those offline sets; @tt{$validate} passes one, the command line, the
generated servers and @tt{raco fsh check} do not.}
@item{@bold{At run time}: the terminology service in fhir-tx answers @tt{$expand},
@tt{$validate-code}, @tt{$lookup} and @tt{$translate} over any package or set of resources, as
operations, as FHIRPath's @tt{%terminologies}, over HTTP, and for VCL's implicit value set urls.}]

CQL and FSH do not use the service: CQL takes value set expansions as data, FSH records bindings and
validates no codes; FML's @tt{translate} asks it for ConceptMaps it does not embed. The service's own limits (external code systems undecidable, supplements only when named) are in
the fhir-tx document, with @tt{raco fhir-tx serve}, which puts it over HTTP.

@section{What is missing}

Each document ends its usage section with a @italic{Limits} list, from the code. The largest:
the server has no paging, sorting, chaining, conditional requests or SMART; the validator checks
no references and no extension contexts and leaves invariants off; the terminology service cannot see
external code systems; CQL scores proportion measures only and
reads no terminology service; FML runs every transform but @tt{dateOp}, @tt{escape} and
@tt{pointer}; FSH reproduces most but not all
of what SUSHI writes for two real IGs; forms exist for R6 only; nothing reads or writes XML.
