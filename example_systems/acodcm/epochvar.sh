#!/bin/bash
cd /mmhome/boittier/home/mmml_tutorial/acodcm
SRC=ckpts/gfn2_nms/gfn2nms-853a615c-e4a6-48f0-8928-c6e930090bbc
B=/mmhome/boittier/home/mmml/.venv/bin/python
S=/mmhome/boittier/home/mmml/scripts/scan_dimer_orientations.py
export CUDA_VISIBLE_DEVICES=1 XLA_PYTHON_CLIENT_MEM_FRACTION=.25
for EP in 996 997 998 999 1000; do
  [ -d "$SRC/epoch-$EP" ] || continue
  F=/tmp/ev; rm -rf $F; mkdir -p $F/epoch-$EP; cp -r $SRC/epoch-$EP/* $F/epoch-$EP/
  for R in ACO DCM; do
    $B $S --checkpoint $F --data out_combined_dedup/energies_forces_dipoles_test.npz \
      --resid $R --n-directions 10 --n-orientations 24 --n-r 36 --mm-switch-on 6.0 \
      --out /tmp/ev_${EP}_$R > /dev/null 2>&1
  done
  $B -c "
import json
a=json.load(open('/tmp/ev_${EP}_ACO/summary.json')); d=json.load(open('/tmp/ev_${EP}_DCM/summary.json'))
print(f\"  {${EP}:5d} | ACO {a['frac_rays_spurious']*100:5.1f}%  {a['deepest_kcal']:7.2f} | DCM {d['frac_rays_spurious']*100:5.1f}%  {d['deepest_kcal']:7.2f}\")
" 2>/dev/null
  rm -rf $F
done
