#!/usr/bin/env bash
# Example: mixed methanol/water (TIP3) 1:1 periodic NVT
# Run from this directory: cd cli && bash 21_md_system_meoh_tip3_1to1.sh

set -e
. ./shared.source

echo "=== 21: md-system mixed MEOH:TIP3 (1:1) ==="
echo "Command: mmml md-system --setup pbc_nvt --composition MEOH:5,TIP3:5 --temperature \"$MDSYS_TEMP_K\" --ps \"$MDSYS_PS\" --dt-fs \"$MDSYS_DT_FS\" --traj-chunk-frames \"$MDSYS_TRAJ_CHUNK_FRAMES\" --output-dir \"$MDSYS_OUT/meoh_tip3_1to1\""

mmml md-system \
  --setup pbc_nvt \
  --composition MEOH:5,TIP3:5 \
  --temperature "$MDSYS_TEMP_K" \
  --ps "$MDSYS_PS" \
  --dt-fs "$MDSYS_DT_FS" \
  --traj-chunk-frames "$MDSYS_TRAJ_CHUNK_FRAMES" \
  --output-dir "$MDSYS_OUT/meoh_tip3_1to1"
