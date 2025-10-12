#!/usr/bin/bash

# Bashly initialization hook - runs before command execution
# Validates environment and performs sanity checks

# Check if OpenFOAM is sourced
if [ -z "${FOAM_LIBBIN}" ]; then
    echo "Error: Please source an OpenFOAM version. Aborting..." >&2
    echo "USAGE: ./foamut [OPTIONS] [CATCH2_ARGS...]" >&2
    exit 1
fi

# Set root directory as the repository root
root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export FOAM_FOAMUT="$root"
