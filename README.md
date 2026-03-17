# MMML Tutorial: Cyanobenzene (CYBZ)

Step-by-step tutorial for building and simulating cyanobenzene using MMML's hybrid MM/ML workflow.

**Prerequisites:** MMML installed (`uv sync --extra all` or `make micromamba-create-full`), CHARMM set up for `make_res`/`make_box`.

---

## 01 – Generating a molecule

Create the residue structure and pack it into a simulation box.

### make_res

Generates PDB, PSF, and topology for a single residue using PyCHARMM/CGENFF:

```bash
# CLI (like pyscf-dft)
mmml make-res --res CYBZ
mmml make-res --res CYBZ --skip-energy-show   # skip energy.show() on clusters

# Or run the example scripts (from project root):
bash examples/mmml_tutorial/cli/01_make_res_cli.sh
uv run python examples/mmml_tutorial/programmatic/01_make_res_programmatic.py
```

Output: `pdb/initial.pdb`, `psf/initial.psf`, `xyz/initial.xyz`, CHARMM topology files (in `cli/` or `programmatic/` respectively).

### make_box

Packs molecules into a periodic box (vacuum or solvated).

In this case, we will prepare the dimers.

```bash
# CLI
mmml make-box --res CYBZ --n 2 --side_length 25.0
mmml make-box --res CYBZ --n 2 --side_length 25.0 --solvent TIP3 --density 1.0

# Or run the example scripts (from project root):
bash examples/mmml_tutorial/cli/02_make_box_cli.sh
uv run python examples/mmml_tutorial/programmatic/02_make_box_programmatic.py
```

Output: `pdb/init-packmol.pdb` (or `pdb/init-TIP3box.pdb` if solvated) in `cli/` or `programmatic/` respectively.

### run-pycharmm (pure CHARMM)

Run CHARMM heating and equilibration only (no ML). Uses the box from step 02:

```bash
# CLI (from cli/ directory after 01–02)
mmml run-pycharmm --pdbfile pdb/init-packmol.pdb --cell 25.0

# Or run the example script (from project root):
bash examples/mmml_tutorial/cli/11_run_pycharmm_cli.sh
```

Output: `heat.pdb`, `equi.pdb`, restart files (`heat.res`, `equi.res`), and trajectories (`heat.dcd`, `equi.dcd`).

---

## 02 – Calculating energy, forces, ESPs

### QM/DFT (GPU)

```bash
# CLI example
mmml pyscf-dft --mol pdb/initial.pdb --energy
mmml pyscf-mp2 --mol "O 0 0 0; H 0.96 0 0; H -0.24 0.93 0" --energy --gradient

# Or run the example scripts (from project root):
# 03: DFT energy
bash examples/mmml_tutorial/cli/03_pyscf_dft_cli.sh
uv run python examples/mmml_tutorial/programmatic/03_pyscf_dft_programmatic.py

# 04: DFT full (energy, gradient, hessian, harmonic, thermo)
bash examples/mmml_tutorial/cli/04_pyscf_dft_cli_full.sh
uv run python examples/mmml_tutorial/programmatic/04_pyscf_dft_programmatic.py

# 05: MP2 (post-HF)
bash examples/mmml_tutorial/cli/05_pyscf_mp2_cli.sh
uv run python examples/mmml_tutorial/programmatic/05_pyscf_mp2_programmatic.py

# 06: Normal mode sampling (from step 04 harmonic output)
bash examples/mmml_tutorial/cli/06_normal_mode_sample_cli.sh
uv run python examples/mmml_tutorial/programmatic/06_normal_mode_sample_programmatic.py

# 07: Evaluate sampled geometries (E, F, D, ESP)
bash examples/mmml_tutorial/cli/07_pyscf_evaluate_cli.sh
uv run python examples/mmml_tutorial/programmatic/07_pyscf_evaluate_programmatic.py

# 08: Fix units and create train/valid/test splits
bash examples/mmml_tutorial/cli/08_fix_and_split_cli.sh

# 09: Train PhysNet (energies, forces, dipoles)
bash examples/mmml_tutorial/cli/09_physnet_train_cli.sh

# 10: Train PhysNet+DCMNet (joint, with ESP)
bash examples/mmml_tutorial/cli/10_physnet_dcmnet_train_cli.sh
```

See `examples/pyscf4gpu/README.md` for full GPU-accelerated DFT/MP2 docs.

### Full training workflow (1000 structures)

For a larger dataset suitable for training, run:

```bash
# Generate 1000 structures (uses combination modes when needed)
mmml normal-mode-sample -i out/04_results.h5 -o out/06_sampled.npz --amplitude 0.1 --max-samples 1000

# Evaluate with pyscf-dft (E, F, D, ESP)
mmml pyscf-evaluate -i out/06_sampled.npz -o out/07_evaluated.npz --esp

# Or run the full pipeline script:
bash examples/mmml_tutorial/cli/run_full_training.sh
```

### Normal mode sampling

After running step 04 (DFT full with harmonic), sample geometries along vibrational modes for downstream QM/ML:

```bash
mmml normal-mode-sample -i out/04_results.h5 -o out/06_sampled.npz --amplitude 0.1 --max-samples 10
mmml normal-mode-sample -i out/04_results.h5 -o out/06_sampled.npz --amplitude 0.1 --include-equilibrium
```

Output: NPZ with `R` (n_samples, n_atoms, 3), `Z`, `N`.

### Evaluate sampled geometries

Run DFT on each sampled geometry (energy, forces, dipoles, ESP) in one GPU process:

```bash
mmml pyscf-evaluate -i out/06_sampled.npz -o out/07_evaluated.npz --esp
```

Output: NPZ with `R`, `Z`, `N`, `E`, `F`, `Dxyz`, `esp`, `esp_grid`. Ready for PhysNet/DCMNet training.

---

## 03 – PhysNet

Train a PhysNetJAX model on energies, forces, and dipoles.

### Prepare data (fix-and-split)

Converts units (Hartree → eV, etc.) and creates train/valid/test splits. If `07_evaluated.npz` contains esp/esp_grid, no separate grid file is needed:

```bash
mmml fix-and-split --efd out/07_evaluated.npz --output-dir out/splits
```

Output: `energies_forces_dipoles_{train,valid,test}.npz`, `grids_esp_{train,valid,test}.npz`.

### Train PhysNet

```bash
bash examples/mmml_tutorial/cli/09_physnet_train_cli.sh
```

Or manually:

```bash
uv run python examples/other/co2/physnet_train/trainer.py \
  --train out/splits/energies_forces_dipoles_train.npz \
  --valid out/splits/energies_forces_dipoles_valid.npz \
  --natoms 16 --epochs 50 --batch-size 1 --name cybz_physnet --ckpt-dir out/ckpts
```

Checkpoints: `out/ckpts/cybz_physnet/`.

---

## 04 – DCMNet

Train a DCMNet model for distributed charges and ESPs (electrostatic potential).

### PhysNet+DCMNet joint training

Train PhysNet and DCMNet together for end-to-end energy, forces, dipoles, and ESP:

```bash
bash examples/mmml_tutorial/cli/10_physnet_dcmnet_train_cli.sh
```

Or manually:

```bash
uv run python -m mmml.cli.misc.train_joint \
  --train-efd out/splits/energies_forces_dipoles_train.npz \
  --train-esp out/splits/grids_esp_train.npz \
  --valid-efd out/splits/energies_forces_dipoles_valid.npz \
  --valid-esp out/splits/grids_esp_valid.npz \
  --epochs 50 --batch-size 1 --name cybz_joint --ckpt-dir out/ckpts
```

Checkpoints: `out/ckpts/cybz_joint/`.

### DCMNet only

```bash
cd examples/dcm-net
python train.py model=base training=bootstrap
```

### With PhysNet (joint training)

See `examples/other/co2/dcmnet_physnet_train/` for joint PhysNet–DCMNet training.

DCMNet predicts monopoles and dipoles per atom for improved ESP and charge fitting.

---

## 05 – DCMNet to fMDCM, kMDCM

Convert trained DCMNet models to MDCM (multipole-derived charge model) formats for use in classical force fields.

- **fMDCM**: Fixed-site MDCM
- **kMDCM**: Kernel-based MDCM variant

*(Detailed workflow and scripts to be added.)*


## 05 – MMML
### Run simulation
Run MD or evaluate energy/forces with a trained ML model.
From Python (see `examples/general/dimers/sim.py`):

```python
import argparse
from pathlib import Path
from mmml.cli.run.run_sim import run
from mmml.cli.base import resolve_desdimers_checkpoint

args = argparse.Namespace(
    pdbfile=Path("pdb/init-packmol.pdb"),
    checkpoint=resolve_desdimers_checkpoint(),
    n_monomers=50,
    n_atoms_monomer=15,
    cell=25.0,
    nsteps_jaxmd=1000,
    nsteps_ase=100,
    temperature=298.0,
    ensemble="npt",
    # ... see run_sim.parse_args() for full options
)
run(args)
```

### Test calculator (energy, forces, charges, dipole)

```bash
python -m mmml.cli.calculator --checkpoint <path-to-checkpoint> --test-molecule CO2
```


---

## Reference

| # | Step | CLI | Scripts |
|---|------|-----|---------|
| 01 | make_res | `mmml make-res --res CYBZ` | `cli/01_make_res_cli.sh`, `programmatic/01_make_res_programmatic.py` |
| 02 | make_box | `mmml make-box --res CYBZ --n 50 --side_length 25` | `cli/02_make_box_cli.sh`, `programmatic/02_make_box_programmatic.py` |
| 11 | run-pycharmm | `mmml run-pycharmm --pdbfile pdb/init-packmol.pdb --cell 25.0` | `cli/11_run_pycharmm_cli.sh` |
| 03 | pyscf-dft | `mmml pyscf-dft --mol "..." --energy` | `cli/03_pyscf_dft_cli.sh`, `programmatic/03_pyscf_dft_programmatic.py` |
| 04 | pyscf-dft full | `mmml pyscf-dft --mol xyz/initial.xyz --energy --gradient --hessian --harmonic --thermo` | `cli/04_pyscf_dft_cli_full.sh`, `programmatic/04_pyscf_dft_programmatic.py` |
| 05 | pyscf-mp2 | `mmml pyscf-mp2 --mol "..." --energy --gradient` | `cli/05_pyscf_mp2_cli.sh`, `programmatic/05_pyscf_mp2_programmatic.py` |
| 06 | normal-mode-sample | `mmml normal-mode-sample -i out/04_results.h5 -o out/06_sampled.npz --amplitude 0.1 --max-samples 10` | `cli/06_normal_mode_sample_cli.sh`, `programmatic/06_normal_mode_sample_programmatic.py` |
| 07 | pyscf-evaluate | `mmml pyscf-evaluate -i out/06_sampled.npz -o out/07_evaluated.npz --esp` | `cli/07_pyscf_evaluate_cli.sh`, `programmatic/07_pyscf_evaluate_programmatic.py` |
| 08 | fix-and-split | `mmml fix-and-split --efd out/07_evaluated.npz --output-dir out/splits` | `cli/08_fix_and_split_cli.sh` |
| 09 | PhysNet train | `python examples/other/co2/physnet_train/trainer.py --train ... --valid ...` | `cli/09_physnet_train_cli.sh` |
| 10 | PhysNet+DCMNet | `python -m mmml.cli.misc.train_joint --train-efd ... --train-esp ...` | `cli/10_physnet_dcmnet_train_cli.sh` |
| — | Full workflow | `bash examples/mmml_tutorial/cli/run_full_training.sh` | 1000 structures, split, PhysNet, PhysNet+DCMNet |
| — | DCMNet only | — | `examples/dcm-net/train.py` |
