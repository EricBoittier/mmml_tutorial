#!/bin/bash
#SBATCH --job-name=lc-summary
#SBATCH --mail-user=ericdavid.boittier@unibas.ch
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=8000
#SBATCH --partition=teach
#SBATCH --time=01:00:00
#SBATCH --dependency=afterany:203273:203274:203275:203276:203277:203278:203279:203280:203281:203282:203283:203284:203285:203286:203287:203288:203289:203290:203291:203292:203293:203294:203295:203296:203297:203298:203299:203300:203301:203302
#SBATCH --output=/mmhome/boittier/home/mmml_tutorial/acodcm/slurm/learning_curve/e1000/summary_compare.out

set -euo pipefail
source "/mmhome/boittier/home/mmml/.venv/bin/activate"
cd "/mmhome/boittier/home/mmml_tutorial/acodcm"
python3 "/mmhome/boittier/home/mmml_tutorial/acodcm/scripts/plot_learning_curve_sweep.py" \
  --eval-root "/mmhome/boittier/home/mmml_tutorial/acodcm/out/eval/learning_curve/e1000" \
  --output "/mmhome/boittier/home/mmml_tutorial/acodcm/out/eval/learning_curve/e1000/comparison_all.png" \
  --summary-json "/mmhome/boittier/home/mmml_tutorial/acodcm/out/eval/learning_curve/e1000/aggregate_summary.json" \
  --plot-style google
