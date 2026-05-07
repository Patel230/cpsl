# CPSL

Safe mini-OS "capsules" for agents that can run everywhere: Linux, macOS, Windows, web browsers, iOS, Android...

Package tools, files, and permissions. Build. Run.

Agents can communicate with CPSL using Bash, Python, or Lua/Luau, and so can you.

CPSL is an early open-source runtime for building small sandbox images an agent can actually live inside. A capsule is described by a TOML manifest and runs inside a Luau VM with selected Rust capabilities exposed to it.

The workflow is intentionally Docker-shaped:

```text
cpsl build -> cpsl ls -> cpsl run
```

CPSL is not Docker. It is not a Linux distribution, not a container image, and not CPython. It is Unix-like enough for agents, with explicit modules, files, mounts, and network rules.

## Quick Start

Requires Rust and Cargo for now. Installers are coming soon.

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

## Describe, Build, Run

A capsule starts as TOML. Name your sandbox, pick modules, and pin network domains. Then use the CPSL CLI to build and run. File mounts and allowed domains can be edited while the capsule is running.

Save this as `browser-agent.toml`:

```toml
[sandbox]
name = "browser-agent"

[modules]
fs = true
json = true
http = true

[python]
enabled = true

[http]
allowed_domains = ["httpbin.org"]
```

Build it:

```sh
./cpsl build -t browser-agent -f browser-agent.toml
```

List it:

```sh
./cpsl ls
```

Run it:

```sh
./cpsl run browser-agent --python -- 'print("hello from inside")'
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

CPSL is a Luau VM that exposes Rust crate assemblies.

### Luau VM

[Luau](https://github.com/luau-lang/luau) is a small, fast, embeddable programming language based on Lua with a gradual type system. It was built and open-sourced by [Roblox](https://luau.org/news/2022-11-04-luau-origins-and-evolution/) and is battle-tested by millions of users.

Luau is a good fit for CPSL because it is designed for [sandboxed VMs](https://luau.org/sandbox/). CPSL adds its own mount table, module registry, HTTP policy, and host-resource gates around that VM.

### Composable

File system, networking, JSON, compression, custom modules... If you just need JSON and HTTP with one allowed domain, then stick to the bare minimum.

### Communication

Agents and humans can interact with CPSL using Bash, Python, or Lua/Luau. A Luau runtime runs under the hood; Bash and Python are transpiled.

## Python-on-Luau

Python code can run faster when transpiled into Luau, even including transpilation time.

[`bench-python-luau.sh`](bench-python-luau.sh) compares CPSL Python mode against `python3`, checks output equality, and reports startup, Python-to-Luau transpilation, Luau execution, and CPython `runpy` script time separately.

On one local Darwin arm64 run with Python 3.9.6 on May 6, 2026:

- 12/12 smoke tests matched CPython output.
- Luau VM execution was faster in 11/12 cases.
- Transpilation plus Luau execution was still faster in 9/12 cases.
- `math_heavy.py` was slower.

This is not a universal Python benchmark. It is a useful proof point.

```sh
./bench-python-luau.sh
```

## What CPSL Is Not

### Not Linux

It looks and feels like Unix: programs, everything is a file, the FS tree is rooted at `/`, and there is a sh/bash-compatible shell, etc. What's important is that it's Unix-like enough for agents.

### Not Docker/OCI

No daemon. Not a Linux distribution. Not a container image.

### Not CPython

Though CPSL can run Python code, it does not carry the actual Python tooling. No `pip install`.

## Build From Source

Installers are coming soon.

```sh
git clone https://github.com/fundamental-research-labs/cpsl
cd cpsl
./build-cli.sh
./cpsl -i
```

For direct Cargo builds:

```sh
cargo build --release -p cpsl-cli
cargo build -p cpsl-cli --no-default-features --features mod-json,mod-fs
```

## Early and Hackable

CPSL was open-sourced on May 4, 2026. It's already used in production in some [Fundamental Research Labs](https://fundamentalresearchlabs.com) products. It's an extremely powerful piece of tech, but it is not yet perfectly modular; not all build targets are clearly exposed, etc.

It's the right time to join as a contributor and help us design the perfect isolated, versatile operating system for AI agents.

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
