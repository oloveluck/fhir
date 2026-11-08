1344
((3) 0 () 5 ((q lib "fhir/mcp/tools.rkt") (q 3790 . 6) (q lib "fhir/mcp/server.rkt") (q 4929 . 4) (q lib "fhir/mcp/workspace.rkt")) () (h ! (equal) ((c def c (c (? . 0) q tool-description)) c (? . 1)) ((c def c (c (? . 0) q struct:tool)) c (? . 1)) ((c def c (c (? . 2) q state-initialized?)) c (? . 3)) ((c def c (c (? . 0) q tool?)) c (? . 1)) ((c def c (c (? . 0) q load-operations!)) q (4100 . 2)) ((c def c (c (? . 2) q struct:state)) c (? . 3)) ((c def c (c (? . 0) q tool-input-schema)) c (? . 1)) ((c def c (c (? . 0) q element-info)) q (4284 . 4)) ((c def c (c (? . 0) q call-tool)) q (3946 . 4)) ((c def c (c (? . 2) q state-tools)) c (? . 3)) ((c def c (c (? . 0) q tool-name)) c (? . 1)) ((c def c (c (? . 0) q tool)) c (? . 1)) ((q def ((lib "fhir/mcp/verbs.rkt") workspace-tools)) q (3733 . 3)) ((c def c (c (? . 2) q serve)) q (4648 . 5)) ((c def c (c (? . 4) q with-hub)) q (3654 . 4)) ((c def c (c (? . 2) q dispatch)) q (4824 . 4)) ((c def c (c (? . 2) q state?)) c (? . 3)) ((c def c (c (? . 0) q apply-json)) q (4152 . 5)) ((c def c (c (? . 2) q state)) c (? . 3)) ((c def c (c (? . 4) q open-hub)) q (3402 . 7)) ((c def c (c (? . 0) q find-definitions)) q (4403 . 7)) ((c def c (c (? . 2) q protocol-version)) q (5032 . 2)) ((c def c (c (? . 0) q tool-run)) c (? . 1)) ((c def c (c (? . 0) q tool->jsexpr)) q (4045 . 3))))

file          language                                                       run gives                                                explain gives
*.fsh         FHIR Shorthand: profiles, extensions, value sets, examples     the resources the file defines; every example validated  an entity's problems, each traced to its rule
*.cql         Clinical Quality Language                                      every define's value for every patient, and counts       one patient's define, down through the defines it uses to the retrieves:
                                                                                                                                      how many resources of the type the patient has, which were kept
*.fhirpath    one FHIRPath expression                                        its value over each resource it reads                    the value of every part of it over one resource
*.vcl         one VCL expression: a ValueSet at <canonical>/ValueSet/<file>  the expansion                                            which part of the expression holds a code
*.map, *.fml  FHIR Mapping Language                                          each source resource transformed, the result validated   one transform's result and its problems, traced to rules
*.view.json   a SQL on FHIR ViewDefinition                                   its rows                                                 the rows one resource produces, and whether each where holds
*.json        any FHIR resource                                              a Measure: $evaluate-measure; anything else: $validate   its validation issues

tool      arguments                         does
write     path, text                        saves a file (empty text deletes it) and answers its problems in the
                                            same call; never outside the workspace or into the data
check     paths?                            every problem, and the configuration: FHIR version, packages, data
run       path, entry?, over?, parameters?  a file against the data: a summary, the first rows, and a handle
                                            result://rN
query     language, text, …                 the same without a file: fhirpath, cql (an expression is evaluated per
                                            patient), vcl, search (Type?params, on a FHIR server), view
explain   ref, subject, entry?              why one subject's answer is what it is (a result or a file)
describe  ref, offset?, limit?, against?    anything by reference: a result (paged, or compared with another),
                                            Type/id, a canonical, a type or element, an operation and its inputs, a
                                            fragment of a name
apply     operation, inputs?, resource?     any registered FHIR operation, in the workspace's context
stage     resources | result | path         a write prepared: each resource validated and compared with the data's
                                            copy (create, update and its changed paths, unchanged)
commit    stage                             a stage written: to a data directory (a file per resource), or a FHIR
                                            server when allowed; a stage with errors is refused
procedure
(open-hub  dir                       
          [#:data data               
           #:packages packages]) -> hub?
  dir : path-string?
  data : (or/c string? #f) = #f
  packages : (listof string?) = '()
procedure
(with-hub h thunk) -> any
  h : hub?
  thunk : (-> any)
procedure
(workspace-tools h) -> list?
  h : hub?
struct
(struct tool (name description input-schema run))
  name : string?
  description : string?
  input-schema : hash?
  run : procedure?
procedure
(call-tool t arguments) -> string? boolean?
  t : tool?
  arguments : hash?
procedure
(tool->jsexpr t) -> hash?
  t : tool?
procedure
(load-operations!) -> (listof symbol?)
procedure
(apply-json o inputs resource) -> hash?
  o : operation?
  inputs : hash?
  resource : (or/c hash? #f)
procedure
(element-info type path) -> (or/c list? string?)
  type : string?
  path : (or/c string? #f)
procedure
(find-definitions fragment          
                  resource-type     
                  limit)        -> list?
  fragment : string?
  resource-type : (or/c string? #f)
  limit : exact-positive-integer?
procedure
(serve tools [in out]) -> void?
  tools : (listof tool?)
  in : input-port? = (current-input-port)
  out : output-port? = (current-output-port)
procedure
(dispatch message st) -> (or/c hash? #f) state?
  message : hash?
  st : state?
struct
(struct state (tools initialized?))
  tools : (listof tool?)
  initialized? : boolean?
value
protocol-version : string?
