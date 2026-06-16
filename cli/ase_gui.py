import numpy as np
import ase.data
from ase import Atoms
from ase.io import write

data = np.load("md.npz")

R = data["R"]        # (n_frames, n_atoms, 3)
Z = data["Z"]

symbols = [ase.data.chemical_symbols[int(z)] for z in Z]

atoms_list = [Atoms(symbols=symbols, positions=r) for r in R]

write("traj.traj", atoms_list)
