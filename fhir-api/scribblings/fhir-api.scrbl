#lang scribble/manual
@(require (for-label racket/base)
          racket/runtime-path racket/file racket/list racket/string
          fhir/api/functions)

@; tt : code inside a sentence, exactly as typed (scribble's own tt would turn -- into a dash and
@; 'x' into curly quotes)
@(require (only-in scribble/core element))
@(define (tt . text) (element 'tt text))

@; The Python examples are the Python README's own (clients/python/README.md), which a test runs
@; and holds to the output shown: this page reads them from that file, so there is one copy.
@(define-runtime-path python-readme "../../clients/python/README.md")
@(define readme-blocks
   (if (file-exists? python-readme)
       (regexp-match* #px"```(python|text)\n(.*?)```" (file->string python-readme) #:match-select cdr)
       '()))
@; example : n -> block   the n-th Python example of the README, with what it prints
@(define (example n)
   (define programs (for/list ([b (in-list readme-blocks)] [i (in-naturals)] #:when (equal? (car b) "python")) i))
   (cond
     [(< n (length programs))
      (define i (list-ref programs n))
      (define printed (and (< (add1 i) (length readme-blocks)) (equal? (car (list-ref readme-blocks (add1 i))) "text")
                           (cadr (list-ref readme-blocks (add1 i)))))
      (apply verbatim #:indent 2
             (append (list (cadr (list-ref readme-blocks i)))
                     (if printed (list "\n" (string-join (map (lambda (l) (string-append "# " l)) (string-split printed "\n")) "\n")) '())))]
     [else (verbatim #:indent 2 "(the example is in clients/python/README.md)")]))

@title{fhir-api: the toolkit from Python, and from any other language}

The toolkit is written in Racket. Most people who work with health data write Python. This page
is how the two meet: a Python package, @tt{fhir-toolkit}, whose functions compile, check, run and
validate FHIR and its languages, and under it a small server that any other language can speak to
in the same way.

Part of the @hyperlink["https://oloveluck.github.io/fhir/"]{fhir} family of FHIR languages and tools.

@table-of-contents[]

@section{What you can do with it}

@itemlist[
@item{Ask a question of a resource in FHIRPath, and get Python values back.}
@item{Check that a resource is valid FHIR, or valid against a profile you wrote in a few lines of FSH.}
@item{Turn FHIR resources into a table (a pandas DataFrame) with a view, and join tables in SQL.}
@item{Run clinical logic written in CQL over patients' data, or get its ELM.}
@item{Convert a resource with a map, expand a value set, write a resource back as FSH.}
@item{Get every problem as a value with its file, line and column, so your program can point at it.}]

@section{A first example}

Install the package. It is not on the Python Package Index yet: a wheel is built by this
repository's @tt{wheels} workflow, and @secref["source"] says how to use a source checkout
meanwhile. A wheel carries the toolkit itself, so nothing else is needed.

@verbatim[#:indent 2]{pip install fhir_toolkit-0.1.0-py3-none-<your platform>.whl}

Then make a @tt{Toolkit} and call it. Each line under a @tt{#} is what the example prints.

@(example 0)

@tt{Toolkit()} starts one process the first time you call it (about a second) and keeps it for
the calls after, which take milliseconds. @tt{fhirpath} answers a list, because a FHIRPath
expression answers a collection. @tt{validate} answers an outcome: @tt{.ok} is true when no issue
is an error, and @tt{.messages()} is one line for each issue, starting with the element it is about.

@section{Projects and data}

Two words carry the rest of the package.

A @bold{project} is the sources a call may refer to: a profile in FSH, a CQL library, a map, a
value set, a view, a FHIR definition as JSON. You give it as a dictionary of file name to text
(the name's ending says the language: @tt{.fsh}, @tt{.cql}, @tt{.map}, @tt{.vcl}, @tt{.sof},
@tt{.json}), or as the path of a directory. What the project defines is in context for the call.
Here a profile is the project, and a resource is held to it:

@(example 1)

A mistake in a source is an exception, @tt{FhirError}, whose @tt{diagnostics} say where:

@(example 2)

@bold{Data} is the FHIR a call reads. Give resources (a list, one resource, a Bundle), or a
string: the path of a directory of FHIR JSON, of a JSON file or of a SQLite FHIR store, or the
base url of a FHIR server.

@section{Tables}

A view is a @tt{SELECT} whose columns are FHIRPath expressions; it turns resources of one type
into rows. @tt{to_pandas()} gives a DataFrame (it needs pandas installed).

@(example 3)

Several views in a project are tables of their names, and @tt{sql} runs a statement over them:

@(example 4)

@section{Clinical logic}

@tt{cql} runs a library over the data and answers one row for each patient, one column for each
definition. @tt{translate} answers the library's ELM, the form other CQL engines run.

@(example 5)

@section[#:tag "source"]{From a source checkout}

Without a wheel, the package looks for the toolkit in this order: the command the
@tt{FHIR_API_COMMAND} environment variable names; an executable bundled with the package;
@tt{fhir-api} on the PATH (the standalone build, @tt{./build-tools.sh dist fhir-api}); and
@tt{raco fhir-api}, which is there once Racket and the family's packages are installed. From a
checkout of this repository:

@verbatim[#:indent 2]{
pip install ./clients/python
python3 -m unittest discover -s clients/python/tests
}

@section{Another language than Python}

The Python package is a thin client. The work is done by a process, @tt{raco fhir-api serve}
(or the standalone @tt{fhir-api serve}), that reads one request on each line of its standard
input and writes one answer on each line of its output, as JSON-RPC 2.0:

@verbatim[#:indent 2]{
$ echo '{"jsonrpc":"2.0","id":1,"method":"fhirpath","params":{"expression":"name.family","resource":{"resourceType":"Patient","name":[{"family":"Lee"}]}}}' | raco fhir-api serve
{"id":1,"jsonrpc":"2.0","result":{"values":["Lee"]}}
}

A request's @tt{method} is a function's name and its @tt{params} are the arguments by name.
@tt{raco fhir-api functions} prints every function; @tt{raco fhir-api functions --json} prints
them with a JSON Schema for each one's arguments. That text is kept in this repository as
@tt{clients/functions.json}, and the Python client's functions are generated from it
(@tt{clients/python/generate.py}): a client for another language starts from the same file.
@tt{raco fhir-api call fhirpath '<json arguments>'} makes one call from a shell.

A call that cannot be answered is an error with a code: @tt{-32601} for a function that does not
exist, @tt{-32602} for arguments that are not the function's, @tt{-32000} when the function
failed, with @tt{data.diagnostics} when the failure has a place in a source and @tt{data.outcome}
when it is a FHIR OperationOutcome. Problems in a source you gave to @tt{compile} or
@tt{translate} are not errors: those functions answer their diagnostics.

@section{Words used here}

@itemlist[
@item{@bold{FHIR}: the standard for health data. A @italic{resource} is one record (a Patient, an Observation) as JSON.}
@item{@bold{Profile}: rules a kind of resource must keep, beyond FHIR's own.}
@item{@bold{FSH} (FHIR Shorthand): the language profiles and example resources are written in.}
@item{@bold{FHIRPath}: a small language for reading values out of a resource.}
@item{@bold{CQL} (Clinical Quality Language): the language of clinical rules and measures; @bold{ELM} is what it compiles to.}
@item{@bold{View}: a table defined over resources (SQL on FHIR).}
@item{@bold{Value set}: a named set of codes; @bold{VCL} is a short way to write one.}
@item{@bold{OperationOutcome}: FHIR's own resource for the result of a check, a list of issues.}
@item{@bold{Wheel}: the file @tt{pip} installs.}]

@section{Limits}

@itemlist[
@item{Values are JSON. A resource is a dictionary, not a typed object.}
@item{A process reads one version of FHIR, 4.0.1 or 5.0.0. @tt{Toolkit("5.0.0")} is a second process.}
@item{Numbers pass through JSON: a decimal written @tt{1.50} arrives as @tt{1.5}.}
@item{A wheel carries the FHIR R4 and R5 core packages. Any other implementation guide is given by its package file.}
@item{Writing to a store with a recorded trail (stage, commit) is @hyperlink["../fhir-mcp/index.html"]{fhir-mcp}'s workspace, which the package does not wrap.}
@item{Wheels are built for Linux and macOS. Windows has not been built.}
@item{A table defined over a large SQLite store is computed again by each new process: for that, use a workspace.}]

@section{How it is tested}

The server's functions are each called as a client calls them, in every language, in
@tt{fhir-api/tests} (among them a process for FHIR 5.0.0). The Python package's
tests (@tt{clients/python/tests}) hold its generated functions to the table and call every
method against the server; they are run again against a built wheel, in a clean environment
with nothing else on the PATH. Every example on this page is run by a test and compared with the
output shown.

@section{The functions}

What the server offers, from its own table (@tt{fhir-api/api/functions.rkt}). A name followed
by @tt{?} is optional.

@(apply itemlist
        (for/list ([f (in-list functions)])
          (item (bold (fn-name f)) ": " (literal (fn-summary f))
                (apply itemlist
                       (append
                        (for/list ([p (in-list (fn-params f))])
                          (item (tt (param-name p) (if (param-required? p) "" "?")) ": " (literal (param-doc p))))
                        (list (item "answers " (literal (fn-returns f)))))))))
