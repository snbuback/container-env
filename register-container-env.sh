#!/bin/bash
# register-container-env.sh
# 
# This script manages the local install.
#
set -e

CONTAINERENV_DIR=$( cd "$(dirname "$0")" ; pwd -P )
# same logic as direnv: https://github.com/direnv/direnv/blob/master/xdg.go
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"${HOME}/.config"}
DIRENV_DIR=${XDG_CONFIG_HOME}/direnv
DIRENV_RC=${DIRENV_DIR}/direnvrc

mkdir -p "${DIRENV_DIR}"
if ! (grep 'container-env' "${DIRENV_RC}" &> /dev/null); then
    echo "Adding container-env to ${DIRENV_RC}"
    cat >> "${DIRENV_RC}" <<EOF

# Automatically added by container-env
for SCRIPT in ${CONTAINERENV_DIR}/src/*; do
    source \${SCRIPT}
done
EOF

    echo "Container-env Installed. Don't forget to load DirEnv in your shell environment."
else
    echo "Already installed."
fi
