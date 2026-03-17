#!/usr/bin/env python
"""
Example: make_res via programmatic interface (section 01 – Generating a molecule).

Run from project root: uv run python examples/mmml_tutorial/programmatic/01_make_res_programmatic.py
Requires: CHARMM, PyCHARMM.
"""

import os
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[3]))

from mmml.cli.make.make_res import main_loop
import argparse


def main():
    os.chdir(Path(__file__).resolve().parent)
    args = argparse.Namespace(res="CYBZ", skip_energy_show=True)
    print("=== 01: make_res programmatic ===")
    atoms = main_loop(args)
    print(f"Generated {len(atoms)} atoms")
    print("Output: pdb/initial.pdb, psf/initial.psf, xyz/initial.xyz, CHARMM topology files")


if __name__ == "__main__":
    main()
