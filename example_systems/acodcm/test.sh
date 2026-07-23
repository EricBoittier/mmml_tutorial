#!/usr/bin/env bash

set -euo pipefail

export CUDA_VISIBLE_DEVICES=1

temps=(250 260)

sizes=$(seq 92 3 100 )

repeats=$(seq 1 4)

checkpoint="/mmhome/boittier/home/mmml_tutorial/acodcm/ckpts/aco1-ef1bd9eb-c9d1-438c-97ec-a6b692aeeba3"

for temp in "${temps[@]}"; do

  for nres in $sizes; do

    for rep in $repeats; do

      seed=$((100000 * rep + 1000 * nres + temp))

      outdir="./acetone/N${nres}/T${temp}/R${rep}"

      mmml md-system \
        --setup free_nvt \
        --backend jaxmd --packmol-radius 15 \
        --spacing 1.0 \
        --temperature "$temp" \
        --checkpoint "$checkpoint" \
        --composition "ACO:${nres}" \
        --flat-bottom-radius 0.0001 \
        --ps 50 \
        --seed "$seed" \
        --dt-fs 0.1 \
        --traj-chunk-frames 1000 \
        --flat-bottom-k 10000.0 \
        --output-dir "$outdir"

    done

  done

done
