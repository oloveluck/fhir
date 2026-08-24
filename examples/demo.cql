#lang fhir/cql
library Demo version '1.0'

define Sum: 1 + 2 * 3
define Greeting: 'Hello, ' + 'CQL'
define InRange: 5 in Interval[1, 10]
define Classify: if Sum > 5 then 'big' else 'small'
define Evens: {2, 4, 6}
define Total: Count(Evens)
define WithNull: 'x' & null
define Ratio: 3.0 / 4
