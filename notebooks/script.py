from mmml.interfaces.dcmInterface import (
    run_kernel_fit_pipeline,
    fit_kernel_from_training_data,
    predict_charges_from_kernel,
    evaluate_and_write_h5,
    optimize_charge_positions,
)
fn = "/home/ericb/mmml_tutorial/cli/charmm_ml_comparison/charmm_ml_comparison.h5"

# Full pipeline (optional ESP-based optimization → kernel fit → CHARMM files + H5)
result = run_kernel_fit_pipeline(
    h5_path=fn,
    out_dir="kernel_out",
    out_h5="kernel_eval.h5",
    out_mdcm="meoh.mdcm",   # optional, default: kernel_out/MEOH.mdcm
    out_kmdcm="meoh.kmdcm", # optional, default: kernel_out/MEOH.kmdcm
    optimize_positions=True,
    residue_name="MEOH",
)

# result["out_mdcm_path"], result["out_kmdcm_path"]

import ase
from ase import io
import mmml
from mmml.interfaces.pycharmmInterface import import_pycharmm
import os
import sys
from pathlib import Path

from mmml.cli.make.make_res import main_loop
import argparse
import pycharmm



def main():
    args = argparse.Namespace(res="MEOH", skip_energy_show=True)
    print("=== 01: make_res programmatic ===")
    atoms = main_loop(args)
    print(f"Generated {len(atoms)} atoms")
    print("Output: pdb/initial.pdb, psf/initial.psf, xyz/initial.xyz, CHARMM topology files")


output =    main()


from pycharmm.coor import set_positions, get_positions

dcm_script = """
open unit 11 card read name meoh.mdcm
open unit 12 card read name meoh.kmdcm
open unit 99 write card name dcm.xyz
!DCM IUDCM 11 TSHIFT XYZ 99
DCM KERN 12 IUDCM 11 TSHIFT XYZ 99
"""
pycharmm.lingo.charmm_script(dcm_script)
pycharmm.lingo.charmm_script("ENER")
pycharmm.lingo.charmm_script("STOP")
