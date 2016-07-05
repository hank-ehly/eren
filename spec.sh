#!/usr/bin/env bash

clean_fixtures() {
        if [[ -d fixtures ]]
        then
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
        ./renex -v -o php -n html fixtures/foo.php

        assertTrue '[[ -e fixtures/foo.html ]]'
        assertFalse '[[ -e fixtures/foo.php ]]'

        assertTrue '[[ -e fixtures/bar.php ]]'
}

test_rename_files_in_dir_non_recursive() {
        ./renex -v -o php -n html fixtures/

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
        ./renex -vr -o php -n html fixtures/

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

test_handle_relative_dirs() {
        cd fixtures && ../renex -vr -o php -n html ./ && cd ..

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
