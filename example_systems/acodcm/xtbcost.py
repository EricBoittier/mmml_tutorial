"""Real GFN2 cost: naive (rebuild calc) vs reused vs native tblite API."""
import time
import numpy as np
from ase import Atoms
from tblite.ase import TBLite

D = "/mmhome/boittier/home/mmml_tutorial/acodcm/out_combined_dedup"
raw = dict(np.load(f"{D}/energies_forces_dipoles_test.npz", allow_pickle=True))
res = np.array([str(x) for x in raw["res_name"]])
i = int(np.where(res == "ACO,ACO")[0][0])
n = int(raw["N"][i]); Z = np.asarray(raw["Z"][i])[:n]; R = np.asarray(raw["R"][i])[:n]

N = 20
# 1. naive: new calculator each time (what my validation script did)
t = time.time()
for k in range(N):
    a = Atoms(numbers=Z, positions=R + np.array([0.001 * k, 0, 0]))
    a.calc = TBLite(method="GFN2-xTB", verbosity=0)
    a.get_potential_energy(); a.get_forces()
print(f"naive (rebuild calc): {(time.time()-t)/N:.3f} s/geom")

# 2. native tblite API, reused
from tblite.interface import Calculator
BOHR = 1.8897261254535
t = time.time()
calc = Calculator("GFN2-xTB", np.asarray(Z), np.asarray(R) * BOHR)
calc.set("verbosity", 0)
for k in range(N):
    calc.update(positions=(R + np.array([0.001 * k, 0, 0])) * BOHR)
    r = calc.singlepoint()
    e = r.get("energy"); g = r.get("gradient")
dt = (time.time() - t) / N
print(f"native tblite (reused): {dt:.3f} s/geom  -> 2576 geoms = {2576*dt/60:.1f} min")
print(f"  E={e:.6f} Ha  |grad|max={np.abs(g).max():.5f}")
