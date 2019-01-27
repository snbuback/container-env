#!/bin/bash

VERSION=1.0-2018-12-12-15-30

container_layout() {
    _container_init

    # refreshing wrappers if required
    local current_checksum=$(_container_wrapper_checksum)
    
    if [[ $(cat "${WRAPPERS}"/.initialized 2>&1) != "${current_checksum}" ]]; then
        _container_refresh_wrappers
        [[ "${CONTAINER_AUTO_WRAPPER}" -eq 1 ]] && _container_auto_wrappers
        _wrapper_in_git_ignore

        echo -n "${current_checksum}" > "${WRAPPERS}/.initialized"
    fi
    PATH_add "${WRAPPERS}"
}

_container_wrapper_checksum() {
    echo "${VERSION}"
    # try to hash the .envrc. In case of changes, rewrites the .wrapper scripts
    if command -v md5 > /dev/null; then
        md5 .envrc
    elif command -v md5sum > /dev/null; then
        md5sum .envrc
    elif command -v shasum > /dev/null; then
        shasum .envrc
    fi
}

# setup default values
_container_init() {

    : "${CONTAINER_PROJECT_DIR:=$PWD}"
    : "${WRAPPERS_DIRNAME:=.wrappers}"
    : "${WRAPPERS:=$CONTAINER_PROJECT_DIR/$WRAPPERS_DIRNAME}"
    : "${CONTAINER_APP_DIR:=\$CONTAINER_PROJECT_DIR}"
    : "${CONTAINER_ARGS:=--rm -i -P -v \$CONTAINER_PROJECT_DIR:\$CONTAINER_APP_DIR}"
    : "${CONTAINER_EXTRA_ARGS:=}"
    : "${CONTAINER_EXE:=$(command -v docker)}"
    : "${CONTAINER_AUTO_WRAPPER:=1}"

    # I can't use array on default initialization
    if [[ -z "${CONTAINER_WRAPPERS}" ]]; then
        CONTAINER_WRAPPERS=(python ruby node java php)
    fi
}

_container_refresh_wrappers() {
    log_status "Recreating wrappers in $WRAPPERS"
    mkdir -p "$WRAPPERS"
    for cmd in "${CONTAINER_WRAPPERS[@]}"; do
        _container_wrap "$cmd"
    done
}

_container_auto_wrappers() {
    # auto wrappers doesn't use _container_cmd
    (
        container_cmd() {
            case "$1" in
                shell)
                    _default_cmd_line bash
                    ;;
                build)
                    echo "$CONTAINER_EXE build -t $CONTAINER_NAME ."
                    ;;
                up)
                    echo "docker-compose up"
                    ;;
                down)
                    echo "docker-compose down"
                    ;;
                *)
                    exit 1
            esac
        }
        _container_wrap shell
        [[ -f Dockerfile ]] && _container_wrap build
        if [[ -f docker-compose.yml ]]; then
            _container_wrap up
            _container_wrap down
        fi
    )
}

_container_wrap() {
    local script_name=$1
    local wrapper_script=$WRAPPERS/${script_name}
    local script_content

    shift
    if [ $# -gt 0 ]; then
        script_content="$*"
    else
        # uses _container_cmd to fetch the script customization
        script_content="$(_container_cmd "${script_name}")"
    fi
    log_status "Wrapping ${script_name} on ${wrapper_script}"

    cat > "${wrapper_script}" <<-EOF
#!/bin/bash
CONTAINER_PROJECT_DIR="$CONTAINER_PROJECT_DIR"
CONTAINER_APP_DIR="$CONTAINER_APP_DIR"
CONTAINER_EXE="$CONTAINER_EXE"
CONTAINER_ARGS="$CONTAINER_ARGS"
CONTAINER_EXTRA_ARGS="$CONTAINER_EXTRA_ARGS"
CONTAINER_NAME="$CONTAINER_NAME"

if [[ -t 1 ]] && [[ -t 0 ]]; then
    CONTAINER_ARGS="-t \$CONTAINER_ARGS"
fi

if [[ "\$PWD" == "\$CONTAINER_PROJECT_DIR"* ]]; then
    CONTAINER_ARGS="-w \${CONTAINER_APP_DIR}\${PWD#\$CONTAINER_PROJECT_DIR} \$CONTAINER_ARGS"
else
    CONTAINER_ARGS="-w \$CONTAINER_APP_DIR \$CONTAINER_ARGS"
fi

$script_content

exit \$?
EOF
    chmod +x "${wrapper_script}"
}

_container_cmd() {
    local cmd=$1

    # if there is a customization, use it's value.
    # the customization function is called in another process to avoid mess
    # with the current script
    if declare -F container_cmd > /dev/null; then
        cmd_line=$(container_cmd "${cmd}") || echo ""
    fi

    if [[ -z "${cmd_line}" ]]; then
        cmd_line="$(_default_cmd_line "${cmd}")"
    fi
    echo -e "${cmd_line}"
}

_default_cmd_line() {
    local cmd=$1
    echo "CONTAINER_CMD=${cmd}"
    # shellcheck disable=SC2016
    echo '"$CONTAINER_EXE" run $CONTAINER_ARGS $CONTAINER_EXTRA_ARGS --entrypoint="$CONTAINER_CMD" "$CONTAINER_NAME" "$@"'
}

_wrapper_in_git_ignore() {

    if ! (echo grep "$WRAPPERS_DIRNAME" .gitignore "$(git config --get core.excludesfile)" 2> /dev/null | bash - > /dev/null); then
        log_status "Adding ${WRAPPERS_DIRNAME} to .gitignore"
        echo -e "\n# Container wrappers\n${WRAPPERS_DIRNAME}\n" >> .gitignore
    fi   
}
