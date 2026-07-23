"""Is the loss dominated by the repulsive-wall outliers? Dataset only, no model."""
import numpy as np
d = dict(np.load("gfn2_nms_train.npz", allow_pickle=True))
F = np.asarray(d["F"]); E = np.asarray(d["E"]).ravel()
res = np.array([str(x) for x in d["res_name"]]); mol = np.asarray(d["mol_id"])
R = np.asarray(d["R"]); N = np.asarray(d["N"])
fmax = np.abs(F).max(axis=(1, 2))

# closest inter-monomer contact per structure
ct = np.full(len(F), np.inf)
for i in range(len(F)):
    m = mol[i]
    if (m == 1).any():
        a, b = R[i][m == 0], R[i][m == 1]
        ct[i] = np.linalg.norm(a[:, None] - b[None, :], axis=-1).min()

print(f"max|F| distribution over {len(F)} train structures (eV/A):")
for q in (50, 90, 99, 99.9, 100):
    print(f"  p{q:<5}: {np.percentile(fmax, q):8.2f}")
print()
# MSE is what the loss sees: sum of F^2. Who owns it?
sq = (F ** 2).sum(axis=(1, 2))
order = np.argsort(-sq)
tot = sq.sum()
for k in (1, 10, 50, 100, 500):
    print(f"  top {k:4d} structures ({k/len(F)*100:5.2f}% of data) own "
          f"{sq[order[:k]].sum()/tot*100:5.1f}% of sum(F^2)")
print()
print("what are they?")
for i in order[:5]:
    print(f"    {res[i]:9s} contact={ct[i]:4.2f} A  max|F|={fmax[i]:7.1f} eV/A  "
          f"E_ref={E[i]:7.2f} eV ({E[i]*23.06:8.0f} kcal/mol)")
print()
print("effect of a contact floor (drops structures below it):")
for cut in (1.1, 1.3, 1.5, 1.7, 2.0):
    keep = (ct >= cut) | ~np.isfinite(ct)
    print(f"  contact >= {cut}: keeps {keep.sum():6d}/{len(F)} ({keep.mean()*100:5.1f}%)  "
          f"max|F| {fmax[keep].max():7.1f}  max E_ref {E[keep].max():6.2f} eV  "
          f"sum(F^2) drops to {sq[keep].sum()/tot*100:5.1f}%")
