#!/usr/bin/env bash
# Example: make_res via CLI (section 01 – Generating a molecule)
# Run from project root: bash examples/mmml_tutorial/cli/01_make_res_cli.sh
# Or from tutorial dir: bash cli/01_make_res_cli.sh (creates pdb/, psf/ in cli/)
# Requires: CHARMM, PyCHARMM.

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== 01: make_res (CLI) ==="
echo "Command: mmml make-res --res CYBZ --skip-energy-show"
mmml make-res --res CYBZ --skip-energy-show
echo "Output: pdb/initial.pdb, psf/initial.psf, xyz/initial.xyz (in $SCRIPT_DIR)"
