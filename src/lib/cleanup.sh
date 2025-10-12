#!/usr/bin/bash

# Cleanup dummy libraries and temporary directories

cleanup() {
    local dummyLibChecks="Pstream dynamicFvMesh"

    # Cleanup dummy libraries
    for dummy in $dummyLibChecks; do
        if [ -f "${FOAM_USER_LIBBIN}/lib${dummy}.so" ] &&
            tr '\n' ' ' < "${FOAM_USER_LIBBIN}/lib${dummy}.so" | grep -q '^!<arch> $'; then
            rm -rf "${FOAM_USER_LIBBIN}/lib${dummy}.so"
        fi
    done

    # Cleanup temporary case directory
    rm -rf "$caseRun"
}
