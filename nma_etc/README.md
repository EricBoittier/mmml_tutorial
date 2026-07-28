# NMA etc. — numbered workflow scripts

Scripts that shadow [`docs/examples/nma-workflow.md`](https://github.com/EricBoittier/mmml/blob/main/docs/examples/nma-workflow.md)
and train PhysNet on the bundled MP2 / aug-cc-pVTZ NPZs:

| File | Species | Samples | Atoms |
|------|---------|--------:|------:|
| `acem_mp2_aug-cc-pvtz_16106.npz` | acetamide (CGenFF `ACEM`) | 16106 | 9 |
| `form_mp2_aug-cc-pvtz_4000.npz` | formamide (CGenFF `FORM`) | 4000 | 6 |

**Require:** `mmml` on `PATH` (uv / micromamba). CHARMM + PyCHARMM for make-res / box / MD.

```bash
cd nma_etc
# Full docs path (residue → scans → …):
bash 01_make_res.sh
# … or jump straight to training on the bundled NPZs:
bash run_from_npz.sh
```

## Script map

| # | Script | Docs § | Notes |
|---|--------|--------|-------|
| 01 | `01_make_res.sh` | §1 Build residue | `mmml make-res --res NMA` |
| 02 | `02_ic_scan_prepare.sh` | §2 prepare | ω + N-methyl, `--prepare-only` |
| 03 | `03_ic_scan_xtb.sh` | §2 xTB smoke | methyl 1D barriers |
| 04 | `04_pad_merge_npz.py` | (prep) | pad FORM→9 atoms, merge ACEM+FORM |
| 05 | `05_fix_and_split.sh` | §3c | units already eV / eV·Å⁻¹ / e·Å |
| 06 | `06_validate.sh` | §3c | `mmml validate` train split |
| 07 | `07_physnet_train.sh` | §4 | `mmml physnet-train` (+ `configs/train.yaml`) |
| 08 | `08_physnet_evaluate.sh` | §5 | test-split metrics + plots |
| 09 | `09_ic_scan_ml.sh` | §5 ML scan | methyl grid with trained ckpt |
| 10 | `10_dimer_scan.sh` | §6 | `mmml dimer-scan NMA` (xtb or ML) |
| 11 | `11_make_box.sh` | §7 Box | Packmol box for `MD_RES` (default ACEM) |
| 12 | `12_md_system.sh` | §7 Hybrid MD | `mmml md-system` (needs `MMML_CKPT`) |

Optional QM labeling from a make-res minimum (docs §3a–3b) is **skipped** here —
the two NPZs already provide E/F/D labels. See `XX_sample_and_label.sh` if you want
that path later.

## Units note

Bundled NPZs look training-ready (R≈Å, E≈eV atomization-scale, F≈eV/Å, D≈e·Å).
`05_fix_and_split.sh` uses `--*-in` / `--*-out same` (no Ha→eV conversion, no
atomic-ref). Override in `shared.source` or the script if your labels differ.

## Checkpoint → MD

Training produces ACEM/FORM PhysNet weights. For condensed-phase MD use
`MD_RES=ACEM` (default). NMA ic-scan / dimer / make-res still follow the docs;
deploying the ACEM+FORM checkpoint on **NMA** MD is not supported without
NMA-labeled training data.
