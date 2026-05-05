# CPSL

CPSL is a cross-platform sandboxed runtime for agent workloads. It gives agents a constrained execution surface with built-in modules for files, structured data, HTTP, documents, plotting, and other practical tasks, while keeping module access explicit through sandbox image manifests.

Agents can interact with CPSL through:

- Bash-style shell commands
- A Python subset
- Raw Lua/Luau

The Python mode is intentionally not a complete Python runtime. It does not support `pip install`, arbitrary native packages, or the full CPython standard library; it is a lightweight compatibility layer for common agent scripts.

## Build the CLI

Requires Rust and Cargo.

```sh
./build-cli.sh
./cpsl --help
```

## Run Commands

Bash is the default mode, including in the interactive REPL:

```sh
./cpsl -- 'echo hello from CPSL'
./cpsl -i
```

Use `--python` or `--lua` when you want those modes:

```sh
./cpsl --python -- 'print("hello from python mode")'
./cpsl --lua -- 'print("hello from luau")'
```

## Build a Sandbox Image

Sandbox image manifests live in `manifests/`. Build one into a named sandbox, then run it:

```sh
./cpsl build -t json-tool -f manifests/json-only.toml
./cpsl run json-tool --lua -- 'print(json.encode({hello = "world"}))'
```

HTTP access is policy-gated. Build a sandbox with the HTTP module, then allow the domains it may reach at run time:

```sh
./cpsl build -t web-tool -f manifests/full.toml
./cpsl run web-tool --allow-domain httpbin.org --lua -- 'local r = http.get("https://httpbin.org/get"); print(r.status)'
```

Other ready-to-use manifests:

- `manifests/minimal.toml` - filesystem, JSON, and CSV
- `manifests/data-science.toml` - structured data, numerical computing, and plotting
- `manifests/full.toml` - all broadly registered modules
- `manifests/all.toml` - all core manifest modules

## Repository Layout

- `cli/` - the `cpsl-cli` package and command-line entry point
- `core/` - the `cpsl-core` sandbox runtime and built-in modules
- `modules/` - native support crates used by CPSL modules
- `runtime/` - Luau runtimes for Python and shell compatibility
- `manifests/` - sandbox image manifests
- `docs/` - design and architecture notes
