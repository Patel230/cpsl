# CPSL Web Site

This directory contains the GitHub Pages site and the browser-hosted CPSL demo.

The demo runs CPSL in a Web Worker. The worker loads an Emscripten-built WASM
bundle from `web/dist/assets/wasm/` and calls the Rust C ABI exposed by
`web/cpsl-web`.

## Build

```sh
./web/build.sh
```

Requirements:

- Rust target: `wasm32-unknown-emscripten`
- Emscripten `emcc` from SDK 5.0.7 or newer

If a repo-local `emsdk/emsdk_env.sh` exists, `build.sh` sources it automatically.
Otherwise install and activate Emscripten from the repo root:

```sh
git clone https://github.com/emscripten-core/emsdk.git
./emsdk/emsdk install 5.0.7
./emsdk/emsdk activate 5.0.7
```

For static layout checks without building the WASM bundle:

```sh
CPSL_SKIP_WASM=1 ./web/build.sh
```

## Serve Locally

```sh
./web/server.sh
```

By default this serves `web/dist` at <http://127.0.0.1:8000>. Override the host
or port with `HOST` and `PORT`:

```sh
PORT=9000 ./web/server.sh
```

## Deploy

The workflow in `.github/workflows/pages.yml` builds `web/dist` and deploys it
with GitHub Pages. In the repository settings, set Pages source to GitHub
Actions. Custom domains can be configured later in the Pages settings.
