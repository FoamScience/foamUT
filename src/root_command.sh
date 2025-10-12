# Main command logic for foamUT
# Orchestrates the entire test execution pipeline

# ShellChecked on every push - Always ShellCheck your scripts!

# Validate custom test driver if provided
if [ -n "${args[--test-driver]}" ]; then
    driver_path="${args[--test-driver]}"
    if [ ! -f "$driver_path" ]; then
        echo "Error: Test driver file not found: $driver_path" >&2
        exit 1
    fi
    if [[ ! "$driver_path" =~ \.(C|cpp)$ ]]; then
        echo "Error: Test driver must be a .C or .cpp source file" >&2
        exit 1
    fi
fi

# Validate --force-timeout is only used with --test-prefix
if [ "${args[--force-timeout]}" = "1" ] && [ -z "${args[--test-prefix]}" ]; then
    echo "Warning: --force-timeout has no effect without --test-prefix" >&2
fi

# Validate --standalone is not used with --parallel
if [ "${args[--standalone]}" = "1" ] && [ "${args[--parallel]}" = "1" ]; then
    echo "Error: --standalone is not compatible with --parallel" >&2
    echo "Standalone mode only runs serial tests" >&2
    exit 1
fi

# Load helper functions
source "$root/src/lib/setup_test_symlinks.sh"
source "$root/src/lib/create_dummy_libs.sh"
source "$root/src/lib/compile_catch2.sh"
source "$root/src/lib/compile_test_drivers.sh"
source "$root/src/lib/run_serial_tests.sh"
source "$root/src/lib/run_parallel_tests.sh"
source "$root/src/lib/cleanup.sh"

# Parse flags from bashly (bashly uses "1" for true flags)
doSerial=true   # Default: serial only
doParallel=false
doReport=false
standalone_mode=false

# If --parallel flag is set, run parallel only (disable serial)
if [ "${args[--parallel]}" = "1" ]; then
    doSerial=false
    doParallel=true
fi

if [ "${args[--report]}" = "1" ]; then
    doReport=true
fi

if [ "${args[--standalone]}" = "1" ]; then
    standalone_mode=true
fi

set -e

# Get OpenFOAM version string
foamV=$(echo "${WM_PROJECT}$(test ! -z "${WM_FORK}" && echo '-'"${WM_FORK}")-${WM_PROJECT_VERSION}")

# Collect catch2 arguments from catch_all
args_array=()
if [ -n "${other_args[*]}" ]; then
    args_array=("${other_args[@]}")
fi

# Setup test symlinks if FOAM_FOAMUT_TESTS is set
setup_test_symlinks

# Create dummy libraries if needed
create_dummy_libs

# libraries to test
libs=$(find -L tests/ -maxdepth 1 -mindepth 1 -type d)
libs_array=($libs)

# where to run OpenFOAM cases
caseRun=/tmp/foamUtCases
mkdir -p "$caseRun"

# a timeout to prevent hanging processes (be CI friendly)
timeOut="${CATCH_TIMEOUT:-60}"

# Compile Catch2
compile_catch2

# Compile test drivers
compile_test_drivers

# Go back to the root of the repository
cd "$root"

# Get setup to run tests
mapfile -t cases_array < <(find -L cases/ -maxdepth 1 -mindepth 1 -type d)

# Build list of case names for tag filtering
case_names=()
for case_dir in "${cases_array[@]}"; do
    case_names+=("$(basename "$case_dir")")
done

if [ "$standalone_mode" = "true" ]; then
    echo "Running in standalone mode (no OpenFOAM cases)..." >&2
    echo "Will exclude tests tagged with: ${case_names[*]}" >&2
    # Create a dummy case array with one entry for the loop structure
    cases_array=("standalone")
else
    if [ ${#cases_array[@]} -eq 0 ]; then
        echo "No cases found to run tests"
        exit 1
    fi
fi

mkdir -p "$root"/reports

# Run the tests, but do not exit until attempting everything
set +e
err=0

for ((k = 0; k < ${#cases_array[@]}; k++)); do
    if [ "$standalone_mode" = "true" ]; then
        caseName="standalone"
        casePath=""
        echo "Running standalone tests (no case)..." >&2
    else
        ofCase="${cases_array[k]}"
        caseName=$(basename "$ofCase")
        casePath=$caseRun/$caseName
        cp -rL "$ofCase" "$casePath"
    fi

    case $doSerial in
        (true) run_serial_tests "$err" "$caseName" "$casePath" "$libs" "${args_array[@]}";;
    esac

    case $doParallel in
        (true) run_parallel_tests "$err" "$caseName" "$casePath" "$libs" "${args_array[@]}";;
    esac

    # separator in case json reporter is used
    for element in "${args_array[@]}"; do
        if [ "$element" == "json" ]; then
            if ((k != ${#cases_array[@]} - 1)); then
                printf ","
            fi
        fi
    done

    # Cleanup case directory if not in standalone mode
    if [ "$standalone_mode" != "true" ]; then
        rm -rf "$casePath"
    fi
done

# Cleanup
cleanup

exit $err
