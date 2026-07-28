#!/usr/bin/env bash
# Docs §6 — 1D dimer COM scan for NMA.
# Default: xTB reference. Set USE_ML=1 and PHYSNET_CHECKPOINT for PhysNet.
set -euo pipefail
. ./shared.source

USE_ML="${USE_ML:-0}"
DIST="${DIST:-3.0:6.0:0.25}"
OUT="${DIMER_OUT}/nma_1d"

echo "=== 10: dimer-scan NMA ==="
if [[ "$USE_ML" == "1" ]]; then
  CKPT="$(resolve_checkpoint || true)"
  if [[ -z "$CKPT" && -f out/last_physnet_checkpoint.txt ]]; then
    CKPT="$(cat out/last_physnet_checkpoint.txt)"
  fi
  if [[ -z "$CKPT" || ! -e "$CKPT" ]]; then
    echo "error: USE_ML=1 but no checkpoint found" >&2
    exit 1
  fi
  mmml dimer-scan NMA \
    --calculator physnet --checkpoint "$CKPT" \
    --distance "$DIST" \
    --energy-definition interaction \
    --output "$OUT"
else
  mmml dimer-scan NMA \
    --calculator xtb \
    --distance "$DIST" \
    --output "${OUT}_xtb"
fi
echo "Done. Output under $DIMER_OUT/"
