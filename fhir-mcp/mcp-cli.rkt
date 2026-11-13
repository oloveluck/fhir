#lang racket/base

;;; mcp-cli.rkt — `raco fhir-mcp`: the Model Context Protocol server over a FHIR workspace.
;;;
;;;   raco fhir-mcp [serve] [--workspace <dir>] [--package <tgz|name>]… [--data <dir|file|url>]
;;;                                      serve on stdin/stdout (one JSON line per message): the nine
;;;                                      workspace tools over <dir> (default: the current directory),
;;;                                      configured by its workspace.yaml; --package and --data add to and
;;;                                      override it
;;;   raco fhir-mcp tools [same flags]   the tools offered, with their schemas (JSON)
;;;   raco fhir-mcp call <tool> ['<json arguments>'] [same flags]   run one tool, print its text (exit 1 on error)
;;;   raco fhir-mcp batch [<file> | -] [same flags]   many calls in one process, one per line
;;;   raco fhir-mcp export [--check]     the store's definitions as text in the `export` directory
;;;   raco fhir-mcp guide [<topic>]      a learn:// guide as text (the topics, without one): every
;;;                                      language's guide and the workspace's, with no server running

(require (only-in "mcp/init.rkt" init-workspace!)
         racket/list racket/string racket/port racket/file json
         (only-in fhir/subcommands run-subcommands usage-error)
         "mcp/server.rkt" "mcp/tools.rkt" "mcp/workspace.rkt" "mcp/verbs.rkt"
         racket/match (only-in "mcp/resources.rkt" current-result-resources learn-topics learn-text guide-blocks guide-block-text)
         (only-in "mcp/trail.rkt" current-agent))

(define flags "[--workspace <dir>] [--package <tgz|name>]… [--data <dir|file|url>] [--indent]")
(define usages
  `(("serve" ,(format "raco fhir-mcp [serve] ~a   the server over stdin/stdout" flags))
    ("tools" ,(format "raco fhir-mcp tools ~a   the tools and their schemas" flags))
    ("call"  ,(format "raco fhir-mcp call <tool> ['<json>' | -] [key=value | key=@file | key:=<json> | key:=@file.json]… ~a   run one tool: arguments as a JSON object (- reads it from stdin) and/or one by one, a file's text with @" flags))
    ("batch" ,(format "raco fhir-mcp batch [<file> | -] ~a   many calls in one process: one per line, `<tool> key=value key=@file key:=<json> …` (quoted as a shell would, \\n inside double quotes a newline; # starts a comment; a line starting with ! is expected to fail), each answer after a `### <line>` header" flags))
    ("export" ,(format "raco fhir-mcp export [--check] ~a   write the store's definitions as text into workspace.yaml's `export` directory (a commit of definitions does it); --check writes nothing and exits 1 when the directory is not up to date (for CI)" flags))
    ("init"  "raco fhir-mcp init [<dir>] [--fhir-version 4.0.1|5.0.0]   make a directory a workspace an agent can use: workspace.yaml (data: fhir.db, a SQLite FHIR store), .mcp.json, CLAUDE.md")
    ("guide" "raco fhir-mcp guide [<topic> [--blocks | --block N|name]]   a guide (learn://<topic>) as text, its code blocks listed, or one (to save as a file); without a topic, the topics")))

;; An Opts is (opts workspace packages data rest indent?)
(struct opts (workspace packages data rest indent?))
(define (read-flags args)
  (let loop ([as args] [o (opts #f '() #f '() #f)])
    (match-args as o loop)))
(define (match-args as o loop)
  (cond [(null? as) (struct-copy opts o [packages (reverse (opts-packages o))] [rest (reverse (opts-rest o))])]
        [(and (equal? (car as) "--workspace") (pair? (cdr as))) (loop (cddr as) (struct-copy opts o [workspace (cadr as)]))]
        [(and (equal? (car as) "--package") (pair? (cdr as))) (loop (cddr as) (struct-copy opts o [packages (cons (cadr as) (opts-packages o))]))]
        [(and (equal? (car as) "--data") (pair? (cdr as))) (loop (cddr as) (struct-copy opts o [data (cadr as)]))]
        [(equal? (car as) "--indent") (loop (cdr as) (struct-copy opts o [indent? #t]))]
        [else (loop (cdr as) (struct-copy opts o [rest (cons (car as) (opts-rest o))]))]))

;; with-workspace : opts (hub tools -> any) -> any   the hub opened, its context and results in place
(define (with-workspace o k)
  (define dir (or (opts-workspace o) (current-directory)))
  (unless (directory-exists? dir) (eprintf "fhir-mcp: no such directory: ~a\n" dir) (exit 2))
  (define h (open-hub dir #:data (opts-data o) #:packages (opts-packages o)))
  (define tools (workspace-tools h))
  (parameterize ([current-result-resources (cons (lambda () (hub-result-uris h)) (lambda (u) (hub-read-result h u)))])
    (with-hub h (lambda () (k h tools)))))

;; only-flags : command opts -> opts   a word that is not a flag is a usage error
(define (only-flags cmd o)
  (unless (null? (opts-rest o)) (usage-error "fhir-mcp" usages cmd (format "unexpected ~a" (car (opts-rest o)))))
  o)

(define (serve-command args)
  (with-workspace (only-flags "serve" (read-flags args)) (lambda (h tools) (serve tools))))

(define (tools-command args)
  (with-workspace (only-flags "tools" (read-flags args)) (lambda (h tools) (write-json (hasheq 'tools (map tool->jsexpr tools))) (newline))))

;; export-command : args -> void   the text export written, or (--check) compared
(define (export-command args)
  (define o (read-flags args))
  (define check? (member "--check" (opts-rest o)))
  (only-flags "export" (struct-copy opts o [rest (remove "--check" (opts-rest o))]))
  (with-workspace o
    (lambda (h tools)
      (with-handlers ([exn:fail? (lambda (e) (eprintf "fhir-mcp: ~a\n" (exn-message e)) (exit 2))])
        (cond [check? (define drift (export-drift h))
                      (for ([d (in-list drift)]) (printf "~a\n" d))
                      (unless (null? drift) (eprintf "the export is not up to date: raco fhir-mcp export writes it\n") (exit 1))
                      (printf "the export is up to date\n")]
              [else (write-json (export! h)) (newline)])))))

(define (call-command args)
  (define o (read-flags args))
  (define rest (opts-rest o))
  (when (null? rest) (usage-error "fhir-mcp" usages "call" "no tool named"))
  (define name (car rest))
  (define arguments (call-arguments (cdr rest)))
  ;; who the trail names: the shell, unless FHIR_MCP_AGENT says who is at it
  (set-box! current-agent (or (getenv "FHIR_MCP_AGENT") "raco fhir-mcp call"))
  (set-box! call-style 'shell)
  (with-workspace o
    (lambda (h tools)
      (define t (findf (lambda (x) (equal? (tool-name x) name)) tools))
      (unless t (usage-error "fhir-mcp" usages "call" (format "no tool ~a (raco fhir-mcp tools lists them)" name)))
      (define-values (text err?) (call-tool t arguments))
      (displayln (if (opts-indent? o) (indent-json-text text) text))
      (exit (if (or err? (reports-errors? text)) 1 0)))))

;; batch-command : args -> void   each line of the file (or stdin) a call, in ONE process: the
;; workspace and its packages are opened once (a call costs ~1-4 s of startup from the shell). Every
;; line runs, a failed one too; exit 1 when any failed or reported errors.
(define (batch-command args)
  (define o (read-flags args))
  (define src (let ([r (opts-rest o)]) (if (null? r) "-" (car r))))
  (unless (or (equal? src "-") (file-exists? src)) (usage-error "fhir-mcp" usages "batch" (format "no such file: ~a" src)))
  (define text (if (equal? src "-") (port->string (current-input-port)) (file->string src)))
  (define lines (for/list ([l (in-list (string-split text "\n"))]
                           #:unless (regexp-match? #px"^\\s*(#|$)" l))
                  (string-trim l)))
  (set-box! current-agent (or (getenv "FHIR_MCP_AGENT") "raco fhir-mcp batch"))
  (set-box! call-style 'shell)
  (with-workspace o
    (lambda (h tools)
      ;; each answer under its line, the line's exit status in the header (`### [exit 1] stage …`) and
      ;; a last line counting them: a rerun's agent read a long batch and missed which line failed
      ;; a line starting with `!` is EXPECTED to fail (a stage meant to be refused): it counts as
      ;; failed when it succeeds, and its header says which way it went
      (define statuses
        (for/list ([l0 (in-list lines)])
          (define expect-fail? (regexp-match? #px"^!\\s*" l0))
          (define l (if expect-fail? (string-trim (substring l0 1)) l0))
          (define words (shell-words l))
          (define t (and (pair? words) (findf (lambda (x) (equal? (tool-name x) (car words))) tools)))
          (define-values (out status)
            (cond
              [(not t) (values (format "no tool ~a (raco fhir-mcp tools lists them)" (if (pair? words) (car words) "")) 1)]
              [else
               (define-values (out err?) (with-handlers ([exn:fail? (lambda (e) (values (exn-message e) #t))])
                                           (call-tool t (call-arguments (cdr words)))))
               (values out (if (or err? (reports-errors? out)) 1 0))]))
          (define ok? (if expect-fail? (and t (= status 1)) (zero? status)))
          (printf "### ~a~a\n"
                  (cond [(and expect-fail? ok?) "[failed, as expected] "]
                        [(and expect-fail? t) "[exit 0, expected to fail] "]
                        [ok? ""]
                        [else "[exit 1] "])
                  l0)
          (displayln (if (opts-indent? o) (indent-json-text out) out))
          (flush-output)
          (cons (if ok? 0 1) expect-fail?)))
      (define failed (for/sum ([x (in-list statuses)]) (car x)))
      (define expected (for/sum ([x (in-list statuses)] #:when (and (cdr x) (zero? (car x)))) 1))
      (printf "### ~a line(s), ~a failed~a~a\n" (length statuses) failed
              (if (zero? expected) "" (format " (~a more failed as expected)" expected))
              (if (zero? failed) ""
                  (format ": ~a" (string-join (for/list ([l (in-list lines)] [x (in-list statuses)] #:unless (zero? (car x))) l) "; "))))
      (exit (if (zero? failed) 0 1)))))

;; indent-json-text : text -> text   a JSON answer laid out two spaces a level, its keys in the order
;; the answer wrote them (re-reading it as a jsexpr would lose that order); an array or object of
;; scalars short enough stays on one line; text that is not JSON (CSV) as it is. A long stage or history
;; answer on one line was hard to read in a terminal (a rerun's agent asked for --indent)
(define (indent-json-text text)
  (cond
    [(not (with-handlers ([exn:fail? (lambda (_) #f)]) (string->jsexpr text) #t)) text]
    [else
     (define in (open-input-string text))
     ;; tokens: strings kept whole, punctuation, and runs of other characters (numbers, literals)
     (define (next-token)
       (define c (peek-char in))
       (cond
         [(eof-object? c) c]
         [(char-whitespace? c) (read-char in) (next-token)]
         [(char=? c #\") (let loop ([acc (list (read-char in))])
                            (define d (read-char in))
                            (cond [(char=? d #\\) (loop (list* (read-char in) d acc))]
                                  [(char=? d #\") (list->string (reverse (cons d acc)))]
                                  [else (loop (cons d acc))]))]
         [(memv c '(#\{ #\} #\[ #\] #\, #\:)) (string (read-char in))]
         [else (let loop ([acc '()])
                 (define d (peek-char in))
                 (if (or (eof-object? d) (char-whitespace? d) (memv d '(#\{ #\} #\[ #\] #\, #\:)))
                     (list->string (reverse acc))
                     (loop (cons (read-char in) acc))))]))
     (define tokens (let loop ([acc '()]) (define t (next-token)) (if (eof-object? t) (reverse acc) (loop (cons t acc)))))
     ;; a value: (values text rest), laid out at depth d
     (define (pad d) (make-string (* 2 d) #\space))
     (define (value ts d)
       (define t (car ts))
       (cond
         [(member t '("{" "["))
          (define close (if (equal? t "{") "}" "]"))
          (let loop ([ts (cdr ts)] [items '()])
            (cond
              [(equal? (car ts) close)
               (define parts (reverse items))
               (define flat (string-append t (string-join parts ", ") close))
               (values (if (or (null? parts)
                               (and (< (string-length flat) 72) (not (regexp-match? #rx"[{[].*[{[]" (substring flat 1)))))
                           flat
                           (string-append t "\n" (string-join (map (lambda (p) (string-append (pad (add1 d)) p)) parts) ",\n")
                                          "\n" (pad d) close))
                       (cdr ts))]
              [(equal? (car ts) ",") (loop (cdr ts) items)]
              [(equal? t "{")
               (define key (car ts))
               (define-values (v rest) (value (cddr ts) (add1 d)))
               (loop rest (cons (string-append key ": " v) items))]
              [else
               (define-values (v rest) (value ts (add1 d)))
               (loop rest (cons v items))]))]
         [else (values t (cdr ts))]))
     (define-values (out _rest) (value tokens 0))
     out]))

;; shell-words : line -> (listof string)   split as a shell would: blanks separate, '…' and "…" quote
;; (inside "…", \" and \\ escape, and \n is a newline — a batch line is one line, so an inline FSH
;; text needs it; `fsh="Instance: x\nInstanceOf: …"` read `\n` as `n`), so `text="SELECT * FROM r1"` is one word
(define (shell-words l)
  (let loop ([cs (string->list l)] [word #f] [out '()] [q #f])
    (define (done) (if word (cons (list->string (reverse word)) out) out))
    (cond
      [(null? cs) (reverse (done))]
      [(and (not q) (char-whitespace? (car cs))) (loop (cdr cs) #f (done) #f)]
      [(and (not q) (memv (car cs) '(#\' #\"))) (loop (cdr cs) (or word '()) out (car cs))]
      [(and q (char=? (car cs) q)) (loop (cdr cs) word out #f)]
      [(and (eqv? q #\") (char=? (car cs) #\\) (pair? (cdr cs)))
       (loop (cddr cs) (cons (case (cadr cs) [(#\n) #\newline] [(#\t) #\tab] [else (cadr cs)]) (or word '())) out q)]
      [else (loop (cdr cs) (cons (car cs) (or word '())) out q)])))

;; reports-errors? : text -> boolean   an answer that counts errors (a stage that cannot commit, a
;; check with problems at error level): the shell's exit status says so too, as the JSON does
(define (reports-errors? text)
  (define js (with-handlers ([exn:fail? (lambda (_) #f)]) (string->jsexpr text)))
  (and (hash? js) (let ([n (hash-ref js 'errors #f)]) (and (exact-positive-integer? n) #t))))

;; call-arguments : (listof string) -> jsexpr   a JSON object (or `-`: JSON on stdin), then
;; `key=value` (a string), `key=@file` (the file's text: FSH, CQL, SQL with no escaping) and
;; `key:=<json>` (a number, a boolean, an array, an object; `key:=@file` reads the JSON from a
;; file: an operation's inputs, a manifest), later ones winning
(define (call-arguments words)
  (define (bad msg) (usage-error "fhir-mcp" usages "call" msg))
  (define (json-of s what)
    (with-handlers ([exn:fail? (lambda (_) (bad (format "~a is not JSON" what)))]) (string->jsexpr s)))
  (for/fold ([args (hasheq)]) ([w (in-list words)])
    (cond
      [(equal? w "-") (let ([j (json-of (port->string (current-input-port)) "stdin")])
                        (if (hash? j) (for/fold ([a args]) ([(k v) (in-hash j)]) (hash-set a k v)) (bad "stdin is not a JSON object")))]
      [(regexp-match? #rx"^[ \t\n]*[{]" w)
       (let ([j (json-of w "the arguments")]) (for/fold ([a args]) ([(k v) (in-hash j)]) (hash-set a k v)))]
      [(regexp-match #rx"^([A-Za-z_][A-Za-z0-9_]*):=@(.+)$" w)
       => (lambda (m) (define f (caddr m))
            (unless (file-exists? f) (bad (format "~a:=@~a: no such file" (cadr m) f)))
            (hash-set args (string->symbol (cadr m)) (json-of (file->string f) f)))]
      [(regexp-match #rx"^([A-Za-z_][A-Za-z0-9_]*):=(.*)$" w)
       => (lambda (m) (hash-set args (string->symbol (cadr m)) (json-of (caddr m) (format "~a's value" (cadr m)))))]
      [(regexp-match #rx"^([A-Za-z_][A-Za-z0-9_]*)=@(.+)$" w)
       => (lambda (m) (define f (caddr m))
            (unless (file-exists? f) (bad (format "~a=@~a: no such file" (cadr m) f)))
            ;; the file's name goes with its text (`files`), so a stage's errors and its Provenance
            ;; name `patients.fsh:12`, not the text
            (hash-set (hash-set args (string->symbol (cadr m)) (file->string f))
                      'files (hash-set (hash-ref args 'files (hasheq)) (string->symbol (cadr m)) f)))]
      [(regexp-match #rx"^([A-Za-z_][A-Za-z0-9_]*)=(.*)$" w)
       => (lambda (m) (hash-set args (string->symbol (cadr m)) (caddr m)))]
      [else (bad (format "unexpected ~a (arguments are '<json>', key=value, key=@file or key:=<json>)" w))])))

;; init-command : args -> void   a directory made ready for an agent (mcp/init.rkt); one line per file
(define (init-command args)
  (define-values (dir fv)
    (let loop ([as args] [dir #f] [fv "4.0.1"])
      (cond [(null? as) (values (or dir ".") fv)]
            [(and (equal? (car as) "--fhir-version") (pair? (cdr as)))
             (unless (member (cadr as) '("4.0.1" "5.0.0")) (usage-error "fhir-mcp" usages "init" (format "--fhir-version ~a: 4.0.1 or 5.0.0" (cadr as))))
             (loop (cddr as) dir (cadr as))]
            [(and (not dir) (not (regexp-match? #rx"^-" (car as)))) (loop (cdr as) (car as) fv)]
            [else (usage-error "fhir-mcp" usages "init" (format "unexpected ~a" (car as)))])))
  (for ([r (in-list (init-workspace! dir #:fhir-version fv))])
    (printf "~a ~a\n" (if (eq? (cdr r) 'written) "wrote" "kept ") (path->string (build-path dir (car r)))))
  (printf "The data is ~a, a SQLite FHIR store: stage and commit write it; raco fhir-server load ~a <dir> imports FHIR JSON.\nFrom an MCP client (Claude Code reads .mcp.json in ~a), or from the shell: raco fhir-mcp call <tool> … (run in ~a, or with --workspace ~a).\nGuides: raco fhir guide workspace (the MCP client reads them as learn://workspace).\n"
          (path->string (build-path dir "fhir.db")) (path->string (build-path dir "fhir.db")) dir dir dir))

;; guide-which : args cmd -> 'list | n | #f   `--blocks`, `--block N`, else the whole guide
(define (guide-which as cmd)
  (match as
    ['() #f]
    [(list "--blocks") 'list]
    [(list "--block" n) (if (exact-positive-integer? (string->number n)) (string->number n) n)]
    [_ (usage-error cmd usages "guide" (format "after the topic: --blocks, or --block N or a name (got ~a)" (string-join as " ")))]))

;; guide-command : args -> void   learn://<topic> printed, or the topics with what each covers
(define (guide-command args)
  (define topic (and (pair? args) (car args)))
  (define which (guide-which (if (pair? args) (cdr args) '()) "fhir-mcp"))
  (cond
    [(not topic)
     (for ([t (in-list learn-topics)]) (printf "~a  ~a\n" (car t) (cdr t)))
     (printf "\nraco fhir-mcp guide <topic> prints one (--blocks lists its code blocks, --block N or --block <name> prints one to save as a file); an MCP client reads it as learn://<topic>\n")]
    [(and which (learn-text topic))
     => (lambda (text) (define out (guide-block-text text which))
          (if out (display out)
              (usage-error "fhir-mcp" usages "guide" (format "~a has no block ~a (--blocks lists its ~a blocks)" topic (cadr (member "--block" args)) (length (guide-blocks text))))))]
    [(learn-text topic) => display]
    [else (usage-error "fhir-mcp" usages "guide"
                       (format "no guide ~a (topics: ~a)" topic (string-join (map car learn-topics) ", ")))]))

;; broken-pipe? : exn -> boolean   stdout closed by the reader (`… | head`): not an error of ours
(define (broken-pipe? e)
  (and (exn:fail:filesystem:errno? e) (equal? (exn:fail:filesystem:errno-errno e) '(32 . posix))))

(module+ main
  (define args (vector->list (current-command-line-arguments)))
  ;; `raco fhir-mcp guide fhir | head` closes the pipe early: end quietly, as a shell tool does
  (let ([default (uncaught-exception-handler)])
    (uncaught-exception-handler (lambda (e) (if (broken-pipe? e) (exit 0) (default e)))))
  (cond
    ;; -h/--help: every usage on stdout, exit 0 (as every raco command of the family)
    [(and (pair? args) (member (car args) '("-h" "--help")))
     (for ([u (in-list usages)]) (printf "~a\n" (cadr u)))
     (exit 0)]
    [(or (null? args) (regexp-match? #rx"^--" (car args))) (serve-command args)]
    [else (run-subcommands "fhir-mcp" usages
                           (hash "serve" serve-command "tools" tools-command "call" call-command "batch" batch-command "init" init-command "guide" guide-command "export" export-command)
                           args)]))

(module+ test
  (require rackunit racket/file)
  ;; key=@file reads the file's text and keeps its name, so a stage's errors name the file
  (define f (make-temporary-file "args-~a.fsh"))
  (with-output-to-file f #:exists 'truncate (lambda () (display "Instance: x\nInstanceOf: Patient\n")))
  (define args (call-arguments (list (format "fsh=@~a" f) "reason=intake" "n:=3")))
  (check-equal? (hash-ref args 'fsh) "Instance: x\nInstanceOf: Patient\n")
  (check-equal? (hash-ref (hash-ref args 'files) 'fsh) (path->string f))
  (check-equal? (hash-ref args 'reason) "intake")
  (check-equal? (hash-ref args 'n) 3)
  (delete-file f)
  ;; key:=@file reads the file's JSON (an operation's inputs, a manifest)
  (let ([j (make-temporary-file "args-~a.json")])
    (with-output-to-file j #:exists 'truncate (lambda () (display "{\"canonical\": \"http://x/StructureDefinition/lab\"}")))
    (check-equal? (hash-ref (call-arguments (list (format "inputs:=@~a" j))) 'inputs) (hasheq 'canonical "http://x/StructureDefinition/lab"))
    (delete-file j))
  ;; --indent lays a JSON answer out, keys in the answer's order, short scalar lists on one line; the
  ;; same JSON back; CSV untouched
  (define answer "{\"stage\":\"stage-1\",\"changes\":[{\"ref\":\"Observation/a1\",\"changed\":[\"value: 150 → 140\",\"note: \\\"x, y\\\"\"]}],\"errors\":0,\"tags\":[1,2]}")
  (define laid (indent-json-text answer))
  (check-equal? laid (string-append "{\n  \"stage\": \"stage-1\",\n  \"changes\": [\n    {\n      \"ref\": \"Observation/a1\",\n"
                                    "      \"changed\": [\"value: 150 → 140\", \"note: \\\"x, y\\\"\"]\n    }\n  ],\n"
                                    "  \"errors\": 0,\n  \"tags\": [1, 2]\n}"))
  (check-equal? (string->jsexpr laid) (string->jsexpr answer))
  (check-equal? (indent-json-text "a,b\n1,2") "a,b\n1,2")
  ;; a batch line: \n inside "…" is a newline (inline FSH on one line), \" a quote
  (check-equal? (shell-words "stage fsh=\"Instance: x\\nInstanceOf: Patient\" note=\"a \\\"b\\\"\"")
                '("stage" "fsh=Instance: x\nInstanceOf: Patient" "note=a \"b\"")))
