#lang racket/base

;;; editors-test.rkt — the editor configurations the manual gives, run in the editors themselves.
;;;
;;; The Neovim and Emacs blocks are read out of scribblings/fhir-lsp.scrbl as written, given to a
;;; headless editor as its init file, and the manual's own first example (bp.fsh, one misspelt
;;; element) is opened: the server must attach, the misspelling must be reported with the message
;;; the manual quotes, hover on `subject` must answer, and correcting the spelling must clear the
;;; problem. An editor that is not installed is skipped with a note (Neovim 0.10+, Emacs 29+;
;;; FHIR_LSP_NVIM / FHIR_LSP_EMACS name a binary that is not on PATH).
;;;
;;; What running them found: Emacs writes a lock file `.#bp.fsh` beside a buffer as soon as it
;;; changes, and the FSH project read it as a source ("cannot open input file" for the whole
;;; project); a mapping-language file had no type findings in an editor (no FHIR version was loaded
;;; in the server's process).

(require rackunit racket/file racket/string racket/system racket/port racket/runtime-path)

(define-runtime-path manual "../scribblings/fhir-lsp.scrbl")
(define text (file->string manual))

;; block : regexp regexp -> string   the lines of the manual from the one matching `from` to the
;; one matching `to`, as written
(define (block from to)
  (define lines (string-split text "\n" #:trim? #f))
  (define start (for/first ([l (in-list lines)] [i (in-naturals)] #:when (regexp-match? from l)) i))
  (define end (for/first ([l (in-list lines)] [i (in-naturals)] #:when (and start (>= i start) (regexp-match? to l))) i))
  (unless (and start end) (error 'editors-test "the manual's block ~a … ~a was not found" from to))
  (string-join (for/list ([l (in-list lines)] [i (in-naturals)] #:when (<= start i end)) l) "\n" #:after-last "\n"))

(define nvim-init (block #rx"^vim[.]filetype[.]add" #rx"^}[)]$"))
(define emacs-init (block #rx"^[(]define-derived-mode fsh-mode" #rx"add-hook hook #'eglot-ensure"))

(define bp "Profile: BloodPressure\nParent: Observation\nId: blood-pressure\n* subject 1..1\n* efective[x] 1..1\n")
(define message "profile: BloodPressure: `efective` is not an element of Observation (did you mean `effective`?)")

;; program : env-name name regexp min -> path | #f   the editor, when it is installed at a version
;; the manual's configuration is for
(define (program env name version-rx least)
  (define exe (or (getenv env) (find-executable-path name)))
  (define v (and exe (file-exists? exe)
                 (let ([m (regexp-match version-rx (with-output-to-string (lambda () (system* exe "--version"))))])
                   (and m (map string->number (cdr m))))))
  (cond [(and v (or (> (car v) (car least)) (and (= (car v) (car least)) (>= (cadr v) (cadr least))))) exe]
        [else (printf "editors-test: ~a ~a.~a or newer is not installed~a: skipped\n" name (car least) (cadr least)
                      (if v (format " (found ~a.~a)" (car v) (cadr v)) ""))
              #f]))

;; run-editor : exe args dir -> string   the editor's output, in `dir`
(define (run-editor exe args dir)
  (parameterize ([current-directory dir])
    (define out (open-output-string))
    (parameterize ([current-output-port out] [current-error-port out])
      (apply system* exe args))
    (get-output-string out)))

(define (check-session out who)
  (check-regexp-match #rx"attached: yes" out who)
  (check-true (and (string-contains? out message) #t) (format "~a reports the misspelling as the manual quotes it:\n~a" who out))
  (check-regexp-match #rx"line: 5" out who)
  (check-regexp-match #rx"hover: [^\n]*Observation[.]subject" out who)
  (check-regexp-match #rx"after the fix: 0" out who))

;; ---- Neovim ----------------------------------------------------------------------------------
(define nvim-probe #<<LUA
vim.wait(90000, function() return #vim.diagnostic.get(0) > 0 end, 200)
local out = { "attached: " .. (#vim.lsp.get_clients({ bufnr = 0 }) == 1 and "yes" or "no") }
for _, d in ipairs(vim.diagnostic.get(0)) do
  table.insert(out, "line: " .. (d.lnum + 1))
  table.insert(out, "message: " .. d.message)
end
vim.api.nvim_win_set_cursor(0, { 4, 3 })
local res = vim.lsp.buf_request_sync(0, "textDocument/hover", vim.lsp.util.make_position_params(), 30000)
for _, r in pairs(res or {}) do
  local c = r.result and r.result.contents
  local text = type(c) == "table" and (c.value or vim.inspect(c)) or tostring(c)
  table.insert(out, "hover: " .. (text:gsub("\n", " ")))
end
vim.api.nvim_buf_set_lines(0, 4, 5, false, { "* effective[x] 1..1" })
vim.wait(90000, function() return #vim.diagnostic.get(0) == 0 end, 200)
table.insert(out, "after the fix: " .. #vim.diagnostic.get(0))
vim.fn.writefile(out, "probe.out")
vim.cmd("qa!")
LUA
  )

(let ([nvim (program "FHIR_LSP_NVIM" "nvim" #rx"NVIM v([0-9]+)[.]([0-9]+)" '(0 10))])
  (when nvim
    (define dir (make-temporary-directory "lsp-nvim-~a"))
    (display-to-file nvim-init (build-path dir "init.lua"))
    (display-to-file nvim-probe (build-path dir "probe.lua"))
    (display-to-file bp (build-path dir "bp.fsh"))
    (define said (run-editor nvim (list "--headless" "-u" "init.lua" "bp.fsh" "-c" "luafile probe.lua") dir))
    (check-session (if (file-exists? (build-path dir "probe.out")) (file->string (build-path dir "probe.out")) said) "Neovim")
    (delete-directory/files dir)))

;; ---- Emacs -----------------------------------------------------------------------------------
(define emacs-probe #<<ELISP
(defun probe-wait (pred secs)
  (let ((end (+ (float-time) secs)))
    (while (and (not (funcall pred)) (< (float-time) end)) (accept-process-output nil 0.2))))
(setq eglot-sync-connect 90 eglot-connect-timeout 120)
(find-file "bp.fsh")
(run-hooks 'post-command-hook)                    ; eglot-ensure connects after the first command
(probe-wait (lambda () (eglot-current-server)) 120)
(message "attached: %s" (if (eglot-current-server) "yes" "no"))
(probe-wait (lambda () (flymake-diagnostics)) 120)
(dolist (d (flymake-diagnostics))
  (message "line: %d" (line-number-at-pos (flymake-diagnostic-beg d)))
  (message "message: %s" (flymake-diagnostic-text d)))
(goto-char (point-min)) (forward-line 3) (forward-char 3)
(let ((h (jsonrpc-request (eglot-current-server) :textDocument/hover (eglot--TextDocumentPositionParams))))
  (message "hover: %s" (replace-regexp-in-string "\n" " " (plist-get (plist-get h :contents) :value))))
;; typing makes Emacs write its lock file, .#bp.fsh, beside the file
(goto-char (point-min)) (search-forward "efective") (replace-match "effective")
(setq probe-published nil)
(advice-add 'eglot-handle-notification :before
            (lambda (_s method &rest args)
              (when (eq method 'textDocument/publishDiagnostics) (setq probe-published t))))
(eglot--signal-textDocument/didChange)
(probe-wait (lambda () probe-published) 90)
(flymake-start)
(probe-wait (lambda () (null (flymake-diagnostics))) 20)
(message "after the fix: %d" (length (flymake-diagnostics)))
(dolist (d (flymake-diagnostics)) (message "still: %s" (flymake-diagnostic-text d)))
(set-buffer-modified-p nil)
(eglot-shutdown (eglot-current-server))
ELISP
  )

(let ([emacs (program "FHIR_LSP_EMACS" "emacs" #rx"GNU Emacs ([0-9]+)[.]([0-9]+)" '(29 1))])
  (when emacs
    (define dir (make-temporary-directory "lsp-emacs-~a"))
    (display-to-file emacs-init (build-path dir "init.el"))
    (display-to-file emacs-probe (build-path dir "probe.el"))
    (display-to-file bp (build-path dir "bp.fsh"))
    (define said (run-editor emacs (list "--batch" "-l" "init.el" "-l" "probe.el") dir))
    (check-session said "Emacs")
    (delete-directory/files dir)))
