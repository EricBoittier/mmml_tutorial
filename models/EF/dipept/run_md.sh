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
uuid=9ae5fddb-f1b2-4ab4-953b-c3f7f97d3639
extra="0ef0"
ell=0
uuid=bce45991-ffe5-4f4b-b4c6-1d6584a809e0
extra="0"

#uuid=451cfa65-55ac-4c90-a0a3-afb57bc3cc44
#ell=1
#extra="1ef0"

#uuid=cc27f596-4003-470f-b119-3218f6c9abad

uuid=1b81054f-fdbd-46ef-8c2e-e7308a557727
ell=4
uuid=30f50bc2-43db-4a6b-b692-098fbc00bd06
params=/mmhome/boittier/home/ckpts/ef_run$ell/params-best-$uuid.json
#params=/mmhome/boittier/home/ckpts/ef0_run$ell/params-$uuid.json
data=out/splits_ef_sim/energies_forces_dipoles_test.npz

mmml ef-md --params $params --data $data -b ase --dt 0.5 --n-replicas 1 --steps 2000000 --output md$extra.traj #--temperature 100.0
