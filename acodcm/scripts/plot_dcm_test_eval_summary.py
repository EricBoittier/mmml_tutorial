#!/usr/bin/env python3
"""Aggregate per-run GPU eval outputs using MMML comparison plotting."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

import numpy as np

from mmml.cli.misc.extract_checkpoint_metrics import plot_training_comparison


def load_run_metrics(run_dir: Path) -> dict | None:
    metrics_path = run_dir / "training_metrics.json"
    summary_path = run_dir / "run_summary.json"
    if not metrics_path.is_file():
        return None
    metrics = json.loads(metrics_path.read_text())
    summary = json.loads(summary_path.read_text()) if summary_path.is_file() else {}
    valid_loss = np.asarray(metrics.get("valid_loss", []), dtype=float)
    if valid_loss.size == 0 or np.all(np.isnan(valid_loss)):
        return None
    metrics = {k: np.asarray(v) for k, v in metrics.items()}
    return {"name": run_dir.name, "metrics": metrics, "summary": summary}


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--orbax-root", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--summary-json", type=Path, required=True)
    parser.add_argument(
        "--plot-style",
        default="google",
        help="Matplotlib style preset (nature, xmgrace, google, tron, mpl_classic).",
    )
    args = parser.parse_args()

    runs = []
    for run_dir in sorted(args.orbax_root.iterdir()):
        if not run_dir.is_dir() or run_dir.name == "slurm":
            continue
        item = load_run_metrics(run_dir)
        if item is not None:
            runs.append(item)

    if not runs:
        raise SystemExit(f"No non-empty training_metrics.json found under {args.orbax_root}")

    comparison_runs = [(r["name"], r["metrics"]) for r in runs]
    plot_training_comparison(
        comparison_runs,
        args.output,
        ef_only=True,
        title="dcm-test · validation curves (subsampled checkpoints)",
        verbose=True,
        plot_style=args.plot_style,
    )

    test_rows = []
    for run in runs:
        te = run["summary"].get("test_eval", {})
        if te:
            test_rows.append(
                {
                    "run": run["name"],
                    "energy_mae_kcal_mol": te.get("energy_mae_kcal_mol"),
                    "forces_mae_kcal_mol": te.get("forces_mae_kcal_mol"),
                }
            )

    aggregate = {
        "runs": [r["summary"] for r in runs if r["summary"]],
        "test_eval_table": sorted(
            test_rows,
            key=lambda row: (
                row.get("energy_mae_kcal_mol") is None,
                row.get("energy_mae_kcal_mol", 0),
            ),
        ),
        "comparison_plot": str(args.output),
    }
    args.summary_json.write_text(json.dumps(aggregate, indent=2))
    print(f"Wrote {args.summary_json}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
