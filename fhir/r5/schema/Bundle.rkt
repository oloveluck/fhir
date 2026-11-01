#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'Bundle (fhir-spec 'Bundle "https://hl7.org/fhir/R5/bundle.html#Bundle" 'type)
  #:schema (type-schema 'Bundle #f 'Resource "https://hl7.org/fhir/R5/bundle.html#Bundle"
             (list
    (schema-field 'identifier 0 1 (vector 'type 'Identifier) #f "https://hl7.org/fhir/R5/bundle.html#Bundle.identifier" #f)
    (schema-field 'type 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/bundle.html#Bundle.type" #f)
    (schema-field 'timestamp 0 1 (vector 'prim "instant") #f "https://hl7.org/fhir/R5/bundle.html#Bundle.timestamp" #f)
    (schema-field 'total 0 1 (vector 'prim "unsignedInt") #f "https://hl7.org/fhir/R5/bundle.html#Bundle.total" #f)
    (schema-field 'link 0 '* (vector 'type 'BundleLink) #f "https://hl7.org/fhir/R5/bundle.html#Bundle.link" #f)
    (schema-field 'entry 0 '* (vector 'type 'BundleEntry) #f "https://hl7.org/fhir/R5/bundle.html#Bundle.entry" #f)
    (schema-field 'signature 0 1 (vector 'type 'Signature) #f "https://hl7.org/fhir/R5/bundle.html#Bundle.signature" #f)
    (schema-field 'issues 0 1 (vector 'resource) #f "https://hl7.org/fhir/R5/bundle.html#Bundle.issues" #f)
             ) #f #f))
(register-element! "Bundle.identifier" (fhir-spec (string->symbol "Bundle.identifier") "https://hl7.org/fhir/R5/bundle.html#Bundle.identifier" 'element))
(register-element! "Bundle.type" (fhir-spec (string->symbol "Bundle.type") "https://hl7.org/fhir/R5/bundle.html#Bundle.type" 'element))
(register-element! "Bundle.timestamp" (fhir-spec (string->symbol "Bundle.timestamp") "https://hl7.org/fhir/R5/bundle.html#Bundle.timestamp" 'element))
(register-element! "Bundle.total" (fhir-spec (string->symbol "Bundle.total") "https://hl7.org/fhir/R5/bundle.html#Bundle.total" 'element))
(register-element! "Bundle.link" (fhir-spec (string->symbol "Bundle.link") "https://hl7.org/fhir/R5/bundle.html#Bundle.link" 'element))
(register-element! "Bundle.entry" (fhir-spec (string->symbol "Bundle.entry") "https://hl7.org/fhir/R5/bundle.html#Bundle.entry" 'element))
(register-element! "Bundle.signature" (fhir-spec (string->symbol "Bundle.signature") "https://hl7.org/fhir/R5/bundle.html#Bundle.signature" 'element))
(register-element! "Bundle.issues" (fhir-spec (string->symbol "Bundle.issues") "https://hl7.org/fhir/R5/bundle.html#Bundle.issues" 'element))

(register-type! 'BundleLink (fhir-spec 'BundleLink "https://hl7.org/fhir/R5/bundle.html#Bundle.link" 'type)
  #:schema (type-schema 'BundleLink #f 'BackboneElement "https://hl7.org/fhir/R5/bundle.html#Bundle.link"
             (list
    (schema-field 'relation 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/bundle.html#Bundle.link.relation" #f)
    (schema-field 'url 1 1 (vector 'prim "uri") #f "https://hl7.org/fhir/R5/bundle.html#Bundle.link.url" #f)
             ) #f #f))
(register-element! "Bundle.link.relation" (fhir-spec (string->symbol "Bundle.link.relation") "https://hl7.org/fhir/R5/bundle.html#Bundle.link.relation" 'element))
(register-element! "Bundle.link.url" (fhir-spec (string->symbol "Bundle.link.url") "https://hl7.org/fhir/R5/bundle.html#Bundle.link.url" 'element))

(register-type! 'BundleEntry (fhir-spec 'BundleEntry "https://hl7.org/fhir/R5/bundle.html#Bundle.entry" 'type)
  #:schema (type-schema 'BundleEntry #f 'BackboneElement "https://hl7.org/fhir/R5/bundle.html#Bundle.entry"
             (list
    (schema-field 'link 0 '* (vector 'type 'BundleLink) #f "https://hl7.org/fhir/R5/bundle.html#Bundle.entry.link" #f)
    (schema-field 'fullUrl 0 1 (vector 'prim "uri") #f "https://hl7.org/fhir/R5/bundle.html#Bundle.entry.fullUrl" #f)
    (schema-field 'resource 0 1 (vector 'resource) #f "https://hl7.org/fhir/R5/bundle.html#Bundle.entry.resource" #f)
    (schema-field 'search 0 1 (vector 'type 'BundleEntrySearch) #f "https://hl7.org/fhir/R5/bundle.html#Bundle.entry.search" #f)
    (schema-field 'request 0 1 (vector 'type 'BundleEntryRequest) #f "https://hl7.org/fhir/R5/bundle.html#Bundle.entry.request" #f)
    (schema-field 'response 0 1 (vector 'type 'BundleEntryResponse) #f "https://hl7.org/fhir/R5/bundle.html#Bundle.entry.response" #f)
             ) #f #f))
(register-element! "Bundle.entry.link" (fhir-spec (string->symbol "Bundle.entry.link") "https://hl7.org/fhir/R5/bundle.html#Bundle.entry.link" 'element))
(register-element! "Bundle.entry.fullUrl" (fhir-spec (string->symbol "Bundle.entry.fullUrl") "https://hl7.org/fhir/R5/bundle.html#Bundle.entry.fullUrl" 'element))
(register-element! "Bundle.entry.resource" (fhir-spec (string->symbol "Bundle.entry.resource") "https://hl7.org/fhir/R5/bundle.html#Bundle.entry.resource" 'element))
(register-element! "Bundle.entry.search" (fhir-spec (string->symbol "Bundle.entry.search") "https://hl7.org/fhir/R5/bundle.html#Bundle.entry.search" 'element))
(register-element! "Bundle.entry.request" (fhir-spec (string->symbol "Bundle.entry.request") "https://hl7.org/fhir/R5/bundle.html#Bundle.entry.request" 'element))
(register-element! "Bundle.entry.response" (fhir-spec (string->symbol "Bundle.entry.response") "https://hl7.org/fhir/R5/bundle.html#Bundle.entry.response" 'element))

(register-type! 'BundleEntrySearch (fhir-spec 'BundleEntrySearch "https://hl7.org/fhir/R5/bundle.html#Bundle.entry.search" 'type)
  #:schema (type-schema 'BundleEntrySearch #f 'BackboneElement "https://hl7.org/fhir/R5/bundle.html#Bundle.entry.search"
             (list
    (schema-field 'mode 0 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/bundle.html#Bundle.entry.search.mode" #f)
    (schema-field 'score 0 1 (vector 'prim "decimal") #f "https://hl7.org/fhir/R5/bundle.html#Bundle.entry.search.score" #f)
             ) #f #f))
(register-element! "Bundle.entry.search.mode" (fhir-spec (string->symbol "Bundle.entry.search.mode") "https://hl7.org/fhir/R5/bundle.html#Bundle.entry.search.mode" 'element))
(register-element! "Bundle.entry.search.score" (fhir-spec (string->symbol "Bundle.entry.search.score") "https://hl7.org/fhir/R5/bundle.html#Bundle.entry.search.score" 'element))

(register-type! 'BundleEntryRequest (fhir-spec 'BundleEntryRequest "https://hl7.org/fhir/R5/bundle.html#Bundle.entry.request" 'type)
  #:schema (type-schema 'BundleEntryRequest #f 'BackboneElement "https://hl7.org/fhir/R5/bundle.html#Bundle.entry.request"
             (list
    (schema-field 'method 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/bundle.html#Bundle.entry.request.method" #f)
    (schema-field 'url 1 1 (vector 'prim "uri") #f "https://hl7.org/fhir/R5/bundle.html#Bundle.entry.request.url" #f)
    (schema-field 'ifNoneMatch 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/bundle.html#Bundle.entry.request.ifNoneMatch" #f)
    (schema-field 'ifModifiedSince 0 1 (vector 'prim "instant") #f "https://hl7.org/fhir/R5/bundle.html#Bundle.entry.request.ifModifiedSince" #f)
    (schema-field 'ifMatch 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/bundle.html#Bundle.entry.request.ifMatch" #f)
    (schema-field 'ifNoneExist 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/bundle.html#Bundle.entry.request.ifNoneExist" #f)
             ) #f #f))
(register-element! "Bundle.entry.request.method" (fhir-spec (string->symbol "Bundle.entry.request.method") "https://hl7.org/fhir/R5/bundle.html#Bundle.entry.request.method" 'element))
(register-element! "Bundle.entry.request.url" (fhir-spec (string->symbol "Bundle.entry.request.url") "https://hl7.org/fhir/R5/bundle.html#Bundle.entry.request.url" 'element))
(register-element! "Bundle.entry.request.ifNoneMatch" (fhir-spec (string->symbol "Bundle.entry.request.ifNoneMatch") "https://hl7.org/fhir/R5/bundle.html#Bundle.entry.request.ifNoneMatch" 'element))
(register-element! "Bundle.entry.request.ifModifiedSince" (fhir-spec (string->symbol "Bundle.entry.request.ifModifiedSince") "https://hl7.org/fhir/R5/bundle.html#Bundle.entry.request.ifModifiedSince" 'element))
(register-element! "Bundle.entry.request.ifMatch" (fhir-spec (string->symbol "Bundle.entry.request.ifMatch") "https://hl7.org/fhir/R5/bundle.html#Bundle.entry.request.ifMatch" 'element))
(register-element! "Bundle.entry.request.ifNoneExist" (fhir-spec (string->symbol "Bundle.entry.request.ifNoneExist") "https://hl7.org/fhir/R5/bundle.html#Bundle.entry.request.ifNoneExist" 'element))

(register-type! 'BundleEntryResponse (fhir-spec 'BundleEntryResponse "https://hl7.org/fhir/R5/bundle.html#Bundle.entry.response" 'type)
  #:schema (type-schema 'BundleEntryResponse #f 'BackboneElement "https://hl7.org/fhir/R5/bundle.html#Bundle.entry.response"
             (list
    (schema-field 'status 1 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/bundle.html#Bundle.entry.response.status" #f)
    (schema-field 'location 0 1 (vector 'prim "uri") #f "https://hl7.org/fhir/R5/bundle.html#Bundle.entry.response.location" #f)
    (schema-field 'etag 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/bundle.html#Bundle.entry.response.etag" #f)
    (schema-field 'lastModified 0 1 (vector 'prim "instant") #f "https://hl7.org/fhir/R5/bundle.html#Bundle.entry.response.lastModified" #f)
    (schema-field 'outcome 0 1 (vector 'resource) #f "https://hl7.org/fhir/R5/bundle.html#Bundle.entry.response.outcome" #f)
             ) #f #f))
(register-element! "Bundle.entry.response.status" (fhir-spec (string->symbol "Bundle.entry.response.status") "https://hl7.org/fhir/R5/bundle.html#Bundle.entry.response.status" 'element))
(register-element! "Bundle.entry.response.location" (fhir-spec (string->symbol "Bundle.entry.response.location") "https://hl7.org/fhir/R5/bundle.html#Bundle.entry.response.location" 'element))
(register-element! "Bundle.entry.response.etag" (fhir-spec (string->symbol "Bundle.entry.response.etag") "https://hl7.org/fhir/R5/bundle.html#Bundle.entry.response.etag" 'element))
(register-element! "Bundle.entry.response.lastModified" (fhir-spec (string->symbol "Bundle.entry.response.lastModified") "https://hl7.org/fhir/R5/bundle.html#Bundle.entry.response.lastModified" 'element))
(register-element! "Bundle.entry.response.outcome" (fhir-spec (string->symbol "Bundle.entry.response.outcome") "https://hl7.org/fhir/R5/bundle.html#Bundle.entry.response.outcome" 'element))

