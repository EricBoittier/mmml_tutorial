#!/usr/bin/env bash

set -euo pipefail

export CUDA_VISIBLE_DEVICES=1

temps=(250 260)

sizes=$(seq 3 3 25)

repeats=$(seq 1 4)

checkpoint="/mmhome/boittier/home/mmml_tutorial/acodcm/ckpts/dcm1-c137fb42-1f65-4748-880b-8f8184a20f70"

for temp in "${temps[@]}"; do

  for nres in $sizes; do

    for rep in $repeats; do

      seed=$((200000 * rep + 1000 * nres + temp))

      outdir="./dichloromethane/N${nres}/T${temp}/R${rep}"

      mmml md-system \
        --setup free_nvt \
        --backend jaxmd --no-charmm-pre-minimize \
        --spacing 1.0 \
        --temperature "$temp" \
        --checkpoint "$checkpoint" \
        --composition "DCM:${nres}" \
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
