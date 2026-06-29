#!/usr/bin/env python3
"""Aggregate learning-curve sweep results into comparison plots and JSON tables."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

import numpy as np

from mmml.cli.misc.extract_checkpoint_metrics import plot_training_comparison


def load_run(out_dir: Path) -> dict | None:
    metrics_path = out_dir / "training_metrics.json"
    summary_path = out_dir / "run_summary.json"
    if not metrics_path.is_file():
        return None
    metrics = {k: np.asarray(v) for k, v in json.loads(metrics_path.read_text()).items()}
    valid_loss = metrics.get("valid_loss", np.array([]))
    if valid_loss.size == 0 or np.all(np.isnan(valid_loss)):
        return None
    summary = json.loads(summary_path.read_text()) if summary_path.is_file() else {}
    return {"name": out_dir.name, "parent": out_dir.parent.name, "metrics": metrics, "summary": summary}


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--eval-root", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--summary-json", type=Path, required=True)
    parser.add_argument("--plot-style", default="google")
    args = parser.parse_args()

    by_dataset: dict[str, list[dict]] = {"aco": [], "dcm": []}
    for dataset_dir in sorted(args.eval_root.iterdir()):
        if not dataset_dir.is_dir() or dataset_dir.name not in by_dataset:
            continue
        for n_dir in sorted(dataset_dir.iterdir()):
            if not n_dir.is_dir() or not n_dir.name.startswith("n"):
                continue
            for r_dir in sorted(n_dir.iterdir()):
                if not r_dir.is_dir():
                    continue
                item = load_run(r_dir)
                if item is not None:
                    by_dataset[dataset_dir.name].append(item)

    aggregate: dict = {"datasets": {}}
    args.output.parent.mkdir(parents=True, exist_ok=True)

    for dataset, runs in by_dataset.items():
        if not runs:
            continue
        # Group by n_train, average valid loss curves across repeats for overview plot
        grouped: dict[str, list] = {}
        for run in runs:
            n_train = run["summary"].get("n_train") or run["parent"]
            grouped.setdefault(str(n_train), []).append(run)

        comparison_runs = []
        for key in sorted(grouped, key=lambda x: int(str(x).replace("n", "")) if str(x).startswith("n") else int(x)):
            reps = grouped[key]
            # Use first repeat for overlay (or could average)
            for rep in reps:
                label = f"{rep['parent']}/{rep['name']}"
                comparison_runs.append((label, rep["metrics"]))

        out_png = args.output.parent / f"comparison_{dataset}.png"
        plot_training_comparison(
            comparison_runs,
            out_png,
            ef_only=True,
            title=f"{dataset} learning curve sweep (valid metrics)",
            plot_style=args.plot_style,
            verbose=True,
        )

        test_rows = []
        for run in runs:
            te = run["summary"].get("test_eval", {})
            if te:
                test_rows.append(
                    {
                        "run": f"{run['parent']}/{run['name']}",
                        "n_train": run["summary"].get("n_train"),
                        "repeat": run["summary"].get("repeat"),
                        "energy_mae_kcal_mol": te.get("energy_mae_kcal_mol"),
                        "forces_mae_kcal_mol": te.get("forces_mae_kcal_mol"),
                    }
                )
        aggregate["datasets"][dataset] = {
            "comparison_plot": str(out_png),
            "test_eval_table": sorted(
                test_rows,
                key=lambda r: (r.get("n_train") or 0, r.get("repeat") or 0),
            ),
        }

    args.summary_json.write_text(json.dumps(aggregate, indent=2))
    print(f"Wrote {args.summary_json}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
