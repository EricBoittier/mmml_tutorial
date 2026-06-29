#!/usr/bin/env bash
set -euo pipefail
# Suggested resume (wrap with ./scripts/mmml-charmm-mpirun.sh on GPU nodes).
# prior job: md_run exit=2
CMD=(
  mmml
  md-system
  --config
  /cluster/home/boittier/mmml_tutorial/cpu_tests/dcm/dcm01/md_system.yaml
  --output-dir
  artifacts/md_run
  --backend
  pycharmm
  --restart-from
  /cluster/home/boittier/mmml_tutorial/cpu_tests/dcm/dcm01/artifacts/md_run/pretreat/mini_box_equil.res
  --md-stages
  mini,heat,nve
  --no-echeck-heat
)
exec "${CMD[@]}"
