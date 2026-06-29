#!/usr/bin/env bash
# Generate (and optionally submit) GPU Slurm jobs for PhysNet learning-curve sweeps.
#
# Trains on subsampled train NPZ at n_train ∈ {800,1600,3200,6400,12000} with 3 seeds
# for both aco and dcm datasets. Each job also extracts loss curves + hold-out test E/F.
#
# Usage:
#   cd ~/mmml_tutorial/acodcm
#   bash scripts/submit_learning_curve_sweep.sh              # dry run (write configs + sbatch)
#   bash scripts/submit_learning_curve_sweep.sh --submit     # submit all jobs
#   NUM_EPOCHS=1000 bash scripts/submit_learning_curve_sweep.sh --submit
#   bash scripts/submit_learning_curve_sweep.sh --submit --serial  # one GPU job at a time
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SIZES=(800 1600 3200 6400 12000)
REPEATS=(1 2 3)
DATASETS=(aco dcm)
MAIL_USER="${MAIL_USER:-ericdavid.boittier@unibas.ch}"
PARTITION="${PARTITION:-gpu}"
SUMMARY_PARTITION="${SUMMARY_PARTITION:-teach}"
EXCLUDE_NODES="${EXCLUDE_NODES:-gpu24}"
# One training job per GPU node (Slurm sets CUDA_VISIBLE_DEVICES; multiple jobs on same node collide)
SBATCH_EXCLUSIVE="${SBATCH_EXCLUSIVE:-1}"
VENV_ACTIVATE="${VENV_ACTIVATE:-$HOME/mmml/.venv/bin/activate}"
NUM_EPOCHS="${NUM_EPOCHS:-1000}"
PLOT_STYLE="${PLOT_STYLE:-google}"

# Separate artifact dirs per epoch budget (avoid mixing 3500-epoch partial runs with 1k reruns).
EPOCH_TAG="${EPOCH_TAG:-e${NUM_EPOCHS}}"

CONFIG_DIR="${ROOT}/configs/learning_curve/generated_${EPOCH_TAG}"
CKPT_ROOT="${ROOT}/ckpts/learning_curve/${EPOCH_TAG}"
OUT_ROOT="${ROOT}/out/eval/learning_curve/${EPOCH_TAG}"
SLURM_DIR="${ROOT}/slurm/learning_curve/${EPOCH_TAG}"

DO_SUBMIT=0
DO_SERIAL=0
for arg in "$@"; do
  case "$arg" in
    --submit) DO_SUBMIT=1 ;;
    --serial) DO_SERIAL=1 ;;
  esac
done

mkdir -p "$CONFIG_DIR" "$CKPT_ROOT" "$OUT_ROOT" "$SLURM_DIR"
# shellcheck disable=SC1091
source "${ROOT}/scripts/lc_common.sh"

n_valid_for() {
  local n_train="$1"
  echo $(( n_train * 300 / 8000 ))
}

seed_for_repeat() {
  local repeat="$1"
  echo $(( 42 + repeat * 1000 ))
}

time_for_size() {
  local n_train="$1"
  # ~1000 epochs: scale walltime mildly with dataset size (train steps/epoch).
  if (( n_train <= 1600 )); then
    echo "02:00:00"
  elif (( n_train <= 6400 )); then
    echo "03:00:00"
  else
    echo "04:00:00"
  fi
}

write_config() {
  local dataset="$1" n_train="$2" repeat="$3" n_valid="$4" seed="$5" config_path="$6"
  local tag data_path num_atoms_line
  tag="${dataset}1_n${n_train}_r${repeat}"
  data_path="./out/splits/${dataset}/energies_forces_dipoles_train.npz"
  num_atoms_line=""
  if [[ "$dataset" == "aco" ]]; then
    num_atoms_line="num_atoms: 20"
  else
    num_atoms_line="# num_atoms: auto-detect (10 for dcm)"
  fi

  cat > "$config_path" <<EOF
data: ${data_path}
ckpt_dir: ./ckpts/learning_curve/${EPOCH_TAG}/${dataset}/n${n_train}/r${repeat}
tag: ${tag}
n_train: ${n_train}
n_valid: ${n_valid}
seed: ${seed}

batch_size: 25
num_epochs: ${NUM_EPOCHS}
learning_rate: 0.001
optimizer: amsgrad
energy_weight: 1000.0
forces_weight: 100.0
dipole_weight: 1.0
charges_weight: 1.0
charges: true
include_electrostatics: false

max_atomic_number: 35
features: 32
max_degree: 2
num_basis_functions: 32
num_iterations: 3
n_res: 3
cutoff: 4.0
zbl: true
${num_atoms_line}
EOF
}

runs_file="$SLURM_DIR/runs.tsv"
: > "$runs_file"
job_ids=()

for dataset in "${DATASETS[@]}"; do
  test_npz="${ROOT}/out/splits/${dataset}/energies_forces_dipoles_test.npz"
  if [[ "$dataset" == "aco" ]]; then
    eval_natoms=20
  else
    eval_natoms=10
  fi

  for n_train in "${SIZES[@]}"; do
    n_valid="$(n_valid_for "$n_train")"
    walltime="$(time_for_size "$n_train")"

    for repeat in "${REPEATS[@]}"; do
      seed="$(seed_for_repeat "$repeat")"
      job_key="${dataset}_n${n_train}_r${repeat}"
      config_path="${CONFIG_DIR}/${job_key}.yaml"
      ckpt_dir="${CKPT_ROOT}/${dataset}/n${n_train}/r${repeat}"
      out_dir="${OUT_ROOT}/${dataset}/n${n_train}/r${repeat}"
      sbatch_file="${SLURM_DIR}/${job_key}.sbatch"
      log_file="${SLURM_DIR}/${job_key}.out"

      write_config "$dataset" "$n_train" "$repeat" "$n_valid" "$seed" "$config_path"

      cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --job-name=lc-${dataset:0:3}-n${n_train}-r${repeat}
#SBATCH --mail-user=${MAIL_USER}
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --partition=${PARTITION}
#SBATCH --gres=gpu:1
$([[ "${SBATCH_EXCLUSIVE}" == "1" ]] && echo "#SBATCH --exclusive")
#SBATCH --exclude=${EXCLUDE_NODES}
#SBATCH --time=${walltime}
#SBATCH --output=${log_file}

set -euo pipefail
echo "HOST=\$HOSTNAME  DATE=\$(date -Is)"
echo "JOB=${job_key}  n_train=${n_train}  n_valid=${n_valid}  seed=${seed}  epochs=${NUM_EPOCHS}"

source "${VENV_ACTIVATE}"
if [[ -f "${HOME}/mmml/scripts/setup_jax_cuda_env.sh" ]]; then
  # shellcheck disable=SC1091
  source "${HOME}/mmml/scripts/setup_jax_cuda_env.sh"
fi
export JAX_PLATFORMS=cuda
export CUDA_VISIBLE_DEVICES=0
cd "${ROOT}"
mkdir -p "${ckpt_dir}" "${out_dir}"
# shellcheck disable=SC1091
source "${ROOT}/scripts/lc_common.sh"

echo "=== [1/3] PhysNet training ==="
mmml physnet-train --config "${config_path}"

run_dir=\$(pick_orbax_run_dir "${ckpt_dir}")
echo "Run directory: \$run_dir"

echo "=== [2/3] Learning curves from checkpoints ==="
n_ckpt_epochs=\$(find "\$run_dir" -maxdepth 1 -type d -name 'epoch-*' | wc -l)
stride=\$(pick_metrics_stride "\$n_ckpt_epochs")
mmml extract-checkpoint-metrics "\$run_dir" \\
  -o "${out_dir}/training_curves.png" \\
  --metrics-json "${out_dir}/training_metrics.json" \\
  --stride "\$stride" \\
  --log-loss \\
  --ef-only \\
  \$(extract_metrics_plot_style_args "${PLOT_STYLE}")

echo "=== [3/3] Hold-out test E/F evaluation ==="
latest_epoch=\$(latest_epoch_dir "\$run_dir")
latest_num=\$(basename "\$latest_epoch" | sed 's/epoch-//')
echo "Latest epoch: \$latest_epoch"
mmml orbax-to-json "\$latest_epoch" -o "${out_dir}/latest.json"
eval_ckpt=\$(pick_eval_checkpoint "${ckpt_dir}" "${out_dir}")
echo "Eval checkpoint: \$eval_ckpt"
mmml physnet-evaluate \\
  --checkpoint "\$eval_ckpt" \\
  --data "${test_npz}" \\
  --natoms ${eval_natoms} \\
  --batch-size 25 \\
  --no-save-npz \\
  -o "${out_dir}"

python3 - <<PY
import json
from pathlib import Path
out = Path("${out_dir}")
metrics = json.loads((out / "metrics.json").read_text())
train = json.loads((out / "training_metrics.json").read_text())
summary = {
    "dataset": "${dataset}",
    "n_train": ${n_train},
    "n_valid": ${n_valid},
    "repeat": ${repeat},
    "seed": ${seed},
    "num_epochs": ${NUM_EPOCHS},
    "run_dir": str(Path("\$run_dir")),
    "latest_epoch": "epoch-\${latest_num}",
    "test_eval": {
        "energy_mae_kcal_mol": metrics["energy"]["mae_kcal_mol"],
        "energy_rmse_kcal_mol": metrics["energy"]["rmse_kcal_mol"],
        "forces_mae_kcal_mol": metrics["forces"]["mae_kcal_mol"],
        "forces_rmse_kcal_mol": metrics["forces"]["rmse_kcal_mol"],
    },
    "training_final": {
        "valid_loss": train["valid_loss"][-1] if train.get("valid_loss") else None,
        "valid_energy_mae": train["valid_energy_mae"][-1] if train.get("valid_energy_mae") else None,
        "valid_forces_mae": train["valid_forces_mae"][-1] if train.get("valid_forces_mae") else None,
    },
}
(out / "run_summary.json").write_text(json.dumps(summary, indent=2))
print(json.dumps(summary, indent=2))
PY

echo "Done: ${out_dir}"
EOF
      chmod +x "$sbatch_file"
      printf '%s\t%s\t%d\t%d\t%d\t%s\t%s\n' \
        "$job_key" "$dataset" "$n_train" "$repeat" "$seed" "$sbatch_file" "$out_dir" >> "$runs_file"
      echo "Wrote $sbatch_file  (${dataset} n_train=${n_train} r=${repeat})"

      if (( DO_SUBMIT )); then
        if (( DO_SERIAL )); then
          job_id=$(sbatch --parsable "$sbatch_file")
          job_ids+=("$job_id")
          echo "  submitted $job_id (serial wait)"
          while squeue -j "$job_id" -h 2>/dev/null | grep -q .; do
            sleep 60
          done
          state=$(sacct -j "$job_id" --format=State -n -P 2>/dev/null | head -1 | cut -d'|' -f1)
          echo "  finished $job_id state=$state" | tee -a "${SLURM_DIR}/serial_submit.log"
        else
          job_id=$(sbatch --parsable "$sbatch_file")
          job_ids+=("$job_id")
          echo "  submitted $job_id"
        fi
      fi
    done
  done
done

if (( DO_SUBMIT )) && ((${#job_ids[@]} > 0)); then
  dep=$(IFS=:; echo "${job_ids[*]}")
  summary_sbatch="${SLURM_DIR}/summary_compare.sbatch"
  cat > "$summary_sbatch" <<EOF
#!/bin/bash
#SBATCH --job-name=lc-summary
#SBATCH --mail-user=${MAIL_USER}
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=8000
#SBATCH --partition=${SUMMARY_PARTITION}
#SBATCH --time=01:00:00
#SBATCH --dependency=afterany:${dep}
#SBATCH --output=${SLURM_DIR}/summary_compare.out

set -euo pipefail
source "${VENV_ACTIVATE}"
cd "${ROOT}"
python3 "${ROOT}/scripts/plot_learning_curve_sweep.py" \\
  --eval-root "${OUT_ROOT}" \\
  --output "${OUT_ROOT}/comparison_all.png" \\
  --summary-json "${OUT_ROOT}/aggregate_summary.json" \\
  --plot-style ${PLOT_STYLE}
EOF
  chmod +x "$summary_sbatch"
  if (( ! DO_SERIAL )); then
    sid=$(sbatch --parsable "$summary_sbatch")
    echo "Submitted summary job $sid (afterany:${dep})"
  else
    echo "Serial mode: run summary after all jobs finish:"
    echo "  sbatch ${summary_sbatch}"
  fi
fi

echo ""
echo "Configs:  $CONFIG_DIR"
echo "Slurm:    $SLURM_DIR"
echo "Ckpts:    $CKPT_ROOT"
echo "Results:  $OUT_ROOT"
echo "Runs TSV: $runs_file"
if (( ! DO_SUBMIT )); then
  echo "Submit with: bash scripts/submit_learning_curve_sweep.sh --submit"
fi
