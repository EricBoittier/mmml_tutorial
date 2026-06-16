import numpy as np
import MDAnalysis as mda

# Load topology + trajectory
u = mda.Universe("psf/system-.psf", "dcd/heat.dcd")

# Select atoms (e.g., your dimer only)
sel = u.select_atoms("all")   # or "resid 1 2"
#rint(sel.atoms[0].element)
# Atomic numbers
Z_out = np.array([
    6 if atom.name.startswith("C") else 1
    for atom in sel.atoms
])

R_samples = []

for ts in u.trajectory:
    R_samples.append(sel.positions.copy())  # shape (n_atoms, 3)

R_samples = np.array(R_samples)  # (n_frames, n_atoms, 3)

# Save
np.savez_compressed(
    "output.npz",
    R=R_samples,
    Z=Z_out,
    N=np.array(len(Z_out))
)
