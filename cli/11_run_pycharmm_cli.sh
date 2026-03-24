#!/usr/bin/env bash
# Example: Pure PyCHARMM heating and equilibration (no MM/ML)
# Run from this directory: cd examples/mmml_tutorial/cli && bash 11_run_pycharmm_cli.sh
# Requires: Steps 01–02 run first (make_res, make_box). CHARMM/PyCHARMM.

set -e

echo "=== 11: run-pycharmm (CHARMM heat + equilibration) ==="
echo "Command: uv run mmml run-pycharmm --pdbfile pdb/init-packmol.pdb --cell 25.0"
uv run mmml run-pycharmm --pdbfile pdb/init-packmol.pdb --cell 25.0
echo "Output: pdb/{heat,equi}.pdb, dcd/{heat,equi}.{dcd,crd}, res/{heat,equi}.res"
