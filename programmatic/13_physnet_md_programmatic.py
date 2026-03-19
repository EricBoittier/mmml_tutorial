#!/usr/bin/env python
"""
Example: Molecular dynamics sampling with PhysNet calculator using ASE and JAX-MD.

Run from project root: uv run python examples/mmml_tutorial/programmatic/13_physnet_md_programmatic.py
Requires: Step 09 run first (PhysNet checkpoint in cli/out/ckpts/cybz_physnet/).
"""

from pathlib import Path

import numpy as np


def main():
    script_dir = Path(__file__).resolve().parent
    base_dir = script_dir.parent
    ckpt_dir = base_dir / "cli" / "out" / "ckpts" / "cybz_physnet"
    data_path = base_dir / "cli" / "out" / "splits" / "energies_forces_dipoles_train.npz"
    output_dir = script_dir / "out"
    output_dir.mkdir(parents=True, exist_ok=True)

    if not ckpt_dir.exists():
        print(f"Error: PhysNet checkpoint not found: {ckpt_dir}")
        print("Run step 09 first: bash examples/mmml_tutorial/cli/09_physnet_train_cli.sh")
        return 1

    # Find initial geometry
    if data_path.exists():
        data = np.load(data_path, allow_pickle=True)
        R = np.asarray(data["R"])
        Z = np.asarray(data["Z"])
        if R.ndim == 3:
            R = R[0]
        if Z.ndim == 2:
            Z = Z[0]
        n_atoms = int(np.sum(Z > 0)) if np.any(Z > 0) else len(Z)
        R = R[:n_atoms]
        Z = Z[:n_atoms]
    else:
        print(f"Error: Training data not found: {data_path}")
        print("Run steps 06–08 first to create splits.")
        return 1

    from mmml.physnetjax.physnetjax.restart.restart import get_last, get_params_model
    from mmml.physnetjax.physnetjax.calc.helper_mlp import get_ase_calc
    import e3x
    import jax
    import jax.numpy as jnp

    restart = get_last(str(ckpt_dir))
    params, model = get_params_model(str(restart), natoms=n_atoms)

    # ASE atoms
    from ase import Atoms, units
    from ase.md.verlet import VelocityVerlet
    from ase.md.langevin import Langevin
    from ase.md.velocitydistribution import MaxwellBoltzmannDistribution, Stationary, ZeroRotation
    from ase.io import write
    from ase.io.trajectory import Trajectory

    atoms = Atoms(numbers=Z, positions=R)
    atoms.center(vacuum=5.0)

    # PhysNet ASE calculator (eV, eV/Å)
    calc = get_ase_calc(
        params,
        model,
        atoms,
        conversion={"energy": 1, "forces": 1, "dipole": 1},
        implemented_properties=["energy", "forces"],
    )
    atoms.calc = calc

    # -------------------------------------------------------------------------
    # 1. ASE sampling (NVT Langevin)
    # -------------------------------------------------------------------------
    print("=== 13: PhysNet MD sampling (ASE + JAX-MD) ===")
    print("\n--- ASE: NVT Langevin ---")
    temperature = 300.0
    timestep_fs = 0.5
    nsteps_ase = 100
    printfreq = 25

    MaxwellBoltzmannDistribution(atoms, temperature_K=temperature)
    Stationary(atoms)
    ZeroRotation(atoms)

    dyn = Langevin(atoms, timestep=timestep_fs * units.fs, temperature_K=temperature, friction=0.01)
    traj_ase = output_dir / "13_physnet_ase.traj"
    traj_writer = Trajectory(traj_ase, "w", atoms)
    traj_writer.write()
    dyn.attach(traj_writer.write, interval=printfreq)

    for i in range(nsteps_ase):
        dyn.run(1)
        if i % printfreq == 0:
            print(f"  step {i:4d}  E={atoms.get_potential_energy():.4f} eV  T={atoms.get_temperature():.1f} K")

    traj_writer.close()
    write(output_dir / "13_physnet_ase_final.xyz", atoms)
    print(f"  Saved ASE trajectory: {traj_ase}")

    # -------------------------------------------------------------------------
    # 2. JAX-MD sampling (NVT Nose-Hoover)
    # -------------------------------------------------------------------------
    try:
        import jax_md
        from jax_md import space, quantity, simulate, partition
    except ImportError:
        print("\n--- JAX-MD: skipped (pip install jax-md) ---")
        return 0

    print("\n--- JAX-MD: NVT Nose-Hoover ---")
    R0 = np.array(atoms.get_positions())
    Z_jnp = jnp.array(Z, dtype=jnp.int32)
    dst_idx, src_idx = e3x.ops.sparse_pairwise_indices(n_atoms)
    dst_idx = jnp.array(dst_idx, dtype=jnp.int32)
    src_idx = jnp.array(src_idx, dtype=jnp.int32)

    @jax.jit
    def model_apply(positions):
        return model.apply(
            params,
            atomic_numbers=Z_jnp,
            positions=positions[None, :, :],
            dst_idx=dst_idx,
            src_idx=src_idx,
        )

    def energy_fn(position, **kwargs):
        out = model_apply(position)
        return jnp.squeeze(out["energy"])

    displacement, shift = space.free()
    K_B = 8.617333e-5  # eV/K
    kT = K_B * temperature
    dt = timestep_fs * 1e-3  # fs -> ps

    nsteps_jaxmd = 200
    save_interval = 50

    init_fn, apply_fn = simulate.nvt_nose_hoover(energy_fn, shift, dt, kT)
    apply_fn = jax.jit(apply_fn)

    from ase.data import atomic_masses
    masses = np.array([atomic_masses[z] for z in Z])
    key = jax.random.PRNGKey(42)
    state = init_fn(key, R0, mass=masses)

    positions_jaxmd = [R0]
    for i in range(nsteps_jaxmd):
        state = apply_fn(state)
        if (i + 1) % save_interval == 0:
            positions_jaxmd.append(np.array(state.position))
            T_curr = float(quantity.temperature(state.momentum, mass=masses) / K_B)
            E = float(energy_fn(state.position))
            print(f"  step {i+1:4d}  E={E:.4f} eV  T={T_curr:.1f} K")

    traj_jaxmd = output_dir / "13_physnet_jaxmd.xyz"
    for i, R in enumerate(positions_jaxmd):
        at = Atoms(numbers=Z, positions=R)
        write(traj_jaxmd, at, append=(i > 0))
    print(f"  Saved JAX-MD trajectory: {traj_jaxmd}")

    print("\nDone.")
    return 0


if __name__ == "__main__":
    exit(main())
