#!/usr/bin/env bash
# Compare CHARMM and ML dipole/ESP on a water monomer test split.

set -e

echo "=== 12: compare-charmm-ml (monomer) ==="
mmml compare-charmm-ml \
  --checkpoint ~/ckpts/water_mono_dimer_joint_ndc2 \
  --valid-efd out/splits/energies_forces_dipoles_test.npz \
  --valid-esp out/splits/grids_esp_test.npz \
  --pdb pdb/initial.pdb \
  --n-samples 10 \
  --out-dir charmm_ml_comparison_monomer_both_ndc2
