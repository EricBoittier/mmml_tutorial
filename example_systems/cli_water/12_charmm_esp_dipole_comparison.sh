#!/usr/bin/env bash
# Compare CHARMM and ML dipole/ESP on a water dimer test split.

set -e

echo "=== 12: compare-charmm-ml (dimer) ==="
mmml compare-charmm-ml \
  --checkpoint ~/ckpts/water_mono_dimer_joint_ndc2_zbl \
  --valid-efd out/splits_dimer/energies_forces_dipoles_test.npz \
  --valid-esp out/splits_dimer/grids_esp_test.npz \
  --pdb pdb/frame_00000.pdb \
  --n-samples 10 \
  --out-dir charmm_ml_comparison_dimer_both_ndc2_zbl
