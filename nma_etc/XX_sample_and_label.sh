#!/usr/bin/env bash
# Optional docs §3a–3b path (not needed when using bundled ACEM/FORM NPZs).
# Hessian → normal-mode sample → pyscf-evaluate with ESP.
set -euo pipefail
. ./shared.source

XYZ="${1:-xyz/nma.xyz}"
if [[ ! -f "$XYZ" ]]; then
  echo "error: missing $XYZ — run 01_make_res.sh first" >&2
  exit 1
fi

MAX_SAMPLES="${MAX_SAMPLES:-1000}"
echo "=== XX: sample + QM label ($XYZ, max=$MAX_SAMPLES) ==="
mmml pyscf-dft --mol "$XYZ" --energy --gradient --hessian --harmonic
mmml normal-mode-sample -i out/results.h5 -o out/sampled.npz --max-samples "$MAX_SAMPLES"
mmml pyscf-evaluate -i out/sampled.npz -o out/evaluated.npz --esp
echo "Wrote out/evaluated.npz — then e.g.:"
echo "  mmml fix-and-split --efd out/evaluated.npz --grid … --output-dir out/splits_nma"
