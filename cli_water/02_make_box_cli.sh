#!/usr/bin/env bash
# Example: make_box via CLI (section 01 – Generating a molecule)
# Run from this directory: cd examples/mmml_tutorial/cli && bash 02_make_box_cli.sh
# Requires: CHARMM, PyCHARMM, PackMol. Run 01_make_res first.

set -e

echo "=== 02: make_box (CLI) ==="
echo "Command: uv run mmml make-box --res CYBZ --n 2 --side_length 25.0"
mmml make-box --res CYBZ --n 2 --side_length 25.0
echo "Output: pdb/init-packmol.pdb"
