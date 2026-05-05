#!/usr/bin/env bash
# Example: md_10mer periodic NVT (NHC thermostat)
# Run from this directory: cd cli && bash 19_md_10mer_pbc_nvt.sh

set -e
. ./shared.source

echo "=== 19: md_10mer periodic NVT ==="
echo "Command: mmml md-system --setup pbc_nvt --temperature \"$MDSYS_TEMP_K\" --n-molecules \"$MDSYS_N_MOLECULES\" --ps \"$MDSYS_PS\" --dt-fs \"$MDSYS_DT_FS\" --traj-chunk-frames \"$MDSYS_TRAJ_CHUNK_FRAMES\" --output-dir \"$MDSYS_OUT/pbc_nvt\""

mmml md-system \
  --setup pbc_nvt \
  --temperature "$MDSYS_TEMP_K" \
  --n-molecules "$MDSYS_N_MOLECULES" \
  --ps "$MDSYS_PS" \
  --dt-fs "$MDSYS_DT_FS" \
  --traj-chunk-frames "$MDSYS_TRAJ_CHUNK_FRAMES" \
  --output-dir "$MDSYS_OUT/pbc_nvt"
