import numpy as np
a = dict(np.load("out_combined_dedup/energies_forces_dipoles_test.npz", allow_pickle=True))
b = dict(np.load("gfn2_nms_test.npz", allow_pickle=True))
for tag, d in (("out_combined (reference table)", a), ("gfn2_nms (gate used this)", b)):
    res = np.array([str(x) for x in d["res_name"]])
    i = int(np.where(res == "ACO")[0][0])
    n = int(d["N"][i]); R = np.asarray(d["R"][i])[:n]
    dm = np.linalg.norm(R[:, None] - R[None, :], axis=-1); np.fill_diagonal(dm, np.inf)
    print(f"{tag:32s} idx={i:5d}  min-dist={dm.min():.3f}  max-dist={dm[np.isfinite(dm)].max():.3f}")
# are they the same geometry at all?
ra = np.asarray(a["R"][int(np.where(np.array([str(x) for x in a["res_name"]])=="ACO")[0][0])])[:10]
rb = np.asarray(b["R"][int(np.where(np.array([str(x) for x in b["res_name"]])=="ACO")[0][0])])[:10]
print(f"\nsame monomer? rmsd(no align) = {np.sqrt(((ra-ra.mean(0))-(rb-rb.mean(0))).__pow__(2).sum(-1).mean()):.3f} A")
