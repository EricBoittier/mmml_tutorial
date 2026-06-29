#!/usr/bin/env bash
set -euo pipefail
# Suggested resume (wrap with ./scripts/mmml-charmm-mpirun.sh on GPU nodes).
# prior job: r1_test exit=2
CMD=(
  mmml
  md-system
  --output-dir
  dichloromethane/n92/t260/r1_test
  --backend
  pycharmm
  --restart-from
  /cluster/home/boittier/mmml_tutorial/acodcm/dichloromethane/n92/t260/r1_test/prep_ladder/002_pre_mlpot_monomer_repack.crd
)
exec "${CMD[@]}"
