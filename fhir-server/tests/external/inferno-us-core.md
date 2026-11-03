# Inferno US Core results for `raco fhir-server serve-ig`

The external check of servers generated from an Implementation Guide (plan Part D1). Run with
`tests/external/run-inferno.sh`; record each run here, newest first.

| field | value |
|---|---|
| test kit | inferno-framework/us-core-test-kit `v1.2.0` (tests US Core ≤ 8.0.0) |
| server | `raco fhir-server serve-ig hl7.fhir.us.core-8.0.0.tgz --bearer <token>`, examples loaded |
| scope | group 4 "US Core FHIR API" with a static bearer token (SMART launch groups are out of scope: no SMART) |
| patient ids | child-example, deceased-example, example, infant-example |

## Runs

_No run yet — needs Docker access for this user (`sudo usermod -aG docker $USER`)._

For each run: date, fhir-server commit, per-test-group pass / fail / skip / omit counts, and every
failure mapped to a cause (a gap in the server, missing example data, or a test-kit expectation).
