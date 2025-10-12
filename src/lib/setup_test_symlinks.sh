#!/usr/bin/bash

# Setup test symlinks if FOAM_FOAMUT_TESTS environment variable is set
# Discovers Make directories and symlinks parent directories under tests/

setup_test_symlinks() {
    # If tests folder is supplied through an env. var. do the symlinking
    if [ -n "${FOAM_FOAMUT_TESTS}" ]; then
        find "${FOAM_FOAMUT_TESTS}" -type d -name "Make" | while read -r make_dir; do
            parent_dir=$(basename "$(dirname "$make_dir")")
            target_dir="$root/tests/$parent_dir"
            ln -f -s "$(dirname "$make_dir")" "$target_dir"
            echo "picked up $parent_dir tests"
        done
    fi
}
