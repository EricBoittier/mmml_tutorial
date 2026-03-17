#!/usr/bin/env python
"""
Example: Evaluate sampled geometries with pyscf-dft via programmatic interface (section 02 – QM/DFT).

Run from project root: uv run python examples/mmml_tutorial/programmatic/07_pyscf_evaluate_programmatic.py
Requires: Step 06 run first (out/06_sampled.npz).
"""

from pathlib import Path

import numpy as np


def main():
    script_dir = Path(__file__).resolve().parent
    input_path = script_dir / "out" / "06_sampled.npz"
    output_path = script_dir / "out" / "07_evaluated.npz"

    if not input_path.exists():
        print(f"Error: Input not found: {input_path}")
        print("Run step 06 first: uv run python examples/mmml_tutorial/programmatic/06_normal_mode_sample_programmatic.py")
        return 1

    from mmml.interfaces.pyscf4gpuInterface.calcs import compute_dft_batch

    print("=== 07: pyscf-evaluate (programmatic) ===")
    data = np.load(input_path, allow_pickle=True)
    R = np.asarray(data["R"])
    Z = np.asarray(data["Z"])
    if R.ndim == 2:
        R = R[np.newaxis, ...]
    if Z.ndim == 2:
        Z = Z[0]

    result = compute_dft_batch(
        R,
        Z,
        basis="def2-SVP",
        xc="PBE0",
        spin=0,
        charge=0,
        energy=True,
        gradient=True,
        dipole=True,
        dens_esp=False,
        verbose=0,
    )

    output_path.parent.mkdir(parents=True, exist_ok=True)
    np.savez_compressed(output_path, **result)

    print(f"Saved {result['R'].shape[0]} evaluated geometries to {output_path}")
    return 0


if __name__ == "__main__":
    exit(main())
