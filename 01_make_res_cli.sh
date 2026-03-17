#!/usr/bin/env bash
# Example: make_res via CLI (section 01 – Generating a molecule)
# Run from project root: bash examples/mmml_tutorial/01_make_res_cli.sh
# Requires: CHARMM, PyCHARMM. Run from a directory with CHARMM setup.

set -e
cd "$(dirname "$0")/../.."

echo "=== 01: make_res (CLI) ==="
uv run mmml make-res --res CYBZ --skip-energy-show
echo "Output: pdb/initial.pdb, psf/initial.psf, CHARMM topology files"
