#!/usr/bin/env python
"""
Example: MP2 energy + gradient via programmatic interface (section 02 – QM/DFT).

Run from project root: uv run python examples/mmml_tutorial/05_pyscf_mp2_programmatic.py
"""

from pathlib import Path

import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from mmml.interfaces.pyscf4gpuInterface.calcs import compute_mp2, save_pyscf_results


def main():
    mol_str = "O 0 0 0; H 0.96 0 0; H -0.24 0.93 0"

    print("=== 05: MP2 programmatic (def2-SVP) ===")
    output = compute_mp2(
        mol_str=mol_str,
        basis="def2-SVP",
        energy=True,
        gradient=True,
    )
    print(f"MP2 energy: {output['energy']} Hartree")
    print(f"HF energy:  {output['energy_hf']} Hartree")
    print(f"Correlation: {output['energy_corr']} Hartree")

    save_pyscf_results("examples/mmml_tutorial/out/05_results", output)
    print("Output: examples/mmml_tutorial/out/05_results.npz and .h5")


if __name__ == "__main__":
    main()
