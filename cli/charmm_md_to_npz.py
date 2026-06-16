#!/usr/bin/env python

import numpy as np
import pycharmm
import pycharmm.lingo as lingo
import pycharmm.coor as coor


# -------------------------------------------------
# 1. LOAD SYSTEM (PSF + PDB + optional FF)
# -------------------------------------------------
def load_system(psf_path, pdb_path, rtf=None, prm=None):

    print("***** Loading CHARMM system *****")

    if rtf and prm:
        lingo.charmm_script(f"""
        bomlev -2
open read card unit 10 name ./benz.rtf
read  rtf card unit 10

open read card unit 20 name ./benz.prm
read param card unit 20 flex

read sequence BENZ 2
generate BENZ setup""")

    lingo.charmm_script(f"""
    read psf card name {psf_path}
    read coor pdb name {pdb_path}
    """)

    # sanity check
    lingo.charmm_script("show atom")
    lingo.charmm_script("show bond")


# -------------------------------------------------
# 2. ASE → CHARMM coordinate conversion
# -------------------------------------------------
def set_coords(atoms):

    xyz = np.asarray(atoms.get_positions(), dtype=float)

    coor.set_positions({
        "x": xyz[:, 0],
        "y": xyz[:, 1],
        "z": xyz[:, 2],
    })


# -------------------------------------------------
# 3. NBONDS SETUP (CRITICAL FOR MD)
# -------------------------------------------------
def setup_nbonds():

    print("***** Setting NBONDS *****")

    lingo.charmm_script("""
    nbonds
    cutnb 12.0
    ctonnb 10.0
    ctofnb 11.0
    atom
    switch
    vfswitch
    ewald
    pmewald
    kappa 0.34
    fftgrid 64 64 64
    inbfrq -1
    imgfrq -1
    """)


# -------------------------------------------------
# 4. MINIMIZATION (IMPORTANT STABILITY STEP)
# -------------------------------------------------
def minimize():

    print("***** Minimization *****")

    lingo.charmm_script("""
    mini abnr nstep 200
    """)


# -------------------------------------------------
# 5. MD RUNNER
# -------------------------------------------------
def run_md(atoms, steps=1000, sample_every=10):

    print("***** Running CHARMM MD *****")

    set_coords(atoms)

    setup_nbonds()
    minimize()

    traj = []

    for i in range(steps):

        # correct MD step command
        lingo.charmm_script("dyna step 1")

        if i % sample_every == 0:
            xyz = coor.get_positions()
            traj.append(np.array(xyz))

    return np.array(traj)


# -------------------------------------------------
# 6. MAIN DRIVER
# -------------------------------------------------
def main():

    import argparse
    import sys
    from pathlib import Path

    parser = argparse.ArgumentParser()

    parser.add_argument("--psf", required=True)
    parser.add_argument("--pdb", required=True)
    parser.add_argument("--rtf", default=None)
    parser.add_argument("--prm", default=None)

    parser.add_argument("-o", "--output", default="md.npz")
    parser.add_argument("--steps", type=int, default=1000)
    parser.add_argument("--sample-every", type=int, default=10)

    args = parser.parse_args()

    # 1. load system
    load_system(args.psf, args.pdb, args.rtf, args.prm)

    # 2. dummy ASE object from PDB (only for coordinates)
    from ase.io import read
    atoms = read(args.pdb)

    # 3. run MD
    R = run_md(
        atoms,
        steps=args.steps,
        sample_every=args.sample_every,
    )

    # 4. save output
    np.savez_compressed(
        args.output,
        R=R,
    )

    print(f"Saved trajectory → {args.output}")


if __name__ == "__main__":
    main()
