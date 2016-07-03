#!/bin/bash

LOGFILE="`pwd`/.erenlog"

SHUNIT2_DL='https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/shunit2/shunit2-2.1.6.tgz'
SHUNIT2_TB='shunit2-2.1.6.tgz'
SHUNIT2_DIRNAME="`echo ${SHUNIT2_TB} | sed s/.tgz//`"

VERBOSE='no'
RUN_TESTS='no'

usage() {
    echo '
    Usage:
            -h             : help
            -r             : recursive
            -t             : run shunit2 tests
            -v             : verbose
            -o <extension> : specify .old extension
            -n <extension> : specify .new extension

    Example: $ eren -r -v -o php -n html src/
             # Recursively rename all .php to .html in src folder
    '
    exit 0
}

clog() {
    if [[ $# -ne 2 ]]; then
        warn 'clog() requires 2 arguments. Exit.' && exit 0
    fi

    local color=${1}

    local log="[$(date +%Y-%m-%d' '%H:%M:%S)] ${2}"

    case ${color} in
        black)
            echo "\033[0m${log}\033[0m" && echo ${log} >> ${LOGFILE}
            ;;
        blue)
            echo "\033[0;34m${log}\033[0m" && echo ${log} >> ${LOGFILE}
            ;;
        red)
            echo "\033[0;31m${log}\033[0m" && echo ${log} >> ${LOGFILE}
            ;;
        yellow)
            echo "\033[0;33m${log}\033[0m" && echo ${log} >> ${LOGFILE}
            ;;
        *)
            clog black "${2}"
            ;;
    esac
}

error() {
    clog red "${1}" && exit 1
}

warn() {
    clog yellow "${1}"
}

debug() {
    if [[ ${VERBOSE} = 'yes' ]]; then
        clog blue "${1}"
    fi
}

log() {
    clog black "${1}"
}

download_shunit2() {
    debug 'mkdir vendor && cd vendor'
    mkdir vendor && cd vendor

    debug "wget ${SHUNIT2_DL}"
    wget ${SHUNIT2_DL} > /dev/null 2>&1

    debug "test ! -f ${SHUNIT2_TB}"
    if [[ ! -f ${SHUNIT2_TB} ]]; then
        error 'Failed to fetch tarball. Exit.'
    fi

    debug "tar xzf ${SHUNIT2_TB}"
    tar xzf ${SHUNIT2_TB}

    debug "rm -f ${SHUNIT2_TB}"
    rm -f ${SHUNIT2_TB}

    debug "test -f ./${SHUNIT2_DIRNAME}/src/shunit2"
    if [[ -f ./${SHUNIT2_DIRNAME}/src/shunit2 ]]; then
        log "Installed shunit2 to vendor/${SHUNIT2_DIRNAME}"

        debug "cd .."
        cd ..

        debug "sh ./eren.sh -t"
        sh ./eren.sh -t
    else
        error 'Installation failed. Exit.'
    fi
}

run_shunit2() {

    debug "test ! -f ./vendor/${SHUNIT2_DIRNAME}/src/shunit2"
    if [[ ! -f ./vendor/${SHUNIT2_DIRNAME}/src/shunit2 ]]; then

        read -p 'You must download shunit2 (320K) to run the tests. Download now? [y/n] '

        local serialized_reply=`echo ${REPLY} | tr [:upper:] [:lower:]`

        case ${serialized_reply} in
            y)
                download_shunit2
                ;;
            n)
                log 'Exit.' && exit 0
                ;;
            *)
                warn "Invalid option ${opt}."
                sh ./eren.sh -t
                ;;
        esac

    else
        debug 'Running tests'
        sh ./vendor/${SHUNIT2_DIRNAME}/src/shunit2 ${BASH_SOURCE[0]}
    fi
}

if [[ ${#} -eq 0 ]]; then
    usage
fi

while getopts 'htrv' opt; do
    case ${opt} in
        h)
            usage
            ;;
        t)
            RUN_TESTS='yes'
            ;;
        r)
            echo 'recursive'
            ;;
        v)
            VERBOSE='yes'
            ;;
        *)
            usage
            ;;
    esac
done

if [[ ${RUN_TESTS} = 'yes' ]]; then
    run_shunit2
fi
