#!/usr/bin/env bash
# Example: make_box via CLI (section 01 – Generating a molecule)
# Run from project root: bash examples/mmml_tutorial/cli/02_make_box_cli.sh
# Requires: CHARMM, PyCHARMM, PackMol. Run 01_make_res first.

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== 02: make_box (CLI) ==="
echo "Command: uv run mmml make-box --res CYBZ --n 2 --side_length 25.0"
uv run mmml make-box --res CYBZ --n 2 --side_length 25.0
echo "Output: pdb/init-packmol.pdb"
