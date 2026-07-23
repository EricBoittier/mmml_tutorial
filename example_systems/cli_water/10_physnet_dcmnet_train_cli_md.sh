uv run python -m mmml.cli.misc.train_joint \
  --train-efd out/splits_mono_dimer_md/energies_forces_dipoles_train.npz \
  --train-esp out/splits_mono_dimer_md/grids_esp_train.npz \
  --valid-efd out/splits_mono_dimer_md/energies_forces_dipoles_valid.npz \
  --valid-esp out/splits_mono_dimer_md/grids_esp_valid.npz \
  --natoms 6 \
  --epochs 1000 \
  --optimizer adam --mono-weight 0.1 --forces-weight 1.0 --energy-weight 1.0 --charge-reg-weight 0.1 --batch-size 10 --grad-clip-norm 1000 \
  --dipole-source physnet --dipole-weight 1.0 --disable-physnet-point-coulomb --physnet-max-degree 0 --physnet-iterations 2 --learning-rate 0.0005 --n-dcm 2 \
   --name water_mono_dimer_md_joint_ndc2_zbl_mix2 \
  --ckpt-dir ~/ckpts \
  --plot-results \
  --plot-freq 0 --mix-warmup-start 200 --mix-warmup-end 500 --mix-weight-max 1.0

 # --mix-coulomb-energy 

