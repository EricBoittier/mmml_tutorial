#!/usr/bin/env bash
# Example: md_10mer periodic NVE
# Run from this directory: cd cli && bash 18_md_10mer_pbc_nve.sh

set -e
. ./shared.source

echo "=== 18: md_10mer periodic NVE ==="
echo "Command: mmml md-system --setup pbc_nve --n-molecules \"$MD10MER_N_MOLECULES\" --ps \"$MD10MER_PS\" --dt-fs \"$MD10MER_DT_FS\" --output-dir \"$MD10MER_OUT/pbc_nve\""

mmml md-system \
  --setup pbc_nve \
  --n-molecules "$MD10MER_N_MOLECULES" \
  --ps "$MD10MER_PS" \
  --dt-fs "$MD10MER_DT_FS" \
  --output-dir "$MD10MER_OUT/pbc_nve"
