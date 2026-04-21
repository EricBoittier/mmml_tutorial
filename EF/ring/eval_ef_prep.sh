#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="/mmhome/boittier/home/mmml_tutorial/EF/hper/ckpts/eval_sbatch3"
mkdir -p "$SCRIPT_DIR"

run_dir="/mmhome/boittier/home/ckpts/ef0_run2"
run_name="ef0_run2"
params="/mmhome/boittier/home/ckpts/ef0_run2/params-82503ea3-6405-4d20-aea3-dd3e2e7cd2bd.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef0_sim/energies_forces_dipoles_train.npz"
param_id="82503ea3-6405-4d20-aea3-dd3e2e7cd2bd"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/ef0_run2_eval_82503ea3-6405-4d20-aea3-dd3e2e7cd2bd.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=ef0_run2_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/mmhome/boittier/home/ckpts/ef0_run2/slurm-eval-82503ea3-6405-4d20-aea3-dd3e2e7cd2bd.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/mmhome/boittier/home/ckpts/ef0_run2"
run_name="ef0_run2"
params="/mmhome/boittier/home/ckpts/ef0_run2/params-1879dbfd-c447-47d3-85e0-5956e9e4178d.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef0_sim/energies_forces_dipoles_train.npz"
param_id="1879dbfd-c447-47d3-85e0-5956e9e4178d"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/ef0_run2_eval_1879dbfd-c447-47d3-85e0-5956e9e4178d.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=ef0_run2_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/mmhome/boittier/home/ckpts/ef0_run2/slurm-eval-1879dbfd-c447-47d3-85e0-5956e9e4178d.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/mmhome/boittier/home/ckpts/ef0_run2"
run_name="ef0_run2"
params="/mmhome/boittier/home/ckpts/ef0_run2/params-a5575a72-e476-4e6c-b609-eb85917a56e6.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef0_sim/energies_forces_dipoles_train.npz"
param_id="a5575a72-e476-4e6c-b609-eb85917a56e6"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/ef0_run2_eval_a5575a72-e476-4e6c-b609-eb85917a56e6.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=ef0_run2_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/mmhome/boittier/home/ckpts/ef0_run2/slurm-eval-a5575a72-e476-4e6c-b609-eb85917a56e6.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/mmhome/boittier/home/ckpts/ef0_run2"
run_name="ef0_run2"
params="/mmhome/boittier/home/ckpts/ef0_run2/params-a5575a72-e476-4e6c-b609-eb85917a56e6.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef0_sim/energies_forces_dipoles_train.npz"
param_id="a5575a72-e476-4e6c-b609-eb85917a56e6"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/ef0_run2_eval_a5575a72-e476-4e6c-b609-eb85917a56e6.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=ef0_run2_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/mmhome/boittier/home/ckpts/ef0_run2/slurm-eval-a5575a72-e476-4e6c-b609-eb85917a56e6.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/mmhome/boittier/home/ckpts/nopt_ef_run5"
run_name="nopt_ef_run5"
params="/mmhome/boittier/home/ckpts/nopt_ef_run5/params-76e9be6c-db57-4353-8fd1-c12ac9575d9c.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef0_t3/energies_forces_dipoles_train.npz"
param_id="76e9be6c-db57-4353-8fd1-c12ac9575d9c"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/nopt_ef_run5_eval_76e9be6c-db57-4353-8fd1-c12ac9575d9c.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=nopt_ef_run5_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/mmhome/boittier/home/ckpts/nopt_ef_run5/slurm-eval-76e9be6c-db57-4353-8fd1-c12ac9575d9c.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/mmhome/boittier/home/ckpts/nopt_ef_run5"
run_name="nopt_ef_run5"
params="/mmhome/boittier/home/ckpts/nopt_ef_run5/params-76e9be6c-db57-4353-8fd1-c12ac9575d9c.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef0_t3/energies_forces_dipoles_train.npz"
param_id="76e9be6c-db57-4353-8fd1-c12ac9575d9c"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/nopt_ef_run5_eval_76e9be6c-db57-4353-8fd1-c12ac9575d9c.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=nopt_ef_run5_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/mmhome/boittier/home/ckpts/nopt_ef_run5/slurm-eval-76e9be6c-db57-4353-8fd1-c12ac9575d9c.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/mmhome/boittier/home/ckpts/nopt_ef_run0"
run_name="nopt_ef_run0"
params="/mmhome/boittier/home/ckpts/nopt_ef_run0/params-2a13de15-639d-4352-8860-3ea480126348.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef0_t3/energies_forces_dipoles_train.npz"
param_id="2a13de15-639d-4352-8860-3ea480126348"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/nopt_ef_run0_eval_2a13de15-639d-4352-8860-3ea480126348.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=nopt_ef_run0_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/mmhome/boittier/home/ckpts/nopt_ef_run0/slurm-eval-2a13de15-639d-4352-8860-3ea480126348.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/mmhome/boittier/home/ckpts/nopt_ef_run0"
run_name="nopt_ef_run0"
params="/mmhome/boittier/home/ckpts/nopt_ef_run0/params-2a13de15-639d-4352-8860-3ea480126348.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef0_t3/energies_forces_dipoles_train.npz"
param_id="2a13de15-639d-4352-8860-3ea480126348"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/nopt_ef_run0_eval_2a13de15-639d-4352-8860-3ea480126348.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=nopt_ef_run0_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/mmhome/boittier/home/ckpts/nopt_ef_run0/slurm-eval-2a13de15-639d-4352-8860-3ea480126348.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/mmhome/boittier/home/ckpts/nopt_ef_run4"
run_name="nopt_ef_run4"
params="/mmhome/boittier/home/ckpts/nopt_ef_run4/params-0cab1cd9-14fa-4886-bb4a-e0aba0069032.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef0_t3/energies_forces_dipoles_train.npz"
param_id="0cab1cd9-14fa-4886-bb4a-e0aba0069032"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/nopt_ef_run4_eval_0cab1cd9-14fa-4886-bb4a-e0aba0069032.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=nopt_ef_run4_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/mmhome/boittier/home/ckpts/nopt_ef_run4/slurm-eval-0cab1cd9-14fa-4886-bb4a-e0aba0069032.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/mmhome/boittier/home/ckpts/nopt_ef_run4"
run_name="nopt_ef_run4"
params="/mmhome/boittier/home/ckpts/nopt_ef_run4/params-0cab1cd9-14fa-4886-bb4a-e0aba0069032.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef0_t3/energies_forces_dipoles_train.npz"
param_id="0cab1cd9-14fa-4886-bb4a-e0aba0069032"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/nopt_ef_run4_eval_0cab1cd9-14fa-4886-bb4a-e0aba0069032.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=nopt_ef_run4_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/mmhome/boittier/home/ckpts/nopt_ef_run4/slurm-eval-0cab1cd9-14fa-4886-bb4a-e0aba0069032.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/mmhome/boittier/home/ckpts/nopt_ef_run4"
run_name="nopt_ef_run4"
params="/mmhome/boittier/home/ckpts/nopt_ef_run4/params-68783a67-7fcf-47f8-bb85-fd1b19263e63.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef0_t3/energies_forces_dipoles_train.npz"
param_id="68783a67-7fcf-47f8-bb85-fd1b19263e63"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/nopt_ef_run4_eval_68783a67-7fcf-47f8-bb85-fd1b19263e63.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=nopt_ef_run4_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/mmhome/boittier/home/ckpts/nopt_ef_run4/slurm-eval-68783a67-7fcf-47f8-bb85-fd1b19263e63.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/mmhome/boittier/home/ckpts/nopt_ef_run3"
run_name="nopt_ef_run3"
params="/mmhome/boittier/home/ckpts/nopt_ef_run3/params-601a1010-e2b0-487b-8f75-54326a4904b3.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef0_t3/energies_forces_dipoles_train.npz"
param_id="601a1010-e2b0-487b-8f75-54326a4904b3"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/nopt_ef_run3_eval_601a1010-e2b0-487b-8f75-54326a4904b3.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=nopt_ef_run3_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/mmhome/boittier/home/ckpts/nopt_ef_run3/slurm-eval-601a1010-e2b0-487b-8f75-54326a4904b3.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/mmhome/boittier/home/ckpts/nopt_ef_run3"
run_name="nopt_ef_run3"
params="/mmhome/boittier/home/ckpts/nopt_ef_run3/params-939923a2-d826-40af-adbf-8a82ca810ff9.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef00_t3/energies_forces_dipoles_train.npz"
param_id="939923a2-d826-40af-adbf-8a82ca810ff9"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/nopt_ef_run3_eval_939923a2-d826-40af-adbf-8a82ca810ff9.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=nopt_ef_run3_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/mmhome/boittier/home/ckpts/nopt_ef_run3/slurm-eval-939923a2-d826-40af-adbf-8a82ca810ff9.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/mmhome/boittier/home/ckpts/nopt_ef_run3"
run_name="nopt_ef_run3"
params="/mmhome/boittier/home/ckpts/nopt_ef_run3/params-939923a2-d826-40af-adbf-8a82ca810ff9.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef00_t3/energies_forces_dipoles_train.npz"
param_id="939923a2-d826-40af-adbf-8a82ca810ff9"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/nopt_ef_run3_eval_939923a2-d826-40af-adbf-8a82ca810ff9.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=nopt_ef_run3_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/mmhome/boittier/home/ckpts/nopt_ef_run3/slurm-eval-939923a2-d826-40af-adbf-8a82ca810ff9.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/mmhome/boittier/home/ckpts/nopt_ef_run2"
run_name="nopt_ef_run2"
params="/mmhome/boittier/home/ckpts/nopt_ef_run2/params-489f9021-269e-48ab-b7e2-d563afc1a368.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef0_t3/energies_forces_dipoles_train.npz"
param_id="489f9021-269e-48ab-b7e2-d563afc1a368"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/nopt_ef_run2_eval_489f9021-269e-48ab-b7e2-d563afc1a368.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=nopt_ef_run2_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/mmhome/boittier/home/ckpts/nopt_ef_run2/slurm-eval-489f9021-269e-48ab-b7e2-d563afc1a368.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/mmhome/boittier/home/ckpts/nopt_ef_run2"
run_name="nopt_ef_run2"
params="/mmhome/boittier/home/ckpts/nopt_ef_run2/params-cd433256-7617-4958-ba13-ef119356c8d6.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef00_t3/energies_forces_dipoles_train.npz"
param_id="cd433256-7617-4958-ba13-ef119356c8d6"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/nopt_ef_run2_eval_cd433256-7617-4958-ba13-ef119356c8d6.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=nopt_ef_run2_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/mmhome/boittier/home/ckpts/nopt_ef_run2/slurm-eval-cd433256-7617-4958-ba13-ef119356c8d6.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/mmhome/boittier/home/ckpts/nopt_ef_run2"
run_name="nopt_ef_run2"
params="/mmhome/boittier/home/ckpts/nopt_ef_run2/params-cd433256-7617-4958-ba13-ef119356c8d6.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef00_t3/energies_forces_dipoles_train.npz"
param_id="cd433256-7617-4958-ba13-ef119356c8d6"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/nopt_ef_run2_eval_cd433256-7617-4958-ba13-ef119356c8d6.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=nopt_ef_run2_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/mmhome/boittier/home/ckpts/nopt_ef_run2/slurm-eval-cd433256-7617-4958-ba13-ef119356c8d6.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/mmhome/boittier/home/ckpts/nopt_ef_run1"
run_name="nopt_ef_run1"
params="/mmhome/boittier/home/ckpts/nopt_ef_run1/params-e572e06c-8fb7-4060-854a-dec53e6b4eab.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef0_t3/energies_forces_dipoles_train.npz"
param_id="e572e06c-8fb7-4060-854a-dec53e6b4eab"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/nopt_ef_run1_eval_e572e06c-8fb7-4060-854a-dec53e6b4eab.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=nopt_ef_run1_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/mmhome/boittier/home/ckpts/nopt_ef_run1/slurm-eval-e572e06c-8fb7-4060-854a-dec53e6b4eab.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/mmhome/boittier/home/ckpts/nopt_ef_run1"
run_name="nopt_ef_run1"
params="/mmhome/boittier/home/ckpts/nopt_ef_run1/params-e572e06c-8fb7-4060-854a-dec53e6b4eab.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef0_t3/energies_forces_dipoles_train.npz"
param_id="e572e06c-8fb7-4060-854a-dec53e6b4eab"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/nopt_ef_run1_eval_e572e06c-8fb7-4060-854a-dec53e6b4eab.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=nopt_ef_run1_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/mmhome/boittier/home/ckpts/nopt_ef_run1/slurm-eval-e572e06c-8fb7-4060-854a-dec53e6b4eab.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


