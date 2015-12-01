#!/bin/bash

Rscript -e "devtools::test()" > testResults.Rout

file=testResults.Rout

testFail=$(grep -ci " Error: \| Error ( \|Error: \|*Error: \| Failure: \| Failure (" $file)
if [ "$testFail" != "0" ]; then
  echo "Some unit tests failed. "
  exit 1
fi
