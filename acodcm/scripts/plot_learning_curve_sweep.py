#!/usr/bin/env python3
"""Aggregate learning-curve sweep results into comparison plots and JSON tables."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

import numpy as np

from mmml.cli.misc.extract_checkpoint_metrics import (
    ComparisonRunSpec,
    collect_scaling_points,
    plot_learning_curve_scaling,
    plot_training_comparison,
)


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


def _n_train_sort_key(value) -> int:
    if isinstance(value, int):
        return value
    text = str(value)
    if text.startswith("n"):
        return int(text[1:])
    return int(text)


def build_test_mae_table(runs: list[dict]) -> list[list[str]]:
    """Pivot hold-out test MAE by n_train with one column per repeat."""
    grouped: dict[int, dict[int, dict]] = {}
    repeats: set[int] = set()
    for run in runs:
        summary = run["summary"]
        n_train = summary.get("n_train") or _n_train_sort_key(run["parent"])
        repeat = int(summary.get("repeat") or int(str(run["name"]).lstrip("r") or 0))
        te = summary.get("test_eval", {})
        if not te:
            continue
        grouped.setdefault(int(n_train), {})[repeat] = te
        repeats.add(repeat)

    rep_list = sorted(repeats)
    headers = ["n_train"] + [f"r{r} E" for r in rep_list] + [f"r{r} F" for r in rep_list]
    rows: list[list[str]] = []
    for n_train in sorted(grouped):
        by_rep = grouped[n_train]
        row = [str(n_train)]
        for repeat in rep_list:
            te = by_rep.get(repeat, {})
            e = te.get("energy_mae_kcal_mol")
            row.append(f"{e:.3f}" if e is not None else "—")
        for repeat in rep_list:
            te = by_rep.get(repeat, {})
            f = te.get("forces_mae_kcal_mol")
            row.append(f"{f:.3f}" if f is not None else "—")
        rows.append(row)
    return [headers, *rows]


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

        comparison_runs: list[ComparisonRunSpec] = []
        for key in sorted(grouped, key=_n_train_sort_key):
            reps = grouped[key]
            for rep in reps:
                label = f"{rep['parent']}/{rep['name']}"
                repeat = rep["summary"].get("repeat")
                if repeat is None and str(rep["name"]).startswith("r"):
                    repeat = int(str(rep["name"])[1:])
                comparison_runs.append(
                    ComparisonRunSpec(
                        name=label,
                        metrics=rep["metrics"],
                        group=str(rep["parent"]),
                        repeat=int(repeat) if repeat is not None else None,
                    )
                )

        summary_table = build_test_mae_table(runs)
        out_png = args.output.parent / f"comparison_{dataset}.png"
        plot_training_comparison(
            comparison_runs,
            out_png,
            ef_only=True,
            title=f"{dataset} learning curve sweep (valid metrics)",
            plot_style=args.plot_style,
            summary_table=summary_table,
            summary_table_title="Hold-out test MAE (kcal/mol)",
            color_by_group=True,
            linestyle_by_repeat=True,
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
            "scaling_plot": str(args.output.parent / f"scaling_{dataset}.png"),
            "test_eval_table": sorted(
                test_rows,
                key=lambda r: (r.get("n_train") or 0, r.get("repeat") or 0),
            ),
            "scaling_points": [
                {
                    "n_train": p.n_train,
                    "repeat": p.repeat,
                    "inv_sqrt_n": p.inv_sqrt_n,
                    **p.values,
                }
                for p in collect_scaling_points(runs)
            ],
        }

        plot_learning_curve_scaling(
            runs,
            args.output.parent / f"scaling_{dataset}.png",
            title=f"{dataset} scaling: ln(metric) vs 1/sqrt(n_train)",
            plot_style=args.plot_style,
            verbose=True,
        )

    args.summary_json.write_text(json.dumps(aggregate, indent=2))
    print(f"Wrote {args.summary_json}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
