#!/usr/bin/env bash
# Compare CHARMM and ML dipole/ESP on a test split (requires completed joint ckpt).
# Run from: cd mmml_tutorial/cli && bash 12_charmm_esp_dipole_comparison.sh

<<<<<<< HEAD
set -e
=======
python -m mmml.cli.misc.compare_charmm_ml   --checkpoint ./output_from_md_checkpnt2/eg_joint   --valid-efd out/output_from_md2/energies_forces_dipoles_test.npz   --valid-esp out/output_from_md2/grids_esp_test.npz   --pdb pdb/init-packmol.pdb   --n-samples 50   --out-dir charmm_ml_com-benzdim-md2
>>>>>>> a0c444a (Sena additions to EF, etc)

echo "=== 12: compare_charmm_ml ==="
uv run python -m mmml.cli.misc.compare_charmm_ml \
  --checkpoint ~/ckpts/eg_joint \
  --valid-efd out/splits/energies_forces_dipoles_test.npz \
  --valid-esp out/splits/grids_esp_test.npz \
  --pdb pdb/initial.pdb \
  --n-samples 50 \
  --out-dir charmm_ml_comparison
