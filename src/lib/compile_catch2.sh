#!/usr/bin/bash

# Compile Catch2 v3 if not already compiled
# Installs to FOAM_USER_LIBBIN/catch2

compile_catch2() {
    echo "Compiling Catch2 v3..." >&2
    if [ ! -f "$FOAM_USER_LIBBIN/catch2/lib/libCatch2.a" ]; then
        cd catch2 || exit 1
        mkdir -p build
        cd build || exit 1

        # Use pipefail to catch failures in piped commands
        set -o pipefail

        if ! cmake -DCMAKE_INSTALL_PREFIX="$FOAM_USER_LIBBIN"/catch2 .. 2>&1 | tee log.cmake; then
            set +o pipefail
            echo "" >&2
            echo "Error: CMake configuration failed for Catch2" >&2
            echo "Full log saved to: $PWD/log.cmake" >&2
            exit 1
        fi

        if ! make -j"$(nproc)" 2>&1 | tee log.makeBuild; then
            set +o pipefail
            echo "" >&2
            echo "Error: Failed to build Catch2" >&2
            echo "Full log saved to: $PWD/log.makeBuild" >&2
            exit 1
        fi

        if ! make install 2>&1 | tee log.makeInstall; then
            set +o pipefail
            echo "" >&2
            echo "Error: Failed to install Catch2" >&2
            echo "Full log saved to: $PWD/log.makeInstall" >&2
            exit 1
        fi

        set +o pipefail
        cd - > /dev/null || exit 1
        rm -rf build
        cd .. || exit 1
    fi
}
