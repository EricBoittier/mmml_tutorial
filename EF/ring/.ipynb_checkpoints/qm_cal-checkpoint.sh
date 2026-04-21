


echo "Command: uv run mmml pyscf-dft --mol xyz/initial.xyz --energy --gradient --hessian --harmonic --thermo --output out/04_results"

for x in qP_samples/*.xyz 
do
echo $x
mmml pyscf-dft --mol $x \
  --energy --gradient --gradient --hessian --harmonic --thermo  \
  --output $x.npz
echo "Output: out/04_results.npz and .h5"
done
