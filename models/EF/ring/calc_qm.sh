export CUDA_VISIBLE_DEVICES=0
for x in qP_samples/*.xyz.h5.npz
do
echo $x
mmml pyscf-evaluate -i $x -o $x"_ef0.npz" --EF --add-random-noise 0.05 --seed 42 --efield-sigma 0.0
mmml pyscf-evaluate -i $x -o $x"_ef1.npz" --EF --add-random-noise 0.05 --seed 42 --efield-sigma 0.01
echo "..."
done
