#!/usr/bin/env bash
# Example: mixed methanol/water (TIP3) 1:1 periodic NVT
# Run from this directory: cd cli && bash 21_md_system_meoh_tip3_1to1.sh

set -e
. ./shared.source

echo "=== 21: md-system mixed MEOH:TIP3 (1:1) ==="
box_args=()
if [[ -n "$MDSYS_BOX_A" ]]; then
  box_args=(--box-size "$MDSYS_BOX_A")
fi

nvt_args=()
if [[ "$MDSYS_BACKEND" != "jaxmd" ]]; then
  nvt_args=(--nvt-integrator "$MDSYS_NVT_INTEGRATOR")
fi

echo "Command: mmml md-system --setup pbc_nvt --backend \"$MDSYS_BACKEND\" ${nvt_args[*]} --composition MEOH:5,TIP3:5 --temperature \"$MDSYS_TEMP_K\" ${box_args[*]} --ps \"$MDSYS_PS\" --dt-fs \"$MDSYS_DT_FS\" --traj-chunk-frames \"$MDSYS_TRAJ_CHUNK_FRAMES\" --seed \"$MDSYS_SEED\" --output-dir \"$MDSYS_OUT/meoh_tip3_1to1\""

mmml md-system \
  --setup pbc_nvt \
  --backend "$MDSYS_BACKEND" \
  "${nvt_args[@]}" \
  --composition MEOH:5,TIP3:5 \
  --temperature "$MDSYS_TEMP_K" \
  "${box_args[@]}" \
  --ps "$MDSYS_PS" \
  --dt-fs "$MDSYS_DT_FS" \
  --traj-chunk-frames "$MDSYS_TRAJ_CHUNK_FRAMES" \
  --seed "$MDSYS_SEED" \
  --output-dir "$MDSYS_OUT/meoh_tip3_1to1"
