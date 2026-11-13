#lang scribble/manual
@; Text in @tt is shown exactly as written: no curly quotes, and "--" stays two hyphens.
@(require (only-in scribble/core [element literal-element]))
@(define (tt . text) (literal-element (quote tt) text))
@(require (for-label racket/base racket/contract fhir/lsp/jsonrpc fhir/lsp/diagnostics fhir/lsp/languages fhir/lsp/server))

@title{fhir-lsp: a language server for the FHIR languages}

When you write a file in one of FHIR's languages, you want to know about a mistake while you are
still on the line: a misspelt element, a function that does not exist, a bracket never closed. An
editor cannot tell you by itself, because it does not know the language.

A @italic{language server} is the piece that does. It is a program your editor starts in the
background and sends your text to as you type. The server answers with the problems it finds and
where they are, and the editor underlines them. The editor can also ask it what a name means, where
a name is defined, and what could be typed next. Editors and servers speak a common protocol, the
@hyperlink["https://microsoft.github.io/language-server-protocol/"]{Language Server Protocol}, so
one server works in any editor that speaks it.

This package is that server for five languages:

@tabular[#:style 'boxed #:sep @hspace[2]
(list (list @bold{language} @bold{files} @bold{what it is for})
      (list "FHIR Shorthand" @tt{.fsh} "profiles, value sets and examples")
      (list "Clinical Quality Language (CQL)" @tt{.cql} "logic over a patient's record")
      (list "FHIR Mapping Language" @elem{@tt{.fml}, @tt{.map}} "converting data from one shape to another")
      (list "ValueSet Compose Language (VCL)" @tt{.vcl} "a set of codes in one line")
      (list "FHIRPath" @tt{.fhirpath} "a question asked of one resource"))]

The problems it reports are the ones each language's own command-line tool reports, word for word.

Part of the @hyperlink["https://oloveluck.github.io/fhir/"]{fhir} family of FHIR languages and tools.

@table-of-contents[]

@section{What you can do with it}

@itemlist[
@item{@bold{See mistakes as you type}, underlined at the place, with the message the command line
would print. Every language.}
@item{@bold{See a file's outline}: its profiles and instances, its definitions, its groups. FHIR
Shorthand, CQL and the mapping language.}
@item{@bold{Hover over a name} to see what it is: an element's cardinality and description, a
definition's text. FHIR Shorthand, CQL and the mapping language.}
@item{@bold{Jump to where a name is defined}, in this file or another one of the project. FHIR
Shorthand, CQL and the mapping language.}
@item{@bold{Complete what you are typing}: keywords, the names your project defines, the elements
of a type. FHIR Shorthand, CQL and the mapping language.}
@item{@bold{Check files without an editor}: @tt{raco fhir-lsp check} prints what the server would
show (@secref["check"]).}]

@secref["languages"] says exactly what each language gets.

@section[#:tag "setup"]{Setting it up}

Three steps: install the tools, tell your editor about the server, open a file.

@subsection{1. Install}

Install the tools as the @hyperlink["https://oloveluck.github.io/fhir/"]{family's front page}
describes. Then ask the server what it serves:

@verbatim{
$ raco fhir-lsp languages
fsh	.fsh
cql	.cql
fml	.fml .map
vcl	.vcl
fhirpath	.fhirpath
}

If you see these five lines, the server is installed. The command an editor must start is
@tt{raco fhir-lsp}, with nothing after it. (If you built the standalone tools, it is @tt{fhir-lsp}.)
It talks to the editor over its standard input and output, which is what editors expect by default.

@subsection{2. Tell your editor}

An editor needs to know two things: which files are in these languages, and which command to start
for them. The server works out the language from the file's extension, so the name your editor
gives a language does not matter.

@bold{Neovim} (0.10 or newer). Put this in @tt{init.lua}:

@verbatim|{
vim.filetype.add({ extension = {
  fsh = "fsh", cql = "cql", fml = "fml", map = "fml", vcl = "vcl", fhirpath = "fhirpath" } })
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "fsh", "cql", "fml", "vcl", "fhirpath" },
  callback = function()
    vim.lsp.start({
      name = "fhir-lsp",
      cmd = { "raco", "fhir-lsp" },
      root_dir = vim.fs.root(0, { "sushi-config.yaml", ".git" }),
    })
  end,
})
}|

The first statement names the file types; the second starts the server whenever a file of one of
them is opened.

@bold{Emacs} (29 or newer, which includes the client @tt{eglot}). Put this in your init file:

@verbatim|{
(define-derived-mode fsh-mode prog-mode "FSH")
(define-derived-mode cql-mode prog-mode "CQL")
(define-derived-mode fml-mode prog-mode "FML")
(define-derived-mode vcl-mode prog-mode "VCL")
(define-derived-mode fhirpath-mode prog-mode "FHIRPath")
(add-to-list 'auto-mode-alist '("\\.fsh\\'" . fsh-mode))
(add-to-list 'auto-mode-alist '("\\.cql\\'" . cql-mode))
(add-to-list 'auto-mode-alist '("\\.\\(fml\\|map\\)\\'" . fml-mode))
(add-to-list 'auto-mode-alist '("\\.vcl\\'" . vcl-mode))
(add-to-list 'auto-mode-alist '("\\.fhirpath\\'" . fhirpath-mode))
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '((fsh-mode cql-mode fml-mode vcl-mode fhirpath-mode) . ("raco" "fhir-lsp"))))
(dolist (hook '(fsh-mode-hook cql-mode-hook fml-mode-hook vcl-mode-hook fhirpath-mode-hook))
  (add-hook hook #'eglot-ensure))
}|

The first lines give each language a mode and tie it to its file extensions. The rest tells
@tt{eglot} which command serves those modes, and to start it when such a file is opened. If you
already have a mode for one of the languages, keep it and name it in the list instead.

@bold{VS Code.} VS Code talks to a language server through an extension, and there is no extension
made for this server yet. A general-purpose client extension does the job (one is called
@italic{Generic LSP Client}). Whichever you choose, give it:

@itemlist[
@item{the command @tt{raco} with the one argument @tt{fhir-lsp} (or the standalone @tt{fhir-lsp},
if the extension takes a single program);}
@item{the files it applies to: @tt{.fsh}, @tt{.cql}, @tt{.fml}, @tt{.map}, @tt{.vcl} and
@tt{.fhirpath};}
@item{standard input and output as the way to talk to it, which is usually the default.}]

Some client extensions run only one server for one language at a time. With those, set it up for
the language you write most.

@bold{Any other editor} that speaks the protocol (Helix, Zed, Sublime Text, Kate …) needs the same
three facts.

@subsection{3. Open a file}

Save this as @tt{bp.fsh} and open it. It is a profile for blood-pressure readings with one
misspelt element:

@verbatim{
Profile: BloodPressure
Parent: Observation
Id: blood-pressure
* subject 1..1
* efective[x] 1..1
}

After a moment @tt{efective[x]} is underlined, and the message reads:

@verbatim{
profile: BloodPressure: `efective` is not an element of Observation (did you mean `effective`?)
}

(Emacs shows where the message comes from before it: @tt{fsh compile: profile: BloodPressure: …}.)
Correct the spelling and the underline goes away. Put the cursor on @tt{subject} and ask for hover
(the mouse in VS Code, @tt{K} in Neovim, @tt{M-x eldoc} in Emacs) to see what FHIR says that element
is.

@section[#:tag "nothing"]{When nothing happens}

Work down this list. Each step rules out one cause.

@itemlist[#:style 'ordered
@item{@bold{Is the server installed?} Run @tt{raco fhir-lsp languages} in a terminal. It should
print the five lines shown above.}
@item{@bold{Does the server see the mistake?} Run it on the file, with no editor involved:

@verbatim{
$ raco fhir-lsp check bp.fsh
bp.fsh:5:3: fsh compile error: profile: BloodPressure: `efective` is not an element of Observation (did you mean `effective`?)
 5 | * efective[x] 1..1
   |   ^^^^^^^^^^^
}

If this prints the problem, the server is fine and the editor is not reaching it. If it prints
nothing, the server finds nothing wrong with the file.}
@item{@bold{Can the editor find the command?} An editor started from a desktop icon may not have
the same @tt{PATH} as your terminal. Give it the full path to @tt{raco} (the terminal command
@tt{which raco} prints it), or start the editor from the terminal.}
@item{@bold{Did the editor start the server for this file?} The file's name must end in one of the
extensions above. In Neovim, @tt{:lua print(#vim.lsp.get_clients({ bufnr = 0 }))} prints 1 when a
server is attached to the file you are in. In Emacs, @tt{M-x eglot} starts the server by hand and
says what went wrong if it cannot; @tt{M-x eglot-events-buffer} shows the conversation. In VS Code,
the Output panel has an entry for the client extension.}
@item{@bold{Is the language installed?} The server loads each language when a file of its kind is
first opened. If that language's package is missing, the file gets one message saying so
(@tt{the fsh package is not installed}) and the other languages keep working.}
@item{@bold{Give it a moment.} The first check of a FHIR Shorthand file reads FHIR's definitions,
which takes a couple of seconds. Later checks are quicker.}]

@section[#:tag "languages"]{What each language gets}

Every language gets its problems reported. Three of them get the rest.

@tabular[#:style 'boxed #:sep @hspace[2]
(list (list @bold{language} @bold{problems reported as you type} @bold{outline, hover, definition, completion})
      (list "FHIR Shorthand" "what compiling the project finds: text that does not parse, an element the type does not have (at its rule), a Parent, InstanceOf or RuleSet that no file of the project and none of its packages defines" "yes, across the project's files")
      (list "CQL" "text that does not parse; every definition translated, each failure at its place, with warnings" "yes; into included libraries beside the file")
      (list "Mapping language" "text that does not parse; the map checked against the structures it names: an element the type lacks, a value that cannot go into its element, a wrong call to a group, a required element never written" "yes; into imported maps beside the file")
      (list "VCL" "the expression parsed and turned into a value set definition" "no")
      (list "FHIRPath" "the expression parsed" "no"))]

@subsection{FHIR Shorthand}

A file is compiled together with the other @tt{.fsh} files of its project, so a profile in one file
can be the Parent of a profile in another. The project is the folder that holds the nearest
@tt{sushi-config.yaml} (beside the file, or up to two folders above), and that file gives the
project's address, its FHIR version and the packages it depends on. Without one, the project is the
file's own folder and FHIR R5 is assumed. A problem in another file of the project is reported on
that file.

@itemlist[
@item{@bold{Hover} on a rule's element path shows what the base type says about that element: its
path, how many values it may have, its types, its short description and definition. The base is the
file's @tt{Parent} or @tt{InstanceOf}, followed through the project's own profiles and aliases.
Hover on a name shows the declaration it refers to.}
@item{@bold{Go to definition} on a name opens its declaration, in whichever file of the project
has it: a Parent, an InstanceOf, a value set in a binding, an alias, a RuleSet in an @tt{insert},
an invariant, an instance in a @tt{Reference}. A name is found by name, by id or by its address.}
@item{@bold{Completion.} At the start of a line: the keywords that begin an entity or its header.
After @tt{Parent:} or @tt{InstanceOf:}: the FHIR types and the project's profiles, extensions and
models. After @tt{from}: its value sets and aliases; after @tt{insert}: its rule sets; after
@tt{obeys}: its invariants. After @tt{* } and the start of a path: the base type's elements at that
point, each with its cardinality, types and short description. After a path: the flags and rule
keywords.}
@item{@bold{Outline}: the file's aliases, profiles, extensions, value sets, instances and the rest,
in order.}]

These four read the text, not a finished compile, so they work while the file still has mistakes
in it.

@subsection{CQL and the mapping language}

@itemlist[
@item{@bold{Outline.} A CQL library's includes, value sets, code systems, parameters, context and
definitions. A map's imports, concept maps and groups.}
@item{@bold{Hover} on a name shows the text of its declaration.}
@item{@bold{Go to definition} jumps to the declaration in the file. In CQL, the name of an included
library, or its alias, opens that library's file when it is in the same folder (@tt{X.cql},
@tt{X-<version>.cql}, or the file whose @tt{library} line names it), and @tt{C."Age"} opens the
definition inside it. In a map, the address after @tt{imports} opens the map that declares that
address, and a group it defines is found there.}
@item{@bold{Completion} offers the names the file declares and the language's keywords that start
with what you have typed. Inside quotes, names only.}]

CQL's warnings are shown as warnings. One worth knowing: comparing an Observation's time with a
period when that time may be a single moment (@secref["check"] shows it).

@section[#:tag "check"]{Checking files without an editor}

@tt{raco fhir-lsp check} runs the same check on files you name and prints the result. Use it to see
what the editor should be showing, or in a script.

@verbatim{
$ raco fhir-lsp check adults.cql
adults.cql:4:15: cql compile error: in define "Age": unknown function 'AgeInYear' (did you mean `AgeInYears` or `AgeInYearsAt`?)
 4 | define "Age": AgeInYear()
   |               ^^^^^^^^^
}

Each problem is one line saying where it is and what it is, then the line of the file with a marker
under the place. A warning looks the same and says @tt{warning}:

@verbatim{
$ raco fhir-lsp check warn.cql
warn.cql:6:1: cql compile warning: in define "In Period": Choice<dateTime, Period, Timing, instant> against an interval reads only its Period member: a dateTime value gives null. Say which member you mean: (… as dateTime)
 6 | define "In Period": [Observation] O where O.effective during "Measurement Period"
   | ^^^^^^
}

You can name several files, of different languages. @litchar{--format json} prints the problems as
JSON and @litchar{--format outcome} as a FHIR OperationOutcome resource, for a program to read. The
command exits with 1 when any problem is an error, 0 otherwise (warnings alone are 0), and 2 when a
file does not exist. A file that is not in one of the five languages is skipped with a note. A
FHIR Shorthand file is checked with its project, as in the editor, so the problems of the project's
other files are listed too.

@tabular[#:style 'boxed #:sep @hspace[2]
(list (list @bold{command} @bold{what it does})
      (list @tt{raco fhir-lsp} "the server, for an editor to start; it reads and writes the protocol on standard input and output")
      (list @tt{raco fhir-lsp check <file>…} "the problems in those files, printed")
      (list @tt{raco fhir-lsp languages} "the languages served and their file extensions"))]

@section{How it works}

You do not need this to use the server. It explains what to expect from it.

@bold{The server knows no language.} Each language package provides one value, its
@italic{support}, with six functions: the problems in a text, the files that belong with it, its
declarations, hover, definition and completion. The server loads a language's support the first time
a file of that language is opened, and passes requests on. So a change to a language and to what the
editor shows for it are made, and tested, in the same place. A language that is not installed costs
nothing and breaks nothing.

@bold{Typing is never held up.} When you change a file, the server stores the new text at once, so
hover and completion see it. The check itself runs on the side. If you type again before it has
finished, the older result is thrown away, so you never see problems from a text you have since
changed.

@bold{The project is the files around the document.} For hover, definition and completion the
server gathers the declarations of the files that belong with the one you are in (a FHIR Shorthand
project's @tt{.fsh} files, the libraries beside a CQL library), reading open files as the editor
holds them and the rest from disk.

@bold{The protocol.} The server answers @tt{initialize}, @tt{shutdown} and @tt{exit};
@tt{textDocument/didOpen}, @tt{didChange}, @tt{didSave} and @tt{didClose};
@tt{textDocument/hover}, @tt{textDocument/definition}, @tt{textDocument/completion} and
@tt{textDocument/documentSymbol}; and sends @tt{textDocument/publishDiagnostics}. Any other request
is answered with "method not found"; other notifications are ignored. It asks the editor for the
whole text on each change.

@section{Limits}

@itemlist[
@item{@bold{FHIR Shorthand examples are compiled, not validated.} The server reports what compiling
the project finds. It does not hold each example to the profile it claims; @tt{raco fsh check
<folder>} does that, and names the rule an example breaks.}
@item{@bold{Hover, definition, completion and outline read the text.} A name is the word under the
cursor. An FHIR Shorthand element is looked up in the base type as FHIR defines it, not as a
profile or a dependency has narrowed it.}
@item{@bold{CQL and the mapping language look beside the file.} Names resolve within the file, and
includes and imports reach files in the same folder. Completion of element paths is for FHIR
Shorthand only.}
@item{@bold{VCL and FHIRPath} get their problems reported and nothing else. For FHIRPath that means
syntax: a misspelt element is not reported, because a file holds an expression and not the resource
it is asked of.}
@item{@bold{No formatting, renaming or "find references".}}
@item{@bold{A problem without a position lands on the first character} of the file. A language
that is not installed is reported that way.}
@item{@bold{Whole texts only.} The server asks for the full text on every change. Every editor
supports this; on a very large file it is more to send.}]

@section{Words used here}

@itemlist[
@item{@bold{Language server}: a program an editor runs in the background to learn about a language:
its mistakes, its names, its completions.}
@item{@bold{Language Server Protocol} (LSP): the common way editors and language servers talk, so
one server works in many editors.}
@item{@bold{Client}: the editor's side of that conversation. Neovim has one built in; Emacs has
@tt{eglot}; VS Code uses an extension.}
@item{@bold{Diagnostic}: one problem the server reports, with its place and whether it is an error
or a warning.}
@item{@bold{Hover}: what the editor shows when you rest on a name. @bold{Go to definition}: jumping
from a name to where it is declared. @bold{Completion}: the list of what could come next.
@bold{Outline} (document symbols): the list of what a file declares.}
@item{@bold{Standard input and output} (stdio): the ordinary way a program reads and writes text;
here, how the editor and the server exchange messages.}
@item{@bold{Profile}, @bold{instance}: in FHIR Shorthand, a set of rules for a kind of resource,
and an example resource. @bold{Parent} and @bold{InstanceOf} name what each is based on.}
@item{@bold{@tt{sushi-config.yaml}}: the file that states a FHIR Shorthand project's address, FHIR
version and dependencies.}]

@section{How it is tested}

@itemlist[
@item{The server's handling of each message is tested as a function from a message and a state to
an answer: the handshake, opening, changing and closing a file, hover, definition, completion and
outline, a message that is not JSON, shutting down.}
@item{Each language's support is run on a small file with a mistake and on the corrected file: the
problem must be an error naming the file (and, for FHIR Shorthand, the line), and the corrected
file must come back clean.}
@item{What each language reports is tested in that language's own repository, against the
published test suites the family's @tt{TESTING.md} files describe.}
@item{The Neovim and Emacs configurations above are run in the editors themselves
(@tt{tests/editors-test.rkt}, with Neovim 0.10.4 and Emacs 29.3): each block is read out of this
page as written and given to a headless editor, which opens the @tt{bp.fsh} of step 3. The server
must attach, the misspelling must be reported with the message quoted there, hover on @tt{subject}
must answer, and the correction must clear the problem. The test is skipped where an editor is not
installed. VS Code is not tested: there is no extension of ours to run.}]

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

@subsection[#:style 'unnumbered]{@tt{fhir/lsp/languages}}
@defmodule[fhir/lsp/languages]

@defstruct*[language ([id string?] [extensions (listof string?)])]{
A language the server knows: its @tt{languageId} (also its collection) and the file extensions it
owns. The catalogue is the foundation's (@tt{fhir/lang/support}).}
@defthing[languages (listof language?)]{The catalogue: fsh, cql, fml, vcl, fhirpath.}
@defproc[(language-of [path path-string?]) (or/c language? #f)]{By file extension.}
@defproc[(language-by-id [id string?]) (or/c language? #f)]
@defproc[(support-of [l language?]) (or/c lang-support? #f)]{The language's support, loaded from its
package's @tt{<id>/support} module on first use; @racket[#f] when the package is not installed.}
@defproc[(diagnose [l language?] [text string?] [path path-string?]) (listof diagnostic?)]{
Every problem in the document, through its support; a language that is not installed answers one
diagnostic saying so, and a support that fails answers one diagnostic with its message — never an
exception.}

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
@defproc[(message->bytes [m hash?]) bytes?]{The message as it goes over the wire, header and body.}
@deftogether[(
@defproc[(request [id any/c] [method string?] [params any/c #f]) hash?]
@defproc[(notification [method string?] [params any/c #f]) hash?]
@defproc[(response [id any/c] [result any/c]) hash?]
@defproc[(error-response [id any/c] [code exact-integer?] [message string?] [data any/c #f]) hash?])]{The message constructors.}
@deftogether[(@defproc[(request? [m any/c]) boolean?] @defproc[(notification? [m any/c]) boolean?] @defproc[(response? [m any/c]) boolean?])]
@deftogether[(
@defproc[(message-method [m hash?]) (or/c string? #f)]
@defproc[(message-id [m hash?]) any/c]
@defproc[(message-params [m hash?]) any/c])]{A message's parts.}
@deftogether[(
@defthing[parse-error exact-integer?]
@defthing[invalid-request exact-integer?]
@defthing[method-not-found exact-integer?]
@defthing[invalid-params exact-integer?]
@defthing[internal-error exact-integer?])]{The error codes the protocol reserves.}
