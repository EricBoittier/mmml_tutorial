// MMML tutorial notes for the cli_water workflow.
#set page(numbering: "1")
#set text(font: "Libertinus Serif", size: 10pt)

= MMML `cli_water` Tutorial

This document is a practical walkthrough of the water and water-dimer workflow in
`cli_water/`. It is written for a live tutorial: each section explains what the
step does, what command to run, what files to expect, and what to check before
moving on.

The workflow builds a small molecular system, labels geometries with QM data,
converts the labels into ML-ready splits, trains PhysNet, and then trains the
joint PhysNet+DCMNet model for ESP-aware charge prediction.

For a command-by-command reference, see the companion `cli_cheatsheet.typ`.

== Recent CLI updates

- Joint DCMNet training can now start from the portable PhysNet parameters
  stored in the repo:
  - `--use-repo-physnet-params`
  - This is the easiest tutorial path because participants do not need to train
    a fresh PhysNet checkpoint before starting DCMNet.
- EF training now supports rotational augmentation flags:
  - `--rot-augment`
  - `--rot-perturbation` (range `0.0` to `1.0`)
- Orbax checkpoint runs can be summarized/plotted with:
  - `mmml extract-checkpoint-metrics <run_dir> -o training_metrics.png --log-loss`

== What this tutorial covers

- The script-driven workflow from structure setup to joint PhysNet+DCMNet
  training.
- The data flow between numbered scripts.
- Key outputs and sanity checks at each stage.
- A short smoke-test path for demonstrating pretrained PhysNet initialization.
- Optional branches: CHARMM comparison, active learning, retraining, and EF
  training.

== Live tutorial strategy

For a classroom or demo, do not make people wait for expensive QM and training
steps unless the machine is prepared for it. A good flow is:

1. Walk through steps 01--05 conceptually.
2. Run or show step 06 and step 07 on a small prepared set.
3. Use existing split files under `out/splits_dimer/` for DCMNet training.
4. Smoke-test joint training for one epoch with `--use-repo-physnet-params`.
5. Show where plots and checkpoints are written.

The fastest end-to-end DCMNet demonstration is:

```bash
cd cli_water
bash 10_physnet_dcmnet_train_cli.sh
```

For a one-epoch smoke test, use the same command but set `--epochs 1` and write
to a temporary checkpoint directory such as `/tmp/mmml_ckpts`.

== Environment checklist

- Run commands from `examples/mmml_tutorial/cli_water`.
- Use the project environment (`uv run ...`) when available.
- CHARMM/PyCHARMM is needed for residue and box generation.
- PackMol is needed for box construction.
- PySCF and GPU setup are needed for the expensive QM labeling steps.
- If JAX tries to initialize a broken CUDA plugin during a CPU-only demo, prefix
  the command with `JAX_PLATFORMS=cpu`.

== Directory map (`cli_water/`)

- `01_make_res_cli.sh`: create residue/topology and initial structure.
- `02_make_box_cli.sh`: build a periodic box (PackMol).
- `04_pyscf_dft_cli_full.sh`: DFT (energy, gradient, hessian, harmonic, thermo).
- `06_normal_mode_sample_cli.sh`: normal-mode sampling over split HDF5 files.
- `07_pyscf_evaluate_cli.sh`: evaluate sampled structures with PySCF (`--esp`).
- `08_fix_and_split_cli.sh`: unit fixes + train/valid/test splits.
- `09_physnet_train_cli.sh`: PhysNet training.
- `10_physnet_dcmnet_train_cli.sh`: joint PhysNet + DCMNet training, using
  repo PhysNet parameters by default.
- `11_run_pycharmm_cli.sh`: CHARMM heat/equilibration baseline run.
- `12_charmm_esp_dipole_comparison.sh`: compare CHARMM and ML dipole/ESP behavior.
- `13_physnet_md.sh`: generate PhysNet MD trajectory.
- `14_active_learning.sh`: extract useful MD frames for re-labeling.
- `15_physnet_retrain_cli.sh`: retrain using one extended split.
- `15.1_physnet_retrain_cli.sh`: retrain using multiple extended splits.
- `run_full_training.sh`: convenience script for a full end-to-end run.
- `shared.source`: shared defaults (trainer path, checkpoints, dataset paths).
- `splits_extended/` and `splits_extended2/`: additional split datasets for retraining.

== Data flow

The main files move through the pipeline like this:

```text
xyz/initial.xyz or out/tip3_dimers_test.xyz
  -> out/dimer04_results.{npz,h5}
  -> out/xyz_split/*.h5
  -> out/xyz_split/*.h5.sampled.npz
  -> out/xyz_split/*.h5.sampled.npz.eval.npz
  -> out/splits_dimer/{energies_forces_dipoles,grids_esp}_{train,valid,test}.npz
  -> ~/ckpts/water_dimer_joint/
```

The exact split directory depends on the script variant:

- `out/splits/`: simple tutorial split.
- `out/splits_dimer/`: water-dimer split used by current joint DCMNet scripts.
- `out/splits_md/`: split generated from MD-labeled NPZ files.

== Recommended run order

This is the high-level order encoded by script dependencies:

1. `01_make_res_cli.sh`
2. `02_make_box_cli.sh`
3. `04_pyscf_dft_cli_full.sh`
4. `06_normal_mode_sample_cli.sh`
5. `07_pyscf_evaluate_cli.sh`
6. `08_fix_and_split_cli.sh`
7. `09_physnet_train_cli.sh`
8. `10_physnet_dcmnet_train_cli.sh`
9. `13_physnet_md.sh`
10. `14_active_learning.sh`
11. `15_physnet_retrain_cli.sh` or `15.1_physnet_retrain_cli.sh`

`11_run_pycharmm_cli.sh` and `12_charmm_esp_dipole_comparison.sh` are side branches for MM baseline and diagnostics.

== Step-by-step notes

=== Step 01: Make residue

Purpose: generate residue-level structure and topology files.

```bash
cd cli_water
bash 01_make_res_cli.sh
```

Main outputs:
- `pdb/initial.pdb`
- `psf/initial.psf`
- `xyz/initial.xyz`
- `out/01_last_command.txt`

Notes:
- The residue is controlled by `RES` in `shared.source`; the default is `TIP3`.
- The script saves the exact command that was run so participants can reproduce
  it later.
- Requires CHARMM/PyCHARMM environment.

=== Step 02: Build box

Purpose: create a packed periodic system from the residue.

```bash
bash 02_make_box_cli.sh
```

Main output:
- `pdb/init-packmol.pdb`

Notes:
- Depends on step 01 output.
- Requires PackMol installed.

=== Step 04: Full DFT with PySCF

Purpose: create high-quality QM reference data and harmonic information.

```bash
bash 04_pyscf_dft_cli_full.sh
```

Main outputs:
- `out/dimer04_results.npz`
- `out/dimer04_results.h5`

Notes:
- Hessian/harmonic/thermo can be expensive.
- The current water script runs on `out/tip3_dimers_test.xyz`.
- Normal-mode sampling expects HDF5 harmonic data. In prepared tutorial runs,
  these may already be split under `out/xyz_split/*.h5`.

=== Step 06: Normal mode sampling

Purpose: generate perturbed geometries for dataset construction.

The current water script loops over split HDF5 files and samples 50 structures
from each:

```bash
bash 06_normal_mode_sample_cli.sh
```

Typical contents:
- `R`, `Z`, `N`

Main outputs:
- `out/xyz_split/*.h5.sampled.npz`

Presentation note:
- This step is a good place to explain that normal-mode sampling turns one QM
  reference calculation into a local geometry cloud for training.

=== Step 07: Evaluate sampled geometries

Purpose: label sampled structures with QM properties (including ESP grids).

```bash
bash 07_pyscf_evaluate_cli.sh
```

Typical contents:
- `R`, `Z`, `N`, `E`, `F`, `Dxyz`, `esp`, `esp_grid`

Main outputs:
- `out/xyz_split/*.h5.sampled.npz.eval.npz`

Presentation note:
- This is usually the slowest step. For a live tutorial, prepare the evaluated
  NPZ files ahead of time and show the command rather than running all frames.

=== Step 08: Fix units and split datasets

Purpose: convert to training units and build deterministic splits.

```bash
bash 08_fix_and_split_cli.sh
```

Main outputs:
- `out/splits_md/energies_forces_dipoles_{train,valid,test}.npz`
- `out/splits_md/grids_esp_{train,valid,test}.npz`

The DCMNet tutorial scripts also use prepared dimer splits:
- `out/splits_dimer/energies_forces_dipoles_{train,valid,test}.npz`
- `out/splits_dimer/grids_esp_{train,valid,test}.npz`

Based on `splits_extended*/README.md`, expected conversions include:
- energy: Hartree -> eV
- force: Hartree/Bohr -> eV/Angstrom
- dipole: Debye -> e*Angstrom
- ESP grid coordinates converted to physical Angstrom positions

=== Step 09: Train PhysNet

Purpose: train baseline PhysNet on E/F/D data.

The script loads defaults from `shared.source`:

```bash
python "$PHYSNET_TRAINER" \
  --train "$PHYSNET_TRAIN_NPZ" \
  --valid "$PHYSNET_VALID_NPZ" \
  --natoms "$PHYSNET_NATOMS" \
  --epochs "$PHYSNET_EPOCHS" \
  --batch-size "$PHYSNET_BATCH" \
  --charges \
  --zbl \
  --name "$PHYSNET_NAME" \
  --ckpt-dir "$PHYSNET_CKPT_DIR"
```

Main output:
- `"$PHYSNET_CKPT_DIR/$PHYSNET_NAME/"` (run directory)

For the shortest DCMNet tutorial, you can skip this long training step and use
the bundled portable PhysNet parameters in step 10.

You can analyze Orbax training checkpoints with:

```bash
mmml extract-checkpoint-metrics "$PHYSNET_CKPT_DIR/$PHYSNET_NAME" \
  -o physnet_training_metrics.png --log-loss
```

=== Step 10: Joint PhysNet + DCMNet training

Purpose: co-train on E/F/D and ESP grid data.

```bash
bash 10_physnet_dcmnet_train_cli.sh
```

The current script expands to:

```bash
uv run python -m mmml.cli.misc.train_joint \
  --train-efd out/splits_dimer/energies_forces_dipoles_train.npz \
  --train-esp out/splits_dimer/grids_esp_train.npz \
  --valid-efd out/splits_dimer/energies_forces_dipoles_valid.npz \
  --valid-esp out/splits_dimer/grids_esp_valid.npz \
  --use-repo-physnet-params \
  --epochs 1000 \
  --batch-size 1 \
  --name water_dimer_joint \
  --ckpt-dir ~/ckpts \
  --plot-results --plot-freq 0
```

Notes:
- `--use-repo-physnet-params` initializes the PhysNet part of the joint model
  from `mmml/models/physnetjax/defaults/meoh_dimer_portable.json`.
- Use `--physnet-checkpoint <path>` instead if you want to start from a PhysNet
  run trained during step 09.
- Use only one of `--use-repo-physnet-params`, `--physnet-checkpoint`, or
  `--restart`.
- For a smoke test, change `--epochs 1000` to `--epochs 1` and use
  `--ckpt-dir /tmp/mmml_ckpts`.
- The same checkpoint metrics command can be used for joint training run directories.

Expected console milestones:
- "Loaded PhysNet config from checkpoint"
- "Merging PhysNet params into joint model"
- "Pre-computing edge lists"
- Training and validation metrics after each printed epoch

=== EF training: rotational augmentation example

Use this when training EF models and you want random SO(3) data augmentation:

```bash
mmml ef-train \
  --train-npz out/splits_ef0_ring/energies_forces_dipoles_train.npz \
  --valid-npz out/splits_ef0_ring/energies_forces_dipoles_valid.npz \
  --test-npz out/splits_ef0_ring/energies_forces_dipoles_test.npz \
  --rot-augment --rot-perturbation 1.0 \
  --clip_norm 1000 \
  --output-dir ~/ckpts/ring_ef_ptT_run2 \
  --num_iterations 2 --max_degree 2
```

Behavior summary:
- vector quantities (positions/forces/dipoles/field vectors) are co-rotated
- scalar targets (energies, scalar losses) remain unchanged
- See `EF/ring/train_ef.sh` for the full command including basis size, feature
  count, loss weights, and checkpoint cadence.

=== Step 11: Pure CHARMM equilibration

Purpose: run MM-only baseline heating/equilibration.

```bash
uv run mmml run-pycharmm --pdbfile pdb/init-packmol.pdb --cell 25.0
```

Main outputs:
- `pdb/heat.pdb`, `pdb/equi.pdb`
- `dcd/heat.dcd`, `dcd/equi.dcd`
- `res/heat.res`, `res/equi.res`

=== Step 12: CHARMM vs ML comparison

Purpose: compare behavior on a test split.

```bash
python -m mmml.cli.misc.compare_charmm_ml \
  --checkpoint ~/ckpts/water_mono_dimer_joint_ndc2_zbl \
  --valid-efd out/splits_dimer/energies_forces_dipoles_test.npz \
  --valid-esp out/splits_dimer/grids_esp_test.npz \
  --pdb pdb/frame_00000.pdb \
  --n-samples 10 \
  --out-dir charmm_ml_comparison_dimer_both_ndc2_zbl
```

Use this as a diagnostic rather than a required tutorial step. It helps answer:
- Are ML dipoles and ESPs in the right range?
- Does the model behave sensibly on held-out dimer geometries?
- Are CHARMM topology and atom ordering aligned with the ML data?

=== Step 13: PhysNet MD sampling

Purpose: run MD to create new candidate structures.

```bash
mmml physnet-md \
  --checkpoint "$PHYSNET_CHECKPOINT" \
  --data "$PHYSNET_TRAIN_NPZ" \
  -o "$PHYSNET_MD_OUT"
```

Main outputs:
- `physnet_ase.traj`
- `physnet_ase_final.xyz`
- `physnet_jaxmd.xyz`

=== Step 14: Active learning extraction

Purpose: filter MD frames (e.g., by temperature) for expensive QM relabeling.

```bash
mmml active-learning \
  -i "$PHYSNET_MD_TRAJ" \
  -o "$ACTIVE_LEARNING_OUT" \
  --max-temp 500
```

Follow-up path suggested by the script:

```bash
mmml pyscf-evaluate -i out/activate_learning.npz -o out/md_evaluated.npz --esp
mmml fix-and-split --efd out/splits/energies_forces_dipoles_train.npz out/md_evaluated.npz -o out/splits_extended
```

The current script overrides the shared defaults to use:
- input trajectory: `nve24.traj`
- output NPZ: `nve_out24.npz`
- maximum frame temperature: `500 K`

=== Step 15 / 15.1: Retraining on extended data

Purpose: continue training from an earlier checkpoint with additional active-learning data.

Single extension:

```bash
python "$PHYSNET_TRAINER" \
  --train out/splits/energies_forces_dipoles_train.npz splits_extended/energies_forces_dipoles_train.npz \
  --valid out/splits/energies_forces_dipoles_valid.npz splits_extended/energies_forces_dipoles_test.npz \
  --natoms "$PHYSNET_NATOMS" \
  --epochs "$PHYSNET_EPOCHS" \
  --name "$PHYSNET_NAME" \
  --ckpt-dir "$PHYSNET_CKPT_DIR" \
  --restart "$PHYSNET_CHECKPOINT"
```

Multiple extensions:

```bash
python "$PHYSNET_TRAINER" \
  --train out/splits/energies_forces_dipoles_train.npz splits_extended/energies_forces_dipoles_train.npz splits_extended2/energies_forces_dipoles_train.npz \
  --valid out/splits/energies_forces_dipoles_valid.npz splits_extended/energies_forces_dipoles_valid.npz splits_extended2/energies_forces_dipoles_valid.npz \
  --natoms "$PHYSNET_NATOMS" \
  --batch-size "$PHYSNET_BATCH" \
  --epochs 1500 \
  --charges \
  --name "$PHYSNET_NAME" \
  --ckpt-dir "$PHYSNET_CKPT_DIR" \
  --restart "$PHYSNET_CHECKPOINT"
```

== Optional scripts (`XX_*`)

- `XX_pyscf_dft_cli.sh`: single-geometry DFT energy example on water.
- `XX_pyscf_mp2_cli.sh`: single-geometry MP2 energy example on water.

These are useful as sanity checks before launching the full dataset workflow.

== `shared.source` variables you will likely edit

- `PHYSNET_TRAINER`
- `PHYSNET_CKPT_DIR`
- `PHYSNET_NAME`
- `PHYSNET_CHECKPOINT`
- `PHYSNET_NATOMS`
- `PHYSNET_EPOCHS`
- `PHYSNET_BATCH`
- `PHYSNET_TRAIN_NPZ`
- `PHYSNET_VALID_NPZ`
- `PHYSNET_MD_OUT`
- `PHYSNET_MD_TRAJ`
- `ACTIVE_LEARNING_OUT`

== Fast start options

=== Option A: full pipeline script

```bash
cd examples/mmml_tutorial/cli_water
bash run_full_training.sh
```

This script is useful for automated runs, but it still includes expensive QM
and training work. For a live tutorial, prefer option B or option C.

=== Option B: manual progression

Run each script in order to inspect intermediate outputs and troubleshoot early.

```bash
cd examples/mmml_tutorial/cli_water
bash 01_make_res_cli.sh
bash 02_make_box_cli.sh
bash 04_pyscf_dft_cli_full.sh
bash 06_normal_mode_sample_cli.sh
bash 07_pyscf_evaluate_cli.sh
bash 08_fix_and_split_cli.sh
bash 10_physnet_dcmnet_train_cli.sh
```

=== Option C: DCMNet-only smoke test

If prepared split files already exist, jump straight to the joint model:

```bash
cd examples/mmml_tutorial/cli_water
JAX_PLATFORMS=cpu uv run python -m mmml.cli.misc.train_joint \
  --train-efd out/splits_dimer/energies_forces_dipoles_train.npz \
  --train-esp out/splits_dimer/grids_esp_train.npz \
  --valid-efd out/splits_dimer/energies_forces_dipoles_valid.npz \
  --valid-esp out/splits_dimer/grids_esp_valid.npz \
  --use-repo-physnet-params \
  --epochs 1 \
  --batch-size 1 \
  --name smoke_repo_physnet \
  --ckpt-dir /tmp/mmml_ckpts \
  --plot-freq 0
```

== Current caveats to mention

- The repository contains both `cli/` and `cli_water/`. This document follows
  `cli_water/`.
- Some script echo lines are shorter than the actual command. Trust the command
  body when in doubt.
- Step 08 currently builds `out/splits_md/` from `mdout/*.npz`, while the main
  DCMNet demo uses prepared `out/splits_dimer/` files.
- Step 10 assumes the portable repo PhysNet checkpoint is compatible with the
  water-dimer architecture and lets the checkpoint config override CLI PhysNet
  shape settings when needed.
- GPU environments can fail before argparse if JAX initializes an incompatible
  CUDA plugin. For CPU smoke tests, use `JAX_PLATFORMS=cpu`.

== Troubleshooting

=== `git pull` refuses to fast-forward

If you made local commits in `mmml_tutorial` and upstream changed too:

```bash
git pull --rebase
```

Resolve conflicts, then:

```bash
git add <resolved-files>
git rebase --continue
```

=== GitHub rejects `git push` password auth

GitHub no longer accepts account passwords for HTTPS pushes. Use:

```bash
gh auth login
gh auth setup-git
git push
```

or switch the remote to SSH.

=== Joint training crashes while loading repo PhysNet params

Expected signs of a healthy run:

```text
Loaded PhysNet config from checkpoint
Merging PhysNet params into joint model
Pre-computing edge lists
```

If the error mentions scalar leaves such as `'float' object has no attribute
'copy'` or `'size'`, update to the current `train_joint.py`; the parameter merge
and EMA initialization should handle scalar leaves.

=== PySCF or CHARMM steps are too slow for the tutorial

Prepare these outputs before the session:

- `out/xyz_split/*.h5`
- `out/xyz_split/*.sampled.npz`
- `out/xyz_split/*.sampled.npz.eval.npz`
- `out/splits_dimer/*.npz`

Then use the live session to explain the pipeline and run only the one-epoch
joint training smoke test.

== Next additions for this document

- Add expected wall-time ranges per step on your hardware.
- Add screenshots of training plots and ESP error plots.
- Add a small glossary: PhysNet, DCMNet, ESP, MDCM, Orbax, EMA.
