#lang racket/base

;;; search-value.rkt — a search value the server cannot read.
;;;
;;; A parameter the server does not support is ignored and said (FHIR's lenient default); a parameter
;;; it supports given a value it cannot read (`date=ge2023-13-45`, `value-quantity=lt5,6x`) is not the
;;; same: ignoring it answers a different search than the one asked — every Observation where the
;;; client asked for the last day's — so it is an error, 400, naming the value and the form expected
;;; (https://hl7.org/fhir/search.html#errors: a search that cannot be executed is a 4xx). The store
;;; raises it while compiling a search; the dispatcher (runtime.rkt) answers it as an OperationOutcome.

(provide (struct-out exn:fail:search-value) raise-search-value)

;; exn:fail:search-value : message marks name value
(struct exn:fail:search-value exn:fail:user (name value))

;; raise-search-value : string string string -> (raises)   `name`'s value `value` is not `what`
(define (raise-search-value name value what)
  (raise (exn:fail:search-value (format "search parameter `~a`: `~a` is not ~a" name value what)
                                (current-continuation-marks) name value)))
