#!/usr/bin/env bash
# Docs §7 — hybrid MD via md-system (smoke PBC NVT).
# Requires: trained checkpoint + CHARMM/PyCHARMM. Default composition ACEM.
#
# Production OpenMPI path (from mmml repo):
#   export MMML_CKPT=...
#   MMML_MPI_NP=1 ./scripts/mmml-charmm-mpirun.sh md-system --config run.yaml
set -euo pipefail
. ./shared.source

CKPT="$(resolve_checkpoint || true)"
if [[ -z "$CKPT" && -f out/last_physnet_checkpoint.txt ]]; then
  CKPT="$(cat out/last_physnet_checkpoint.txt)"
fi
if [[ -z "$CKPT" || ! -e "$CKPT" ]]; then
  echo "error: no checkpoint — set PHYSNET_CHECKPOINT / MMML_CKPT or run 07" >&2
  exit 1
fi

export MMML_CKPT="$CKPT"
OUT="$MDSYS_OUT/${MD_RES,,}_pbc_nvt"

echo "=== 12: md-system pbc_nvt ${MD_RES}:${MD_N} T=${MDSYS_TEMP_K} ==="
echo "MMML_CKPT=$MMML_CKPT"
mmml env || true
mmml md-system --setup pbc_nvt \
  --composition "${MD_RES}:${MD_N}" \
  --temperature "$MDSYS_TEMP_K" \
  --output-dir "$OUT"

echo "Output: $OUT"
