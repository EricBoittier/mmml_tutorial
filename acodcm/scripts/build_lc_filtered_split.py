#!/usr/bin/env python3
"""Build fixed train/valid NPZ splits with outlier structures removed."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

import jax
import numpy as np

from mmml.cli.misc.diagnose_learning_curve_outliers import (
    enrich_bad_samples,
    flag_run_outliers,
    load_runs,
    warmup_seed_permutations,
)


def seed_for_repeat(repeat: int) -> int:
    return 42 + repeat * 1000


def n_valid_for(n_train: int) -> int:
    return n_train * 300 // 8000


def reproduce_train_valid_indices(seed: int, n_train: int, n_valid: int, n_total: int) -> tuple[np.ndarray, np.ndarray]:
    data_key = jax.random.split(jax.random.PRNGKey(seed), 2)[0]
    perm = np.asarray(jax.random.choice(data_key, n_total, shape=(n_total,), replace=False), dtype=np.int64)
    return perm[:n_train], perm[n_train : n_train + n_valid]


def subset_npz(src: Path, indices: list[int] | np.ndarray, out: Path) -> None:
    data = np.load(src, allow_pickle=True)
    idx = np.asarray(indices, dtype=np.int64)
    out.parent.mkdir(parents=True, exist_ok=True)
    np.savez_compressed(out, **{key: data[key][idx] for key in data.files})


def choose_exclude_indices(
    *,
    mode: str,
    train_indices: np.ndarray,
    energies: np.ndarray,
    energy_threshold: float,
    eval_root: Path | None,
    dataset: str,
    train_npz: Path,
    seed: int,
) -> list[int]:
    train_set = set(int(i) for i in train_indices)
    if mode == "bad-energy":
        return sorted(int(i) for i in train_indices if float(energies[i]) > energy_threshold)
    if mode == "suspects":
        if eval_root is None:
            raise ValueError("--eval-root is required for --mode suspects")
        runs = load_runs(eval_root, dataset)
        flag_run_outliers(runs)
        n_total = len(energies)
        warmup_seed_permutations({r.seed for r in runs}, n_total, verbose=False)
        candidates = enrich_bad_samples(runs, train_npz=train_npz, top_k=200)
        return sorted(
            int(row["index"])
            for row in candidates
            if int(row["index"]) in train_set and seed in row.get("outlier_seeds", [])
        )
    raise ValueError(f"Unknown mode: {mode}")


def backfill_train_indices(
    perm: np.ndarray,
    train_indices: list[int],
    exclude: set[int],
    *,
    n_train: int,
    n_valid: int,
) -> list[int]:
    kept = [int(i) for i in train_indices if int(i) not in exclude]
    used = set(kept)
    pool = [int(i) for i in perm[n_train + n_valid :] if int(i) not in exclude and int(i) not in used]
    while len(kept) < n_train and pool:
        kept.append(pool.pop(0))
    if len(kept) < n_train:
        raise RuntimeError(
            f"Could not backfill train split to n_train={n_train} after removing {len(exclude)} outliers"
        )
    return kept[:n_train]


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dataset", default="aco")
    parser.add_argument("--n-train", type=int, default=3200)
    parser.add_argument("--repeat", type=int, default=3)
    parser.add_argument("--seed", type=int, default=None)
    parser.add_argument(
        "--train-npz",
        type=Path,
        default=Path("out/splits/aco/energies_forces_dipoles_train.npz"),
    )
    parser.add_argument("--eval-root", type=Path, default=Path("out/eval/learning_curve/e1000"))
    parser.add_argument(
        "--out-dir",
        type=Path,
        default=None,
        help="Output directory (default: out/splits/<dataset>/lc_n<n>_r<repeat>_no_outliers)",
    )
    parser.add_argument(
        "--mode",
        choices=("bad-energy", "suspects"),
        default="bad-energy",
        help="bad-energy: drop high-energy cluster; suspects: diagnose-lc-outliers suspects",
    )
    parser.add_argument(
        "--energy-threshold",
        type=float,
        default=-70.0,
        help="Remove train samples with E above this value (kcal/mol) in bad-energy mode",
    )
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    seed = args.seed if args.seed is not None else seed_for_repeat(args.repeat)
    n_valid = n_valid_for(args.n_train)
    out_dir = args.out_dir
    if out_dir is None:
        out_dir = Path(f"out/splits/{args.dataset}/lc_n{args.n_train}_r{args.repeat}_no_outliers")

    src = args.train_npz.resolve()
    data = np.load(src, allow_pickle=True)
    n_total = len(data["E"])
    perm = np.asarray(
        jax.random.choice(
            jax.random.split(jax.random.PRNGKey(seed), 2)[0],
            n_total,
            shape=(n_total,),
            replace=False,
        ),
        dtype=np.int64,
    )
    train_idx, valid_idx = reproduce_train_valid_indices(seed, args.n_train, n_valid, n_total)
    exclude = choose_exclude_indices(
        mode=args.mode,
        train_indices=train_idx,
        energies=np.asarray(data["E"], dtype=float),
        energy_threshold=args.energy_threshold,
        eval_root=args.eval_root.resolve() if args.eval_root else None,
        dataset=args.dataset,
        train_npz=src,
        seed=seed,
    )
    exclude_set = set(exclude)
    new_train = backfill_train_indices(
        perm,
        train_idx.tolist(),
        exclude_set,
        n_train=args.n_train,
        n_valid=n_valid,
    )

    train_out = out_dir / "train.npz"
    valid_out = out_dir / "valid.npz"
    manifest_out = out_dir / "manifest.json"
    subset_npz(src, new_train, train_out)
    subset_npz(src, valid_idx.tolist(), valid_out)

    manifest = {
        "dataset": args.dataset,
        "n_train": args.n_train,
        "n_valid": n_valid,
        "repeat": args.repeat,
        "seed": seed,
        "mode": args.mode,
        "energy_threshold": args.energy_threshold,
        "removed_indices": [int(i) for i in exclude],
        "n_removed": len(exclude),
        "train_npz": str(train_out),
        "valid_npz": str(valid_out),
    }
    manifest_out.write_text(json.dumps(manifest, indent=2))

    print(f"Wrote {train_out} ({args.n_train} structures)")
    print(f"Wrote {valid_out} ({n_valid} structures)")
    print(f"Removed {len(exclude)} outliers ({args.mode})")
    print(f"Manifest: {manifest_out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
