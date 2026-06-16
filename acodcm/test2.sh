#!/usr/bin/env bash

set -euo pipefail

export CUDA_VISIBLE_DEVICES=0

temps=(250 260)

sizes=$(seq 92 3 100)

repeats=$(seq 1 4)

checkpoint="/mmhome/boittier/home/mmml_tutorial/acodcm/ckpts/dcm1-c137fb42-1f65-4748-880b-8f8184a20f70"

for temp in "${temps[@]}"; do

  for nres in $sizes; do

    for rep in $repeats; do

      seed=$((200000 * rep + 1000 * nres + temp))

      outdir="./dichloromethane/N${nres}/T${temp}/R${rep}"

      mmml md-system \
        --setup free_nvt \
        --backend jaxmd \
        --spacing 1.0 \
        --temperature "$temp" \
        --checkpoint "$checkpoint" \
        --composition "DCM:${nres}" \
        --packmol-radius 15 --flat-bottom-radius 100.0 \
        --ps 100 \
        --seed "$seed" \
        --dt-fs 0.1 \
        --traj-chunk-frames 1000 \
        --flat-bottom-k 0.0 \
        --output-dir "$outdir"

    done

  done

done
