#lang racket/base

;;; operations-server.rkt — FHIR operations over HTTP, nothing else: /metadata is derived from them.
;;;
;;;   racket examples/operations-server.rkt          (then:)
;;;   curl localhost:8080/metadata
;;;   curl 'localhost:8080/ValueSet/$expand?url=http://hl7.org/fhir/ValueSet/administrative-gender'
;;;
;;; The same operation values a pipeline applies (fhir/operation); to add them to a server with
;;; resources, write `(operation "ValueSet/$expand")` in a #lang fhir/capability module instead.

(require (only-in fhir/r5/schemas)
         fhir/capability/operations
         (only-in fhir/conformance/operations $validate)
         (only-in fhir/terminology/operations $expand $validate-code $lookup))

(module+ main
  (define stop (serve-operations (list $validate $expand $validate-code $lookup) #:port 8080))
  (printf "FHIR operations on http://localhost:8080  (GET /metadata; Ctrl-C to stop)\n")
  (with-handlers ([exn:break? (lambda (_) (stop))]) (sync/enable-break never-evt)))
