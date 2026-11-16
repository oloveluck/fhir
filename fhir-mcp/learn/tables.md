# A relational schema over FHIR data

You are given a relational schema — tables and columns someone computes against — and the data is
FHIR. Define the schema's tables over the data, in the workspace, and queries written for that
schema run as they stand. Two kinds of file do it:

- `<name>.view.json` — a SQL on FHIR ViewDefinition: ONE resource type flattened into rows
  (`raco fhir guide sql-on-fhir`). Keep the resource's keys in it: `getResourceKey()` for its own
  id, `getReferenceKey(Patient)` for a reference.
- `<name>.sql` — the table `<name>`: one `SELECT` over the views (and over other such tables). A
  join on the keys, the columns named and typed as the schema has them.

Both are tables to `query language=sql`, by the file's name.

## Official references
- SQL on FHIR (the ViewDefinition): https://build.fhir.org/ig/FHIR/sql-on-fhir-v2/
- The SQL that `query language=sql` runs is SQLite's: https://www.sqlite.org/lang_select.html

## Steps

1. **Find each table's source.** `describe ref=data` lists the resource types; `describe
   ref=data/<Type>` gives a type's profiles (`_profile`: one type often holds several of the
   schema's tables), its codes, what its references point at and the elements it carries.
   `describe ref=<Type>/<id> as=fsh` shows one resource whole.
2. **A view per source**, with a `where` on what tells that kind apart (a profile, an identifier's
   system). Name it apart from the schema's table (`fhir_admissions`) when the table needs a join.
3. **The table as SQL**: join the views on their keys, name the columns as the schema does, cast
   what the schema holds as a number (`CAST(x AS INTEGER)`).
4. **Check it**: `SELECT count(*)` against what `describe ref=data/<Type>` counts for that profile;
   then a question whose answer you know, asked as the schema's own query.

## What goes where

A view's rows are computed once and kept until the data or the view's text changes: seconds for a
few thousand resources, minutes for several hundred thousand. A `.sql` table is only a statement:
changing it costs nothing. So put renames, casts, joins and filters in the `.sql` file, and change
a large view only when it lacks a column.

## A worked example

The schema: `admissions(subject_id, hadm_id, admittime, dischtime)` — the patient's number, the
admission's number, when it began and ended, times as `YYYY-MM-DD HH:MM:SS`. In the FHIR data the
patient's number is the Patient's identifier and an admission is an Encounter.

```json
{"resourceType": "ViewDefinition", "name": "fhir_patients", "status": "active", "resource": "Patient",
 "select": [{"column": [
   {"name": "id", "path": "getResourceKey()"},
   {"name": "subject_id", "path": "identifier.value.first()"},
   {"name": "gender", "path": "gender"}]}]}
```

```json
{"resourceType": "ViewDefinition", "name": "fhir_admissions", "status": "active", "resource": "Encounter",
 "select": [{"column": [
   {"name": "id", "path": "getResourceKey()"},
   {"name": "patient_id", "path": "subject.getReferenceKey(Patient)"},
   {"name": "hadm_id", "path": "identifier.value.first()"},
   {"name": "admittime", "path": "period.start.toString().substring(0,19).replace('T',' ')"},
   {"name": "dischtime", "path": "period.end.toString().substring(0,19).replace('T',' ')"}]}]}
```

```sql
-- admissions
SELECT CAST(p.subject_id AS INTEGER) AS subject_id, CAST(a.hadm_id AS INTEGER) AS hadm_id,
       a.admittime, a.dischtime
FROM fhir_admissions a JOIN fhir_patients p ON p.id = a.patient_id
```

Saved as `fhir_patients.view.json`, `fhir_admissions.view.json` and `admissions.sql`, a query
written for the schema runs unchanged:

```
query language=sql text="SELECT admissions.hadm_id FROM admissions WHERE admissions.subject_id = 1001 AND admissions.dischtime IS NOT NULL"
```

## Things that go wrong

- **A column that lives on another resource** (the patient's number on an admission, a drug's name
  on a prescription that references a Medication): a view cannot follow a reference. Keep the
  reference's key in the view and join in the `.sql` table.
- **Times.** A FHIR time carries a zone (`2125-03-01T23:50:00-05:00`); a relational table usually
  holds the clock time as text. `x.toString().substring(0,19).replace('T',' ')` is the time as the
  record wrote it. SQLite's own date functions read a zoned text as UTC and would move that
  evening to the next day.
- **One row per repeated element** (a stay's transfers, an Encounter's `location` entries): a
  `forEach` in the view.
- **A choice element**: `value.ofType(Quantity).value`, `effective.ofType(dateTime)`.
- **A column absent from a table**: `no such column: admissions.kind (admissions: subject_id, …)`
  lists the columns the table has. A column a `.sql` table's own views lack is said when the
  table is used.
- **A name defined twice**: a view and a `.sql` file of one name are refused. Name the view apart.
