#!/bin/bash
#SBATCH --job-name=lc-aco-n3200-r3-fresh
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1
#SBATCH --exclusive
#SBATCH --exclude=gpu24
#SBATCH --time=03:00:00
#SBATCH --output=/mmhome/boittier/home/mmml_tutorial/acodcm/slurm/learning_curve/e1000/fresh_aco_n3200_r3_clean.out

set -euo pipefail
source "/mmhome/boittier/home/mmml/.venv/bin/activate"
if [[ -f "/mmhome/boittier/home/mmml/scripts/setup_jax_cuda_env.sh" ]]; then
  # shellcheck disable=SC1091
  source "/mmhome/boittier/home/mmml/scripts/setup_jax_cuda_env.sh"
fi
export JAX_PLATFORMS=cuda
export CUDA_VISIBLE_DEVICES=0
cd "/mmhome/boittier/home/mmml_tutorial/acodcm"
# shellcheck disable=SC1091
source "/mmhome/boittier/home/mmml_tutorial/acodcm/scripts/lc_common.sh"

echo "=== [0/4] Build filtered split (bad-energy) ==="
PYTHONPATH="/mmhome/boittier/home/mmml" python3 scripts/build_lc_filtered_split.py \
  --dataset aco \
  --n-train 3200 \
  --repeat 3 \
  --seed 3042 \
  --mode bad-energy \
  --energy-threshold -70

cat > "/mmhome/boittier/home/mmml_tutorial/acodcm/configs/learning_curve/aco_n3200_r3_clean.yaml" <<YAML
data: /mmhome/boittier/home/mmml_tutorial/acodcm/out/splits/aco/lc_n3200_r3_no_outliers/train.npz
valid_data: /mmhome/boittier/home/mmml_tutorial/acodcm/out/splits/aco/lc_n3200_r3_no_outliers/valid.npz
n_train: 0
n_valid: 0
ckpt_dir: /mmhome/boittier/home/mmml_tutorial/acodcm/ckpts/learning_curve/e1000/aco/n3200/r3_clean
tag: aco1_n3200_r3_clean
seed: 3042
batch_size: 25
num_epochs: 1000
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
num_atoms: 20
YAML

echo "=== [1/4] Fresh training on cleaned split (1000 epochs) ==="
mmml physnet-train --config "/mmhome/boittier/home/mmml_tutorial/acodcm/configs/learning_curve/aco_n3200_r3_clean.yaml"

run_dir=$(pick_orbax_run_dir "/mmhome/boittier/home/mmml_tutorial/acodcm/ckpts/learning_curve/e1000/aco/n3200/r3_clean")
echo "Run directory: $run_dir"

echo "=== [2/4] Extract metrics + individual plots ==="
metrics_dir="/mmhome/boittier/home/mmml_tutorial/acodcm/out/eval/learning_curve/e1000/aco/n3200/r3_clean/metrics_individual"
n_ckpt_epochs=$(find "$run_dir" -maxdepth 1 -type d -name 'epoch-*' | wc -l)
stride=$(pick_metrics_stride "$n_ckpt_epochs")
mmml extract-checkpoint-metrics "$run_dir" \
  -o "/mmhome/boittier/home/mmml_tutorial/acodcm/out/eval/learning_curve/e1000/aco/n3200/r3_clean/training_curves.png" \
  --metrics-json "/mmhome/boittier/home/mmml_tutorial/acodcm/out/eval/learning_curve/e1000/aco/n3200/r3_clean/training_metrics.json" \
  --individual-dir "$metrics_dir" \
  --stride "$stride" \
  --log-loss \
  --ef-only \
  $(extract_metrics_plot_style_args "google")

echo "=== [3/4] Hold-out test eval ==="
latest_epoch=$(latest_epoch_dir "$run_dir")
latest_num=$(basename "$latest_epoch" | sed 's/epoch-//')
mmml orbax-to-json "$latest_epoch" -o "/mmhome/boittier/home/mmml_tutorial/acodcm/out/eval/learning_curve/e1000/aco/n3200/r3_clean/latest.json"
eval_ckpt=$(pick_eval_checkpoint "/mmhome/boittier/home/mmml_tutorial/acodcm/ckpts/learning_curve/e1000/aco/n3200/r3_clean" "/mmhome/boittier/home/mmml_tutorial/acodcm/out/eval/learning_curve/e1000/aco/n3200/r3_clean")
mmml physnet-evaluate \
  --checkpoint "$eval_ckpt" \
  --data "/mmhome/boittier/home/mmml_tutorial/acodcm/out/splits/aco/energies_forces_dipoles_test.npz" \
  --natoms 20 \
  --batch-size 25 \
  --no-save-npz \
  -o "/mmhome/boittier/home/mmml_tutorial/acodcm/out/eval/learning_curve/e1000/aco/n3200/r3_clean"

echo "=== [4/4] run_summary.json ==="
latest_num=$(basename "$run_dir" | sed 's|.*/epoch-||')
if [[ "$latest_num" == "$run_dir" ]]; then
  latest_num=$(basename "$(latest_epoch_dir "$run_dir")" | sed 's/epoch-//')
fi
python3 - <<PY
import json
from pathlib import Path
out = Path("/mmhome/boittier/home/mmml_tutorial/acodcm/out/eval/learning_curve/e1000/aco/n3200/r3_clean")
metrics = json.loads((out / "training_metrics.json").read_text())
eval_metrics = json.loads((out / "metrics.json").read_text())
manifest = json.loads(Path("/mmhome/boittier/home/mmml_tutorial/acodcm/out/splits/aco/lc_n3200_r3_no_outliers/manifest.json").read_text())
energy = eval_metrics.get("energy", {})
forces = eval_metrics.get("forces", {})
summary = {
    "dataset": "aco",
    "n_train": 3200,
    "n_valid": 120,
    "repeat": 3,
    "seed": 3042,
    "num_epochs": 1000,
    "training_mode": "fresh_clean_split",
    "outlier_mode": "bad-energy",
    "n_outliers_removed": manifest.get("n_removed"),
    "removed_indices": manifest.get("removed_indices"),
    "run_dir": "/mmhome/boittier/home/mmml_tutorial/acodcm/ckpts/learning_curve/e1000/aco/n3200/r3_clean",
    "orbax_run_dir": "$run_dir",
    "latest_epoch": f"epoch-{$latest_num}",
    "test_eval": {
        "energy_mae_kcal_mol": energy.get("mae_kcal_mol"),
        "energy_rmse_kcal_mol": energy.get("rmse_kcal_mol"),
        "forces_mae_kcal_mol": forces.get("mae_kcal_mol"),
        "forces_rmse_kcal_mol": forces.get("rmse_kcal_mol"),
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

echo "Done. Outputs under /mmhome/boittier/home/mmml_tutorial/acodcm/out/eval/learning_curve/e1000/aco/n3200/r3_clean"
