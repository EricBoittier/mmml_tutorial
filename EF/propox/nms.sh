for x in *.xyz.h5 
do
echo $x
mmml normal-mode-sample -i $x -o a05.$x.npz --amplitude 0.05 --max-samples 10000
echo "..."
done
