"""Is the -10.87 kcal/mol ACO hole at a geometry the training data covers?

If covered -> the model failed where it HAD data: architecture/loss, and a better
reference will not fix it. If not covered -> still extrapolation, and denser data
(or PBE0) plausibly helps.
"""
import sys
import numpy as np
sys.path.insert(0, "/mmhome/boittier/home/mmml")
from scripts.scan_dimer_orientations import fibonacci_sphere, quat_to_matrix, super_fibonacci

D = "/mmhome/boittier/home/mmml_tutorial/acodcm"
scan_src = dict(np.load(f"{D}/out_combined_dedup/energies_forces_dipoles_test.npz", allow_pickle=True))
res = np.array([str(x) for x in scan_src["res_name"]])
k = int(np.where(res == "ACO")[0][0])
n = int(scan_src["N"][k]); Z1 = np.asarray(scan_src["Z"][k])[:n]
R1 = np.asarray(scan_src["R"][k])[:n]; R1 = R1 - R1.mean(0)

dirs = fibonacci_sphere(10); quats = super_fibonacci(24)
rs = np.linspace(3.0, 10.0, 36)
import csv
rows = list(csv.DictReader(open("/tmp/gate_fair_ACO/rays.csv")))
r146 = [r for r in rows if int(r["ray"]) == 146][0]
r_min = float(r146["r_at_min"])
di, qi = 146 // 24, 146 % 24
a = R1 - 0.5 * r_min * dirs[di]
b = R1 @ quat_to_matrix(quats[qi]).T + 0.5 * r_min * dirs[di]
contact = np.linalg.norm(a[:, None] - b[None, :], axis=-1).min()
print(f"ACO ray 146 minimum: r_com={r_min:.2f} A  contact={contact:.2f} A  "
      f"ML={float(r146['e_min_kcal']):.2f} kcal/mol (xTB -1.28)")

# coverage in the TRAINING data
tr = dict(np.load(f"{D}/gfn2_nms15_train.npz", allow_pickle=True))
tres = np.array([str(x) for x in tr["res_name"]])
m = tres == "ACO,ACO"
R, mol = np.asarray(tr["R"])[m], np.asarray(tr["mol_id"])[m]
rc, ct = [], []
for i in range(len(R)):
    aa, bb = R[i][mol[i] == 0], R[i][mol[i] == 1]
    rc.append(np.linalg.norm(aa.mean(0) - bb.mean(0)))
    ct.append(np.linalg.norm(aa[:, None] - bb[None, :], axis=-1).min())
rc, ct = np.array(rc), np.array(ct)
near = (np.abs(rc - r_min) < 0.4) & (np.abs(ct - contact) < 0.3)
print(f"\ntraining ACO,ACO dimers: {m.sum()}")
print(f"  within (r_com +-0.4, contact +-0.3) of this point: {near.sum()} "
      f"({near.mean()*100:.1f}%)")
print(f"  at r_com <= {r_min:.2f}: {(rc <= r_min).sum()}   contact <= {contact:.2f}: {(ct <= contact).sum()}")
if near.sum():
    print(f"\n  -> COVERED. The model had {near.sum()} nearby training points and still "
          f"put a {float(r146['e_min_kcal']):.1f} kcal/mol hole here.")
    print("     A better reference (PBE0) will not fix that; it is architecture/loss.")
else:
    print("\n  -> NOT covered: still extrapolation. Denser data may help.")
