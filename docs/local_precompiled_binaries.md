# Local Precompiled Binaries

In addition to downloading binaries from GitHub releases, Cargokit supports using
precompiled binaries that are stored locally, for example bundled within the
plugin itself.

This is useful for development or when you want to avoid external network
dependencies during the build process, while still reducing the friction for
developers who don't have a Rust toolchain installed.

This is how the process looks from the perspective of the build:

1. Cargokit checks if there is `cargokit_options.yaml` file in the root folder of the target application. It checks for the `use_local_precompiled_binaries` option. If set to `true`, Cargokit will attempt to use local binaries.

2. Cargokit checks if there is `cargokit.yaml` file in the Rust crate and looks for the `local_precompiled_binaries` section to find the path where the binaries are stored.

3. Cargokit looks for the required binaries in the specified local directory using the structure `localPrecompiledDir/$target/$artifactName`.

4. If the binaries are found, they are used directly from that location. Otherwise, Cargokit will attempt to build from source (or fall back to remote precompiled binaries if configured).

## Configuring Local Precompiled Binaries

### Provide a `cargokit.yaml` file in the Rust crate

The file must be placed alongside `Cargo.toml`.

```yaml
local_precompiled_binaries:
  # Path to the directory containing precompiled binaries.
  # Can be relative to this file or absolute.
  path: precompiled
```

### Enable local binaries in `cargokit_options.yaml`

The application consuming the plugin must opt-in to using local precompiled binaries.

```yaml
# Enables use of local precompiled binaries.
use_local_precompiled_binaries: true
```

## Providing local precompiled binaries

You can generate the local binaries manually or using a CI workflow.

### Manually using `build_tool`:

```bash
cd cargokit/build_tool
dart run build_tool precompile-local-binaries \
  --manifest-dir=path/to/crate \
  --local-precompiled-dir=path/to/destination
```

The `--local-precompiled-dir` is optional. If omitted, it will use the path from `cargokit.yaml` or default to a `precompiled/` directory next to `Cargo.toml`.

### Configure a GitHub Action to build local binaries

The following example workflow shows how to build binaries for multiple targets and upload them as a GitHub artifact.

```yaml
name: Precompile Rust

on:
  workflow_dispatch:

jobs:
  rust-precompile:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4

      - uses: dart-lang/setup-dart@v1

      - name: Precompile binaries
        run: |
          dart run build_tool precompile-local-binaries \
            --manifest-dir ${{ github.workspace }}/rust/ \
            --local-precompiled-dir ${{ github.workspace }}/artifacts/ \
            --android-sdk-location "$ANDROID_HOME" \
            --android-ndk-version 28.2.13676358 \
            --android-min-sdk-version 24
        working-directory: rust_builder/cargokit/build_tool

      - name: Upload precompiled binaries
        uses: actions/upload-artifact@v4
        with:
          name: rust-precompiled
          path: artifacts/
```

By default, the `precompile-local-binaries` command builds binaries for all targets buildable from the current host. You can use the `--target <rust-triple>` argument to specify particular targets.
