#!/bin/bash
# install.sh
#
# Fetch container-env from repository and install its dependencies.
set -e

REPOSITORY=https://github.com/snbuback/container-env
BRANCH=master
INSTALL_PATH=${HOME}/.container-env
SUDO=$(command -v sudo || true)

log() {
    echo "log: $*"
}

os_detector() {
    case $(uname -s) in
    Linux)
        command -v yum > /dev/null && { echo redhat; return; }
        command -v apt-get > /dev/null && { echo debian; return; }
        ;;
    Darwin)
        command -v brew > /dev/null && { echo macosx_brew; return; }
        command -v ports > /dev/null && { echo macosx_ports; return; }
        ;;
    *)
        echo "Unsupported OS"
        exit 1
    ;;
    esac
}

install_package() {
    local pkg="$1"
    case $(os_detector) in
    redhat)
        ${SUDO} yum install -q -y "${pkg}" || exit 2
        ;;
    debian)
        ${SUDO} apt-get -qq update && ${SUDO} apt-get install -qq -y "${pkg}" || exit 2
        ;;
    macosx_brew)
        brew install "${pkg}" || exit 2
        ;;
    macosx_ports)
        ports install "${pkg}" || exit 2
        ;;
    esac
}

ensure_command() {
    local cmd=$1
    local package=$2
    if ! command -v "${cmd}" > /dev/null; then
        log "Installing ${package}"
        install_package "${package}"
    fi
}

download_repo() {
    if [ -e "${INSTALL_PATH}" ]; then
        log "Path ${INSTALL_PATH} already exist. This installation will erase it before proceed. Type 'Y' to proceed."
        read -r
        if [ "$REPLY" != "Y" ]; then
            echo "Aborted."
            exit 1
        fi
        log "DEBUG" "Erasing ${INSTALL_PATH}"
        rm -rf "${INSTALL_PATH}"
    fi
    git clone -q -b "${BRANCH}" "${REPOSITORY}" "${INSTALL_PATH}"
}

local_install() {
    cd "${INSTALL_PATH}"
    ./install-container-env.sh
}

ensure_command git git
ensure_command direnv direnv
download_repo
local_install
echo "Container-env installed successfully."
