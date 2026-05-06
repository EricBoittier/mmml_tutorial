#!/usr/bin/env bash
# Example: md_10mer periodic NPT (JAX-MD NHC + barostat)
# Run from this directory: cd cli && bash 20_md_10mer_pbc_npt.sh

set -e
. ./shared.source

echo "=== 20: md_10mer periodic NPT ==="
box_args=()
if [[ -n "$MDSYS_BOX_A" ]]; then
  box_args=(--box-size "$MDSYS_BOX_A")
fi

echo "Command: mmml md-system --setup pbc_npt --backend \"$MDSYS_BACKEND\" --temperature \"$MDSYS_TEMP_K\" --pressure \"$MDSYS_PRESSURE_ATM\" --n-molecules \"$MDSYS_N_MOLECULES\" ${box_args[*]} --ps \"$MDSYS_PS\" --dt-fs \"$MDSYS_DT_FS\" --traj-chunk-frames \"$MDSYS_TRAJ_CHUNK_FRAMES\" --seed \"$MDSYS_SEED\" --output-dir \"$MDSYS_OUT/pbc_npt\""

mmml md-system \
  --setup pbc_npt \
  --backend "$MDSYS_BACKEND" \
  --temperature "$MDSYS_TEMP_K" \
  --pressure "$MDSYS_PRESSURE_ATM" \
  --n-molecules "$MDSYS_N_MOLECULES" \
  "${box_args[@]}" \
  --ps "$MDSYS_PS" \
  --dt-fs "$MDSYS_DT_FS" \
  --traj-chunk-frames "$MDSYS_TRAJ_CHUNK_FRAMES" \
  --seed "$MDSYS_SEED" \
  --output-dir "$MDSYS_OUT/pbc_npt"
