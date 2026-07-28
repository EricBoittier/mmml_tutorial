#!/usr/bin/env bash
# Docs §3c — fix units + train/valid/test splits from bundled ACEM+FORM NPZs.
# Requires: 04_pad_merge_npz.py (merged file with shared atom padding).
#
# Bundled labels are already training-scale (Å, eV, eV/Å, e·Å) — no Ha→eV / atomic-ref.
set -euo pipefail
. ./shared.source

if [[ ! -f "$MERGED_NPZ" ]]; then
  echo "=== 04 (auto): pad + merge ACEM + FORM ==="
  python3 "$HERE/04_pad_merge_npz.py" \
    --acem "$ACEM_NPZ" --form "$FORM_NPZ" \
    --pad-natoms "$PAD_NATOMS" -o "$MERGED_NPZ"
fi

echo "=== 05: fix-and-split → $SPLITS_DIR ==="
mmml fix-and-split \
  --efd "$MERGED_NPZ" \
  --output-dir "$SPLITS_DIR" \
  --coords-in angstrom --coords-out same \
  --energy-in ev --energy-out same \
  --force-in ev-angstrom --force-out same \
  --dipole-in e-angstrom --dipole-out same

echo "Output: $SPLITS_DIR/energies_forces_dipoles_{train,valid,test}.npz"
