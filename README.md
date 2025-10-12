# A unit/integration testing framework for OpenFOAM code

> This offering is not approved or endorsed by OpenCFD Limited,
> the producer of the OpenFOAM software and owner of the OPENFOAM® and OpenCFD® trade marks.

> [!IMPORTANT]
> There have been breaking changes on the CLI interface from **v2.0.0**:
> - `foamut` is now the main command (built with [bashly](https://bashly.dannyb.co/))
> - `Alltest` remains available as a symlink for backward compatibility
> - **New default behavior**: Serial tests only (use `--parallel` for parallel-only execution)
> - **New features**:
>   - `--standalone`: Run tests without OpenFOAM cases (mode-agnostic and serial tests)
>   - `--test-driver <path>`: Use custom testDriver.C source file
>   - `--test-prefix <cmd>`: Prefix test execution with debuggers/profilers (e.g., `gdb --args`, `valgrind`)
>   - `--report`: Generate JSON test reports in `reports/` directory
>   - `--force-timeout`: Keep timeout even when using `--test-prefix`
> - All Catch2 arguments can be passed directly (no special separator needed)
>
> If you need the old behavior, use tag **v1.0.0**

This is a unit/integration testing framework to help test-proof new OpenFOAM code
(might be too late for the OpenFOAM library itself). This repository will always work with the
latest versions of the main three OpenFOAM forks: [ESI OpenCFD's](https://openfoam.com),
[Foundation version](https://openfoam.org) and
[Foam-Extend](https://sourceforge.net/projects/foam-extend/files/).

<!-- mtoc-start:cb9ef56 -->

* [A quick demo](#a-quick-demo)
* [How to use this repo](#how-to-use-this-repo)
* [Usage](#usage)
* [Migration from v1.0.0](#migration-from-v100)
  * [Command Changes](#command-changes)
  * [Behavior Changes](#behavior-changes)
  * [New Capabilities](#new-capabilities)
  * [CI/Automation](#ciautomation)
* [Documentation](#documentation)
* [Contributing](#contributing)

<!-- mtoc-end:cb9ef56 -->

If you intend to write cross-forks code, this can help you maintain your sanity. You can
just keep branches for each fork on your code's repository and invoke CI on them with the
help of this testing framework.

## A quick demo

![OpenFOAM unit testing in action](demo.gif)

## How to use this repo

The `foamut` command orchestrates the entire test pipeline:
1. Compiles [Catch2](https://github.com/catchorg/Catch2) v3 (if needed)
2. Compiles test drivers for each test library under [tests](tests)
3. Runs tests on [OpenFOAM cases](cases) in serial (default) or parallel (`--parallel`)
4. Supports standalone mode (`--standalone`) for tests that don't require OpenFOAM cases

You can use this framework without including it in your codebase:

1. **Write your tests** following the [Catch2 v3](https://github.com/catchorg/Catch2) framework
   - Ship tests with their own `Make` directory (see [example tests](tests/exampleTests))
   - Tag tests appropriately: `[serial]`, `[parallel]`, and case-specific tags like `[cavity]`

2. **Setup foamUT** in your environment:
   ```bash
   git clone https://github.com/FoamScience/foamUT.git
   export FOAM_FOAMUT=/path/to/foamUT
   ```

3. **Link your tests** using one of these methods:
   - **Symlink** your tests under `tests/`:
     ```bash
     ln -s /path/to/your/tests/myLibTests $FOAM_FOAMUT/tests/myLibTests
     ```
   - **Environment variable** (recommended for CI):
     ```bash
     export FOAM_FOAMUT_TESTS=/path/to/your/tests
     ```

4. **Provide OpenFOAM cases** (optional, skip if using `--standalone`, or
   if the default cavity case is enough):
   - Symlink or copy your cases to `cases/`
   - Cases must include `system/controlDict` (and `system/decomposeParDict` for parallel)

5. **Run tests**:
   ```bash
   # Source OpenFOAM environment first
   source /path/to/OpenFOAM/etc/bashrc

   # Run serial tests (default)
   ./foamut

   # Run parallel tests only
   ./foamut --parallel

   # Run standalone tests (no OpenFOAM cases needed)
   ./foamut --standalone

   # Debug a specific test
   ./foamut --test-prefix "gdb --args" "[mytest]"

   # Generate JSON reports
   ./foamut --report
   ```

## Usage

Run `./foamut --help` to see all available options. `foamut -- -h` to see all
Catch2 options.

## Migration from v1.0.0

If you're upgrading from v1.0.0, here are the key changes:

### Command Changes
| v1.0.0 | v2.0.0 | Notes |
|--------|--------|-------|
| `./Alltest` | `./foamut` | `Alltest` still works (symlink) |
| `./Alltest` (both modes) | `./foamut` (serial only) | Use `--parallel` for parallel tests |
| N/A | `./foamut --standalone` | New: Run tests without cases |

### Behavior Changes
- **Default**: v1.0.0 ran both serial and parallel tests; v2.0.0 runs **serial only** by default
- **Parallel mode**: Use `--parallel` flag explicitly to run parallel tests
- **Catch2 args**: No longer need special handling, pass directly (e.g., `./foamut "[mytag]"`)

### New Capabilities
```bash
# Debug failing tests
./foamut --test-prefix "gdb --args" "[failing-test]"

# Profile test performance
./foamut --test-prefix "valgrind --tool=callgrind"

# Use custom test driver
./foamut --test-driver /path/to/myTestDriver.C

# Run unit tests without OpenFOAM cases
./foamut --standalone
```

### CI/Automation
If you have CI pipelines using v1.0.0:
```bash
# Old way (v1.0.0)
./Alltest

# New way (v2.0.0) - for same behavior, run both:
./foamut              # Serial tests
./foamut --parallel   # Parallel tests
./Alltest             # This is just a symlink for ./foamut
```

## Documentation

Head to the [wiki](https://github.com/FoamScience/foamUT/wiki)
to read few more words about this framework. There is also a FAQ there.

## Contributing

Ease of use and portability across OpenFOAM forks are the main focus of this framework.
As long as your contribution doesn't hinder one of those two objectives; it will be welcomed!
And PRs against master are the way to go.
