// MMML tutorial: `mmml_tutorial/cli` workflow (default residue BENZ in shared.source).
// Figures: `cd mmml_tutorial/cli && uv run python generate_tutorial_assets.py`
// (optional `--allow-placeholders`). Then `typst compile tutorial.typ`.
#set page(numbering: "1")
#set text(font: "Libertinus Serif", size: 10pt)

#let stepfig(file, cap) = figure(
  image("assets/cli/" + file, width: 82%),
  caption: cap,
)

// --- Flowchart helpers (no external packages; compiles offline) ---
#let flow-stroke = 0.65pt + rgb("#2d4a5e")
#let flow-fill = rgb("#f2f6fa")
#let flow-fill-branch = rgb("#faf8f2")
#let flow-arrow = text(size: 14pt, fill: rgb("#2d4a5e"))[#sym.arrow.b]
#let flow-box(title, body, fill: flow-fill) = box(
  fill: fill,
  stroke: flow-stroke,
  radius: 4pt,
  inset: (x: 11pt, y: 8pt),
  width: 100%,
)[
  #text(weight: "bold", fill: rgb("#1a3050"))[#title] \
  #body
]
#let flow-stack(..nodes) = {
  set align(center)
  stack(spacing: 0.28em, ..nodes)
}

= MMML `cli` tutorial

This walkthrough follows the numbered scripts in `mmml_tutorial/cli/`: build a
small system with PyCHARMM, run GPU DFT and sampling, label data, split into
training NPZs, train PhysNet (optional), and train the joint PhysNet+DCMNet
model with ESP grids. Default residue is `BENZ` (`shared.source`); override with
`RES=TIP3` (or another residue) before sourcing if you want a different
chemistry.

Each step below links a *figure* (molecule, plot, or schematic) and a *log
excerpt* from the checked-in `*.log` files in `cli/`, so a prepared tutorial
room can show expected console output without re-running long jobs.

For a flat command index, see `cli_cheatsheet.typ`.

== Tutorial map: core path, options, and extras

The figure below is the *contract* for the rest of the document: a linear
*core* pipeline (stacked boxes) you can trim for demos, plus *optional branches*
(bottom panel) for classical MM, diagnostics, neural MD, active learning, preset
`md-system` workloads, and equivariant field (EF) models.

#figure(
  block(width: 100%, inset: (x: 2pt))[
    #set text(size: 9.2pt)
    #flow-stack(
      flow-box([Core: system setup (01–02)], [
        Residue / topology / `xyz/initial.xyz` → optional periodic box (`make-box`, PackMol). \
        *Extras:* change `RES`, `n`, `side_length`; skip 02 for gas-phase QM on `initial.xyz` only.
      ]),
      flow-arrow,
      flow-box([Core: QM reference (04)], [
        DFT energy, gradient, Hessian, harmonic, thermo → `out/04_results.{npz,h5}`. \
        *Extras:* `XX_pyscf_dft_cli.sh` / `XX_pyscf_mp2_cli.sh` for quick single-point checks; tune `basis`, `xc` on the CLI.
      ]),
      flow-arrow,
      flow-box([Core: ensemble + labels (06–08)], [
        Normal-mode sample → batched PySCF (`--esp`) → `fix-and-split` → `out/splits/*.npz`. \
        *Extras:* sampling strength (`--amplitude`, `--max-samples`); omit `--esp` in 07 for faster E/F/D-only labels; adjust split fractions / `--atomic-ref` in 08.
      ]),
      flow-arrow,
      flow-box([Training: PhysNet (09) — optional], [
        Standalone potential on E/F/D; checkpoint under `PHYSNET_CKPT_DIR`. \
        *Shortcut:* skip 09 and use `--use-repo-physnet-params` in step 10.
      ]),
      flow-arrow,
      flow-box([Training: joint PhysNet + DCMNet (10)], [
        E/F/D + ESP grids → `eg_joint` (or renamed run) under `~/ckpts`. \
        *Extras:* `--physnet-checkpoint` instead of repo params; smoke-test with `--epochs 1`, `JAX_PLATFORMS=cpu`.
      ]),
      flow-arrow,
      flow-box([Post-train: MD, AL, retrain (13–15)], [
        `physnet-md` trajectories → `active-learning` frames → optional `pyscf-evaluate` + extended splits → `15` / `15.1` retrain. \
        *Requires:* trained checkpoint paths in `shared.source`.
      ], fill: flow-fill-branch),
      v(0.45em),
      block(width: 100%, inset: 6pt, stroke: 0.55pt + rgb("#8a6d3b"), radius: 4pt, fill: rgb("#fffdf7"))[
        #text(weight: "bold")[Parallel branches (any time after relevant artifacts exist)] \
        #grid(
          columns: (1fr, 1fr),
          column-gutter: 0.85em,
          row-gutter: 0.55em,
        )[
          - *11* — pure CHARMM heat / equilibration on `init-packmol.pdb` \
          - *12* — `compare_charmm_ml` ESP / dipole diagnostics
          ,
          - *16–21* — `mmml md-system` presets (free / PBC, NVE/NVT/NPT, mixed solvents) \
          - *EF track* — `mmml ef-train` / `ef-evaluate` / `ef-md` on ring or other EF-ready splits (not the default `cli/` benzene path)
        ]
      ],
    )
  ],
  caption: [
    End-to-end *tutorial coverage* (center column) versus *extra functionality* you can demonstrate with the same repo (branches). Numbers refer to scripts in `mmml_tutorial/cli/`.
  ],
)

=== How to choose options at each stage

- *Residue and box (01–02).* Use `shared.source` or `RES=…` for chemistry. Need a condensed phase or interface? Increase `--n` and box `side_length`, or add solvent flags if your `make-box` invocation supports them. Gas-phase dataset: run 01 only and point step 04 at `xyz/initial.xyz`.

- *Reference QM (04).* The tutorial script requests Hessian + harmonic for normal-mode sampling. For a *cheap* sanity check, use the `XX_*` scripts or a minimal `pyscf-dft` run without `--hessian`. Production datasets usually keep harmonic data for 06.

- *Sampling (06).* `--max-samples` trades cost (step 07) against diversity. Multiple `--amplitudes` are supported by the CLI if you customize the script.

- *Batch evaluation (07).* `--esp` adds cost and ESP grid tensors required for DCMNet. For pure PhysNet-on-EF training without ESP, you can drop `--esp` and adjust step 08 / 10 inputs accordingly.

- *Splits (08).* `fix-and-split` chooses train/valid/test fractions and optional atomic energy references. For *active learning*, merge new evaluated NPZs into extended directories (`splits_extended*`) as in steps 14–15.

- *PhysNet vs joint (09–10).* If the portable repo PhysNet matches your stoichiometry, prefer `--use-repo-physnet-params` and skip long 09 runs in the classroom. Use `--physnet-checkpoint` when you need your own step-09 run.

- *After training.* Step 13 drives exploratory MD; step 14 subsamples frames for re-QM. Steps 16–21 showcase `md-system` automation (cutoff figures in the tutorial assets). The EF subsection documents a *different* model family on its own NPZ layout.

== Figures and log excerpts

- Regenerate PNGs under `assets/cli/` with
  `uv run python generate_tutorial_assets.py` from `mmml_tutorial/cli/`.
- Log snippets are illustrative; your exact timings and energies will differ.

== Recent CLI updates

- Joint training: `--use-repo-physnet-params` bootstraps PhysNet from portable
  repo JSON (no fresh PhysNet run required for a DCMNet demo).
- EF training: `--rot-augment`, `--rot-perturbation`.
- Checkpoints: `mmml extract-checkpoint-metrics <run_dir> -o metrics.png --log-loss`.

== What this tutorial covers

See *Tutorial map* (above) for the full pipeline and branches. In short: scripts
`01`–`08` build the ML dataset; `09`–`10` train; `11`–`21` and EF commands are
optional extensions using the same CLI.

== Live tutorial strategy

1. Walk through steps 01–02 and 04 conceptually (show figures + logs).
2. Run or show 06–07 only if GPUs are ready; otherwise use precomputed `out/`.
3. For DCMNet, either run `08` then `10`, or supply prepared `out/splits/*.npz`.
4. Smoke-test joint training: `--epochs 1`, `--ckpt-dir /tmp/mmml_ckpts`,
   `JAX_PLATFORMS=cpu` on laptops.

Quickest joint-training demo (after splits exist):

```bash
cd mmml_tutorial/cli
bash 10_physnet_dcmnet_train_cli.sh
```

== Environment checklist

- Work from `mmml_tutorial/cli` (paths below are relative to that directory).
- `uv run …` when the project uses `uv`.
- PyCHARMM + PackMol for steps 01–02; PySCF/GPU stack for 04 and 07.
- `JAX_PLATFORMS=cpu` if CUDA init breaks before argparse.

== Directory map (`mmml_tutorial/cli/`)

- `shared.source` — `RES`, PhysNet trainer path, checkpoint dirs, NPZ paths, MD defaults.
- `01_make_res_cli.sh` — residue/topology + `xyz/initial.xyz`.
- `02_make_box_cli.sh` — PackMol box `pdb/init-packmol.pdb`.
- `04_pyscf_dft_cli_full.sh` — DFT + Hessian + harmonic + thermo → `out/04_results.{npz,h5}`.
- `06_normal_mode_sample_cli.sh` — `out/06_sampled.npz`.
- `07_pyscf_evaluate_cli.sh` — batched QM + ESP → `out/07_evaluated*.npz`.
- `08_fix_and_split_cli.sh` — splits under `out/splits/`.
- `09_physnet_train_cli.sh` — PhysNet (trainer script from `shared.source`).
- `10_physnet_dcmnet_train_cli.sh` — joint PhysNet+DCMNet → `~/ckpts/eg_joint/…`.
- `11_run_pycharmm_cli.sh` — classical heat/equilibration.
- `12_charmm_esp_dipole_comparison.sh` — CHARMM vs ML diagnostics.
- `13_physnet_md.sh` — PhysNet MD trajectories.
- `14_active_learning.sh` — frames for re-labeling.
- `15_physnet_retrain_cli.sh`, `15.1_physnet_retrain_cli.sh` — continued training.
- `16_md_10mer_free_nve.sh` … `20_md_10mer_pbc_npt.sh` — `mmml md-system` presets.
- `21_md_system_meoh_tip3_1to1.sh` — mixed composition example.
- `run_full_training.sh` — 06→10 automation with shortened epochs in-repo.

== Data flow

```text
xyz/initial.xyz
  -> out/04_results.{npz,h5}
  -> out/06_sampled.npz
  -> out/07_evaluated*.npz
  -> out/splits/{energies_forces_dipoles,grids_esp}_{train,valid,test}.npz
  -> ~/ckpts/<PHYSNET_NAME>/   (step 09, optional)
  -> ~/ckpts/eg_joint/         (step 10, Orbax run id may include a UUID suffix)
```

== Recommended run order

1. `01_make_res_cli.sh`
2. `02_make_box_cli.sh`
3. `04_pyscf_dft_cli_full.sh`
4. `06_normal_mode_sample_cli.sh`
5. `07_pyscf_evaluate_cli.sh`
6. `08_fix_and_split_cli.sh`
7. `09_physnet_train_cli.sh` *(optional if using repo PhysNet params in step 10)*
8. `10_physnet_dcmnet_train_cli.sh`
9. `13_physnet_md.sh`, `14_active_learning.sh`, `15*.sh` as needed
10. `16`–`21` MD presets for `md-system` exploration

Side branches: `11_run_pycharmm_cli.sh`, `12_charmm_esp_dipole_comparison.sh`.

== Step-by-step notes

=== Step 01: Make residue

Purpose: CHARMM residue/topology and `xyz/initial.xyz` for the chosen `RES`.

```bash
cd mmml_tutorial/cli
bash 01_make_res_cli.sh
```

#stepfig("step01_monomer.png", [Study system (`BENZ` by default): 2D depiction or `xyz/initial.xyz` after step 01.])

Main outputs: `pdb/initial.pdb`, `psf/initial.psf`, `xyz/initial.xyz`, `out/01_last_command.txt`.

#figure(
  align(left)[
    #block(fill: luma(248), inset: 9pt, radius: 3pt, width: 100%)[
      #set text(8.8pt, font: "Libertinus Mono")
      #raw(
        block: true,
        lang: "text",
        "=== 01: make_res (CLI) ===\n"
          + "Command: mmml make-res --res BENZ --skip-energy-show\n"
          + "...\n"
          + "                    NORMAL TERMINATION BY NORMAL STOP\n"
          + "Saved command: out/01_last_command.txt",
      )
    ]
  ],
  caption: [Tail of `mmml_tutorial/cli/01.log` (CHARMM output abbreviated).],
)

=== Step 02: Build box

Purpose: Pack copies into a cubic cell for classical equilibration or visualization.

```bash
bash 02_make_box_cli.sh
```

#stepfig("step02_packed.png", [Subset of atoms from `pdb/init-packmol.pdb` (two `BENZ` molecules in the default script).])

#figure(
  align(left)[
    #block(fill: luma(248), inset: 9pt, radius: 3pt, width: 100%)[
      #set text(8.8pt, font: "Libertinus Mono")
      #raw(
        block: true,
        lang: "text",
        "=== 02: make_box (CLI) ===\n"
          + "Command: mmml make-box --res BENZ --n 2 --side_length 25.0\n"
          + "...\n"
          + "Saved command: out/02_last_command.txt",
      )
    ]
  ],
  caption: [Excerpt from `cli/02.log`.],
)

=== Step 04: Full DFT with PySCF

Purpose: reference energy, gradient, Hessian, harmonic analysis, and thermo on `xyz/initial.xyz`.

```bash
bash 04_pyscf_dft_cli_full.sh
```

#stepfig("step04_qm_summary.png", [DFT total energy (from `04.log`) and harmonic frequencies when `out/04_results.h5` is present.])

Main outputs: `out/04_results.npz`, `out/04_results.h5`, `pyscf.log`.

#figure(
  align(left)[
    #block(fill: luma(248), inset: 9pt, radius: 3pt, width: 100%)[
      #set text(8.8pt, font: "Libertinus Mono")
      #raw(
        block: true,
        lang: "text",
        "=== 04: DFT full (energy, gradient, hessian, harmonic, thermo) ===\n"
          + "Command: uv run mmml pyscf-dft --mol xyz/initial.xyz --energy --gradient --hessian --harmonic --thermo --output out/04_results\n"
          + "...\n"
          + "total energy = -231.8013573798481\n"
          + "...\n"
          + "Results saved to out/04_results.npz (ML keys) and out/04_results.h5 (all arrays)\n"
          + "Elapsed: 16.68 s",
      )
    ]
  ],
  caption: [Excerpt from `cli/04.log`.],
)

=== Step 06: Normal-mode sampling

Purpose: build a local geometry ensemble from the harmonic model.

```bash
bash 06_normal_mode_sample_cli.sh
```

#stepfig("step06_sampling.png", [Distribution of displacements relative to the first sampled frame (`out/06_sampled.npz`).])

#figure(
  align(left)[
    #block(fill: luma(248), inset: 9pt, radius: 3pt, width: 100%)[
      #set text(8.8pt, font: "Libertinus Mono")
      #raw(
        block: true,
        lang: "text",
        "=== 06: Normal mode sampling ===\n"
          + "Command: mmml normal-mode-sample -i out/04_results.h5 -o out/06_sampled.npz --amplitude 0.1 --max-samples 200\n"
          + "Saved 200 geometries to out/06_sampled.npz\n"
          + "Elapsed: 0.03 s",
      )
    ]
  ],
  caption: [Excerpt from `cli/06.log`.],
)

=== Step 07: Evaluate sampled geometries

Purpose: batch QM labels and ESP grids for ML.

```bash
bash 07_pyscf_evaluate_cli.sh
```

If `out/07_evaluated.npz` already exists, the CLI may write `out/07_evaluated_2.npz` (see log). Step 08 picks the newest `out/07_evaluated*.npz`.

#stepfig("step07_energies.png", [Histogram of total energies across the evaluated batch (`out/07_evaluated*.npz`).])

#figure(
  align(left)[
    #block(fill: luma(248), inset: 9pt, radius: 3pt, width: 100%)[
      #set text(8.8pt, font: "Libertinus Mono")
      #raw(
        block: true,
        lang: "text",
        "=== 07: pyscf-evaluate (energy, forces, dipoles, ESP) ===\n"
          + "Command: uv run mmml pyscf-evaluate -i out/06_sampled.npz -o out/07_evaluated.npz --esp\n"
          + "Evaluating 200 geometries with pyscf-dft (GPU)...\n"
          + "Output exists, using out/07_evaluated_2.npz instead of out/07_evaluated.npz\n"
          + "Saved to out/07_evaluated_2.npz\n"
          + "  R: (200, 12, 3), E: (200,), F: (200, 12, 3)\n"
          + "Elapsed: 502.56 s",
      )
    ]
  ],
  caption: [Excerpt from `cli/07.log`.],
)

=== Step 08: Fix units and split datasets

Purpose: atomic references, unit cleanup, deterministic train/valid/test NPZs.

```bash
bash 08_fix_and_split_cli.sh
```

#stepfig("step08_splits.png", [Structure counts in `out/splits/` after `fix-and-split`.])

#figure(
  align(left)[
    #block(fill: luma(248), inset: 9pt, radius: 3pt, width: 100%)[
      #set text(8.8pt, font: "Libertinus Mono")
      #raw(
        block: true,
        lang: "text",
        "=== 08: fix-and-split (train/valid/test) ===\n"
          + "Command: mmml fix-and-split --efd out/07_evaluated_2.npz --output-dir out/splits",
      )
    ]
  ],
  caption: [The shell script passes the newest matching `out/07_evaluated` NPZ (see `08_fix_and_split_cli.sh`).],
)

Typical outputs:

- `out/splits/energies_forces_dipoles_{train,valid,test}.npz`
- `out/splits/grids_esp_{train,valid,test}.npz`

=== Step 09: Train PhysNet

Purpose: baseline potential on E/F/D (charges + ZBL in the bundled trainer invocation).

```bash
bash 09_physnet_train_cli.sh
```

Checkpoints land under `"$PHYSNET_CKPT_DIR/$PHYSNET_NAME/"` (see `shared.source`).

#stepfig("step09_training_metrics.png", [Orbax metrics from `mmml extract-checkpoint-metrics` when a PhysNet run directory is available; otherwise regenerate assets with placeholders.])

```bash
mmml extract-checkpoint-metrics "$PHYSNET_CKPT_DIR/$PHYSNET_NAME" \
  -o typst_docs/tutorial/assets/cli/step09_training_metrics.png --log-loss
```

*(Adjust the output path if you run the command from another working directory.)*

=== Step 10: Joint PhysNet + DCMNet training

Purpose: co-train on energies, forces, dipoles, and ESP grids.

```bash
bash 10_physnet_dcmnet_train_cli.sh
```

Equivalent command (from the script):

```bash
python -m mmml.cli.misc.train_joint \
  --train-efd out/splits/energies_forces_dipoles_train.npz \
  --train-esp out/splits/grids_esp_train.npz \
  --valid-efd out/splits/energies_forces_dipoles_valid.npz \
  --valid-esp out/splits/grids_esp_valid.npz \
  --use-repo-physnet-params \
  --epochs 1000 \
  --batch-size 1 \
  --name eg_joint \
  --ckpt-dir ~/ckpts --plot-results --plot-freq 0
```

#stepfig("step10_training_metrics.png", [Joint training metrics; generate with `extract-checkpoint-metrics` on `~/ckpts/eg_joint*`.])

Notes:

- Use only one of `--use-repo-physnet-params`, `--physnet-checkpoint`, or `--restart`.
- Smoke test: `--epochs 1`, `--ckpt-dir /tmp/mmml_ckpts`.

=== EF training: rotational augmentation example

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

*(EF ring dataset paths are examples; adapt to your splits.)*

=== Step 11: Pure CHARMM equilibration

```bash
bash 11_run_pycharmm_cli.sh
```

#stepfig("step02_packed.png", [Same packed cell as step 02: this is the geometry family fed to `run-pycharmm` before heat/equilibration outputs are written.])

Outputs: `pdb/{heat,equi}.pdb`, `dcd/{heat,equi}.dcd`, `res/{heat,equi}.res`.

=== Step 12: CHARMM vs ML comparison

```bash
bash 12_charmm_esp_dipole_comparison.sh
```

The script runs `compare_charmm_ml` against `~/ckpts/eg_joint` and `out/splits/*_test.npz`; edit the checkpoint path if your joint run uses another directory.

#stepfig("step12_comparison.png", [Placeholder: replace by parity or GUI screenshots after you run `compare_charmm_ml` and regenerate assets if desired.])

=== Step 13: PhysNet MD sampling

```bash
bash 13_physnet_md.sh
```

#stepfig("step13_md_frame.png", [Last frame of ASE or JAX-MD output under `out/physnet_md/` when trajectories exist.])

=== Step 14: Active learning extraction

```bash
bash 14_active_learning.sh
```

#stepfig("step14_active_learning.png", [Spread of geometries in the active-learning NPZ (`out/activate_learning.npz` by default in `shared.source`).])

Suggested follow-up:

```bash
mmml pyscf-evaluate -i "$ACTIVE_LEARNING_OUT" -o out/md_evaluated.npz --esp
mmml fix-and-split --efd "$PHYSNET_TRAIN_NPZ" out/md_evaluated.npz -o out/splits_extended
```

=== Step 15 / 15.1: Retraining on extended splits

Continue PhysNet training with `--restart` pointing at your previous run; see
`15_physnet_retrain_cli.sh` and `15.1_physnet_retrain_cli.sh` for one or multiple
extension directories (`splits_extended/`).

#stepfig("step01_monomer.png", [Chemistry reminder: extended datasets still target the same `RES` / atom count configured in `shared.source`.])

== `mmml md-system` cutoff schematics (steps 16–19)

These scripts call `mmml md-system` with different ensembles. Logs record a
complementary cutoff schematic PNG; copies are placed in `assets/cli/` when the
generator finds the source files.

```bash
bash 16_md_10mer_free_nve.sh
bash 17_md_10mer_free_nvt.sh
bash 18_md_10mer_pbc_nve.sh
bash 19_md_10mer_pbc_nvt.sh
```

#figure(
  grid(
    columns: 2,
    column-gutter: 0.75em,
    row-gutter: 0.75em,
    image("assets/cli/step_md_free_nve_cutoffs.png", width: 100%),
    image("assets/cli/step_md_free_nvt_cutoffs.png", width: 100%),
    image("assets/cli/step_md_pbc_nve_cutoffs.png", width: 100%),
    image("assets/cli/step_md_pbc_nvt_cutoffs.png", width: 100%),
  ),
  caption: [Cutoff layout figures referenced from `16.log`–`19.log` (paths may differ on your machine).],
)

Periodic NPT and mixed-solvent examples: `20_md_10mer_pbc_npt.sh`, `21_md_system_meoh_tip3_1to1.sh`.

== Optional scripts (`XX_*`)

- `XX_pyscf_dft_cli.sh` — minimal DFT energy demo.
- `XX_pyscf_mp2_cli.sh` — MP2 reference example.

== `shared.source` variables you will likely edit

- `RES`, `PHYSNET_TRAINER`, `PHYSNET_CKPT_DIR`, `PHYSNET_NAME`, `PHYSNET_CHECKPOINT`
- `PHYSNET_NATOMS`, `PHYSNET_EPOCHS`, `PHYSNET_BATCH`
- `PHYSNET_TRAIN_NPZ`, `PHYSNET_VALID_NPZ`
- `PHYSNET_MD_OUT`, `PHYSNET_MD_TRAJ`, `ACTIVE_LEARNING_OUT`
- `MDSYS_*` knobs for `md-system` demos

== Fast start options

=== Option A: bundled full script

```bash
cd mmml_tutorial/cli
bash run_full_training.sh
```

*(Still runs expensive QM; shorten epochs/checkpoints inside the script for demos.)*

=== Option B: manual progression

```bash
cd mmml_tutorial/cli
bash 01_make_res_cli.sh
bash 02_make_box_cli.sh
bash 04_pyscf_dft_cli_full.sh
bash 06_normal_mode_sample_cli.sh
bash 07_pyscf_evaluate_cli.sh
bash 08_fix_and_split_cli.sh
bash 10_physnet_dcmnet_train_cli.sh
```

=== Option C: joint smoke test (splits prepared)

```bash
cd mmml_tutorial/cli
JAX_PLATFORMS=cpu uv run python -m mmml.cli.misc.train_joint \
  --train-efd out/splits/energies_forces_dipoles_train.npz \
  --train-esp out/splits/grids_esp_train.npz \
  --valid-efd out/splits/energies_forces_dipoles_valid.npz \
  --valid-esp out/splits/grids_esp_valid.npz \
  --use-repo-physnet-params \
  --epochs 1 \
  --batch-size 1 \
  --name smoke_joint \
  --ckpt-dir /tmp/mmml_ckpts \
  --plot-freq 0
```

== Caveats

- Script `echo` lines are sometimes shortened; the shell body is authoritative.
- `pyscf-evaluate` may append `_2`, `_3`, … when outputs exist; step 08 always
  consumes the newest file.
- GPU JAX failures before argparse: prefix with `JAX_PLATFORMS=cpu`.
- Portable PhysNet JSON must match the architecture expected by `train_joint`
  for your system size.

== Troubleshooting

=== Joint training parameter merge errors

Healthy startup usually prints:

```text
Loaded PhysNet config from checkpoint
Merging PhysNet params into joint model
Pre-computing edge lists
```

=== PySCF or CHARMM too slow for live sessions

Precompute `out/04_results.h5`, `out/06_sampled.npz`, `out/07_evaluated*.npz`,
and `out/splits/*.npz`, then teach from logs + figures and run only short
training.

== Appendix: water-dimer or other dedicated layouts

Some course materials use a water-dimer directory with `out/splits_dimer/` and
different `train_joint` names. The workflow is the same at the CLI level; only
paths and `NATOMS` change. Start from the appropriate `shared.source` overrides
for that dataset.

== Next additions

- Wall-time table on reference hardware.
- Screenshots from `mmml gui` on trajectories produced in step 13.
