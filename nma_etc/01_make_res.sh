#!/usr/bin/env bash
# Docs §1 — build NMA residue (CGenFF).
# Run from this directory: bash 01_make_res.sh
# Requires: CHARMM, PyCHARMM.
set -euo pipefail
. ./shared.source

echo "=== 01: make-res (${RES}) ==="
cmd=(mmml make-res --res "$RES" --skip-energy-show)
printf -v cmd_str '%q ' "${cmd[@]}"
echo "Command: ${cmd_str% }"
mkdir -p out
printf '%s\n' "${cmd_str% }" > out/01_last_command.txt
"${cmd[@]}"
echo "Artifacts: xyz/${RES,,}.xyz (or xyz/initial.xyz), pdb/, psf/"
echo "Inspect: vmd xyz/${RES,,}.xyz"
