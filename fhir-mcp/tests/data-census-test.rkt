#lang racket/base

;;; data-census-test.rkt — data an agent has not seen, read in the calls that answer it.
;;;
;;; Given agents a FHIR dataset (MIMIC-IV on FHIR) and twenty questions, the pilot found most of
;;; their effort went into learning the data's shape: a search answered ids alone, ten at a time,
;;; its `total` the page's length; nothing said which codes the data uses or what they are called;
;;; and a medication's name sat in an identifier. Held here, over a store of a few resources:
;;; - `describe ref=data` and `data/<Type>`: the types; a type's codes with what they are called,
;;;   its references, its dates, the elements its resources carry;
;;; - `query language=find`: where words occur (a code's display, an identifier), with the search
;;;   for each — and that search finds them;
;;; - a search answers a page of rows that say what each resource holds, `total` every match,
;;;   `next` the page after; `_summary=count` the total alone; `code:text` by what a code is called;
;;; - `describe ref=Patient/<id> as=summary`: what is recorded about a patient, by type, and the
;;;   latest encounters;
;;; - SQL over the search indexes (`refs`), and learn://search's own block.

(require rackunit racket/file racket/string racket/list json
         fhir/mcp/workspace fhir/mcp/verbs fhir/mcp/init
         (only-in fhir/mcp/tools tool-name tool-run)
         (only-in fhir/mcp/resources learn-text guide-block-text))

(define dir (make-temporary-directory "census-~a"))
(void (init-workspace! dir))
(define h (open-hub dir))
(define tools (for/hash ([t (in-list (workspace-tools h))]) (values (tool-name t) t)))
(define (call name args #:ok? [ok? #t])
  (define-values (text err?) ((tool-run (hash-ref tools name)) args))
  (when ok? (check-false err? (format "~a: ~a" name text)))
  (with-handlers ([exn:fail? (lambda (_) text)]) (string->jsexpr text)))

;; two patients, two stays, six haemoglobins and a glucose, a medication named by its identifier
(define fsh
  (string-append
   "Instance: ann\nInstanceOf: Patient\n* name.given = \"Ann\"\n* name.family = \"Ng\"\n* gender = #female\n\n"
   "Instance: bob\nInstanceOf: Patient\n* name.given = \"Bob\"\n* name.family = \"Lee\"\n\n"
   "Instance: stay1\nInstanceOf: Encounter\n* status = #finished\n* class = http://terminology.hl7.org/CodeSystem/v3-ActCode#IMP\n"
   "* subject = Reference(Patient/ann)\n* period.start = \"2125-01-01T10:00:00Z\"\n* period.end = \"2125-01-04T10:00:00Z\"\n\n"
   "Instance: stay2\nInstanceOf: Encounter\n* status = #finished\n* class = http://terminology.hl7.org/CodeSystem/v3-ActCode#EMER\n"
   "* subject = Reference(Patient/ann)\n* period.start = \"2125-03-01T10:00:00Z\"\n\n"
   (apply string-append
          (for/list ([i (in-range 6)])
            (format (string-append "Instance: hb~a\nInstanceOf: Observation\n* status = #final\n"
                                   "* code = http://loinc.org#718-7 \"Hemoglobin [Mass/volume] in Blood\"\n"
                                   "* subject = Reference(Patient/~a)\n* encounter = Reference(Encounter/stay1)\n"
                                   "* effectiveDateTime = \"2125-01-0~aT08:00:00Z\"\n* valueQuantity = ~a 'g/dL'\n\n")
                    i (if (< i 4) "ann" "bob") (add1 i) (+ 10 i))))
   "Instance: glu1\nInstanceOf: Observation\n* status = #final\n* code = http://loinc.org#2339-0 \"Glucose [Mass/volume] in Blood\"\n"
   "* subject = Reference(Patient/bob)\n* effectiveDateTime = \"2125-02-01\"\n* valueQuantity = 99 'mg/dL'\n\n"
   "Instance: med1\nInstanceOf: Medication\n* identifier.system = \"http://example.org/medication-name\"\n"
   "* identifier.value = \"Miconazole 2% Cream\"\n"))

(with-hub h
  (lambda ()
    (define st (call "stage" (hasheq 'fsh fsh)))
    (call "commit" (hasheq 'stage (hash-ref st 'stage) 'reason "census test"))

    ;; ---- the data as a whole, and one type --------------------------------------------------
    (define data (call "describe" (hasheq 'ref "data")))
    (check-equal? (hash-ref (hash-ref data 'types) 'Observation) 7)
    (check-equal? (hash-ref (hash-ref data 'types) 'Patient) 2)
    (check-regexp-match #rx"data/<Type>" (hash-ref data 'next))
    (define obs (call "describe" (hasheq 'ref "data/Observation")))
    (check-equal? (hash-ref obs 'count) 7)
    ;; the codes, commonest first, with what they are called; the system once
    (define code (hash-ref (hash-ref obs 'search) (string->symbol "code, combo-code")))
    (check-equal? (hash-ref code 'system) "http://loinc.org")
    (check-equal? (hash-ref code 'top) '("718-7 \"Hemoglobin [Mass/volume] in Blood\" ×6" "2339-0 \"Glucose [Mass/volume] in Blood\" ×1"))
    (check-equal? (hash-ref (hash-ref obs 'elements) 'always) '("code" "effectiveDateTime" "status" "subject" "valueQuantity"))
    (check-equal? (hash-ref (hash-ref obs 'elements) 'sometimes) '("encounter 86%"))
    ;; a type the data does not hold
    (check-regexp-match #rx"holds no Conditon [(]did you mean `Encounter`[?][)]|holds no Conditon"
                        (jsexpr->string (call "describe" (hasheq 'ref "data/Conditon") #:ok? #f)))

    ;; ---- where words occur, and the search for each ------------------------------------------
    (define found (hash-ref (call "query" (hasheq 'language "find" 'text "hemoglobin")) 'rows))
    (check-equal? (length found) 1)
    (check-equal? (hash-ref (car found) 'text) "Hemoglobin [Mass/volume] in Blood")
    (check-equal? (hash-ref (car found) 'resources) 6)
    (define (total-of search) (hash-ref (call "query" (hasheq 'language "search" 'text search)) 'total))
    (check-equal? (total-of (hash-ref (car found) 'search)) 6 "find's search finds what it counted")
    ;; a name kept in an identifier
    (define med (hash-ref (call "query" (hasheq 'language "find" 'text "miconazole cream")) 'rows))
    (check-equal? (map (lambda (r) (hash-ref r 'where)) med) '("Medication.identifier"))
    (check-equal? (total-of (hash-ref (car med) 'search)) 1)
    (check-equal? (hash-ref (call "query" (hasheq 'language "find" 'text "aspirin")) 'total) 0)

    ;; ---- a search: a page of rows that read, the total, the next page ------------------------
    (define page (call "query" (hasheq 'language "search" 'text "Observation?code:text=hemoglobin&_sort=date&_count=2")))
    (check-equal? (hash-ref page 'total) 6)
    (check-equal? (hash-ref page 'columns) '("resource" "code" "value" "effective" "status" "subject" "encounter"))
    (check-equal? (car (hash-ref page 'rows))
                  (hasheq 'resource "Observation/hb0" 'code "Hemoglobin [Mass/volume] in Blood" 'value "10 g/dL"
                          'effective "2125-01-01T08:00:00Z" 'status "final" 'subject "Patient/ann" 'encounter "Encounter/stay1"))
    (check-regexp-match #rx"_offset=2" (hash-ref page 'next))
    (check-equal? (map (lambda (r) (hash-ref r 'resource))
                       (hash-ref (call "query" (hasheq 'language "search" 'text "Observation?code:text=hemoglobin&_sort=date&_count=2&_offset=4")) 'rows))
                  '("Observation/hb4" "Observation/hb5"))
    (let ([n (call "query" (hasheq 'language "search" 'text "Observation?patient=Patient/ann&_summary=count"))])
      (check-equal? (list (hash-ref n 'total) (hash-ref n 'rows)) '(4 ())))
    ;; the rows as CSV are the digests, not the JSON
    (check-regexp-match #rx"^resource,code,value,effective,status,subject,encounter\nObservation/hb0,"
                        (call "query" (hasheq 'language "search" 'text "Observation?code:text=hemoglobin&_sort=date" 'as "csv")))

    ;; ---- what is recorded about one patient --------------------------------------------------
    (define ann (call "describe" (hasheq 'ref "Patient/ann" 'as "summary")))
    (check-equal? (hash-ref ann 'is) (hasheq 'name "Ann Ng" 'gender "female"))
    (check-equal? (hash-ref ann 'holds) (hasheq 'Observation 4 'Encounter 2))
    (check-equal? (hash-ref ann 'trail) (hasheq 'Provenance 1 'AuditEvent 1) "the commit's own records, apart")
    (check-equal? (hash-ref (hash-ref ann 'encounters) 'total) 2)
    (check-equal? (map (lambda (e) (list (hash-ref e 'resource) (hash-ref e 'class))) (hash-ref (hash-ref ann 'encounters) 'latest))
                  '(("Encounter/stay2" "EMER") ("Encounter/stay1" "IMP")) "newest first")

    ;; ---- SQL over the search indexes, and the guide's own block ------------------------------
    (check-equal? (hash-ref (call "query" (hasheq 'language "sql" 'text "SELECT COUNT(*) AS n FROM refs WHERE type = 'Observation' AND param = 'patient' AND target_id = 'bob'")) 'rows)
                  (list (hasheq 'n 3)))
    (define block (guide-block-text (learn-text "search") "obs-per-encounter"))
    (check-equal? (hash-ref (call "query" (hasheq 'language "sql" 'text block)) 'rows)
                  (list (hasheq 'encounter "stay1" 'observations 6)))))

(delete-directory/files dir)
