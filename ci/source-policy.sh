#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

cargo run -p ci-check -- all \
  --max-file-lines 2000 \
  --max-function-lines 500 \
  --min-doc-chars 20 \
  --max-doc-chars 700 \
  "${SOURCE_PATHS[@]}"
