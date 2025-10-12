#!/usr/bin/bash

# Create dummy libraries if they don't exist
# Some OpenFOAM forks/configurations may not have certain libraries

create_dummy_libs() {
    # If there is no lib${libName}.so, create a dummy one
    local dummyLibChecks="Pstream dynamicFvMesh"
    for dummy in $dummyLibChecks; do
        if [ ! -f "${FOAM_LIBBIN}/lib${dummy}.so" ] &&
            [ ! -f "${FOAM_USER_LIBBIN}/lib${dummy}.so" ] &&
            [ ! -f "${FOAM_LIBBIN}/${FOAM_MPI}/lib${dummy}.so" ]; then
            echo '!<arch>' > "${FOAM_USER_LIBBIN}/lib${dummy}.so"
        fi
    done
}
