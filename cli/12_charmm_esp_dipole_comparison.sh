
python -m mmml.cli.misc.compare_charmm_ml   --checkpoint out/ckpts/cybz_joint   --valid-efd out/splits/energies_forces_dipoles_test.npz   --valid-esp out/splits/grids_esp_test.npz   --pdb pdb/initial.pdb   --n-samples 50   --out-dir charmm_ml_comparison

