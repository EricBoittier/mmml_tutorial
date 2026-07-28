#!/usr/bin/env python3
"""Pad FORM NPZ to ACEM natoms and concatenate ACEM + FORM for fix-and-split.

fix-and-split requires a shared atom-axis size across --efd files. ACEM is
9 atoms; FORM is 6 — pad FORM with Z=0 / R=0 / F=0 and keep N=6.

Usage (from nma_etc/):
  python 04_pad_merge_npz.py
  python 04_pad_merge_npz.py --pad-natoms 9 -o out/acem_form_merged.npz
"""
from __future__ import annotations

import argparse
from pathlib import Path

import numpy as np

HERE = Path(__file__).resolve().parent
DEFAULT_ACEM = HERE / "acem_mp2_aug-cc-pvtz_16106.npz"
DEFAULT_FORM = HERE / "form_mp2_aug-cc-pvtz_4000.npz"
DEFAULT_OUT = HERE / "out" / "acem_form_merged.npz"


def _pad(data: dict, natoms: int) -> dict:
    out = dict(data)
    n = int(out["R"].shape[0])
    cur = int(out["R"].shape[1])
    if cur == natoms:
        return out
    if cur > natoms:
        raise ValueError(f"cannot pad down: have {cur} atoms, target {natoms}")

    def pad_rf(arr: np.ndarray, fill: float = 0.0) -> np.ndarray:
        shape = (n, natoms) + arr.shape[2:]
        padded = np.full(shape, fill, dtype=arr.dtype)
        padded[:, :cur, ...] = arr
        return padded

    out["R"] = pad_rf(np.asarray(out["R"]))
    out["F"] = pad_rf(np.asarray(out["F"]))
    z = np.asarray(out["Z"])
    z_pad = np.zeros((n, natoms), dtype=z.dtype)
    z_pad[:, :cur] = z
    out["Z"] = z_pad
    # N stays real atom count (mask for PhysNet)
    if "N" in out:
        out["N"] = np.asarray(out["N"]).reshape(n).astype(np.int64)
    return out


def _load(path: Path) -> dict:
    with np.load(path, allow_pickle=True) as z:
        return {k: z[k] for k in z.files}


def merge(acem: Path, form: Path, out: Path, pad_natoms: int) -> None:
    a = _pad(_load(acem), pad_natoms)
    f = _pad(_load(form), pad_natoms)
    keys = sorted(set(a) & set(f))
    merged = {}
    for k in keys:
        merged[k] = np.concatenate([np.asarray(a[k]), np.asarray(f[k])], axis=0)
    out.parent.mkdir(parents=True, exist_ok=True)
    np.savez_compressed(out, **merged)
    print(f"Wrote {out}")
    print(f"  samples: {merged['R'].shape[0]}  padded atoms: {merged['R'].shape[1]}")
    print(f"  N unique: {sorted(set(int(x) for x in merged['N']))}")
    print(f"  keys: {sorted(merged)}")


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--acem", type=Path, default=DEFAULT_ACEM)
    p.add_argument("--form", type=Path, default=DEFAULT_FORM)
    p.add_argument("-o", "--output", type=Path, default=DEFAULT_OUT)
    p.add_argument("--pad-natoms", type=int, default=9)
    args = p.parse_args()
    for path in (args.acem, args.form):
        if not path.is_file():
            raise SystemExit(f"missing NPZ: {path}")
    merge(args.acem, args.form, args.output, args.pad_natoms)


if __name__ == "__main__":
    main()
