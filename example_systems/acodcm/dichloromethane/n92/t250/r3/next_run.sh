#!/usr/bin/env bash
set -euo pipefail
# Suggested resume (wrap with ./scripts/mmml-charmm-mpirun.sh on GPU nodes).
# prior job: r3 exit=0
CMD=(
  mmml
  md-system
  --output-dir
  dichloromethane/n92/t250/r3
  --backend
  pycharmm
  --restart-from
  /cluster/home/boittier/mmml_tutorial/acodcm/dichloromethane/n92/t250/r3/prep_ladder/002_pre_mlpot_monomer_repack.crd
  --no-echeck-heat
)
exec "${CMD[@]}"
