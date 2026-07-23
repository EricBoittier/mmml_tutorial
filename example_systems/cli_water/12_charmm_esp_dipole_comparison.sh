
python -m mmml.cli.misc.compare_charmm_ml   --checkpoint ~/ckpts/water_mono_dimer_joint_ndc2_zbl   --valid-efd out/splits_dimer/energies_forces_dipoles_test.npz   --valid-esp out/splits_dimer/grids_esp_test.npz   --pdb pdb/frame_00000.pdb   --n-samples 10   --out-dir charmm_ml_comparison_dimer_both_ndc2_zbl

