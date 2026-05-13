#!/usr/bin/env python
"""
Reproducible ASE/MMML ring simulations with optional z-directed electric field.

Typical usage:

    python reproducible_ring_simulations.py \
        --xyz qP_samples/q_0.100_P_288.0.xyz \
        --config /mmhome/boittier/home/ckpts/ring_ef2_ptT_run2/config-66b8e895-abc4-4ae5-9c26-3e09c67126a2.json \
        --params /mmhome/boittier/home/ckpts/ring_ef2_ptT_run2/params-66b8e895-abc4-4ae5-9c26-3e09c67126a2.json \
        --field-z 0.0 \
        --run-name ef0

    python reproducible_ring_simulations.py \
        --xyz qP_samples/q_0.100_P_288.0.xyz \
        --config /mmhome/boittier/home/ckpts/ring_ef2_ptT_run2/config-66b8e895-abc4-4ae5-9c26-3e09c67126a2.json \
        --params /mmhome/boittier/home/ckpts/ring_ef2_ptT_run2/params-66b8e895-abc4-4ae5-9c26-3e09c67126a2.json \
        --field-z 0.001 \
        --run-name efz_0p001

Outputs are written to:

    runs/<run-name>/

including optimized geometry, trajectory, energy log, puckering coordinates,
normal-vector analysis, and plots.
"""

from __future__ import annotations

import argparse
import json
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

import ase.io
from ase import units
from ase.md.verlet import VelocityVerlet
from ase.md.velocitydistribution import MaxwellBoltzmannDistribution, Stationary, ZeroRotation
from ase.optimize import BFGS
from ase.io.trajectory import Trajectory

from mmml.models.EF.ase_calc_EF import AseCalculatorEF
from mmml.interfaces.chemcoordInterface.interface import patch_chemcoord_for_pandas3


@dataclass(frozen=True)
class SimulationConfig:
    xyz: Path
    config_path: Path
    params_path: Path
    run_name: str
    output_root: Path = Path("runs")

    # Model field settings. The calculator interprets these according to field_scale.
    field_x: float = 0.0
    field_y: float = 0.0
    field_z: float = 0.0
    field_scale: float = 100.0

    # Optimization settings.
    optimize: bool = True
    fmax: float = 0.003
    opt_steps: int = 1000
    maxstep: float = 0.04

    # MD settings.
    temperature_K: float = 300.0
    dt_fs: float = 0.5
    nsteps: int = 500_000
    write_every: int = 1000
    seed: int = 7

    # Ring definition.
    ring_idx: tuple[int, ...] = (0, 3, 6, 9, 12)

    @property
    def electric_field(self) -> np.ndarray:
        return np.array([self.field_x, self.field_y, self.field_z], dtype=float)

    @property
    def run_dir(self) -> Path:
        return self.output_root / self.run_name


def _json_safe(value: Any) -> Any:
    if isinstance(value, Path):
        return str(value)
    if isinstance(value, tuple):
        return list(value)
    if isinstance(value, np.ndarray):
        return value.tolist()
    return value


def write_run_metadata(cfg: SimulationConfig) -> None:
    cfg.run_dir.mkdir(parents=True, exist_ok=True)
    payload = {k: _json_safe(v) for k, v in asdict(cfg).items()}
    payload["electric_field"] = cfg.electric_field.tolist()
    with open(cfg.run_dir / "run_config.json", "w") as f:
        json.dump(payload, f, indent=2)


def make_calculator(cfg: SimulationConfig) -> AseCalculatorEF:
    return AseCalculatorEF(
        str(cfg.params_path),
        config_path=str(cfg.config_path),
        electric_field=cfg.electric_field,
        field_scale=cfg.field_scale,
    )


def load_atoms(cfg: SimulationConfig):
    atoms = ase.io.read(str(cfg.xyz))
    atoms.calc = make_calculator(cfg)
    return atoms


def optimize_geometry(atoms, cfg: SimulationConfig):
    traj_path = cfg.run_dir / "opt_bfgs.traj"
    log_path = cfg.run_dir / "opt_bfgs.log"

    opt = BFGS(
        atoms,
        trajectory=str(traj_path),
        logfile=str(log_path),
        maxstep=cfg.maxstep,
    )
    opt.run(fmax=cfg.fmax, steps=cfg.opt_steps)

    ase.io.write(str(cfg.run_dir / "optimized.xyz"), atoms)

    forces = atoms.get_forces()
    summary = {
        "final_energy_eV": float(atoms.get_potential_energy()),
        "final_max_abs_force_eV_per_A": float(np.max(np.abs(forces))),
        "fmax_target_eV_per_A": cfg.fmax,
    }
    with open(cfg.run_dir / "optimization_summary.json", "w") as f:
        json.dump(summary, f, indent=2)

    return atoms


def initialize_velocities(atoms, cfg: SimulationConfig) -> None:
    rng = np.random.default_rng(cfg.seed)
    MaxwellBoltzmannDistribution(atoms, temperature_K=cfg.temperature_K, rng=rng)
    Stationary(atoms)
    ZeroRotation(atoms)


def run_nve(atoms, cfg: SimulationConfig) -> pd.DataFrame:
    dyn = VelocityVerlet(atoms, timestep=cfg.dt_fs * units.fs)

    traj_path = cfg.run_dir / "nve.traj"
    log_rows: list[dict[str, float | int]] = []

    with Trajectory(str(traj_path), mode="w") as traj:
        traj.write(atoms)

        for step in range(0, cfg.nsteps + 1, cfg.write_every):
            if step > 0:
                dyn.run(cfg.write_every)
                traj.write(atoms)

            epot = float(atoms.get_potential_energy())
            ekin = float(atoms.get_kinetic_energy())
            temp = float(atoms.get_temperature())

            row = {
                "step": step,
                "time_fs": step * cfg.dt_fs,
                "E_pot_eV": epot,
                "E_kin_eV": ekin,
                "E_tot_eV": epot + ekin,
                "T_K": temp,
            }
            log_rows.append(row)

            print(
                f"step={step:8d}  "
                f"E_pot={epot:+.6f}  "
                f"E_kin={ekin:+.6f}  "
                f"E_tot={epot + ekin:+.6f}  "
                f"T(K)={temp:.1f}"
            )

    df = pd.DataFrame(log_rows)
    df.to_csv(cfg.run_dir / "nve_energy_log.csv", index=False)
    return df


def _best_fit_plane(coords: np.ndarray):
    coords = np.asarray(coords, dtype=float)
    centroid = coords.mean(axis=0)
    X = coords - centroid
    _, _, vh = np.linalg.svd(X, full_matrices=False)
    normal = vh[-1]
    normal /= np.linalg.norm(normal)
    z = X @ normal
    return centroid, normal, z


def _cp_single(R: np.ndarray, ring_idx: tuple[int, ...], degrees: bool = False) -> dict[str, Any]:
    R = np.asarray(R, dtype=float)
    ring = R[list(ring_idx)]
    n = len(ring_idx)

    centroid, normal, z = _best_fit_plane(ring)
    j = np.arange(n)

    if n == 5:
        c = np.cos(4.0 * np.pi * j / 5.0)
        s = np.sin(4.0 * np.pi * j / 5.0)

        A = np.sqrt(2.0 / 5.0) * np.sum(z * c)
        B = -np.sqrt(2.0 / 5.0) * np.sum(z * s)

        q = np.hypot(A, B)
        P = np.arctan2(B, A)
        if degrees:
            P = np.rad2deg(P)

        return {
            "q": float(q),
            "P": float(P),
            "z": z,
            "centroid": centroid,
            "normal": normal,
        }

    if n == 6:
        c = np.cos(4.0 * np.pi * j / 6.0)
        s = np.sin(4.0 * np.pi * j / 6.0)

        A = np.sqrt(2.0 / 6.0) * np.sum(z * c)
        B = -np.sqrt(2.0 / 6.0) * np.sum(z * s)

        q2 = np.hypot(A, B)
        phi = np.arctan2(B, A)
        q3 = np.sqrt(1.0 / 6.0) * np.sum(((-1.0) ** j) * z)
        Q = np.hypot(q2, q3)
        theta = np.arctan2(q2, q3)

        if degrees:
            phi = np.rad2deg(phi)
            theta = np.rad2deg(theta)

        return {
            "q2": float(q2),
            "phi": float(phi),
            "q3": float(q3),
            "Q": float(Q),
            "theta": float(theta),
            "z": z,
            "centroid": centroid,
            "normal": normal,
        }

    raise ValueError("Only 5- or 6-membered rings are supported")


def cp_from_R(R: np.ndarray, ring_idx: tuple[int, ...], degrees: bool = False):
    R = np.asarray(R, dtype=float)

    if R.ndim == 2:
        return _cp_single(R, ring_idx, degrees=degrees)

    if R.ndim == 3:
        results = [_cp_single(r, ring_idx, degrees=degrees) for r in R]
        keys = results[0].keys()
        return {k: np.array([res[k] for res in results]) for k in keys}

    raise ValueError(f"R must have shape (N,3) or (M,N,3), got {R.shape}")


def analyze_trajectory(cfg: SimulationConfig) -> pd.DataFrame:
    frames = ase.io.read(str(cfg.run_dir / "nve.traj"), ":")

    rows: list[dict[str, float | int]] = []
    for frame_idx, atoms in enumerate(frames):
        cp = cp_from_R(atoms.get_positions(), cfg.ring_idx, degrees=False)
        normal = np.asarray(cp["normal"], dtype=float)
        unit_normal = normal / np.linalg.norm(normal)
        cos_theta = float(np.clip(unit_normal[2], -1.0, 1.0))
        theta_deg = float(np.degrees(np.arccos(cos_theta)))

        if len(cfg.ring_idx) == 5:
            q = float(cp["q"])
            P = float(cp["P"])
            x_cp = q * np.cos(P)
            y_cp = q * np.sin(P)
            row = {
                "frame": frame_idx,
                "q": q,
                "P_rad": P,
                "x_cp": x_cp,
                "y_cp": y_cp,
            }
        else:
            q2 = float(cp["q2"])
            phi = float(cp["phi"])
            row = {
                "frame": frame_idx,
                "q2": q2,
                "phi_rad": phi,
                "q3": float(cp["q3"]),
                "Q": float(cp["Q"]),
                "theta_ring_rad": float(cp["theta"]),
                "x_cp": q2 * np.cos(phi),
                "y_cp": q2 * np.sin(phi),
            }

        row.update(
            {
                "E_pot_eV": float(atoms.get_potential_energy()),
                "normal_x": float(unit_normal[0]),
                "normal_y": float(unit_normal[1]),
                "normal_z": float(unit_normal[2]),
                "cos_theta_to_lab_z": cos_theta,
                "theta_to_lab_z_deg": theta_deg,
            }
        )
        rows.append(row)

    df = pd.DataFrame(rows)
    df.to_csv(cfg.run_dir / "puckering_and_normals.csv", index=False)
    return df


def plot_energy_log(df: pd.DataFrame, cfg: SimulationConfig) -> None:
    plt.figure(figsize=(8, 4))
    plt.plot(df["time_fs"], df["E_tot_eV"], label="total")
    plt.plot(df["time_fs"], df["E_pot_eV"], label="potential", alpha=0.8)
    plt.plot(df["time_fs"], df["E_kin_eV"], label="kinetic", alpha=0.8)
    plt.xlabel("Time / fs")
    plt.ylabel("Energy / eV")
    plt.title("NVE energy trace")
    plt.legend()
    plt.tight_layout()
    plt.savefig(cfg.run_dir / "energy_trace.png", dpi=200)
    plt.close()

    drift = df["E_tot_eV"] - df["E_tot_eV"].iloc[0]
    plt.figure(figsize=(8, 4))
    plt.plot(df["time_fs"], drift)
    plt.xlabel("Time / fs")
    plt.ylabel("Total energy drift / eV")
    plt.title("NVE total-energy drift")
    plt.tight_layout()
    plt.savefig(cfg.run_dir / "energy_drift.png", dpi=200)
    plt.close()


def plot_puckering(df: pd.DataFrame, cfg: SimulationConfig) -> None:
    plt.figure(figsize=(6, 5))
    s = plt.scatter(
        df["x_cp"],
        df["y_cp"],
        s=6.0,
        c=df["E_pot_eV"] - df["E_pot_eV"].min(),
    )
    plt.colorbar(s, label="E - min(E) / eV")
    plt.xlabel("q cos(P) / Å")
    plt.ylabel("q sin(P) / Å")
    plt.title("Puckering trajectory")
    plt.tight_layout()
    plt.savefig(cfg.run_dir / "puckering_scatter_energy.png", dpi=200)
    plt.close()

    plt.figure(figsize=(6, 5))
    plt.hist2d(df["x_cp"], df["y_cp"], bins=30)
    plt.colorbar(label="Count")
    plt.xlabel("q cos(P) / Å")
    plt.ylabel("q sin(P) / Å")
    plt.title("Puckering occupancy")
    plt.tight_layout()
    plt.savefig(cfg.run_dir / "puckering_hist2d.png", dpi=200)
    plt.close()


def plot_normals(df: pd.DataFrame, cfg: SimulationConfig) -> None:
    plt.figure(figsize=(8, 4))
    plt.plot(df["frame"], df["theta_to_lab_z_deg"])
    plt.xlabel("Frame")
    plt.ylabel("Angle to lab z-axis / degrees")
    plt.title("Ring normal orientation")
    plt.tight_layout()
    plt.savefig(cfg.run_dir / "normal_angle_timeseries.png", dpi=200)
    plt.close()

    bins = np.linspace(0, 180, 37)
    theta_grid_deg = np.linspace(0, 180, 500)
    theta_grid_rad = np.radians(theta_grid_deg)
    p_theta_deg = 0.5 * np.sin(theta_grid_rad) * np.pi / 180.0

    plt.figure(figsize=(7, 4))
    plt.hist(df["theta_to_lab_z_deg"], bins=bins, density=True, alpha=0.6, label="Observed")
    plt.plot(theta_grid_deg, p_theta_deg, label=r"Isotropic reference: $\frac{1}{2}\sin\theta$")
    plt.xlabel("Angle to lab z-axis / degrees")
    plt.ylabel("Probability density")
    plt.title("Normal angle distribution")
    plt.legend()
    plt.tight_layout()
    plt.savefig(cfg.run_dir / "normal_angle_histogram.png", dpi=200)
    plt.close()

    plt.figure(figsize=(7, 4))
    plt.hist(df["cos_theta_to_lab_z"], bins=30, density=True, alpha=0.6, label="Observed")
    plt.axhline(0.5, linestyle="--", label="Uniform isotropic reference")
    plt.xlabel(r"$\cos(\theta)$")
    plt.ylabel("Probability density")
    plt.title(r"Reference check: $\cos(\theta)$ uniform on [-1, 1]")
    plt.legend()
    plt.tight_layout()
    plt.savefig(cfg.run_dir / "normal_costheta_histogram.png", dpi=200)
    plt.close()


def run_workflow(cfg: SimulationConfig) -> None:
    patch_chemcoord_for_pandas3()
    cfg.run_dir.mkdir(parents=True, exist_ok=True)
    write_run_metadata(cfg)

    print(f"Run directory: {cfg.run_dir}")
    print(f"Electric field input vector: {cfg.electric_field}")

    atoms = load_atoms(cfg)

    if cfg.optimize:
        atoms = optimize_geometry(atoms, cfg)
    else:
        ase.io.write(str(cfg.run_dir / "initial.xyz"), atoms)

    initialize_velocities(atoms, cfg)
    energy_df = run_nve(atoms, cfg)
    analysis_df = analyze_trajectory(cfg)

    plot_energy_log(energy_df, cfg)
    plot_puckering(analysis_df, cfg)
    plot_normals(analysis_df, cfg)

    print("Done.")
    print(f"Wrote trajectory: {cfg.run_dir / 'nve.traj'}")
    print(f"Wrote analysis:   {cfg.run_dir / 'puckering_and_normals.csv'}")


def parse_args() -> SimulationConfig:
    parser = argparse.ArgumentParser(description="Run reproducible ASE/MMML ring simulations.")

    parser.add_argument("--xyz", required=True, type=Path)
    parser.add_argument("--config", required=True, dest="config_path", type=Path)
    parser.add_argument("--params", required=True, dest="params_path", type=Path)
    parser.add_argument("--run-name", required=True)
    parser.add_argument("--output-root", default=Path("runs"), type=Path)

    parser.add_argument("--field-x", default=0.0, type=float)
    parser.add_argument("--field-y", default=0.0, type=float)
    parser.add_argument("--field-z", default=0.0, type=float)
    parser.add_argument("--field-scale", default=100.0, type=float)

    parser.add_argument("--no-optimize", action="store_true")
    parser.add_argument("--fmax", default=0.003, type=float)
    parser.add_argument("--opt-steps", default=1000, type=int)
    parser.add_argument("--maxstep", default=0.04, type=float)

    parser.add_argument("--temperature-K", default=300.0, type=float)
    parser.add_argument("--dt-fs", default=0.5, type=float)
    parser.add_argument("--nsteps", default=500_000, type=int)
    parser.add_argument("--write-every", default=1000, type=int)
    parser.add_argument("--seed", default=7, type=int)

    parser.add_argument(
        "--ring-idx",
        default="0,3,6,9,12",
        help="Comma-separated atom indices defining the ring, e.g. 0,3,6,9,12",
    )

    args = parser.parse_args()
    ring_idx = tuple(int(x.strip()) for x in args.ring_idx.split(",") if x.strip())

    return SimulationConfig(
        xyz=args.xyz,
        config_path=args.config_path,
        params_path=args.params_path,
        run_name=args.run_name,
        output_root=args.output_root,
        field_x=args.field_x,
        field_y=args.field_y,
        field_z=args.field_z,
        field_scale=args.field_scale,
        optimize=not args.no_optimize,
        fmax=args.fmax,
        opt_steps=args.opt_steps,
        maxstep=args.maxstep,
        temperature_K=args.temperature_K,
        dt_fs=args.dt_fs,
        nsteps=args.nsteps,
        write_every=args.write_every,
        seed=args.seed,
        ring_idx=ring_idx,
    )


if __name__ == "__main__":
    run_workflow(parse_args())
