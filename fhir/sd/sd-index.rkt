#lang racket/base

;;; sd-index.rkt — resolve a base StructureDefinition (with its snapshot) from the R5 core package.
;;;
;;; Snapshot generation needs the parent's full snapshot; the vendored R5 core package carries one per
;;; StructureDefinition. We lazily stream the .tgz once and index every SD by url / name / id (mirrors
;;; the terminology service's loader). Consumed by sd/{snapshot,element-index}.rkt, the validator
;;; (fhir-validation) and the FSH snapshot mode; the differential-only FSH compile path does not touch this.
;;;
;;; The packages searched are `current-sd-packages` — a list, searched in order, so an IG's profiles
;;; resolve before the core package it builds on: (list us-core.tgz r4-core.tgz). The default is the
;;; R5 core package from the OPTIONAL `fhir-spec` package. Without any package the index is empty:
;;; resolve-sd-raw returns #f and snapshot generation degrades to differential-only.
;;; Consumers that cache derived data (element-index's type cache) key it by `sd-context`.

(require (only-in fhir/canonical canonical-url)
         json
         racket/promise
         file/gunzip
         file/untar
         racket/contract
         (only-in racket/list last)
         (only-in fhir/spec-package spec-package-path))

(provide (contract-out
          [resolve-sd-raw (-> string? (or/c hash? #f))]
          ;; a CodeSystem / ValueSet / StructureDefinition by url, name or id
          [resolve-canonical-raw (-> (or/c "CodeSystem" "ValueSet" "StructureDefinition" "StructureMap" "ConceptMap")
                                     string? (or/c hash? #f))]
          ;; the FHIR NPM packages (.tgz) to resolve from, in priority order; #f = fhir-spec's R5 core
          [current-sd-packages (parameter/c (or/c #f (listof path-string?)))]
          ;; the effective package list — a cache key for anything derived from the index
          [sd-context (-> (listof path?))]
          ;; can snapshots be generated at all (is a core package available)?
          [sd-index-available? (-> boolean?)]))

(define current-sd-packages (make-parameter #f))
;; sd-context : -> (listof path)   the effective packages, normalised. Asked on every lookup (and as
;; a cache key on every datatype jump), so the normal form is kept per package list (by identity)
;; when every path in it is complete — a relative one resolves against the current directory, so
;; it is normalised afresh. The default (fhir-spec's R5 core, an absolute path) is computed once.
(define contexts (make-weak-hasheq))
(define default-context #f)
(define (sd-context)
  (define pkgs (current-sd-packages))
  (cond
    [(and pkgs (andmap complete-path? pkgs)) (hash-ref! contexts pkgs (lambda () (normalise pkgs)))]
    [pkgs (normalise pkgs)]
    [else (unless default-context
            (set! default-context
                  (normalise (let ([core (spec-package-path "hl7.fhir.r5.core.tgz" #:optional? #t)]) (if core (list core) '())))))
          default-context]))
(define (normalise pkgs) (map (lambda (p) (simplify-path (path->complete-path p))) pkgs))
(define (sd-index-available?) (pair? (sd-context)))

;; indexed resource kinds: file-name prefix in a package -> table key
(define indexed-kinds '("StructureDefinition" "CodeSystem" "ValueSet" "StructureMap" "ConceptMap"))
(define file-rx #px"^package/(StructureDefinition|CodeSystem|ValueSet|StructureMap|ConceptMap)-.*\\.json$")

;; one index per package, built on first use; a lookup searches the context's packages in order.
;; A package index is kind -> (url | name | id -> resource), so a CodeSystem and a ValueSet that share
;; a name never shadow each other.
(define indexes (make-hash))
(define (package-index tgz) (hash-ref! indexes tgz (lambda () (load-index tgz))))

;; load-index : tgz -> (hash kind (mutable-hash key Entry))
;; An Entry is a promise of the resource jsexpr (or #f). Indexing needs only each resource's
;; top-level url, name and id, read by `skim-keys` from the raw bytes; the resource itself is parsed
;; the first time a lookup reaches it (a core package holds thousands; a compile touches tens).
(define (load-index tgz)
    (define tables (for/hash ([k (in-list indexed-kinds)]) (values k (make-hash))))
    (define-values (pin pout) (make-pipe (* 1024 1024)))
    (define inflate
      (thread (lambda () (call-with-input-file tgz (lambda (gz) (gunzip-through-ports gz pout)))
                     (close-output-port pout))))
    (untar pin
           #:handle-entry
           (lambda (kind name content size attribs)
             (when (eq? kind 'file)
               (define bytes (if (= size 0) #"" (read-bytes size content)))
               (define m (regexp-match file-rx (path->string name)))
               (when m
                 (define-values (keys entry) (index-entry bytes))
                 (define table (hash-ref tables (cadr m)))
                 (for ([k (in-list keys)])
                   (unless (hash-has-key? table k) (hash-set! table k entry)))))   ; first wins
             '()))
    (thread-wait inflate)
    tables)

;; index-entry : bytes -> (values (listof key) Entry)   the resource's url, name and id (the strings
;; among them) and the promise of the resource. When the skim cannot read the bytes, they are parsed
;; at once, as before (a file that is not a JSON object is no entry: no keys).
(define (index-entry bs)
  (define (parse) (let ([js (with-handlers ([exn:fail? (lambda (_) #f)]) (bytes->jsexpr bs))]) (and (hash? js) js)))
  (define skim (skim-keys bs))
  (cond
    [skim (values (filter string? skim) (delay (parse)))]
    [else (define js (parse))
          (values (if js (filter string? (list (hash-ref js 'url #f) (hash-ref js 'name #f) (hash-ref js 'id #f))) '())
                  (delay js))]))

;; entry-resource : Entry -> resource | #f
(define (entry-resource e) (and e (force e)))

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

;; resolve-canonical-raw : kind name-or-url -> resource | #f   (kind: "CodeSystem" | "ValueSet" |
;; "StructureDefinition" | "StructureMap" | "ConceptMap"; searched over the context's packages in
;; order; |version suffix ignored)
(define (resolve-canonical-raw kind name-or-url)
  (define key (canonical-url name-or-url))
  (for/or ([tgz (in-list (sd-context))])
    (entry-resource (hash-ref (hash-ref (package-index tgz) kind (hash)) key #f))))

(define (resolve-sd-raw name-or-url)
  (define key (canonical-url name-or-url))        ; drop a |version suffix
  (define tables (map (lambda (t) (hash-ref (package-index t) "StructureDefinition")) (sd-context)))
  (define (lookup k) (for/or ([t (in-list tables)]) (entry-resource (hash-ref t k #f))))
  ;; a bare type code ("Patient") means the core canonical, NOT whatever SD happens to share that
  ;; name or id (R4 core has an extension NAMED "FamilyMemberHistory")
  (or (and (not (regexp-match? #rx"/" key))
           (lookup (string-append "http://hl7.org/fhir/StructureDefinition/" key)))
      (lookup key)
      (and (regexp-match? #rx"/" key)
           (lookup (last (regexp-split #rx"/" key))))))


(module+ test
  (require rackunit)
  (define (skim s) (skim-keys (string->bytes/utf-8 s)))
  ;; the top level only: a nested url (an extension's) or name (a contact's) is not the resource's
  (check-equal? (skim "{\"resourceType\":\"StructureDefinition\",\"extension\":[{\"url\":\"http://x/e\"}],\"url\":\"http://x/sd\",\"contact\":[{\"name\":\"c\"}],\"name\":\"N\",\"id\":\"i\"}")
                '("http://x/sd" "N" "i"))
  ;; absent keys, non-string values, escapes, whitespace, numbers and literals skipped
  (check-equal? (skim " { \"id\" : \"a\\\"b\" , \"n\": 1.5e3, \"b\": true, \"o\": {\"url\": \"no\"}, \"name\": 3 } ")
                '(#f #f "a\"b"))
  ;; as in a parse, a repeated key's last value wins
  (check-equal? (skim "{\"url\":\"a\",\"url\":\"b\"}") '("b" #f #f))
  ;; brackets inside strings do not count
  (check-equal? (skim "{\"d\":\"}]{[\",\"id\":\"x\"}") '(#f #f "x"))
  ;; not an object, or truncated: #f (the caller parses in full)
  (check-false (skim "[1,2]"))
  (check-false (skim "{\"id\":\"x\""))
  ;; an index entry is the parsed resource, on demand; a non-object file has no keys
  (define-values (keys e) (index-entry #"{\"url\":\"u\",\"id\":\"i\",\"x\":[1]}"))
  (check-equal? keys '("u" "i"))
  (check-equal? (entry-resource e) (hasheq 'url "u" 'id "i" 'x '(1)))
  (define-values (keys2 e2) (index-entry #"[1]"))
  (check-equal? keys2 '())
  (check-false (entry-resource e2)))
