


echo "Command: uv run mmml pyscf-dft --mol xyz/initial.xyz --energy --gradient --hessian --harmonic --thermo --output out/04_results"
export CUDA_VISIBLE_DEVICES=0
for x in qP_samples/q_0.500*.xyz 
do
echo $x
mmml pyscf-dft --mol $x \
  --optimize --energy --gradient --gradient --hessian --harmonic  \
  --output $x.eval.npz
echo "Output: out/04_results.npz and .h5"
done
