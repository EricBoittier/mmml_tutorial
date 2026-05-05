#!/usr/bin/env bash
# Example: md_10mer free-space NVT (NHC thermostat)
# Run from this directory: cd cli && bash 17_md_10mer_free_nvt.sh

set -e
. ./shared.source

echo "=== 17: md_10mer free-space NVT ==="
echo "Command: mmml md-system --setup free_nvt --temperature \"$MDSYS_TEMP_K\" --n-molecules \"$MDSYS_N_MOLECULES\" --ps \"$MDSYS_PS\" --dt-fs \"$MDSYS_DT_FS\" --traj-chunk-frames \"$MDSYS_TRAJ_CHUNK_FRAMES\" --output-dir \"$MDSYS_OUT/free_nvt\""

mmml md-system \
  --setup free_nvt \
  --temperature "$MDSYS_TEMP_K" \
  --n-molecules "$MDSYS_N_MOLECULES" \
  --ps "$MDSYS_PS" \
  --dt-fs "$MDSYS_DT_FS" \
  --traj-chunk-frames "$MDSYS_TRAJ_CHUNK_FRAMES" \
  --output-dir "$MDSYS_OUT/free_nvt"
