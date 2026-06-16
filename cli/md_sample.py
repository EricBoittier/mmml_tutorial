import numpy as np
import os

os.environ["CHARMM_DIMENS"] = "chsize 2000000 maxres 200000"

import pycharmm
import pycharmm.lingo as lingo
import pycharmm.generate as gen
import pycharmm.ic as ic
import pycharmm.coor as coor
import pycharmm.energy as energy
import pycharmm.dynamics as dyn
import pycharmm.write as write


def load_forcefield(rtf, prm):
      
    lingo.charmm_script(f"""
bomlev -2
! core force field
open read card unit 10 name toppar/top_all36_cgenff.rtf
read rtf card unit 10

! ONLY small molecule parameters (not full cgenff)
open read card unit 20 name benz_1.prm
read param card unit 20 flex


bomlev 0
""")


def build_benzene_dimer():

    print("***** Creating PSF *****")

    lingo.charmm_script("""
read sequence BENZ 2
generate BENZ setup
""")

    print("***** Loading coordinates from PDB *****")

    lingo.charmm_script("""
read coor pdb name ligandrm.pdb
""")

    # sanity check
    lingo.charmm_script("show coor")
    energy.show()


def run_md(steps=2000, sample_every=10):

    print("***** Running MD *****")

    lingo.charmm_script("""
nbonds atom vatom cutnb 14 ctofnb 12 ctonnb 10
""")

    dyn_script = f"""
dynamics leap start nstep {steps} timestep 0.001 -
  firstt 300 finalt 300 tbath 300 -
  iasvel maxwell -
  nprint {sample_every}
"""

    lingo.charmm_script(dyn_script)

    traj = []

    for i in range(steps // sample_every):
        xyz = coor.get_positions().to_numpy()
        traj.append(xyz.copy())

    return np.array(traj)


def main():

    load_forcefield("toppar/top_all36_cgenff.rtf", "toppar/par_all36_cgenff.prm")

    build_benzene_dimer()

    # save psf + pdb
    write.psf_card("benz_dimer.psf")
    write.coor_pdb("benz_dimer.pdb")

    R = run_md()

    np.savez("benz_md.npz", R=R)

    print("Saved benz_md.npz")
    print("shape:", R.shape)


if __name__ == "__main__":
    main()
