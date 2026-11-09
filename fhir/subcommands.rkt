#lang racket/base

;;; subcommands.rkt — the shape of a `raco <tool> <command> …` CLI, shared by `raco fhir` and
;;; `raco fhir-server`: one usage line per command; `-h`/`--help` (on the tool or any command) prints
;;; usage on stdout, exit 0; no command, an unknown one, or a usage error prints on stderr, exit 2.
;;;
;;; run-subcommands : tool usages handlers args -> any
;;;   usages   : (listof (list command usage-line))
;;;   handlers : (hash command -> (args-after-command -> any))
;;; usage-error : tool usages command [message] -> exits 2
;;; require-files! : tool usages command files -> void   a missing file is a usage error

(require)

(provide run-subcommands usage-error require-files!)

(define (overview tool usages)
  (string-append (format "usage: raco ~a <command> …\n" tool)
                 (apply string-append (for/list ([u (in-list usages)]) (format "  ~a\n" (cadr u))))))

(define (usage-error tool usages cmd [msg #f])
  (when msg (eprintf "raco ~a ~a: ~a\n" tool cmd msg))
  (eprintf "usage: ~a\n" (cadr (assoc cmd usages)))
  (exit 2))

(define (require-files! tool usages cmd files)
  (for ([f (in-list files)] #:unless (file-exists? f))
    (usage-error tool usages cmd (format "no such file: ~a" f))))

(define (help? a) (and (member a '("-h" "--help")) #t))

(define (run-subcommands tool usages handlers args)
  (define cmd (and (pair? args) (car args)))
  (cond
    [(not cmd) (eprintf "~a" (overview tool usages)) (exit 2)]
    [(help? cmd) (display (overview tool usages)) (exit 0)]
    [(not (hash-ref handlers cmd #f))
     (eprintf "raco ~a: unknown command ~a\n~a" tool cmd (overview tool usages)) (exit 2)]
    [(ormap help? (cdr args)) (printf "usage: ~a\n" (cadr (assoc cmd usages))) (exit 0)]
    [else ((hash-ref handlers cmd) (cdr args))]))

(module+ test
  (require rackunit)
  (define usages '(("go" "raco t go <x>")))
  (define ran #f)
  (run-subcommands "t" usages (hash "go" (lambda (as) (set! ran as))) '("go" "1"))
  (check-equal? ran '("1")))
