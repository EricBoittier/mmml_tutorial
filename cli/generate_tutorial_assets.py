#!/usr/bin/env python3
"""Build PNG figures under typst_docs/tutorial/assets/cli/ for tutorial.typ.

Structure images use ASE `plot_atoms` (2D matplotlib projection), not RDKit.

Run from repo root or from this directory after executing pipeline steps 01+:

  cd mmml_tutorial/cli
  uv run python generate_tutorial_assets.py

If outputs are missing, pass --allow-placeholders to emit labeled placeholder PNGs
so `typst compile tutorial.typ` still succeeds.

Training runs can pass `--write-checkpoint-path out/last_joint_checkpoint.txt` to
`train_joint` (see `10_physnet_dcmnet_train_cli.sh`). This script reads that
one-line manifest before falling back to globs. For step10 (joint), it prefers
`history.json` in that run directory (written each epoch by `train_joint`); if
that is missing, it falls back to `mmml extract-checkpoint-metrics`. The manifest
is refreshed after a successful step10 or step09 plot. Use `--force-metrics` to
rebuild step09/step10 PNGs even when they already exist.

Optional: save metrics as typst_docs/tutorial/assets/cli/step{09,10}_training_metrics.png

Cutoff schematics: logs (16–19.log) may contain absolute paths to PNGs from mmml;
those files are copied when present.
"""

from __future__ import annotations

import argparse
import glob
import json
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

try:
    from ase.visualize.plot import plot_atoms as _ase_plot_atoms
except ImportError:
    _ase_plot_atoms = None  # type: ignore[misc, assignment]


def _save_plot_atoms(
    atoms,
    dest: Path,
    *,
    title: str | None = None,
    rotation: str = "45x,-35y,0z",
    radii: float = 0.45,
    figsize: tuple[float, float] = (4.6, 4.6),
) -> None:
    """Render `atoms` with ASE plot_atoms and save PNG."""
    if _ase_plot_atoms is None:
        raise RuntimeError("ase.visualize.plot.plot_atoms not available")
    fig, ax = plt.subplots(figsize=figsize)
    _ase_plot_atoms(atoms, ax=ax, radii=radii, rotation=rotation)
    ax.set_axis_off()
    if title:
        fig.suptitle(title, fontsize=10, y=0.98)
    fig.tight_layout()
    fig.savefig(dest, dpi=150, bbox_inches="tight")
    plt.close(fig)


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
    xyz = cli / "xyz" / "initial.xyz"
    try:
        from ase.build import molecule
        from ase.io import read

        if xyz.is_file():
            atoms = read(xyz)
            label = "xyz/initial.xyz"
        else:
            atoms = molecule("C6H6")
            label = "C6H6 (ASE built-in; run 01 for real RES)"
        _save_plot_atoms(
            atoms,
            dest,
            title=label,
            rotation="35x,-25y,0z",
            radii=0.5,
        )
        print(f"wrote {dest} (ASE plot_atoms, {label})")
        return
    except Exception as e:
        print(f"step01: {e}")

    if allow_ph:
        _placeholder(
            dest,
            "Install ASE; run 01_make_res_cli.sh\nfor xyz/initial.xyz, or use built-in C6H6.",
        )
    else:
        print("skip step01: ASE/xyz", file=sys.stderr)


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
        n = min(len(atoms), 140)
        sub = atoms[:n] if n < len(atoms) else atoms
        _save_plot_atoms(
            sub,
            dest,
            title=f"init-packmol.pdb ({len(sub)} of {len(atoms)} atoms)",
            rotation="25x,-40y,0z",
            radii=0.35,
            figsize=(5.0, 4.2),
        )
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


def _read_ckpt_manifest(manifest: Path) -> str | None:
    """First line of manifest if it points to an existing directory."""
    if not manifest.is_file():
        return None
    try:
        text = manifest.read_text(encoding="utf-8").strip()
    except OSError:
        return None
    if not text:
        return None
    line = text.splitlines()[0].strip()
    if not line:
        return None
    p = Path(line).expanduser()
    if p.is_dir():
        return str(p.resolve())
    return None


def _resolve_ckpt_dir(manifest: Path | None, glob_pat: str) -> str | None:
    """Prefer manifest from training (`train_joint --write-checkpoint-path`); else newest glob match."""
    if manifest is not None:
        got = _read_ckpt_manifest(manifest)
        if got:
            print(f"checkpoint dir (manifest {manifest.name}): {got}")
            return got
    paths = sorted(
        glob.glob(os.path.expanduser(glob_pat)),
        key=os.path.getmtime,
        reverse=True,
    )
    return paths[0] if paths else None


def _find_joint_history_json(run_root: Path) -> Path | None:
    """`train_joint` writes `history.json` under `ckpt_dir / name` (the run root)."""
    direct = run_root / "history.json"
    if direct.is_file():
        return direct
    nested = list(run_root.glob("*/history.json"))
    if nested:
        return max(nested, key=lambda p: p.stat().st_mtime)
    return None


def _plot_joint_history_dict(
    history: dict,
    dest: Path,
    *,
    ckpt_name: str,
    log_loss: bool = True,
) -> None:
    """Plot curves from `train_joint` history.json (same units as training logs)."""
    train_loss = history.get("train_loss") or []
    val_loss = history.get("val_loss") or []
    if not train_loss or not val_loss:
        raise ValueError("history.json needs non-empty train_loss and val_loss")

    def _series(key: str) -> list[float]:
        v = history.get(key)
        if not v:
            return []
        return [float(x) for x in v]

    val_e = _series("val_energy_mae")
    val_f = _series("val_forces_mae")
    val_d = _series("val_dipole_mae")
    val_esp = _series("val_esp_mae")
    epoch_times = _series("epoch_times")

    lengths = [len(train_loss), len(val_loss)]
    for s in (val_e, val_f, val_d, val_esp, epoch_times):
        if s:
            lengths.append(len(s))
    m = min(lengths)
    if m < 1:
        raise ValueError("no aligned epoch rows in history")

    train_loss = np.asarray(train_loss[:m], dtype=float)
    val_loss = np.asarray(val_loss[:m], dtype=float)
    epochs = np.arange(1, m + 1)

    eV_to_kcal = 23.0605
    Ha_to_kcal = 627.503

    def _take(s: list[float], fill: float = np.nan) -> np.ndarray:
        if not s:
            return np.full(m, fill)
        a = np.asarray(s[:m], dtype=float)
        if a.size < m:
            pad = np.full(m - a.size, fill)
            a = np.concatenate([a, pad])
        return a

    energy_kcal = _take(val_e) * eV_to_kcal
    forces_kcal = _take(val_f) * eV_to_kcal
    dipole_ea = _take(val_d)
    esp_kcal = _take(val_esp) * Ha_to_kcal
    times = _take(epoch_times, fill=0.0)

    best_so_far = np.minimum.accumulate(val_loss)
    improvement = (val_loss[0] - val_loss) / max(val_loss[0], 1e-12) * 100.0

    fig = plt.figure(figsize=(18, 12))
    gs = fig.add_gridspec(3, 3, hspace=0.35, wspace=0.3)

    ax1 = fig.add_subplot(gs[0, :2])
    ax1.plot(epochs, train_loss, "o-", color="#0072B2", linewidth=2.5, markersize=6, alpha=0.8, label="Training loss")
    ax1.plot(epochs, val_loss, "s-", color="#D55E00", linewidth=2.5, markersize=6, alpha=0.8, label="Validation loss")
    bi = int(np.argmin(val_loss))
    ax1.scatter(
        epochs[bi],
        val_loss[bi],
        s=300,
        color="gold",
        edgecolor="black",
        linewidth=3,
        zorder=5,
        marker="*",
        label="Best val",
    )
    ax1.set_xlabel("Epoch", fontsize=13, fontweight="bold")
    ax1.set_ylabel("Loss", fontsize=13, fontweight="bold")
    ax1.set_title("Training progress (train_joint history.json)", fontsize=14, fontweight="bold")
    if log_loss:
        ax1.set_yscale("log")
    ax1.legend(fontsize=11, loc="best")
    ax1.grid(True, alpha=0.3)

    ax2 = fig.add_subplot(gs[0, 2])
    ax2.plot(epochs, best_so_far, "o-", color="#009E73", linewidth=2.5, markersize=6, alpha=0.8)
    ax2.set_xlabel("Epoch", fontsize=11)
    ax2.set_ylabel("Best val loss so far", fontsize=11)
    ax2.set_title("Best model (cum. min)", fontsize=12, fontweight="bold")
    ax2.grid(True, alpha=0.3)
    if log_loss:
        ax2.set_yscale("log")

    ax3 = fig.add_subplot(gs[1, 0])
    if np.any(np.isfinite(energy_kcal) & (energy_kcal > 0)):
        ax3.plot(epochs, energy_kcal, "s-", color="#E69F00", linewidth=2.5, markersize=6, alpha=0.8)
        bj = int(np.nanargmin(np.where(energy_kcal > 0, energy_kcal, np.inf)))
        ax3.scatter(epochs[bj], energy_kcal[bj], s=200, color="gold", edgecolor="black", linewidth=2, zorder=5, marker="*")
    ax3.set_xlabel("Epoch", fontsize=11)
    ax3.set_ylabel("Energy MAE (kcal/mol)", fontsize=11)
    ax3.set_title("Energy (val)", fontsize=12, fontweight="bold")
    ax3.grid(True, alpha=0.3)
    if log_loss:
        ax3.set_yscale("log")

    ax4 = fig.add_subplot(gs[1, 1])
    if np.any(np.isfinite(forces_kcal) & (forces_kcal > 0)):
        ax4.plot(epochs, forces_kcal, "s-", color="#CC79A7", linewidth=2.5, markersize=6, alpha=0.8)
        bj = int(np.nanargmin(np.where(forces_kcal > 0, forces_kcal, np.inf)))
        ax4.scatter(epochs[bj], forces_kcal[bj], s=200, color="gold", edgecolor="black", linewidth=2, zorder=5, marker="*")
    ax4.set_xlabel("Epoch", fontsize=11)
    ax4.set_ylabel("Forces MAE (kcal/mol/Å)", fontsize=11)
    ax4.set_title("Forces (val)", fontsize=12, fontweight="bold")
    ax4.grid(True, alpha=0.3)
    if log_loss:
        ax4.set_yscale("log")

    ax5 = fig.add_subplot(gs[1, 2])
    if np.any(np.isfinite(dipole_ea) & (dipole_ea > 0)):
        ax5.plot(epochs, dipole_ea, "s-", color="#56B4E9", linewidth=2.5, markersize=6, alpha=0.8)
        bj = int(np.nanargmin(np.where(dipole_ea > 0, dipole_ea, np.inf)))
        ax5.scatter(epochs[bj], dipole_ea[bj], s=200, color="gold", edgecolor="black", linewidth=2, zorder=5, marker="*")
    ax5.set_xlabel("Epoch", fontsize=11)
    ax5.set_ylabel("Dipole MAE (e·Å)", fontsize=11)
    ax5.set_title("Dipole PhysNet (val)", fontsize=12, fontweight="bold")
    ax5.grid(True, alpha=0.3)
    if log_loss:
        ax5.set_yscale("log")

    ax6 = fig.add_subplot(gs[2, 0])
    if np.any(np.isfinite(esp_kcal) & (esp_kcal > 0)):
        ax6.plot(epochs, esp_kcal, "s-", color="#999999", linewidth=2.5, markersize=6, alpha=0.8)
        bj = int(np.nanargmin(np.where(esp_kcal > 0, esp_kcal, np.inf)))
        ax6.scatter(epochs[bj], esp_kcal[bj], s=200, color="gold", edgecolor="black", linewidth=2, zorder=5, marker="*")
    ax6.set_xlabel("Epoch", fontsize=11)
    ax6.set_ylabel("ESP RMSE DCMNet ((kcal/mol)/e)", fontsize=11)
    ax6.set_title("ESP (val)", fontsize=12, fontweight="bold")
    ax6.grid(True, alpha=0.3)
    if log_loss:
        ax6.set_yscale("log")

    ax7 = fig.add_subplot(gs[2, 1])
    if np.any(times > 0):
        ax7.bar(epochs, times, color="#F0E442", alpha=0.85, width=0.6)
    ax7.set_xlabel("Epoch", fontsize=11)
    ax7.set_ylabel("Wall time (s)", fontsize=11)
    ax7.set_title("Epoch duration", fontsize=12, fontweight="bold")
    ax7.grid(True, axis="y", alpha=0.3)

    ax8 = fig.add_subplot(gs[2, 2])
    if m > 1:
        ax8.plot(epochs, improvement, "o-", color="#009E73", linewidth=2.5, markersize=6, alpha=0.8)
        ax8.axhline(0, color="red", linestyle="--", linewidth=2, alpha=0.5)
        ax8.fill_between(epochs, 0, improvement, alpha=0.2, color="#009E73")
    ax8.set_xlabel("Epoch", fontsize=11)
    ax8.set_ylabel("Improvement from start (%)", fontsize=11)
    ax8.set_title("Val loss improvement", fontsize=12, fontweight="bold")
    ax8.grid(True, alpha=0.3)

    plt.suptitle(f"Joint training: {ckpt_name}\n{m} epochs (history.json)", fontsize=16, fontweight="bold")
    dest.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(dest, dpi=300, bbox_inches="tight")
    plt.close(fig)


def _try_joint_training_metrics(
    ckpt: str | None,
    dest: Path,
    *,
    manifest_out: Path | None,
    force: bool,
) -> None:
    """Prefer train_joint `history.json`; fall back to Orbax extract-checkpoint-metrics."""
    if not ckpt:
        return
    if force and dest.is_file():
        dest.unlink()
    if dest.is_file():
        print(f"keep existing {dest}")
        return
    root = Path(ckpt).resolve()
    hist_path = _find_joint_history_json(root)
    if hist_path is not None:
        try:
            history = json.loads(hist_path.read_text(encoding="utf-8"))
            _plot_joint_history_dict(history, dest, ckpt_name=root.name)
            print(f"wrote {dest} from train_joint history ({hist_path})")
            if manifest_out is not None:
                manifest_out.parent.mkdir(parents=True, exist_ok=True)
                manifest_out.write_text(str(root) + "\n", encoding="utf-8")
                print(f"wrote manifest for scripts: {manifest_out.resolve()}")
            return
        except (OSError, json.JSONDecodeError, ValueError, TypeError) as e:
            print(f"train_joint history plot failed ({hist_path}): {e}", file=sys.stderr)
    _try_checkpoint_plot(ckpt, dest, manifest_out=manifest_out, force=False)


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
        _save_plot_atoms(
            atoms,
            dest,
            title=f"{path.name} (last frame)",
            rotation="35x,-30y,0z",
            radii=0.48,
        )
        print(f"wrote {dest}")
    except Exception as e:
        print(f"step13: {e}")
        if allow_ph:
            _placeholder(dest, "Could not read MD xyz")


def _try_checkpoint_plot(
    ckpt: str | None,
    dest: Path,
    *,
    manifest_out: Path | None,
    force: bool,
) -> None:
    if not ckpt:
        return
    if force and dest.is_file():
        dest.unlink()
    if dest.is_file():
        print(f"keep existing {dest}")
        return
    prefix = _mmml_prefix()
    if not prefix:
        print("skip checkpoint plot: mmml/uv not on PATH", file=sys.stderr)
        return
    ckpt_resolved = str(Path(ckpt).resolve())
    try:
        subprocess.run(
            prefix
            + [
                "extract-checkpoint-metrics",
                ckpt_resolved,
                "-o",
                str(dest),
                "--log-loss",
            ],
            check=True,
            timeout=180,
            capture_output=True,
            text=True,
        )
        print(f"wrote {dest} via extract-checkpoint-metrics ({ckpt_resolved})")
        if manifest_out is not None:
            manifest_out.parent.mkdir(parents=True, exist_ok=True)
            manifest_out.write_text(ckpt_resolved + "\n", encoding="utf-8")
            print(f"wrote manifest for scripts: {manifest_out.resolve()}")
    except (subprocess.CalledProcessError, subprocess.TimeoutExpired) as e:
        print(f"skip checkpoint plot ({ckpt_resolved}): {e}")


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
    ap.add_argument(
        "--force-metrics",
        action="store_true",
        help="Regenerate step09/step10 PNGs even if they already exist",
    )
    args = ap.parse_args()
    cli: Path = args.cli_dir
    out: Path = args.assets_dir
    out.mkdir(parents=True, exist_ok=True)
    ph = args.allow_placeholders
    manifest_physnet = cli / "out" / "last_physnet_checkpoint.txt"
    manifest_joint = cli / "out" / "last_joint_checkpoint.txt"

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

    phys_ckpt = _resolve_ckpt_dir(manifest_physnet, args.physnet_ckpt_glob)
    joint_ckpt = _resolve_ckpt_dir(manifest_joint, args.joint_ckpt_glob)
    _try_checkpoint_plot(
        phys_ckpt,
        out / "step09_training_metrics.png",
        manifest_out=manifest_physnet,
        force=args.force_metrics,
    )
    _try_joint_training_metrics(
        joint_ckpt,
        out / "step10_training_metrics.png",
        manifest_out=manifest_joint,
        force=args.force_metrics,
    )

    if not (out / "step09_training_metrics.png").is_file() and ph:
        _placeholder(
            out / "step09_training_metrics.png",
            "After PhysNet training:\nmmml extract-checkpoint-metrics <run_dir> -o step09_training_metrics.png --log-loss",
        )
    if not (out / "step10_training_metrics.png").is_file() and ph:
        _placeholder(
            out / "step10_training_metrics.png",
            "After joint training:\nensure <run_dir>/history.json exists, or\n"
            "mmml extract-checkpoint-metrics <run_dir> -o step10_training_metrics.png --log-loss",
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
