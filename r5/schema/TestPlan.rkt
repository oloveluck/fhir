#lang racket/base
;;; GENERATED from hl7.fhir.r5.core#5.0.0 — DO NOT EDIT (verified by raco fhir check).
(require fhir/model/schema fhir/model/registry)

(register-type! 'TestPlan (fhir-spec 'TestPlan "https://hl7.org/fhir/R5/testplan.html#TestPlan" 'type)
  #:schema (type-schema 'TestPlan #f 'DomainResource "https://hl7.org/fhir/R5/testplan.html#TestPlan"
             (list
    (schema-field 'url 0 1 (vector 'prim "uri") #f "https://hl7.org/fhir/R5/testplan.html#TestPlan.url" #f)
    (schema-field 'identifier 0 '* (vector 'type 'Identifier) #f "https://hl7.org/fhir/R5/testplan.html#TestPlan.identifier" #f)
    (schema-field 'version 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/testplan.html#TestPlan.version" #f)
    (schema-field 'name 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/testplan.html#TestPlan.name" #f)
    (schema-field 'title 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/testplan.html#TestPlan.title" #f)
    (schema-field 'status 1 1 (vector 'prim "code") #f "https://hl7.org/fhir/R5/testplan.html#TestPlan.status" #f)
    (schema-field 'experimental 0 1 (vector 'prim "boolean") #f "https://hl7.org/fhir/R5/testplan.html#TestPlan.experimental" #f)
    (schema-field 'date 0 1 (vector 'prim "dateTime") #f "https://hl7.org/fhir/R5/testplan.html#TestPlan.date" #f)
    (schema-field 'publisher 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/testplan.html#TestPlan.publisher" #f)
    (schema-field 'contact 0 '* (vector 'type 'ContactDetail) #f "https://hl7.org/fhir/R5/testplan.html#TestPlan.contact" #f)
    (schema-field 'description 0 1 (vector 'prim "markdown") #f "https://hl7.org/fhir/R5/testplan.html#TestPlan.description" #f)
    (schema-field 'useContext 0 '* (vector 'type 'UsageContext) #f "https://hl7.org/fhir/R5/testplan.html#TestPlan.useContext" #f)
    (schema-field 'jurisdiction 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/testplan.html#TestPlan.jurisdiction" #f)
    (schema-field 'purpose 0 1 (vector 'prim "markdown") #f "https://hl7.org/fhir/R5/testplan.html#TestPlan.purpose" #f)
    (schema-field 'copyright 0 1 (vector 'prim "markdown") #f "https://hl7.org/fhir/R5/testplan.html#TestPlan.copyright" #f)
    (schema-field 'copyrightLabel 0 1 (vector 'prim "string") #f "https://hl7.org/fhir/R5/testplan.html#TestPlan.copyrightLabel" #f)
    (schema-field 'category 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/testplan.html#TestPlan.category" #f)
    (schema-field 'scope 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/testplan.html#TestPlan.scope" #f)
    (schema-field 'testTools 0 1 (vector 'prim "markdown") #f "https://hl7.org/fhir/R5/testplan.html#TestPlan.testTools" #f)
    (schema-field 'dependency 0 '* (vector 'type 'TestPlanDependency) #f "https://hl7.org/fhir/R5/testplan.html#TestPlan.dependency" #f)
    (schema-field 'exitCriteria 0 1 (vector 'prim "markdown") #f "https://hl7.org/fhir/R5/testplan.html#TestPlan.exitCriteria" #f)
    (schema-field 'testCase 0 '* (vector 'type 'TestPlanTestCase) #f "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase" #f)
    (schema-field 'versionAlgorithmString 0 1 (vector 'prim "string") 'versionAlgorithm "https://hl7.org/fhir/R5/testplan.html#TestPlan.versionAlgorithm[x]" #f)
    (schema-field 'versionAlgorithmCoding 0 1 (vector 'type 'Coding) 'versionAlgorithm "https://hl7.org/fhir/R5/testplan.html#TestPlan.versionAlgorithm[x]" #f)
             ) #f #f))
(register-element! "TestPlan.url" (fhir-spec (string->symbol "TestPlan.url") "https://hl7.org/fhir/R5/testplan.html#TestPlan.url" 'element))
(register-element! "TestPlan.identifier" (fhir-spec (string->symbol "TestPlan.identifier") "https://hl7.org/fhir/R5/testplan.html#TestPlan.identifier" 'element))
(register-element! "TestPlan.version" (fhir-spec (string->symbol "TestPlan.version") "https://hl7.org/fhir/R5/testplan.html#TestPlan.version" 'element))
(register-element! "TestPlan.name" (fhir-spec (string->symbol "TestPlan.name") "https://hl7.org/fhir/R5/testplan.html#TestPlan.name" 'element))
(register-element! "TestPlan.title" (fhir-spec (string->symbol "TestPlan.title") "https://hl7.org/fhir/R5/testplan.html#TestPlan.title" 'element))
(register-element! "TestPlan.status" (fhir-spec (string->symbol "TestPlan.status") "https://hl7.org/fhir/R5/testplan.html#TestPlan.status" 'element))
(register-element! "TestPlan.experimental" (fhir-spec (string->symbol "TestPlan.experimental") "https://hl7.org/fhir/R5/testplan.html#TestPlan.experimental" 'element))
(register-element! "TestPlan.date" (fhir-spec (string->symbol "TestPlan.date") "https://hl7.org/fhir/R5/testplan.html#TestPlan.date" 'element))
(register-element! "TestPlan.publisher" (fhir-spec (string->symbol "TestPlan.publisher") "https://hl7.org/fhir/R5/testplan.html#TestPlan.publisher" 'element))
(register-element! "TestPlan.contact" (fhir-spec (string->symbol "TestPlan.contact") "https://hl7.org/fhir/R5/testplan.html#TestPlan.contact" 'element))
(register-element! "TestPlan.description" (fhir-spec (string->symbol "TestPlan.description") "https://hl7.org/fhir/R5/testplan.html#TestPlan.description" 'element))
(register-element! "TestPlan.useContext" (fhir-spec (string->symbol "TestPlan.useContext") "https://hl7.org/fhir/R5/testplan.html#TestPlan.useContext" 'element))
(register-element! "TestPlan.jurisdiction" (fhir-spec (string->symbol "TestPlan.jurisdiction") "https://hl7.org/fhir/R5/testplan.html#TestPlan.jurisdiction" 'element))
(register-element! "TestPlan.purpose" (fhir-spec (string->symbol "TestPlan.purpose") "https://hl7.org/fhir/R5/testplan.html#TestPlan.purpose" 'element))
(register-element! "TestPlan.copyright" (fhir-spec (string->symbol "TestPlan.copyright") "https://hl7.org/fhir/R5/testplan.html#TestPlan.copyright" 'element))
(register-element! "TestPlan.copyrightLabel" (fhir-spec (string->symbol "TestPlan.copyrightLabel") "https://hl7.org/fhir/R5/testplan.html#TestPlan.copyrightLabel" 'element))
(register-element! "TestPlan.category" (fhir-spec (string->symbol "TestPlan.category") "https://hl7.org/fhir/R5/testplan.html#TestPlan.category" 'element))
(register-element! "TestPlan.scope" (fhir-spec (string->symbol "TestPlan.scope") "https://hl7.org/fhir/R5/testplan.html#TestPlan.scope" 'element))
(register-element! "TestPlan.testTools" (fhir-spec (string->symbol "TestPlan.testTools") "https://hl7.org/fhir/R5/testplan.html#TestPlan.testTools" 'element))
(register-element! "TestPlan.dependency" (fhir-spec (string->symbol "TestPlan.dependency") "https://hl7.org/fhir/R5/testplan.html#TestPlan.dependency" 'element))
(register-element! "TestPlan.exitCriteria" (fhir-spec (string->symbol "TestPlan.exitCriteria") "https://hl7.org/fhir/R5/testplan.html#TestPlan.exitCriteria" 'element))
(register-element! "TestPlan.testCase" (fhir-spec (string->symbol "TestPlan.testCase") "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase" 'element))
(register-element! "TestPlan.versionAlgorithm[x]" (fhir-spec (string->symbol "TestPlan.versionAlgorithm[x]") "https://hl7.org/fhir/R5/testplan.html#TestPlan.versionAlgorithm[x]" 'element))
(register-element! "TestPlan.versionAlgorithm[x]" (fhir-spec (string->symbol "TestPlan.versionAlgorithm[x]") "https://hl7.org/fhir/R5/testplan.html#TestPlan.versionAlgorithm[x]" 'element))

(register-type! 'TestPlanDependency (fhir-spec 'TestPlanDependency "https://hl7.org/fhir/R5/testplan.html#TestPlan.dependency" 'type)
  #:schema (type-schema 'TestPlanDependency #f 'BackboneElement "https://hl7.org/fhir/R5/testplan.html#TestPlan.dependency"
             (list
    (schema-field 'description 0 1 (vector 'prim "markdown") #f "https://hl7.org/fhir/R5/testplan.html#TestPlan.dependency.description" #f)
    (schema-field 'predecessor 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/testplan.html#TestPlan.dependency.predecessor" #f)
             ) #f #f))
(register-element! "TestPlan.dependency.description" (fhir-spec (string->symbol "TestPlan.dependency.description") "https://hl7.org/fhir/R5/testplan.html#TestPlan.dependency.description" 'element))
(register-element! "TestPlan.dependency.predecessor" (fhir-spec (string->symbol "TestPlan.dependency.predecessor") "https://hl7.org/fhir/R5/testplan.html#TestPlan.dependency.predecessor" 'element))

(register-type! 'TestPlanTestCase (fhir-spec 'TestPlanTestCase "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase" 'type)
  #:schema (type-schema 'TestPlanTestCase #f 'BackboneElement "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase"
             (list
    (schema-field 'sequence 0 1 (vector 'prim "integer") #f "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.sequence" #f)
    (schema-field 'scope 0 '* (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.scope" #f)
    (schema-field 'dependency 0 '* (vector 'type 'TestPlanTestCaseDependency) #f "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.dependency" #f)
    (schema-field 'testRun 0 '* (vector 'type 'TestPlanTestCaseTestRun) #f "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.testRun" #f)
    (schema-field 'testData 0 '* (vector 'type 'TestPlanTestCaseTestData) #f "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.testData" #f)
    (schema-field 'assertion 0 '* (vector 'type 'TestPlanTestCaseAssertion) #f "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.assertion" #f)
             ) #f #f))
(register-element! "TestPlan.testCase.sequence" (fhir-spec (string->symbol "TestPlan.testCase.sequence") "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.sequence" 'element))
(register-element! "TestPlan.testCase.scope" (fhir-spec (string->symbol "TestPlan.testCase.scope") "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.scope" 'element))
(register-element! "TestPlan.testCase.dependency" (fhir-spec (string->symbol "TestPlan.testCase.dependency") "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.dependency" 'element))
(register-element! "TestPlan.testCase.testRun" (fhir-spec (string->symbol "TestPlan.testCase.testRun") "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.testRun" 'element))
(register-element! "TestPlan.testCase.testData" (fhir-spec (string->symbol "TestPlan.testCase.testData") "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.testData" 'element))
(register-element! "TestPlan.testCase.assertion" (fhir-spec (string->symbol "TestPlan.testCase.assertion") "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.assertion" 'element))

(register-type! 'TestPlanTestCaseDependency (fhir-spec 'TestPlanTestCaseDependency "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.dependency" 'type)
  #:schema (type-schema 'TestPlanTestCaseDependency #f 'BackboneElement "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.dependency"
             (list
    (schema-field 'description 0 1 (vector 'prim "markdown") #f "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.dependency.description" #f)
    (schema-field 'predecessor 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.dependency.predecessor" #f)
             ) #f #f))
(register-element! "TestPlan.testCase.dependency.description" (fhir-spec (string->symbol "TestPlan.testCase.dependency.description") "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.dependency.description" 'element))
(register-element! "TestPlan.testCase.dependency.predecessor" (fhir-spec (string->symbol "TestPlan.testCase.dependency.predecessor") "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.dependency.predecessor" 'element))

(register-type! 'TestPlanTestCaseTestRun (fhir-spec 'TestPlanTestCaseTestRun "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.testRun" 'type)
  #:schema (type-schema 'TestPlanTestCaseTestRun #f 'BackboneElement "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.testRun"
             (list
    (schema-field 'narrative 0 1 (vector 'prim "markdown") #f "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.testRun.narrative" #f)
    (schema-field 'script 0 1 (vector 'type 'TestPlanTestCaseTestRunScript) #f "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.testRun.script" #f)
             ) #f #f))
(register-element! "TestPlan.testCase.testRun.narrative" (fhir-spec (string->symbol "TestPlan.testCase.testRun.narrative") "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.testRun.narrative" 'element))
(register-element! "TestPlan.testCase.testRun.script" (fhir-spec (string->symbol "TestPlan.testCase.testRun.script") "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.testRun.script" 'element))

(register-type! 'TestPlanTestCaseTestRunScript (fhir-spec 'TestPlanTestCaseTestRunScript "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.testRun.script" 'type)
  #:schema (type-schema 'TestPlanTestCaseTestRunScript #f 'BackboneElement "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.testRun.script"
             (list
    (schema-field 'language 0 1 (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.testRun.script.language" #f)
    (schema-field 'sourceString 0 1 (vector 'prim "string") 'source "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.testRun.script.source[x]" #f)
    (schema-field 'sourceReference 0 1 (vector 'type 'Reference) 'source "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.testRun.script.source[x]" #f)
             ) #f #f))
(register-element! "TestPlan.testCase.testRun.script.language" (fhir-spec (string->symbol "TestPlan.testCase.testRun.script.language") "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.testRun.script.language" 'element))
(register-element! "TestPlan.testCase.testRun.script.source[x]" (fhir-spec (string->symbol "TestPlan.testCase.testRun.script.source[x]") "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.testRun.script.source[x]" 'element))
(register-element! "TestPlan.testCase.testRun.script.source[x]" (fhir-spec (string->symbol "TestPlan.testCase.testRun.script.source[x]") "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.testRun.script.source[x]" 'element))

(register-type! 'TestPlanTestCaseTestData (fhir-spec 'TestPlanTestCaseTestData "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.testData" 'type)
  #:schema (type-schema 'TestPlanTestCaseTestData #f 'BackboneElement "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.testData"
             (list
    (schema-field 'type 1 1 (vector 'type 'Coding) #f "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.testData.type" #f)
    (schema-field 'content 0 1 (vector 'type 'Reference) #f "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.testData.content" #f)
    (schema-field 'sourceString 0 1 (vector 'prim "string") 'source "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.testData.source[x]" #f)
    (schema-field 'sourceReference 0 1 (vector 'type 'Reference) 'source "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.testData.source[x]" #f)
             ) #f #f))
(register-element! "TestPlan.testCase.testData.type" (fhir-spec (string->symbol "TestPlan.testCase.testData.type") "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.testData.type" 'element))
(register-element! "TestPlan.testCase.testData.content" (fhir-spec (string->symbol "TestPlan.testCase.testData.content") "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.testData.content" 'element))
(register-element! "TestPlan.testCase.testData.source[x]" (fhir-spec (string->symbol "TestPlan.testCase.testData.source[x]") "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.testData.source[x]" 'element))
(register-element! "TestPlan.testCase.testData.source[x]" (fhir-spec (string->symbol "TestPlan.testCase.testData.source[x]") "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.testData.source[x]" 'element))

(register-type! 'TestPlanTestCaseAssertion (fhir-spec 'TestPlanTestCaseAssertion "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.assertion" 'type)
  #:schema (type-schema 'TestPlanTestCaseAssertion #f 'BackboneElement "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.assertion"
             (list
    (schema-field 'type 0 '* (vector 'type 'CodeableConcept) #f "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.assertion.type" #f)
    (schema-field 'object 0 '* (vector 'type 'CodeableReference) #f "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.assertion.object" #f)
    (schema-field 'result 0 '* (vector 'type 'CodeableReference) #f "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.assertion.result" #f)
             ) #f #f))
(register-element! "TestPlan.testCase.assertion.type" (fhir-spec (string->symbol "TestPlan.testCase.assertion.type") "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.assertion.type" 'element))
(register-element! "TestPlan.testCase.assertion.object" (fhir-spec (string->symbol "TestPlan.testCase.assertion.object") "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.assertion.object" 'element))
(register-element! "TestPlan.testCase.assertion.result" (fhir-spec (string->symbol "TestPlan.testCase.assertion.result") "https://hl7.org/fhir/R5/testplan.html#TestPlan.testCase.assertion.result" 'element))

