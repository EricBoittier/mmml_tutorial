#!/usr/bin/env bash
# Example: md_10mer periodic NVT (NHC thermostat)
# Run from this directory: cd cli && bash 19_md_10mer_pbc_nvt.sh

set -e
. ./shared.source

echo "=== 19: md_10mer periodic NVT ==="
box_args=()
if [[ -n "$MDSYS_BOX_A" ]]; then
  box_args=(--box-size "$MDSYS_BOX_A")
fi

echo "Command: mmml md-system --setup pbc_nvt --backend \"$MDSYS_BACKEND\" --temperature \"$MDSYS_TEMP_K\" --n-molecules \"$MDSYS_N_MOLECULES\" ${box_args[*]} --ps \"$MDSYS_PS\" --dt-fs \"$MDSYS_DT_FS\" --traj-chunk-frames \"$MDSYS_TRAJ_CHUNK_FRAMES\" --seed \"$MDSYS_SEED\" --output-dir \"$MDSYS_OUT/pbc_nvt\""

mmml md-system \
  --setup pbc_nvt \
  --composition "DCM:${MDSYS_N_MOLECULES}" \
  --backend "$MDSYS_BACKEND" \
  --temperature "$MDSYS_TEMP_K" \
  --n-molecules "$MDSYS_N_MOLECULES" \
  "${box_args[@]}" \
  --ps "$MDSYS_PS" \
  --dt-fs "$MDSYS_DT_FS" \
  --traj-chunk-frames "$MDSYS_TRAJ_CHUNK_FRAMES" \
  --seed "$MDSYS_SEED" \
  --output-dir "$MDSYS_OUT/pbc_nvt"
