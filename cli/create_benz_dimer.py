#!/usr/bin/env python

import numpy as np
import pycharmm
import pycharmm.lingo as lingo
import pycharmm.coor as coor


# -------------------------------------------------
# 1. LOAD FORCE FIELD (CRITICAL)
# -------------------------------------------------
def load_forcefield():

    print("***** Loading CGenFF force field *****")
    lingo.charmm_script(""" bomlev -2

    ! IMPORTANT: increase internal limits
    set maxdihe 50000
    set maximpr 50000""")

    lingo.charmm_script("""
    open read card unit 10 name toppar/top_all36_prot.rtf
read  rtf card unit 10

open read card unit 20 name toppar/par_all36m_prot.prm
read para card unit 20 flex
open read card unit 10 name toppar/top_all36_cgenff.rtf
read  rtf card unit 10 append

open read card unit 20 name toppar/par_all36_cgenff.prm
read para card unit 20 append flex """)

# -------------------------------------------------
# 2. BUILD BENZENE DIMER SYSTEM
# -------------------------------------------------
def build_benzene_dimer(distance=5.0):

    print("***** Building benzene dimer *****")

    lingo.charmm_script("""
    delete atom sele all end
    """)

    # create first benzene
    lingo.charmm_script("""
    read sequence string BENZ
    generate BENZ setup
    """)

    # create second benzene
    lingo.charmm_script("""
    read sequence string BENZ
    generate BENZ2 setup
    """)

    # build internal coordinates
    lingo.charmm_script("ic build")

    # separate dimers along x-axis
    lingo.charmm_script(f"""
    coor orient sele segid BENZ end
    coor translate xdir {distance}

    coor orient sele segid BENZ2 end
    coor translate xdir -{distance}
    """)

    # show system
    lingo.charmm_script("show atom")
    lingo.charmm_script("show bond")


# -------------------------------------------------
# 3. SETUP NBONDS
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
    """)


# -------------------------------------------------
# 4. MINIMIZATION
# -------------------------------------------------
def minimize():

    print("***** Minimization *****")

    lingo.charmm_script("""
    mini abnr nstep 300
    """)


# -------------------------------------------------
# 5. MD RUN
# -------------------------------------------------
def run_md(steps=1000, sample_every=10):

    print("***** Running MD *****")

    traj = []

    for i in range(steps):

        lingo.charmm_script("dyna step 1")

        if i % sample_every == 0:
            xyz = coor.get_positions()
            traj.append(np.array(xyz))

    return np.array(traj)


# -------------------------------------------------
# 6. SAVE SYSTEM
# -------------------------------------------------
def write_outputs():

    lingo.charmm_script("""
    write psf card name benz_dimer.psf
    write coor pdb name benz_dimer.pdb
    """)


# -------------------------------------------------
# 7. MAIN PIPELINE
# -------------------------------------------------
def main():

    print("***** BENZENE DIMER MD PIPELINE *****")

    # 1. force field
    load_forcefield()

    # 2. build system
    build_benzene_dimer(distance=5.0)

    # 3. save structure (PSF + PDB)
    write_outputs()

    # 4. prepare MD
    setup_nbonds()
    minimize()

    # 5. run MD
    R = run_md(steps=500, sample_every=5)

    # 6. save NPZ
    np.savez_compressed(
        "benzene_md.npz",
        R=R
    )

    print("Done → benzene_md.npz")


if __name__ == "__main__":
    main()
