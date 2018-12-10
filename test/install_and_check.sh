#!/bin/bash
set -e

# like using curl
bash <(cat ./install.sh)

# clean before test
rm -rf ./test/project_test/.wrappers

# validate if direnv is loading container-env
direnv allow ./test/project_test
direnv exec ./test/project_test test-ok

# clean after test
rm -rf ./test/project_test/.wrappers