#lang racket/base

;;; parallel.rkt — map a function over items on every core, in order.
;;;
;;; Racket threads share one core, and Racket CS places share one heap (a garbage collection stops
;;; every place), so allocation-heavy work scales with neither. Worker PROCESSES do: each is a
;;; `racket` of its own with its own heap. A worker starts empty, so the function to run is named,
;;; not passed: a module path and an export (`(list 'fhir/tests/example-harness 'verdict)`), which
;;; each worker dynamic-requires — after instantiating an optional setup module (a type tower, say).
;;; Items and results travel as written S-expressions over the worker's stdin/stdout, so they must
;;; be readable data: numbers, strings, symbols, booleans, and lists, vectors and hashes of those.
;;;
;;; Data definitions
;;;   A Fn is (list module-path symbol) — where the function lives and what it is called.
;;;   A Message to a worker is (list index item) or done; from a worker, (list index ok result)
;;;   or (list index error message-string).
;;; Items are handed out one at a time as workers finish (work stealing), so uneven items balance.
;;; A worker's error is re-raised in the caller, naming the item's index; a worker's stderr is
;;; relayed. With one worker the function runs here, sequentially — same results.
;;; FHIR_WORKERS=n in the environment sets the default worker count (1 keeps everything in-process).
;;; A worker is a `racket` process, so a program with no Racket executable to start (a standalone
;;; build of the command-line tools, build-tools.sh) runs the function here too.

(require racket/contract racket/list racket/port racket/system (only-in racket/future processor-count)
         (only-in compiler/find-exe find-exe))

(provide
 (contract-out
  [parallel-map (->* (fn/c list?)
                     (#:workers exact-positive-integer? #:setup (or/c module-path? #f))
                     list?)]
  [fn/c contract?]
  [default-workers (-> exact-positive-integer?)]
  [worker-main (-> void?)]))

(define fn/c (list/c module-path? symbol?))

;; default-workers : -> Nat   one per core, or what FHIR_WORKERS says
(define (default-workers)
  (define env (getenv "FHIR_WORKERS"))
  (define n (and env (string->number env)))
  (if (exact-positive-integer? n) n (max 1 (processor-count))))

;; parallel-map : Fn (listof Item) [#:workers Nat] [#:setup module-path] -> (listof Result)
(define (parallel-map fn items #:workers [workers (default-workers)] #:setup [setup #f])
  (define k (min workers (length items)))
  (if (or (<= k 1) (not (racket-executable)))
      (map (load-fn fn setup) items)
      (parallel-map/processes fn items k setup)))

;; racket-executable : -> (or/c path #f)   the Racket a worker runs on, or #f when there is none
(define racket-executable
  (let ([found 'unknown])
    (lambda ()
      (when (eq? found 'unknown) (set! found (with-handlers ([exn:fail? (lambda (_) #f)]) (find-exe))))
      found)))

;; load-fn : Fn module-path|#f -> procedure   instantiate the setup, then fetch the function
(define (load-fn fn setup)
  (when setup (dynamic-require setup #f))
  (dynamic-require (car fn) (cadr fn)))

;; ---- the workers ----------------------------------------------------------------------------------
;; A Worker is (worker process in out): the subprocess, its stdout (we read), its stdin (we write).
(struct worker (process in out))

;; start-worker : Fn module-path|#f -> Worker   a racket running worker-main, told the Fn and setup
(define (start-worker fn setup)
  (define-values (p out in err)
    (subprocess #f #f #f (racket-executable) "-l" "racket/base" "-l" "fhir/parallel" "-e" "(worker-main)"))
  (thread (lambda () (copy-port err (current-error-port)) (close-input-port err)))
  (send! in (list fn setup))
  (worker p out in))

;; send! : output-port Any -> Void   one written datum, flushed
(define (send! port v) (write v port) (newline port) (flush-output port))

;; parallel-map/processes : Fn (listof Item) Nat module-path|#f -> (listof Result)
;; k workers; items dealt one at a time to whichever worker answers; results kept by index. Only a
;; worker with an item outstanding is waited on: one told `done` exits, and its closed stdout
;; would otherwise read as ready.
(define (parallel-map/processes fn items k setup)
  (define workers (for/list ([_ (in-range k)]) (start-worker fn setup)))
  (define results (make-vector (length items) #f))
  (define remaining (for/list ([it (in-list items)] [i (in-naturals)]) (list i it)))
  (define busy '())                                   ; the workers with an item outstanding
  (define (feed! w)
    (cond [(pair? remaining) (send! (worker-out w) (car remaining)) (set! remaining (cdr remaining)) (set! busy (cons w busy))]
          [else (send! (worker-out w) 'done)]))
  (define (stop-all!)
    (for ([w (in-list workers)]) (subprocess-kill (worker-process w) #t)))
  (with-handlers ([exn:fail? (lambda (e) (stop-all!) (raise e))])
    (for ([w (in-list workers)]) (feed! w))
    (let loop ()
      (when (pair? busy)
        (define w (sync (apply choice-evt (for/list ([w (in-list busy)]) (wrap-evt (worker-in w) (lambda (_) w))))))
        (define m (read (worker-in w)))
        (set! busy (remq w busy))
        (cond
          [(eof-object? m) (error 'parallel-map "a worker exited unexpectedly")]
          [(eq? (cadr m) 'ok) (vector-set! results (car m) (caddr m))]
          [else (error 'parallel-map "item ~a: ~a" (car m) (caddr m))])
        (feed! w)
        (loop))))
  (for ([w (in-list workers)])
    (close-output-port (worker-out w))
    (subprocess-wait (worker-process w))
    (close-input-port (worker-in w)))
  (vector->list results))

;; worker-main : -> Void   the body of a worker process: read the Fn and setup, load the function,
;; then answer every (index item) read from stdin on stdout until done
(define (worker-main)
  (define in (current-input-port))
  (define out (current-output-port))
  (define spec (read in))
  (define f (load-fn (car spec) (cadr spec)))
  (let loop ()
    (define m (read in))
    (unless (or (eof-object? m) (eq? m 'done))
      (send! out (with-handlers ([exn:fail? (lambda (e) (list (car m) 'error (exn-message e)))])
                   (list (car m) 'ok (f (cadr m)))))
      (loop))))

;; ---- living examples ----------------------------------------------------------------------------
(module+ test
  (require rackunit)
  (define squares (list 'fhir/parallel 'square))
  (check-equal? (parallel-map squares '(1 2 3 4 5 6 7) #:workers 1) '(1 4 9 16 25 36 49))
  (check-equal? (parallel-map squares '() #:workers 3) '())
  ;; across processes: the same answers, in order, whatever the balance of work
  (check-equal? (parallel-map squares (range 1 41) #:workers 3) (map (lambda (x) (* x x)) (range 1 41)))
  ;; a worker's error reaches the caller, naming the item
  (check-exn #rx"item 2: boom" (lambda () (parallel-map (list 'fhir/parallel 'explode-at-3) '(1 2 3 4) #:workers 2))))
;; the examples' functions (exported so a worker can find them)
(provide square explode-at-3)
(define (square x) (* x x))
(define (explode-at-3 x) (if (= x 3) (error "boom") x))
