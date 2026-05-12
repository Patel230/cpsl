#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

cargo check --workspace --all-targets --all-features
