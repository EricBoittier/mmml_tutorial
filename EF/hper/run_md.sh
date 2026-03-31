#mmml ef-md --help
data=out/splits_ef0_sim/energies_forces_dipoles_test.npz


#uuid=1be603a1-527e-4cb6-84bb-4b5f407c8288
uuid=a273c107-6d5e-4a1e-98bc-2191e8ac0c42
extra="4"


uuid=be95b0e3-5c84-45c7-add4-a026022f3baf
extra="0"

uuid=3ac6a95a-6f0b-4b00-8a78-ae2fc63de26c
extra="1"


uuid=714cc439-f4e9-4973-9af4-08098d9dd810
extra="2"

uuid=8a9ff4aa-0c48-4a8e-b8f4-504eae6276d7
extra=3


uuid=30b3a438-c568-4670-bc4c-0f4b78b655a4
extra="0ef0"
ell=0
params=/mmhome/boittier/home/ckpts/ef_run$ell/params-$uuid.json
mmml ef-md --params $params --data $data -b ase --dt 0.5 --n-replicas 10 --steps 2000000 --output md$extra.traj --temperature 100.0
