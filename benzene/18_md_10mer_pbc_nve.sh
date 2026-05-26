#!/usr/bin/env bash
# Example: md_10mer periodic NVE
# Run from this directory: cd cli && bash 18_md_10mer_pbc_nve.sh

set -e
. ./shared.source

echo "=== 18: md_10mer periodic NVE ==="
box_args=()
if [[ -n "$MDSYS_BOX_A" ]]; then
  box_args=(--box-size "$MDSYS_BOX_A")
fi

echo "Command: mmml md-system --setup pbc_nve --backend \"$MDSYS_BACKEND\" --n-molecules \"$MDSYS_N_MOLECULES\" ${box_args[*]} --ps \"$MDSYS_PS\" --dt-fs \"$MDSYS_DT_FS\" --traj-chunk-frames \"$MDSYS_TRAJ_CHUNK_FRAMES\" --seed \"$MDSYS_SEED\" --output-dir \"$MDSYS_OUT/pbc_nve\""

mmml md-system \
  --setup pbc_nve \
  --backend "$MDSYS_BACKEND" \
  --n-molecules "$MDSYS_N_MOLECULES" \
  "${box_args[@]}" \
  --ps "$MDSYS_PS" \
  --dt-fs "$MDSYS_DT_FS" \
  --traj-chunk-frames "$MDSYS_TRAJ_CHUNK_FRAMES" \
  --seed "$MDSYS_SEED" \
  --output-dir "$MDSYS_OUT/pbc_nve"
