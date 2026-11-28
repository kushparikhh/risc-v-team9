#!/bin/bash
# Runs every unit test in tb/unit. Run from inside tb/.

failed=0

for test in unit/*_tb.cpp
do
    echo "=== Running $test ==="
    if ! ./doit.sh "$test"; then
        echo "FAILED: $test"
        failed=$((failed + 1))
    fi
done

echo "Done. $failed test file(s) failed."
exit $failed