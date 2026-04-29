
python -m mmml.cli.misc.compare_charmm_ml   --checkpoint ~/ckpts/water_mono_dimer_joint_ndc2   --valid-efd out/splits/energies_forces_dipoles_test.npz   --valid-esp out/splits/grids_esp_test.npz   --pdb pdb/initial.pdb   --n-samples 10   --out-dir charmm_ml_comparison_monomer_both_ndc2

