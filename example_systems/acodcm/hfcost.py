"""Real per-geometry HF cost, so the dataset can be sized honestly."""
import time
import numpy as np
from gpu4pyscf.scf import RHF
from pyscf import gto

D = "/mmhome/boittier/home/mmml_tutorial/acodcm/out_combined_dedup"
raw = dict(np.load(f"{D}/energies_forces_dipoles_test.npz", allow_pickle=True))
res = np.array([str(x) for x in raw["res_name"]])

for name in ("DCM,DCM", "ACO,ACO"):
    i = int(np.where(res == name)[0][0])
    n = int(raw["N"][i])
    Z = np.asarray(raw["Z"][i])[:n]; R = np.asarray(raw["R"][i])[:n]
    atom = [(int(z), tuple(float(x) for x in r)) for z, r in zip(Z, R)]
    for basis in ("def2-SVP", "6-31G*"):
        mol = gto.M(atom=atom, basis=basis, verbose=0)
        t = time.time(); mf = RHF(mol).density_fit(); e = mf.kernel(); t_e = time.time() - t
        t = time.time(); g = mf.nuc_grad_method().kernel(); t_g = time.time() - t
        print(f"{name:9s} {basis:9s} nbf={mol.nao:4d}  E={e:14.6f} Ha  "
              f"scf {t_e:5.1f}s + grad {t_g:5.1f}s = {t_e+t_g:5.1f}s  |F|max={np.abs(g).max():.4f}")
