
# setup default values
container_setup() {

    : "${WRAPPERS_DIRNAME:=.wrappers}"
    : "${WRAPPERS:=$PWD/$WRAPPERS_DIRNAME}"
    : "${CONTAINER_ARGS:=--rm -it -P}"
    : "${CONTAINER_EXTRA_ARGS:=-v $PWD:$PWD -w $PWD}"

    # I can't use array on default initialization
    if [ -z "${CONTAINER_WRAPPERS}" ]; then
        CONTAINER_WRAPPERS=(python ruby node)
    fi
}

_container_cmd() {
    local cmd=$1
    local cmd_extra_cfg="${CONTAINER_EXTRA_ARGS}"

    if declare -F container_arguments > /dev/null; then
        cmd_extra_cfg=`container_arguments ${cmd}`
    fi

    echo "docker run $CONTAINER_ARGS --entrypoint=${cmd} ${cmd_extra_cfg} ${CONTAINER_NAME} \$*"
}

_container_run() {
    `container_cmd $*`
}

_refresh_wrappers() {
    log_status "Recreating wrappers in $WRAPPERS"
    mkdir -p $WRAPPERS
    for cmd in "${CONTAINER_WRAPPERS[@]}"; do
        echo "cmd='$cmd'"
        container_wrap $cmd
    done
    container_wrap bash shell
    _wrapper_in_git_ignore
}

container_wrap() {
    local cmd=$1
    local wrapper_script=$WRAPPERS/${2-$cmd}
    local docker_cmd=`_container_cmd $cmd`
    log_status "Wrapping $cmd on $wrapper_script"

    (cat <<-EOF
#!/bin/bash
$docker_cmd
exit $?
EOF
    ) > $wrapper_script
    chmod +x $wrapper_script

}

_wrapper_in_git_ignore() {
    if ! grep "$WRAPPERS_DIRNAME" .gitignore > /dev/null; then
        log_status "Adding $WRAPPERS_DIRNAME to .gitignore"
        echo -e "\n# Container wrappers\n$WRAPPERS_DIRNAME\n" >> .gitignore
    fi   
}

container_layout() {
    local cmd

    container_setup

    # refreshing wrappers if required
    if [ ! -f $WRAPPERS/.initialized ]; then
        _refresh_wrappers
        touch $WRAPPERS/.initialized
    fi

    PATH_add $WRAPPERS

}
