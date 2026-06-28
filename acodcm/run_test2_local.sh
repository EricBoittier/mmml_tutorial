#!/usr/bin/env bash
# Run test2.sh DCM free_nvt jobs on pc-bach (CPU + MPI).
# Fixes vs raw test2.sh:
#   - pc_bach_env + mmml-charmm-mpirun.sh (no bare mmml under MPI-linked CHARMM)
#   - per-job CHARMM tier via ensure_charmm_mlpot_limits (default libcharmm is max 100 ML atoms)
#   - spacing 4.0 / packmol-radius 20 (spacing 1.0 is too dense for liquid_prep gate)
#   - serial JAX warmup before each MPI md-system (avoids compile OOM/segfault on contested nodes)
#   - one exclusive srun per job on an idle node
#   - vacuum overlap: warn only (rescue needs PBC box and fails on free_nvt)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MMML_ROOT="${MMML_ROOT:-/cluster/home/boittier/mmml}"
cd "$ROOT"

# shellcheck source=../../mmml/scripts/pc_bach_env.sh
source "$MMML_ROOT/scripts/pc_bach_env.sh"
export JAX_ENABLE_X64=1
export MMML_CKPT="${MMML_CKPT:-$MMML_ROOT/examples/ckpts_json/DESdimers_params.json}"
export MMML_MLPOT_DEVICE=cpu
export JAX_PLATFORMS=cpu
unset CUDA_VISIBLE_DEVICES
export XLA_PYTHON_CLIENT_PREALLOCATE=false
export MMML_JAX_COMPILE_THREADS="${MMML_JAX_COMPILE_THREADS:-4}"

MPIRUN="$MMML_ROOT/scripts/mmml-charmm-mpirun.sh"
ENSURE="$MMML_ROOT/scripts/ensure_charmm_mlpot_limits.sh"
WARMUP="$MMML_ROOT/.venv/bin/mmml"

temps=(250 260)
sizes=$(seq 92 3 100)
repeats=$(seq 1 4)

log_dir="$ROOT/artifacts/test2_local_logs"
mkdir -p "$log_dir"

pick_idle_node() {
  sinfo -h -N -p long -t idle -o "%N %m" 2>/dev/null \
    | awk '$2 >= 400000 {print $1}' | head -1
}

job_done() {
  local outdir=$1 nres=$2
  local summary="$outdir/stage_summary.json"
  local topo="$outdir/model.topology.json"
  [[ -f "$summary" && -f "$topo" ]] || return 1
  python3 - "$summary" "$topo" "$nres" <<'PY'
import json, sys
summary_path, topo_path, nres = sys.argv[1:4]
nres = int(nres)
summary = json.load(open(summary_path))
topo = json.load(open(topo_path))
if int(topo.get("nres", 0)) != nres:
    sys.exit(1)
if int(summary.get("exit_code", 1)) != 0:
    sys.exit(1)
heat = next((s for s in summary.get("stages", []) if s.get("stage") == "heat"), None)
if heat is None or heat.get("status") != "completed":
    sys.exit(1)
sys.exit(0)
PY
}

reset_outdir_if_wrong() {
  local outdir=$1 nres=$2
  local topo="$outdir/model.topology.json"
  if [[ -f "$topo" ]]; then
    local have
    have=$(python3 -c "import json; print(json.load(open('$topo')).get('nres',0))")
    if [[ "$have" != "$nres" ]]; then
      echo "Removing stale output (nres=$have, want $nres): $outdir"
      rm -rf "$outdir"
    fi
  fi
}

run_one() {
  local temp=$1 nres=$2 rep=$3
  local seed=$((200000 * rep + 1000 * nres + temp))
  local outdir="./dichloromethane/n${nres}/t${temp}/r${rep}"
  local tag="n${nres}_t${temp}_r${rep}"
  local log="$log_dir/${tag}.log"
  local n_ml=$((5 * nres))
  local node

  if job_done "$outdir" "$nres"; then
    echo "SKIP $tag (already complete)" | tee -a "$log_dir/summary.log"
    return 0
  fi

  reset_outdir_if_wrong "$outdir" "$nres"

  node=$(pick_idle_node || true)
  if [[ -z "${node:-}" ]]; then
    node=$(sinfo -h -N -p long -t idle -o "%N" 2>/dev/null | head -1 || true)
  fi
  if [[ -z "${node:-}" ]]; then
    echo "ERROR: no idle node for $tag" | tee -a "$log"
    return 1
  fi

  echo "=== [$tag] node=$node $(date -Is) ===" | tee "$log"
  eval "$("$ENSURE" --n-ml "$n_ml" --box-size 30 2>&1 | grep '^export ' || true)"
  if [[ -z "${CHARMM_LIB_DIR:-}" ]]; then
    echo "ERROR: CHARMM_LIB_DIR unset for $tag" | tee -a "$log"
    return 1
  fi
  echo "CHARMM_LIB_DIR=$CHARMM_LIB_DIR" | tee -a "$log"

  local srun_extra=(--partition=long --exclusive --nodelist="$node" --cpus-per-task=16 --mem=180G --time=12:00:00)
  if ! srun "${srun_extra[@]}" bash -lc "
      set -euo pipefail
      source '$MMML_ROOT/scripts/pc_bach_env.sh'
      export CHARMM_LIB_DIR='$CHARMM_LIB_DIR'
      export JAX_ENABLE_X64=1 MMML_CKPT='$MMML_CKPT' MMML_MLPOT_DEVICE=cpu JAX_PLATFORMS=cpu
      export XLA_PYTHON_CLIENT_PREALLOCATE=false MMML_JAX_COMPILE_THREADS=4
      unset CUDA_VISIBLE_DEVICES OMPI_COMM_WORLD_SIZE PMI_SIZE PMIX_SIZE
      cd '$ROOT'

      echo '--- warmup-mlpot-jax ---'
      '$WARMUP' warmup-mlpot-jax --checkpoint '$MMML_CKPT' \\
        --n-monomers $nres --atoms-per-monomer 5 --box-side 0 \\
        --ml-batch-size 32 --compile-threads 4

      echo '--- md-system ---'
      '$MPIRUN' md-system \\
        --setup free_nvt --backend pycharmm --spacing 4.0 --temperature $temp \\
        --composition DCM:${nres} --packmol-radius 20 --flat-bottom-radius 100.0 \\
        --ps 100 --seed $seed --dt-fs 0.1 --traj-chunk-frames 1000 --flat-bottom-k 1.0 \\
        --ml-batch-size 32 --no-echeck-heat --cleanup \\
        --dynamics-intra-rescue-sd-steps 400 --dynamics-intra-min-distance 0.95 \\
        --dynamics-overlap-action warn \\
        --output-dir '$outdir'
    " >>"$log" 2>&1; then
    echo "FAILED $tag (see $log)" | tee -a "$log_dir/summary.log"
    return 1
  fi

  if job_done "$outdir" "$nres"; then
    echo "OK $tag" | tee -a "$log_dir/summary.log"
    return 0
  fi
  echo "FAILED $tag (incomplete; see $log and $outdir/stage_summary.json)" | tee -a "$log_dir/summary.log"
  return 1
}

for temp in "${temps[@]}"; do
  for nres in $sizes; do
    for rep in $repeats; do
      run_one "$temp" "$nres" "$rep" || true
    done
  done
done

echo "Done. Logs: $log_dir"
