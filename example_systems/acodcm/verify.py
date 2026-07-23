import numpy as np
from mmml.models.hybrid_energy import HYBRID_MM_BATCH_KEYS

NEW = "gfn2_nms_train.npz"
OLD = "out_combined_dedup/energies_forces_dipoles_train.npz"
n = dict(np.load(NEW, allow_pickle=True)); o = dict(np.load(OLD, allow_pickle=True))

print("=== fields the hybrid trainer needs ===")
need = list(HYBRID_MM_BATCH_KEYS) + ["cgenff_master_sigmas", "cgenff_master_epsilons",
                                     "R", "Z", "N", "E", "F", "D"]
for k in need:
    print(f"  {'OK ' if k in n else 'MISSING'} {k:24s} {np.asarray(n[k]).shape if k in n else ''}")
print(f"  master tables identical to source: "
      f"{np.array_equal(n['cgenff_master_sigmas'], o['cgenff_master_sigmas'])}")

print("\n=== coverage: the thing this dataset exists to fix ===")
for tag, d in (("OLD (MD snapshots)", o), ("NEW (GFN2 scan)", d if False else n)):
    res = np.array([str(x) for x in d["res_name"]]); mol = np.asarray(d["mol_id"])
    R = np.asarray(d["R"])
    for sp in ("DCM,DCM", "ACO,ACO"):
        i = np.where(res == sp)[0]
        if len(i) == 0: continue
        rc, ct = [], []
        for k in i[:4000]:
            a, b = R[k][mol[k] == 0], R[k][mol[k] == 1]
            rc.append(np.linalg.norm(a.mean(0) - b.mean(0)))
            ct.append(np.linalg.norm(a[:, None] - b[None, :], axis=-1).min())
        rc, ct = np.array(rc), np.array(ct)
        print(f"  {tag:20s} {sp}: n={len(i):5d}  r_com med {np.median(rc):5.2f}  "
              f"contact med {np.median(ct):5.2f} min {ct.min():4.2f}  "
              f"| frac r_com<6: {(rc<6).mean()*100:4.1f}%  frac contact<2.5: {(ct<2.5).mean()*100:4.1f}%")

print("\n=== energies / forces sane? ===")
E = np.asarray(n["E"]).ravel(); F = np.asarray(n["F"]); D = np.asarray(n["D"])
res = np.array([str(x) for x in n["res_name"]])
for sp in ("DCM", "ACO", "DCM,DCM", "ACO,ACO"):
    m = res == sp
    if m.sum(): print(f"  {sp:9s} n={m.sum():5d}  E {E[m].min():12.3f}..{E[m].max():12.3f} eV  "
                      f"|F|max {np.abs(F[m]).max():7.3f} eV/A  |D| med {np.median(np.linalg.norm(D[m],axis=1)):.3f} e.A")
# interaction energy sanity: dimer E minus 2x monomer E
for sp in ("DCM", "ACO"):
    mono = E[res == sp]
    dim = E[res == f"{sp},{sp}"]
    if len(mono) and len(dim):
        eint = (dim - 2 * mono.mean()) * 23.0605
        print(f"  {sp} dimer E_int: min {eint.min():8.2f}  median {np.median(eint):7.2f} kcal/mol "
              f"(deepest well)")
