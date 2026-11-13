#lang scribble/manual
@; Text in @tt is shown exactly as written: no curly quotes, and "--" stays two hyphens.
@(require (only-in scribble/core [element literal-element]))
@(define (tt . text) (literal-element (quote tt) text))
@(require (for-label (except-in racket/base make-string make-date read-string write-string) racket/contract
                     fhir/result/result fhir/model/node fhir/model/leaf fhir/model/registry fhir/registry
                     fhir/serialize/to-json fhir/serialize/from-json fhir/serialize/read-json
                     fhir/serialize/fhir-json fhir/serialize/lenient
                     fhir/primitives/primitives fhir/package fhir/spec-package fhir/operation
                     fhir/data-source fhir/rest-data-source fhir/diagnostic fhir/canonical fhir/suggest
                     fhir/check-files fhir/lang/support
                     fhir/sd/sd-index fhir/sd/snapshot (except-in fhir/sd/element-index opaque-type?)
                     fhir/sd/operations fhir/sd/logical fhir/sd/profile))

@title{fhir: the foundation}

@hyperlink["https://hl7.org/fhir/"]{FHIR} is the standard most health systems use to exchange data.
A patient, a lab result, a prescription are each a small JSON document called a @italic{resource},
and the standard says exactly what each one may contain: which fields, how many of each, what a date
or a code must look like.

Every tool in this family has to do the same few things with resources: read one, check that each
value is what FHIR says it must be, write it back out unchanged, and say where a mistake is. This
package is where that is done, once, for the three FHIR versions in use (R4, R5 and R6). The
languages and tools (@tt{fsh}, @tt{cql}, @tt{fml}, the validator, the server) are built on it.

You will rarely use it directly. If you only use the command-line tools, it is installed with them
and works underneath; @secref["cli-only"] is all you need from this page. If you write programs in
Racket, this is the library you program against, and the rest of the page is for you.

Part of the @hyperlink["https://oloveluck.github.io/fhir/"]{fhir} family of FHIR languages and tools.

@table-of-contents[]

@section{What you can do with it}

@itemlist[
@item{@bold{Read the guides from the command line}: @tt{raco fhir guide} prints the family's
guides, one per language and one for FHIR itself (@secref["cli-only"]).}
@item{@bold{Start a small project from a template} and @bold{check every language file in a folder
in one run}: @tt{raco fhir new pipeline} and @tt{raco fhir check-files} (@secref["modules"]).}
@item{@bold{Write a resource as a checked form}: in @hash-lang[] @tt{fhir/r6} a misspelt field, a
date that is no date or a code FHIR does not allow stops the file from building (@secref["first"]).}
@item{@bold{Read FHIR JSON in a program}, look inside it, and write it back with every number as it
was written (@secref["json"]).}
@item{@bold{Call FHIR's operations as functions}: @tt{$validate}, @tt{$expand}, @tt{$transform} and
the rest, with no server (@secref["operations"]).}
@item{@bold{Let definitions find each other by address}: a profile, a value set or a map is found
by its url wherever it lives (@secref["finding"]).}
@item{@bold{Report problems the way the family does}: one value, shown as @tt{file:line:column}
text, as JSON or as a FHIR resource (@secref["diagnostics"]).}]

@section[#:tag "cli-only"]{If you only use the command-line tools}

Install the tools as the @hyperlink["https://oloveluck.github.io/fhir/"]{family's front page}
describes. This package comes with them; there is nothing to set up. Three things on this page are
worth knowing.

@bold{The guides.} @tt{raco fhir guide} lists them, and @tt{raco fhir guide <topic>} prints one.
They are written to be read quickly: a cheat sheet, a worked example, the common problems.

@verbatim{
$ raco fhir guide
fhir  FHIR for agents: which resource holds which fact, the shapes that recur (codes, quantities, references, choice elements), the usual code systems, links to the specification
workspace  The workspace: files, the tools (write, check, run, query, explain, describe, apply, stage, commit), which language for which question, workspace.yaml
fsh  FHIR Shorthand: profiles, extensions, value sets, examples; cheat sheet, worked example, links to the FSH specification
cql  Clinical Quality Language: patient logic and cohorts; cheat sheet, worked example, links to the CQL specification and reference
…
}

A guide's examples can be saved as files: @litchar{raco fhir guide racket --blocks} lists the code
blocks of the @tt{racket} guide, and @litchar{raco fhir guide racket --block minimal > main.rkt} saves the
one named @tt{minimal}. A block is asked for by its name or its number.

@bold{One way of reporting a mistake.} Every tool in the family says where a problem is in the same
form: the file, the line and the column, the message, then the line itself with a marker under the
place. Here is the CQL tool refusing a misspelt function:

@verbatim{
Intake.cql:6:15: cql compile error: in define "Age": unknown function 'AgeInYear' (did you mean `AgeInYears` or `AgeInYearsAt`?)
 6 | define "Age": AgeInYear()
   |               ^^^^^^^^^
}

The languages' tools and the validator take @litchar{--format json} or @litchar{--format outcome}
to print the same report for a program to read (@secref["diagnostics"]).

@bold{The same exit codes.} A tool exits with 0 when all is well, 1 when it found a problem in what
you gave it, and 2 when it was called wrongly (an unknown option, a file that is not there). Every
tool prints its usage with @litchar{--help}.

The other commands of @tt{raco fhir} are in @secref["cli"].

@section[#:tag "first"]{A first example}

This example writes one resource and has it checked. It needs Racket.

@bold{1. Install} as the @hyperlink["https://oloveluck.github.io/fhir/"]{front page} describes. Of
the packages it installs, this page needs two: @tt{fhir} (this one, which depends on nothing but
Racket itself) and @tt{fhir-spec} (the FHIR specification as HL7 publishes it, which the tools read).

@bold{2. Write a resource.} FHIR resources are usually written as JSON. Here you write one as a
@italic{form} instead: the same content, with parentheses, in a file whose first line names the
FHIR version. This is @tt{patient.fhir6}:

@racketmod[#:file "patient.fhir6" fhir/r6
(Patient
 (id "example") (active #t) (gender "male") (birthDate "1974-12-25")
 (name (HumanName (use "official") (family "Chalmers") (given "Peter" "James"))))]

Each pair of parentheses is one field of the resource and its value. A field that holds a
structure, such as a name, takes a form of that structure's type (@tt{HumanName}). A field that
repeats takes all its values at once (@tt{given}).

@bold{3. Run it.} The file is a program that prints the resource as JSON:

@verbatim|{
$ racket patient.fhir6
{"active":true,"birthDate":"1974-12-25","gender":"male","id":"example","name":[{"family":"Chalmers","given":["Peter","James"],"use":"official"}],"resourceType":"Patient"}
}|

@bold{4. Make a mistake.} FHIR allows four values for a patient's gender. Write
@racket[(gender "florp")] and the file no longer builds; the message lists the values that are
allowed:

@verbatim{
$ racket patient.fhir6
Patient: "florp" is not in the required value set for Patient.gender (http://hl7.org/fhir/ValueSet/administrative-gender); valid codes: (female male other unknown)
  in: "florp"
  …
}

The same happens for a field FHIR does not define (@tt{Patient: unknown field Patient.actve}), a
date that is no date (@tt{Patient: invalid date value: "1974-02-30"}), a required field left out,
or a field given twice. Nothing has to run for these to be found: they are caught when the file is
built.

@bold{5. Use it from a program.} The file is also a Racket module. Another program requires it and
gets the resource as a value:

@racketblock[
(require "patient.fhir6" fhir/model/leaf)
(define p (car resources))
(node-str p 'gender)        (code:comment "\"male\"")
(->json)                    (code:comment "the same resources as JSON data")
]

@section[#:tag "cli"]{The command line}

@tt{raco fhir} is this package's command. Half of it is for anyone, half for people who maintain
the package.

@tabular[#:style 'boxed #:sep @hspace[2]
(list (list @bold{command} @bold{what it does})
      (list @tt{raco fhir guide [topic]} @elem{the list of guides, or one of them; @litchar{--blocks} lists a guide's code blocks, @litchar{--block N} or @litchar{--block <name>} prints one})
      (list @tt{raco fhir new pipeline <dir>} @elem{a copy of the Racket pipeline template in a new folder (@secref["modules"])})
      (list @tt{raco fhir new tests [dir]} @elem{the template's @tt{tests.rkt} alone, to put beside files of your own})
      (list @tt{raco fhir check-files [dir|file …]} @elem{every @tt{#lang} @tt{.fsh}, @tt{.map}, @tt{.cql} and @tt{.vcl} file compiled, each one's problem at its line, in one run})
      (list @tt{raco fhir roundtrip file.json [Type]} "read one resource and write it back; a quick test that it is well-formed FHIR")
      (list @tt{raco fhir snapshot sd.json} @elem{a profile with its @italic{snapshot} filled in (@secref["words"])})
      (list @tt{raco fhir roundtrip-tck [r4|r5]} "for maintainers: read and write back every resource HL7 publishes for that version")
      (list @tt{raco fhir regen [r6|r4|r5|all]} "for maintainers: regenerate the FHIR types from the specification")
      (list @tt{raco fhir check [r6|r4|r5|all]} "for maintainers: the generated types on disk equal a fresh generation"))]

@tt{roundtrip} reads strictly, with the R6 types: an element FHIR does not define is refused.

@verbatim|{
$ raco fhir roundtrip odd.json
roundtrip: parse failed: Patient: unknown field colour (see https://build.fhir.org/patient.html#Patient)
}|

To check a resource against FHIR's rules in full (allowed codes, required fields, a profile), use
@tt{raco fhir-validate}, the validator's own command.

@tt{snapshot} needs the @tt{fhir-spec} package, and looks the profile's base up in the R5
specification. It prints the profile again with every element spelt out: a profile that changes one
element of Patient comes back with all 45.

Exit codes are the family's: 0, 1 for a problem found (a resource that does not parse, generated
files that differ), 2 for a wrong call, which prints one line and the usage:

@verbatim{
$ raco fhir roundtrip nope.json
raco fhir roundtrip: no such file: nope.json
usage: raco fhir roundtrip <file.json> [Type]
}

Turning FHIR JSON into FHIR Shorthand is the @tt{fsh} package's (@litchar{raco fsh --decompile}).

@section[#:tag "forms"]{Resources as forms}

A form is a resource written so that it is checked as it is built. You have seen one in
@secref["first"]; this section is the rules.

@itemlist[
@item{@bold{One form per resource or structure.} @racket[(Patient …)], @racket[(Observation …)],
@racket[(HumanName …)], @racket[(Coding …)]: every R6 resource and datatype has a form of its name.
A file may hold several top-level forms.}
@item{@bold{A simple value is a literal}: a string, a number, @racket[#t] or @racket[#f].}
@item{@bold{A repeating field takes all its values in one form}: @racket[(given "Peter" "James")].
Writing the field twice is an error that says so.}
@item{@bold{A choice is written by its full name.} Where FHIR lets a value be one of several types
(@tt{deceased[x]} is a boolean or a date and time), write the one you mean: @racket[(deceasedBoolean #f)].}
@item{@bold{What is checked}: unknown and duplicate fields, missing required fields, how many values
a field may have, the type of a nested form, the text of every date, time, code, url and number,
and codes that FHIR restricts to a fixed list.}]

A file in @hash-lang[] @tt{fhir/r6} provides @racket[resources] (the resources as typed values),
@racket[(->nodes)] (the same list) and @racket[(->json)] (as JSON data). Run directly it prints the
JSON.

@subsection{Narrowing a type: @hash-lang[] @tt{fhir/sd}}

A @italic{profile} is a stricter version of a type for one setting: "here, every patient has a name
and a gender". @hash-lang[] @tt{fhir/sd} is a small way to say that in Racket:

@racketmod[#:file "us.sd" fhir/sd
(profile USCorePatient #:base Patient (name 1 *) (gender 1 1))
(profile VIPPatient #:base USCorePatient (name 1 1))]

Each line of a profile gives a field its least and greatest number of values (@racket[*] is "any
number"). The profile becomes a form of its own, which checks its rules and then builds the base
resource:

@racketblock[
(require "us.sd" fhir/r6/types)
(USCorePatient (gender "female") (name (HumanName (family "A"))))    (code:comment "a Patient")
(USCorePatient (gender "female"))
(code:comment "error: USCorePatient: missing required field USCorePatient.name")
]

A profile may only narrow. One that loosens its base is refused where it does so:

@verbatim{
loose.sd:3:20: profile: name: min 0 loosens base min 1 (a profile may only narrow)
}

This covers how many values a field has, nothing more. Real profiles (fixed values, bindings to
value sets, slices, invariants) are written in FHIR Shorthand, with the
@hyperlink["https://oloveluck.github.io/fsh/"]{fsh} package.

@section[#:tag "json"]{Reading and writing FHIR JSON}

Most programs meet FHIR as JSON from somewhere else. Reading it gives a @italic{typed node}: a value
that knows its FHIR type and holds each field already checked.

@racketblock[
(require fhir/r5/schemas fhir/serialize/from-json fhir/serialize/to-json fhir/serialize/read-json
         fhir/model/node fhir/model/leaf fhir/result/result)
(define js (call-with-input-file "patient.json" read-fhir-json))
(define p (ok-value (from-json js)))
(fhir-type p)                                                 (code:comment "'Patient")
(node-str p 'gender)                                          (code:comment "\"male\"")
(pv (fhir-ref (car (listify (fhir-ref p 'name))) 'family))   (code:comment "\"Chalmers\"")
(node->json-string p)                                         (code:comment "the JSON text again")
]

Four things to know:

@itemlist[
@item{@bold{Load a FHIR version first.} @racket[(require fhir/r5/schemas)] is what tells
@racket[from-json] what a Patient is. See @secref["versions"].}
@item{@bold{The answer is a result, not an exception.} @racket[from-json] returns @racket[(ok node)]
or @racket[(err error)], and the error carries the address of the rule in the specification:

@racketblock[
(from-json (hash-set js 'favouriteColour "blue"))
(code:comment "(err (unknown-field 'Patient \"https://hl7.org/fhir/R5/patient.html#Patient\" 'favouriteColour))")
]}
@item{@bold{Strict or lenient.} By default an element FHIR does not define is an error. With
@racket[#:lenient? #t] it is skipped, and so is a value that does not parse, so that data from
another FHIR version still loads. @racket[lenient-drops] then tells you what was left out:
@tt{birthDate ("25/12/1974"), favouriteColour ("blue")}.}
@item{@bold{Numbers keep their digits.} In clinical data @tt{1.50} and @tt{1.5} are not the same
statement: the first claims more precision. @racket[read-fhir-json] remembers each number as it was
written, and @racket[node->json-string] writes it back that way. @racket[node->jsexpr] gives plain
Racket numbers for when you want to compute.}]

To print JSON the way FHIR documents are written, with @tt{resourceType} first and each element in
the order the specification lists it, use @racket[write-fhir-json]:

@racketblock[
(require fhir/serialize/fhir-json)
(write-fhir-json (node->jsexpr p) #:indent 2)
]

@verbatim|{
{
  "resourceType": "Patient",
  "id": "example",
  "active": true,
  "name": [
    {
      "use": "official",
      …
}|

@section[#:tag "versions"]{FHIR versions}

FHIR has versions, and a resource of one is not always valid in another. The types of each version
are a module you load; the family calls the set of them a @italic{tower}.

@tabular[#:style 'boxed #:sep @hspace[2]
(list (list @bold{version} @bold{load it with} @bold{what you get})
      (list "R4 (4.0.1)" @racket[(require fhir/r4/schemas)] "reading, writing, navigation, validation")
      (list "R5 (5.0.0)" @racket[(require fhir/r5/schemas)] "the same")
      (list "R6 (6.0.0-ballot4)" @racket[(require fhir/r6/types)] @elem{the same, and the forms of @hash-lang[] @tt{fhir/r6}}))]

Load one version in a program. The types are known by name (@tt{Patient}, @tt{Observation}), so a
second version loaded into the same process would replace the first one's.

Each version also brings its operation definitions as data (@tt{fhir/r4/operations},
@tt{fhir/r5/operations}, @tt{fhir/r6/operations}) and the code lists FHIR fixes (@tt{terminology}),
which is how @racket[(gender "florp")] is caught.

All of this is generated from the specification HL7 publishes, and never edited by hand:
@tt{raco fhir regen} writes it and @tt{raco fhir check} confirms that what is on disk is what a
fresh generation gives.

@section[#:tag "operations"]{Operations as functions}

FHIR names its services with a dollar sign: @tt{$validate} checks a resource, @tt{$expand} lists the
codes of a value set, @tt{$transform} runs a map. On a server you call one over HTTP. Here each is an
ordinary function, and no server is involved.

@racketblock[
(require json fhir/r5/schemas fhir/operation
         (only-in fhir/conformance/operations ensure-valid)      (code:comment "fhir-validation: $validate")
         (only-in fhir/terminology/operations))                  (code:comment "fhir-tx: $expand, $validate-code …")
(define patient (call-with-input-file "patient.json" read-json))

(apply-operation "$validate" patient)
(code:comment "an OperationOutcome saying \"All OK (FHIR R5 (5.0.0))\"")

(apply-operation "ValueSet/$expand" #:url "http://hl7.org/fhir/ValueSet/administrative-gender")
(code:comment "a ValueSet whose expansion holds male, female, other, unknown")

(define validate (operation "$validate"))       (code:comment "look it up once")
(validate patient)                              (code:comment "then call it like any function")
(~> patient (ensure-valid) (validate))          (code:comment "pass a value through several")
]

How it works:

@itemlist[
@item{@bold{You name the operation}, by its code (@racket["$validate"]), by type and code when two
operations share a code (@racket["ValueSet/$validate-code"]), or by the url of its definition. An
ambiguous name is refused with the names to use instead.}
@item{@bold{The first argument is the resource it applies to}; the operation's other inputs are
keywords, named as FHIR names them (@racket[#:url], @racket[#:profile]). A misspelt one is an error
that lists the right ones: @tt{$validate has no input parameter 'profle' (it takes: resource, mode,
profile, usageContext)}.}
@item{@bold{The answer is FHIR JSON}: the resource the operation returns, or a Parameters resource
holding its outputs.}
@item{@bold{A failure raises} @racket[exn:fail:operation], which carries an
@italic{OperationOutcome}, FHIR's own resource for reporting problems.
@racket[apply-operation/outcome] returns that outcome instead of raising.}
@item{@bold{The package that does the work provides the operation.} Requiring its module is what
makes the name known; without it you get @tt{no operation $validate is registered}.}]

@tabular[#:style 'boxed #:sep @hspace[2]
(list (list @bold{operations} @bold{require} @bold{package})
      (list @tt{$snapshot} @racket[fhir/sd/operations] "fhir (this one)")
      (list @elem{@tt{$validate}, and @racket[ensure-valid]} @tt{fhir/conformance/operations} "fhir-validation")
      (list @elem{@tt{$expand}, @tt{$validate-code}, @tt{$lookup}, @tt{$subsumes}, @tt{$find-matches}, @tt{$translate}, @tt{$closure}} @tt{fhir/terminology/operations} "fhir-tx")
      (list @tt{$transform} @tt{fml/operations} "fml")
      (list @tt{$evaluate-measure} @tt{cql/measure} "cql")
      (list @elem{@tt{$sql-run}, @tt{$sql-export}} @tt{sql-on-fhir/operations} "sql-on-fhir"))]

@tt{$validate} answers with a report whether or not the resource is valid. @racket[ensure-valid] is
the form for a program: it returns the resource when it is valid and raises when it is not, with
every problem in the message.

@verbatim{
invalid Patient (FHIR R5 (5.0.0)):
  Patient.gender code `florp` not in required value set http://hl7.org/fhir/ValueSet/administrative-gender; it holds female, male, other, unknown
}

Load a FHIR version before validating, as the example does. The check of codes against FHIR's fixed
lists reads them from the loaded version; without one, that check is skipped and @tt{"florp"}
passes.

The same functions are what @hyperlink["https://oloveluck.github.io/fhir/fhir-server/index.html"]{fhir-server}
answers with over HTTP, and you can add your own: @racket[make-operation] and
@racket[register-operation!], in the reference.

@section[#:tag "finding"]{How definitions and data are found}

A profile, a value set, a map: each has a web address, its @italic{canonical url}, and everything
that refers to it uses that address. Nothing is fetched from the address; it is a name. When an
operation needs the definition behind one, it looks in three places, in this order.

@itemlist[
@item{@bold{The data you gave it}: @racket[current-data-source]. This is where an operation finds
resources to work on, such as the patients a measure counts. It can be a list in memory, a folder of
JSON files, or a FHIR server.

@racketblock[
(require fhir/data-source)
(parameterize ([current-data-source (directory->data-source "data/")])
  …)
]}
@item{@bold{What your program defined}: the registry (@racketmodname[fhir/registry]). A file written
in one of the family's languages registers what it defines when your program requires it: an FSH
file its profiles and value sets, a map file its map, a CQL file its library. So requiring the file
is enough for its definitions to be found by address. You can register resources you built yourself:

@racketblock[
(require fhir/registry)
(register-resources! (list profile) #:source 'my-program)
(ensure-valid patient #:profile "http://example.org/StructureDefinition/named-patient")
]

Two sources that define the same address differently are an error naming both.}
@item{@bold{The published packages}: @racket[current-sd-packages]. FHIR itself and each
Implementation Guide are published as a @italic{package}, a @tt{.tgz} file. By default this is the
R5 specification. To validate against a published guide, name its package, then the FHIR version it
is built on:

@racketblock[
(require fhir/r4/schemas fhir/sd/sd-index fhir/spec-package)
(parameterize ([current-sd-packages (list (spec-package-path "hl7.fhir.us.core-6.1.0.tgz")
                                          (spec-package-path "hl7.fhir.r4.core.tgz"))])
  (ensure-valid patient #:profile "http://hl7.org/fhir/us/core/StructureDefinition/us-core-patient"))
(code:comment "invalid Patient against …/us-core-patient (FHIR R4 (4.0.1)):")
(code:comment "  Patient.identifier minimum required = 1, but found 0")
]

@racket[spec-package-path] finds a package by file name in the @tt{fhir-spec} package, in the
directories of @racket[current-package-directories], and in those the environment variable
@tt{FHIR_PACKAGE_PATH} names.}]

@section[#:tag "modules"]{Language files as modules}

Each of the family's languages is also a Racket language. Put the right first line on a file
(@tt{#lang fsh}, @tt{#lang fml}, @tt{#lang cql}, @tt{#lang vcl}) and a program can require it like
any module. The file is checked when the program is built, so a mistake in the map or the logic
stops the build at its line.

The quickest way to see this is the template:

@verbatim|{
$ raco fhir new pipeline my-pipeline
my-pipeline: the pipeline template (fsh/, fsh-invalid/, qr2patient.map, Intake.cql, main.rkt, qr.json, tests.rkt)
next: cd my-pipeline && raco test tests.rkt   (then: racket main.rkt qr.json)
$ cd my-pipeline
$ racket main.rkt qr.json
{
  "resourceType": "Patient",
  "name": [
    {
      "text": "Ana Rivera"
    }
  ],
  "gender": "female",
  "birthDate": "1950-05-01"
}
65 or older: true
}|

It is a small program in three languages. An answered intake form (@tt{qr.json}) is turned into a
Patient by a map (@tt{qr2patient.map}), the Patient is held to a profile (@tt{fsh/intake.fsh}), and
a CQL library (@tt{Intake.cql}) answers a question about it. @tt{main.rkt} requires the three files
and calls what they provide. @tt{raco test tests.rkt} checks the whole thing. The template needs the
@tt{fhir-examples} package, where it lives.

@bold{Checking every file at once.} Building a program stops at the first file with a mistake. To
see all of them, run @tt{raco fhir check-files} in the folder. Here the map and the library each
have a typo:

@verbatim|{
$ raco fhir check-files
Intake.cql:6:15: cql compile error: in define "Age": unknown function 'AgeInYear' (did you mean `AgeInYears` or `AgeInYearsAt`?)
 6 | define "Age": AgeInYear()
   |               ^^^^^^^^^

qr2patient.map:14:49: fml check error: `gendr` is not an element of Patient (did you mean `gender`?)
 14 |   src.item as item where (linkId = 'gender') -> tgt.gendr = (item.answer.value.code) "gender";
    |                                                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

ok  fsh/intake.fsh
3 files checked, 2 with a problem: Intake.cql, qr2patient.map
}|

It reads the files that start with a @tt{#lang} line, in the folders you name or the current one.
It does not validate FSH examples against their profiles; that needs the whole project, and is
@tt{raco fsh check}.

@tt{raco fhir new tests} puts the template's @tt{tests.rkt} beside files you wrote yourself. The
whole route, with the functions each file provides, is one page: @tt{raco fhir guide racket}.

@section[#:tag "diagnostics"]{Reporting problems}

Every language in the family reports a problem as the same value, a @italic{diagnostic}: which
language, at what stage, how serious, the message, and the place. One value can then be shown three
ways.

@racketblock[
(require fhir/diagnostic)
(define d (diagnostic 'fsh 'compile 'error "`nmae` is not an element of Patient"
                      (loc "profiles.fsh" 4 3 40 4)))
(diagnostic->string d #:text source-text)
]

@verbatim{
profiles.fsh:4:3: fsh compile error: `nmae` is not an element of Patient
 4 | * nmae 1..1
   |   ^^^^
}

@racket[diagnostic->jsexpr] gives the same as JSON data (@tt{lang}, @tt{phase}, @tt{severity},
@tt{message}, @tt{source}, @tt{line}, @tt{column}), and @racket[diagnostics->operation-outcome]
gives a FHIR OperationOutcome with the line and column in FHIR's standard extensions. These are
what the tools print for @litchar{--format json} and @litchar{--format outcome}: the text form goes
to the error stream, the other two to standard output.

Lines and columns count from 1, as editors show them. A language that raises its problems raises
@racket[exn:fail:diagnostic], which Racket prints as the message alone, with no stack trace.

@section{In an editor, and for an AI agent}

@itemlist[
@item{@bold{In an editor.} The language server,
@hyperlink["https://oloveluck.github.io/fhir/fhir-lsp/index.html"]{fhir-lsp}, shows the same
diagnostics as you type. What a language offers an editor is a contract defined here
(@racketmodname[fhir/lang/support]), which each language package fulfils.}
@item{@bold{For an agent.} @hyperlink["https://oloveluck.github.io/fhir/fhir-mcp/index.html"]{fhir-mcp}
gives an agent a folder to work in, with tools to write, check, run and store. What a language
offers there is a second contract defined here (@tt{fhir/lang/workspace}). The guides
@tt{raco fhir guide} prints are the ones the agent reads; in the repository,
@tt{.claude/skills/} holds the same workflows for an agent using the command line.}]

@section[#:tag "limits"]{Limits}

@itemlist[
@item{@bold{Forms are for R6 only.} R4 and R5 can be read, written, navigated and validated; there
is no @tt{#lang fhir/r4} or @tt{fhir/r5} to write them as forms.}
@item{@bold{One FHIR version per program.} Types are registered by name, so two versions loaded
together would replace each other's.}
@item{@bold{JSON only.} FHIR's XML form is not read or written, here or anywhere in the family.}
@item{@bold{A mistake in a @tt{.fhir6} file is named, not located.} The message says which field
and which value are wrong; it does not give the line.}
@item{@bold{Fixed code lists.} A code is checked as the file builds only where FHIR requires a list
whose codes the specification itself spells out. A list defined by a rule, or one that draws on
another list, is not checked at that stage.}
@item{@bold{@hash-lang[] @tt{fhir/sd}} narrows how many values a field has. It does not write a
StructureDefinition resource; FHIR Shorthand does.}
@item{@bold{Snapshots.} Generating a snapshot merges the profile's changes over its base, places
named slices and expands the datatypes the profile reaches into. It does not handle a slice of a
slice, work out a discriminator that is not stated, expand the slices of a choice element, or follow
a @tt{contentReference}. @tt{raco fhir snapshot} reads the base from R5.}
@item{@bold{@tt{raco fhir roundtrip}} reads with the R6 types only.}]

@section[#:tag "words"]{Words used here}

@itemlist[
@item{@bold{Resource}: one FHIR document, such as a Patient or an Observation, written as JSON.}
@item{@bold{Element}, @bold{field}: one named part of a resource (@tt{gender}, @tt{birthDate}).}
@item{@bold{Datatype}: a structure used inside resources, such as HumanName or Quantity. A
@bold{primitive} is a single value with a fixed format: a date, a code, a decimal.}
@item{@bold{Choice element}: an element whose value may be one of several types, written with the
type in its name: @tt{deceasedBoolean}, @tt{valueQuantity}. The specification writes the family as
@tt{deceased[x]}.}
@item{@bold{Form}: a resource written in Racket's parenthesised notation, checked as it is built.}
@item{@bold{Typed node}: a resource as this package holds it in memory, knowing its type.}
@item{@bold{Tower}: the generated types of one FHIR version.}
@item{@bold{Profile}: rules a resource must follow in some setting, on top of FHIR's own. It is
itself a resource, a @bold{StructureDefinition}. Its @bold{differential} states only what it
changes; its @bold{snapshot} spells out every element after the changes.}
@item{@bold{Canonical url}: the web address that names a definition. It is a name; nothing needs to
be served there.}
@item{@bold{Package}, @bold{Implementation Guide} (IG): a published set of profiles, value sets and
examples for one purpose, distributed as a @tt{.tgz} file. FHIR's own definitions come as a package
too, the @italic{core} package.}
@item{@bold{Value set}: a named set of codes. A @bold{required binding} is FHIR's rule that an
element's code must come from one.}
@item{@bold{Operation}: a named service FHIR defines, written with a dollar sign. Its
@bold{OperationDefinition} is the resource that states its inputs and outputs.}
@item{@bold{OperationOutcome}: FHIR's resource for reporting problems. @bold{Parameters}: its
resource for passing named values in and out of an operation. @bold{Bundle}: a resource that holds
other resources.}
@item{@bold{Diagnostic}: one problem, with its place, as the family's tools report it.}
@item{@bold{Module}, @bold{@tt{#lang}}: a Racket file other files can require; the first line of a
file names the language it is written in.}]

@section[#:tag "tested"]{How it is tested}

Against what HL7 publishes, not only its own examples:

@itemlist[
@item{Every resource in the R5 and R4 core packages is read into the typed model and written back
unchanged: 2968 and 4581 resources, and HL7's 77 and 72 test examples. @tt{raco fhir roundtrip-tck}
runs it.}
@item{Every example two published guides ship (US Core 9.0.0 and the International Patient Summary
2.0.1) reads and writes back: 274 of 274.}
@item{Generated snapshots are compared, element by element, with the ones HL7's test cases expect:
80 of 80 paths, 476 of 478 cardinalities, 235 of 236 types.}
@item{The generated types are regenerated and compared byte for byte with what is committed
(@tt{raco fhir check}).}]

The repository's @tt{TESTING.md} has the whole table for this repository's packages, and names the
cases that differ.

@section{Reference}

@subsection[#:style 'unnumbered]{@hash-lang[] @tt{fhir/r6}}
@defmodulelang[fhir/r6]

Provides @racket[resources], @racket[(->nodes)] and @racket[(->json)], as above; the form macros are
the R6 types from @tt{fhir/r6/types}.

@subsection[#:style 'unnumbered]{@hash-lang[] @tt{fhir/sd}}
@defmodulelang[fhir/sd]

@defform[(profile Name #:base Base (field min max) ...)]{
Defines and provides the form @racket[Name]: @racket[Base]'s form with the given fields' number of
values narrowed (@racket[max] is a number or @racket[*]). @racket[Base] is an R6 type or an earlier
profile. A rule that loosens the base is a compile error; the value a profile's form builds is the
base resource.}

@subsection[#:style 'unnumbered]{@tt{fhir/result/result}}
@defmodule[fhir/result/result]

Validation returns data, not exceptions. Every error carries the spec url of the rule.

@deftogether[(@defstruct*[ok ([value any/c])] @defstruct*[err ([error any/c])] @defproc[(result? [v any/c]) boolean?])]
@defstruct*[validation-error ([type symbol?] [spec-url (or/c string? #f)])]{
The base of @racket[pattern-mismatch], @racket[out-of-range], @racket[length-exceeded],
@racket[precision-exceeded], @racket[invalid-encoding], @racket[unknown-field], @racket[missing-field]
and @racket[multiple] (a list of errors).}
@deftogether[(
@defproc[(result-map [f (-> any/c any/c)] [r result?]) result?]
@defproc[(result-bind [r result?] [f (-> any/c result?)]) result?]
@defproc[(result-traverse [rs (listof result?)] [#:accumulate? accumulate? boolean? #f]) result?])]{
Functor, monad, sequence; with @racket[accumulate?] every error is collected into a
@racket[multiple] instead of the first short-circuiting.}
@defproc[(ok-or-raise [r result?]) any/c]{The value, or an error.}
@defproc[(validation-error-message [e validation-error?]) string?]

@subsection[#:style 'unnumbered]{@tt{fhir/model/node}}
@defmodule[fhir/model/node]

@defstruct*[fhir ([type symbol?] [fields hash?])]{
The one in-memory value: a type and the fields present (a single value, or a list for a repeating
field). Primitives inside it are the structs of @tt{fhir/primitives/primitives}.}
@defproc[(fhir-ref [node fhir?] [field symbol?] [default any/c #f]) any/c]
@defproc[(fhir-has? [node fhir?] [field symbol?]) boolean?]
@defproc[(fhir-field-names [node fhir?]) (listof symbol?)]

@subsection[#:style 'unnumbered]{@tt{fhir/model/leaf}}
@defmodule[fhir/model/leaf]

@defproc[(pv [v any/c]) any/c]{A primitive's value; anything else passes through.}
@defproc[(listify [v any/c]) list?]{A repeating field's value as a list, always.}
@defproc[(node-str [node fhir?] [field symbol?]) (or/c string? #f)]{A leaf rendered as a string, or @racket[#f].}

@subsection[#:style 'unnumbered]{@tt{fhir/model/registry}}
@defmodule[fhir/model/registry]

Every FHIR type knows the spec that defines it. Loading a tower registers its types; the registry
is what @racket[from-json], the form macros, FHIRPath's type system and the validator consult.

@defstruct*[fhir-spec ([name string?] [url string?] [constraint any/c])]
@defstruct*[type-info ([spec fhir-spec?] [schema any/c] [predicate any/c] [constructor any/c])]
@deftogether[(
@defproc[(type-registered? [type symbol?]) boolean?]
@defproc[(type-spec-of [type symbol?]) (or/c fhir-spec? #f)]
@defproc[(type-schema-of [type symbol?]) any/c]
@defproc[(type-predicate-of [type symbol?]) (or/c procedure? #f)]
@defproc[(type-constructor-of [type symbol?]) (or/c procedure? #f)]
@defproc[(all-types) (listof symbol?)])]{Complex types and resources.}
@deftogether[(
@defproc[(pin-registered-types!) void?]
@defproc[(unpin-registered-types!) void?])]{
Types are registered by name. Pinning keeps the types registered now against later registrations
of the same names (a new name is still added): a process that holds one FHIR version and then
loads a module built over another keeps its own Patient and Observation. Unpin before loading
another tower on purpose.}
@deftogether[(
@defproc[(primitive-name? [name symbol?]) boolean?]
@defproc[(spec-of [name symbol?]) (or/c fhir-spec? #f)]
@defproc[(predicate-of [name symbol?]) (or/c procedure? #f)]
@defproc[(constructor-of [name symbol?]) (or/c procedure? #f)]
@defproc[(registered-names) (listof symbol?)])]{Primitives.}
@deftogether[(
@defproc[(element-spec-of [path string?]) (or/c fhir-spec? #f)]
@defproc[(registered-element-paths) (listof string?)])]{Elements by path.}

@subsection[#:style 'unnumbered]{@tt{fhir/primitives/primitives}}
@defmodule[fhir/primitives/primitives]

The 21 FHIR primitive types, each a struct with @racket[id], @racket[extension] and @racket[value],
a validating constructor and a JSON writer: @racket[fhir-string], @racket[make-string],
@racket[fhir-date], @racket[make-date], and so on for @tt{id}, @tt{code}, @tt{markdown}, @tt{uri},
@tt{url}, @tt{canonical}, @tt{oid}, @tt{uuid}, @tt{base64Binary}, @tt{xhtml}, @tt{boolean},
@tt{integer}, @tt{integer64}, @tt{positiveInt}, @tt{unsignedInt}, @tt{decimal} (string-backed, so
precision survives; its constructor takes the text or a Racket real), @tt{time}, @tt{dateTime} and
@tt{instant}. @racket[(make-date "1974-13-40")] is an @racket[err] naming the pattern and its spec
url. A date, dateTime or instant is also held to the calendar: @racket[(make-date "1974-02-30")] is
an @racket[out-of-range] error, since that February has 28 days. The module re-exports the results,
the registry and the temporal structs @racket[t-date], @racket[t-time] and @racket[t-datetime]
(components and a precision).

@defproc[(primitive->jsexpr [p primitive-type?]) (or/c string? boolean? real? 'null)]
@defproc[(temporal->string [t any/c]) string?]

@tt{fhir/primitives/literals} provides @racket[(lit date "1974-12-25")]: a primitive literal
validated at compile time.

@subsection[#:style 'unnumbered]{@tt{fhir/serialize/from-json}}
@defmodule[fhir/serialize/from-json]

@defproc[(from-json [js any/c] [#:type type (or/c symbol? #f) #f] [#:lenient? lenient? boolean? #f]) result?]{
FHIR JSON to a typed node, driven by the registered schema. A resource carries its
@tt{resourceType}; a bare datatype needs @racket[type]. Strict by default: an unknown element is an
@racket[err]. Lenient parsing skips unknown keys and drops fields that do not parse, and never
raises, so data from a newer FHIR version still loads.}

@subsection[#:style 'unnumbered]{@tt{fhir/serialize/lenient}}
@defmodule[fhir/serialize/lenient]

What a lenient read left out. A Drop is a list of a path and the value there:
@racket['("birthDate" "25/12/1974")].

@defproc[(lenient-drops [js any/c] [node fhir?]) (listof (list/c string? any/c))]{
The values of the JSON that the node read from it does not hold.}
@defproc[(drop->string [drop (list/c string? any/c)]) string?]{@tt{birthDate ("25/12/1974")}.}
@defproc[(drops-message [drops (listof (list/c string? any/c))] [type string?]) string?]{
One sentence for a warning: the drops, then why they were not read (the calendar's reason for a
date its month lacks; else "not a valid value, or not an element of" the type).}

@subsection[#:style 'unnumbered]{@tt{fhir/serialize/to-json}}
@defmodule[fhir/serialize/to-json]

@defproc[(node->jsexpr [node fhir?]) jsexpr?]{The structured view: decimals as numbers.}
@defproc[(node->json-string [node fhir?]) string?]{Precise text: decimals as the tokens they were read as, so @racket["1.50"] survives.}

@subsection[#:style 'unnumbered]{@tt{fhir/serialize/fhir-json}}
@defmodule[fhir/serialize/fhir-json]

FHIR JSON written as FHIR documents are: @tt{resourceType}, @tt{id} and @tt{meta} first, then each
element in the order its type lists it (read from the core package's definition when one is at
hand, else from the loaded tower, else by name), a primitive's @tt{_x} companion after @tt{x}.

@defproc[(fhir-json->string [js jsexpr?] [#:indent indent (or/c #f exact-nonnegative-integer?) #f]) string?]{Compact, or indented by @racket[indent] spaces.}
@defproc[(write-fhir-json [js jsexpr?] [out output-port? (current-output-port)] [#:indent indent (or/c #f exact-nonnegative-integer?) #f]) void?]
@defproc[(key-order [keys (listof symbol?)]) (listof symbol?)]{@tt{resourceType}, @tt{id}, @tt{meta}, then the rest by name: the order used when the type is not known.}

@subsection[#:style 'unnumbered]{@tt{fhir/serialize/read-json}}
@defmodule[fhir/serialize/read-json]

A JSON reader that keeps each number's lexeme in a @racket[jnum], so decimals round-trip.

@defstruct*[jnum ([lexeme string?])]
@defproc[(read-fhir-json [in input-port?]) any/c]
@defproc[(read-fhir-json/duplicates [in input-port?]) (values any/c (listof string?))]{Also the dotted paths of duplicate object keys the reader collapsed.}
@defproc[(string->fhir-jsexpr [s string?]) any/c]
@defproc[(jnum-value [n jnum?]) real?]
@defproc[(strip-jnum [v any/c]) any/c]{A plain jsexpr.}

@subsection[#:style 'unnumbered]{@tt{fhir/package}}
@defmodule[fhir/package]

@defproc[(read-package [tgz path-string?] [#:exact-decimals? exact-decimals? boolean? #f] [#:select select (-> string? any/c) (lambda (f) #t)])
         (values (or/c hash? #f) (listof (cons/c string? hash?)) (listof (cons/c string? hash?)))]{
A FHIR NPM package: its manifest, its resources (@tt{package/*.json}) and its examples
(@tt{package/example/*.json}), each as @racket[(cons file-name resource)]. @racket[select] filters by
file name before parsing.}

@subsection[#:style 'unnumbered]{@tt{fhir/spec-package}}
@defmodule[fhir/spec-package]

@defproc[(spec-package-path [file string?] [#:optional? optional? boolean? #f]) (or/c path? #f)]{
A package by file name (@racket["hl7.fhir.r5.core.tgz"]): @racket[current-package-directories] first,
then the @tt{fhir-spec} collection, the directories @tt{FHIR_PACKAGE_PATH} names, and
@tt{share/fhir-packages} beside a standalone tool. Missing is an error unless @racket[optional?].}
@defparam[current-package-directories dirs (listof path-string?)]{Directories of packages searched before @tt{fhir-spec}, for fetched IGs.}
@defproc[(spec-package-available?) boolean?]{Is @tt{fhir-spec} installed.}

@subsection[#:style 'unnumbered]{@tt{fhir/canonical}}
@defmodule[fhir/canonical]

A canonical may carry a version after a bar: @racket["http://example.org/StructureDefinition/bp|1.0"].

@defproc[(canonical-url [canonical string?]) string?]{The part before the first @litchar{|}; all of it when there is none.}
@defproc[(canonical-version [canonical string?]) (or/c string? #f)]{The part after it, or @racket[#f].}

@subsection[#:style 'unnumbered]{@tt{fhir/suggest}}
@defmodule[fhir/suggest]

The "did you mean" every tool appends to a message about a name it does not know.

@defproc[(closest-names [name string?] [candidates (listof string?)] [#:limit limit exact-positive-integer? 3]) (listof string?)]{
The candidates near enough to be what was meant, closest first; none when nothing is near.}
@defproc[(did-you-mean [name string?] [candidates (listof string?)]) string?]{
@racket[" (did you mean `gender`?)"], ready to append to a message, or @racket[""].}

@subsection[#:style 'unnumbered]{@tt{fhir/sd/sd-index}}
@defmodule[fhir/sd/sd-index]

@defparam[current-sd-packages packages (or/c #f (listof path-string?))]{
The packages (.tgz) profiles, value sets and code systems resolve from, in priority order: an IG, its
dependencies, then core. @racket[#f] means @tt{fhir-spec}'s R5 core. The validator, the terminology
service and the FSH compiler all read it.}
@defproc[(resolve-sd-raw [ref string?]) (or/c hash? #f)]{A StructureDefinition by canonical (a @tt{|version} is dropped), name, id or bare type code.}
@defproc[(resolve-canonical-raw [type (or/c "CodeSystem" "ValueSet" "StructureDefinition" "StructureMap" "ConceptMap")] [ref string?]) (or/c hash? #f)]{
A resource of one of these types by url, name or id. A package is indexed lazily: a resource is
parsed when a lookup first reaches it.}
@defproc[(sd-context) (listof path?)]{The effective package list: a cache key.}
@defproc[(sd-index-available?) boolean?]

@subsection[#:style 'unnumbered]{@tt{fhir/sd/snapshot}}
@defmodule[fhir/sd/snapshot]

@defproc[(generate-snapshot [sd hash?]) list?]{
The snapshot elements of a profile: the base's snapshot re-rooted, the differential merged element by
element (constraints accumulate), named slices re-rooted, datatypes the profile dives into expanded.
With no resolvable base, the differential.}
@defproc[(shipped-snapshot [sd hash?]) (or/c #f (listof hash?))]{The snapshot elements a StructureDefinition already carries, or @racket[#f]: generate one.}
@defproc[(snapshot-paths [elements list?]) list?]
@defproc[(opaque-type? [type string?]) boolean?]{The framework types no snapshot describes usefully: Resource, DomainResource, Element, BackboneElement, Extension.}

@subsection[#:style 'unnumbered]{@tt{fhir/sd/element-index}}
@defmodule[fhir/sd/element-index]

@defproc[(make-element-index [elements (listof hash?)]) element-index?]{O(1) lookups over a snapshot.}
@deftogether[(
@defproc[(element-index? [v any/c]) boolean?]
@defproc[(index-elements [ix element-index?]) (listof hash?)]
@defproc[(index-root [ix element-index?]) (or/c hash? #f)]
@defproc[(child-elements [ix element-index?] [path string?]) (listof hash?)]
@defproc[(slices-of [ix element-index?] [path string?]) (listof hash?)]
@defproc[(index-by-id [ix element-index?] [id string?]) (or/c hash? #f)])]
@defproc[(type-index [type string?]) (or/c element-index? #f)]{A type code's snapshot index, cached per @racket[sd-context].}

The module also provides @racket[opaque-type?], from @tt{fhir/sd/snapshot}.

@subsection[#:style 'unnumbered]{@tt{fhir/sd/operations}}
@defmodule[fhir/sd/operations]

@defthing[$snapshot procedure?]{@tt{StructureDefinition/$snapshot} as an operation: @racket[($snapshot sd)] or @racket[(apply-operation "$snapshot" #:url canonical)].}
@defproc[(resolve-structure-definition [canonical string?]) (or/c hash? #f)]{
A StructureDefinition by canonical: the current data source, then the registry, then the packages.}

@subsection[#:style 'unnumbered]{@tt{fhir/sd/logical}}
@defmodule[fhir/sd/logical]

A StructureDefinition registered as a type at run time. The towers register FHIR's own types; a
@italic{logical model} (a guide's own data model) is a StructureDefinition they never saw.

@defproc[(register-structure-definition! [sd hash?] [#:resolve resolve (-> string? (or/c hash? #f)) resolve-structure-definition/data]) (or/c symbol? #f)]{
Registers the definition's type, with a nested type for each element that has children, so that
@racket[from-json], FHIRPath, the validator and the languages treat its instances as typed nodes.
Answers the type's name.}
@defproc[(structure-definition-type [sd hash?]) (or/c symbol? #f)]{The type's name, without registering.}
@defproc[(resolve-structure-definition/data [url string?]) (or/c hash? #f)]{The current data source, the registry, then the packages.}

@subsection[#:style 'unnumbered]{@tt{fhir/operation}}
@defmodule[fhir/operation]

A FHIR operation is an OperationDefinition plus an implementation, with nothing about HTTP: a
procedure whose keyword arguments are the definition's parameters. Applying is
@racket[(op subject #:name value ...)]: the subject is the resource the operation applies to, a
Parameters resource may carry inputs, a list gives several values; strings are converted for
integer, decimal and boolean parameters; an unknown keyword is an error listing the parameters. The
result is the @tt{return} resource, or a Parameters of the outputs. The packages register their
operations when loaded: @tt{$validate} and @racket[ensure-valid] (fhir-validation), @tt{$expand},
@tt{$validate-code}, @tt{$lookup}, @tt{$translate} (fhir-tx), @tt{$transform} (fml),
@tt{$evaluate-measure} (cql), @tt{$sql-run} (sql-on-fhir), @tt{$snapshot} (here).

@racketblock[
(apply-operation "StructureMap/$transform" qr #:srcMap fml)
(define transform (operation "StructureMap/$transform"))
(~> qr (transform #:srcMap fml) (ensure-valid) ($snapshot))]

@defproc[(operation [ref (or/c string? hash? operation?)]) operation?]{
A reference resolved to a procedure: a canonical url, an OperationDefinition, @racket["$code"], or
@racket["Type/$code"] when a code is ambiguous.}
@deftogether[(
@defproc[(apply-operation [ref any/c] [subject any/c] ... [#:name value any/c] ...) hash?]
@defproc[(apply-operation/outcome [ref any/c] [subject any/c] ... [#:name value any/c] ...) hash?])]{
Apply by reference; the second returns a failure's OperationOutcome instead of raising.}
@defform[(~> expr (proc arg ...) ...)]{Threads a value: each form receives the previous value as its first argument.}
@defstruct*[(exn:fail:operation exn:fail:user) ([outcome hash?])]{
What a failure raises. A user error: uncaught, Racket prints its message alone.}
@defproc[(make-operation [definition hash?] [run (-> hash? any/c any/c)] [#:subject subject (or/c string? #f) #f]) operation?]{
An implementation: @racket[run] takes the inputs (name to a list of values) and the subject.
@racket[subject] names the input the subject fills (@racket["resource"] for @tt{$validate}), or
@racket[#f] when the operation applies to the subject itself.}
@defproc[(register-operation! [op operation?]) void?]{Makes it resolvable by its canonical.}
@defproc[(registered-operations) (listof operation?)]
@defproc[(add-operation-loader! [load (-> any)]) void?]{
A thunk that registers operations (by requiring the modules that implement them), run once, the
first time an operation is looked up. For a host that offers many operations and should load a
module only when a call needs it.}
@deftogether[(
@defproc[(operation? [v any/c]) boolean?]
@defproc[(operation-definition [op operation?]) hash?]
@defproc[(operation-code [op operation?]) string?]
@defproc[(operation-url [op operation?]) (or/c string? #f)]
@defproc[(operation-subject [op operation?]) (or/c string? #f)]
@defproc[(operation-levels [op operation?]) (listof (or/c 'system 'type 'instance))]
@defproc[(operation-resource-types [op operation?]) (listof string?)])]
@defproc[(invoke [op operation?] [subject any/c] [inputs hash?]) hash?]{The host form: a server's request Parameters as an inputs hash.}
@defproc[(input [inputs hash?] [name string?] [default any/c]) any/c]{For implementations: the first value given for a name.}
@defproc[(operation-error [issue-code string?] [format string?] [arg any/c] ...) none/c]{Raises @racket[exn:fail:operation].}
@deftogether[(
@defproc[(outcome [severity string?] [code string?] [diagnostics string?]) hash?]
@defproc[(outcome-errors? [outcome hash?]) boolean?]
@defproc[(parameters->inputs [parameters hash?]) hash?]
@defproc[(outputs->parameters [op operation?] [outputs hash?]) hash?])]

@subsection[#:style 'unnumbered]{@tt{fhir/data-source}}
@defmodule[fhir/data-source]

Where an operation's data comes from, independent of any server.

@defstruct*[data-source ([all procedure?] [read procedure?] [of-patient procedure?] [search (or/c procedure? #f)])]{
@racket[all] is @tt{type -> resources}, @racket[read] is @tt{type id -> resource | #f},
@racket[of-patient] is @tt{type patient-id -> resources}, @racket[search] takes a type and
parameters, or is @racket[#f]. Resources are FHIR JSON. fhir-server's @tt{store->data-source} gives
one with real search.}
@defparam[current-data-source source data-source?]{What operations read; @racket[empty-data-source] by default.}
@defproc[(resources->data-source [resources (listof hash?)]) data-source?]{In memory; Bundles contribute their entries.}
@defproc[(directory->data-source [dir path-string?]) data-source?]{Every @tt{.json} under it, read once.}
@defthing[empty-data-source data-source?]
@defproc[(patient-reference-of [resource hash?]) (listof string?)]{The @tt{Patient/id} references in @tt{patient}, @tt{subject}, @tt{beneficiary} and @tt{individual}.}
@defproc[(bundle-resources [bundle hash?]) (listof hash?)]{A Bundle's entries, nested Bundles flattened; any other resource as itself.}

@subsection[#:style 'unnumbered]{@tt{fhir/rest-data-source}}
@defmodule[fhir/rest-data-source]

A FHIR server's REST API as a data source. A Header is a string, @racket["Name: value"].

@defproc[(rest->data-source [base-url string?] [#:headers headers (listof string?) '()] [#:page-size page-size exact-positive-integer? 200]) data-source?]{
Read-only. @racket[all] and @racket[search] page through searchsets, following each Bundle's
@tt{next} link; @racket[read] is @tt{GET [base]/Type/id}; @racket[of-patient] searches by the
type's @tt{patient} parameter, else @tt{subject}, else reads every resource of the type and keeps
the patient's.}
@defproc[(rest-write! [base-url string?] [resource hash?] [#:headers headers (listof string?) '()]) (values exact-integer? (or/c hash? #f))]{
@tt{PUT [base]/Type/id} when the resource has an id, @tt{POST [base]/Type} when it has none: the
status, and the resource or OperationOutcome the server answered.}
@defproc[(rest-url? [s string?]) boolean?]{An http or https url.}

@subsection[#:style 'unnumbered]{@tt{fhir/registry}}
@defmodule[fhir/registry]

The module system as the FHIR registry. A @hash-lang[] @tt{fsh} module registers its profiles, value
sets and code systems when it is instantiated, a @hash-lang[] @tt{vcl} module its value set, a
@hash-lang[] @tt{fml} module its StructureMap, a @hash-lang[] @tt{cql} module its Library; every
resolver in the family looks here between the current data source and the packages (profiles for
@tt{#:profile} and @tt{meta.profile}, a map's @tt{uses}, the terminology resolver,
@tt{$transform #:source}), so requiring a module is enough for what it defines to be found by
canonical, with no data source to set up. A @hash-lang[] @tt{fhir/r6} file's resources are data, not
definitions, and are not registered.

@defproc[(register-resources! [resources (listof hash?)] [#:source source any/c #f]) void?]{
Registers each resource with a @tt{url} or an @tt{id} under its kind. A canonical already registered
with different content by another source is an error naming both; the same content again is
accepted, and a source may redefine its own. Ids are not checked: the latest registration wins.}
@defproc[(registered-resource [kind string?] [url-or-id string?]) (or/c hash? #f)]{A @tt{|version} suffix is ignored.}
@defproc[(registered-resources [kind string?]) (listof hash?)]
@defproc[(registered-source [kind string?] [url-or-id string?]) any/c]
@defproc[(registered-kinds) (listof string?)]
@defproc[(registered-by [source? (-> any/c any/c)]) (listof hash?)]{Everything the sources the predicate accepts registered, each once, by kind then url or id.}
@defproc[(unregister-source! [source any/c]) void?]{Forgets everything one source registered (a file that changed or went away).}

@subsection[#:style 'unnumbered]{@tt{fhir/parallel}}
@defmodule[fhir/parallel]

@defproc[(parallel-map [fn (list/c module-path? symbol?)] [items list?]
                       [#:workers workers exact-positive-integer? (default-workers)]
                       [#:setup setup (or/c module-path? #f) #f]) list?]{
Maps the function @racket[fn] names (a module path and an export) over @racket[items] on every
core and answers the results in order. The workers are @tt{racket} processes of their own (threads
share one core, and places share one heap, whose collections stop every place), so the function is
named, not passed: each worker instantiates @racket[setup] (a type tower, say) and then the
function's module. Items and results are written and read as S-expressions, so they must be
readable data; the sharing wins when what crosses is small next to the work — hand a worker a path
or a shard number rather than the data. Items are dealt one at a time as workers finish. With one
worker, or in a standalone build of the tools (where there is no @tt{racket} to start workers on),
the function runs in-process.}
@defproc[(default-workers) exact-positive-integer?]{One per core, or @tt{FHIR_WORKERS} from the environment (1 keeps everything in-process).}

@subsection[#:style 'unnumbered]{@tt{fhir/diagnostic}}
@defmodule[fhir/diagnostic]

Every language reports errors as one value, rendered three ways: text with the source line and a
caret, JSON, or a FHIR OperationOutcome with the standard line, column and source extensions. The
CLIs take @litchar{--format text|json|outcome}.

@defstruct*[loc ([source any/c] [line exact-integer?] [column exact-integer?] [position exact-integer?] [span exact-integer?]) #:prefab]{1-based line and column.}
@defstruct*[diagnostic ([lang symbol?] [phase symbol?] [severity (or/c 'error 'warning)] [message string?] [loc (or/c loc? #f)]) #:prefab]{
@racket[lang] names the language or tool: @racket['fsh], @racket['cql], @racket['fhirpath],
@racket['vcl], @racket['fml], @racket['sql-on-fhir], @racket['ig], @racket['capability],
@racket['fhir]. @racket[phase] is the stage that found the problem: @racket['lex], @racket['parse],
@racket['compile], @racket['check], @racket['validate], @racket['run] and a few a language adds
of its own.}
@defstruct*[(exn:fail:diagnostic exn:fail:user) ([diagnostic diagnostic?])]{
The carrier FSH and FHIRPath raise; it has @racket[prop:exn:srclocs]. A user error: a @tt{#lang}
build that fails with one prints its line, with no stack trace.}
@defproc[(raise-diagnostic [d diagnostic?]) any]{Raises it, with the source line and a caret in the message when the source file can be read.}
@defproc[(exn->diagnostic [e exn?] [lang symbol?] [#:phase phase symbol? 'parse] [#:source source any/c #f]
                          [#:line-offset line-offset exact-integer? 0] [#:last-position last-position (or/c exact-integer? #f) #f]
                          [#:unit unit string? "input"] [#:ran-out? ran-out? (-> any/c) (lambda () #f)]) diagnostic?]{
A parser's exception as a diagnostic: brag's message becomes words, and when the failure sits on the
last token a probe tells whether the input ran out ("the entity ends after @tt{=}").}
@deftogether[(
@defproc[(diagnostic->string [d diagnostic?] [#:text text (or/c string? #f) #f]) string?]
@defproc[(diagnostic->jsexpr [d diagnostic?]) hash?]
@defproc[(diagnostics->operation-outcome [ds (listof diagnostic?)]) hash?])]{The three renderings; with @racket[text], the source line and a caret.}
@defproc[(emit-diagnostics [ds (listof diagnostic?)] [#:format format (or/c 'text 'json 'outcome) 'text] [#:text-of text-of (-> any/c (or/c string? #f)) (lambda (s) #f)]) void?]{Text to stderr; JSON and outcome to stdout.}
@defproc[(format-flag [args (listof string?)]) (values (or/c 'text 'json 'outcome) (listof string?))]{Takes @litchar{--format} out of a command line.}
@deftogether[(
@defproc[(attach-diagnostic! [v any/c] [d diagnostic?]) any]
@defproc[(attached-diagnostic [v any/c]) (or/c diagnostic? #f)]
@defproc[(attach-loc! [v any/c] [l loc?]) any]
@defproc[(attached-loc [v any/c]) (or/c loc? #f)])]{Diagnostics and positions attached to values that are not exceptions (VCL's error payload, CQL's definitions).}
@deftogether[(
@defproc[(tokens->last-position [tokens list?] [position-of (-> any/c (or/c exact-integer? #f))]) (or/c exact-integer? #f)]
@defproc[(error-position [e exn?]) (or/c exact-integer? #f)])]

@subsection[#:style 'unnumbered]{@tt{fhir/check-files}}
@defmodule[fhir/check-files]

What @tt{raco fhir check-files} does, as functions.

@defproc[(language-file? [path path-string?]) boolean?]{A file the command checks, by extension: @tt{.fsh}, @tt{.map}, @tt{.fml}, @tt{.cql}, @tt{.vcl}.}
@defproc[(files-to-check [paths (listof path-string?)]) (listof path?)]{
The language files under each directory (recursively, @tt{compiled/} left out) and each file named,
in order; only those that start with a @tt{#lang} line.}
@defproc[(check-file [path path-string?]) (or/c string? (cons/c 'note string?) #f)]{
The file compiled on its own in a fresh namespace: its first problem as Racket reports it, a note
(an FSH file whose profile another folder defines), or @racket[#f] when it is clean.}

@subsection[#:style 'unnumbered]{@tt{fhir/lang/support}}
@defmodule[fhir/lang/support]

The contract a language keeps with an editor. Each language package provides, in its
@tt{<id>/support} module, one @racket[lang-support] value named @tt{support}; the language server
(@hyperlink["https://oloveluck.github.io/fhir/fhir-lsp/index.html"]{fhir-lsp}) finds it by that
name and knows nothing else about the language. A Position is @racket[(cons line character)],
counting from 0 as the protocol does.

@defstruct*[lang-support ([id string?] [diagnose procedure?] [project-files procedure?] [entities procedure?]
                          [hover procedure?] [definition procedure?] [complete procedure?])]{
@racket[id] is the language id and collection (@racket["fsh"]). @racket[diagnose] is
@tt{text path -> diagnostics}: every problem in the document. @racket[project-files] is
@tt{path -> paths}: the other files that belong with it. @racket[entities] is
@tt{text file -> entities}: its declarations. @racket[hover] is
@tt{project text position -> markdown | #f}, @racket[definition]
@tt{project text position -> entity | #f}, @racket[complete]
@tt{project text position -> completion items}.}
@defstruct*[entity ([kind string?] [name string?] [id (or/c string? #f)] [file string?] [line exact-nonnegative-integer?])]{
A declaration: its kind as the language names it (@racket["Profile"], @racket["define"],
@racket["group"]), its name, its id (an FSH @tt{Id:}, a map's url), and where it is (the line counts
from 0).}
@defstruct*[project ([path path-string?] [entities (listof entity?)] [text-of procedure?])]{
A document's project: its path, every declaration of the project's files, and @tt{path -> text} for
any of those files, as the editor holds them when they are open.}
@deftogether[(
@defthing[language-ids (listof string?)]
@defthing[extensions-by-language (hash/c string? (listof string?))]
@defproc[(language-id-of [path path-string?]) (or/c string? #f)])]{
The family's languages as data: @racket['("fsh" "cql" "fml" "vcl" "fhirpath")], each one's file
extensions, and the language of a file by its extension.}
@defproc[(language-support [id string?]) (or/c lang-support? #f)]{The language's support, loaded on first use; @racket[#f] when its package is not installed.}
@defparam[current-language-supports supports (hash/c string? lang-support?)]{Supports given by hand, consulted first: a test's stand-in, an embedder's own.}
@defproc[(installed-supports) (listof lang-support?)]
@defproc[(diagnose-safely [id string?] [support (or/c lang-support? #f)] [text string?] [path path-string?]) (listof diagnostic?)]{
Diagnoses through a support and never raises: a language that is not installed, or a support that
fails, is one diagnostic at the document.}
@defproc[(find-entity [entities (listof entity?)] [name string?]) (or/c entity? #f)]{By name, by id, or by a canonical's last segment.}
@deftogether[(
@defproc[(positionless [lang symbol?] [phase symbol?] [message string?] [source path-string?]) diagnostic?]
@defproc[(with-source [d diagnostic?] [source path-string?]) diagnostic?]
@defproc[(blank-lang-line [text string?]) string?]
@defproc[(line-of [text string?] [n exact-nonnegative-integer?]) (or/c string? #f)]
@defproc[(word-at [text string?] [position pair?]) (or/c string? #f)])]{
What supports share: an error diagnostic that names a file and no place; a diagnostic given a file
when it names none; a text with its @tt{#lang} line blanked (so line numbers stay true); a line of
a text; the name under the cursor.}

@subsection[#:style 'unnumbered]{Also in the package}

@itemlist[
@item{@tt{fhir/lang/workspace}: the contract a language keeps with an agent's workspace (what its
files define, running one, explaining an answer), and the reading of @tt{workspace.yaml}. The
@hyperlink["https://oloveluck.github.io/fhir/fhir-mcp/index.html"]{fhir-mcp} page describes the
workspace.}
@item{@tt{fhir/ig-config} and @tt{fhir/yaml}: the one reader of @tt{sushi-config.yaml}, the file
that states an Implementation Guide's address, version and dependencies. The
@hyperlink["https://oloveluck.github.io/fsh/"]{fsh} package re-exports both.}
@item{@tt{fhir/codegen/…}: the generator behind @tt{raco fhir regen}, which reads a package's
StructureDefinitions and writes a tower.}]
