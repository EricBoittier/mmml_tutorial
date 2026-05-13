#!/usr/bin/env bash
set -euo pipefail

# Run all trained ring EF models with and without a z-directed field.
# Assumes reproducible_ring_simulations.py is in the current directory.

PYTHON=${PYTHON:-python}
SCRIPT=${SCRIPT:-reproducible_ring_simulations.py}

XYZ=${XYZ:-qP_samples/q_0.100_P_288.0.xyz}
OUTPUT_ROOT=${OUTPUT_ROOT:-runs_model_sweep}

# MD / optimization settings.
# Override any of these from the shell if needed, e.g.
#   NSTEPS=100000 WRITE_EVERY=500 ./run_all_ring_models.sh
TEMPERATURE_K=${TEMPERATURE_K:-300.0}
DT_FS=${DT_FS:-0.5}
NSTEPS=${NSTEPS:-500000}
WRITE_EVERY=${WRITE_EVERY:-1000}
SEED=${SEED:-7}
FMAX=${FMAX:-0.003}
OPT_STEPS=${OPT_STEPS:-1000}
MAXSTEP=${MAXSTEP:-0.04}
FIELD_SCALE=${FIELD_SCALE:-100}

# Field values in model input units.
# The calculator uses: E_physical [au] = E_input * FIELD_SCALE.
FIELDS_Z=(0.0 0.001)
FIELD_LABELS=(ef0 efz_0p001)

CKPT_ROOT=/mmhome/boittier/home/ckpts

MODELS=(
  "ptF_run0:${CKPT_ROOT}/ring_ef2_ptF_run0"
  "ptT_run0:${CKPT_ROOT}/ring_ef2_ptT_run0"
  "ptF_run1:${CKPT_ROOT}/ring_ef2_ptF_run1"
  "ptT_run1:${CKPT_ROOT}/ring_ef2_ptT_run1"
  "ptF_run2:${CKPT_ROOT}/ring_ef2_ptF_run2"
  "ptT_run2:${CKPT_ROOT}/ring_ef2_ptT_run2"
)

mkdir -p "${OUTPUT_ROOT}"

for model_entry in "${MODELS[@]}"; do
    model_name="${model_entry%%:*}"
    ckpt_dir="${model_entry#*:}"

    config="${ckpt_dir}/config.json"
    params="${ckpt_dir}/params.json"

    if [[ ! -f "${config}" ]]; then
        echo "Missing config: ${config}" >&2
        exit 1
    fi

    if [[ ! -f "${params}" ]]; then
        echo "Missing params: ${params}" >&2
        exit 1
    fi

    for i in "${!FIELDS_Z[@]}"; do
        field_z="${FIELDS_Z[$i]}"
        field_label="${FIELD_LABELS[$i]}"
        run_name="${model_name}_${field_label}"

        echo "============================================================"
        echo "Running ${run_name}"
        echo "Checkpoint: ${ckpt_dir}"
        echo "Field z:    ${field_z}"
        echo "Output:     ${OUTPUT_ROOT}/${run_name}"
        echo "============================================================"

        "${PYTHON}" "${SCRIPT}" \
            --xyz "${XYZ}" \
            --config "${config}" \
            --params "${params}" \
            --field-z "${field_z}" \
            --field-scale "${FIELD_SCALE}" \
            --run-name "${run_name}" \
            --output-root "${OUTPUT_ROOT}" \
            --temperature-K "${TEMPERATURE_K}" \
            --dt-fs "${DT_FS}" \
            --nsteps "${NSTEPS}" \
            --write-every "${WRITE_EVERY}" \
            --seed "${SEED}" \
            --fmax "${FMAX}" \
            --opt-steps "${OPT_STEPS}" \
            --maxstep "${MAXSTEP}"
    done
done

echo "============================================================"
echo "All model-field runs completed."
echo "Output root: ${OUTPUT_ROOT}"
echo "============================================================"
