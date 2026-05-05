#!/usr/bin/env bash
# Example: md_10mer free-space NVE
# Run from this directory: cd cli && bash 16_md_10mer_free_nve.sh

set -e
. ./shared.source

echo "=== 16: md_10mer free-space NVE ==="
echo "Command: mmml md-system --setup free_nve --n-molecules \"$MDSYS_N_MOLECULES\" --ps \"$MDSYS_PS\" --dt-fs \"$MDSYS_DT_FS\" --traj-chunk-frames \"$MDSYS_TRAJ_CHUNK_FRAMES\" --output-dir \"$MDSYS_OUT/free_nve\""

mmml md-system \
  --setup free_nve \
  --n-molecules "$MDSYS_N_MOLECULES" \
  --ps "$MDSYS_PS" \
  --dt-fs "$MDSYS_DT_FS" \
  --traj-chunk-frames "$MDSYS_TRAJ_CHUNK_FRAMES" \
  --output-dir "$MDSYS_OUT/free_nve"
