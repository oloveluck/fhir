#lang racket/base

;;; tool-budget-test.rkt — what an agent pays before it has asked anything.
;;;
;;; An MCP client puts every tool's definition and the server's instructions into the model's
;;; context at the start of each session: bytes the agent reads whether or not it uses the tool.
;;; They are a budget, held here as a ceiling that only comes down (the conformance floors only go
;;; up): the definitions had grown from 6 KB to 14 KB over thirty rounds of small additions, and
;;; nothing said so. Lower a ceiling when the size falls; to raise one, the addition has to be
;;; worth more to every session than what it costs.
;;;
;;; Also held: every verb says how it behaves (MCP's tool annotations), so a client can run the
;;; reading verbs without asking; and there are nine verbs.

(require rackunit racket/file racket/list
         (only-in json jsexpr->string)
         (only-in fhir/mcp/workspace open-hub)
         (only-in fhir/mcp/verbs workspace-tools)
         (only-in fhir/mcp/tools tool->jsexpr)
         (only-in fhir/mcp/server current-server-instructions)
         (only-in fhir/mcp/init init-workspace!))

(define dir (make-temporary-directory "budget-~a"))
(void (init-workspace! dir))
(define tools (map tool->jsexpr (workspace-tools (open-hub dir))))
(define (bytes-of js) (bytes-length (string->bytes/utf-8 (jsexpr->string js))))

;; the ceilings, in bytes of compact JSON (about four bytes to a token)
(define tools-ceiling 12300)
(define instructions-ceiling 1400)
(define one-tool-ceiling 2400)

(check-equal? (map (lambda (t) (hash-ref t 'name)) tools)
              '("write" "check" "run" "query" "explain" "describe" "apply" "stage" "commit"))
(define total (bytes-of tools))
(printf "tool definitions: ~a bytes (ceiling ~a); instructions: ~a bytes (ceiling ~a)\n"
        total tools-ceiling (string-length (current-server-instructions)) instructions-ceiling)
(check-true (<= total tools-ceiling) (format "the nine tools' definitions are ~a bytes: over the ceiling of ~a" total tools-ceiling))
(check-true (<= (string-length (current-server-instructions)) instructions-ceiling))
(for ([t (in-list tools)])
  (check-true (<= (bytes-of t) one-tool-ceiling) (format "~a: ~a bytes" (hash-ref t 'name) (bytes-of t)))
  ;; how it behaves, for the client: the four hints and a title, each a boolean or a string
  (define a (hash-ref t 'annotations (hasheq)))
  (check-true (string? (hash-ref a 'title #f)) (hash-ref t 'name))
  (for ([k '(readOnlyHint destructiveHint idempotentHint openWorldHint)])
    (check-true (boolean? (hash-ref a k 'missing)) (format "~a ~a" (hash-ref t 'name) k))))

(delete-directory/files dir)
