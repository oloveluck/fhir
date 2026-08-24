#lang racket/base

;;; store-app.rkt — a persistent FHIR server whose search parameters come from the IG itself.
;;;
;;; The R5 core package's own SearchParameter resources drive both the /metadata
;;; CapabilityStatement (which params are advertised) and the store's indexes (how search
;;; evaluates) — one artifact, no drift. Backed by SQLite (store/).
;;;
;;;   racket examples/store-app.rkt          # prints the derived /metadata
;;;   raco fhir serve examples/store-app.rkt # serves it over HTTP

(require racket/runtime-path
         fhir/r5/schemas                       ; the package is R5 -> build against the R5 tower
         (only-in fhir/store/fhir-sqlite open-fhir-store)
         (only-in fhir/store/serve make-store-app)
         (only-in fhir/capability/runtime app-capability-statement)
         (only-in fhir/serialize/to-json node->json-string))

(provide app)

(define-runtime-path r5-package "../spec/hl7.fhir.r5.core.tgz")
(define db-path (build-path (find-system-path 'temp-dir) "fhir-store-demo.db"))

(define store (open-fhir-store db-path))
(define app
  (make-store-app store
                  #:package r5-package
                  #:types '(Patient Observation Condition)
                  #:url "http://localhost:8080"))

(module+ main
  (displayln (node->json-string (app-capability-statement app))))
