#lang fhir/capability

;;; ops-app.rkt — a capability app that exposes existing operations (fhir/operation) next to its own
;;; resources: by reference, and as a value in scope. /metadata advertises them under their own
;;; canonicals (operations-http-test.rkt).

(require (only-in fhir/conformance/operations $validate)
         (only-in fhir/terminology/operations))

(server #:mode "server" #:status "active" #:url "http://example.org/fhir")

(resource Patient #:interactions (read create))

(operation $validate)               ; a value in scope: Resource/$validate on every declared type
(operation "ValueSet/$expand")      ; a reference: ValueSet gets a rest.resource entry for it
