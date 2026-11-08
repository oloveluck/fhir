1836
((3) 0 () 6 ((q lib "fhir/lsp/jsonrpc.rkt") (q lib "fhir/lsp/languages.rkt") (q lib "fhir/lsp/diagnostics.rkt") (q 1252 . 4) (q lib "fhir/lsp/server.rkt") (q 1064 . 5)) () (h ! (equal) ((c def c (c (? . 1) q support-of)) q (1549 . 3)) ((c def c (c (? . 0) q notification?)) q (2778 . 3)) ((c def c (c (? . 0) q response)) q (2482 . 4)) ((c def c (c (? . 0) q read-message)) q (2086 . 3)) ((c def c (c (? . 2) q uri->path)) q (2016 . 3)) ((c def c (c (? . 1) q struct:language)) c (? . 3)) ((c def c (c (? . 2) q group-by-uri)) q (1820 . 4)) ((c def c (c (? . 4) q state-down?)) c (? . 5)) ((c def c (c (? . 1) q language-of)) q (1389 . 3)) ((c def c (c (? . 0) q error-response)) q (2564 . 6)) ((c def c (c (? . 1) q language?)) c (? . 3)) ((c def c (c (? . 2) q diagnostic->lsp)) q (1756 . 3)) ((c def c (c (? . 0) q write-message)) q (2170 . 4)) ((c def c (c (? . 4) q server-capabilities)) q (1216 . 2)) ((c def c (c (? . 0) q request?)) q (2724 . 3)) ((c def c (c (? . 1) q language-extensions)) c (? . 3)) ((c def c (c (? . 0) q response?)) q (2837 . 3)) ((c def c (c (? . 4) q state-documents)) c (? . 5)) ((c def c (c (? . 1) q languages)) q (1349 . 2)) ((c def c (c (? . 4) q state?)) c (? . 5)) ((c def c (c (? . 4) q state)) c (? . 5)) ((c def c (c (? . 1) q language-id)) c (? . 3)) ((c def c (c (? . 0) q request)) q (2256 . 5)) ((c def c (c (? . 1) q language-by-id)) q (1472 . 3)) ((c def c (c (? . 2) q path->uri)) q (1955 . 3)) ((c def c (c (? . 4) q serve)) q (803 . 4)) ((c def c (c (? . 4) q struct:state)) c (? . 5)) ((c def c (c (? . 1) q language)) c (? . 3)) ((c def c (c (? . 4) q initial-state)) q (1185 . 2)) ((c def c (c (? . 1) q diagnose)) q (1626 . 5)) ((c def c (c (? . 0) q notification)) q (2377 . 4)) ((c def c (c (? . 4) q dispatch)) q (942 . 4)) ((c def c (c (? . 4) q state-published)) c (? . 5))))

language  on open, change and save
fsh       the whole project compiled with the document's text in place of the file
          on disk: parse errors, unknown element paths at their rule, entities
          that fail, every example validated against the project's profiles
          (positioned at the instance rule, naming the profile rule); diagnostics
          for other files of the project are published too
cql       parse errors; every definition translated, each failure at its define
fml       parse errors; the map checked against its structures (an element the
          type lacks, a value that cannot go into its element, a wrong group call,
          a required target never assigned)
vcl       the expression parsed and compiled to a compose
fhirpath  the expression parsed
procedure
(serve [in out]) -> void?
  in : input-port? = (current-input-port)
  out : output-port? = (current-output-port)
procedure
(dispatch message st) -> (or/c hash? #f) state? (listof hash?)
  message : hash?
  st : state?
struct
(struct state (documents published down?))
  documents : hash?
  published : hash?
  down? : boolean?
value
initial-state : state?
value
server-capabilities : hash?
struct
(struct language (id extensions))
  id : string?
  extensions : (listof string?)
value
languages : (listof language?)
procedure
(language-of path) -> (or/c language? #f)
  path : path-string?
procedure
(language-by-id id) -> (or/c language? #f)
  id : string?
procedure
(support-of l) -> (or/c lang-support? #f)
  l : language?
procedure
(diagnose l text path) -> (listof diagnostic?)
  l : language?
  text : string?
  path : path-string?
procedure
(diagnostic->lsp d) -> hash?
  d : diagnostic?
procedure
(group-by-uri ds default) -> (hash/c string? (listof hash?))
  ds : (listof diagnostic?)
  default : string?
procedure
(path->uri p) -> string?
  p : path-string?
procedure
(uri->path uri) -> (or/c path? #f)
  uri : string?
procedure
(read-message in) -> (or/c hash? eof-object?)
  in : input-port?
procedure
(write-message m out) -> void?
  m : hash?
  out : output-port?
procedure
(request id method [params]) -> hash?
  id : any/c
  method : string?
  params : any/c = #f
procedure
(notification method [params]) -> hash?
  method : string?
  params : any/c = #f
procedure
(response id result) -> hash?
  id : any/c
  result : any/c
procedure
(error-response id code message [data]) -> hash?
  id : any/c
  code : exact-integer?
  message : string?
  data : any/c = #f
procedure
(request? m) -> boolean?
  m : any/c
procedure
(notification? m) -> boolean?
  m : any/c
procedure
(response? m) -> boolean?
  m : any/c
