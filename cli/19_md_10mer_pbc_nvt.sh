#!/usr/bin/env bash
# Example: md_10mer periodic NVT (NHC thermostat)
# Run from this directory: cd cli && bash 19_md_10mer_pbc_nvt.sh

set -e
. ./shared.source

echo "=== 19: md_10mer periodic NVT ==="
echo "Command: mmml md-system --setup pbc_nvt --temperature \"$MD10MER_TEMP_K\" --n-molecules \"$MD10MER_N_MOLECULES\" --ps \"$MD10MER_PS\" --dt-fs \"$MD10MER_DT_FS\" --output-dir \"$MD10MER_OUT/pbc_nvt\""

mmml md-system \
  --setup pbc_nvt \
  --temperature "$MD10MER_TEMP_K" \
  --n-molecules "$MD10MER_N_MOLECULES" \
  --ps "$MD10MER_PS" \
  --dt-fs "$MD10MER_DT_FS" \
  --output-dir "$MD10MER_OUT/pbc_nvt"
