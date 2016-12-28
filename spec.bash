#!/usr/bin/env bash


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ -L ${SCRIPT_DIR}/renex ]]
then
        SCRIPT_DIR=$(dirname `readlink ${SCRIPT_DIR}/renex`)
fi

clean_fixtures() {
        if [[ -d fixtures ]]
        then
                rm -rf fixtures
        fi
}

# Generates the following folder structure for testing
#
# fixtures/
# ├── bar.component.php
# ├── baz.html
# ├── biz.html
# ├── foo.php
# └── level1
#     ├── bar.php
#     ├── baz.html
#     ├── biz.html
#     ├── foo.php
#     └── level2
#         ├── bar.php
#         ├── baz.html
#         ├── biz.html
#         └── foo.php
generate_fixtures() {
        mkdir -p ${SCRIPT_DIR}/fixtures/level1/level2

        touch ${SCRIPT_DIR}/fixtures/{,level1/{,level2/}}{{foo,bar}.php,{biz,baz}.html}
        mv ${SCRIPT_DIR}/fixtures/bar{,.component}.php
}

setUp() {
        clean_fixtures
}

tearDown() {
        clean_fixtures
}

test_rename_single_file() {
        generate_fixtures
        ${SCRIPT_DIR}/renex -o php -n html ${SCRIPT_DIR}/fixtures/foo.php

        assertTrue " ${SCRIPT_DIR}/fixtures/foo.html should exist" "[[ -e ${SCRIPT_DIR}/fixtures/foo.html ]]"
        assertFalse " ${SCRIPT_DIR}/fixtures/foo.php should not exist" "[[ -e ${SCRIPT_DIR}/fixtures/foo.php ]]"

        assertTrue " ${SCRIPT_DIR}/fixtures/bar.component.php should exist" "[[ -e ${SCRIPT_DIR}/fixtures/bar.component.php ]]"
}

test_rename_files_in_dir_non_recursive() {
        generate_fixtures
        ${SCRIPT_DIR}/renex -o php -n html ${SCRIPT_DIR}/fixtures/

        assertTrue " ${SCRIPT_DIR}/fixtures/foo.html should exist" "[[ -e ${SCRIPT_DIR}/fixtures/foo.html ]]"
        assertTrue " ${SCRIPT_DIR}/fixtures/bar.component.html should exist" "[[ -e ${SCRIPT_DIR}/fixtures/bar.component.html ]]"
        assertTrue " ${SCRIPT_DIR}/fixtures/biz.html should exist" "[[ -e ${SCRIPT_DIR}/fixtures/biz.html ]]"
        assertTrue " ${SCRIPT_DIR}/fixtures/baz.html should exist" "[[ -e ${SCRIPT_DIR}/fixtures/baz.html ]]"
}

test_rename_files_recursively() {
        generate_fixtures
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
        generate_fixtures
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

test_handle_files_containing_spaces() {
        mkdir -p ${SCRIPT_DIR}/fixtures/level1/level2

        touch ${SCRIPT_DIR}/fixtures/{,level1/{,level2/}}{{foo\ space,bar}.php,{biz\ space,baz}.html}
        mv ${SCRIPT_DIR}/fixtures/bar{,.component}.php

        ${SCRIPT_DIR}/renex -r -o php -n html ${SCRIPT_DIR}/fixtures/

        assertTrue " ${SCRIPT_DIR}/fixtures/foo\ space.html should exist"               "[[ -e ${SCRIPT_DIR}/fixtures/foo\ space.html ]]"
        assertTrue " ${SCRIPT_DIR}/fixtures/level1/foo\ space.html should exist"        "[[ -e ${SCRIPT_DIR}/fixtures/level1/foo\ space.html ]]"
        assertTrue " ${SCRIPT_DIR}/fixtures/level1/level2/foo\ space.html should exist" "[[ -e ${SCRIPT_DIR}/fixtures/level1/level2/foo\ space.html ]]"
}

