#!/usr/bin/env python
"""
Example: DFT full (energy, gradient, hessian, harmonic, thermo) via programmatic interface (section 02 – QM/DFT).

Run from project root: uv run python examples/mmml_tutorial/programmatic/04_pyscf_dft_programmatic.py
Note: Hessian/harmonic/thermo are expensive; use small molecules.
"""

import os
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[3]))

from mmml.interfaces.pyscf4gpuInterface.calcs import (
    compute_dft,
    get_dummy_args,
    save_pyscf_results,
)
from mmml.interfaces.pyscf4gpuInterface.enums import CALCS


def main():
    script_dir = Path(__file__).resolve().parent
    os.chdir(script_dir)
    output_path = "out/04_results"

    mol_str = "xyz/initial.xyz"
    calcs = [CALCS.ENERGY, CALCS.GRADIENT, CALCS.HESSIAN, CALCS.HARMONIC, CALCS.THERMO]
    args = get_dummy_args(mol_str, calcs)
    args.basis = "def2-SVP"
    args.xc = "PBE0"
    args.output = output_path

    print("=== 04: DFT full programmatic (energy, gradient, hessian, harmonic, thermo) ===")
    output = compute_dft(args, calcs)
    print(f"Energy: {output['energy']} Hartree")

    save_pyscf_results(args.output, output)
    print(f"Output: {args.output}.npz and .h5")


if __name__ == "__main__":
    main()
