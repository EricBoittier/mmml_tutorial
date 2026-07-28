#!/usr/bin/env bash
# Docs §3c — validate train split schema.
set -euo pipefail
. ./shared.source

if [[ ! -f "$PHYSNET_TRAIN_NPZ" ]]; then
  echo "error: missing $PHYSNET_TRAIN_NPZ — run 05_fix_and_split.sh first" >&2
  exit 1
fi

echo "=== 06: validate ==="
mmml validate "$PHYSNET_TRAIN_NPZ" "$PHYSNET_VALID_NPZ" "$PHYSNET_TEST_NPZ"
