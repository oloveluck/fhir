#lang s-exp syntax/module-reader

;;; reader.rkt — #lang fhir/sd : plain s-expression reader; the module language fhir/sd/base
;;; interprets `profile` forms as definitions (unlike the resource-tower langs, an sd module is a
;;; collection of profile DEFINITIONS, not resource instances, so forms are not wrapped).

fhir/sd/base
