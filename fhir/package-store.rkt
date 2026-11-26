#lang racket/base

;;; package-store.rkt — a package's conformance resources, without unpacking its archive again.
;;;
;;; A FHIR NPM package is a gzipped tar. Reading one means inflating all of it (Racket's inflate:
;;; 0.7 s for the R4 core package's 13 MB), and a process used to do so once for the definitions'
;;; index (sd/sd-index) and once more for the terminology's (fhir-tx): most of the two to three
;;; seconds a process's FIRST validation took. What both need is the same — the package's
;;; StructureDefinitions, CodeSystems, ValueSets, StructureMaps and ConceptMaps, each by its url,
;;; name and id, its JSON read when a lookup reaches it — and it depends on the archive alone.
;;;
;;; So the archive is read ONCE: each such resource's bytes are written one after another to a file
;;; in the user's cache directory (`FHIR_CACHE_DIR`, else Racket's cache directory), with an index
;;; of what stands where, keyed by the archive's path, size and time of writing. A later process
;;; reads the index (a few milliseconds) and then only the resources it looks up, by position.
;;; A cache that cannot be written or read is not used: the bytes are then kept in memory, read
;;; from the archive once a process (`FHIR_PACKAGE_CACHE=0` asks for that).
;;;
;;; A PackageEntry is (package-entry kind url name id read):
;;;   kind : one of `entry-kinds` — the resource type, from the file's name
;;;   url, name, id : String | #f — the resource's top-level elements of those names
;;;   read : (-> Bytes) — the file's bytes

(require racket/contract racket/file racket/fasl file/gunzip file/untar file/sha1 (only-in json bytes->jsexpr)
         (only-in fhir/serialize/fast-json fast-bytes->jsexpr))

(provide
 (struct-out package-entry)
 (contract-out
  ;; the resource types kept
  [entry-kinds (listof string?)]
  ;; package-entries : tgz -> (listof PackageEntry)   in the archive's order; the same list for as
  ;; long as the process lives
  [package-entries (-> path-string? (listof package-entry?))]
  ;; entry-bytes : PackageEntry -> Bytes   the file as the archive holds it
  [entry-bytes (-> package-entry? bytes?)]
  ;; skim-keys : Bytes -> (list url name id) | #f   see below
  [skim-keys (-> bytes? (or/c (list/c (or/c string? #f) (or/c string? #f) (or/c string? #f)) #f))]
  ;; fhir-cache-directory : -> Path   where the family keeps what it computes once a machine
  [fhir-cache-directory (-> path?)]))

(struct package-entry (kind url name id read))
(define (entry-bytes e) ((package-entry-read e)))

(define entry-kinds '("StructureDefinition" "CodeSystem" "ValueSet" "StructureMap" "ConceptMap"))
(define file-rx #px"^package/(StructureDefinition|CodeSystem|ValueSet|StructureMap|ConceptMap)-.*\\.json$")

(define (fhir-cache-directory)
  (define d (getenv "FHIR_CACHE_DIR"))
  (if (and d (not (string=? d ""))) (string->path d) (build-path (find-system-path 'cache-dir) "fhir-racket")))

;; ---- one list a package, for as long as the process lives ---------------------------------------
(define loaded (make-hash))                      ; complete path -> (listof PackageEntry)
(define (package-entries tgz)
  (define p (simplify-path (path->complete-path tgz)))
  (hash-ref! loaded p (lambda () (or (and (cache-wanted?) (kept-entries p)) (memory-entries (read-archive p))))))

(define (cache-wanted?) (not (equal? (getenv "FHIR_PACKAGE_CACHE") "0")))

;; ---- reading the archive -------------------------------------------------------------------------
;; A Raw is (vector kind url name id bytes): one kept file of the archive
;; read-archive : path -> (listof Raw)   in the archive's order
(define (read-archive tgz)
  (define-values (pin pout) (make-pipe (* 1024 1024)))
  (define inflate
    (thread (lambda () (call-with-input-file tgz (lambda (gz) (gunzip-through-ports gz pout)))
                    (close-output-port pout))))
  (define raws '())
  (untar pin
         #:handle-entry
         (lambda (kind name content size attribs)
           (when (eq? kind 'file)
             (define bytes (if (= size 0) #"" (read-bytes size content)))    ; always consume `size`
             (define m (regexp-match file-rx (path->string name)))
             (when m (set! raws (cons (raw-of (cadr m) bytes) raws))))
           '()))
  (thread-wait inflate)
  (reverse raws))

;; raw-of : kind bytes -> Raw   the file with its resource's url, name and id: skimmed from the
;; bytes, else (a JSON object the skim does not follow) read from the parsed resource; a file that
;; is no JSON object has none
(define (raw-of kind bs)
  (define keys
    (or (skim-keys bs)
        (let ([js (with-handlers ([exn:fail? (lambda (_) #f)]) (fast-bytes->jsexpr bs))])
          (if (hash? js)
              (for/list ([k (in-list '(url name id))]) (let ([v (hash-ref js k #f)]) (and (string? v) v)))
              (list #f #f #f)))))
  (vector kind (car keys) (cadr keys) (caddr keys) bs))

;; memory-entries : (listof Raw) -> (listof PackageEntry)   the bytes held by the process
(define (memory-entries raws)
  (for/list ([r (in-list raws)])
    (define bs (vector-ref r 4))
    (package-entry (vector-ref r 0) (vector-ref r 1) (vector-ref r 2) (vector-ref r 3) (lambda () bs))))

;; ---- kept between processes ------------------------------------------------------------------------
;; Two files a package, named by the SHA-1 of what they depend on: `<key>.dat` is the kept files'
;; bytes one after another; `<key>.idx` is (list store-format total (vector kind url name id
;; offset length) ...) as fasl, written LAST, so an index that is there describes data that is.
(define store-format 1)

;; store-files : path -> (values idx dat)
(define (store-files tgz)
  (define key (format "~a|~a|~a|~a" store-format (path->string tgz) (file-size tgz) (file-or-directory-modify-seconds tgz)))
  (define stem (sha1 (open-input-string key)))
  (define dir (build-path (fhir-cache-directory) "packages"))
  (values (build-path dir (string-append stem ".idx")) (build-path dir (string-append stem ".dat"))))

;; kept-entries : path -> (listof PackageEntry) | #f   read from the cache, written there first when
;; it holds nothing for this archive; #f when the cache cannot be used
(define (kept-entries tgz)
  (with-handlers ([exn:fail? (lambda (_) #f)])
    (define-values (idx dat) (store-files tgz))
    (define (read-index)
      (define d (and (file-exists? idx) (file-exists? dat) (call-with-input-file idx fasl->s-exp)))
      (and (list? d) (>= (length d) 2) (equal? (car d) store-format) (= (cadr d) (file-size dat)) (cddr d)))
    (define rows
      (or (with-handlers ([exn:fail? (lambda (_) #f)]) (read-index))
          (begin (write-store! tgz idx dat) (read-index))))
    (and rows (store-entries tgz dat rows))))

;; write-store! : path idx dat -> void   each file written beside its place and moved there whole,
;; so a reader never sees half of one (two processes writing at once write the same bytes)
(define (write-store! tgz idx dat)
  (define raws (read-archive tgz))
  (define-values (dir _n _d) (split-path idx))
  (make-directory* dir)
  (define (put! file write)
    (define tmp (make-temporary-file "pkg-~a.tmp" #f dir))
    (with-handlers ([(lambda (_) #t) (lambda (e) (when (file-exists? tmp) (delete-file tmp)) (raise e))])
      (call-with-output-file tmp #:exists 'truncate write)
      (rename-file-or-directory tmp file #t)))
  (put! dat (lambda (o) (for ([r (in-list raws)]) (write-bytes (vector-ref r 4) o))))
  (define-values (rows total)
    (for/fold ([rows '()] [at 0]) ([r (in-list raws)])
      (define n (bytes-length (vector-ref r 4)))
      (values (cons (vector (vector-ref r 0) (vector-ref r 1) (vector-ref r 2) (vector-ref r 3) at n) rows) (+ at n))))
  (put! idx (lambda (o) (s-exp->fasl (list* store-format total (reverse rows)) o))))

;; store-entries : path dat rows -> (listof PackageEntry)   each reads its bytes at its place. Should
;; the data be gone or changed under a process (a cache emptied while it runs), the archive is read
;; into memory once and answers from then on.
(define (store-entries tgz dat rows)
  (define fallback #f)                            ; (vectorof bytes), by position in the list
  (define (from-archive i)
    (unless fallback (set! fallback (for/vector ([r (in-list (read-archive tgz))]) (vector-ref r 4))))
    (vector-ref fallback i))
  (for/list ([row (in-list rows)] [i (in-naturals)])
    (define at (vector-ref row 4))
    (define n (vector-ref row 5))
    (package-entry
     (vector-ref row 0) (vector-ref row 1) (vector-ref row 2) (vector-ref row 3)
     (lambda ()
       (or (and (not fallback)
                (with-handlers ([exn:fail? (lambda (_) #f)])
                  (define bs (call-with-input-file dat (lambda (in) (file-position in at) (read-bytes n in))))
                  (and (bytes? bs) (= (bytes-length bs) n) bs)))
           (from-archive i))))))

;; skim-keys : bytes -> (list url name id) | #f
;; The top-level "url", "name" and "id" of a JSON object (each a string, or #f when absent or not a
;; string), read without building the object: nested values are skipped by bracket depth. #f when the
;; bytes are not a JSON object this reader follows (the caller then parses them in full).
(define (skim-keys bs)
  (define n (bytes-length bs))
  (define (ws i) (if (and (< i n) (memv (bytes-ref bs i) '(32 9 10 13))) (ws (add1 i)) i))
  (define (string-end i)                         ; i just after the opening quote -> index of the closing one
    (cond [(>= i n) #f]
          [(= (bytes-ref bs i) 34) i]
          [(= (bytes-ref bs i) 92) (string-end (+ i 2))]
          [else (string-end (add1 i))]))
  (define (decode i j)                           ; the string between quotes at i-1 and j
    (define raw (subbytes bs i j))
    (if (for/or ([b (in-bytes raw)]) (= b 92))
        (with-handlers ([exn:fail? (lambda (_) #f)]) (bytes->jsexpr (subbytes bs (sub1 i) (add1 j))))
        (with-handlers ([exn:fail? (lambda (_) #f)]) (bytes->string/utf-8 raw))))
  (define (skip-value i)                         ; -> index just after the value, or #f
    (cond
      [(>= i n) #f]
      [(= (bytes-ref bs i) 34) (let ([e (string-end (add1 i))]) (and e (add1 e)))]
      [(memv (bytes-ref bs i) '(123 91))
       (let loop ([i (add1 i)] [depth 1])
         (cond [(>= i n) #f]
               [(= (bytes-ref bs i) 34) (let ([e (string-end (add1 i))]) (and e (loop (add1 e) depth)))]
               [(memv (bytes-ref bs i) '(123 91)) (loop (add1 i) (add1 depth))]
               [(memv (bytes-ref bs i) '(125 93)) (if (= depth 1) (add1 i) (loop (add1 i) (sub1 depth)))]
               [else (loop (add1 i) depth)]))]
      [else (let loop ([i i])
              (if (or (>= i n) (memv (bytes-ref bs i) '(44 125 93 32 9 10 13))) i (loop (add1 i))))]))
  (define start (ws 0))
  (and (< start n) (= (bytes-ref bs start) 123)
       (let loop ([i (ws (add1 start))] [url #f] [name #f] [id #f])
         (cond
           [(>= i n) #f]
           [(= (bytes-ref bs i) 125) (list url name id)]
           [(= (bytes-ref bs i) 34)
            (define ke (string-end (add1 i)))
            (define key (and ke (decode (add1 i) ke)))
            (define c (and ke (ws (add1 ke))))
            (cond
              [(not (and key c (< c n) (= (bytes-ref bs c) 58))) #f]
              [else
               (define v (ws (add1 c)))
               (define after (skip-value v))
               (define str (and after (< v n) (= (bytes-ref bs v) 34) (decode (add1 v) (sub1 after))))
               (define nxt (and after (ws after)))
               (define-values (url* name* id*)
                 (case key
                   [("url") (values str name id)]           ; the last occurrence wins, as in a parse
                   [("name") (values url str id)]
                   [("id") (values url name str)]
                   [else (values url name id)]))
               (cond [(not nxt) #f]
                     [(and (< nxt n) (= (bytes-ref bs nxt) 44)) (loop (ws (add1 nxt)) url* name* id*)]
                     [(and (< nxt n) (= (bytes-ref bs nxt) 125)) (list url* name* id*)]
                     [else #f])])]
           [else #f]))))


(module+ test
  (require rackunit file/tar racket/list)
  ;; the skim: the top level only — a nested url (an extension's) or name (a contact's) is not the resource's
  (define (skim s) (skim-keys (string->bytes/utf-8 s)))
  (check-equal? (skim "{\"resourceType\":\"StructureDefinition\",\"extension\":[{\"url\":\"http://x/e\"}],\"url\":\"http://x/sd\",\"contact\":[{\"name\":\"c\"}],\"name\":\"N\",\"id\":\"i\"}")
                '("http://x/sd" "N" "i"))
  ;; absent keys, non-string values, escapes, whitespace, numbers and literals skipped
  (check-equal? (skim " { \"id\" : \"a\\\"b\" , \"n\": 1.5e3, \"b\": true, \"o\": {\"url\": \"no\"}, \"name\": 3 } ")
                '(#f #f "a\"b"))
  ;; as in a parse, a repeated key's last value wins
  (check-equal? (skim "{\"url\":\"a\",\"url\":\"b\"}") '("b" #f #f))
  ;; brackets inside strings do not count
  (check-equal? (skim "{\"d\":\"}]{[\",\"id\":\"x\"}") '(#f #f "x"))
  ;; not an object, or truncated: #f (the file is then parsed in full)
  (check-false (skim "[1,2]"))
  (check-false (skim "{\"id\":\"x\""))

  ;; a package of five files, two of them not kept, one no JSON object, one the skim does not follow
  (define dir (make-temporary-file "package-store-~a" 'directory))
  (define (file! name text) (make-parent-directory* (build-path dir name)) (display-to-file text (build-path dir name)))
  (file! "package/package.json" "{\"name\":\"x\"}")
  (file! "package/StructureDefinition-a.json" "{\"resourceType\":\"StructureDefinition\",\"url\":\"http://x/a\",\"name\":\"A\",\"id\":\"a\"}")
  (file! "package/ValueSet-v.json" "{\"resourceType\":\"ValueSet\",\"id\":\"v\",\"url\":\"http://x/v\"}")
  (file! "package/CodeSystem-broken.json" "[1, 2]")
  (file! "package/Patient-p.json" "{\"resourceType\":\"Patient\",\"id\":\"p\"}")
  (file! "package/example/ValueSet-e.json" "{\"resourceType\":\"ValueSet\",\"id\":\"e\"}")
  (define tgz (build-path dir "x.tgz"))
  (parameterize ([current-directory dir]) (tar-gzip tgz "package"))
  (define cache (build-path dir "cache"))
  (define (facts es) (sort (for/list ([e (in-list es)]) (list (package-entry-kind e) (package-entry-url e) (package-entry-name e) (package-entry-id e) (entry-bytes e)))
                           string<? #:key car))
  (define expected
    (list (list "CodeSystem" #f #f #f #"[1, 2]")
          (list "StructureDefinition" "http://x/a" "A" "a" #"{\"resourceType\":\"StructureDefinition\",\"url\":\"http://x/a\",\"name\":\"A\",\"id\":\"a\"}")
          (list "ValueSet" "http://x/v" #f "v" #"{\"resourceType\":\"ValueSet\",\"id\":\"v\",\"url\":\"http://x/v\"}")))
  (define (fresh thunk) (hash-clear! loaded) (thunk))          ; as a new process reads
  (define cache-before (getenv "FHIR_CACHE_DIR"))
  (define wanted-before (getenv "FHIR_PACKAGE_CACHE"))
  (define (stored) (if (directory-exists? (build-path cache "packages")) (length (directory-list (build-path cache "packages"))) 0))
  (dynamic-wind
   void
   (lambda ()
     (putenv "FHIR_CACHE_DIR" (path->string cache))
     ;; in memory when asked: nothing is written
     (putenv "FHIR_PACKAGE_CACHE" "0")
     (check-equal? (facts (fresh (lambda () (package-entries tgz)))) expected)
     (check-equal? (stored) 0)
     ;; kept: written once (an index and its data), read by the next process without the archive
     (putenv "FHIR_PACKAGE_CACHE" "1")
     (check-equal? (facts (fresh (lambda () (package-entries tgz)))) expected)
     (check-equal? (stored) 2)
     (check-eq? (package-entries tgz) (package-entries tgz))
     (define moved (build-path dir "moved.tgz"))
     (rename-file-or-directory tgz moved)
     (rename-file-or-directory moved tgz)                         ; (the same path, size and time)
     (define again (fresh (lambda () (package-entries tgz))))
     (check-equal? (facts again) expected)
     (check-equal? (stored) 2)
     ;; the data gone under a process that holds the entries: the archive answers
     (for ([f (in-list (directory-list (build-path cache "packages") #:build? #t))]) (delete-file f))
     (check-equal? (facts again) expected)
     ;; an index that does not describe its data is written again
     (check-equal? (facts (fresh (lambda () (package-entries tgz)))) expected)
     (define dat (for/first ([f (in-list (directory-list (build-path cache "packages") #:build? #t))] #:when (regexp-match? #rx"[.]dat$" (path->string f))) f))
     (call-with-output-file dat #:exists 'truncate (lambda (o) (write-bytes #"short" o)))
     (check-equal? (facts (fresh (lambda () (package-entries tgz)))) expected)
     ;; a cache directory that cannot be made (its place is a file): in memory, as before
     (putenv "FHIR_CACHE_DIR" (path->string (build-path dir "package" "package.json")))
     (check-equal? (facts (fresh (lambda () (package-entries tgz)))) expected)
     ;; another archive at the same path is another key
     (putenv "FHIR_CACHE_DIR" (path->string cache))
     (file! "package/ValueSet-w.json" "{\"resourceType\":\"ValueSet\",\"id\":\"w\"}")
     (delete-file tgz)
     (parameterize ([current-directory dir]) (tar-gzip tgz "package"))
     (check-equal? (length (fresh (lambda () (package-entries tgz)))) 4))
   (lambda ()
     (environment-variables-set! (current-environment-variables) #"FHIR_CACHE_DIR" (and cache-before (string->bytes/utf-8 cache-before)))
     (environment-variables-set! (current-environment-variables) #"FHIR_PACKAGE_CACHE" (and wanted-before (string->bytes/utf-8 wanted-before)))
     (hash-clear! loaded)
     (delete-directory/files dir))))
