#!/bin/bash

SOURCE_FILE="hosts.source.txt"
FAILED_TESTS=()

_test_host() {
    local line_array=($@)
    echo "testing: ${line_array[1]} ${line_array[2]}:${line_array[3]}"
    curl --max-time 3 -sS -I \
        "https://${line_array[1]}" \
        --connect-to ::${line_array[2]}:${line_array[3]} >/dev/null
    if [ $? -ne 0 ]; then
        n=${#FAILED_TESTS[@]}
        FAILED_TESTS[n]="${line_array[1]}-${line_array[2]}:${line_array[3]}"
    fi
}

test_hosts() {
    while IFS='' read -r line; do
        echo "$line" |grep '^ *-front' >/dev/null
        if [ "$?" -eq 0 ]; then
            _test_host $line
        fi
    done < "$SOURCE_FILE"

    if [ ${#FAILED_TESTS[@]} -ne 0 ]; then
        echo ""
        echo "test failed"
        for i in "${FAILED_TESTS[@]}"; do
            echo "failed: $i"
        done
        exit 1
    fi
}

test_hosts
