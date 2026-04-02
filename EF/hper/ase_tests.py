import ase
import numpy as np
from ase import io
from ase.constraints import FixInternals
from ase.optimize import BFGS
from mmml.models.EF.ase_calc_EF import AseCalculatorEF

uuid = "bce45991-ffe5-4f4b-b4c6-1d6584a809e0"
uuid = "cc27f596-4003-470f-b119-3218f6c9abad"
PARAMS = f"/mmhome/boittier/home/ckpts/ef_run0/params-{uuid}.json"
CONFIG = f"/mmhome/boittier/home/ckpts/ef_run0/config-{uuid}.json"

PARAMS = f"/mmhome/boittier/home/ckpts/ef0_run1/params-{uuid}.json"
CONFIG = f"/mmhome/boittier/home/ckpts/ef0_run1/config-{uuid}.json"

#uuid = "a273c107-6d5e-4a1e-98bc-2191e8ac0c42"
PARAMS = f"/mmhome/boittier/home/ckpts/ef_run4/params-{uuid}.json"
CONFIG = f"/mmhome/boittier/home/ckpts/ef_run4/config-{uuid}.json"

uuid = "bce45991-ffe5-4f4b-b4c6-1d6584a809e0"
uuid = "451cfa65-55ac-4c90-a0a3-afb57bc3cc44"


PARAMS = f"/mmhome/boittier/home/ckpts/ef_run1/params-{uuid}.json"
CONFIG = f"/mmhome/boittier/home/ckpts/ef_run1/config-{uuid}.json"

uuid = "bce45991-ffe5-4f4b-b4c6-1d6584a809e0"
uuid = "30b3a438-c568-4670-bc4c-0f4b78b655a4"



PARAMS = f"/mmhome/boittier/home/ckpts/ef_run0/params-{uuid}.json"
CONFIG = f"/mmhome/boittier/home/ckpts/ef_run0/config-{uuid}.json"

uuid="714cc439-f4e9-4973-9af4-08098d9dd810"
PARAMS = f"/mmhome/boittier/home/ckpts/ef_run2/params-{uuid}.json"
CONFIG = f"/mmhome/boittier/home/ckpts/ef_run2/config-{uuid}.json"

uuid="8a9ff4aa-0c48-4a8e-b8f4-504eae6276d7"
PARAMS = f"/mmhome/boittier/home/ckpts/ef_run3/params-{uuid}.json"
CONFIG = f"/mmhome/boittier/home/ckpts/ef_run3/config-{uuid}.json"



EF = [0.01, 0.01, 0.01]
EF = [-0.01, -0.01, -0.01]
EFs = [[0.0, 0.0, 0.0],
[-0.01, -0.01, -0.01],
[-0.02, -0.02, -0.02],
[0.01, 0.01, 0.01],
[0.02, 0.02, 0.02]
        ]


for EF in EFs:
    calc = AseCalculatorEF(
        PARAMS,
        config_path=CONFIG,
        electric_field=EF,  # optional default field (model input units)
        field_scale=100,  # E_physical [au] = E_input * field_scale
    )
    print(calc)
    atoms = ase.io.read("hper_a.xyz")
    atoms.calc = calc
    
    E = atoms.get_potential_energy()
    print(E)
    print(atoms)
    
    print(atoms.get_atomic_numbers())
    
    bond_indices1 = [[2, 0], [0, 1], [1, 3]]
    dihedral_indices1 = [2, 0, 1, 3]
    
    bonds1 = [[atoms.get_distance(*_), _] for _ in bond_indices1]
    
    energies = []
    forces = []
    positions = []
    angles = []
    
    filenames = []
    
    start = atoms.get_dihedral(*dihedral_indices1)
    thetas = np.arange(start - 30, start + 390, 1)
    
    from tqdm import tqdm
    for file in ["hper_a.xyz", "hper_b.xyz"]:
        for theta in tqdm(thetas):
            atoms = ase.io.read(file)
            atoms.calc = calc
        
            dihedral1 = [
                # atoms.get_dihedral(*dihedral_indices1),
                theta,
                dihedral_indices1,
            ]
        
            c = FixInternals(
                bonds=bonds1, angles_deg=None, dihedrals_deg=[dihedral1], bondcombos=None
            )
            atoms.set_constraint(c)
            try:
                dyn = BFGS(atoms, trajectory=f"bfgs.traj")
                dyn.run(fmax=0.005)
                e = atoms.get_potential_energy()
                f = atoms.get_forces()
                energies.append(e)
                forces.append(f)
                positions.append(atoms.get_positions())
                angles.append(theta)
                filenames.append(file)
            except:
                pass
            del atoms.constraints
        
    import pandas as pd
    
    data_dict = {"E": energies, "F": forces, "R": positions, "phi": angles, "fn": filenames, "EF": [EF for _ in range(len(energies))]}
    
    
    df = pd.DataFrame(data_dict)
    
    df.to_csv(f"dih_scan_{uuid}_{EF}.csv")
