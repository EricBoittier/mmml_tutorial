#!/usr/bin/env python
"""
Example: PhysNet MD sampling (ASE + JAX-MD) via mmml CLI.

Run from project root: bash examples/mmml_tutorial/cli/13_physnet_md.sh
Requires: Step 09 run first (PhysNet checkpoint in cli/out/ckpts/cybz_physnet/).
"""

from pathlib import Path
import sys


def main():
    script_dir = Path(__file__).resolve().parent
    base_dir = script_dir.parent
    ckpt_dir = base_dir / "cli" / "out" / "ckpts" / "cybz_physnet"
    data_path = base_dir / "cli" / "out" / "splits" / "energies_forces_dipoles_train.npz"
    output_dir = script_dir / "out"

    if not ckpt_dir.exists():
        print(f"Error: PhysNet checkpoint not found: {ckpt_dir}")
        print("Run step 09 first: bash examples/mmml_tutorial/cli/09_physnet_train_cli.sh")
        return 1

    if not data_path.exists():
        print(f"Error: Training data not found: {data_path}")
        print("Run steps 06–08 first to create splits.")
        return 1

    from mmml.cli.misc import physnet_md

    sys.argv = [
        "mmml",
        "physnet-md",
        "--checkpoint",
        str(ckpt_dir),
        "--data",
        str(data_path),
        "-o",
        str(output_dir),
    ]
    return physnet_md.main()


if __name__ == "__main__":
    sys.exit(main())
