#lang racket/base

;;; canonical.rkt — a canonical reference's two parts. A Canonical is a string `url` or `url|version`
;;; (FHIR's canonical datatype: the version after the first `|`). Every resolver keys its tables by
;;; the url alone; this is the one definition of "the url alone" (it was written ten ways, and the
;;; `string-split` ones failed on "" and read "|v" as the url "v").

(require racket/contract)

(provide
 (contract-out
  ;; canonical-url : Canonical -> string   the part before the first `|` (all of it when none)
  [canonical-url (-> string? string?)]
  ;; canonical-version : Canonical -> string | #f   the part after the first `|`, #f when none
  [canonical-version (-> string? (or/c string? #f))]))

(define (canonical-url c)
  (define i (bar-index c))
  (if i (substring c 0 i) c))

(define (canonical-version c)
  (define i (bar-index c))
  (and i (substring c (add1 i))))

;; bar-index : string -> index | #f   the first `|`
(define (bar-index c)
  (for/first ([ch (in-string c)] [i (in-naturals)] #:when (char=? ch #\|)) i))

(module+ test
  (require rackunit)
  (check-equal? (canonical-url "http://hl7.org/fhir/ValueSet/x|4.0.1") "http://hl7.org/fhir/ValueSet/x")
  (check-equal? (canonical-version "http://hl7.org/fhir/ValueSet/x|4.0.1") "4.0.1")
  (check-equal? (canonical-url "http://x") "http://x")
  (check-false (canonical-version "http://x"))
  ;; the edges the string-split spellings got wrong
  (check-equal? (canonical-url "") "")
  (check-equal? (canonical-url "|v") "")
  (check-equal? (canonical-version "|v") "v")
  (check-equal? (canonical-url "u|") "u")
  (check-equal? (canonical-version "u|") "")
  (check-equal? (canonical-url "u|1|2") "u")
  (check-equal? (canonical-version "u|1|2") "1|2"))
