#!/usr/bin/env bash
set -euo pipefail

DATA="out/splits_ef00_t3/energies_forces_dipoles_test.npz"
SCRIPT_DIR="/mmhome/boittier/home/ckpts/eval_sbatch2"
mkdir -p "$SCRIPT_DIR"

PARAMS=(
"/mmhome/boittier/home/ckpts/nopt_ef_run5/params-b94f99c7-14c1-4904-b6ae-050778b89e36.json"
"/mmhome/boittier/home/ckpts/ef_run5/params-2a43e598-d310-43a0-85d0-353388cda93d.json"
"/mmhome/boittier/home/ckpts/nopt_ef_run1/params-eaf9407e-d61a-44e6-8af4-a4314324c0c7.json"
"/mmhome/boittier/home/ckpts/nopt_ef_run2/params-c3882ad7-3349-47fb-8335-4e6ffe74da8b.json"
"/mmhome/boittier/home/ckpts/nopt_ef_run3/params-97938270-df87-42eb-bb1c-7aa28d8ea247.json"
"/mmhome/boittier/home/ckpts/nopt_ef_run4/params-91619cb7-6aa6-4af4-b875-d0c5d661bd71.json"
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
