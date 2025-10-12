#!/usr/bin/bash

# Run parallel tests for all libraries on a specific case
# Arguments: $1=error_count, $2=case_name, $3=case_path, $4=libs, $@=additional args

run_parallel_tests() {
    if [ "$standalone_mode" = "true" ]; then
        echo "Skipping decomposePar for standalone mode..." >&2
    else
        if ! test -f "${3}/system/decomposeParDict" ; then
            rm -rf "${3}/processor*"
            echo "decomposeParDict not found, not running parallel tests on this case..." >&2
            return 0
        fi
    fi

    local fargs=("$@")
    local params=()
    local skip_next=false

    # Filter out foamUT-specific flags from params
    for ((i = 4; i <= $#; i++)); do
        arg="${fargs[i]}"

        if [ "$skip_next" = true ]; then
            skip_next=false
            continue
        fi

        case "$arg" in
            --parallel|--report|--standalone|--force-timeout)
                # These flags don't take arguments
                ;;
            --test-driver|--test-prefix)
                # These flags take an argument, skip the next one too
                skip_next=true
                ;;
            *)
                params+=("$arg")
                ;;
        esac
    done

    local test_prefix="${args[--test-prefix]}"
    local force_timeout="${args[--force-timeout]}"

    # Decompose case if not in standalone mode
    if [ "$standalone_mode" != "true" ]; then
        local nProcs=$(grep -oP "numberOfSubdomains\s+\K\d+" "${3}"/system/decomposeParDict)
        decomposePar -force -case "${3}" > "${3}/log.decomposePar"
        err=$((err + $?))
    else
        # In standalone mode, default to 2 processors or read from FOAM_FOAMUT_NPROCS
        local nProcs="${FOAM_FOAMUT_NPROCS:-2}"
    fi

    # run the case in parallel mode
    report=""
    case $doReport in
        (true) report="-s -r json -d yes";;
    esac

    for ((i = 0; i < ${#libs_array[@]}; i++)); do
        lib="${libs_array[i]}"
        printf "\n\nRunning tests for lib %s, on %s case in parallel...\n" "$lib" "${2}" >&2
        libName=$(basename "$lib")
        logdir="reports/${libName}_${2}_parallel"
        logparams=""
        direct=""
        case $doReport in
            (true) logparams="-output-filename $logdir"
                direct="> /dev/null"
                echo "Parallel Reports (${nProcs}): ${logdir}" >&2
        esac

        # Execute the test
        if [ "$standalone_mode" = "true" ]; then
            # Standalone mode: no case argument, exclude all case-tagged tests
            # Build exclusion filter: [parallel]~[case1]~[case2]...
            local tag_filter="[parallel]"
            for case_name in "${case_names[@]}"; do
                tag_filter="${tag_filter}~[${case_name}]"
            done

            # Build and execute command with or without timeout and prefix
            # Prefix comes AFTER mpirun in parallel mode
            if [ -z "$test_prefix" ]; then
                timeout "$timeOut" mpirun $logparams -np "$nProcs" "$root"/"$lib"/testDriver \
                    --allow-running-no-tests \
                    -n "$(basename "$lib")" $report \
                    --rng-seed time "$tag_filter" ${params[@]} --- -parallel $direct
            else
                if [ "$force_timeout" = "1" ]; then
                    timeout "$timeOut" mpirun $logparams -np "$nProcs" $test_prefix "$root"/"$lib"/testDriver \
                        --allow-running-no-tests \
                        -n "$(basename "$lib")" $report \
                        --rng-seed time "$tag_filter" ${params[@]} --- -parallel $direct
                else
                    mpirun $logparams -np "$nProcs" $test_prefix "$root"/"$lib"/testDriver \
                        --allow-running-no-tests \
                        -n "$(basename "$lib")" $report \
                        --rng-seed time "$tag_filter" ${params[@]} --- -parallel $direct
                fi
            fi
        else
            # Normal mode: with case argument and -parallel flag
            if [ -z "$test_prefix" ]; then
                timeout "$timeOut" mpirun $logparams -np "$nProcs" "$root"/"$lib"/testDriver \
                    --allow-running-no-tests \
                    -n "$(basename "$lib")" $report \
                    --rng-seed time "[parallel][${2}]" ${params[@]} --- -parallel -case "${3}" $direct
            else
                if [ "$force_timeout" = "1" ]; then
                    timeout "$timeOut" mpirun $logparams -np "$nProcs" $test_prefix "$root"/"$lib"/testDriver \
                        --allow-running-no-tests \
                        -n "$(basename "$lib")" $report \
                        --rng-seed time "[parallel][${2}]" ${params[@]} --- -parallel -case "${3}" $direct
                else
                    mpirun $logparams -np "$nProcs" $test_prefix "$root"/"$lib"/testDriver \
                        --allow-running-no-tests \
                        -n "$(basename "$lib")" $report \
                        --rng-seed time "[parallel][${2}]" ${params[@]} --- -parallel -case "${3}" $direct
                fi
            fi
        fi

        set +x
        # separator in case json reporter is used
        for element in "${params[@]}"; do
            if [ "$element" == "json" ]; then
                if ((i != ${#libs_array[@]} - 1)); then
                    printf ","
                fi
            fi
        done
        err=$((err + lerr))
    done
}
