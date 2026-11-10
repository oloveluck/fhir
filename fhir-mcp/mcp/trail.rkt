#lang racket/base

;;; trail.rkt — what the workspace writes about what it does, as FHIR resources in the data itself,
;;; so the trail is searched, read and computed on like any other data (FHIR search, SQL, CQL).
;;;
;;;   a commit  -> a Provenance: the exact versions it wrote (`Patient/ann/_history/2`), when, the
;;;                agent (the MCP client that asked, through fhir-mcp), why (the commit's `reason`),
;;;                and what they were made from — the source text itself (FSH, a map, a CQL library)
;;;                in a contained DocumentReference with its SHA-1, or the result they came from;
;;;             -> an AuditEvent: the transaction, its outcome, every version written
;;;   a run, a query or an apply (workspace.yaml `audit: all`) -> an AuditEvent of the execution
;;;
;;; A Source is a hash: 'kind ("fsh" | "file" | "result" | "query" | "operation" | "resources"), and as the kind has them
;;; 'text, 'path, 'language, 'result, 'entry (a define), 'over.
;;; An Agent is a string: "claude-code 2.0.1 via fhir-mcp".

(require racket/contract racket/string racket/list json file/sha1 net/base64)

(provide
 (contract-out
  ;; current-agent : (box string)   who asks: set from the MCP client's initialize (clientInfo)
  [current-agent box?]
  ;; agent-from-client : clientInfo -> string
  [agent-from-client (-> any/c string?)]
  ;; provenance : targets source reason agent now -> Provenance
  ;;   targets: (listof (list reference action)) — "Type/id[/_history/v]", 'create | 'update
  [provenance (-> (listof list?) hash? (or/c string? #f) string? string? hash?)]
  ;; commit-audit : fhir-version targets agent now -> AuditEvent   the transaction that wrote them
  [commit-audit (-> string? (listof list?) string? string? hash?)]
  ;; execution-audit : fhir-version what source outcome agent now -> AuditEvent   a run, query or apply
  [execution-audit (-> string? string? hash? (or/c #t string?) string? string? hash?)]
  ;; text-sha1 : string -> hex string
  [text-sha1 (-> string? string?)]))

(define current-agent (box "fhir-mcp"))
(define (agent-from-client info)
  (define name (and (hash? info) (hash-ref info 'name #f)))
  (define version (and (hash? info) (hash-ref info 'version #f)))
  (if (string? name)
      (string-append name (if (string? version) (string-append " " version) "") " via fhir-mcp")
      "fhir-mcp"))

(define (text-sha1 s) (sha1 (open-input-bytes (string->bytes/utf-8 s))))
(define (base64 bs) (bytes->string/utf-8 (base64-encode bs #"")))

(define content-types
  (hash "fsh" "text/fsh" "cql" "text/cql" "fml" "text/fhir-mapping" "vcl" "text/plain" "fhirpath" "text/fhirpath"
        "sql-on-fhir" "application/json" "capability" "text/racket" "fhir" "application/fhir+json" "sql" "application/sql"
        "search" "text/plain"))

;; source-document : Source -> DocumentReference | #f   the source text, contained, with its hash
(define (source-document src)
  (define text (hash-ref src 'text #f))
  (and (string? text)
       (hasheq 'resourceType "DocumentReference" 'id "source" 'status "current"
               'description (source-label src)
               'content (list (hasheq 'attachment
                                      (hasheq 'contentType (hash-ref content-types (hash-ref src 'language (hash-ref src 'kind "fsh")) "text/plain")
                                              'title (or (hash-ref src 'path #f) (hash-ref src 'kind "source"))
                                              'data (base64 (string->bytes/utf-8 text))
                                              'hash (base64 (sha1-bytes (open-input-bytes (string->bytes/utf-8 text))))))))))

;; source-label : Source -> string   one line: what the data was made from
(define (source-label src)
  (define sha (let ([t (hash-ref src 'text #f)]) (if (string? t) (string-append " sha1:" (text-sha1 t)) "")))
  (case (hash-ref src 'kind "resources")
    [("fsh") (if (hash-ref src 'path #f) (format "~a~a" (hash-ref src 'path) sha) (string-append "FSH written in the stage" sha))]
    [("file") (format "~a~a" (hash-ref src 'path "a file") sha)]
    [("result") (format "~a of ~a~a~a" (hash-ref src 'result "a result") (or (hash-ref src 'path #f) (hash-ref src 'language "a query"))
                        (let ([e (hash-ref src 'entry #f)]) (if (string? e) (format " (~a)" e) ""))
                        sha)]
    [("query") (format "a ~a query~a" (hash-ref src 'language "?") sha)]
    [("operation") (format "the operation ~a" (hash-ref src 'operation "?"))]
    [else "resources given in the stage"]))

(define (activity targets)
  (define actions (remove-duplicates (map cadr targets)))
  (and (= 1 (length actions))
       (hasheq 'coding (list (hasheq 'system "http://terminology.hl7.org/CodeSystem/v3-DataOperation"
                                     'code (if (eq? (car actions) 'create) "CREATE" "UPDATE"))))))

;; agent-who : string -> Reference   who wrote: a reference when the agent is one (`Practitioner/dr-ng`,
;; `Device/intake-kiosk` — an audit can follow it), else a display (`intake desk`)
(define (agent-who agent)
  (if (regexp-match? #px"^[A-Z][A-Za-z]+/[A-Za-z0-9.-]{1,64}$" agent)
      (hasheq 'reference agent)
      (hasheq 'display agent)))

;; source-line-url : the extension a Provenance target carries: where in the source it was written
(define source-line-url "urn:fhir-mcp:source-line")

;; target-reference : (list ref action [at]) -> Reference   the version written, and the source's
;; file and line that wrote it when known (`patients.fsh:30`)
(define (target-reference t)
  (define at (and (pair? (cddr t)) (caddr t)))
  (if at
      (hasheq 'reference (car t) 'extension (list (hasheq 'url source-line-url 'valueString at)))
      (hasheq 'reference (car t))))

(define (provenance targets src reason agent now)
  (define doc (source-document src))
  (define act (activity targets))
  (for/fold ([p (hasheq 'resourceType "Provenance"
                        'target (for/list ([t (in-list targets)]) (target-reference t))
                        'recorded now
                        'agent (list (hasheq 'type (hasheq 'coding (list (hasheq 'system "http://terminology.hl7.org/CodeSystem/provenance-participant-type" 'code "author")))
                                             'who (agent-who agent))))])
            ([kv (in-list (list (cons 'contained (and doc (list doc)))
                                (cons 'activity act)
                                (cons 'reason (and reason (list (hasheq 'text reason))))
                                (cons 'entity (and (not (equal? (hash-ref src 'kind "resources") "resources"))
                                                   (list (hasheq 'role "source"
                                                                 'what (if doc
                                                                           (hasheq 'reference "#source" 'display (source-label src))
                                                                           (hasheq 'display (source-label src)))))))))]
            #:when (cdr kv))
    (hash-set p (car kv) (cdr kv))))

;; the AuditEvent shape differs between R4 (type: Coding, outcome: code) and R5 (code, outcome.code)
(define (r4? v) (regexp-match? #rx"^4[.]" v))
(define (audit-event v action subtype outcome-ok? outcome-text agent now entities)
  (define base
    (if (r4? v)
        (hasheq 'resourceType "AuditEvent"
                'type (hasheq 'system "http://terminology.hl7.org/CodeSystem/audit-event-type" 'code "rest" 'display "RESTful Operation")
                'subtype (list (hasheq 'system "http://hl7.org/fhir/restful-interaction" 'code subtype))
                'action action 'recorded now
                'outcome (if outcome-ok? "0" "8")
                'agent (list (hasheq 'who (agent-who agent) 'requestor #t))
                'source (hasheq 'observer (hasheq 'display "fhir-mcp"))
                'entity entities)
        (hasheq 'resourceType "AuditEvent"
                'code (hasheq 'coding (list (hasheq 'system "http://hl7.org/fhir/restful-interaction" 'code subtype)))
                'action action 'recorded now
                'outcome (hasheq 'code (hasheq 'system "http://terminology.hl7.org/CodeSystem/audit-event-outcome" 'code (if outcome-ok? "0" "8")))
                'agent (list (hasheq 'who (agent-who agent) 'requestor #t))
                'source (hasheq 'observer (hasheq 'display "fhir-mcp"))
                'entity entities)))
  (if (and (not outcome-ok?) outcome-text)
      (hash-set base 'outcomeDesc outcome-text)          ; R4's element; R5 reads outcome.detail
      base))

(define (commit-audit v targets agent now)
  (audit-event v (if (andmap (lambda (t) (eq? (cadr t) 'create)) targets) "C" "U") "transaction" #t #f agent now
               (for/list ([t (in-list targets)]) (hasheq 'what (hasheq 'reference (car t))))))

(define (execution-audit v what src outcome agent now)
  (define text (hash-ref src 'text #f))
  (audit-event v "E" (if (equal? (hash-ref src 'language #f) "search") "search-type" "operation") (eq? outcome #t)
               (and (string? outcome) outcome) agent now
               (list (for/fold ([e (hasheq 'what (hasheq 'display (format "~a: ~a" what (source-label src))))])
                               ([kv (in-list (list (cons 'query (and (string? text) (base64 (string->bytes/utf-8 text))))))]
                                #:when (cdr kv))
                       (hash-set e (car kv) (cdr kv))))))

(module+ test
  (require rackunit)
  (check-equal? (agent-from-client (hasheq 'name "claude-code" 'version "2.0.1")) "claude-code 2.0.1 via fhir-mcp")
  (check-equal? (agent-from-client #f) "fhir-mcp")
  (define fsh "Instance: ann\nInstanceOf: Patient\n* gender = #female\n")
  (define p (provenance (list (list "Patient/ann/_history/1" 'create)) (hasheq 'kind "fsh" 'text fsh 'language "fsh")
                        "intake from the clinic's form" "claude-code via fhir-mcp" "2026-11-09T12:00:00Z"))
  (check-equal? (hash-ref p 'target) (list (hasheq 'reference "Patient/ann/_history/1")))
  (check-equal? (hash-ref (car (hash-ref p 'reason)) 'text) "intake from the clinic's form")
  (check-equal? (hash-ref (car (hash-ref (hash-ref p 'activity) 'coding)) 'code) "CREATE")
  ;; the source text travels with the Provenance, with its hash
  (define doc (car (hash-ref p 'contained)))
  (define att (hash-ref (car (hash-ref doc 'content)) 'attachment))
  (check-equal? (bytes->string/utf-8 (base64-decode (string->bytes/utf-8 (hash-ref att 'data)))) fsh)
  (check-equal? (hash-ref att 'contentType) "text/fsh")
  (check-equal? (hash-ref (hash-ref (car (hash-ref p 'entity)) 'what) 'reference) "#source")
  ;; mixed creates and updates: no single activity; resources given directly: no source entity
  (define p2 (provenance (list (list "Patient/a/_history/2" 'update) (list "Patient/b/_history/1" 'create)) (hasheq 'kind "resources") #f "x" "t"))
  (check-false (hash-ref p2 'activity #f))
  (check-false (hash-ref p2 'entity #f))
  ;; AuditEvents in each version's shape
  (check-equal? (hash-ref (commit-audit "4.0.1" (list (list "Patient/a/_history/1" 'create)) "x" "t") 'outcome) "0")
  (check-equal? (hash-ref (commit-audit "4.0.1" (list (list "Patient/a/_history/2" 'update)) "x" "t") 'action) "U")
  (check-true (hash? (hash-ref (commit-audit "5.0.0" (list (list "Patient/a/_history/1" 'create)) "x" "t") 'outcome)))
  (define ex (execution-audit "4.0.1" "query sql" (hasheq 'kind "result" 'language "sql" 'text "SELECT 1") "no such column: x" "x" "t"))
  (check-equal? (hash-ref ex 'outcome) "8")
  (check-equal? (hash-ref ex 'outcomeDesc) "no such column: x"))
