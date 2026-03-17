#!/usr/bin/env python
"""
Example: make_box via programmatic interface (section 01 – Generating a molecule).

Run from project root: uv run python examples/mmml_tutorial/programmatic/02_make_box_programmatic.py
Requires: CHARMM, PyCHARMM, PackMol. Run 01_make_res first.
"""

import os
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[3]))

from mmml.cli.make.make_box import main_loop
import argparse


def main():
    os.chdir(Path(__file__).resolve().parent)
    args = argparse.Namespace(
        res="CYBZ",
        n=50,
        side_length=25.0,
        pdb=None,
        solvent=None,
        density=None,
    )
    print("=== 02: make_box programmatic ===")
    main_loop(args)
    print("Output: pdb/init-packmol.pdb")


if __name__ == "__main__":
    main()
