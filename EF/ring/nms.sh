for x in qP_samples/*.xyz.h5 
do
echo $x
mmml normal-mode-sample -i $x -o $x.npz --amplitude 0.5 --max-samples 100
echo "..."
done
