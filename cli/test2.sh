mmml md-system \
  --setup free_nvt \
  --backend jaxmd --temperature 300 \
  --composition 'ACO:100' \
  --flat-bottom-radius 25.0 \
  --ps 500 --seed 100 \
  --dt-fs 0.5 \
  --traj-chunk-frames 1000 \
  --flat-bottom-k 10.0 \
  --output-dir acetone 
