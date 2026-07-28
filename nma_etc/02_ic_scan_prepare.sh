#!/usr/bin/env bash
# Docs §2 — prepare ω + N-methyl ic-scan geometries (no energy eval).
# Requires: 01_make_res.sh (xyz/nma.xyz). Uses configs/nma_omega_methyl_2d.yaml.
set -euo pipefail
. ./shared.source

XYZ="xyz/nma.xyz"
if [[ ! -f "$XYZ" ]]; then
  echo "error: missing $XYZ — run 01_make_res.sh first" >&2
  exit 1
fi

CFG="$HERE/configs/nma_omega_methyl_2d.yaml"
OUT="$IC_SCAN_OUT/omega_methyl_2d"

echo "=== 02: ic-scan prepare-only → $OUT ==="
mmml ic-scan --config "$CFG" --prepare-only --output "$OUT" --overwrite
echo "Wrote ~195 frames. Inspect: ase gui $OUT/trajectory.traj"
