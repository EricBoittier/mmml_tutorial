#!/bin/bash
#SBATCH --job-name=lc-summary
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=8000
#SBATCH --partition=short
#SBATCH --time=01:00:00
#SBATCH --dependency=afterany:203226:203227:203228:203229:203230:203231:203232:203233:203234:203235:203236:203237:203238:203239:203240:203241:203242:203243:203244:203245:203246:203247:203248:203249:203250:203251:203252:203253:203254:203255
#SBATCH --output=/mmhome/boittier/home/mmml_tutorial/acodcm/slurm/learning_curve/summary_compare.out

set -euo pipefail
source "/mmhome/boittier/home/mmml/.venv/bin/activate"
cd "/mmhome/boittier/home/mmml_tutorial/acodcm"
python3 "/mmhome/boittier/home/mmml_tutorial/acodcm/scripts/plot_learning_curve_sweep.py" \
  --eval-root "/mmhome/boittier/home/mmml_tutorial/acodcm/out/eval/learning_curve" \
  --output "/mmhome/boittier/home/mmml_tutorial/acodcm/out/eval/learning_curve/comparison_all.png" \
  --summary-json "/mmhome/boittier/home/mmml_tutorial/acodcm/out/eval/learning_curve/aggregate_summary.json" \
  --plot-style google
