# CPSL

Safe mini-OS "capsules" for agents that can run everywhere: Linux, macOS, Windows, web browsers, iOS, Android...

Package tools, files, and permissions. Build. Run.

Agents and humans can interact with CPSL using Bash, Python, or Lua/Luau.

Try a WASM CPSL capsule in the browser at [cpsl.io](https://cpsl.io/).

CPSL is an early open-source runtime for building small sandbox capsules an agent can actually live inside. A capsule is described by a TOML manifest and runs inside a Luau VM with selected Rust capabilities exposed to it.

The CLI loop is short:

```text
cpsl build -> cpsl ls -> cpsl run
```

CPSL is not Docker. It is not a Linux distribution, not a container image, and not CPython. It is Unix-like enough for agents, with explicit modules, files, mounts, and network rules.

## Early and Hackable

CPSL was open-sourced on May 4, 2026. It is already used in some [Fundamental Research Labs](https://fundamentalresearchlabs.com) products, but the public project is still young: install targets, module boundaries, SDK builds, and demos are still being shaped.

This is a good time to contribute to the runtime, CLI, manifests, web demo, SDK targets, and agent workflows.

## Quick Start

Requires Rust and Cargo for now. Installers are coming soon.

```sh
# Download the source tree.
git clone https://github.com/fundamental-research-labs/cpsl

# Enter the checkout.
cd cpsl

# Build the repo-local CPSL CLI at ./cpsl.
./build-cli.sh

# Run one command through the default Bash-compatible interface.
./cpsl -- 'echo hello from CPSL'

# Start an interactive CPSL shell.
./cpsl -i
```

`./build-cli.sh` builds the CLI, not a capsule. A capsule is built from a TOML manifest:

```sh
# Build the json-only capsule from an included manifest.
./cpsl build -f manifests/json-only.toml

# List capsules built on this machine.
./cpsl ls

# Run Luau code inside the json-only capsule.
./cpsl run json-only --lua -- 'print(json.encode({hello = "world"}))'
```

Use `--python` or `--lua` when you want to use those language interfaces:

```sh
./cpsl --python -- 'print("hello from python mode")'
./cpsl --lua -- 'print("hello from luau")'
```

Default mode is Bash-compatible. `--lua` executes Luau directly. `--python` transpiles Python syntax to Luau; it does not invoke CPython and does not require Python to be installed.

### Custom Capsule

A capsule starts as TOML. Name it, pick modules, and pin network domains:

```toml
[sandbox]
name = "browser-agent"

[modules]
fs = true
json = true
http = true

[http]
allowed_domains = ["httpbin.org"]
```

Save that as `browser-agent.toml`, then build and run it:

```sh
./cpsl build -f browser-agent.toml
./cpsl run browser-agent --lua -- 'print(json.encode({status = "ready"}))'
```

Useful included manifests:

- `manifests/json-only.toml` - filesystem and JSON
- `manifests/minimal.toml` - filesystem, JSON, and CSV
- `manifests/data-science.toml` - structured data, numerical computing, and plotting
- `manifests/full.toml` - broad CLI-registered module set
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

### Composable Modules

File system, networking, JSON, compression, custom modules... If you just need JSON and HTTP with one allowed domain, stick to the bare minimum.

### Communication

Agents and humans can interact with CPSL using Bash, Python, or Lua/Luau. A Luau runtime runs under the hood; Bash and Python are transpiled.

### Python-on-Luau

Python mode is intentionally not CPython. It does not support `pip install`, arbitrary native packages, or the full CPython standard library. It is a lightweight compatibility layer for practical scripts.

<details>
<summary>Python-on-Luau benchmark notes</summary>

These local comparison runs use `./bench-python-luau.sh`, which is optional and requires `python3`. Python is not required to build CPSL or run CPSL Python mode.

| Test | CPSL total ms | CPython total ms |
|------|---------------|------------------|
| `comprehensive` | 16.87 | 24.73 |
| `control_flow` | 14.59 | 21.52 |
| `dict_ops` | 15.74 | 22.03 |
| `fibonacci` | 14.70 | 24.45 |
| `functional` | 15.60 | 22.12 |
| `hello` | 15.74 | 22.05 |
| `imports` | 16.17 | 23.12 |
| `list_ops` | 16.84 | 22.06 |
| `math_heavy` | 22.87 | 25.09 |
| `patterns` | 17.90 | 22.41 |
| `sorting` | 28.18 | 23.75 |
| `string_ops` | 18.63 | 23.19 |

```sh
./bench-python-luau.sh
```

</details>

## Roadmap

| Area | Next milestone | Tracking |
|------|----------------|----------|
| SDK targets | Build manifest-aware SDKs for iOS, macOS, Windows, Android, and Linux, starting with generated C headers. SDK artifacts should be built on demand by `cpsl` from manifest features, not published as version-tag artifacts. | [#9](https://github.com/fundamental-research-labs/cpsl/issues/9) |
| Detached sessions | Add `cpsl run -d` and `cpsl --exec` entry points for long-lived CPSL sessions while leaving the implementation architecture open. | [#10](https://github.com/fundamental-research-labs/cpsl/issues/10) |
| CLI release artifacts | Publish `cpsl` CLI binaries for macOS, Windows, and Linux when tagging a version. | [#11](https://github.com/fundamental-research-labs/cpsl/issues/11) |
| Capsule module contracts | Define the external capsule-module contract, including module metadata, source pinning, compatibility checks, and build boundaries so community modules can live in separate repositories. Distinct from CPSL Hub: this is the source/build contract; Hub is artifact distribution and discovery. | [#18](https://github.com/fundamental-research-labs/cpsl/issues/18) |
| CPSL Hub | Design the push and pull workflow for pre-built capsules, including metadata, compatibility checks, and provenance. | [#12](https://github.com/fundamental-research-labs/cpsl/issues/12) |
| Agent sandbox demo | Add a reproducible demo of an agent using a CPSL capsule with explicit files, modules, network rules, and output artifacts. | [#13](https://github.com/fundamental-research-labs/cpsl/issues/13) |

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for the local build, test, and contribution workflow.
