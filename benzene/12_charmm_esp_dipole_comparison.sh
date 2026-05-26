#!/usr/bin/env bash
# Compare CHARMM and ML dipole/ESP on a test split (requires completed joint ckpt).
# Run from: cd mmml_tutorial/cli && bash 12_charmm_esp_dipole_comparison.sh

set -e

echo "=== 12: compare_charmm_ml ==="
uv run python -m mmml.cli.misc.compare_charmm_ml \
  --checkpoint ~/ckpts/eg_joint \
  --valid-efd out/splits/energies_forces_dipoles_test.npz \
  --valid-esp out/splits/grids_esp_test.npz \
  --pdb pdb/initial.pdb \
  --n-samples 50 \
  --out-dir charmm_ml_comparison
