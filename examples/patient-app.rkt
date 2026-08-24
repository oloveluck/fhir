#lang fhir/capability

;;; patient-app.rkt — a tiny FHIR application configured entirely by declarations.
;;;
;;; The (server)/(resource)/(operation) forms DECLARE what this app supports; the lang DERIVES the
;;; CapabilityStatement (run this file to print it — that's the /metadata view) and assembles an
;;; in-process `app` value. Plain Racket `define`s (the repository + handlers) are interleaved freely;
;;; the declarations may reference them regardless of order.

;; ---- an in-memory Patient repository -------------------------------------------------------
(define patients (make-hash))
(define next-id (box 0))

(define patient-repo
  (make-repository
   #:create (lambda (node)
              (set-box! next-id (add1 (unbox next-id)))
              (define id (number->string (unbox next-id)))
              (define stored (Patient (id id)))     ; a minimal stored echo carrying the assigned id
              (hash-set! patients id (or node stored))
              (hash-ref patients id))
   #:read   (lambda (id) (hash-ref patients id #f))
   #:search (lambda (params) (hash-values patients))))

;; ---- a trivial $ping operation handler -----------------------------------------------------
;; in : hash "message" -> (list <string>) ; returns a Parameters echoing it back.
(define (ping-handler in req)
  (define msg (let ([vs (hash-ref in "message" '())]) (if (pair? vs) (car vs) "pong")))
  (Parameters (parameter (ParametersParameter (name "result") (valueString msg)))))

;; ---- DECLARATIONS --------------------------------------------------------------------------
(server #:mode "server" #:status "active" #:url "http://example.org/fhir")

(resource Patient
  #:interactions (read create search-type)
  #:search-params ([gender token] [birthdate date])
  #:repository patient-repo)

(operation $ping
  #:system
  #:in  ([message string 0 1])
  #:out ([result string 1 1])
  #:handler ping-handler)
