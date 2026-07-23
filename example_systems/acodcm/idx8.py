"""Characterise valid[8] against every other ACO monomer. Read-only, no model."""
import numpy as np
D = "/mmhome/boittier/home/mmml_tutorial/acodcm/out_combined_dedup"
va = dict(np.load(f"{D}/energies_forces_dipoles_valid.npz", allow_pickle=True))
tr = dict(np.load(f"{D}/energies_forces_dipoles_train.npz", allow_pickle=True))

def acos(d):
    res = np.array([str(x) for x in d["res_name"]])
    return np.where(res == "ACO")[0]

def stats(d, name):
    ii = acos(d)
    E = np.array([float(np.asarray(d["E"][i]).reshape(-1)[0]) for i in ii])
    print(f"{name}: {len(ii)} ACO monomers  E: min {E.min():.3f}  max {E.max():.3f} "
          f"mean {E.mean():.3f}  std {E.std():.3f}")
    return ii, E

it, Et = stats(tr, "train")
iv, Ev = stats(va, "valid")

i = 8
Z = np.asarray(va["Z"][i]); R = np.asarray(va["R"][i]); n = int(va["N"][i])
Zr, Rr = Z[:n], R[:n]
dm = np.linalg.norm(Rr[:, None] - Rr[None, :], axis=-1)
np.fill_diagonal(dm, np.inf)
E8 = float(np.asarray(va["E"][i]).reshape(-1)[0])
F8 = np.asarray(va["F"][i])[:n]
print(f"\n--- valid[8] ---")
print(f"  Z = {Zr.tolist()}  N={n}")
print(f"  E = {E8:.4f} eV   (train ACO mean {Et.mean():.3f} +- {Et.std():.3f})")
print(f"  z-score vs train ACO monomers: {(E8 - Et.mean()) / Et.std():+.2f} sigma")
print(f"  min interatomic distance: {dm.min():.4f} A   max: {dm[np.isfinite(dm)].max():.3f} A")
print(f"  |F| max = {np.abs(F8).max():.4f} eV/A   |F| rms = {np.sqrt((F8**2).mean()):.4f}")
print(f"  sum F (should be ~0): {np.abs(F8.sum(0)).max():.3e}")

# how do OTHER ACO monomers compare on these same measures?
def geom(d, ii):
    out = []
    for k in ii:
        nn = int(d["N"][k]); Rk = np.asarray(d["R"][k])[:nn]
        dd = np.linalg.norm(Rk[:, None] - Rk[None, :], axis=-1); np.fill_diagonal(dd, np.inf)
        Fk = np.asarray(d["F"][k])[:nn]
        out.append((dd.min(), np.abs(Fk).max()))
    return np.array(out)

gt = geom(tr, it)
print(f"\ntrain ACO monomers: min-dist  mean {gt[:,0].mean():.3f} min {gt[:,0].min():.3f}")
print(f"                    |F|max    mean {gt[:,1].mean():.3f} max {gt[:,1].max():.3f}")
gv = geom(va, iv)
worst = iv[np.argsort(-gv[:,1])][:5]
print(f"\nvalid ACO monomers by |F|max:")
for k in worst:
    nn = int(va["N"][k]); Rk = np.asarray(va["R"][k])[:nn]
    dd = np.linalg.norm(Rk[:,None]-Rk[None,:],axis=-1); np.fill_diagonal(dd, np.inf)
    print(f"  idx {k:4d}  E {float(np.asarray(va['E'][k]).reshape(-1)[0]):9.4f}  "
          f"|F|max {np.abs(np.asarray(va['F'][k])[:nn]).max():8.4f}  min-dist {dd.min():.4f}")

# is valid[8] a near-duplicate of any train structure?
best = None
for k in it:
    nn = int(tr["N"][k])
    if nn != n: continue
    Rk = np.asarray(tr["R"][k])[:nn]
    if (np.asarray(tr["Z"][k])[:nn] != Zr).any(): continue
    rms = np.sqrt(((Rk - Rr)**2).sum(1).mean())
    if best is None or rms < best[0]: best = (rms, k)
if best:
    print(f"\nclosest train ACO monomer (no alignment): rms {best[0]:.3f} A at train idx {best[1]}, "
          f"E {float(np.asarray(tr['E'][best[1]]).reshape(-1)[0]):.4f}")
