# Tutorial figures (`assets/cli/`)

PNG assets for [`tutorial.typ`](../tutorial.typ). Molecular structure panels use **ASE** `plot_atoms` (matplotlib), not RDKit. Regenerate after running CLI steps so plots match your machine:

```bash
cd mmml_tutorial/cli
uv run python generate_tutorial_assets.py
```

- With incomplete outputs, add `--allow-placeholders` so missing steps still produce labeled placeholder images (useful for `typst compile` in CI).

**Checkpoint path for scripts:** after `train_joint`, use
`--write-checkpoint-path out/last_joint_checkpoint.txt` (see
`10_physnet_dcmnet_train_cli.sh`). That file is a single absolute directory path
(`ckpt-dir`/`name`). `generate_tutorial_assets.py` reads it before globbing
`~/ckpts/eg_joint*`, and rewrites it when metrics extraction succeeds. For
PhysNet, create `out/last_physnet_checkpoint.txt` the same way or let the asset
script fill it after a successful extract.

Training curves (steps 09–10) are created automatically only when `mmml` (or `uv run mmml`) can run and the checkpoint directory contains Orbax `epoch-*` folders (layout depends on trainer). Joint `train_joint` checkpoints are often pickle-only; `extract-checkpoint-metrics` may skip those. Regenerate plots with:

```bash
uv run python generate_tutorial_assets.py --force-metrics
```

Otherwise create metrics manually:

```bash
uv run mmml extract-checkpoint-metrics "$HOME/ckpts/<run_dir>" \
  -o ../../typst_docs/tutorial/assets/cli/step09_training_metrics.png --log-loss
```

MD cutoff schematics are copied from paths embedded in `16.log`–`19.log` when those PNG files are still present on disk.

Then compile:

```bash
cd mmml_tutorial/typst_docs/tutorial
typst compile tutorial.typ
```
