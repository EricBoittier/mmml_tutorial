"""
Pure PyCHARMM runner: heating and equilibration only (no MM/ML).

Runs CHARMM setup, minimization, heating, and equilibration. Does not run
ASE MD, JAX-MD, or any ML calculator. Use this for classical CHARMM-only
simulations or to prepare structures before running mmml run (MM/ML).

Usage:
    python -m mmml.cli.run.run_pycharmm --pdbfile pdb/init-packmol.pdb --cell 40
    mmml run-pycharmm --pdbfile pdb/init-packmol.pdb --cell 40
"""
#python -m mmml.cli.run.run_pycharmm --pdbfile pdb/init-packmol.pdb --cell 40 --pycharmm-minimize-steps 20000 --skip-setup-energy-show
mmml run-pycharmm --pdbfile pdb/init-packmol.pdb --cell 40
