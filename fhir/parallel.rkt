#lang racket/base

;;; parallel.rkt — map a function over items on every core, in order.
;;;
;;; Racket threads share one core, and Racket CS places share one heap (a garbage collection stops
;;; every place), so allocation-heavy work scales with neither. Worker PROCESSES do: each is a
;;; `racket` of its own with its own heap. A worker starts empty, so the function to run is named,
;;; not passed: a module path and an export (`(list 'fhir/tests/example-harness 'verdict)`), which
;;; each worker dynamic-requires — after instantiating an optional setup module (a type tower, say).
;;; Items and results travel over the worker's stdin/stdout (racket/fasl), so they must be plain
;;; data: numbers, strings, symbols, booleans, and lists, vectors and hashes of those.
;;;
;;; Data definitions
;;;   A Fn is (list module-path symbol) — where the function lives and what it is called.
;;;   A Message to a worker is (list index item) or done; from a worker, (list index ok result)
;;;   or (list index error message-string).
;;; Items are handed out one at a time as workers finish (work stealing), so uneven items balance.
;;; A Pool is the workers kept between maps: `parallel-map` starts its workers and stops them, which
;;; costs a process start and the setup module's load each time (a second or more when the setup is
;;; a FHIR type tower) — a caller with many batches to map (a bulk load: one batch per 2,000
;;; resources) makes one pool, maps each batch over it with `pool-map`, and closes it at the end.
;;; A worker's error is re-raised in the caller, naming the item's index; a worker's stderr is
;;; relayed. With one worker the function runs here, sequentially — same results.
;;; FHIR_WORKERS=n in the environment sets the default worker count (1 keeps everything in-process).
;;; A worker is a `racket` process, so a program with no Racket executable to start (a standalone
;;; build of the command-line tools, build-tools.sh) runs the function here too.

(require racket/contract racket/list racket/port racket/system racket/fasl (only-in racket/future processor-count)
         (only-in compiler/find-exe find-exe))

(provide
 (contract-out
  [parallel-map (->* (fn/c list?)
                     (#:workers exact-positive-integer? #:setup (or/c module-path? #f))
                     list?)]
  ;; the workers kept for many maps (pool-map), until closed
  [make-worker-pool (->* (fn/c) (#:workers exact-positive-integer? #:setup (or/c module-path? #f) #:init any/c) pool?)]
  [pool-map (-> pool? list? list?)]
  [close-worker-pool (-> pool? void?)]
  [pool? (-> any/c boolean?)]
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
  (define p (make-worker-pool fn #:workers (min workers (length items)) #:setup setup))
  (begin0 (pool-map p items) (close-worker-pool p)))

;; ---- pools ------------------------------------------------------------------------------------
;; A Pool is (pool workers local): its worker processes, or — with one worker, or no Racket
;; executable to start workers on — the function itself, run in this process (`local`).
(struct pool (workers local))

;; make-worker-pool : Fn [#:workers Nat] [#:setup module-path] [#:init datum] -> Pool
;; With `#:init v` the Fn's export is a MAKER: applied to v once in each worker, it answers the
;; function the items are given to — what every item needs and none should carry (a catalogue).
(define (make-worker-pool fn #:workers [workers (default-workers)] #:setup [setup #f] #:init [init no-init])
  (if (and (> workers 1) (racket-executable))
      (pool (for/list ([_ (in-range workers)]) (start-worker fn setup init)) #f)
      (pool '() (item-function (load-fn fn setup) init))))

;; pool-map : Pool (listof Item) -> (listof Result)   the items over the pool, results in order
(define (pool-map p items)
  (if (pool-local p)
      (map (pool-local p) items)
      (map-over-workers (pool-workers p) items)))

;; close-worker-pool : Pool -> Void   every worker told it is done, and waited for
(define (close-worker-pool p)
  (for ([w (in-list (pool-workers p))])
    (with-handlers ([exn:fail? void]) (send! (worker-out w) 'done))
    (close-output-port (worker-out w))
    (subprocess-wait (worker-process w))
    (close-input-port (worker-in w))))

;; no-init : the absence of an `#:init` (any datum, #f included, may be one)
(define no-init (string->uninterned-symbol "no-init"))
;; item-function : procedure init -> procedure   the export itself, or what it makes of the init
(define (item-function f init) (if (eq? init no-init) f (f init)))

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

;; start-worker : Fn module-path|#f init -> Worker   a racket running worker-main, told the Fn, the
;; setup and (when there is one) the init
(define (start-worker fn setup init)
  (define-values (p out in err)
    (subprocess #f #f #f (racket-executable) "-l" "racket/base" "-l" "fhir/parallel" "-e" "(worker-main)"))
  (thread (lambda () (copy-port err (current-error-port)) (close-input-port err)))
  (send! in (if (eq? init no-init) (list fn setup) (list fn setup init)))
  (worker p out in))

;; send! : output-port Any -> Void   one datum, flushed
;; read-message : input-port -> Any | eof   the next datum
;; Messages travel in Racket's fast-load form (racket/fasl), not as written text: a message of
;; strings (a chunk of JSON lines, the prepared resources that come back) is read three to four
;; times faster, and the dispatcher's reading is what every worker waits on. A datum is exactly
;; its bytes — nothing is left in the pipe after it. (Written text was followed by a newline that
;; stayed there, so a worker's port looked ready for ever after its first answer: the dispatcher
;; picked a worker that had only just been fed, blocked on its answer for as long as it took to
;; compute, and left the others idle with theirs ready — four workers gave 1.35 times one.)
(define (send! port v) (s-exp->fasl v port) (flush-output port))
(define (read-message in)
  (if (eof-object? (peek-byte in)) eof (fasl->s-exp in)))

;; map-over-workers : (listof Worker) (listof Item) -> (listof Result)
;; Items dealt one at a time to whichever worker answers; results kept by index. Only a worker
;; with an item outstanding is waited on. The workers are left running: every one has answered
;; all it was given when this returns. An error (a worker's, or a worker gone) stops them all.
(define (map-over-workers workers items)
  (define results (make-vector (length items) #f))
  (define remaining (for/list ([it (in-list items)] [i (in-naturals)]) (list i it)))
  (define busy '())                                   ; the workers with an item outstanding
  (define (feed! w)
    (when (pair? remaining)
      (send! (worker-out w) (car remaining)) (set! remaining (cdr remaining)) (set! busy (cons w busy))))
  (define (stop-all!)
    (for ([w (in-list workers)]) (subprocess-kill (worker-process w) #t)))
  (with-handlers ([exn:fail? (lambda (e) (stop-all!) (raise e))])
    (for ([w (in-list workers)]) (feed! w))
    (let loop ()
      (when (pair? busy)
        (define w (sync (apply choice-evt (for/list ([w (in-list busy)]) (wrap-evt (worker-in w) (lambda (_) w))))))
        (define m (read-message (worker-in w)))
        (set! busy (remq w busy))
        (cond
          [(eof-object? m) (error 'parallel-map "a worker exited unexpectedly")]
          [(eq? (cadr m) 'ok) (vector-set! results (car m) (caddr m))]
          [else (error 'parallel-map "item ~a: ~a" (car m) (caddr m))])
        (feed! w)
        (loop))))
  (vector->list results))

;; worker-main : -> Void   the body of a worker process: read the Fn and setup, load the function,
;; then answer every (index item) read from stdin on stdout until done
(define (worker-main)
  (define in (current-input-port))
  (define out (current-output-port))
  (define spec (read-message in))
  (define f (item-function (load-fn (car spec) (cadr spec)) (if (pair? (cddr spec)) (caddr spec) no-init)))
  (let loop ()
    (define m (read-message in))
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
  ;; an answer read leaves nothing behind: a worker's port is ready only when it has answered
  (let-values ([(in out) (make-pipe)])
    (send! out '(0 ok 1))
    (check-equal? (read-message in) '(0 ok 1))
    (check-false (sync/timeout 0 in))
    (close-output-port out)
    (check-true (eof-object? (read-message in))))
  ;; a worker's error reaches the caller, naming the item
  (check-exn #rx"item 2: boom" (lambda () (parallel-map (list 'fhir/parallel 'explode-at-3) '(1 2 3 4) #:workers 2)))
  ;; a pool: the same workers answer one map after another (their process ids do not change)
  (define p (make-worker-pool squares #:workers 2))
  (define (pids p) (for/list ([w (in-list (pool-workers p))]) (subprocess-pid (worker-process w))))
  (define before (pids p))
  (check-equal? (pool-map p '(1 2 3)) '(1 4 9))
  (check-equal? (pool-map p (range 1 21)) (map (lambda (x) (* x x)) (range 1 21)))
  (check-equal? (pool-map p '()) '())
  (check-equal? (pids p) before)
  (close-worker-pool p)
  ;; one worker: the function runs here, with the same answers
  (define here (make-worker-pool squares #:workers 1))
  (check-equal? (pool-map here '(1 2 3)) '(1 4 9))
  (check-equal? (close-worker-pool here) (void))
  ;; an init: the export makes the item function from it, once in each worker
  (for ([k '(1 2)])
    (define scaled (make-worker-pool (list 'fhir/parallel 'scale-by) #:workers k #:init 10))
    (check-equal? (pool-map scaled '(1 2 3)) '(10 20 30))
    (close-worker-pool scaled)))
;; the examples' functions (exported so a worker can find them)
(provide square explode-at-3 scale-by)
(define ((scale-by k) x) (* k x))
(define (square x) (* x x))
(define (explode-at-3 x) (if (= x 3) (error "boom") x))
