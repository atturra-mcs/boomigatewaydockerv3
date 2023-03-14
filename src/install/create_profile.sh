#!/bin/bash
blacklisted () {
    case $1 in
        PWD|OLDPWD|SHELL|STORAGE|HOME|PATH|USER) return 0 ;;
        *) return 1 ;;
    esac
}

env_save () {
    local VAR
    for VAR in $(compgen -A export); do
        blacklisted $VAR || \
            echo "export $VAR='${!VAR}'" >> ".profile"
    done
}
env_save
