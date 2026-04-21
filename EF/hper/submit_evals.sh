for f in /mmhome/boittier/home/ckpts/eval_sbatch2/*.sbatch; do
    sbatch "$f"
done
