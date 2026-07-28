#!/usr/bin/env bash
set -euo pipefail
# Suggested resume (wrap with ./scripts/mmml-charmm-mpirun.sh on GPU nodes).
# prior job: md_run exit=2
CMD=(
  mmml
  md-system
  --config
  md_system.yaml
  --output-dir
  artifacts/md_run
  --backend
  pycharmm
  --restart-from
  /mmhome/boittier/home/mmml_tutorial/tests/cpu_tests/dcm/dcm01/artifacts/md_run/baseline.res
  --md-stages
  mini,heat,nve
  --dynamics-intra-rescue-sd-steps
  800
)
exec "${CMD[@]}"
