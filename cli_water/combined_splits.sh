#!/usr/bin/env bash
set -euo pipefail

python - <<'PY'
import numpy as np
from pathlib import Path

mono = Path("out/splits")
dimer = Path("out/splits_dimer")
out = Path("out/splits_mono_dimer")
out.mkdir(parents=True, exist_ok=True)

def pad_axis1(arr, target):
    """Pad/truncate axis=1 to target size."""
    if arr.shape[1] == target:
        return arr
    if arr.shape[1] > target:
        return arr[:, :target, ...]
    new_shape = list(arr.shape)
    new_shape[1] = target
    out_arr = np.zeros(new_shape, dtype=arr.dtype)
    out_arr[:, :arr.shape[1], ...] = arr
    return out_arr

def merge_dicts(a_dict, b_dict, name, split):
    out_dict = {}
    n_a = next(iter(a_dict.values())).shape[0]
    n_b = next(iter(b_dict.values())).shape[0]

    common = sorted(set(a_dict.keys()) & set(b_dict.keys()))
    if not common:
        raise RuntimeError(f"No common keys in {name} {split}")

    for k in common:
        a = a_dict[k]
        b = b_dict[k]

        # Must match rank
        if a.ndim != b.ndim:
            raise ValueError(f"{name}/{split}/{k}: ndim mismatch {a.ndim} vs {b.ndim}")

        # If per-sample array and axis=1 differs, pad axis=1 when trailing dims match
        if (
            a.ndim >= 2
            and a.shape[0] == n_a
            and b.shape[0] == n_b
            and a.shape[1] != b.shape[1]
            and a.shape[2:] == b.shape[2:]
        ):
            target = max(a.shape[1], b.shape[1])
            a = pad_axis1(a, target)
            b = pad_axis1(b, target)

        # Final compatibility check (excluding sample axis)
        if a.shape[1:] != b.shape[1:]:
            raise ValueError(
                f"{name}/{split}/{k}: incompatible shapes after padding: {a.shape} vs {b.shape}"
            )

        out_dict[k] = np.concatenate([a, b], axis=0)

    return out_dict

for split in ("train", "valid"):
    efd_m = dict(np.load(mono / f"energies_forces_dipoles_{split}.npz"))
    efd_d = dict(np.load(dimer / f"energies_forces_dipoles_{split}.npz"))
    esp_m = dict(np.load(mono / f"grids_esp_{split}.npz"))
    esp_d = dict(np.load(dimer / f"grids_esp_{split}.npz"))

    efd_out = merge_dicts(efd_m, efd_d, "efd", split)
    esp_out = merge_dicts(esp_m, esp_d, "esp", split)

    np.savez_compressed(out / f"energies_forces_dipoles_{split}.npz", **efd_out)
    np.savez_compressed(out / f"grids_esp_{split}.npz", **esp_out)

    natoms_efd = efd_out["F"].shape[1] if "F" in efd_out and efd_out["F"].ndim >= 2 else "?"
    natoms_esp = esp_out["R"].shape[1] if "R" in esp_out and esp_out["R"].ndim >= 2 else "?"
    print(f"{split}: merged -> efd_natoms={natoms_efd}, esp_natoms={natoms_esp}, samples={len(esp_out['N'])}")

print(f"Done. Wrote merged files to: {out}")
PY
