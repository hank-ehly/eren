#!/bin/bash

LOGFILE="`pwd`/.erenlog"

SHUNIT2_DL='https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/shunit2/shunit2-2.1.6.tgz'
SHUNIT2_TB='shunit2-2.1.6.tgz'
SHUNIT2_DIRNAME="`echo ${SHUNIT2_TB} | sed s/.tgz//`"

VERBOSE=''
RUN_TESTS='no'
sflags=''

SOURCE_EXT=''
TARGET_EXT=''

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
        warn 'clog() requires 2 arguments. Exiting.' && exit 0
    fi

    local color=${1}

    local log_call_ln=${BASH_LINENO[1]}

    local log="[$(date +%Y-%m-%d' '%H:%M:%S) Line: ${log_call_ln}] ${2}"

    case ${color}
    in
        black)
            echo "\033[0m${log}\033[0m" && echo ${log} >> ${LOGFILE}
            ;;
        blue)
            echo "\033[0;34m${log}\033[0m" && echo ${log} >> ${LOGFILE}
            ;;
        red)
            echo "\033[1;31m${log}\033[0m" && echo ${log} >> ${LOGFILE}
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
    if echo ${sflags} | grep 'v' >/dev/null; then
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
    wget ${SHUNIT2_DL} >/dev/null 2>&1

    debug "test ! -f ${SHUNIT2_TB}"
    if [[ ! -f ${SHUNIT2_TB} ]]; then
        error 'Failed to fetch tarball. Exiting.'
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
        error 'Installation failed. Exiting.'
    fi
}

run_shunit2() {

    debug "test ! -f ./vendor/${SHUNIT2_DIRNAME}/src/shunit2"
    if [[ ! -f ./vendor/${SHUNIT2_DIRNAME}/src/shunit2 ]]; then

        read -p 'You must download shunit2 (320K) to run the tests. Download now? [y/n] '

        local serialized_reply=`echo ${REPLY} | tr [:upper:] [:lower:]`

        case ${serialized_reply}
        in
            y)
                download_shunit2
                ;;
            n)
                log 'Exiting.' && exit 0
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

clean_fixtures() {
    debug 'test -d fixtures'
    if [[ -d fixtures ]]; then
        debug 'rm -rf fixtures'
        rm -rf fixtures
    fi
}

generate_fixtures() {
    mkdir fixtures
    touch fixtures/foo.php
    touch fixtures/bar.php
    touch fixtures/biz.html
    touch fixtures/baz.html

    mkdir fixtures/level1
    touch fixtures/level1/foo.php
    touch fixtures/level1/bar.php
    touch fixtures/level1/biz.html
    touch fixtures/level1/baz.html

    mkdir fixtures/level1/level2
    touch fixtures/level1/level2/foo.php
    touch fixtures/level1/level2/bar.php
    touch fixtures/level1/level2/biz.html
    touch fixtures/level1/level2/baz.html
}

setUp() {
    clean_fixtures
    generate_fixtures
}

tearDown() {
    clean_fixtures
}

test_rename_single_file() {
    sh eren.sh -v -o php -n html fixtures/foo.php

    assertTrue '[[ -e fixtures/foo.html ]]'
    assertFalse '[[ -e fixtures/foo.php ]]'

    assertTrue '[[ -e fixtures/bar.php ]]'
}

test_rename_files_in_dir_non_recursive() {
    sh eren.sh -v -o php -n html fixtures/

    assertTrue '[[ -e fixtures/foo.html ]]'
    assertTrue '[[ -e fixtures/bar.html ]]'
    assertTrue '[[ -e fixtures/biz.html ]]'
    assertTrue '[[ -e fixtures/baz.html ]]'

    assertFalse '[[ -e fixtures/foo.php ]]'
    assertFalse '[[ -e fixtures/bar.php ]]'
    assertFalse '[[ -e fixtures/biz.php ]]'
    assertFalse '[[ -e fixtures/baz.php ]]'

    assertTrue '[[ -e fixtures/level1/foo.php ]]'
    assertTrue '[[ -e fixtures/level1/bar.php ]]'
    assertTrue '[[ -e fixtures/level1/biz.html ]]'
    assertTrue '[[ -e fixtures/level1/baz.html ]]'
}

test_rename_files_recursively() {
    sh eren.sh -vr -o php -n html fixtures/

    assertTrue '[[ -e fixtures/foo.html ]]'
    assertTrue '[[ -e fixtures/bar.html ]]'
    assertTrue '[[ -e fixtures/biz.html ]]'
    assertTrue '[[ -e fixtures/baz.html ]]'

    assertFalse '[[ -e fixtures/foo.php ]]'
    assertFalse '[[ -e fixtures/bar.php ]]'
    assertFalse '[[ -e fixtures/biz.php ]]'
    assertFalse '[[ -e fixtures/baz.php ]]'

    assertTrue '[[ -e fixtures/level1/foo.html ]]'
    assertTrue '[[ -e fixtures/level1/bar.html ]]'
    assertTrue '[[ -e fixtures/level1/biz.html ]]'
    assertTrue '[[ -e fixtures/level1/baz.html ]]'

    assertFalse '[[ -e fixtures/level1/foo.php ]]'
    assertFalse '[[ -e fixtures/level1/bar.php ]]'
    assertFalse '[[ -e fixtures/level1/biz.php ]]'
    assertFalse '[[ -e fixtures/level1/baz.php ]]'

    assertTrue '[[ -e fixtures/level1/level2/foo.html ]]'
    assertTrue '[[ -e fixtures/level1/level2/bar.html ]]'
    assertTrue '[[ -e fixtures/level1/level2/biz.html ]]'
    assertTrue '[[ -e fixtures/level1/level2/baz.html ]]'

    assertFalse '[[ -e fixtures/level1/level2/foo.php ]]'
    assertFalse '[[ -e fixtures/level1/level2/bar.php ]]'
    assertFalse '[[ -e fixtures/level1/level2/biz.php ]]'
    assertFalse '[[ -e fixtures/level1/level2/baz.php ]]'
}

eren() {

    if [[ -d ${3} ]]; then

        local serialized_dirname=`echo ${3} | sed 's/\/$//'`

        if echo ${sflags} | grep 'r' >/dev/null; then

            for file in ${serialized_dirname}/*
            do
                if [[ -d ${file} ]]; then

                    debug "Going into ${file}"
                    eren ${1} ${2} ${file}

                elif echo ${file} | grep ".${1}" >/dev/null; then

                    debug "mv ${file} `echo ${file} | cut -d. -f1`.${2}"
                    mv ${file} `echo ${file} | cut -d. -f1`.${2}

                else
                    debug "Skipped ${file}"
                fi
            done

        else

            # non-recursive dir
            for file in ${serialized_dirname}/*.${1}
            do
                debug "mv ${file} `echo ${file} | cut -d. -f1`.${2}"
                mv ${file} `echo ${file} | cut -d. -f1`.${2}
            done

        fi
    fi

    if [[ -f ${3} ]]; then
        mv ${3} `echo ${3} | cut -d. -f1`.${2}
    fi
}



args=`getopt hn:o:rtv $*`

if [[ ${?} -ne 0 ]]; then
    usage
    exit 2
fi

set -- $args

for i
do
    case "$i"
    in
        -h)
            usage
            ;;
        -r|-t|-v)
            sflags="${i#-}$sflags";
            shift;;
        -o)
            debug "old extension is ${2}"; oarg="$2"; shift;
            shift;;
        -n)
            debug "new extension is ${2}"; narg="$2"; shift;
            shift;;
        --)
            shift; break;;
    esac
done

debug "single-char flags: ${sflags}"

if [[ -z ${sflags} ]] && [[ $# -eq 0 ]]; then
    usage
fi

if echo ${sflags} | grep 't' >/dev/null; then
    run_shunit2
fi

if [[ ! -z ${1} ]] && [[ ! -f ${1} ]] && [[ ! -d ${1} ]]; then
    error "\"${1}\" is not a file or a directory. Exiting."
    usage
fi

if [[ ! -z ${oarg} ]] && [[ ! -z ${narg} ]] && [[ -e ${1} ]]; then
    eren ${oarg} ${narg} ${1}
fi
