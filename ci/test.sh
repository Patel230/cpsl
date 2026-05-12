#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

cargo test --workspace --all-features
