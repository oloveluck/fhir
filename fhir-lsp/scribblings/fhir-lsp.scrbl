#lang scribble/manual
@(require (for-label racket/base racket/contract fhir/lsp/jsonrpc fhir/lsp/diagnostics fhir/lsp/languages fhir/lsp/server))

@title{fhir-lsp: a language server for the FHIR languages}

One @hyperlink["https://microsoft.github.io/language-server-protocol/"]{Language Server Protocol}
server for FHIR Shorthand (@tt{.fsh}), CQL (@tt{.cql}), the FHIR Mapping Language (@tt{.fml},
@tt{.map}), VCL (@tt{.vcl}) and FHIRPath (@tt{.fhirpath}). As you type, each document's problems are
published to the editor exactly as the language's own compiler reports them, positioned on the line
and column; an FSH file is checked as part of its project (its @tt{sushi-config.yaml} and the other
files beside it), so a profile rule that breaks an example two files away is reported there. Each
language package is loaded when a document of its kind is opened, so the server runs with whichever
languages are installed. Part of the @hyperlink["https://github.com/oloveluck/fhir"]{fhir} family.

@table-of-contents[]

@section{Quick start}

@bold{1. Install} the server and the languages you write (the packages are not on the Racket package
server yet; clone the repositories side by side):

@verbatim{
raco pkg install --link --auto fhir/fhir fhir/fhir-spec fhirpath vcl fhir/fhir-tx fhir/fhir-validation cql fml fsh fhir/fhir-lsp
raco fhir-lsp languages        # fsh .fsh / cql .cql / fml .fml .map / vcl .vcl / fhirpath .fhirpath
}

@bold{2. Point your editor at it.} The command is @tt{raco fhir-lsp}, speaking the protocol on
stdin and stdout.

@itemlist[
@item{@bold{VS Code}: with a generic LSP client such as @italic{Generic LSP Client} or
@italic{LSP Proxy}, add a server with command @tt{raco}, arguments @tt{["fhir-lsp"]}, for the
languages @tt{fsh}, @tt{cql}, @tt{fml}, @tt{vcl}; associate the file extensions with those
language ids under @tt{files.associations} if the extension does not already.}
@item{@bold{Neovim} (0.8+), in @tt{init.lua}:
@verbatim|{vim.filetype.add({ extension = { fsh = "fsh", cql = "cql", fml = "fml", map = "fml", vcl = "vcl" } })
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "fsh", "cql", "fml", "vcl" },
  callback = function()
    vim.lsp.start({ name = "fhir-lsp", cmd = { "raco", "fhir-lsp" }, root_dir = vim.fs.root(0, { "sushi-config.yaml", ".git" }) })
  end,
})}|}
@item{@bold{Emacs} (29+, eglot):
@verbatim|{(add-to-list 'eglot-server-programs '((fsh-mode cql-mode fml-mode vcl-mode) . ("raco" "fhir-lsp")))}|
with a mode per extension (@tt{define-derived-mode} from @tt{prog-mode} and @tt{auto-mode-alist}
entries are enough).}]

@bold{3. Open a file.} A mistake is underlined where it is, with the message the command line would
print; in an FSH project, an example that breaks a profile rule is reported on the instance rule and
names the profile rule.

Without an editor, @tt{raco fhir-lsp check ig/input/fsh/bp.fsh} prints what the server would
publish, in the family's diagnostic format (@litchar{--format text|json|outcome}), and exits 1 when
any problem is an error.

@section{What it does}

@tabular[#:style 'boxed #:sep @hspace[2]
(list (list @bold{language} @bold{on open, change and save})
      (list "fsh" "the whole project compiled with the document's text in place of the file on disk: parse errors, unknown element paths at their rule, entities that fail, every example validated against the project's profiles (positioned at the instance rule, naming the profile rule); diagnostics for other files of the project are published too")
      (list "cql" "parse errors; every definition translated, each failure at its define")
      (list "fml" "parse errors; the map checked against its structures (an element the type lacks, a value that cannot go into its element, a wrong group call, a required target never assigned)")
      (list "vcl" "the expression parsed and compiled to a compose")
      (list "fhirpath" "the expression parsed"))]

For FSH, two more, read from the text rather than a parse (so they work while a document does not
parse yet): @bold{hover} on a rule's element path shows the base type's definition of that element
(path, cardinality, types, short and definition from the core snapshot; the base is the document's
@tt{Parent} or @tt{InstanceOf}, followed through the project's own profiles and aliases); hover on
a name shows the declaration it refers to. @bold{Go to definition} on a name (a Parent, an
InstanceOf, a value set in a binding, an alias, a RuleSet in an insert, an invariant, an instance in
a Reference) opens the declaration in this project, found by name, id or canonical, across the
project's files as the editor holds them.

@bold{Completion} (FSH): at the start of a line the entity and metadata keywords; after
@tt{Parent:} or @tt{InstanceOf:} the FHIR types and the project's profiles, extensions and models;
after @tt{from} its value sets and aliases, after @tt{insert} its rule sets, after @tt{obeys} its
invariants; after @tt{* } and a dotted prefix, the base type's elements at that path with their
cardinality, types and short description; after a path, the flags and rule keywords.
@bold{Document symbols}: the document's declarations as an outline.

For CQL and FML the same three work from the declarations the text shows, without a parse: the
outline lists a library's includes, value sets, code systems, parameters, context and defines (a map's
uses, imports, concept maps and groups); hover on a name shows its declaration, and go to definition
jumps to it within the document (a quoted CQL name is the text inside its quotes); completion offers
the document's declared names and the language's keywords that start with what is typed (inside
quotes, names only).

Diagnostics are computed off the protocol loop: an open, change or save updates the stored text at
once (so hover and completion see it) and the diagnosing runs in a worker thread; when another edit
arrives before it finishes, the older result is dropped, so a large project's compile never blocks
the editor or publishes stale findings.

Protocol: @tt{initialize}, @tt{initialized}, @tt{shutdown}, @tt{exit}, @tt{textDocument/didOpen},
@tt{didChange} (full text), @tt{didSave}, @tt{didClose}, @tt{textDocument/hover},
@tt{textDocument/definition}, @tt{textDocument/completion}, @tt{textDocument/documentSymbol}, and
@tt{textDocument/publishDiagnostics} back. Any other request is answered with method-not-found;
other notifications are ignored.

@section{Limits}

@itemlist[
@item{Hover, definition, completion and symbols read the text, not a parse: a name is the word under
the cursor, an FSH element is looked up in the base type's core snapshot (not the profile's or a
dependency's constraints). Element-path completion and project-wide definition are for FSH;
CQL and FML names complete and resolve within one document. No formatting, rename or references.}
@item{An FSH document is recompiled with its project on every change; on a large project (mCODE:
hundreds of entities) that takes seconds, during which the previous diagnostics stand.}
@item{Positions are the compilers' positions: a CQL translation error without one, or a problem in
a file the project reports on without a line, lands on the first character.}
@item{Documents are read as whole texts (full synchronisation); incremental changes are not
accepted, which every editor negotiates from the capabilities.}]

@section{Reference}

@subsection[#:style 'unnumbered]{@tt{fhir/lsp/server}}
@defmodule[fhir/lsp/server]

@defproc[(serve [in input-port? (current-input-port)] [out output-port? (current-output-port)]) void?]{
Reads messages from @racket[in], dispatches each and writes the replies and notifications to
@racket[out], until @tt{exit} or the end of the stream.}
@defproc[(dispatch [message hash?] [st state?]) (values (or/c hash? #f) state? (listof hash?))]{
One message: the response (a request's), the next state, and the notifications to send. Pure.}
@defstruct*[state ([documents hash?] [published hash?] [down? boolean?])]{
The open documents by uri, the documents each one's last diagnostics went to, and whether
@tt{shutdown} was received.}
@defthing[initial-state state?]
@defthing[server-capabilities hash?]{What @tt{initialize} answers: full text synchronisation with the text on save, hover, definition, completion, document symbols.}

@subsection[#:style 'unnumbered]{@tt{fhir/lsp/fsh-complete}}
@defmodule[fhir/lsp/fsh-complete]

@defproc[(completion-context [text string?] [pos pair?]) (values symbol? string?)]{What the cursor is in (@racket['keyword], @racket['parent], @racket['valueset], @racket['ruleset], @racket['invariant], @racket['path], @racket['flag] or @racket['none]) and the word being typed.}
@defproc[(complete [text string?] [pos pair?] [es (listof entity?)] [aliases hash?]) (listof hash?)]{The completion items for that context.}

@subsection[#:style 'unnumbered]{@tt{fhir/lsp/fsh-symbols}}
@defmodule[fhir/lsp/fsh-symbols]

@defstruct*[entity ([kind string?] [name string?] [id (or/c string? #f)] [file string?] [line exact-nonnegative-integer?])]{A declaration in a project file (0-based line).}
@defproc[(entities-of [text string?] [file path-string?]) (listof entity?)]
@defproc[(find-entity [es (listof entity?)] [name string?]) (or/c entity? #f)]{By name, id, or a canonical's last segment.}
@defproc[(word-at [text string?] [pos pair?]) (or/c string? #f)]{The name under a (line . character) position.}
@defproc[(rule-path-at [text string?] [pos pair?]) (or/c string? #f)]{The element path of the rule on that line, when the position is on it.}
@defproc[(parent-of [text string?] [es (listof entity?)] [aliases hash?]) (or/c string? #f)]{The document's base type, through the project's profiles.}
@defproc[(element-hover [base-type string?] [fsh-path string?]) (or/c string? #f)]{Markdown for the element, from the base's snapshot.}
@defproc[(entity-hover [e entity?] [text string?]) (or/c string? #f)]{The declaration's header lines.}
@defproc[(aliases-of [text string?]) (hash/c string? string?)]
@defproc[(project-root [file path-string?]) path?]{Where the file's @tt{sushi-config.yaml} is, else its directory.}
@defproc[(project-fsh-files [dir path?]) (listof path?)]

@subsection[#:style 'unnumbered]{@tt{fhir/lsp/languages}}
@defmodule[fhir/lsp/languages]

@defstruct*[language ([id string?] [extensions (listof string?)] [diagnose procedure?])]{
A language the server knows: its LSP language id (also its package), its file extensions, and
@racket[(diagnose text path)], the problems in a document as @tt{fhir/diagnostic} values.}
@defthing[languages (listof language?)]{The catalogue: fsh, cql, fml, vcl, fhirpath.}
@defproc[(language-of [path path-string?]) (or/c language? #f)]{By file extension.}
@defproc[(language-by-id [id string?]) (or/c language? #f)]
@defproc[(diagnose [l language?] [text string?] [path path-string?]) (listof diagnostic?)]{
The language's adapter, which never raises: a language whose package is not installed, or an
adapter failure, is one diagnostic saying so.}

@subsection[#:style 'unnumbered]{@tt{fhir/lsp/diagnostics}}
@defmodule[fhir/lsp/diagnostics]

@defproc[(diagnostic->lsp [d diagnostic?]) hash?]{A @tt{fhir/diagnostic} as an LSP diagnostic: 0-based range, severity 1 (error) or 2 (warning), the language and phase as @tt{source}.}
@defproc[(group-by-uri [ds (listof diagnostic?)] [default string?]) (hash/c string? (listof hash?))]{By the file each diagnostic names; one naming none goes to @racket[default].}
@defproc[(path->uri [p path-string?]) string?]
@defproc[(uri->path [uri string?]) (or/c path? #f)]

@subsection[#:style 'unnumbered]{@tt{fhir/lsp/jsonrpc}}
@defmodule[fhir/lsp/jsonrpc]

@defproc[(read-message [in input-port?]) (or/c hash? eof-object?)]{One @tt{Content-Length}-framed JSON-RPC message; a body that is not JSON carries an @racket['invalid] key.}
@defproc[(write-message [m hash?] [out output-port?]) void?]
@deftogether[(
@defproc[(request [id any/c] [method string?] [params any/c #f]) hash?]
@defproc[(notification [method string?] [params any/c #f]) hash?]
@defproc[(response [id any/c] [result any/c]) hash?]
@defproc[(error-response [id any/c] [code exact-integer?] [message string?] [data any/c #f]) hash?])]{The message constructors.}
@deftogether[(@defproc[(request? [m any/c]) boolean?] @defproc[(notification? [m any/c]) boolean?] @defproc[(response? [m any/c]) boolean?])]
