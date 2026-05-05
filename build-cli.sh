#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*)
    EXE_SUFFIX=".exe"
    ;;
  *)
    EXE_SUFFIX=""
    ;;
esac

cargo build --release -p cpsl-cli --manifest-path "$ROOT_DIR/Cargo.toml"

cp "$ROOT_DIR/target/release/cpsl-cli${EXE_SUFFIX}" "$ROOT_DIR/cpsl${EXE_SUFFIX}"
chmod +x "$ROOT_DIR/cpsl${EXE_SUFFIX}"

echo "Built $ROOT_DIR/cpsl${EXE_SUFFIX}"
