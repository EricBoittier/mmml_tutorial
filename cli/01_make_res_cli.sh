#!/usr/bin/env bash
# Example: make_res via CLI (section 01 – Generating a molecule)
# Run from this directory: cd examples/mmml_tutorial/cli && bash 01_make_res_cli.sh
# Requires: CHARMM, PyCHARMM.

set -e

echo "=== 01: make_res (CLI) ==="
echo "Command: mmml make-res --res CYBZ --skip-energy-show"
mmml make-res --res PCRO --skip-energy-show
echo "Output: pdb/initial.pdb, psf/initial.psf, xyz/initial.xyz"
