#!/usr/bin/env bash
# Example: make_box via CLI (section 01 – Generating a molecule)
# Run from this directory: cd cli && bash 02_make_box_cli.sh
# Requires: CHARMM, PyCHARMM, PackMol. Run 01_make_res first.

set -e
. ./shared.source

echo "=== 02: make_box (CLI) ==="
cmd=(mmml make-box --res "$RES" --n 2 --side_length 25.0)
printf -v cmd_str '%q ' "${cmd[@]}"
cmd_str="${cmd_str% }"

echo "Command: $cmd_str"
mkdir -p out
printf '%s\n' "$cmd_str" > out/02_last_command.txt
"${cmd[@]}"
echo "Saved command: out/02_last_command.txt"
