#mmml ef-md --help
data=out/splits_ef/energies_forces_dipoles_test.npz

uuid=77635c90-7e76-4e8e-b9c5-3092b1b242f1
extra="0"
params=/mmhome/boittier/home/ckpts/ef_run$extra/params-$uuid.json
mmml ef-md --params $params --data $data -b ase --dt 0.5 --n-replicas 10 --temperature 200.0 --steps 2000000 --output md$extra.200.traj

uuid=83c9aa1b-65cb-4fcb-a22f-109e081adc7b
extra="1"
params=/mmhome/boittier/home/ckpts/ef_run$extra/params-$uuid.json
mmml ef-md --params $params --data $data -b ase --dt 0.5 --n-replicas 10 --temperature 200.0 --steps 2000000 --output md$extra.200.traj

uuid=d8c883c5-8266-4f26-a05d-6e7a8fcadb09
extra="2"
params=/mmhome/boittier/home/ckpts/ef_run$extra/params-$uuid.json
mmml ef-md --params $params --data $data -b ase --dt 0.5 --n-replicas 10 --temperature 200.0 --steps 2000000 --output md$extra.200.traj

uuid=38f21a4f-8ebc-4df3-bb62-0ef2328ff619
extra="3"
params=/mmhome/boittier/home/ckpts/ef_run$extra/params-$uuid.json
mmml ef-md --params $params --data $data -b ase --dt 0.5 --n-replicas 10 --temperature 200.0 --steps 2000000 --output md$extra.200.traj

uuid=62b7a42a-b5c2-4fab-bb62-4585055820d3
extra="4"
params=/mmhome/boittier/home/ckpts/ef_run$extra/params-$uuid.json
mmml ef-md --params $params --data $data -b ase --dt 0.5 --n-replicas 10 --temperature 200.0 --steps 2000000 --output md$extra.200.traj



