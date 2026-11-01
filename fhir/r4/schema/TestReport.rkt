#lang racket/base
;;; GENERATED from hl7.fhir.r4.core#4.0.1 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'TestReport (fhir-spec 'TestReport "https://hl7.org/fhir/R4/testreport.html#TestReport" 'type)
  #:schema (type-schema 'TestReport #f 'DomainResource "https://hl7.org/fhir/R4/testreport.html#TestReport"
             (list
    (schema-field 'identifier 0 1 (vector 'type 'Identifier) #f "https://hl7.org/fhir/R4/testreport.html#TestReport.identifier" #f)
    (schema-field 'name 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/testreport.html#TestReport.name" #f)
    (schema-field 'status 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/testreport.html#TestReport.status" #f)
    (schema-field 'testScript 1 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R4/testreport.html#TestReport.testScript" #f)
    (schema-field 'result 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/testreport.html#TestReport.result" #f)
    (schema-field 'score 0 1 (vector 'prim "decimal") #f "https://hl7.org/fhir/R4/testreport.html#TestReport.score" #f)
    (schema-field 'tester 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/testreport.html#TestReport.tester" #f)
    (schema-field 'issued 0 1 (vector 'prim "dateTime") #f "https://hl7.org/fhir/R4/testreport.html#TestReport.issued" #f)
    (schema-field 'participant 0 '* (vector 'type 'TestReportParticipant) #f "https://hl7.org/fhir/R4/testreport.html#TestReport.participant" #f)
    (schema-field 'setup 0 1 (vector 'type 'TestReportSetup) #f "https://hl7.org/fhir/R4/testreport.html#TestReport.setup" #f)
    (schema-field 'test 0 '* (vector 'type 'TestReportTest) #f "https://hl7.org/fhir/R4/testreport.html#TestReport.test" #f)
    (schema-field 'teardown 0 1 (vector 'type 'TestReportTeardown) #f "https://hl7.org/fhir/R4/testreport.html#TestReport.teardown" #f)
             ) #f #f))
(register-element! "TestReport.identifier" (fhir-spec (string->symbol "TestReport.identifier") "https://hl7.org/fhir/R4/testreport.html#TestReport.identifier" 'element))
(register-element! "TestReport.name" (fhir-spec (string->symbol "TestReport.name") "https://hl7.org/fhir/R4/testreport.html#TestReport.name" 'element))
(register-element! "TestReport.status" (fhir-spec (string->symbol "TestReport.status") "https://hl7.org/fhir/R4/testreport.html#TestReport.status" 'element))
(register-element! "TestReport.testScript" (fhir-spec (string->symbol "TestReport.testScript") "https://hl7.org/fhir/R4/testreport.html#TestReport.testScript" 'element))
(register-element! "TestReport.result" (fhir-spec (string->symbol "TestReport.result") "https://hl7.org/fhir/R4/testreport.html#TestReport.result" 'element))
(register-element! "TestReport.score" (fhir-spec (string->symbol "TestReport.score") "https://hl7.org/fhir/R4/testreport.html#TestReport.score" 'element))
(register-element! "TestReport.tester" (fhir-spec (string->symbol "TestReport.tester") "https://hl7.org/fhir/R4/testreport.html#TestReport.tester" 'element))
(register-element! "TestReport.issued" (fhir-spec (string->symbol "TestReport.issued") "https://hl7.org/fhir/R4/testreport.html#TestReport.issued" 'element))
(register-element! "TestReport.participant" (fhir-spec (string->symbol "TestReport.participant") "https://hl7.org/fhir/R4/testreport.html#TestReport.participant" 'element))
(register-element! "TestReport.setup" (fhir-spec (string->symbol "TestReport.setup") "https://hl7.org/fhir/R4/testreport.html#TestReport.setup" 'element))
(register-element! "TestReport.test" (fhir-spec (string->symbol "TestReport.test") "https://hl7.org/fhir/R4/testreport.html#TestReport.test" 'element))
(register-element! "TestReport.teardown" (fhir-spec (string->symbol "TestReport.teardown") "https://hl7.org/fhir/R4/testreport.html#TestReport.teardown" 'element))

(register-type! 'TestReportParticipant (fhir-spec 'TestReportParticipant "https://hl7.org/fhir/R4/testreport.html#TestReport.participant" 'type)
  #:schema (type-schema 'TestReportParticipant #f 'BackboneElement "https://hl7.org/fhir/R4/testreport.html#TestReport.participant"
             (list
    (schema-field 'type 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/testreport.html#TestReport.participant.type" #f)
    (schema-field 'uri 1 1 (vector 'prim "uri") #f "https://hl7.org/fhir/R4/testreport.html#TestReport.participant.uri" #f)
    (schema-field 'display 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/testreport.html#TestReport.participant.display" #f)
             ) #f #f))
(register-element! "TestReport.participant.type" (fhir-spec (string->symbol "TestReport.participant.type") "https://hl7.org/fhir/R4/testreport.html#TestReport.participant.type" 'element))
(register-element! "TestReport.participant.uri" (fhir-spec (string->symbol "TestReport.participant.uri") "https://hl7.org/fhir/R4/testreport.html#TestReport.participant.uri" 'element))
(register-element! "TestReport.participant.display" (fhir-spec (string->symbol "TestReport.participant.display") "https://hl7.org/fhir/R4/testreport.html#TestReport.participant.display" 'element))

(register-type! 'TestReportSetup (fhir-spec 'TestReportSetup "https://hl7.org/fhir/R4/testreport.html#TestReport.setup" 'type)
  #:schema (type-schema 'TestReportSetup #f 'BackboneElement "https://hl7.org/fhir/R4/testreport.html#TestReport.setup"
             (list
    (schema-field 'action 1 '* (vector 'type 'TestReportSetupAction) #f "https://hl7.org/fhir/R4/testreport.html#TestReport.setup.action" #f)
             ) #f #f))
(register-element! "TestReport.setup.action" (fhir-spec (string->symbol "TestReport.setup.action") "https://hl7.org/fhir/R4/testreport.html#TestReport.setup.action" 'element))

(register-type! 'TestReportSetupAction (fhir-spec 'TestReportSetupAction "https://hl7.org/fhir/R4/testreport.html#TestReport.setup.action" 'type)
  #:schema (type-schema 'TestReportSetupAction #f 'BackboneElement "https://hl7.org/fhir/R4/testreport.html#TestReport.setup.action"
             (list
    (schema-field 'operation 0 1 (vector 'type 'TestReportSetupActionOperation) #f "https://hl7.org/fhir/R4/testreport.html#TestReport.setup.action.operation" #f)
    (schema-field 'assert 0 1 (vector 'type 'TestReportSetupActionAssert) #f "https://hl7.org/fhir/R4/testreport.html#TestReport.setup.action.assert" #f)
             ) #f #f))
(register-element! "TestReport.setup.action.operation" (fhir-spec (string->symbol "TestReport.setup.action.operation") "https://hl7.org/fhir/R4/testreport.html#TestReport.setup.action.operation" 'element))
(register-element! "TestReport.setup.action.assert" (fhir-spec (string->symbol "TestReport.setup.action.assert") "https://hl7.org/fhir/R4/testreport.html#TestReport.setup.action.assert" 'element))

(register-type! 'TestReportSetupActionOperation (fhir-spec 'TestReportSetupActionOperation "https://hl7.org/fhir/R4/testreport.html#TestReport.setup.action.operation" 'type)
  #:schema (type-schema 'TestReportSetupActionOperation #f 'BackboneElement "https://hl7.org/fhir/R4/testreport.html#TestReport.setup.action.operation"
             (list
    (schema-field 'result 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/testreport.html#TestReport.setup.action.operation.result" #f)
    (schema-field 'message 0 1 (vector 'prim "markdown") #f "https://hl7.org/fhir/R4/testreport.html#TestReport.setup.action.operation.message" #f)
    (schema-field 'detail 0 1 (vector 'prim "uri") #f "https://hl7.org/fhir/R4/testreport.html#TestReport.setup.action.operation.detail" #f)
             ) #f #f))
(register-element! "TestReport.setup.action.operation.result" (fhir-spec (string->symbol "TestReport.setup.action.operation.result") "https://hl7.org/fhir/R4/testreport.html#TestReport.setup.action.operation.result" 'element))
(register-element! "TestReport.setup.action.operation.message" (fhir-spec (string->symbol "TestReport.setup.action.operation.message") "https://hl7.org/fhir/R4/testreport.html#TestReport.setup.action.operation.message" 'element))
(register-element! "TestReport.setup.action.operation.detail" (fhir-spec (string->symbol "TestReport.setup.action.operation.detail") "https://hl7.org/fhir/R4/testreport.html#TestReport.setup.action.operation.detail" 'element))

(register-type! 'TestReportSetupActionAssert (fhir-spec 'TestReportSetupActionAssert "https://hl7.org/fhir/R4/testreport.html#TestReport.setup.action.assert" 'type)
  #:schema (type-schema 'TestReportSetupActionAssert #f 'BackboneElement "https://hl7.org/fhir/R4/testreport.html#TestReport.setup.action.assert"
             (list
    (schema-field 'result 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R4/testreport.html#TestReport.setup.action.assert.result" #f)
    (schema-field 'message 0 1 (vector 'prim "markdown") #f "https://hl7.org/fhir/R4/testreport.html#TestReport.setup.action.assert.message" #f)
    (schema-field 'detail 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/testreport.html#TestReport.setup.action.assert.detail" #f)
             ) #f #f))
(register-element! "TestReport.setup.action.assert.result" (fhir-spec (string->symbol "TestReport.setup.action.assert.result") "https://hl7.org/fhir/R4/testreport.html#TestReport.setup.action.assert.result" 'element))
(register-element! "TestReport.setup.action.assert.message" (fhir-spec (string->symbol "TestReport.setup.action.assert.message") "https://hl7.org/fhir/R4/testreport.html#TestReport.setup.action.assert.message" 'element))
(register-element! "TestReport.setup.action.assert.detail" (fhir-spec (string->symbol "TestReport.setup.action.assert.detail") "https://hl7.org/fhir/R4/testreport.html#TestReport.setup.action.assert.detail" 'element))

(register-type! 'TestReportTest (fhir-spec 'TestReportTest "https://hl7.org/fhir/R4/testreport.html#TestReport.test" 'type)
  #:schema (type-schema 'TestReportTest #f 'BackboneElement "https://hl7.org/fhir/R4/testreport.html#TestReport.test"
             (list
    (schema-field 'name 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/testreport.html#TestReport.test.name" #f)
    (schema-field 'description 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R4/testreport.html#TestReport.test.description" #f)
    (schema-field 'action 1 '* (vector 'type 'TestReportTestAction) #f "https://hl7.org/fhir/R4/testreport.html#TestReport.test.action" #f)
             ) #f #f))
(register-element! "TestReport.test.name" (fhir-spec (string->symbol "TestReport.test.name") "https://hl7.org/fhir/R4/testreport.html#TestReport.test.name" 'element))
(register-element! "TestReport.test.description" (fhir-spec (string->symbol "TestReport.test.description") "https://hl7.org/fhir/R4/testreport.html#TestReport.test.description" 'element))
(register-element! "TestReport.test.action" (fhir-spec (string->symbol "TestReport.test.action") "https://hl7.org/fhir/R4/testreport.html#TestReport.test.action" 'element))

(register-type! 'TestReportTestAction (fhir-spec 'TestReportTestAction "https://hl7.org/fhir/R4/testreport.html#TestReport.test.action" 'type)
  #:schema (type-schema 'TestReportTestAction #f 'BackboneElement "https://hl7.org/fhir/R4/testreport.html#TestReport.test.action"
             (list
    (schema-field 'operation 0 1 (vector 'type 'TestReportSetupActionOperation) #f "https://hl7.org/fhir/R4/testreport.html#TestReport.test.action.operation" #f)
    (schema-field 'assert 0 1 (vector 'type 'TestReportSetupActionAssert) #f "https://hl7.org/fhir/R4/testreport.html#TestReport.test.action.assert" #f)
             ) #f #f))
(register-element! "TestReport.test.action.operation" (fhir-spec (string->symbol "TestReport.test.action.operation") "https://hl7.org/fhir/R4/testreport.html#TestReport.test.action.operation" 'element))
(register-element! "TestReport.test.action.assert" (fhir-spec (string->symbol "TestReport.test.action.assert") "https://hl7.org/fhir/R4/testreport.html#TestReport.test.action.assert" 'element))

(register-type! 'TestReportTeardown (fhir-spec 'TestReportTeardown "https://hl7.org/fhir/R4/testreport.html#TestReport.teardown" 'type)
  #:schema (type-schema 'TestReportTeardown #f 'BackboneElement "https://hl7.org/fhir/R4/testreport.html#TestReport.teardown"
             (list
    (schema-field 'action 1 '* (vector 'type 'TestReportTeardownAction) #f "https://hl7.org/fhir/R4/testreport.html#TestReport.teardown.action" #f)
             ) #f #f))
(register-element! "TestReport.teardown.action" (fhir-spec (string->symbol "TestReport.teardown.action") "https://hl7.org/fhir/R4/testreport.html#TestReport.teardown.action" 'element))

(register-type! 'TestReportTeardownAction (fhir-spec 'TestReportTeardownAction "https://hl7.org/fhir/R4/testreport.html#TestReport.teardown.action" 'type)
  #:schema (type-schema 'TestReportTeardownAction #f 'BackboneElement "https://hl7.org/fhir/R4/testreport.html#TestReport.teardown.action"
             (list
    (schema-field 'operation 1 1 (vector 'type 'TestReportSetupActionOperation) #f "https://hl7.org/fhir/R4/testreport.html#TestReport.teardown.action.operation" #f)
             ) #f #f))
(register-element! "TestReport.teardown.action.operation" (fhir-spec (string->symbol "TestReport.teardown.action.operation") "https://hl7.org/fhir/R4/testreport.html#TestReport.teardown.action.operation" 'element))

