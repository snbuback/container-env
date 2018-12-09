#!/bin/bash
set -e

# like using curl
bash <(cat ./install.sh)

# validate if direnv is loading container-env
direnv allow ./test/project_test 
direnv exec ./test/project_test test-ok
