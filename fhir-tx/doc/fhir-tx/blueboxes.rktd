2391
((3) 0 () 3 ((q lib "fhir/terminology/service.rkt") (q lib "fhir/terminology/operations.rkt") (q 3162 . 5)) () (h ! (equal) ((c def c (c (? . 0) q make-r5-terminology)) q (778 . 2)) ((c def c (c (? . 0) q packages->code-systems)) q (4892 . 3)) ((c def c (c (? . 0) q make-cs-validate)) q (5266 . 3)) ((c def c (c (? . 1) q $validate-code)) q (5462 . 2)) ((c def c (c (? . 0) q terminology-capabilities)) q (4998 . 5)) ((c def c (c (? . 0) q validate-code/json)) q (1722 . 24)) ((c def c (c (? . 1) q current-terminology-capabilities)) q (5852 . 3)) ((c def c (c (? . 0) q closure-relation)) q (4618 . 9)) ((c def c (c (? . 1) q $closure)) q (5664 . 2)) ((c def c (c (? . 0) q make-terminology/resolver)) q (1082 . 3)) ((c def c (c (? . 0) q struct:version-policy)) c (? . 2)) ((c def c (c (? . 0) q subsumes/json)) q (3880 . 11)) ((c def c (c (? . 1) q $find-matches)) q (5597 . 2)) ((c def c (c (? . 1) q $translate)) q (5632 . 2)) ((c def c (c (? . 0) q version-policy-default)) c (? . 2)) ((c def c (c (? . 1) q $cs-validate-code)) q (5498 . 2)) ((c def c (c (? . 1) q current-terminology-resolver)) q (5694 . 3)) ((c def c (c (? . 0) q make-r4-terminology)) q (827 . 2)) ((c def c (c (? . 0) q cs-validate-code/json)) q (3449 . 11)) ((c def c (c (? . 0) q make-terminology)) q (700 . 3)) ((c def c (c (? . 1) q $subsumes)) q (5566 . 2)) ((c def c (c (? . 0) q version-policy-check)) c (? . 2)) ((c def c (c (? . 0) q translate/json)) q (2982 . 6)) ((c def c (c (? . 0) q resources->resolver)) q (1272 . 3)) ((c def c (c (? . 0) q version-policy)) c (? . 2)) ((c def c (c (? . 0) q make-terminology/packages)) q (876 . 3)) ((c def c (c (? . 0) q version-policy?)) c (? . 2)) ((c def c (c (? . 0) q make-undecidable?)) q (5349 . 3)) ((c def c (c (? . 1) q $expand)) q (5433 . 2)) ((c def c (c (? . 1) q terminology-operations)) q (5798 . 2)) ((c def c (c (? . 0) q expand/json)) q (1365 . 11)) ((c def c (c (? . 0) q make-lookup)) q (5188 . 3)) ((c def c (c (? . 0) q lookup/json)) q (2797 . 6)) ((c def c (c (? . 0) q policy-of)) q (3321 . 5)) ((c def c (c (? . 1) q $lookup)) q (5537 . 2)) ((c def c (c (? . 0) q no-version-policy)) q (3277 . 2)) ((c def c (c (? . 0) q packages->resolver)) q (1175 . 3)) ((c def c (c (? . 0) q find-matches/json)) q (4216 . 11)) ((c def c (c (? . 0) q make-terminology/resources)) q (981 . 3)) ((c def c (c (? . 0) q version-policy-force)) c (? . 2))))

raco fhir-tx expand <ValueSet url> [–filter t] [–count n] [–offset n]   the expansion
raco fhir-tx validate-code <ValueSet url> <system> <code> [–display t]  is the code in the set
raco fhir-tx lookup <system> <code>                                     a concept's details
raco fhir-tx translate <ConceptMap url> <code> [–system s]              a code through a map
raco fhir-tx subsumes <system> <codeA> <codeB>                          the subsumption relation
raco fhir-tx serve [–port n]                                            every operation over HTTP
raco fhir-tx tck [-v]                                                   the tx-ecosystem suite, floor-ratcheted
procedure
(make-terminology core) -> tx-service?
  core : path-string?
procedure
(make-r5-terminology) -> tx-service?
procedure
(make-r4-terminology) -> tx-service?
procedure
(make-terminology/packages packages) -> tx-service?
  packages : (listof path-string?)
procedure
(make-terminology/resources resources) -> tx-service?
  resources : (listof hash?)
procedure
(make-terminology/resolver resolver) -> tx-service?
  resolver : procedure?
procedure
(packages->resolver packages) -> procedure?
  packages : (listof path-string?)
procedure
(resources->resolver resources) -> procedure?
  resources : (listof hash?)
procedure
(expand/json  resolver     
              url          
             [version      
              params       
              policy]) -> hash?
  resolver : procedure?
  url : string?
  version : (or/c string? #f) = #f
  params : hash? = (hash)
  policy : version-policy? = no-version-policy
procedure
(validate-code/json  resolver                            
                     url                                 
                    [code                                
                     system                              
                     #:coding coding                     
                     #:codeable-concept concept          
                     #:display display                   
                     #:lenient-display? lenient?         
                     #:system-version system-version     
                     #:valueset-version valueset-version 
                     #:policy policy])                   
 -> hash?
  resolver : procedure?
  url : string?
  code : (or/c string? #f) = #f
  system : (or/c string? #f) = #f
  coding : any/c = #f
  concept : any/c = #f
  display : any/c = #f
  lenient? : boolean? = #f
  system-version : any/c = #f
  valueset-version : any/c = #f
  policy : version-policy? = no-version-policy
procedure
(lookup/json resolver system code [version]) -> hash?
  resolver : procedure?
  system : string?
  code : string?
  version : (or/c string? #f) = #f
procedure
(translate/json resolver url code [system]) -> hash?
  resolver : procedure?
  url : string?
  code : string?
  system : (or/c string? #f) = #f
struct
(struct version-policy (default force check))
  default : hash?
  force : hash?
  check : hash?
value
no-version-policy : version-policy?
procedure
(policy-of default force check) -> version-policy?
  default : any/c
  force : any/c
  check : any/c
procedure
(cs-validate-code/json  resolver                
                        system                  
                        code                    
                       [version                 
                        #:display display]) -> hash?
  resolver : procedure?
  system : string?
  code : string?
  version : (or/c string? #f) = #f
  display : any/c = #f
procedure
(subsumes/json  resolver      
                system        
                code-a        
                code-b        
               [version]) -> hash?
  resolver : procedure?
  system : string?
  code-a : string?
  code-b : string?
  version : (or/c string? #f) = #f
procedure
(find-matches/json  resolver       
                    system         
                    properties     
                   [version        
                    exact?])   -> hash?
  resolver : procedure?
  system : string?
  properties : (listof (cons/c string? string?))
  version : (or/c string? #f) = #f
  exact? : boolean? = #t
procedure
(closure-relation resolver     
                  system       
                  code-a       
                  code-b)  -> (or/c string? #f)
  resolver : procedure?
  system : string?
  code-a : string?
  code-b : string?
procedure
(packages->code-systems packages) -> (listof hash?)
  packages : (listof path-string?)
procedure
(terminology-capabilities  code-systems     
                          [#:url url])  -> hash?
  code-systems : (listof hash?)
  url : (or/c string? #f) = #f
procedure
(make-lookup resolver) -> procedure?
  resolver : procedure?
procedure
(make-cs-validate resolver) -> procedure?
  resolver : procedure?
procedure
(make-undecidable? resolver) -> procedure?
  resolver : procedure?
value
$expand : procedure?
value
$validate-code : procedure?
value
$cs-validate-code : procedure?
value
$lookup : procedure?
value
$subsumes : procedure?
value
$find-matches : procedure?
value
$translate : procedure?
value
$closure : procedure?
procedure
(current-terminology-resolver [extra]) -> procedure?
  extra : (listof hash?) = '()
value
terminology-operations : (listof procedure?)
procedure
(current-terminology-capabilities [#:url url]) -> hash?
  url : (or/c string? #f) = #f
