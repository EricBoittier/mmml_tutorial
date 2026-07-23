#!/usr/bin/env bash

set -euo pipefail

export CUDA_VISIBLE_DEVICES=0

temps=(250 260)

sizes=$(seq 30 40)

repeats=$(seq 1 4)

checkpoint="/mmhome/boittier/home/mmml_tutorial/acodcm/ckpts/aco1-ef1bd9eb-c9d1-438c-97ec-a6b692aeeba3"

for temp in "${temps[@]}"; do

  for nres in $sizes; do

    for rep in $repeats; do

      seed=$((100000 * rep + 1000 * nres + temp))

      outdir="./acetone/N${nres}/T${temp}/R${rep}"

      mmml md-system \
        --setup free_nvt \
        --backend jaxmd --no-charmm-pre-minimize \
        --spacing 1.0 \
        --temperature "$temp" \
        --checkpoint "$checkpoint" \
        --composition "ACO:${nres}" \
        --flat-bottom-radius 20.0 \
        --ps 500 \
        --seed "$seed" \
        --dt-fs 0.5 \
        --traj-chunk-frames 1000 \
        --flat-bottom-k 1.0 \
        --output-dir "$outdir"

    done

  done

done
