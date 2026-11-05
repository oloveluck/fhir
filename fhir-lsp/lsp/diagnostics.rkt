#lang racket/base

;;; diagnostics.rkt — fhir/diagnostic values as LSP diagnostics, grouped by the document they belong to.
;;;
;;; An LspDiagnostic is a jsexpr {range {start {line character} end {line character}}, severity,
;;; source, message} with 0-based lines and characters (fhir/diagnostic counts both from 1).
;;; A Uri is a `file://` url string; a Path is the file system path it names.

(require racket/contract racket/string racket/list
         (only-in net/uri-codec uri-decode uri-encode)
         (only-in fhir/diagnostic diagnostic? diagnostic-loc diagnostic-lang diagnostic-phase diagnostic-severity
                  diagnostic-message loc-source loc-line loc-column loc-span))

(provide
 (contract-out
  [diagnostic->lsp  (-> diagnostic? hash?)]
  [group-by-uri     (-> (listof diagnostic?) string? (hash/c string? (listof hash?)))]
  [path->uri        (-> path-string? string?)]
  [uri->path        (-> string? (or/c path? #f))]))

;; diagnostic->lsp : diagnostic -> LspDiagnostic   a diagnostic without a position points at 0:0
(define (diagnostic->lsp d)
  (define l (diagnostic-loc d))
  (define line (max 0 (sub1 (or (and l (loc-line l)) 1))))
  (define col (max 0 (sub1 (or (and l (loc-column l)) 1))))
  (define span (max 1 (or (and l (loc-span l)) 1)))
  (hasheq 'range (hasheq 'start (hasheq 'line line 'character col)
                         'end (hasheq 'line line 'character (+ col span)))
          'severity (case (diagnostic-severity d) [(error) 1] [(warning) 2] [else 3])
          'source (format "~a ~a" (diagnostic-lang d) (diagnostic-phase d))
          'message (diagnostic-message d)))

;; group-by-uri : diagnostics default-uri -> (hash uri -> lsp-diagnostics)   each diagnostic goes to
;; the document its source names; one with no source to `default`
(define (group-by-uri ds default)
  (for/fold ([h (hash)]) ([d (in-list ds)])
    (define l (diagnostic-loc d))
    (define src (and l (loc-source l)))
    (define uri (if (and src (not (equal? src ""))) (path->uri src) default))
    (hash-update h uri (lambda (l) (append l (list (diagnostic->lsp d)))) '())))

;; path->uri : path -> "file:///…"   an absolute path, each segment percent-encoded
(define (path->uri p)
  (define abs (path->string (simplify-path (path->complete-path (if (path? p) p (string->path p))))))
  (string-append "file://" (string-join (map uri-encode (string-split abs "/" #:trim? #f)) "/")))

;; uri->path : "file:///…" -> path | #f   anything but a file url is #f
(define (uri->path u)
  (define m (regexp-match #px"^file://(?:localhost)?(/.*)$" u))
  (and m (string->path (uri-decode (cadr m)))))

(module+ test
  (require rackunit (only-in fhir/diagnostic diagnostic loc))
  (define d (diagnostic 'fsh 'parse 'error "unexpected `used`" (loc "/tmp/a.fsh" 3 5 20 4)))
  (define j (diagnostic->lsp d))
  (check-equal? (hash-ref j 'range) (hasheq 'start (hasheq 'line 2 'character 4) 'end (hasheq 'line 2 'character 8)))
  (check-equal? (hash-ref j 'severity) 1)
  (check-equal? (hash-ref j 'source) "fsh parse")
  ;; no position: the start of the document, one character wide; a warning is severity 2
  (define w (diagnostic 'fml 'compile 'warning "unassigned" #f))
  (check-equal? (hash-ref (diagnostic->lsp w) 'range) (hasheq 'start (hasheq 'line 0 'character 0) 'end (hasheq 'line 0 'character 1)))
  (check-equal? (hash-ref (diagnostic->lsp w) 'severity) 2)
  ;; grouping: by the source file, the sourceless one to the document asked about
  (define g (group-by-uri (list d w (diagnostic 'fsh 'compile 'error "x" (loc "/tmp/b.fsh" 1 1 0 1))) "file:///tmp/c.fsh"))
  (check-equal? (sort (hash-keys g) string<?) '("file:///tmp/a.fsh" "file:///tmp/b.fsh" "file:///tmp/c.fsh"))
  (check-equal? (length (hash-ref g "file:///tmp/a.fsh")) 1)
  ;; uris: spaces encoded, decoded back; a non-file uri is no path
  (check-equal? (path->uri "/tmp/a b/c.fsh") "file:///tmp/a%20b/c.fsh")
  (check-equal? (uri->path "file:///tmp/a%20b/c.fsh") (string->path "/tmp/a b/c.fsh"))
  (check-false (uri->path "untitled:Untitled-1")))
