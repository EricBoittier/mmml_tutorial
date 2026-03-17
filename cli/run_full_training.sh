#!/usr/bin/env bash
# Full training workflow: 1000 structures -> split -> PhysNet -> PhysNet+DCMNet
# Run from project root: bash examples/mmml_tutorial/cli/run_full_training.sh
# Requires: Steps 01-04 run first (make_res, make_box, pyscf-dft full).

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

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
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$REPO_ROOT"
uv run python examples/other/co2/physnet_train/trainer.py \
  --train examples/mmml_tutorial/cli/out/splits/energies_forces_dipoles_train.npz \
  --valid examples/mmml_tutorial/cli/out/splits/energies_forces_dipoles_valid.npz \
  --natoms 16 \
  --epochs 50 \
  --batch-size 1 \
  --name cybz_physnet \
  --ckpt-dir examples/mmml_tutorial/cli/out/ckpts \
  --charges

echo ""
echo "--- 10: PhysNet+DCMNet joint training ---"
cd "$SCRIPT_DIR"
uv run python -m mmml.cli.misc.train_joint \
  --train-efd out/splits/energies_forces_dipoles_train.npz \
  --train-esp out/splits/grids_esp_train.npz \
  --valid-efd out/splits/energies_forces_dipoles_valid.npz \
  --valid-esp out/splits/grids_esp_valid.npz \
  --epochs 50 \
  --batch-size 1 \
  --name cybz_joint \
  --ckpt-dir out/ckpts

echo ""
echo "=== Full training workflow complete ==="
echo "  PhysNet: out/ckpts/cybz_physnet/"
echo "  PhysNet+DCMNet: out/ckpts/cybz_joint/"
