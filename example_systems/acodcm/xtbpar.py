import os, sys, time
import numpy as np
print("OMP_NUM_THREADS =", os.environ.get("OMP_NUM_THREADS", "(unset)"))
print("cpus =", os.cpu_count())
from tblite.interface import Calculator
D = "/mmhome/boittier/home/mmml_tutorial/acodcm/out_combined_dedup"
raw = dict(np.load(f"{D}/energies_forces_dipoles_test.npz", allow_pickle=True))
res = np.array([str(x) for x in raw["res_name"]])
i = int(np.where(res == "ACO,ACO")[0][0])
n = int(raw["N"][i]); Z = np.asarray(raw["Z"][i])[:n]; R = np.asarray(raw["R"][i])[:n]
BOHR = 1.8897261254535
N = 10
t = time.time()
for k in range(N):
    c = Calculator("GFN2-xTB", Z, (R + np.array([0.001*k,0,0])) * BOHR)
    c.set("verbosity", 0)
    r = c.singlepoint()
dt = (time.time()-t)/N
print(f"serial: {dt:.3f} s/geom -> 2576 = {2576*dt/60:.1f} min")
