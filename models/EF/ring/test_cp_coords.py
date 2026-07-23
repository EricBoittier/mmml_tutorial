import numpy as np
from pathlib import Path


# ---------- atomic numbers ----------

ATOMIC_NUMBERS = {
    "H": 1,
    "C": 6,
    "N": 7,
    "O": 8,
    "F": 9,
    "P": 15,
    "S": 16,
    "Cl": 17,
}


def symbols_to_Z(symbols):
    try:
        return np.array([ATOMIC_NUMBERS[s] for s in symbols], dtype=np.int32)
    except KeyError as e:
        raise ValueError(f"Unknown element symbol: {e.args[0]}")


# ---------- basic xyz io ----------

def read_xyz_string(xyz_text):
    lines = [x.rstrip() for x in xyz_text.strip().splitlines()]
    n = int(lines[0])
    comment = lines[1]
    symbols = []
    coords = []
    for line in lines[2:2+n]:
        parts = line.split()
        symbols.append(parts[0])
        coords.append([float(parts[1]), float(parts[2]), float(parts[3])])
    return symbols, np.array(coords, dtype=float), comment


def write_xyz(path, symbols, coords, comment=""):
    coords = np.asarray(coords, dtype=float)
    with open(path, "w") as f:
        f.write(f"{len(symbols)}\n")
        f.write(comment + "\n")
        for s, (x, y, z) in zip(symbols, coords):
            f.write(f"{s:2s} {x:16.8f} {y:16.8f} {z:16.8f}\n")


def write_npz(path, symbols, coords):
    coords = np.asarray(coords, dtype=float)
    Z = symbols_to_Z(symbols)
    N = np.int32(len(symbols))
    np.savez(path, Z=Z, R=coords, N=N)


# ---------- geometry helpers ----------

def best_fit_plane(coords):
    coords = np.asarray(coords, dtype=float)
    centroid = coords.mean(axis=0)
    X = coords - centroid
    _, _, vh = np.linalg.svd(X, full_matrices=False)
    normal = vh[-1]
    normal /= np.linalg.norm(normal)
    z = X @ normal
    return centroid, normal, z


def local_frame_from_ring(coords):
    """
    Build a reproducible in-plane basis from the ring geometry itself.
    """
    centroid, normal, _ = best_fit_plane(coords)
    X = coords - centroid

    e1 = X[0] - np.dot(X[0], normal) * normal
    if np.linalg.norm(e1) < 1e-10:
        e1 = X[1] - np.dot(X[1], normal) * normal
    e1 /= np.linalg.norm(e1)

    e2 = np.cross(normal, e1)
    e2 /= np.linalg.norm(e2)

    return centroid, e1, e2, normal


def regular_ngon_xy_from_radius(n, radius):
    ang = 2.0 * np.pi * np.arange(n) / n
    return np.column_stack([radius * np.cos(ang), radius * np.sin(ang)])


def embed_xy_z(xy, z, centroid, e1, e2, normal):
    return (
        centroid
        + np.outer(xy[:, 0], e1)
        + np.outer(xy[:, 1], e2)
        + np.outer(z, normal)
    )


# ---------- 5-membered Cremer-Pople ----------

def cp5_z_from_qP(q, P, degrees=False):
    if degrees:
        P = np.deg2rad(P)
    j = np.arange(5)
    return np.sqrt(2.0 / 5.0) * q * np.cos(P + 4.0 * np.pi * j / 5.0)


def cp5_from_xyz(ring_xyz, degrees=False):
    ring_xyz = np.asarray(ring_xyz, dtype=float)
    if ring_xyz.shape != (5, 3):
        raise ValueError("ring_xyz must have shape (5, 3)")

    centroid, normal, z = best_fit_plane(ring_xyz)

    j = np.arange(5)
    c = np.cos(4.0 * np.pi * j / 5.0)
    s = np.sin(4.0 * np.pi * j / 5.0)

    A = np.sqrt(2.0 / 5.0) * np.sum(z * c)    # q cos P
    B = -np.sqrt(2.0 / 5.0) * np.sum(z * s)   # q sin P

    q = np.hypot(A, B)
    P = np.arctan2(B, A)

    if degrees:
        P = np.rad2deg(P)

    return {
        "q": q,
        "P": P,
        "centroid": centroid,
        "normal": normal,
        "z": z,
    }


def rebuild_ring5_from_qP(reference_ring_xyz, q, P, degrees=False):
    """
    Rebuild a 5-membered ring using:
    - the reference ring's mean-plane centroid and orientation
    - an average in-plane radius from the reference
    - target Cremer-Pople (q, P)
    """
    reference_ring_xyz = np.asarray(reference_ring_xyz, dtype=float)
    centroid, e1, e2, normal = local_frame_from_ring(reference_ring_xyz)

    X = reference_ring_xyz - centroid
    x = X @ e1
    y = X @ e2
    r = np.mean(np.sqrt(x**2 + y**2))

    xy = regular_ngon_xy_from_radius(5, r)
    z = cp5_z_from_qP(q, P, degrees=degrees)
    return embed_xy_z(xy, z, centroid, e1, e2, normal)


def rotation_matrix_from_vectors(a, b):
    """
    Return rotation matrix that maps unit vector a onto unit vector b.
    """
    a = np.asarray(a, dtype=float)
    b = np.asarray(b, dtype=float)

    a /= np.linalg.norm(a)
    b /= np.linalg.norm(b)

    v = np.cross(a, b)
    c = np.dot(a, b)

    if np.isclose(c, 1.0):
        return np.eye(3)

    if np.isclose(c, -1.0):
        # 180-degree rotation: choose any axis perpendicular to a
        axis = np.array([1.0, 0.0, 0.0])
        if abs(np.dot(axis, a)) > 0.9:
            axis = np.array([0.0, 1.0, 0.0])
        v = np.cross(a, axis)
        v /= np.linalg.norm(v)
        K = np.array([
            [0, -v[2], v[1]],
            [v[2], 0, -v[0]],
            [-v[1], v[0], 0],
        ])
        return np.eye(3) + 2 * (K @ K)

    s = np.linalg.norm(v)
    K = np.array([
        [0, -v[2], v[1]],
        [v[2], 0, -v[0]],
        [-v[1], v[0], 0],
    ])

    R = np.eye(3) + K + K @ K * ((1 - c) / (s ** 2))
    return R


def move_attached_substituents_rigid(coords, ring_idx, new_ring_coords, attachment_map):
    """
    Move attached atoms with a rigid local rotation around each parent ring atom.

    The rotation is chosen so that the direction from the ring centroid to each
    parent carbon follows the new ring geometry.
    """
    coords = np.asarray(coords, dtype=float).copy()
    old_ring = coords[ring_idx].copy()
    old_centroid = old_ring.mean(axis=0)
    new_centroid = new_ring_coords.mean(axis=0)

    new_coords = coords.copy()
    new_coords[ring_idx] = new_ring_coords

    for ring_atom, attached_atoms in attachment_map.items():
        ring_pos = ring_idx.index(ring_atom)

        old_c = old_ring[ring_pos]
        new_c = new_ring_coords[ring_pos]

        old_vec = old_c - old_centroid
        new_vec = new_c - new_centroid

        R = rotation_matrix_from_vectors(old_vec, new_vec)

        for a in attached_atoms:
            rel = coords[a] - old_c
            new_rel = R @ rel
            new_coords[a] = new_c + new_rel

    return new_coords


# ---------- sampling ----------

def sample_qP_grid(
    symbols,
    coords,
    ring_idx,
    attachment_map,
    q_values,
    P_values,
    outdir="qP_samples",
    degrees=True,
    write_xyz_files=True,
    write_npz_files=True,
):
    outdir = Path(outdir)
    outdir.mkdir(exist_ok=True)

    ring_xyz = coords[ring_idx]
    cp = cp5_from_xyz(ring_xyz, degrees=degrees)
    unit = "deg" if degrees else "rad"
    print(f"Starting structure: q = {cp['q']:.6f}, P = {cp['P']:.3f} {unit}")

    generated = []
    for q in q_values:
        for P in P_values:
            new_ring = rebuild_ring5_from_qP(ring_xyz, q=q, P=P, degrees=degrees)
            new_coords = move_attached_substituents_rigid(
            coords=coords,
            ring_idx=ring_idx,
            new_ring_coords=new_ring,
            attachment_map=attachment_map,
            )

            if degrees:
                tag = f"q_{q:.3f}_P_{P:.1f}"
            else:
                tag = f"q_{q:.3f}_P_{P:.3f}"

            xyz_path = outdir / f"{tag}.xyz"
            npz_path = outdir / f"{tag}.npz"

            if write_xyz_files:
                write_xyz(xyz_path, symbols, new_coords, comment=f"sampled CP point {tag}")

            if write_npz_files:
                write_npz(npz_path, symbols, new_coords)

            generated.append({
                "tag": tag,
                "xyz": xyz_path if write_xyz_files else None,
                "npz": npz_path if write_npz_files else None,
            })

    return generated


# ---------- your structure ----------

xyz_text = """15
Properties=species:S:1:pos:R:3 pbc="F F F"
C        1.74133769       1.31596735       0.40074118
H        2.56024676       1.38490293      -0.33008272
H        1.94076932       2.08656179       1.16183648
C        1.68152527      -0.08590916       1.03634145
H        2.18407319      -0.81150936       0.37471610
H        2.19363786      -0.14106187       2.00619865
C        0.18916528      -0.42446631       1.12245085
H       -0.25316590       0.03692514       2.02151476
H       -0.00705626      -1.50260841       1.18708620
C       -0.39127914       0.22287430      -0.13762474
H       -1.48112856       0.34559073      -0.10287289
H       -0.16980356      -0.41027827      -1.01428945
C        0.36551454       1.55395439      -0.25471204
H        0.44494189       1.90148074      -1.29327944
H       -0.17600486       2.34213023       0.29610312
"""

symbols, coords, comment = read_xyz_string(xyz_text)

# 0-based indices of the 5 ring carbons
ring_idx = [0, 3, 6, 9, 12]

# each ring carbon carries two hydrogens
attachment_map = {
    0: [1, 2],
    3: [4, 5],
    6: [7, 8],
    9: [10, 11],
    12: [13, 14],
}

# example sampling grid
q_values = np.linspace(0.00, 0.50, 6)      # 0.00, 0.10, ..., 0.50
P_values = np.arange(0.0, 360.0, 18.0)     # full pseudorotation cycle

generated = sample_qP_grid(
    symbols,
    coords,
    ring_idx,
    attachment_map,
    q_values,
    P_values,
    outdir="qP_samples",
    degrees=True,
    write_xyz_files=True,
    write_npz_files=True,
)

print(f"Generated {len(generated)} structures")
print("Example npz fields: Z, R, N")