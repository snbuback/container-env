#!/bin/bash

run_on_container() {
    local container_name=$1
    docker run --rm -v "${PWD}":"${PWD}" -w "${PWD}" "${container_name}" ./test/install_and_check.sh | tee -a /tmp/out.txt
    return $?
}

run() {
    for container in fedora debian ubuntu; do
        echo "## Testing on ${container} ##"
        local output
        output=$(run_on_container ${container})
        local rc=$?
        if [ ${rc} -eq 0 ] && [[ ${output} == *"Installed. Test Acceptance!"* ]]; then
            echo "   Passed"
        else
            echo -e "   Failed on ${container}. Status code=${rc}"
            echo -e "${output}"
            # exit 1
        fi
        echo
    done
}

run
