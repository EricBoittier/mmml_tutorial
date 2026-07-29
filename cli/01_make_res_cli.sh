#!/usr/bin/env bash
# Example: make_res via CLI (section 01 – Generating a molecule)
# Run from this directory: cd cli && bash 01_make_res_cli.sh
# Requires: CHARMM, PyCHARMM.

set -e
. ./shared.source

echo "=== 01: make_res (CLI) ==="
cmd=(mmml make-res --res "$RES" --skip-energy-show)
printf -v cmd_str '%q ' "${cmd[@]}"
cmd_str="${cmd_str% }"

echo "Command: $cmd_str"
mkdir -p out
printf '%s\n' "$cmd_str" > out/01_last_command.txt
"${cmd[@]}"
echo "Saved command: out/01_last_command.txt"
