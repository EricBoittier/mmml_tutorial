#!/usr/bin/env bash
set -euo pipefail

DATA="out/splits_ef00_t3/energies_forces_dipoles_test.npz"
SCRIPT_DIR="/mmhome/boittier/home/ckpts/eval_sbatch"
mkdir -p "$SCRIPT_DIR"

PARAMS=(
"/mmhome/boittier/home/ckpts/ef_run1/params-dc3d6888-c75d-43fa-8e3d-2c2692df3d51.json"
"/mmhome/boittier/home/ckpts/ef_run2/params-e59a1562-5c93-4a38-8f78-bb8b3fd2323d.json"
"/mmhome/boittier/home/ckpts/ef_run3/params-a93e60fb-b231-4820-b48a-e34a8ecdb1d5.json"
"/mmhome/boittier/home/ckpts/ef_run4/params-cca47a3f-937e-410b-ac8c-0c3978e03adb.json"
)

for params in "${PARAMS[@]}"; do
    run_dir="$(dirname "$params")"
    run_name="$(basename "$run_dir")"
    param_file="$(basename "$params")"
    param_id="${param_file#params-}"
    param_id="${param_id%.json}"

    eval_dir="${run_dir}/eval_${param_id}"
    output_h5="${eval_dir}/out.h5"
    sbatch_file="${SCRIPT_DIR}/${run_name}_eval_${param_id}.sbatch"

    cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=${run_name}_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=${run_dir}/slurm-eval-${param_id}.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

mmml ef-evaluate \\
  --params "${params}" \\
  --data "${DATA}" \\
  --output-dir "${eval_dir}" \\
  --output-h5 "${output_h5}"
EOF

    chmod +x "$sbatch_file"
    echo "Created: $sbatch_file"
done
