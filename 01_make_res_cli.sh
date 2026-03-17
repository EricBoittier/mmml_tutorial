#!/usr/bin/env bash
# Example: make_res via CLI (section 01 – Generating a molecule)
# Run from project root: bash examples/mmml_tutorial/01_make_res_cli.sh
# Or from tutorial dir: bash 01_make_res_cli.sh (creates pdb/, psf/ in current dir)
# Requires: CHARMM, PyCHARMM.

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# If script is in examples/mmml_tutorial, cd there so output goes to tutorial dir
cd "$SCRIPT_DIR"

echo "=== 01: make_res (CLI) ==="
uv run mmml make-res --res CYBZ --skip-energy-show
echo "Output: pdb/initial.pdb, psf/initial.psf (in $SCRIPT_DIR)"
