"""Real DFT cost per geometry at def2-TZVP -- SCF + gradient, as the dataset needs."""
import time
import numpy as np
from gpu4pyscf import dft
from pyscf import gto

D = "/mmhome/boittier/home/mmml_tutorial/acodcm/out_combined_dedup"
raw = dict(np.load(f"{D}/energies_forces_dipoles_test.npz", allow_pickle=True))
res = np.array([str(x) for x in raw["res_name"]])

def bench(name, basis, xc, grids):
    i = int(np.where(res == name)[0][0]); n = int(raw["N"][i])
    Z = np.asarray(raw["Z"][i])[:n]; R = np.asarray(raw["R"][i])[:n]
    mol = gto.M(atom=[(int(z), tuple(float(x) for x in r)) for z, r in zip(Z, R)],
                basis=basis, verbose=0)
    t = time.time()
    mf = dft.RKS(mol, xc=xc).density_fit()
    mf.grids.atom_grid = grids
    e = mf.kernel(); t_e = time.time() - t
    t = time.time(); g = mf.nuc_grad_method().kernel(); t_g = time.time() - t
    print(f"  {name:9s} {basis:11s} {xc:6s} grid{str(grids):10s} nbf={mol.nao:4d}  "
          f"scf {t_e:6.1f}s + grad {t_g:6.1f}s = {t_e+t_g:6.1f}s", flush=True)
    return t_e + t_g

print("=== warmup (JIT) ===")
bench("DCM,DCM", "def2-SVP", "PBE0", (75, 302))
print("=== def2-TZVP ===")
t1 = bench("DCM,DCM", "def2-TZVP", "PBE0", (99, 590))
t2 = bench("ACO,ACO", "def2-TZVP", "PBE0", (99, 590))
print("=== def2-TZVP, cheaper grid ===")
t3 = bench("DCM,DCM", "def2-TZVP", "PBE0", (75, 302))
t4 = bench("ACO,ACO", "def2-TZVP", "PBE0", (75, 302))
N = 24773
for label, per in (("TZVP (99,590)", (t1 + t2) / 2), ("TZVP (75,302)", (t3 + t4) / 2)):
    print(f"\n{label}: mean {per:.1f} s/geom -> {N} geoms = {N*per/3600:.1f} GPU-hours "
          f"({N*per/86400:.1f} days)")
