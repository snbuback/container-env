#!/bin/bash
set -e

echo "Validating syntax"
find . -name \*.sh -exec shellcheck -S style -s bash -a {} +

echo "Running tests"
./test-libs/bats ./test
