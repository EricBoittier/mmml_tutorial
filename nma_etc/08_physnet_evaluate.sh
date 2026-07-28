#!/usr/bin/env bash
# Docs §5 — evaluate PhysNet on the held-out test split.
set -euo pipefail
. ./shared.source

CKPT="$(resolve_checkpoint || true)"
if [[ -z "$CKPT" ]]; then
  if [[ -f out/last_physnet_checkpoint.txt ]]; then
    CKPT="$(cat out/last_physnet_checkpoint.txt)"
  fi
fi
if [[ -z "$CKPT" || ! -e "$CKPT" ]]; then
  echo "error: no checkpoint — set PHYSNET_CHECKPOINT or run 07_physnet_train.sh" >&2
  exit 1
fi
if [[ ! -f "$PHYSNET_TEST_NPZ" ]]; then
  echo "error: missing $PHYSNET_TEST_NPZ — run 05_fix_and_split.sh first" >&2
  exit 1
fi

echo "=== 08: physnet-evaluate ==="
echo "Checkpoint: $CKPT"
mmml physnet-evaluate \
  --checkpoint "$CKPT" \
  --data "$PHYSNET_TEST_NPZ" \
  --natoms "$PAD_NATOMS" \
  --plots \
  -o "$EVAL_OUT"

echo "Metrics: $EVAL_OUT/metrics.json (and plots if written)"
