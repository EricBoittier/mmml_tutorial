#!/usr/bin/env bash

data="out/splits_ef_sim/energies_forces_dipoles_test.npz"
base_ckpt_dir="$HOME/ckpts"

for params in $base_ckpt_dir/ef_run*/best-valid-*.json; do
    # Extract a readable name for output (e.g., run + uuid)
    run_name=$(basename "$(dirname "$params")")
    uuid=$(basename "$params" .json | sed 's/best-valid-//')

    outdir="ef_eval_${run_name}_${uuid}"
    outh5="${outdir}/out.h5"

    echo "Running evaluation for $params"
    config=$base_ckpt_dir/$run_name/config-$uuid.json
    params=$base_ckpt_dir/$run_name/params-$uuid.json
    echo $config
    mmml ef-evaluate --params "$params" --config "$config" --data "$data" --output-dir "$outdir" --output-h5 "$outh5"

done
