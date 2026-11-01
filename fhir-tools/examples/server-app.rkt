#lang fhir/capability
;; server-app.rkt — a runnable FHIR server configured entirely by declarations.
;;   raco fhir serve examples/server-app.rkt 8080
;; then:  curl localhost:8080/metadata
;;        curl -XPOST localhost:8080/Patient -d '{"resourceType":"Patient","gender":"male"}'
;;        curl 'localhost:8080/Patient?gender=male'
;; Resources with no #:repository get a generic in-memory store; declared search-params filter via
;; their FHIRPath expression.

(define (ping-handler in req)
  (define msg (let ([m (hash-ref in "message" '())]) (if (pair? m) (car m) "pong")))
  (Parameters (parameter (ParametersParameter (name "result") (valueString msg)))))

(server #:mode "server" #:status "active" #:url "http://localhost/fhir")

(resource Patient
  #:interactions (read create update delete search-type)
  #:search-params ([gender token "Patient.gender"]
                   [family string "Patient.name.family"]))

(resource Observation
  #:interactions (read create search-type)
  #:search-params ([status token "Observation.status"]))

(operation $ping
  #:system
  #:in  ([message string 0 1])
  #:out ([result string 1 1])
  #:handler ping-handler)
