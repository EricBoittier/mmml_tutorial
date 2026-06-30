#!/usr/bin/env bash
# Restart one learning-curve run with outlier structures removed from the train split.
#
# Example (aco n3200/r3, +500 optimizer steps):
#   cd ~/mmml_tutorial/acodcm
#   bash scripts/restart_lc_no_outliers.sh --submit aco_n3200_r3
#   EXTRA_STEPS=500 bash scripts/restart_lc_no_outliers.sh aco_n3200_r3
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EPOCH_TAG="${EPOCH_TAG:-e${NUM_EPOCHS:-1000}}"
EXTRA_STEPS="${EXTRA_STEPS:-500}"
BATCH_SIZE="${BATCH_SIZE:-25}"
OUTLIER_MODE="${OUTLIER_MODE:-bad-energy}"
ENERGY_THRESHOLD="${ENERGY_THRESHOLD:--70}"
PLOT_STYLE="${PLOT_STYLE:-google}"
MAIL_USER="${MAIL_USER:-ericdavid.boittier@unibas.ch}"
VENV_ACTIVATE="${VENV_ACTIVATE:-$HOME/mmml/.venv/bin/activate}"
DO_SUBMIT=0
JOB_KEY="aco_n3200_r3"

for arg in "$@"; do
  case "$arg" in
    --submit) DO_SUBMIT=1 ;;
    -*) echo "Unknown flag: $arg" >&2; exit 2 ;;
    *) JOB_KEY="$arg" ;;
  esac
done

# shellcheck disable=SC1091
source "${ROOT}/scripts/lc_common.sh"

if [[ ! "$JOB_KEY" =~ ^(aco|dcm)_n([0-9]+)_r([0-9]+)$ ]]; then
  echo "Expected job key like aco_n3200_r3, got: $JOB_KEY" >&2
  exit 2
fi

dataset="${BASH_REMATCH[1]}"
n_train="${BASH_REMATCH[2]}"
repeat="${BASH_REMATCH[3]}"
seed=$((42 + repeat * 1000))
n_valid=$(( n_train * 300 / 8000 ))
extra_epochs=0
if (( n_train > 0 )); then
  steps_per_epoch=$(( (n_train + BATCH_SIZE - 1) / BATCH_SIZE ))
  extra_epochs=$(( (EXTRA_STEPS + steps_per_epoch - 1) / steps_per_epoch ))
fi
target_epochs=$(( ${NUM_EPOCHS:-1000} + extra_epochs ))

split_dir="${ROOT}/out/splits/${dataset}/lc_n${n_train}_r${repeat}_no_outliers"
config_path="${ROOT}/configs/learning_curve/${JOB_KEY}_no_outliers.yaml"
ckpt_dir="${ROOT}/ckpts/learning_curve/${EPOCH_TAG}/${dataset}/n${n_train}/r${repeat}"
out_dir="${ROOT}/out/eval/learning_curve/${EPOCH_TAG}/${dataset}/n${n_train}/r${repeat}_no_outliers"
slurm_dir="${ROOT}/slurm/learning_curve/${EPOCH_TAG}"
log_file="${slurm_dir}/restart_${JOB_KEY}_no_outliers.out"
sbatch_file="${slurm_dir}/restart_${JOB_KEY}_no_outliers.sbatch"
test_npz="${ROOT}/out/splits/${dataset}/energies_forces_dipoles_test.npz"
if [[ "$dataset" == "aco" ]]; then
  eval_natoms=20
  num_atoms_line="num_atoms: 20"
else
  eval_natoms=10
  num_atoms_line="# num_atoms: auto-detect"
fi

mkdir -p "$slurm_dir" "$(dirname "$config_path")" "$out_dir"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --job-name=lc-${dataset:0:3}-n${n_train}-r${repeat}-clean
#SBATCH --mail-user=${MAIL_USER}
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1
#SBATCH --exclusive
#SBATCH --exclude=gpu24
#SBATCH --time=01:30:00
#SBATCH --output=${log_file}

set -euo pipefail
source "${VENV_ACTIVATE}"
if [[ -f "${HOME}/mmml/scripts/setup_jax_cuda_env.sh" ]]; then
  # shellcheck disable=SC1091
  source "${HOME}/mmml/scripts/setup_jax_cuda_env.sh"
fi
export JAX_PLATFORMS=cuda
export CUDA_VISIBLE_DEVICES=0
cd "${ROOT}"
# shellcheck disable=SC1091
source "${ROOT}/scripts/lc_common.sh"

echo "=== [0/4] Build filtered split (${OUTLIER_MODE}) ==="
PYTHONPATH="${HOME}/mmml" python3 scripts/build_lc_filtered_split.py \\
  --dataset ${dataset} \\
  --n-train ${n_train} \\
  --repeat ${repeat} \\
  --seed ${seed} \\
  --mode ${OUTLIER_MODE} \\
  --energy-threshold ${ENERGY_THRESHOLD}

cat > "${config_path}" <<YAML
data: ${split_dir}/train.npz
valid_data: ${split_dir}/valid.npz
ckpt_dir: ${ckpt_dir}
tag: ${dataset}1_n${n_train}_r${repeat}_noout
seed: ${seed}
batch_size: ${BATCH_SIZE}
num_epochs: ${target_epochs}
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
YAML

run_dir=\$(pick_orbax_run_dir "${ckpt_dir}")
echo "Restart from: \$run_dir"
echo "Target epochs: ${target_epochs} (+${extra_epochs} after e${NUM_EPOCHS:-1000}, ~${EXTRA_STEPS} steps)"

echo "=== [1/4] Continue training on cleaned split ==="
mmml physnet-train \\
  --config "${config_path}" \\
  --restart "\$run_dir" \\
  --num-epochs ${target_epochs}

run_dir=\$(pick_orbax_run_dir "${ckpt_dir}")
echo "Run directory: \$run_dir"

echo "=== [2/4] Extract metrics + individual plots ==="
metrics_dir="${out_dir}/metrics_individual"
n_ckpt_epochs=\$(find "\$run_dir" -maxdepth 1 -type d -name 'epoch-*' | wc -l)
stride=\$(pick_metrics_stride "\$n_ckpt_epochs")
mmml extract-checkpoint-metrics "\$run_dir" \\
  -o "${out_dir}/training_curves.png" \\
  --metrics-json "${out_dir}/training_metrics.json" \\
  --individual-dir "\$metrics_dir" \\
  --stride "\$stride" \\
  --log-loss \\
  --ef-only \\
  \$(extract_metrics_plot_style_args "${PLOT_STYLE}")

echo "=== [3/4] Hold-out test eval ==="
latest_epoch=\$(latest_epoch_dir "\$run_dir")
mmml orbax-to-json "\$latest_epoch" -o "${out_dir}/latest.json"
eval_ckpt=\$(pick_eval_checkpoint "${ckpt_dir}" "${out_dir}")
mmml physnet-evaluate \\
  --checkpoint "\$eval_ckpt" \\
  --data "${test_npz}" \\
  --natoms ${eval_natoms} \\
  --batch-size ${BATCH_SIZE} \\
  --no-save-npz \\
  -o "${out_dir}"

echo "=== [4/4] run_summary.json ==="
python3 - <<PY
import json
from pathlib import Path
out = Path("${out_dir}")
metrics = json.loads((out / "training_metrics.json").read_text())
eval_metrics = json.loads((out / "metrics.json").read_text())
manifest = json.loads(Path("${split_dir}/manifest.json").read_text())
summary = {
    "dataset": "${dataset}",
    "n_train": ${n_train},
    "n_valid": ${n_valid},
    "repeat": ${repeat},
    "seed": ${seed},
    "num_epochs": ${target_epochs},
    "extra_steps_requested": ${EXTRA_STEPS},
    "outlier_mode": "${OUTLIER_MODE}",
    "n_outliers_removed": manifest.get("n_removed"),
    "removed_indices": manifest.get("removed_indices"),
    "run_dir": str(out),
    "test_eval": {
        "energy_mae_kcal_mol": eval_metrics.get("energy_mae"),
        "forces_mae_kcal_mol": eval_metrics.get("forces_mae"),
    },
    "training_final": {
        "valid_loss": metrics["valid_loss"][-1] if metrics.get("valid_loss") else None,
        "valid_energy_mae": metrics["valid_energy_mae"][-1] if metrics.get("valid_energy_mae") else None,
        "valid_forces_mae": metrics["valid_forces_mae"][-1] if metrics.get("valid_forces_mae") else None,
    },
}
(out / "run_summary.json").write_text(json.dumps(summary, indent=2))
print("Wrote", out / "run_summary.json")
PY

echo "Done. Outputs under ${out_dir}"
EOF

chmod +x "${ROOT}/scripts/restart_lc_no_outliers.sh"

echo "Wrote ${sbatch_file}"
echo "  job=${JOB_KEY}  extra_steps=${EXTRA_STEPS}  extra_epochs=${extra_epochs}  target_epochs=${target_epochs}"
echo "  outlier_mode=${OUTLIER_MODE}  eval_out=${out_dir}"

if (( DO_SUBMIT )); then
  sbatch "$sbatch_file"
else
  echo "Dry run. Submit with: bash scripts/restart_lc_no_outliers.sh --submit ${JOB_KEY}"
fi
