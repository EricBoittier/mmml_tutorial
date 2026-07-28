#!/usr/bin/env bash
# Docs §4 — PhysNet E/F(/D) training on ACEM+FORM splits.
# Requires: 05_fix_and_split.sh. Override PHYSNET_EPOCHS for a longer run.
set -euo pipefail
. ./shared.source

if [[ ! -f "$PHYSNET_TRAIN_NPZ" ]]; then
  echo "error: missing $PHYSNET_TRAIN_NPZ — run 05_fix_and_split.sh first" >&2
  exit 1
fi

CFG="$HERE/configs/train.yaml"
mkdir -p "$PHYSNET_CKPT_DIR"

echo "=== 07: physnet-train → $PHYSNET_CKPT_DIR (tag=$PHYSNET_TAG) ==="
mmml physnet-train \
  --config "$CFG" \
  --data "$PHYSNET_TRAIN_NPZ" \
  --valid-data "$PHYSNET_VALID_NPZ" \
  --ckpt-dir "$PHYSNET_CKPT_DIR" \
  --tag "$PHYSNET_TAG" \
  --num-epochs "$PHYSNET_EPOCHS" \
  --batch-size "$PHYSNET_BATCH" \
  --learning-rate "$PHYSNET_LR" \
  --charges \
  --zbl

CKPT="$(resolve_checkpoint || true)"
if [[ -n "$CKPT" ]]; then
  echo "$CKPT" > out/last_physnet_checkpoint.txt
  echo "Checkpoint: $CKPT"
  echo "(also written to out/last_physnet_checkpoint.txt)"
fi
