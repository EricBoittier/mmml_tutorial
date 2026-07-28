#!/usr/bin/env bash
# Shortcut: pad/merge → fix-and-split → validate → train → evaluate
# using the two NPZs already in this directory (skip make-res / ic-scan / QM).
set -euo pipefail
cd "$(dirname "$0")"
. ./shared.source

echo "=== run_from_npz: ACEM + FORM → PhysNet ==="
python3 ./04_pad_merge_npz.py \
  --acem "$ACEM_NPZ" --form "$FORM_NPZ" \
  --pad-natoms "$PAD_NATOMS" -o "$MERGED_NPZ"

bash ./05_fix_and_split.sh
bash ./06_validate.sh
bash ./07_physnet_train.sh
bash ./08_physnet_evaluate.sh

echo ""
echo "=== Done ==="
echo "  Splits:  $SPLITS_DIR"
echo "  Ckpts:   $PHYSNET_CKPT_DIR"
echo "  Eval:    $EVAL_OUT"
echo "Next (optional): bash 09_ic_scan_ml.sh | bash 10_dimer_scan.sh | bash 12_md_system.sh"
