# Liquid box report

**Status:** PASS
**Profile:** dense

## System

- Composition: `ACO:178`
- Molecules: 178
- Atoms: 1780

## Box

- Target cubic side: 27.976 Å
- Final cubic side: 27.976 Å
- Target density: 0.7840 g/cm³
- Final density: 0.7840 g/cm³
- Density relative error: 0.00%

## Geometry certification (MM)

- Worst inter-monomer contact: 1.525 Å
- Prep floor: 0.450 Å
- Dynamics overlap reference: 0.450 Å
- CHARMM MM GRMS: 0.1411 kcal/mol/Å

## Steps applied

- packmol_cluster
- mc_density_skipped_hold_box
- save_model_topology
- charmm_mm_pre_minimize
- pre_mlpot:monomer_repack_skipped_clean
- pre_mlpot:mc_density_skipped_hold_box
- write_model_crd

## Artifacts

- `model.psf`
- `model.crd`
- `model.pdb`
- `box.json`
- `prep_ladder/` (checkpoints)

## Next step

```bash
mmml md-system \
  --from-psf /mmhome/boittier/home/mmml_tutorial/acodcm/boxes/aco178/model.psf \
  --from-crd /mmhome/boittier/home/mmml_tutorial/acodcm/boxes/aco178/model.crd \
  --checkpoint /path/to/checkpoint.json \
  --backend jaxmd --setup pbc_nve \
  --output-dir runs/aco178_nve
# or: --backend pycharmm --md-stages mini,heat,equi
```
