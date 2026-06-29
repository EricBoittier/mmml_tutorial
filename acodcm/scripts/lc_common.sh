#!/usr/bin/env bash
# Shared helpers for learning-curve sweep scripts.
set -euo pipefail

# Pick the Orbax run subdirectory with the most epoch-* checkpoints.
pick_orbax_run_dir() {
  local ckpt_dir="$1"
  local best="" best_n=0 n d
  for d in "$ckpt_dir"/*/; do
    [[ -d "$d" ]] || continue
    n=$(find "$d" -maxdepth 1 -type d -name 'epoch-*' 2>/dev/null | wc -l)
    if (( n > best_n )); then
      best_n=$n
      best="${d%/}"
    fi
  done
  if (( best_n == 0 )); then
    echo "ERROR: no Orbax epoch checkpoints under $ckpt_dir" >&2
    return 1
  fi
  echo "$best"
}

pick_metrics_stride() {
  local n_ckpt_epochs="$1"
  if (( n_ckpt_epochs <= 200 )); then
    echo 1
  elif (( n_ckpt_epochs <= 1000 )); then
    echo 5
  else
    echo $(( (n_ckpt_epochs + 499) / 500 ))
  fi
}

latest_epoch_dir() {
  local run_dir="$1"
  local latest_num
  latest_num=$(find "$run_dir" -maxdepth 1 -type d -name 'epoch-*' | sed 's|.*/epoch-||' | sort -n | tail -1)
  echo "$run_dir/epoch-${latest_num}"
}

# Prefer portable params JSON written at end of training; else latest orbax epoch.
pick_eval_checkpoint() {
  local ckpt_dir="$1" out_dir="$2"
  local latest_json
  latest_json=$(find "$ckpt_dir" -maxdepth 1 -type f -name 'params_*.json' | sort | tail -1)
  if [[ -n "$latest_json" ]]; then
    echo "$latest_json"
    return 0
  fi
  if [[ -f "$out_dir/latest.json" ]]; then
    echo "$out_dir/latest.json"
    return 0
  fi
  return 1
}

# Emit --plot-style only when the installed mmml CLI supports it.
extract_metrics_plot_style_args() {
  local style="${1:-${PLOT_STYLE:-google}}"
  if mmml extract-checkpoint-metrics --help 2>&1 | grep -q -- '--plot-style'; then
    echo --plot-style "$style"
  fi
}
