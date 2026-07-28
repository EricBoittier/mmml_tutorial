#!/usr/bin/env bash
# Docs §2 — methyl 1D ic-scan with GFN2-xTB (smoke barriers).
# Requires: 01_make_res.sh. Expect ~0.5 kcal/mol (acetyl) / ~1 kcal/mol (N-methyl).
set -euo pipefail
. ./shared.source

XYZ="xyz/nma.xyz"
if [[ ! -f "$XYZ" ]]; then
  echo "error: missing $XYZ — run 01_make_res.sh first" >&2
  exit 1
fi

CFG="$HERE/configs/nma_methyl.yaml"
OUT="$IC_SCAN_OUT/methyl_xtb"

echo "=== 03: ic-scan xTB methyl → $OUT ==="
mmml ic-scan --config "$CFG" --output "$OUT" --overwrite
echo "See $OUT/data.csv and optional energy_*.png"
