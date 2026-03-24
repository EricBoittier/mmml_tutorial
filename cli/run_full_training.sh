#!/usr/bin/env bash
# Full training workflow: 1000 structures -> split -> PhysNet -> PhysNet+DCMNet
# Run from this directory: cd examples/mmml_tutorial/cli && bash run_full_training.sh
# Requires: Steps 01-04 run first (make_res, make_box, pyscf-dft full).

set -e
PHYSNET_EPOCHS=50
PHYSNET_CKPT_DIR=out/ckpts
. ./shared.source

echo "=== Full training workflow (1000 structures) ==="
echo ""

echo "--- 06: Normal mode sampling (max 1000) ---"
echo "Command: uv run mmml normal-mode-sample -i out/04_results.h5 -o out/06_sampled.npz --amplitude 0.1 --max-samples 1000"
uv run mmml normal-mode-sample -i out/04_results.h5 -o out/06_sampled.npz --amplitude 0.1 --max-samples 1000

echo ""
echo "--- 07: pyscf-evaluate ---"
echo "Command: uv run mmml pyscf-evaluate -i out/06_sampled.npz -o out/07_evaluated.npz --esp"
uv run mmml pyscf-evaluate -i out/06_sampled.npz -o out/07_evaluated.npz --esp

echo ""
echo "--- 08: fix-and-split ---"
echo "Command: uv run mmml fix-and-split --efd out/07_evaluated.npz --output-dir out/splits"
uv run mmml fix-and-split --efd out/07_evaluated.npz --output-dir out/splits

echo ""
echo "--- 09: PhysNet training ---"
uv run python "$PHYSNET_TRAINER" \
  --train "$PHYSNET_TRAIN_NPZ" \
  --valid "$PHYSNET_VALID_NPZ" \
  --natoms "$PHYSNET_NATOMS" \
  --epochs "$PHYSNET_EPOCHS" \
  --batch-size "$PHYSNET_BATCH" \
  --name "$PHYSNET_NAME" \
  --ckpt-dir "$PHYSNET_CKPT_DIR" \
  --charges

echo ""
echo "--- 10: PhysNet+DCMNet joint training ---"
PHYSNET_ARG=""
if ls -d out/ckpts/"$PHYSNET_NAME"-* >/dev/null 2>&1; then
  PHYSNET_CKPT=$(ls -d out/ckpts/"$PHYSNET_NAME"-* 2>/dev/null | tail -1)
  PHYSNET_ARG="--physnet-checkpoint $PHYSNET_CKPT"
  echo "Using PhysNet checkpoint: $PHYSNET_CKPT"
fi
uv run python -m mmml.cli.misc.train_joint \
  --train-efd out/splits/energies_forces_dipoles_train.npz \
  --train-esp out/splits/grids_esp_train.npz \
  --valid-efd out/splits/energies_forces_dipoles_valid.npz \
  --valid-esp out/splits/grids_esp_valid.npz \
  --epochs 50 \
  --batch-size 1 \
  --name cybz_joint \
  --ckpt-dir out/ckpts \
  $PHYSNET_ARG

echo ""
echo "=== Full training workflow complete ==="
echo "  PhysNet: out/ckpts/$PHYSNET_NAME/"
echo "  PhysNet+DCMNet: out/ckpts/cybz_joint/"
