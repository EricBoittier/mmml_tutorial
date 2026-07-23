


echo "Command: uv run mmml pyscf-dft --mol xyz/initial.xyz --energy --gradient --hessian --harmonic --thermo --output out/04_results"
mmml pyscf-dft --mol "hyper_a.xyz" \
  --energy --gradient --hessian --harmonic --thermo \
  --output out/hyper_a.npz
echo "Output: out/04_results.npz and .h5"

