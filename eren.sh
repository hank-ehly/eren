#!/bin/bash

usage() {
    echo '
    Usage:
            -h              : help
            -r              : recursive
            -o <extentsion> : specify .old extension
            -n <extension>  : specify .new extension

    Example: $ eren -r -o php -n html src/
             # Recursively rename all .php to .html in src folder
    '
    exit 0
}

if [[ ${#} -eq 0 ]] || [[ ! -f ${1} ]]; then
    usage
fi

while getopts 'h' opt; do
    case ${opt} in
        h)
            usage
            ;;
        *)
            usage
            ;;
    esac
done


