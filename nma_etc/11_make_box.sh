#!/usr/bin/env bash
# Docs §7 — Packmol box for condensed-phase MD.
# Default MD_RES=ACEM (matches training species). Override: MD_RES=NMA bash 11_make_box.sh
set -euo pipefail
. ./shared.source

echo "=== 11: make-box ${MD_RES}:${MD_N} side=${MDSYS_BOX_SIDE} ==="
# Ensure residue artifacts exist for MD_RES
if [[ ! -f "xyz/${MD_RES,,}.xyz" && ! -f "xyz/initial.xyz" && ! -f "pdb/${MD_RES,,}.pdb" ]]; then
  echo "Building residue $MD_RES first…"
  mmml make-res --res "$MD_RES" --skip-energy-show
fi

mmml make-box --res "$MD_RES" --n "$MD_N" --side_length "$MDSYS_BOX_SIDE"
echo "Box artifacts under pdb/ (init-packmol*). Or: mmml liquid-box --help"
