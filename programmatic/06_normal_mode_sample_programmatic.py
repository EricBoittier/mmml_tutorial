#!/usr/bin/env python
"""
Example: Normal mode sampling from pyscf-dft harmonic output via programmatic interface (section 02 – QM/DFT).

Run from project root: uv run python examples/mmml_tutorial/programmatic/06_normal_mode_sample_programmatic.py
Requires: Step 04 run first (out/04_results.h5 with harmonic data).
"""

from pathlib import Path

import numpy as np


def main():
    script_dir = Path(__file__).resolve().parent
    input_path = script_dir / "out" / "04_results.h5"
    output_path = script_dir / "out" / "06_sampled.npz"

    if not input_path.exists():
        print(f"Error: Input not found: {input_path}")
        print("Run step 04 first: uv run python examples/mmml_tutorial/programmatic/04_pyscf_dft_programmatic.py")
        return 1

    from mmml.cli.misc.normal_mode_sample import _load_h5, sample_normal_modes

    print("=== 06: Normal mode sampling (programmatic) ===")
    data = _load_h5(input_path)

    R_eq = data["R"]
    if R_eq.ndim == 3:
        R_eq = R_eq[0]
    Z = data["Z"]
    if Z.ndim == 2:
        Z = Z[0]
    norm_mode = data["norm_mode"]
    freq_wavenumber = data["freq_wavenumber"]

    R_samples, Z_out = sample_normal_modes(
        R_eq,
        Z,
        norm_mode,
        freq_wavenumber,
        amplitudes=[0.1],
        freq_min=50.0,
        include_equilibrium=False,
        samples_per_mode=2,
        max_samples=10,
    )

    output_path.parent.mkdir(parents=True, exist_ok=True)
    np.savez_compressed(
        output_path,
        R=R_samples,
        Z=Z_out,
        N=np.array(len(Z_out)),
    )

    print(f"Saved {R_samples.shape[0]} geometries to {output_path}")
    return 0


if __name__ == "__main__":
    exit(main())
