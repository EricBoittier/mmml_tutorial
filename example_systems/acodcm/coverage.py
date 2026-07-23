"""Are the -33 kcal/mol wells at geometries the training data ever visits?

If validation MAE is 0.053 eV but the model errs by 1.4 eV on these rays, the
rays must sit outside the training distribution. Check it directly.
"""
import sys
import numpy as np
sys.path.insert(0, "/mmhome/boittier/home/mmml")
from scripts.scan_dimer_orientations import fibonacci_sphere, quat_to_matrix, super_fibonacci

D = "/mmhome/boittier/home/mmml_tutorial/acodcm/out_combined_dedup"
tr = dict(np.load(f"{D}/energies_forces_dipoles_train.npz", allow_pickle=True))
res = np.array([str(x) for x in tr["res_name"]])

# --- what the TRAINING data actually covers, for DCM dimers ---
mol = np.asarray(tr["mol_id"]); R = np.asarray(tr["R"])
rc, ct = [], []
for i in np.where(res == "DCM,DCM")[0]:
    a, b = R[i][mol[i] == 0], R[i][mol[i] == 1]
    rc.append(np.linalg.norm(a.mean(0) - b.mean(0)))
    ct.append(np.linalg.norm(a[:, None] - b[None, :], axis=-1).min())
rc, ct = np.array(rc), np.array(ct)
print(f"TRAIN DCM,DCM dimers: n={len(rc)}")
print(f"  r_com   : min {rc.min():.2f}  p1 {np.percentile(rc,1):.2f}  median {np.median(rc):.2f}")
print(f"  contact : min {ct.min():.2f}  p1 {np.percentile(ct,1):.2f}  median {np.median(ct):.2f}")

# --- where the deepest rays put their minima ---
k = int(np.where(res == "DCM")[0][0])
n = int(tr["N"][k]); Z1 = np.asarray(tr["Z"][k])[:n]
R1 = np.asarray(tr["R"][k])[:n]; R1 = R1 - R1.mean(0)
dirs = fibonacci_sphere(10); quats = super_fibonacci(24)

print(f"\ndeepest ML wells (new model) vs that coverage:")
for ray, r_min, depth in ((68, 3.2, -33.6), (147, 4.4, -32.2), (29, 3.4, -31.5)):
    di, qi = ray // 24, ray % 24
    Rb = R1 @ quat_to_matrix(quats[qi]).T
    a = R1 - 0.5 * r_min * dirs[di]
    b = Rb + 0.5 * r_min * dirs[di]
    c = np.linalg.norm(a[:, None] - b[None, :], axis=-1).min()
    # nearest training dimer by (r_com, contact) -- a crude but honest proxy
    dist = np.sqrt(((rc - r_min) / 0.5) ** 2 + ((ct - c) / 0.5) ** 2)
    inside_r = (rc <= r_min).sum()
    inside_c = (ct <= c).sum()
    print(f"  ray {ray:3d}: ML {depth:7.1f} kcal/mol at r_com={r_min:.1f}, contact={c:.2f} A")
    print(f"           training dimers at r_com <= {r_min:.1f}: {inside_r}/{len(rc)}"
          f"   |  at contact <= {c:.2f}: {inside_c}/{len(ct)}")
