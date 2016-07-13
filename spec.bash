#!/usr/bin/env bash

if [[ -z ${SCRIPT_DIR} ]]
then
        SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

        if [[ -L ${SCRIPT_DIR}/renex ]]
        then
                SCRIPT_DIR=$(dirname `readlink ${SCRIPT_DIR}/renex`)
        fi
fi

clean_fixtures() {
        if [[ -d fixtures ]]
        then
                rm -rf fixtures
        fi
}

generate_fixtures() {
        mkdir -p ${SCRIPT_DIR}/fixtures/level1/level2

        touch ${SCRIPT_DIR}/fixtures/foo.php
        touch ${SCRIPT_DIR}/fixtures/bar.component.php
        touch ${SCRIPT_DIR}/fixtures/biz.html
        touch ${SCRIPT_DIR}/fixtures/baz.html

        touch ${SCRIPT_DIR}/fixtures/level1/foo.php
        touch ${SCRIPT_DIR}/fixtures/level1/bar.php
        touch ${SCRIPT_DIR}/fixtures/level1/biz.html
        touch ${SCRIPT_DIR}/fixtures/level1/baz.html

        touch ${SCRIPT_DIR}/fixtures/level1/level2/foo.php
        touch ${SCRIPT_DIR}/fixtures/level1/level2/bar.php
        touch ${SCRIPT_DIR}/fixtures/level1/level2/biz.html
        touch ${SCRIPT_DIR}/fixtures/level1/level2/baz.html
}

setUp() {
        clean_fixtures
        generate_fixtures
}

tearDown() {
        clean_fixtures
}

test_rename_single_file() {
        ${SCRIPT_DIR}/renex -o php -n html ${SCRIPT_DIR}/fixtures/foo.php

        assertTrue ' fixtures/foo.html should exist' '[[ -e fixtures/foo.html ]]'
        assertFalse ' fixtures/foo.php should not exist' '[[ -e fixtures/foo.php ]]'

        assertTrue ' fixtures/bar.component.php should exist' '[[ -e fixtures/bar.component.php ]]'
}

test_rename_files_in_dir_non_recursive() {
        ${SCRIPT_DIR}/renex -o php -n html ${SCRIPT_DIR}/fixtures/

        assertTrue '[[ -e fixtures/foo.html ]]'
        assertTrue '[[ -e fixtures/bar.component.html ]]'
        assertTrue '[[ -e fixtures/biz.html ]]'
        assertTrue '[[ -e fixtures/baz.html ]]'
}

test_rename_files_recursively() {
        ${SCRIPT_DIR}/renex -r -o php -n html ${SCRIPT_DIR}/fixtures/

        assertTrue ' fixtures/foo.html should exist' '[[ -e fixtures/foo.html ]]'
        assertTrue '[[ -e fixtures/bar.component.html ]]'
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

test_handle_relative_dirs() {
        cd ${SCRIPT_DIR}/fixtures || exit 1
        ${SCRIPT_DIR}/renex -r -o php -n html ./ || exit 1
        cd ${SCRIPT_DIR} || exit 1

        assertTrue ' fixtures/foo.html should exist' '[[ -e fixtures/foo.html ]]'
        assertTrue '[[ -e fixtures/bar.component.html ]]'
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
