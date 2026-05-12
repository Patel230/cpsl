#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

./ci/fmt.sh
./ci/cargo-check.sh
./ci/clippy.sh
./ci/test.sh
./ci/build-cli.sh
./ci/source-policy.sh
./ci/audit.sh
