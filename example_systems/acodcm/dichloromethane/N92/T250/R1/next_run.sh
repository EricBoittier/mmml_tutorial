#!/usr/bin/env bash
set -euo pipefail
# Suggested resume (wrap with ./scripts/mmml-charmm-mpirun.sh on GPU nodes).
# prior job: R1 exit=1
CMD=(
  mmml
  md-system
  --output-dir
  dichloromethane/N92/T250/R1
  --backend
  pycharmm
  --no-echeck-heat
)
exec "${CMD[@]}"
