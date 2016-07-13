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

        assertTrue " ${SCRIPT_DIR}/fixtures/foo.html should exist" "[[ -e ${SCRIPT_DIR}/fixtures/foo.html ]]"
        assertFalse " ${SCRIPT_DIR}/fixtures/foo.php should not exist" "[[ -e ${SCRIPT_DIR}/fixtures/foo.php ]]"

        assertTrue " ${SCRIPT_DIR}/fixtures/bar.component.php should exist" "[[ -e ${SCRIPT_DIR}/fixtures/bar.component.php ]]"
}

test_rename_files_in_dir_non_recursive() {
        ${SCRIPT_DIR}/renex -o php -n html ${SCRIPT_DIR}/fixtures/

        assertTrue " ${SCRIPT_DIR}/fixtures/foo.html should exist" "[[ -e ${SCRIPT_DIR}/fixtures/foo.html ]]"
        assertTrue " ${SCRIPT_DIR}/fixtures/bar.component.html should exist" "[[ -e ${SCRIPT_DIR}/fixtures/bar.component.html ]]"
        assertTrue " ${SCRIPT_DIR}/fixtures/biz.html should exist" "[[ -e ${SCRIPT_DIR}/fixtures/biz.html ]]"
        assertTrue " ${SCRIPT_DIR}/fixtures/baz.html should exist" "[[ -e ${SCRIPT_DIR}/fixtures/baz.html ]]"
}

test_rename_files_recursively() {
        ${SCRIPT_DIR}/renex -r -o php -n html ${SCRIPT_DIR}/fixtures/

        assertTrue " ${SCRIPT_DIR}/fixtures/foo.html should exist" "[[ -e ${SCRIPT_DIR}/fixtures/foo.html ]]"
        assertTrue " ${SCRIPT_DIR}/fixtures/bar.component.html should exist" "[[ -e ${SCRIPT_DIR}/fixtures/bar.component.html ]]"
        assertTrue " ${SCRIPT_DIR}/fixtures/biz.html should exist" "[[ -e ${SCRIPT_DIR}/fixtures/biz.html ]]"
        assertTrue " ${SCRIPT_DIR}/fixtures/baz.html should exist" "[[ -e ${SCRIPT_DIR}/fixtures/baz.html ]]"

        assertFalse " ${SCRIPT_DIR}/fixtures/foo.php should not exist" "[[ -e ${SCRIPT_DIR}/fixtures/foo.php ]]"
        assertFalse " ${SCRIPT_DIR}/fixtures/bar.php should not exist" "[[ -e ${SCRIPT_DIR}/fixtures/bar.php ]]"
        assertFalse " ${SCRIPT_DIR}/fixtures/biz.php should not exist" "[[ -e ${SCRIPT_DIR}/fixtures/biz.php ]]"
        assertFalse " ${SCRIPT_DIR}/fixtures/baz.php should not exist" "[[ -e ${SCRIPT_DIR}/fixtures/baz.php ]]"

        assertTrue " ${SCRIPT_DIR}/fixtures/level1/foo.html should exist" "[[ -e ${SCRIPT_DIR}/fixtures/level1/foo.html ]]"
        assertTrue " ${SCRIPT_DIR}/fixtures/level1/bar.html should exist" "[[ -e ${SCRIPT_DIR}/fixtures/level1/bar.html ]]"
        assertTrue " ${SCRIPT_DIR}/fixtures/level1/biz.html should exist" "[[ -e ${SCRIPT_DIR}/fixtures/level1/biz.html ]]"
        assertTrue " ${SCRIPT_DIR}/fixtures/level1/baz.html should exist" "[[ -e ${SCRIPT_DIR}/fixtures/level1/baz.html ]]"

        assertFalse " ${SCRIPT_DIR}/fixtures/level1/foo.php should not exist" "[[ -e ${SCRIPT_DIR}/fixtures/level1/foo.php ]]"
        assertFalse " ${SCRIPT_DIR}/fixtures/level1/bar.php should not exist" "[[ -e ${SCRIPT_DIR}/fixtures/level1/bar.php ]]"
        assertFalse " ${SCRIPT_DIR}/fixtures/level1/biz.php should not exist" "[[ -e ${SCRIPT_DIR}/fixtures/level1/biz.php ]]"
        assertFalse " ${SCRIPT_DIR}/fixtures/level1/baz.php should not exist" "[[ -e ${SCRIPT_DIR}/fixtures/level1/baz.php ]]"

        assertTrue " ${SCRIPT_DIR}/fixtures/level1/level2/foo.html should exist" "[[ -e ${SCRIPT_DIR}/fixtures/level1/level2/foo.html ]]"
        assertTrue " ${SCRIPT_DIR}/fixtures/level1/level2/bar.html should exist" "[[ -e ${SCRIPT_DIR}/fixtures/level1/level2/bar.html ]]"
        assertTrue " ${SCRIPT_DIR}/fixtures/level1/level2/biz.html should exist" "[[ -e ${SCRIPT_DIR}/fixtures/level1/level2/biz.html ]]"
        assertTrue " ${SCRIPT_DIR}/fixtures/level1/level2/baz.html should exist" "[[ -e ${SCRIPT_DIR}/fixtures/level1/level2/baz.html ]]"

        assertFalse " ${SCRIPT_DIR}/fixtures/level1/level2/foo.php should not exist" "[[ -e ${SCRIPT_DIR}/fixtures/level1/level2/foo.php ]]"
        assertFalse " ${SCRIPT_DIR}/fixtures/level1/level2/bar.php should not exist" "[[ -e ${SCRIPT_DIR}/fixtures/level1/level2/bar.php ]]"
        assertFalse " ${SCRIPT_DIR}/fixtures/level1/level2/biz.php should not exist" "[[ -e ${SCRIPT_DIR}/fixtures/level1/level2/biz.php ]]"
        assertFalse " ${SCRIPT_DIR}/fixtures/level1/level2/baz.php should not exist" "[[ -e ${SCRIPT_DIR}/fixtures/level1/level2/baz.php ]]"
}

test_handle_relative_dirs() {
        ( cd ${SCRIPT_DIR}/fixtures && ${SCRIPT_DIR}/renex -r -o php -n html ./ && cd ${SCRIPT_DIR} ) || exit 1

        assertTrue " ${SCRIPT_DIR}/fixtures/foo.html should exist" "[[ -e ${SCRIPT_DIR}/fixtures/foo.html ]]"
        assertTrue " ${SCRIPT_DIR}/fixtures/bar.component.html should exist" "[[ -e ${SCRIPT_DIR}/fixtures/bar.component.html ]]"
        assertTrue " ${SCRIPT_DIR}/fixtures/biz.html should exist" "[[ -e ${SCRIPT_DIR}/fixtures/biz.html ]]"
        assertTrue " ${SCRIPT_DIR}/fixtures/baz.html should exist" "[[ -e ${SCRIPT_DIR}/fixtures/baz.html ]]"

        assertFalse " ${SCRIPT_DIR}/fixtures/foo.php should not exist" "[[ -e ${SCRIPT_DIR}/fixtures/foo.php ]]"
        assertFalse " ${SCRIPT_DIR}/fixtures/bar.php should not exist" "[[ -e ${SCRIPT_DIR}/fixtures/bar.php ]]"
        assertFalse " ${SCRIPT_DIR}/fixtures/biz.php should not exist" "[[ -e ${SCRIPT_DIR}/fixtures/biz.php ]]"
        assertFalse " ${SCRIPT_DIR}/fixtures/baz.php should not exist" "[[ -e ${SCRIPT_DIR}/fixtures/baz.php ]]"

        assertTrue " ${SCRIPT_DIR}/fixtures/level1/foo.html should exist" "[[ -e ${SCRIPT_DIR}/fixtures/level1/foo.html ]]"
        assertTrue " ${SCRIPT_DIR}/fixtures/level1/bar.html should exist" "[[ -e ${SCRIPT_DIR}/fixtures/level1/bar.html ]]"
        assertTrue " ${SCRIPT_DIR}/fixtures/level1/biz.html should exist" "[[ -e ${SCRIPT_DIR}/fixtures/level1/biz.html ]]"
        assertTrue " ${SCRIPT_DIR}/fixtures/level1/baz.html should exist" "[[ -e ${SCRIPT_DIR}/fixtures/level1/baz.html ]]"

        assertFalse " ${SCRIPT_DIR}/fixtures/level1/foo.php should not exist" "[[ -e ${SCRIPT_DIR}/fixtures/level1/foo.php ]]"
        assertFalse " ${SCRIPT_DIR}/fixtures/level1/bar.php should not exist" "[[ -e ${SCRIPT_DIR}/fixtures/level1/bar.php ]]"
        assertFalse " ${SCRIPT_DIR}/fixtures/level1/biz.php should not exist" "[[ -e ${SCRIPT_DIR}/fixtures/level1/biz.php ]]"
        assertFalse " ${SCRIPT_DIR}/fixtures/level1/baz.php should not exist" "[[ -e ${SCRIPT_DIR}/fixtures/level1/baz.php ]]"

        assertTrue " ${SCRIPT_DIR}/fixtures/level1/level2/foo.html should exist" "[[ -e ${SCRIPT_DIR}/fixtures/level1/level2/foo.html ]]"
        assertTrue " ${SCRIPT_DIR}/fixtures/level1/level2/bar.html should exist" "[[ -e ${SCRIPT_DIR}/fixtures/level1/level2/bar.html ]]"
        assertTrue " ${SCRIPT_DIR}/fixtures/level1/level2/biz.html should exist" "[[ -e ${SCRIPT_DIR}/fixtures/level1/level2/biz.html ]]"
        assertTrue " ${SCRIPT_DIR}/fixtures/level1/level2/baz.html should exist" "[[ -e ${SCRIPT_DIR}/fixtures/level1/level2/baz.html ]]"

        assertFalse " ${SCRIPT_DIR}/fixtures/level1/level2/foo.php should not exist" "[[ -e ${SCRIPT_DIR}/fixtures/level1/level2/foo.php ]]"
        assertFalse " ${SCRIPT_DIR}/fixtures/level1/level2/bar.php should not exist" "[[ -e ${SCRIPT_DIR}/fixtures/level1/level2/bar.php ]]"
        assertFalse " ${SCRIPT_DIR}/fixtures/level1/level2/biz.php should not exist" "[[ -e ${SCRIPT_DIR}/fixtures/level1/level2/biz.php ]]"
        assertFalse " ${SCRIPT_DIR}/fixtures/level1/level2/baz.php should not exist" "[[ -e ${SCRIPT_DIR}/fixtures/level1/level2/baz.php ]]"
}
