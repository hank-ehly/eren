### renex (ren)ame (ex)tension

A bash script for easily renaming file extensions

    Usage:
            -h             : help
            -r             : recursive
            -t             : run shunit2 tests
            -v             : verbose
            -o <extension> : specify .old extension
            -n <extension> : specify .new extension

    Example: $ renex -r -v -o php -n html src/
             # Recursively rename all .php to .html in src folder