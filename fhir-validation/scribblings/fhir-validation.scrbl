#lang scribble/manual
@; Text in @tt is shown exactly as written: no curly quotes, and "--" stays two hyphens.
@(require (only-in scribble/core [element literal-element]))
@(define (tt . text) (literal-element (quote tt) text))
@(require (for-label racket/base racket/contract
                     fhir/conformance/validate fhir/conformance/operations fhir/terminology/service))

@title{fhir-validation: checking FHIR resources}

Health data is exchanged as @hyperlink["https://hl7.org/fhir/"]{FHIR} @italic{resources}: a patient,
a lab result, a prescription, each a small JSON document. FHIR says exactly what each kind may
contain, and a receiving system will refuse one that breaks the rules: a misspelt field, a date that
is not a date, a code that is not among the allowed ones, a required field left out.

This package is the validator. You give it a resource, and it lists what is wrong and where. You can
also give it stricter rules of your own or of a published guide, and it holds the resource to those
too. The command is @tt{raco fhir-validate}.

Part of the @hyperlink["https://oloveluck.github.io/fhir/"]{fhir} family of FHIR languages and tools.

@table-of-contents[]

@section{What you can do with it}

@itemlist[
@item{@bold{Check one resource against FHIR's own rules}: @secref["first"].}
@item{@bold{Hold it to a profile}, a stricter set of rules for one setting ("every patient has an
identifier"): @secref["profiles"].}
@item{@bold{Hold it to a published Implementation Guide} such as US Core: @secref["ig"].}
@item{@bold{Decide how far to trust the answer}: an error is always real; a clean answer covers what
could be checked (@secref["trust"]).}
@item{@bold{Validate from a program}, or stop a pipeline at the first invalid resource:
@secref["program"].}]

@section[#:tag "first"]{A first example}

@bold{1. Install} the tools as the @hyperlink["https://oloveluck.github.io/fhir/"]{family's front
page} describes. The command is then @tt{raco fhir-validate} (or @tt{fhir-validate}, if you built
the standalone tools).

@bold{2. Have a resource.} Here it is a patient, in @tt{patient.json}:

@verbatim|{{"resourceType": "Patient", "id": "ann",
 "name": [{"family": "Lee", "given": ["Ann"]}],
 "gender": "female", "birthDate": "1974-12-25"}}|

@bold{3. Check it.}

@verbatim{
$ raco fhir-validate patient.json --format text
patient.json: information informational: All OK
}

Nothing was found. @litchar{--format text} asks for one line per finding, for a person to read;
without it the same answer comes as a FHIR @italic{OperationOutcome}, the JSON document FHIR uses to
report problems, for a program to read (@secref["cli"]).

@bold{4. Make two mistakes.} Write the gender in French and give February thirty days
(@tt{bad.json}):

@verbatim|{{"resourceType": "Patient", "id": "ann",
 "name": [{"family": "Lee", "given": ["Ann"]}],
 "gender": "femme", "birthDate": "1974-02-30"}}|

@verbatim{
$ raco fhir-validate bad.json --format text
bad.json: error code-invalid at Patient.gender: code `femme` not in required value set http://hl7.org/fhir/ValueSet/administrative-gender; it holds female, male, other, unknown
bad.json: error invalid at Patient.birthDate: '1974-02-30' is not a valid date (February 1974 has 28 days)
}

Both are found in one run, each with the place and the reason. The command exits with 1 because
there is an error, so a script can stop on it.

@section[#:tag "reading"]{Reading an issue}

Every finding is called an @italic{issue}, and every issue line has the same five parts. Take the
first line above:

@tabular[#:style 'boxed #:sep @hspace[2]
(list (list @bold{part} @bold{here} @bold{what it is})
      (list "file" @tt{bad.json} "the file that was checked")
      (list "severity" @tt{error} @elem{how serious: @tt{error}, @tt{warning} or @tt{information} (@secref["severity"])})
      (list "kind" @tt{code-invalid} "the kind of rule that was broken, from FHIR's own list (below)")
      (list "place" @tt{at Patient.gender} @elem{the element, as a path from the top of the resource})
      (list "message" @elem{@tt{code `femme` not in …}} "what was found, the rule, and often what to write instead"))]

The place is a dotted path: @tt{Patient.contact} is the @tt{contact} element of the patient,
@tt{Observation.component.value[x].code} the code of the value of a component (@tt{value[x]} is how
FHIR writes "the value, whichever type it has": @tt{valueQuantity}, @tt{valueString} …). A problem
inside a nested part may be named from that part: @tt{Narrative.div} for the text of any resource,
@tt{Observation.status} for an Observation contained in a Patient.

The kinds you will meet:

@tabular[#:style 'boxed #:sep @hspace[2]
(list (list @bold{kind} @bold{meaning} @bold{example message})
      (list @tt{structure} "an element FHIR does not define there, or an unknown resource type"
            @elem{@tt{element 'birthdate' is not defined at Patient (did you mean `birthDate`?)}})
      (list @tt{required} "too few or too many of an element"
            @elem{@tt{minimum required = 1, but found 0}})
      (list @tt{invalid} "a value in the wrong form: a date, a number, an id; a JSON key written twice"
            @elem{@tt{'1974-02-30' is not a valid date (February 1974 has 28 days)}})
      (list @tt{value} "a value other than the one a profile fixes"
            @elem{@tt{value does not match fixed value true}})
      (list @tt{code-invalid} "a code outside the set of codes allowed there; a unit that is not a UCUM unit"
            @elem{@tt{code `femme` not in required value set …}})
      (list @tt{invariant} "a rule that relates several elements"
            @elem{@tt{pat-1: SHALL at least contain a contact's details or a reference to an organization (found no name; no telecom; no address; no organization)}}))]

An @italic{invariant} is a rule FHIR or a profile writes as a formula over the resource, with a short
key (@tt{pat-1}) and a sentence for people. When one is broken, the message gives the key, the
sentence, and in parentheses what the validator found in the elements the rule looks at, so you can
see which part failed:

@verbatim{
obs.json: error invariant at Observation: obs-6: dataAbsentReason SHALL only be present if Observation.value[x] is not present (found dataAbsentReason = not measured; value = 72 '/min')
}

@section[#:tag "severity"]{Errors and warnings}

An @bold{error} means the resource breaks a rule: it is not valid. A @bold{warning} means something
is probably wrong, but the resource is still valid. An @bold{information} line is only the
"All OK" you get when nothing was found.

Here is a blood-pressure reading whose unit is written the common way, @tt{mmHg}. FHIR quantities
name their units in @hyperlink["https://ucum.org"]{UCUM}, the standard for unit codes, and UCUM
writes millimetres of mercury as @tt{mm[Hg]}:

@verbatim{
$ raco fhir-validate bp.json --fhir-version 4.0.1 --format text
bp.json: warning code-invalid at Observation.component.value[x].code: `mmHg` is not a UCUM unit (mercury is written mm[Hg])
}

It is a warning, not an error, because published examples from HL7 itself contain such units; a
system that computes with the value will still stumble on it, so fix it. Warnings come from two
places: a unit that is not a UCUM unit, and an invariant that its author marked as a warning.

The exit code follows errors only: 0 when there is none (warnings or not), 1 when there is at least
one, 2 when the command was called wrongly.

@section[#:tag "valid"]{What "valid" means}

A resource is valid when it follows two sets of rules.

@bold{FHIR's own rules for its type.} Every Patient, whoever sends it, must be a Patient as FHIR
defines one. The validator checks:

@itemlist[
@item{that @tt{resourceType} names a real type (@tt{`Observaton` is not a resource type (did you
mean `Observation`?)});}
@item{that every element is one the type has, spelt and capitalised as FHIR does;}
@item{how many of each element there are: a required one is present, a single one is not a list;}
@item{that each value has the form of its type: a date is a real calendar date, a decimal a number
and not a string, an id only the characters an id may have;}
@item{that a value written under a choice (@tt{valueQuantity}, @tt{valueString} …) is of a type the
element allows;}
@item{that a code is in the value set where FHIR requires one (a @italic{required binding}:
@tt{gender} must be female, male, other or unknown);}
@item{the type's invariants;}
@item{that the JSON itself is sound: no key written twice, nothing malformed.}]

@bold{The rules of each profile it is held to.} A @italic{profile} narrows a type for one setting:
it makes optional elements required, fixes values, restricts codes, adds invariants. A resource is
held to a profile in two ways: it @italic{claims} the profile by listing the profile's address in
its @tt{meta.profile}, or you name the profile when you validate. Either way the checks are the same
as above, with the profile's stricter answers, plus:

@itemlist[
@item{values a profile fixes or gives a pattern for;}
@item{@italic{slices}: a profile can say that a repeating element must contain particular entries,
told apart by a value. A blood pressure must have one component coded systolic and one coded
diastolic; an entry that matches a slice is held to that slice's own rules.}]

@section[#:tag "profiles"]{Checking against a profile}

A profile is itself a FHIR resource, a @italic{StructureDefinition}, so on the command line it is a
JSON file. Give it after the resource. This is the US Core Patient profile, which requires an
identifier, and the patient from the first example has none:

@verbatim{
$ raco fhir-validate patient.json StructureDefinition-us-core-patient.json --fhir-version 4.0.1 --format text
patient.json: error required at Patient.identifier: minimum required = 1, but found 0
}

You can give several profiles. One written for another type than the resource's is passed over
without a message: a Patient profile says nothing about an Observation.

A profile checks more than counts. The blood-pressure reading above has only its systolic component,
and the US Core blood-pressure profile wants two components, one of them the diastolic:

@verbatim{
$ raco fhir-validate bp.json StructureDefinition-us-core-blood-pressure.json --fhir-version 4.0.1 --format text
bp.json: warning code-invalid at Observation.component.value[x].code: `mmHg` is not a UCUM unit (mercury is written mm[Hg])
bp.json: error required at Observation.component: minimum required = 2, but found 1
bp.json: error required at Observation.component: slice 'diastolic' requires 1, found 0
}

@bold{FHIR versions.} FHIR has several versions in use, and a resource valid in one may not be in
another. The command checks against R5 unless you say otherwise with
@litchar{--fhir-version 4.0.1} (R4), @litchar{5.0.0} (R5) or @litchar{6.0.0} (R6), or unless the
resource states its own version in a @tt{fhirVersion} element, as a CapabilityStatement or a
StructureDefinition does, or you name a guide's package (@secref["ig"]), which brings its own
version. US Core is written for R4, hence the option above.

If you write your profiles in FHIR Shorthand you do not need this command at all:
@hyperlink["https://oloveluck.github.io/fsh/"]{@tt{raco fsh check}} validates every example in a
project against the project's profiles with this validator, and points at the line of the FHIR
Shorthand that wrote the offending value.

@section[#:tag "ig"]{Checking against an Implementation Guide}

An @italic{Implementation Guide} (IG) is a published set of profiles, value sets and examples for
one purpose: US Core for exchanging records in the United States, the International Patient Summary,
mCODE for cancer data. It is distributed as a @italic{package}, one @tt{.tgz} file. There are three
ways to hold a resource to one.

@bold{On the command line, with the package.} Name the guide's package with @litchar{--package}.
The command reads it with the packages it depends on, finds in them every profile the resource
claims, and validates in the FHIR version the guide is written for:

@verbatim{
$ raco fhir-validate claims.json --package hl7.fhir.us.core-6.1.0 --format text
claims.json: error required at Patient.identifier: minimum required = 1, but found 0
}

@tt{claims.json} is a patient that lists the US Core patient profile in its @tt{meta.profile} and
has no identifier (it is shown in @secref["trust"]). A package is named as it is installed
(@tt{hl7.fhir.us.core-6.1.0}) or by its file (@tt{./my-guide.tgz}); repeat the option for more than
one. To hold a resource to one profile it does not claim, give that profile's file instead, as in
the section above: a package is an archive of JSON files, one per profile, so
@tt{tar -xzf hl7.fhir.us.core-6.1.0.tgz package/StructureDefinition-us-core-patient.json} takes one out.

@bold{From a program, with the whole package.} There the validator takes a list of packages, and
finds in them every profile a resource claims, the profiles those build on, and the value sets they
use (@secref["program"]).

@bold{Through a server made from the guide.}
@hyperlink["../fhir-server/index.html"]{@tt{raco fhir-server serve-ig}} starts a FHIR server from an
IG's package. It validates every resource written to it against the guide, refuses the invalid ones
with the same issues, and answers @tt{$validate} requests.

The packages that come with the tools (in the @tt{fhir-spec} package) are the core specification
for R4, R5 and R6, US Core 6.1.0, 8.0.0 and 9.0.0, the International Patient Summary 2.0.1, mCODE
4.0.0, CQF Measures 5.0.0, CRMI 2.0.0 and Genomics Reporting 2.0.0. Any other package is a file you
download from @hyperlink["https://packages.fhir.org"]{packages.fhir.org}.

@section[#:tag "trust"]{What it does not decide, and what that means for trust}

The validator has one rule above the others: @bold{it never reports what it cannot decide.} If it
cannot find a profile, cannot work out which codes a value set holds, or cannot evaluate an
invariant, it says nothing about that point rather than guess. (This is sometimes called
@italic{failing open}.)

That makes its two answers worth different things.

@itemlist[
@item{@bold{An error is real.} Each one states a fact about the resource and a rule the validator
could read in full. It is held to this by the examples that guides publish: every example in US
Core, the International Patient Summary and CRMI validates against its own profiles with no error
(@secref["tested"]). You can act on an error without second-guessing it.}
@item{@bold{"All OK" means nothing was found in what could be checked.} It is not a certificate. A
different validator, or this one with more to go on, may still find something.}]

One such case is said out loud, because it is the easiest to misread: a profile the resource
claims that the validator could not find. This patient claims the US Core profile, and has no
identifier:

@verbatim|{{"resourceType": "Patient", "id": "ann",
 "meta": {"profile": ["http://hl7.org/fhir/us/core/StructureDefinition/us-core-patient"]},
 "name": [{"family": "Lee", "given": ["Ann"]}],
 "gender": "female", "birthDate": "1974-12-25"}}|

@verbatim{
$ raco fhir-validate claims.json --fhir-version 4.0.1 --format text
claims.json: warning not-found at Patient.meta.profile[0]: the resource claims profile
  `http://hl7.org/fhir/us/core/StructureDefinition/us-core-patient`, but nothing in context
  defines it: it was not checked against that profile
$ raco fhir-validate claims.json --package hl7.fhir.us.core-6.1.0 --format text
claims.json: error required at Patient.identifier: minimum required = 1, but found 0
}

(The warning is one line; it is wrapped here to fit the page.) The first run had only FHIR's own
rules, by which the patient is fine, so there is no error and the command exits 0. But it could not
see the profile, and it says so. The second run was given the guide's package. So when a clean
answer matters, make sure the validator had the profiles and packages the resource depends on, and
read the warnings.

One thing is decided rather than passed over: a name that is simply wrong. A misspelt resource type
or element is reported, with the nearest real name, because the packages at hand define all the
names there are.

What is never checked, whatever you give it, is listed in @secref["limits"].

@section[#:tag "cli"]{Running it}

@subsection{Command line}

@tabular[#:style 'boxed #:sep @hspace[2]
(list (list @tt{raco fhir-validate r.json} "check against FHIR's rules for its type; the answer is an OperationOutcome")
      (list @tt{raco fhir-validate r.json --format text} "one line per issue, for reading")
      (list @tt{raco fhir-validate r.json p1.json p2.json} "also against these profiles (StructureDefinition files)")
      (list @tt{raco fhir-validate r.json --package hl7.fhir.us.core-6.1.0} @elem{with a guide's package (a name, or a @tt{.tgz} file) and what it depends on in reach, so the profiles the resource claims are found; repeatable})
      (list @tt{raco fhir-validate r.json --fhir-version 4.0.1} @elem{as FHIR R4; @tt{5.0.0} and @tt{6.0.0} likewise. Without it: the version the resource names, else the first package's, else R5})
      (list @tt{raco fhir-validate --help} "the usage line"))]

@litchar{--format} chooses the form of the answer. @tt{outcome}, the default, prints the
OperationOutcome as JSON on standard output:

@verbatim|{$ raco fhir-validate bad.json
{"issue":[{"code":"code-invalid","diagnostics":"code `femme` not in required value set …","expression":["Patient.gender"],"severity":"error"},{"code":"invalid","diagnostics":"'1974-02-30' is not a valid date (February 1974 has 28 days)","expression":["Patient.birthDate"],"severity":"error"}],"resourceType":"OperationOutcome"}}|

@tt{text} prints one line per issue on standard error. @tt{json} prints the OperationOutcome too.

A file that is not JSON at all is reported where reading stopped, and a key written twice in one
object (which most JSON readers silently accept, keeping the last) is an error:

@verbatim|{$ raco fhir-validate mal.json --format text
mal.json:1:48: json parse error: expected , or } in object
 1 | {"resourceType": "Patient", "gender": "female" "x": 1}
   |                                                ^
$ raco fhir-validate dup.json --format text
dup.json: error invalid at gender: duplicate JSON property 'gender'}|

A file that does not exist, or an option the command does not have, is said in one line, with exit
code 2.

@subsection[#:tag "program"]{From a program}

In FHIR, validation is an @italic{operation} called @tt{$validate}. Here an operation is an ordinary
function, so a Racket program validates by calling it. The resource is FHIR JSON as @tt{read-json}
gives it; the answer is an OperationOutcome, also JSON.

@racketblock[
(require json fhir/operation fhir/sd/sd-index fhir/spec-package
         fhir/conformance/operations fhir/r4/schemas)
(define patient (call-with-input-file "claims.json" read-json))
(define us-core (spec-package-path "hl7.fhir.us.core-6.1.0.tgz"))
(define r4-core (spec-package-path "hl7.fhir.r4.core.tgz"))

(parameterize ([current-sd-packages (list us-core r4-core)])
  (apply-operation "$validate" patient))
(code:comment "=> an OperationOutcome with one issue:")
(code:comment "   error Patient.identifier: minimum required = 1, but found 0")
]

@racket[current-sd-packages] is the list of packages to look things up in: the guide first, then
the core package it is written for. With US Core in the list, the profile the patient claims is
found and applied, which the command line could not do. @racket[spec-package-path] finds a package
that comes with the tools by its file name; a package you downloaded is just its path.

To hold a resource to a profile it does not claim, name the profile by its address:

@racketblock[
(apply-operation "$validate" patient
                 #:profile "http://hl7.org/fhir/us/core/StructureDefinition/us-core-patient")
]

A clean answer is one information issue that says which FHIR version the resource was held to:
@tt{All OK (FHIR R4 (4.0.1))}.

@bold{Stopping a pipeline.} @racket[ensure-valid] returns the resource when it is valid and raises
an error otherwise, so it can sit between two steps of a program:

@racketblock[
(ensure-valid patient #:profile "http://hl7.org/fhir/us/core/StructureDefinition/us-core-patient")
(code:comment "raises exn:fail:operation:")
(code:comment "invalid Patient against http://hl7.org/fhir/us/core/StructureDefinition/us-core-patient (FHIR R4 (4.0.1)):")
(code:comment "  Patient.identifier minimum required = 1, but found 0")
]

The message lists every error and names the profiles and the FHIR version; the exception carries the
OperationOutcome. In a threaded pipeline it reads
@racket[(~> qr (transform #:srcMap fml) (ensure-valid #:profile url))].

@bold{Where profiles are looked for.} A profile named by @racket[#:profile] or claimed in
@tt{meta.profile} is looked for, in this order: among the resources of @racket[current-data-source]
(StructureDefinitions you hold as data); among the definitions that Racket modules written in the
family's languages have registered (a @tt{#lang fsh} file's profiles, once the file is required); in
the packages of @racket[current-sd-packages]. With no packages set, the R5 core package is used.

@racketblock[
(code:comment "an FSH project's profiles, compiled by fsh/project")
(parameterize ([current-data-source (resources->data-source (project-artifacts ig))]
               [current-sd-packages (project-sd-packages ig)])
  (ensure-valid observation #:profile url))
]

@subsection{The validator itself}

Under the operation is one function, @racket[validate-issues]. It takes the resource and the
profiles as StructureDefinitions already in hand, and returns the issues as values rather than as an
OperationOutcome:

@racketblock[
(require fhir/conformance/validate fhir/terminology/service fhir/r4/schemas)
(parameterize ([current-sd-packages (list us-core r4-core)])
  (validate-issues bp #:profiles (list blood-pressure-profile)
                   #:terminology (make-terminology/packages (list us-core r4-core))))
(code:comment "=> (list (issue \"warning\" \"code-invalid\" \"Observation.component.value[x].code\" \"`mmHg` is not a UCUM unit …\")")
(code:comment "         (issue \"error\" \"required\" \"Observation.component\" \"minimum required = 2, but found 1\")")
(code:comment "         (issue \"error\" \"required\" \"Observation.component\" \"slice 'diastolic' requires 1, found 0\"))")
]

@subsection[#:tag "codes"]{Which codes can be checked}

Whether a code is allowed is a question about a value set, and answering it needs the list of codes
the value set holds. The validator knows that list in two ways.

@itemlist[
@item{For the value sets FHIR itself binds as required and that list their codes (gender, an
Observation's status and the like), the lists are built into the tools. The command line uses
these, and only these.}
@item{For anything else it asks a @italic{terminology service}, given as @racket[#:terminology]: a
value set from a guide, or one defined by a rule ("every code below this one") rather than a list.
@tt{$validate} builds a service over the data source and the packages by itself.}]

When neither can list the value set, for instance one drawn from SNOMED CT, which is not shipped,
the code is not checked. The service and what it can answer are described with
@hyperlink["../fhir-tx/index.html"]{fhir-tx}.

@section{Where else it runs}

You will often meet this validator through another tool rather than by its own command.

@itemlist[
@item{@bold{FHIR Shorthand.} @hyperlink["https://oloveluck.github.io/fsh/"]{@tt{raco fsh check}}
validates a project's examples against its profiles and reports each issue at the line that wrote
the value.}
@item{@bold{Servers.} A @hyperlink["../fhir-server/index.html"]{fhir-server} validates every
resource before it stores it and answers 422 with the issues when it is invalid; it serves
@tt{$validate} over HTTP.}
@item{@bold{The mapping language.} @hyperlink["https://oloveluck.github.io/fml/"]{fml} can validate
what a map produced and name the rule of the map that wrote the bad value.}
@item{@bold{An AI agent's workspace.} In @hyperlink["../fhir-mcp/index.html"]{fhir-mcp}, data is
validated when it is staged, and a change with an error cannot be committed.}]

@section[#:tag "limits"]{Limits}

What the validator does not check. None of these produces a message: a resource that is wrong only
in these ways gets "All OK".

@itemlist[
@item{@bold{References.} A reference to another resource (@tt{"reference": "Patient/ann"}) is not
followed: not whether the target exists, not whether it is of an allowed type or profile, not a
@tt{#id} pointing into @tt{contained}.}
@item{@bold{Extensions.} An extension's address, where it may be used and the rules of its own
definition are not checked; the content of an @tt{extension} is not looked into. A profile that
requires one particular extension is enforced: a resource without that extension is refused.}
@item{@bold{Codes where the binding is not required.} Only @italic{required} bindings are checked.
Extensible and preferred bindings, a maximum value set and additional bindings are not.}
@item{@bold{Some slicing.} Slices told apart by a value or a pattern are checked. Slices told apart
by whether an element exists, by type, by profile or by position are not, and neither is a rule that
a list may hold nothing but its slices (closed slicing) or a slice's maximum.}
@item{@bold{Profiles inside a resource.} A contained resource, or an entry of a Bundle, is held to
FHIR's rules for its type but not to the profiles its own @tt{meta.profile} claims.}
@item{@bold{The narrative.} A resource's human-readable text (@tt{text.div}) must not be empty; that
it is well-formed XHTML is not checked.}
@item{@bold{Some invariants.} The rules every element and every resource carries (@tt{ele-1},
@tt{ext-1}, the @tt{dom-} rules) are skipped, as is an invariant defined on a slice. An invariant
that depends on following a reference (@tt{resolve()}) finds nothing to follow, and one whose formula
cannot be evaluated counts as held.}
@item{@bold{Must-support.} A profile's "must support" flags are obligations on systems, not on a
single resource, and are not checked, by design.}
@item{@bold{A claimed profile that is not at hand.} The resource is checked without it, and a
warning says so (@secref["trust"]). Give the guide's package with @litchar{--package}.}
@item{@bold{No terminology service on the command line.} @tt{raco fhir-validate} checks codes against
the value sets in the core package and in the packages you name. It has no option to ask a
terminology server about SNOMED CT or LOINC codes.}
@item{@bold{JSON only.} FHIR written as XML is not read.}]

@section[#:tag "words"]{Words used here}

@itemlist[
@item{@bold{Resource}: one FHIR document, such as a Patient or an Observation, written as JSON.}
@item{@bold{Element}: one named part of a resource (@tt{birthDate}, @tt{component.code}).}
@item{@bold{Profile}: a set of stricter rules for one type of resource in one setting. As a
resource it is a @bold{StructureDefinition}.}
@item{@bold{@tt{meta.profile}}: where a resource lists the profiles it claims to follow.}
@item{@bold{Implementation Guide} (IG): a published set of profiles, value sets and examples.
@bold{Package}: the @tt{.tgz} file it is distributed as. The @bold{core package} is the FHIR
specification itself in that form.}
@item{@bold{Canonical url}: the web address that names a profile or a value set. It is a name;
nothing needs to be served there.}
@item{@bold{Cardinality}: how many of an element are allowed, written @tt{min..max} (@tt{1..1},
@tt{0..*}).}
@item{@bold{Value set}: a named set of codes. @bold{Binding}: the statement that an element's code
comes from a value set; a @italic{required} binding allows no other code.}
@item{@bold{Invariant} (or constraint): a rule relating several elements, written as a
@hyperlink["https://oloveluck.github.io/fhirpath/"]{FHIRPath} formula, with a key such as
@tt{obs-6}.}
@item{@bold{Slice}: one named entry a profile requires in a repeating element, such as the systolic
component of a blood pressure.}
@item{@bold{Choice element}: an element that may hold one of several types, written @tt{value[x]}
in a path and @tt{valueQuantity}, @tt{valueString} … in the JSON.}
@item{@bold{Issue}: one finding. @bold{OperationOutcome}: the FHIR resource that carries a list of
issues.}
@item{@bold{Operation}: a named service FHIR defines, written with a dollar sign (@tt{$validate}).}
@item{@bold{Terminology service}: the part that knows which codes a value set holds
(@hyperlink["../fhir-tx/index.html"]{fhir-tx}).}
@item{@bold{UCUM}: the standard codes for units of measure (@tt{mm[Hg]}, @tt{mg/dL}).}
@item{@bold{Fail open}: to say nothing where a rule cannot be decided, rather than report a
possible problem.}]

@section[#:tag "tested"]{How it is tested}

Against published work, in two directions: it must not complain about what is valid, and it should
catch what is not.

@itemlist[
@item{@bold{No false alarm on published guides.} Every example in US Core 9.0.0, the International
Patient Summary 2.0.1 and CRMI 2.0.0 that claims one of the guide's profiles is validated against
it: 330 examples (216, 44 and 70), none with an error. mCODE 4.0.0's 283 examples are held to its profiles the same
way, through a server generated from the guide.}
@item{@bold{No false alarm on the specification.} Of the 2,968 resources in the R5 core package,
2,957 show no broken invariant; the other 11 are real faults in the package (ten logical models
without a @tt{derivation}, and one code system against a profile it claims).}
@item{@bold{Against HL7's validator test cases.} On 67 cases with the reference validator's
recorded verdicts, it never calls a valid case invalid, and catches 18 of the 26 invalid ones. The
eight it misses need what @secref["limits"] lists: following references, and details of choice
types and decimal formats.}]

The repository's @hyperlink["https://github.com/oloveluck/fhir/blob/main/TESTING.md"]{@tt{TESTING.md}}
has every suite and names the misses.

@section{Reference}

@subsection[#:style 'unnumbered]{@tt{fhir/conformance/validate}}
@defmodule[fhir/conformance/validate]

@defproc[(validate-issues [resource hash?]
                          [#:profiles profiles (listof hash?) '()]
                          [#:terminology terminology any/c #f]
                          [#:invariants? invariants? boolean? #t]
                          [#:duplicates duplicates (listof string?) '()]) (listof issue?)]{
Validates raw FHIR JSON against its base type, the profiles in @tt{meta.profile}, and the
StructureDefinitions given (those whose type matches), their snapshots generated on demand. The
checks: cardinality; unknown elements (lenient on choice variants) and unknown resource types; the
choice variant narrowed to its type; primitive lexemes (decimals on their lexeme, calendar dates, the
id grammar, canonicals); @tt{fixed[x]} and @tt{pattern[x]}; required bindings, through a
@racket[tx-service] when one is given and the value set expands offline, else through the offline
expansions generated with the type tower; UCUM codes of quantities (a warning); value and pattern
discriminator slicing, with an entry matched to exactly one slice held to the slice's own children;
and, unless @racket[invariants?] is false, FHIRPath constraints — each at its element with
@tt{%resource} and @tt{%context} bound, a violation only on a singleton false, the universal base
keys (ele-1, ext-1, dom-*) and constraints on slices left unchecked (slice membership is not decided
here). Invariants are on by default. Over the whole R5 core package they report nothing the package
does not itself break (ten logical models without @tt{derivation}, sdf-27; the fhir-types code system
against the Shareable profile, scs-1). @racket[duplicates] are the paths of duplicate JSON keys from
@racket[read-fhir-json/duplicates], each an error. Anything undecidable (an unresolvable type,
profile or value set, an unparseable expression) is not reported.}
@defstruct*[issue ([severity string?] [code string?] [path (or/c string? #f)] [msg string?])]{
One finding: @racket[severity] is @racket["error"], @racket["warning"] or @racket["fatal"];
@racket[code] an OperationOutcome issue-type code (@racket["structure"], @racket["required"],
@racket["value"], @racket["invalid"], @racket["code-invalid"], @racket["invariant"]); @racket[path]
the dotted element path; @racket[msg] a sentence.}
@defproc[(validate-json [resource hash?]
                        [#:profiles profiles (listof hash?) '()]
                        [#:terminology terminology any/c #f]
                        [#:invariants? invariants? boolean? #t]
                        [#:duplicates duplicates (listof string?) '()]) any/c]{The same as an OperationOutcome node.}
@defproc[(write-errors/rows [item (list/c string? (listof string?))])
         (listof (list/c string? string? (or/c string? #f) string?))]{
The error and fatal issues of a resource given as JSON text, validated in the context of the named
packages (paths as strings, as @racket[current-sd-packages] takes them), each as a row of severity,
code, path and message. Plain data in and out, so a worker process can be handed it: how a server
validates many resources at once before a load.}

@subsection[#:style 'unnumbered]{@tt{fhir/conformance/operations}}
@defmodule[fhir/conformance/operations]

@defthing[$validate procedure?]{
@tt{Resource/$validate} as a @tt{fhir/operation} value, registered when the module loads:
@racket[($validate resource #:profile canonical)] returns an OperationOutcome (one informational
"All OK" issue, naming the FHIR version, when clean). The profile resolves from
@racket[current-data-source], then the registered definitions, then @racket[current-sd-packages];
terminology comes from the same places.}
@defproc[(ensure-valid [resource hash?] [#:profile profile (or/c string? #f) #f]) hash?]{
The resource when it is valid, else @racket[exn:fail:operation] with the outcome; its message lists
every error and names the profiles and the FHIR version the resource was held to.}
