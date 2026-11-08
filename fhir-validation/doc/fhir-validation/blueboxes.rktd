658
((3) 0 () 3 ((q lib "fhir/conformance/validate.rkt") (q 479 . 6) (q lib "fhir/conformance/operations.rkt")) () (h ! (equal) ((c def c (c (? . 0) q issue-code)) c (? . 1)) ((c def c (c (? . 2) q $validate)) q (1083 . 2)) ((c def c (c (? . 0) q issue?)) c (? . 1)) ((c def c (c (? . 0) q issue-severity)) c (? . 1)) ((c def c (c (? . 0) q validate-json)) q (625 . 11)) ((c def c (c (? . 0) q issue-msg)) c (? . 1)) ((c def c (c (? . 0) q struct:issue)) c (? . 1)) ((c def c (c (? . 0) q issue)) c (? . 1)) ((c def c (c (? . 0) q issue-path)) c (? . 1)) ((c def c (c (? . 0) q validate-issues)) q (0 . 11)) ((c def c (c (? . 2) q ensure-valid)) q (1114 . 4))))
procedure
(validate-issues  resource                      
                 [#:profiles profiles           
                  #:terminology terminology     
                  #:invariants? invariants?     
                  #:duplicates duplicates]) -> (listof issue?)
  resource : hash?
  profiles : (listof hash?) = '()
  terminology : any/c = #f
  invariants? : boolean? = #t
  duplicates : (listof string?) = '()
struct
(struct issue (severity code path msg))
  severity : string?
  code : string?
  path : (or/c string? #f)
  msg : string?
procedure
(validate-json  resource                      
               [#:profiles profiles           
                #:terminology terminology     
                #:invariants? invariants?     
                #:duplicates duplicates]) -> any/c
  resource : hash?
  profiles : (listof hash?) = '()
  terminology : any/c = #f
  invariants? : boolean? = #t
  duplicates : (listof string?) = '()
value
$validate : procedure?
procedure
(ensure-valid resource [#:profile profile]) -> hash?
  resource : hash?
  profile : (or/c string? #f) = #f
