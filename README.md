# CPSL

Manifest-built mini-OS capsules for agents.

Package tools, permissions, files, network access, and language adapters into explicit sandbox images. The same runtime contract can live in a CLI, server, app host, browser, or mobile shell.

CPSL is an early open-source runtime for building small sandbox images an agent can actually live inside. A capsule bundles a Luau VM, selected Rust modules, files, mounts, HTTP policy, and optional shell/Python shims behind one TOML manifest.

The workflow is intentionally Docker-shaped:

```text
cpsl build -> cpsl sandboxes -> cpsl run
```

The implementation is not Docker. A CPSL capsule is not OCI, not a Linux filesystem, and not kernel isolation. It is a compact Luau-backed runtime image with only the modules and host access you asked for.

CPSL started on May 4, 2026. The CLI, manifest format, module API, prebuilt capsule story, and registry shape are all still open. Patches welcome.

## Quick Start

Requires Rust and Cargo for now:

```sh
./build-cli.sh
./cpsl -- 'echo hello from CPSL'
./cpsl -i
```

Use `--python` or `--lua` when you want those modes:

```sh
./cpsl --python -- 'print("hello from python mode")'
./cpsl --lua -- 'print("hello from luau")'
```

Python mode is intentionally not CPython. It does not support `pip install`, arbitrary native packages, or the full CPython standard library. It is a lightweight compatibility layer for practical scripts.

## Build, List, Run

A capsule starts as TOML:

```toml
[sandbox]
name = "json-tool"

[modules]
fs = true
json = true

[python]
enabled = false
```

Build it, list it, and run it:

```sh
./cpsl build -t json-tool -f manifests/json-only.toml
./cpsl sandboxes
./cpsl run json-tool --lua -- 'print(json.encode({hello = "world"}))'
```

That manifest includes only filesystem and JSON support. Other modules stay out. HTTP, mounts, and Python support are explicit too.

HTTP is policy-gated:

```sh
./cpsl build -t web-tool -f manifests/full.toml
./cpsl run web-tool --allow-domain httpbin.org --lua -- 'local r = http.get("https://httpbin.org/get"); print(r.status)'
```

Included manifests:

- `manifests/json-only.toml` - filesystem and JSON
- `manifests/minimal.toml` - filesystem, JSON, and CSV
- `manifests/data-science.toml` - structured data, numerical computing, and plotting
- `manifests/full.toml` - broad CLI-registered module set with Python enabled
- `manifests/all.toml` - broad CLI-registered module set

List the built-in modules accepted by manifests:

```sh
./cpsl modules
```

## How Does It Work?

CPSL runs code inside [Luau](https://luau.org/), the open-source Lua-derived runtime maintained at [luau-lang/luau](https://github.com/luau-lang/luau).

Luau is the bet: small, fast, embeddable, and designed for [sandboxed VMs](https://luau.org/sandbox/). It is also [battle-tested at Roblox scale](https://luau.org/news/2022-11-04-luau-origins-and-evolution/): Luau powers user-generated content on Roblox, hundreds of thousands of developers write it every month, and Roblox app code written in Luau reaches tens of millions of people daily. CPSL adds its own mount table, module registry, HTTP policy, and host-resource gates around that VM.

Shell and Python modes are front doors. CPSL parses those inputs, lowers them into Luau, and runs them in the same sandbox instead of spawning a host shell or CPython.

### Python-on-Luau Can Win Sometimes

`./run_tests.sh` compares CPSL Python mode against `python3`, checks output equality, and reports startup, Python-to-Luau transpilation, Luau execution, and CPython `runpy` script time separately.

On one local Darwin arm64 run with Python 3.9.6 on May 6, 2026:

- 12/12 smoke tests matched CPython output.
- Luau VM execution was faster in 11/12 cases.
- Transpilation plus Luau execution was still faster in 9/12 cases.
- `math_heavy.py` was slower.

The smoke suite is the proof point, not a universal benchmark. Python-on-Luau can be faster for some scripts, which is enough to make the experiment interesting.

```sh
./run_tests.sh
```

## What CPSL Is Not

- Not Docker, OCI, or a Linux VM.
- Not kernel-level isolation.
- Not full Bash.
- Not CPython or `pip`.
- Not a package manager for arbitrary host dependencies.
- Not stable infrastructure yet.

## Early, Hackable, Help Wanted

CPSL is new; the repository started on May 4, 2026. The useful pieces today are:

- native Rust CLI
- Luau sandbox runtime
- manifest-selected built-in modules
- shell-style, Python-compatible, and Luau entry points
- browser-hosted WASM demo using the same manifest idea

Good places to help:

- stabilize the manifest schema and validation
- improve shell and Python compatibility
- add and test Rust modules exposed to Luau
- design external modules, e.g. `my-tool = { source = "github.com/org/cpsl-mod-tool" }`
- make prebuilt capsules so common builds do not require Rust locally
- keep the browser demo aligned with the native runtime

Later: a registry for prebuilt capsule images, similar in spirit to container registries but for CPSL capsules.

## Build From Source

```sh
git clone https://github.com/fundamental-research-labs/cpsl
cd cpsl
./build-cli.sh
./cpsl --help
```

For direct Cargo builds:

```sh
cargo build --release -p cpsl-cli
cargo build -p cpsl-cli --no-default-features --features mod-json,mod-fs
```

## Repository Layout

- `cli/` - command-line entry point
- `core/` - sandbox runtime and built-in modules
- `modules/` - native support crates used by CPSL modules
- `runtime/` - Luau runtimes for Python and shell compatibility
- `manifests/` - capsule manifests
- `web/` - browser demo and static site
- `docs/` - design notes
- `test/` - Python compatibility smoke tests

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for the local build, test, and contribution workflow.
