#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="/mmhome/boittier/home/mmml_tutorial/EF/hper/ckpts/eval_sbatch3"
mkdir -p "$SCRIPT_DIR"

run_dir="/home/boittier/studixh/ckpts/ef_run1"
run_name="ef_run1"
params="/home/boittier/studixh/ckpts/ef_run1/params-239546fe-d941-4712-a628-436be7acad2f.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef_sim/energies_forces_dipoles_test.npz"
param_id="239546fe-d941-4712-a628-436be7acad2f"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/ef_run1_eval_239546fe-d941-4712-a628-436be7acad2f.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=ef_run1_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/home/boittier/studixh/ckpts/ef_run1/slurm-eval-239546fe-d941-4712-a628-436be7acad2f.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/ef_run1"
run_name="ef_run1"
params="/home/boittier/studixh/ckpts/ef_run1/params-8ed9c12a-afdb-412c-ae8d-0f733deb71f2.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef_sim/energies_forces_dipoles_test.npz"
param_id="8ed9c12a-afdb-412c-ae8d-0f733deb71f2"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/ef_run1_eval_8ed9c12a-afdb-412c-ae8d-0f733deb71f2.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=ef_run1_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/home/boittier/studixh/ckpts/ef_run1/slurm-eval-8ed9c12a-afdb-412c-ae8d-0f733deb71f2.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/ef_run1"
run_name="ef_run1"
params="/home/boittier/studixh/ckpts/ef_run1/params-69d111c1-af09-4d98-83d6-cf87ef721537.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef00_t3/energies_forces_dipoles_test.npz"
param_id="69d111c1-af09-4d98-83d6-cf87ef721537"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/ef_run1_eval_69d111c1-af09-4d98-83d6-cf87ef721537.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=ef_run1_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/home/boittier/studixh/ckpts/ef_run1/slurm-eval-69d111c1-af09-4d98-83d6-cf87ef721537.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/ef_run1"
run_name="ef_run1"
params="/home/boittier/studixh/ckpts/ef_run1/params-dc3d6888-c75d-43fa-8e3d-2c2692df3d51.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef00_t3/energies_forces_dipoles_test.npz"
param_id="dc3d6888-c75d-43fa-8e3d-2c2692df3d51"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/ef_run1_eval_dc3d6888-c75d-43fa-8e3d-2c2692df3d51.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=ef_run1_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/home/boittier/studixh/ckpts/ef_run1/slurm-eval-dc3d6888-c75d-43fa-8e3d-2c2692df3d51.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/ef_run1"
run_name="ef_run1"
params="/home/boittier/studixh/ckpts/ef_run1/params-dc3d6888-c75d-43fa-8e3d-2c2692df3d51.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef00_t3/energies_forces_dipoles_test.npz"
param_id="dc3d6888-c75d-43fa-8e3d-2c2692df3d51"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/ef_run1_eval_dc3d6888-c75d-43fa-8e3d-2c2692df3d51.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=ef_run1_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/home/boittier/studixh/ckpts/ef_run1/slurm-eval-dc3d6888-c75d-43fa-8e3d-2c2692df3d51.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/ef_run3"
run_name="ef_run3"
params="/home/boittier/studixh/ckpts/ef_run3/params-4f9d6765-50db-4209-88d5-f795d1f9b8f8.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef_sim/energies_forces_dipoles_test.npz"
param_id="4f9d6765-50db-4209-88d5-f795d1f9b8f8"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/ef_run3_eval_4f9d6765-50db-4209-88d5-f795d1f9b8f8.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=ef_run3_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/home/boittier/studixh/ckpts/ef_run3/slurm-eval-4f9d6765-50db-4209-88d5-f795d1f9b8f8.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/ef_run3"
run_name="ef_run3"
params="/home/boittier/studixh/ckpts/ef_run3/params-a93e60fb-b231-4820-b48a-e34a8ecdb1d5.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef00_t3/energies_forces_dipoles_test.npz"
param_id="a93e60fb-b231-4820-b48a-e34a8ecdb1d5"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/ef_run3_eval_a93e60fb-b231-4820-b48a-e34a8ecdb1d5.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=ef_run3_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/home/boittier/studixh/ckpts/ef_run3/slurm-eval-a93e60fb-b231-4820-b48a-e34a8ecdb1d5.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/ef_run3"
run_name="ef_run3"
params="/home/boittier/studixh/ckpts/ef_run3/params-a93e60fb-b231-4820-b48a-e34a8ecdb1d5.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef00_t3/energies_forces_dipoles_test.npz"
param_id="a93e60fb-b231-4820-b48a-e34a8ecdb1d5"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/ef_run3_eval_a93e60fb-b231-4820-b48a-e34a8ecdb1d5.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=ef_run3_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/home/boittier/studixh/ckpts/ef_run3/slurm-eval-a93e60fb-b231-4820-b48a-e34a8ecdb1d5.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/ef_run4"
run_name="ef_run4"
params="/home/boittier/studixh/ckpts/ef_run4/params-cca47a3f-937e-410b-ac8c-0c3978e03adb.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef00_t3/energies_forces_dipoles_test.npz"
param_id="cca47a3f-937e-410b-ac8c-0c3978e03adb"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/ef_run4_eval_cca47a3f-937e-410b-ac8c-0c3978e03adb.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=ef_run4_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/home/boittier/studixh/ckpts/ef_run4/slurm-eval-cca47a3f-937e-410b-ac8c-0c3978e03adb.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/ef_run4"
run_name="ef_run4"
params="/home/boittier/studixh/ckpts/ef_run4/params-ca1ec0f3-3971-4893-96e5-5aea4a0ce649.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef00_t3/energies_forces_dipoles_test.npz"
param_id="ca1ec0f3-3971-4893-96e5-5aea4a0ce649"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/ef_run4_eval_ca1ec0f3-3971-4893-96e5-5aea4a0ce649.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=ef_run4_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/home/boittier/studixh/ckpts/ef_run4/slurm-eval-ca1ec0f3-3971-4893-96e5-5aea4a0ce649.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/ef_run4"
run_name="ef_run4"
params="/home/boittier/studixh/ckpts/ef_run4/params-30f50bc2-43db-4a6b-b692-098fbc00bd06.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef_sim/energies_forces_dipoles_test.npz"
param_id="30f50bc2-43db-4a6b-b692-098fbc00bd06"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/ef_run4_eval_30f50bc2-43db-4a6b-b692-098fbc00bd06.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=ef_run4_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/home/boittier/studixh/ckpts/ef_run4/slurm-eval-30f50bc2-43db-4a6b-b692-098fbc00bd06.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/ef_run4"
run_name="ef_run4"
params="/home/boittier/studixh/ckpts/ef_run4/params-9e73374f-343e-48f5-9541-477735db84d8.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef00_t3/energies_forces_dipoles_test.npz"
param_id="9e73374f-343e-48f5-9541-477735db84d8"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/ef_run4_eval_9e73374f-343e-48f5-9541-477735db84d8.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=ef_run4_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/home/boittier/studixh/ckpts/ef_run4/slurm-eval-9e73374f-343e-48f5-9541-477735db84d8.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/ef_run4"
run_name="ef_run4"
params="/home/boittier/studixh/ckpts/ef_run4/params-55146e3c-d70a-49bc-abf4-645e13bbf002.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef_sim/energies_forces_dipoles_test.npz"
param_id="55146e3c-d70a-49bc-abf4-645e13bbf002"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/ef_run4_eval_55146e3c-d70a-49bc-abf4-645e13bbf002.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=ef_run4_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/home/boittier/studixh/ckpts/ef_run4/slurm-eval-55146e3c-d70a-49bc-abf4-645e13bbf002.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/ef_run4"
run_name="ef_run4"
params="/home/boittier/studixh/ckpts/ef_run4/params-7371f727-0750-4bc5-ad0e-597684426c2c.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef_sim/energies_forces_dipoles_test.npz"
param_id="7371f727-0750-4bc5-ad0e-597684426c2c"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/ef_run4_eval_7371f727-0750-4bc5-ad0e-597684426c2c.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=ef_run4_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/home/boittier/studixh/ckpts/ef_run4/slurm-eval-7371f727-0750-4bc5-ad0e-597684426c2c.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/ef_run4"
run_name="ef_run4"
params="/home/boittier/studixh/ckpts/ef_run4/params-cdcc429c-7a18-4264-b596-935dbf9a09af.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef_sim/energies_forces_dipoles_test.npz"
param_id="cdcc429c-7a18-4264-b596-935dbf9a09af"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/ef_run4_eval_cdcc429c-7a18-4264-b596-935dbf9a09af.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=ef_run4_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/home/boittier/studixh/ckpts/ef_run4/slurm-eval-cdcc429c-7a18-4264-b596-935dbf9a09af.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/ef_run4"
run_name="ef_run4"
params="/home/boittier/studixh/ckpts/ef_run4/params-cca47a3f-937e-410b-ac8c-0c3978e03adb.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef00_t3/energies_forces_dipoles_test.npz"
param_id="cca47a3f-937e-410b-ac8c-0c3978e03adb"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/ef_run4_eval_cca47a3f-937e-410b-ac8c-0c3978e03adb.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=ef_run4_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/home/boittier/studixh/ckpts/ef_run4/slurm-eval-cca47a3f-937e-410b-ac8c-0c3978e03adb.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/ef_run2"
run_name="ef_run2"
params="/home/boittier/studixh/ckpts/ef_run2/params-482ee847-a1bf-46b7-b859-fd7a9c22958a.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef_sim/energies_forces_dipoles_test.npz"
param_id="482ee847-a1bf-46b7-b859-fd7a9c22958a"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/ef_run2_eval_482ee847-a1bf-46b7-b859-fd7a9c22958a.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=ef_run2_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/home/boittier/studixh/ckpts/ef_run2/slurm-eval-482ee847-a1bf-46b7-b859-fd7a9c22958a.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/ef_run2"
run_name="ef_run2"
params="/home/boittier/studixh/ckpts/ef_run2/params-e59a1562-5c93-4a38-8f78-bb8b3fd2323d.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef00_t3/energies_forces_dipoles_test.npz"
param_id="e59a1562-5c93-4a38-8f78-bb8b3fd2323d"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/ef_run2_eval_e59a1562-5c93-4a38-8f78-bb8b3fd2323d.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=ef_run2_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/home/boittier/studixh/ckpts/ef_run2/slurm-eval-e59a1562-5c93-4a38-8f78-bb8b3fd2323d.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/ef_run2"
run_name="ef_run2"
params="/home/boittier/studixh/ckpts/ef_run2/params-fe28860b-70c6-4a2b-9498-759f9dc2f586.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef_sim/energies_forces_dipoles_test.npz"
param_id="fe28860b-70c6-4a2b-9498-759f9dc2f586"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/ef_run2_eval_fe28860b-70c6-4a2b-9498-759f9dc2f586.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=ef_run2_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/home/boittier/studixh/ckpts/ef_run2/slurm-eval-fe28860b-70c6-4a2b-9498-759f9dc2f586.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/ef_run2"
run_name="ef_run2"
params="/home/boittier/studixh/ckpts/ef_run2/params-ee539723-be94-4473-b451-97e899942b3e.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef_sim/energies_forces_dipoles_test.npz"
param_id="ee539723-be94-4473-b451-97e899942b3e"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/ef_run2_eval_ee539723-be94-4473-b451-97e899942b3e.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=ef_run2_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/home/boittier/studixh/ckpts/ef_run2/slurm-eval-ee539723-be94-4473-b451-97e899942b3e.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/ef_run2"
run_name="ef_run2"
params="/home/boittier/studixh/ckpts/ef_run2/params-16299a69-dd59-4f45-8aa0-88bbf9699264.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef00_t3/energies_forces_dipoles_test.npz"
param_id="16299a69-dd59-4f45-8aa0-88bbf9699264"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/ef_run2_eval_16299a69-dd59-4f45-8aa0-88bbf9699264.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=ef_run2_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/home/boittier/studixh/ckpts/ef_run2/slurm-eval-16299a69-dd59-4f45-8aa0-88bbf9699264.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/ef_run2"
run_name="ef_run2"
params="/home/boittier/studixh/ckpts/ef_run2/params-fe71aa90-a924-4ba1-91f0-8dfe603beb68.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef_sim/energies_forces_dipoles_test.npz"
param_id="fe71aa90-a924-4ba1-91f0-8dfe603beb68"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/ef_run2_eval_fe71aa90-a924-4ba1-91f0-8dfe603beb68.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=ef_run2_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/home/boittier/studixh/ckpts/ef_run2/slurm-eval-fe71aa90-a924-4ba1-91f0-8dfe603beb68.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/ef_run2"
run_name="ef_run2"
params="/home/boittier/studixh/ckpts/ef_run2/params-e59a1562-5c93-4a38-8f78-bb8b3fd2323d.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef00_t3/energies_forces_dipoles_test.npz"
param_id="e59a1562-5c93-4a38-8f78-bb8b3fd2323d"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/ef_run2_eval_e59a1562-5c93-4a38-8f78-bb8b3fd2323d.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=ef_run2_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/home/boittier/studixh/ckpts/ef_run2/slurm-eval-e59a1562-5c93-4a38-8f78-bb8b3fd2323d.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/ef0_run2"
run_name="ef0_run2"
params="/home/boittier/studixh/ckpts/ef0_run2/params-82503ea3-6405-4d20-aea3-dd3e2e7cd2bd.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef0_sim/energies_forces_dipoles_test.npz"
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
#SBATCH --output=/home/boittier/studixh/ckpts/ef0_run2/slurm-eval-82503ea3-6405-4d20-aea3-dd3e2e7cd2bd.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/ef0_run2"
run_name="ef0_run2"
params="/home/boittier/studixh/ckpts/ef0_run2/params-1879dbfd-c447-47d3-85e0-5956e9e4178d.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef0_sim/energies_forces_dipoles_test.npz"
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
#SBATCH --output=/home/boittier/studixh/ckpts/ef0_run2/slurm-eval-1879dbfd-c447-47d3-85e0-5956e9e4178d.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/ef0_run2"
run_name="ef0_run2"
params="/home/boittier/studixh/ckpts/ef0_run2/params-a5575a72-e476-4e6c-b609-eb85917a56e6.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef0_sim/energies_forces_dipoles_test.npz"
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
#SBATCH --output=/home/boittier/studixh/ckpts/ef0_run2/slurm-eval-a5575a72-e476-4e6c-b609-eb85917a56e6.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/ef0_run2"
run_name="ef0_run2"
params="/home/boittier/studixh/ckpts/ef0_run2/params-a5575a72-e476-4e6c-b609-eb85917a56e6.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef0_sim/energies_forces_dipoles_test.npz"
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
#SBATCH --output=/home/boittier/studixh/ckpts/ef0_run2/slurm-eval-a5575a72-e476-4e6c-b609-eb85917a56e6.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/mef_run2"
run_name="mef_run2"
params="/home/boittier/studixh/ckpts/mef_run2/params-4a605008-ac03-4551-b3ae-e7f7f601df87.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef/energies_forces_dipoles_test.npz"
param_id="4a605008-ac03-4551-b3ae-e7f7f601df87"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/mef_run2_eval_4a605008-ac03-4551-b3ae-e7f7f601df87.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=mef_run2_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/home/boittier/studixh/ckpts/mef_run2/slurm-eval-4a605008-ac03-4551-b3ae-e7f7f601df87.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/mef_run2"
run_name="mef_run2"
params="/home/boittier/studixh/ckpts/mef_run2/params-4a605008-ac03-4551-b3ae-e7f7f601df87.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef/energies_forces_dipoles_test.npz"
param_id="4a605008-ac03-4551-b3ae-e7f7f601df87"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/mef_run2_eval_4a605008-ac03-4551-b3ae-e7f7f601df87.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=mef_run2_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/home/boittier/studixh/ckpts/mef_run2/slurm-eval-4a605008-ac03-4551-b3ae-e7f7f601df87.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/mef_run0"
run_name="mef_run0"
params="/home/boittier/studixh/ckpts/mef_run0/params-bd658992-7e85-4f50-b2c2-f657ba2b002b.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef/energies_forces_dipoles_test.npz"
param_id="bd658992-7e85-4f50-b2c2-f657ba2b002b"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/mef_run0_eval_bd658992-7e85-4f50-b2c2-f657ba2b002b.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=mef_run0_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/home/boittier/studixh/ckpts/mef_run0/slurm-eval-bd658992-7e85-4f50-b2c2-f657ba2b002b.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/mef_run0"
run_name="mef_run0"
params="/home/boittier/studixh/ckpts/mef_run0/params-cc701dad-cb00-467b-9405-5d2eb0358648.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef/energies_forces_dipoles_test.npz"
param_id="cc701dad-cb00-467b-9405-5d2eb0358648"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/mef_run0_eval_cc701dad-cb00-467b-9405-5d2eb0358648.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=mef_run0_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/home/boittier/studixh/ckpts/mef_run0/slurm-eval-cc701dad-cb00-467b-9405-5d2eb0358648.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/mef_run0"
run_name="mef_run0"
params="/home/boittier/studixh/ckpts/mef_run0/params-cc701dad-cb00-467b-9405-5d2eb0358648.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef/energies_forces_dipoles_test.npz"
param_id="cc701dad-cb00-467b-9405-5d2eb0358648"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/mef_run0_eval_cc701dad-cb00-467b-9405-5d2eb0358648.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=mef_run0_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/home/boittier/studixh/ckpts/mef_run0/slurm-eval-cc701dad-cb00-467b-9405-5d2eb0358648.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/mef_run1"
run_name="mef_run1"
params="/home/boittier/studixh/ckpts/mef_run1/params-df360f7f-0038-48de-b299-2cbfdb17d233.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef/energies_forces_dipoles_test.npz"
param_id="df360f7f-0038-48de-b299-2cbfdb17d233"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/mef_run1_eval_df360f7f-0038-48de-b299-2cbfdb17d233.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=mef_run1_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/home/boittier/studixh/ckpts/mef_run1/slurm-eval-df360f7f-0038-48de-b299-2cbfdb17d233.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/mef_run1"
run_name="mef_run1"
params="/home/boittier/studixh/ckpts/mef_run1/params-df360f7f-0038-48de-b299-2cbfdb17d233.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef/energies_forces_dipoles_test.npz"
param_id="df360f7f-0038-48de-b299-2cbfdb17d233"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/mef_run1_eval_df360f7f-0038-48de-b299-2cbfdb17d233.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=mef_run1_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/home/boittier/studixh/ckpts/mef_run1/slurm-eval-df360f7f-0038-48de-b299-2cbfdb17d233.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/nmef_run1"
run_name="nmef_run1"
params="/home/boittier/studixh/ckpts/nmef_run1/params-276f4163-de87-476c-87a1-8c1a4db09785.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef/energies_forces_dipoles_test.npz"
param_id="276f4163-de87-476c-87a1-8c1a4db09785"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/nmef_run1_eval_276f4163-de87-476c-87a1-8c1a4db09785.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=nmef_run1_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/home/boittier/studixh/ckpts/nmef_run1/slurm-eval-276f4163-de87-476c-87a1-8c1a4db09785.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/nmef_run1"
run_name="nmef_run1"
params="/home/boittier/studixh/ckpts/nmef_run1/params-276f4163-de87-476c-87a1-8c1a4db09785.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef/energies_forces_dipoles_test.npz"
param_id="276f4163-de87-476c-87a1-8c1a4db09785"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/nmef_run1_eval_276f4163-de87-476c-87a1-8c1a4db09785.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=nmef_run1_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/home/boittier/studixh/ckpts/nmef_run1/slurm-eval-276f4163-de87-476c-87a1-8c1a4db09785.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/ef_run5"
run_name="ef_run5"
params="/home/boittier/studixh/ckpts/ef_run5/params-2a43e598-d310-43a0-85d0-353388cda93d.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef00_t3/energies_forces_dipoles_test.npz"
param_id="2a43e598-d310-43a0-85d0-353388cda93d"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/ef_run5_eval_2a43e598-d310-43a0-85d0-353388cda93d.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=ef_run5_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/home/boittier/studixh/ckpts/ef_run5/slurm-eval-2a43e598-d310-43a0-85d0-353388cda93d.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/ef_run5"
run_name="ef_run5"
params="/home/boittier/studixh/ckpts/ef_run5/params-2a43e598-d310-43a0-85d0-353388cda93d.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef00_t3/energies_forces_dipoles_test.npz"
param_id="2a43e598-d310-43a0-85d0-353388cda93d"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/ef_run5_eval_2a43e598-d310-43a0-85d0-353388cda93d.sbatch"

cat > "$sbatch_file" <<EOF
#!/bin/bash
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --job-name=ef_run5_eval
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --mem-per-cpu=3000
#SBATCH --partition=gpu
#SBATCH --exclude=gpu24
#SBATCH --gres=gpu:1
#SBATCH --output=/home/boittier/studixh/ckpts/ef_run5/slurm-eval-2a43e598-d310-43a0-85d0-353388cda93d.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/nopt_ef_run5"
run_name="nopt_ef_run5"
params="/home/boittier/studixh/ckpts/nopt_ef_run5/params-b94f99c7-14c1-4904-b6ae-050778b89e36.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef00_t3/energies_forces_dipoles_test.npz"
param_id="b94f99c7-14c1-4904-b6ae-050778b89e36"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/nopt_ef_run5_eval_b94f99c7-14c1-4904-b6ae-050778b89e36.sbatch"

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
#SBATCH --output=/home/boittier/studixh/ckpts/nopt_ef_run5/slurm-eval-b94f99c7-14c1-4904-b6ae-050778b89e36.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/nopt_ef_run5"
run_name="nopt_ef_run5"
params="/home/boittier/studixh/ckpts/nopt_ef_run5/params-d5fd3605-9e75-49aa-aa68-c0b84e9d97c1.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef0_t3/energies_forces_dipoles_test.npz"
param_id="d5fd3605-9e75-49aa-aa68-c0b84e9d97c1"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/nopt_ef_run5_eval_d5fd3605-9e75-49aa-aa68-c0b84e9d97c1.sbatch"

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
#SBATCH --output=/home/boittier/studixh/ckpts/nopt_ef_run5/slurm-eval-d5fd3605-9e75-49aa-aa68-c0b84e9d97c1.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/nopt_ef_run5"
run_name="nopt_ef_run5"
params="/home/boittier/studixh/ckpts/nopt_ef_run5/params-76e9be6c-db57-4353-8fd1-c12ac9575d9c.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef0_t3/energies_forces_dipoles_test.npz"
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
#SBATCH --output=/home/boittier/studixh/ckpts/nopt_ef_run5/slurm-eval-76e9be6c-db57-4353-8fd1-c12ac9575d9c.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/nopt_ef_run5"
run_name="nopt_ef_run5"
params="/home/boittier/studixh/ckpts/nopt_ef_run5/params-76e9be6c-db57-4353-8fd1-c12ac9575d9c.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef0_t3/energies_forces_dipoles_test.npz"
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
#SBATCH --output=/home/boittier/studixh/ckpts/nopt_ef_run5/slurm-eval-76e9be6c-db57-4353-8fd1-c12ac9575d9c.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/nopt_ef_run0"
run_name="nopt_ef_run0"
params="/home/boittier/studixh/ckpts/nopt_ef_run0/params-c94d6c74-39f1-441d-9abd-152f63942af3.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef00_t3/energies_forces_dipoles_test.npz"
param_id="c94d6c74-39f1-441d-9abd-152f63942af3"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/nopt_ef_run0_eval_c94d6c74-39f1-441d-9abd-152f63942af3.sbatch"

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
#SBATCH --output=/home/boittier/studixh/ckpts/nopt_ef_run0/slurm-eval-c94d6c74-39f1-441d-9abd-152f63942af3.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/nopt_ef_run0"
run_name="nopt_ef_run0"
params="/home/boittier/studixh/ckpts/nopt_ef_run0/params-2a13de15-639d-4352-8860-3ea480126348.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef0_t3/energies_forces_dipoles_test.npz"
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
#SBATCH --output=/home/boittier/studixh/ckpts/nopt_ef_run0/slurm-eval-2a13de15-639d-4352-8860-3ea480126348.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/nopt_ef_run0"
run_name="nopt_ef_run0"
params="/home/boittier/studixh/ckpts/nopt_ef_run0/params-2a13de15-639d-4352-8860-3ea480126348.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef0_t3/energies_forces_dipoles_test.npz"
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
#SBATCH --output=/home/boittier/studixh/ckpts/nopt_ef_run0/slurm-eval-2a13de15-639d-4352-8860-3ea480126348.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/nopt_ef_run4"
run_name="nopt_ef_run4"
params="/home/boittier/studixh/ckpts/nopt_ef_run4/params-91619cb7-6aa6-4af4-b875-d0c5d661bd71.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef0_t3/energies_forces_dipoles_test.npz"
param_id="91619cb7-6aa6-4af4-b875-d0c5d661bd71"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/nopt_ef_run4_eval_91619cb7-6aa6-4af4-b875-d0c5d661bd71.sbatch"

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
#SBATCH --output=/home/boittier/studixh/ckpts/nopt_ef_run4/slurm-eval-91619cb7-6aa6-4af4-b875-d0c5d661bd71.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/nopt_ef_run4"
run_name="nopt_ef_run4"
params="/home/boittier/studixh/ckpts/nopt_ef_run4/params-0cab1cd9-14fa-4886-bb4a-e0aba0069032.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef0_t3/energies_forces_dipoles_test.npz"
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
#SBATCH --output=/home/boittier/studixh/ckpts/nopt_ef_run4/slurm-eval-0cab1cd9-14fa-4886-bb4a-e0aba0069032.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/nopt_ef_run4"
run_name="nopt_ef_run4"
params="/home/boittier/studixh/ckpts/nopt_ef_run4/params-68783a67-7fcf-47f8-bb85-fd1b19263e63.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef00_t3/energies_forces_dipoles_test.npz"
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
#SBATCH --output=/home/boittier/studixh/ckpts/nopt_ef_run4/slurm-eval-68783a67-7fcf-47f8-bb85-fd1b19263e63.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/nopt_ef_run4"
run_name="nopt_ef_run4"
params="/home/boittier/studixh/ckpts/nopt_ef_run4/params-68783a67-7fcf-47f8-bb85-fd1b19263e63.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef00_t3/energies_forces_dipoles_test.npz"
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
#SBATCH --output=/home/boittier/studixh/ckpts/nopt_ef_run4/slurm-eval-68783a67-7fcf-47f8-bb85-fd1b19263e63.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/nopt_ef_run3"
run_name="nopt_ef_run3"
params="/home/boittier/studixh/ckpts/nopt_ef_run3/params-97938270-df87-42eb-bb1c-7aa28d8ea247.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef0_t3/energies_forces_dipoles_test.npz"
param_id="97938270-df87-42eb-bb1c-7aa28d8ea247"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/nopt_ef_run3_eval_97938270-df87-42eb-bb1c-7aa28d8ea247.sbatch"

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
#SBATCH --output=/home/boittier/studixh/ckpts/nopt_ef_run3/slurm-eval-97938270-df87-42eb-bb1c-7aa28d8ea247.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/nopt_ef_run3"
run_name="nopt_ef_run3"
params="/home/boittier/studixh/ckpts/nopt_ef_run3/params-601a1010-e2b0-487b-8f75-54326a4904b3.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef0_t3/energies_forces_dipoles_test.npz"
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
#SBATCH --output=/home/boittier/studixh/ckpts/nopt_ef_run3/slurm-eval-601a1010-e2b0-487b-8f75-54326a4904b3.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/nopt_ef_run3"
run_name="nopt_ef_run3"
params="/home/boittier/studixh/ckpts/nopt_ef_run3/params-939923a2-d826-40af-adbf-8a82ca810ff9.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef00_t3/energies_forces_dipoles_test.npz"
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
#SBATCH --output=/home/boittier/studixh/ckpts/nopt_ef_run3/slurm-eval-939923a2-d826-40af-adbf-8a82ca810ff9.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/nopt_ef_run3"
run_name="nopt_ef_run3"
params="/home/boittier/studixh/ckpts/nopt_ef_run3/params-939923a2-d826-40af-adbf-8a82ca810ff9.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef00_t3/energies_forces_dipoles_test.npz"
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
#SBATCH --output=/home/boittier/studixh/ckpts/nopt_ef_run3/slurm-eval-939923a2-d826-40af-adbf-8a82ca810ff9.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/nopt_ef_run2"
run_name="nopt_ef_run2"
params="/home/boittier/studixh/ckpts/nopt_ef_run2/params-c3882ad7-3349-47fb-8335-4e6ffe74da8b.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef0_t3/energies_forces_dipoles_test.npz"
param_id="c3882ad7-3349-47fb-8335-4e6ffe74da8b"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/nopt_ef_run2_eval_c3882ad7-3349-47fb-8335-4e6ffe74da8b.sbatch"

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
#SBATCH --output=/home/boittier/studixh/ckpts/nopt_ef_run2/slurm-eval-c3882ad7-3349-47fb-8335-4e6ffe74da8b.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/nopt_ef_run2"
run_name="nopt_ef_run2"
params="/home/boittier/studixh/ckpts/nopt_ef_run2/params-489f9021-269e-48ab-b7e2-d563afc1a368.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef0_t3/energies_forces_dipoles_test.npz"
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
#SBATCH --output=/home/boittier/studixh/ckpts/nopt_ef_run2/slurm-eval-489f9021-269e-48ab-b7e2-d563afc1a368.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/nopt_ef_run2"
run_name="nopt_ef_run2"
params="/home/boittier/studixh/ckpts/nopt_ef_run2/params-cd433256-7617-4958-ba13-ef119356c8d6.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef00_t3/energies_forces_dipoles_test.npz"
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
#SBATCH --output=/home/boittier/studixh/ckpts/nopt_ef_run2/slurm-eval-cd433256-7617-4958-ba13-ef119356c8d6.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/nopt_ef_run2"
run_name="nopt_ef_run2"
params="/home/boittier/studixh/ckpts/nopt_ef_run2/params-cd433256-7617-4958-ba13-ef119356c8d6.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef00_t3/energies_forces_dipoles_test.npz"
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
#SBATCH --output=/home/boittier/studixh/ckpts/nopt_ef_run2/slurm-eval-cd433256-7617-4958-ba13-ef119356c8d6.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/nopt_ef_run1"
run_name="nopt_ef_run1"
params="/home/boittier/studixh/ckpts/nopt_ef_run1/params-eaf9407e-d61a-44e6-8af4-a4314324c0c7.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef0_t3/energies_forces_dipoles_test.npz"
param_id="eaf9407e-d61a-44e6-8af4-a4314324c0c7"
eval_dir="${run_dir}/eval_${param_id}"
output_h5="${eval_dir}/out.h5"
sbatch_file="${SCRIPT_DIR}/nopt_ef_run1_eval_eaf9407e-d61a-44e6-8af4-a4314324c0c7.sbatch"

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
#SBATCH --output=/home/boittier/studixh/ckpts/nopt_ef_run1/slurm-eval-eaf9407e-d61a-44e6-8af4-a4314324c0c7.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/nopt_ef_run1"
run_name="nopt_ef_run1"
params="/home/boittier/studixh/ckpts/nopt_ef_run1/params-e572e06c-8fb7-4060-854a-dec53e6b4eab.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef0_t3/energies_forces_dipoles_test.npz"
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
#SBATCH --output=/home/boittier/studixh/ckpts/nopt_ef_run1/slurm-eval-e572e06c-8fb7-4060-854a-dec53e6b4eab.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


run_dir="/home/boittier/studixh/ckpts/nopt_ef_run1"
run_name="nopt_ef_run1"
params="/home/boittier/studixh/ckpts/nopt_ef_run1/params-e572e06c-8fb7-4060-854a-dec53e6b4eab.json"
data="/mmhome/boittier/home/mmml_tutorial/EF/hper/out/splits_ef0_t3/energies_forces_dipoles_test.npz"
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
#SBATCH --output=/home/boittier/studixh/ckpts/nopt_ef_run1/slurm-eval-e572e06c-8fb7-4060-854a-dec53e6b4eab.out

echo \$HOSTNAME
source ~/mmml/.venv/bin/activate

rm -rf "${eval_dir}"
mkdir -p "${eval_dir}"

mmml ef-evaluate \
  --params "${params}" \
  --data "${data}" \
  --output-dir "${eval_dir}" \
  --output-h5 "${output_h5}"
EOF

chmod +x "$sbatch_file"
echo "Created: $sbatch_file"


