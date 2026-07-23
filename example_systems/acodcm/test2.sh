#!/usr/bin/env bash
# DCM free_nvt matrix on pc-bach. Use run_test2_local.sh (CPU/MPI fixes).
# Raw mmml without CHARMM tier / mpirun fails for n>=20 (max 100 ML atoms default lib).
set -euo pipefail
exec "$(dirname "$0")/run_test2_local.sh" "$@"
