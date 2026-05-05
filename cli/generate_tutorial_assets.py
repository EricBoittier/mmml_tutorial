#!/usr/bin/env python3
"""Build PNG figures under typst_docs/tutorial/assets/cli/ for tutorial.typ.

Run from repo root or from this directory after executing pipeline steps 01+:

  cd mmml_tutorial/cli
  uv run python generate_tutorial_assets.py

If outputs are missing, pass --allow-placeholders to emit labeled placeholder PNGs
so `typst compile tutorial.typ` still succeeds.

Optional: after training, generate metrics with mmml and save as:
  typst_docs/tutorial/assets/cli/step10_training_metrics.png
This script will not overwrite an existing step10_training_metrics.png.

Cutoff schematics: logs (16–19.log) may contain absolute paths to PNGs from mmml;
those files are copied when present.
"""

from __future__ import annotations

import argparse
import glob
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np


def _placeholder(path: Path, msg: str) -> None:
    fig, ax = plt.subplots(figsize=(5.5, 2.8))
    ax.text(0.5, 0.5, msg, ha="center", va="center", fontsize=10)
    ax.set_axis_off()
    fig.savefig(path, dpi=150, bbox_inches="tight")
    plt.close(fig)
    print(f"placeholder -> {path}")


def _parse_energy_ha(log_text: str) -> str | None:
    m = re.search(r"total energy = ([-\d.Ee+]+)", log_text)
    return m.group(1) if m else None


def _harmonic_freqs_cm(h5_path: Path) -> np.ndarray | None:
    try:
        import h5py
    except ImportError:
        return None
    try:
        with h5py.File(h5_path, "r") as h5:
            if "harmonic" not in h5:
                return None
            g = h5["harmonic"]
            for key in (
                "freq_wavenumber",
                "freq_cm-1",
                "freq_cm_1",
                "omega",
            ):
                if key in g and isinstance(g[key], h5py.Dataset):
                    return np.asarray(g[key][:], dtype=float)
            for key in g.keys():
                obj = g[key]
                if isinstance(obj, h5py.Dataset) and obj.ndim == 1 and obj.size > 6:
                    try:
                        a = np.asarray(obj[:], dtype=float)
                        if np.nanmax(np.abs(a[np.isfinite(a)])) > 30:
                            return a
                    except (TypeError, ValueError):
                        pass
    except OSError as e:
        print(f"warn: could not read {h5_path}: {e}", file=sys.stderr)
    return None


def _step01_monomer(cli: Path, dest: Path, allow_ph: bool) -> None:
    ok = False
    try:
        from rdkit import Chem
        from rdkit.Chem import Draw

        mol2d = Chem.MolFromSmiles("c1ccccc1")
        if mol2d is not None:
            img = Draw.MolToImage(mol2d, size=(420, 420))
            img.save(dest)
            ok = True
            print(f"wrote {dest} (RDKit 2D, benzene)")
    except Exception as e:
        print(f"step01 RDKit: {e}")

    if ok:
        return

    xyz = cli / "xyz" / "initial.xyz"
    if xyz.is_file():
        try:
            from ase.io import read

            atoms = read(xyz)
            pos = atoms.get_positions()
            z = atoms.get_atomic_numbers()
            fig = plt.figure(figsize=(4.2, 4.2))
            ax = fig.add_subplot(111, projection="3d")
            ax.scatter(pos[:, 0], pos[:, 1], pos[:, 2], c=z, s=85, cmap="tab10")
            ax.set_title("xyz/initial.xyz")
            fig.savefig(dest, dpi=150, bbox_inches="tight")
            plt.close(fig)
            print(f"wrote {dest} (ASE)")
            return
        except Exception as e:
            print(f"step01 ASE: {e}")

    if allow_ph:
        _placeholder(dest, "Install RDKit or run 01_make_res_cli.sh\nto generate xyz/initial.xyz")
    else:
        print("skip step01: no RDKit/xyz", file=sys.stderr)


def _step02_packed(cli: Path, dest: Path, allow_ph: bool) -> None:
    pdb = cli / "pdb" / "init-packmol.pdb"
    if not pdb.is_file():
        if allow_ph:
            _placeholder(dest, "Run 02_make_box_cli.sh\n→ pdb/init-packmol.pdb")
        else:
            print("skip step02: no packmol pdb", file=sys.stderr)
        return
    try:
        from ase.io import read

        atoms = read(str(pdb))
        pos = atoms.get_positions()
        z = atoms.get_atomic_numbers()
        fig = plt.figure(figsize=(5.2, 4.2))
        ax = fig.add_subplot(111, projection="3d")
        n = min(len(pos), 600)
        ax.scatter(
            pos[:n, 0],
            pos[:n, 1],
            pos[:n, 2],
            c=z[:n],
            s=10,
            cmap="tab10",
            alpha=0.65,
        )
        ax.set_title("init-packmol.pdb (subset of atoms)")
        fig.savefig(dest, dpi=150, bbox_inches="tight")
        plt.close(fig)
        print(f"wrote {dest}")
    except Exception as e:
        print(f"step02: {e}")
        if allow_ph:
            _placeholder(dest, "Could not read PDB (ASE?)")


def _step04_qm(cli: Path, log_dir: Path, dest: Path) -> None:
    log = log_dir / "04.log"
    energy = None
    if log.is_file():
        energy = _parse_energy_ha(log.read_text(errors="ignore"))
    h5 = cli / "out" / "04_results.h5"
    freqs = _harmonic_freqs_cm(h5) if h5.is_file() else None

    fig, (ax0, ax1) = plt.subplots(1, 2, figsize=(8.2, 3.2))
    if energy:
        ax0.text(
            0.05,
            0.55,
            f"PBE0/def2-SVP total energy (Ha)\n{energy}",
            fontsize=11,
            family="monospace",
            va="center",
        )
    else:
        ax0.text(0.05, 0.55, "Energy: add cli/04.log or run step 04", fontsize=10, va="center")
    ax0.set_axis_off()

    if freqs is not None and freqs.size > 0:
        fv = freqs[freqs > 40][:36]
        ax1.bar(np.arange(len(fv)), fv, color="steelblue")
        ax1.set_xlabel("mode index (subset)")
        ax1.set_ylabel(r"cm$^{-1}$")
        ax1.set_title("Harmonic frequencies (from 04_results.h5)")
    else:
        ax1.text(0.5, 0.5, "Harmonic modes:\nneed out/04_results.h5", ha="center", va="center")
        ax1.set_axis_off()
    fig.suptitle("Step 04 — QM reference", fontsize=11, y=1.02)
    fig.tight_layout()
    fig.savefig(dest, dpi=150, bbox_inches="tight")
    plt.close(fig)
    print(f"wrote {dest}")


def _step06_sample(cli: Path, dest: Path, allow_ph: bool) -> None:
    p = cli / "out" / "06_sampled.npz"
    if not p.is_file():
        if allow_ph:
            _placeholder(dest, "Run 06_normal_mode_sample_cli.sh\n→ out/06_sampled.npz")
        else:
            print("skip step06", file=sys.stderr)
        return
    z = np.load(p)
    R = z["R"]
    ref = R[0]
    disp = np.linalg.norm(R - ref, axis=(1, 2))
    fig, ax = plt.subplots(figsize=(4.8, 3.2))
    ax.hist(disp, bins=30, color="teal", edgecolor="white")
    ax.set_xlabel(r"$\|R - R_0\|_F$ per frame vs first (Å)")
    ax.set_ylabel("count")
    ax.set_title("Normal-mode sampling spread")
    fig.tight_layout()
    fig.savefig(dest, dpi=150, bbox_inches="tight")
    plt.close(fig)
    print(f"wrote {dest}")


def _step07_energies(cli: Path, dest: Path, allow_ph: bool) -> None:
    cands = sorted(
        cli.glob("out/07_evaluated*.npz"),
        key=lambda x: x.stat().st_mtime,
        reverse=True,
    )
    if not cands:
        if allow_ph:
            _placeholder(dest, "Run 07_pyscf_evaluate_cli.sh\n→ out/07_evaluated*.npz")
        else:
            print("skip step07", file=sys.stderr)
        return
    d = np.load(cands[0])
    if "E" not in d:
        if allow_ph:
            _placeholder(dest, "07_evaluated npz missing E")
        return
    E = np.asarray(d["E"]).ravel()
    fig, ax = plt.subplots(figsize=(4.8, 3.2))
    ax.hist(E, bins=30, color="coral", edgecolor="white")
    ax.set_xlabel("E (stored units)")
    ax.set_ylabel("count")
    ax.set_title(f"Batch QM energies ({cands[0].name})")
    fig.tight_layout()
    fig.savefig(dest, dpi=150, bbox_inches="tight")
    plt.close(fig)
    print(f"wrote {dest}")


def _step08_splits(cli: Path, dest: Path, allow_ph: bool) -> None:
    split_dir = cli / "out" / "splits"
    triple = [
        ("train", "energies_forces_dipoles_train.npz"),
        ("valid", "energies_forces_dipoles_valid.npz"),
        ("test", "energies_forces_dipoles_test.npz"),
    ]
    counts = []
    labels = []
    for lab, name in triple:
        p = split_dir / name
        if not p.is_file():
            continue
        z = np.load(p)
        if "R" in z.files:
            n = z["R"].shape[0]
        elif "E" in z.files:
            n = z["E"].shape[0]
        else:
            continue
        counts.append(n)
        labels.append(lab)
    if not counts:
        if allow_ph:
            _placeholder(dest, "Run 08_fix_and_split_cli.sh\n→ out/splits/")
        else:
            print("skip step08", file=sys.stderr)
        return
    fig, ax = plt.subplots(figsize=(4.8, 3.2))
    ax.bar(labels, counts, color=["#4477aa", "#66ccee", "#228833"])
    ax.set_ylabel("structures")
    ax.set_title("Train / valid / test sizes")
    fig.tight_layout()
    fig.savefig(dest, dpi=150, bbox_inches="tight")
    plt.close(fig)
    print(f"wrote {dest}")


def _copy_cutoff_from_log(log_path: Path, dest: Path, allow_ph: bool) -> None:
    if not log_path.is_file():
        if allow_ph:
            _placeholder(dest, f"Missing {log_path.name} or cutoff PNG path")
        return
    text = log_path.read_text(errors="ignore")
    m = re.search(r"cutoff plot:\s*(\S+\.png)", text)
    if not m:
        if allow_ph:
            _placeholder(dest, f"No cutoff line in {log_path.name}")
        return
    src = Path(m.group(1))
    if src.is_file():
        shutil.copy(src, dest)
        print(f"copied {src.name} -> {dest}")
    elif allow_ph:
        _placeholder(dest, f"Cutoff PNG not found:\n{src}")


def _mmml_prefix() -> list[str]:
    if shutil.which("mmml"):
        return ["mmml"]
    if shutil.which("uv"):
        return ["uv", "run", "mmml"]
    return []


def _step14_active_learning(cli: Path, dest: Path, allow_ph: bool) -> None:
    cands = list(cli.glob("out/*activate_learning*.npz")) + list(cli.glob("out/*active_learning*.npz"))
    p = cands[0] if cands else None
    if p is None or not p.is_file():
        if allow_ph:
            _placeholder(dest, "Run 14_active_learning.sh\n→ e.g. out/activate_learning.npz")
        else:
            print("skip step14: no active-learning npz", file=sys.stderr)
        return
    try:
        z = np.load(p)
        R = np.asarray(z["R"])
        ref = R[0]
        disp = np.linalg.norm(R - ref, axis=(1, 2))
        fig, ax = plt.subplots(figsize=(4.8, 3.2))
        ax.hist(disp, bins=min(25, max(5, R.shape[0] // 4)), color="purple", edgecolor="white")
        ax.set_xlabel(r"$\|R - R_0\|_F$ vs first kept frame (Å)")
        ax.set_ylabel("count")
        ax.set_title(f"Active-learning frames ({p.name})")
        fig.tight_layout()
        fig.savefig(dest, dpi=150, bbox_inches="tight")
        plt.close(fig)
        print(f"wrote {dest}")
    except Exception as e:
        print(f"step14: {e}")
        if allow_ph:
            _placeholder(dest, "Could not plot active-learning NPZ")


def _step13_md_frame(cli: Path, dest: Path, allow_ph: bool) -> None:
    """Final ASE MD frame if 13_physnet_md.sh was run (default out/physnet_md)."""
    candidates = [
        cli / "out" / "physnet_md" / "physnet_ase_final.xyz",
        cli / "out" / "physnet_md" / "physnet_jaxmd.xyz",
    ]
    path = next((p for p in candidates if p.is_file()), None)
    if path is None:
        if allow_ph:
            _placeholder(dest, "Run 13_physnet_md.sh\n→ out/physnet_md/*.xyz")
        else:
            print("skip step13: no MD xyz", file=sys.stderr)
        return
    try:
        from ase.io import read

        atoms = read(str(path), index=-1)
        pos = atoms.get_positions()
        z = atoms.get_atomic_numbers()
        fig = plt.figure(figsize=(4.2, 4.2))
        ax = fig.add_subplot(111, projection="3d")
        ax.scatter(pos[:, 0], pos[:, 1], pos[:, 2], c=z, s=55, cmap="tab10")
        ax.set_title(path.name + " (last frame)")
        fig.savefig(dest, dpi=150, bbox_inches="tight")
        plt.close(fig)
        print(f"wrote {dest}")
    except Exception as e:
        print(f"step13: {e}")
        if allow_ph:
            _placeholder(dest, "Could not read MD xyz")


def _try_checkpoint_plot(ckpt_glob: str, dest: Path) -> None:
    if dest.is_file():
        print(f"keep existing {dest}")
        return
    paths = sorted(glob.glob(ckpt_glob), key=os.path.getmtime, reverse=True)
    if not paths:
        return
    ckpt = paths[0]
    prefix = _mmml_prefix()
    if not prefix:
        print("skip checkpoint plot: mmml/uv not on PATH", file=sys.stderr)
        return
    try:
        subprocess.run(
            prefix
            + [
                "extract-checkpoint-metrics",
                ckpt,
                "-o",
                str(dest),
                "--log-loss",
            ],
            check=True,
            timeout=180,
            capture_output=True,
            text=True,
        )
        print(f"wrote {dest} via extract-checkpoint-metrics")
    except (subprocess.CalledProcessError, subprocess.TimeoutExpired) as e:
        print(f"skip checkpoint plot ({ckpt}): {e}")


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument(
        "--cli-dir",
        type=Path,
        default=Path(__file__).resolve().parent,
        help="mmml_tutorial/cli directory",
    )
    ap.add_argument(
        "--assets-dir",
        type=Path,
        default=Path(__file__).resolve().parent.parent / "typst_docs" / "tutorial" / "assets" / "cli",
    )
    ap.add_argument(
        "--allow-placeholders",
        action="store_true",
        help="Emit placeholder PNGs when inputs are missing",
    )
    ap.add_argument(
        "--physnet-ckpt-glob",
        default=os.path.expanduser("~/ckpts/cybz_physnet*"),
        help="Glob for PhysNet Orbax run dir (optional metrics figure)",
    )
    ap.add_argument(
        "--joint-ckpt-glob",
        default=os.path.expanduser("~/ckpts/eg_joint*"),
        help="Glob for joint training run dir (optional metrics figure)",
    )
    args = ap.parse_args()
    cli: Path = args.cli_dir
    out: Path = args.assets_dir
    out.mkdir(parents=True, exist_ok=True)
    ph = args.allow_placeholders

    _step01_monomer(cli, out / "step01_monomer.png", ph)
    _step02_packed(cli, out / "step02_packed.png", ph)
    _step04_qm(cli, cli, out / "step04_qm_summary.png")
    _step06_sample(cli, out / "step06_sampling.png", ph)
    _step07_energies(cli, out / "step07_energies.png", ph)
    _step08_splits(cli, out / "step08_splits.png", ph)

    _copy_cutoff_from_log(cli / "16.log", out / "step_md_free_nve_cutoffs.png", ph)
    _copy_cutoff_from_log(cli / "17.log", out / "step_md_free_nvt_cutoffs.png", ph)
    _copy_cutoff_from_log(cli / "18.log", out / "step_md_pbc_nve_cutoffs.png", ph)
    _copy_cutoff_from_log(cli / "19.log", out / "step_md_pbc_nvt_cutoffs.png", ph)

    _step13_md_frame(cli, out / "step13_md_frame.png", ph)
    _step14_active_learning(cli, out / "step14_active_learning.png", ph)

    _try_checkpoint_plot(args.physnet_ckpt_glob, out / "step09_training_metrics.png")
    _try_checkpoint_plot(args.joint_ckpt_glob, out / "step10_training_metrics.png")

    if not (out / "step09_training_metrics.png").is_file() and ph:
        _placeholder(
            out / "step09_training_metrics.png",
            "After PhysNet training:\nmmml extract-checkpoint-metrics <run_dir> -o step09_training_metrics.png --log-loss",
        )
    if not (out / "step10_training_metrics.png").is_file() and ph:
        _placeholder(
            out / "step10_training_metrics.png",
            "After joint training:\nmmml extract-checkpoint-metrics <run_dir> -o step10_training_metrics.png --log-loss",
        )

    s12 = out / "step12_comparison.png"
    if not s12.is_file():
        _placeholder(
            s12,
            "After compare_charmm_ml:\ninspect parity plots / HDF5 in out-dir",
        )

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
