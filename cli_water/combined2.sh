python - <<'PY'
import numpy as np
from pathlib import Path

sources = [Path("out/splits_mono_dimer"), Path("out/splits_md")]
out = Path("out/splits_mono_dimer_md")
out.mkdir(parents=True, exist_ok=True)

DROP_FROM_EFD = {"esp", "esp_grid", "vdw_grid", "vdw_surface"}

def merge_npz(paths, out_path, drop_keys=None):
    parts = [dict(np.load(p, allow_pickle=True)) for p in paths]
    common = set.intersection(*(set(p.keys()) for p in parts))
    if drop_keys:
        common -= set(drop_keys)
    common = sorted(common)

    merged = {}
    for k in common:
        arrs = [np.asarray(p[k]) for p in parts]
        s = arrs[0].shape[1:]
        for a in arrs[1:]:
            if a.shape[1:] != s:
                raise ValueError(f"Shape mismatch for key '{k}': {[x.shape for x in arrs]}")
        merged[k] = np.concatenate(arrs, axis=0)

    np.savez_compressed(out_path, **merged)
    return merged

for split in ("train", "valid", "test"):
    efd_files = [s / f"energies_forces_dipoles_{split}.npz" for s in sources if (s / f"energies_forces_dipoles_{split}.npz").exists()]
    esp_files = [s / f"grids_esp_{split}.npz" for s in sources if (s / f"grids_esp_{split}.npz").exists()]

    if efd_files:
        m = merge_npz(efd_files, out / f"energies_forces_dipoles_{split}.npz", drop_keys=DROP_FROM_EFD)
        print(f"{split} EFD merged: samples={m['R'].shape[0]}, keys={list(m.keys())[:6]}...")

    if esp_files:
        m = merge_npz(esp_files, out / f"grids_esp_{split}.npz")
        print(f"{split} ESP merged: samples={m['R'].shape[0]}, esp shape={m['esp'].shape}")

print(f"\nWrote merged splits to: {out}")
PY
