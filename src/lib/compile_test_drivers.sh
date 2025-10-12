#!/usr/bin/bash

# Compile test drivers for all test libraries
# Supports custom test driver via --test-driver flag

compile_test_drivers() {
    local custom_driver="${args[--test-driver]}"

    # Compile tests
    for lib in $libs; do
        cd "$lib" || exit 1

        # If custom driver is specified, copy it to this test directory
        if [ -n "$custom_driver" ]; then
            cp "$custom_driver" "$root/tests/testDriver.C"
            echo "Using custom test driver: $custom_driver" >&2
        fi

        echo "Compiling $lib test driver..." >&2
        wmakeLnInclude . # Just in case the tested libs are header only

        # Use set -o pipefail to catch wmake failures even when piped to tee
        set -o pipefail
        if ! wmake 2>&1 | tee log.wmake; then
            set +o pipefail
            echo "" >&2
            echo "Error: Failed to compile $lib test driver" >&2
            echo "Full log saved to: $PWD/log.wmake" >&2
            exit 1
        fi
        set +o pipefail
        echo "Test driver for $lib has been compiled." >&2
        cd - > /dev/null || exit 1
    done
}
