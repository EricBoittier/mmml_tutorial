#!/usr/bin/env bash
# Example: md_10mer free-space NVT (NHC thermostat)
# Run from this directory: cd cli && bash 17_md_10mer_free_nvt.sh

set -e
. ./shared.source

echo "=== 17: md_10mer free-space NVT ==="
echo "Command: mmml md-10mer --setup free_nvt --temperature \"$MD10MER_TEMP_K\" --n-molecules \"$MD10MER_N_MOLECULES\" --ps \"$MD10MER_PS\" --dt-fs \"$MD10MER_DT_FS\" --output-dir \"$MD10MER_OUT/free_nvt\""

mmml md-10mer \
  --setup free_nvt \
  --temperature "$MD10MER_TEMP_K" \
  --n-molecules "$MD10MER_N_MOLECULES" \
  --ps "$MD10MER_PS" \
  --dt-fs "$MD10MER_DT_FS" \
  --output-dir "$MD10MER_OUT/free_nvt"
