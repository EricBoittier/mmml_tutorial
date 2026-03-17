#!/usr/bin/env python
"""
Example: make_box via programmatic interface (section 01 – Generating a molecule).

Run from project root: uv run python examples/mmml_tutorial/02_make_box_programmatic.py
Requires: CHARMM, PyCHARMM, PackMol. Run 01_make_res first.
"""

from pathlib import Path

import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from mmml.cli.make.make_box import main_loop
import argparse


def main():
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
