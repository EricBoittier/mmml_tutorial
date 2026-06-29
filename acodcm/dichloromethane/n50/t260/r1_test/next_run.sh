#!/usr/bin/env bash
set -euo pipefail
# Suggested resume (wrap with ./scripts/mmml-charmm-mpirun.sh on GPU nodes).
# prior job: r1_test exit=2
CMD=(
  mmml
  md-system
  --output-dir
  dichloromethane/n50/t260/r1_test
  --backend
  pycharmm
  --restart-from
  /cluster/home/boittier/mmml_tutorial/acodcm/dichloromethane/n50/t260/r1_test/prep_ladder/002_pre_mlpot_monomer_repack.crd
  --md-stages
  mini,heat,equi
  --dynamics-intra-rescue-sd-steps
  400
)
exec "${CMD[@]}"
