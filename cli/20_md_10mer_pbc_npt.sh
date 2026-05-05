#!/usr/bin/env bash
# Example: md_10mer periodic NPT (JAX-MD NHC + barostat)
# Run from this directory: cd cli && bash 20_md_10mer_pbc_npt.sh

set -e
. ./shared.source

echo "=== 20: md_10mer periodic NPT ==="
echo "Command: mmml md-system --setup pbc_npt --temperature \"$MD10MER_TEMP_K\" --pressure \"$MD10MER_PRESSURE_ATM\" --n-molecules \"$MD10MER_N_MOLECULES\" --ps \"$MD10MER_PS\" --dt-fs \"$MD10MER_DT_FS\" --output-dir \"$MD10MER_OUT/pbc_npt\""

mmml md-system \
  --setup pbc_npt \
  --temperature "$MD10MER_TEMP_K" \
  --pressure "$MD10MER_PRESSURE_ATM" \
  --n-molecules "$MD10MER_N_MOLECULES" \
  --ps "$MD10MER_PS" \
  --dt-fs "$MD10MER_DT_FS" \
  --output-dir "$MD10MER_OUT/pbc_npt"
