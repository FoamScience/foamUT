#!/usr/bin/bash

# Run serial tests for all libraries on a specific case
# Arguments: $1=error_count, $2=case_name, $3=case_path, $4=libs, $@=additional args

run_serial_tests() {
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
            --test-driver|--test-prefix|--case)
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

    for ((i = 0; i < ${#libs_array[@]}; i++)); do
        lib="${libs_array[i]}"
        printf "\n\nRunning tests for lib %s, on %s case in serial...\n" "$lib" "${2}" >&2
        libName=$(basename "$lib")
        report=""
        case $doReport in
            (true) report="-s -r json::out=${root}/reports/${libName}_${2}_serial.json -d yes"
            echo "Report: ${root}/reports/${libName}_${2}_serial.json" >&2
            ;;
        esac

        # Execute the test
        if [ "$standalone_mode" = "true" ]; then
            # Standalone mode: no case argument, exclude all case-tagged tests
            # Run tests that are:
            #   - ([serial] AND not-case-tagged) OR (not-[parallel] AND not-case-tagged)
            # This includes: [serial] tests, and tests with neither [serial] nor [parallel]
            local tag_filter="[serial]"
            for case_name in "${case_names[@]}"; do
                tag_filter="${tag_filter}~[${case_name}]"
            done
            tag_filter="${tag_filter},~[parallel]"
            for case_name in "${case_names[@]}"; do
                tag_filter="${tag_filter}~[${case_name}]"
            done

            # Build and execute command with or without timeout and prefix
            if [ -z "$test_prefix" ]; then
                timeout "$timeOut" "$root"/"$lib"/testDriver --allow-running-no-tests \
                    -n "$(basename "$lib")" $report "$tag_filter" "${params[@]}"
            else
                if [ "$force_timeout" = "1" ]; then
                    timeout "$timeOut" $test_prefix "$root"/"$lib"/testDriver --allow-running-no-tests \
                        -n "$(basename "$lib")" $report "$tag_filter" "${params[@]}"
                else
                    $test_prefix "$root"/"$lib"/testDriver --allow-running-no-tests \
                        -n "$(basename "$lib")" $report "$tag_filter" "${params[@]}"
                fi
            fi
        else
            # Normal mode: with case argument
            if [ -z "$test_prefix" ]; then
                timeout "$timeOut" "$root"/"$lib"/testDriver --allow-running-no-tests \
                    -n "$(basename "$lib")" $report "[serial][${2}]" "${params[@]}" \
                    --- -case "${3}"
            else
                if [ "$force_timeout" = "1" ]; then
                    timeout "$timeOut" $test_prefix "$root"/"$lib"/testDriver --allow-running-no-tests \
                        -n "$(basename "$lib")" $report "[serial][${2}]" "${params[@]}" \
                        --- -case "${3}"
                else
                    $test_prefix "$root"/"$lib"/testDriver --allow-running-no-tests \
                        -n "$(basename "$lib")" $report "[serial][${2}]" "${params[@]}" \
                        --- -case "${3}"
                fi
            fi
        fi

        locErr=$?
        err=$((err+locErr))

        # separator in case json reporter is used
        for element in "${params[@]}"; do
            if [ "$element" == "json" ]; then
                if ((i != ${#libs_array[@]})); then
                    printf ","
                fi
            fi
        done
    done
}
