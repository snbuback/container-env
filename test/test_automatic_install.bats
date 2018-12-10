# Important: sometimes line error doesn't match on bats
LOG=/tmp/out.txt

install_on() {
    local container_name=$1
    echo -e "\n\nRunning ${container_name}" | tee -a "$LOG"
    docker run --rm -v "${PWD}":"${PWD}" -w "${PWD}" -e REPOSITORY=$PWD/.git "${container_name}" ./test/install_and_check.sh | tee -a "$LOG"
    return $?
}

@test "Install on Ubuntu" {
    run install_on ubuntu
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"Installed. Test Acceptance!"* ]]
}

@test "Install on Debian" {
    run install_on debian
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"Installed. Test Acceptance!"* ]]
}

@test "Install on Fedora" {
    run install_on fedora
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"Installed. Test Acceptance!"* ]]
}
