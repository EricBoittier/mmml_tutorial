#!/usr/bin/env bash
# Docs §5 — re-run methyl ic-scan with the trained PhysNet calculator.
# Requires: 01_make_res.sh + trained checkpoint (07). NMA geometry; ML model is ACEM/FORM —
# use as a smoke check only, or train an NMA potential for production methyl barriers.
set -euo pipefail
. ./shared.source

XYZ="xyz/nma.xyz"
if [[ ! -f "$XYZ" ]]; then
  echo "error: missing $XYZ — run 01_make_res.sh first" >&2
  exit 1
fi

CKPT="$(resolve_checkpoint || true)"
if [[ -z "$CKPT" && -f out/last_physnet_checkpoint.txt ]]; then
  CKPT="$(cat out/last_physnet_checkpoint.txt)"
fi
if [[ -z "$CKPT" || ! -e "$CKPT" ]]; then
  echo "error: no checkpoint — set PHYSNET_CHECKPOINT or run 07_physnet_train.sh" >&2
  exit 1
fi

CFG="$HERE/configs/nma_methyl_ml.yaml"
# Rewrite checkpoint path into a temp config next to the template.
TMP_CFG="$HERE/out/nma_methyl_ml.resolved.yaml"
python3 - <<PY
from pathlib import Path
src = Path("$CFG").read_text()
src = src.replace("__CHECKPOINT__", r"""$CKPT""")
Path("$TMP_CFG").write_text(src)
print("Wrote", "$TMP_CFG")
PY

OUT="$IC_SCAN_OUT/methyl_ml"
echo "=== 09: ic-scan PhysNet methyl → $OUT ==="
mmml ic-scan --config "$TMP_CFG" --output "$OUT" --overwrite
echo "Compare to xTB: $IC_SCAN_OUT/methyl_xtb/data.csv vs $OUT/data.csv"
