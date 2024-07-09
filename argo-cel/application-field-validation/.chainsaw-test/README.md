## Description

This is an automated test of the sample policy in this directory.

## Expected Behavior

A policy report should be generated in which the following results are observed:

* `badapp01` fails for the rule `source-path-chart` and passes for the rule `destination-server-name`
* `badapp02` fails for the rule `destination-server-name` and passes for the rule `source-path-chart`
* `goodapp01` passes for both rules

## Reference Issue(s)

N/A
