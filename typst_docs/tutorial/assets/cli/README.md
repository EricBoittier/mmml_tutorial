# Tutorial figures (`assets/cli/`)

PNG assets for [`tutorial.typ`](../tutorial.typ). Regenerate after running CLI steps so plots match your machine:

```bash
cd mmml_tutorial/cli
uv run python generate_tutorial_assets.py
```

- With incomplete outputs, add `--allow-placeholders` so missing steps still produce labeled placeholder images (useful for `typst compile` in CI).

Training curves (steps 09–10) are created automatically only when `mmml` (or `uv run mmml`) can run and a matching Orbax directory exists under the globs passed to `generate_tutorial_assets.py`. Otherwise create them manually:

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
