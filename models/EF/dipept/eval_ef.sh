
data=out/splits_ef0_sim/energies_forces_dipoles_test.npz 

#uuid=d8c883c5-8266-4f26-a05d-6e7a8fcadb09
#extra="2"
#params=/mmhome/boittier/home/ckpts/ef_run$extra/params-$uuid.json
#mmml ef-evaluate --params $params --data $data --output-dir ./ef_eval$extra --output-h5 ./ef_eval$extra/out.h5 
#
#uuid=83c9aa1b-65cb-4fcb-a22f-109e081adc7b
#extra="1"
#params=/mmhome/boittier/home/ckpts/ef_run$extra/params-$uuid.json
#mmml ef-evaluate --params $params --data $data --output-dir ./ef_eval$extra --output-h5 ./ef_eval$extra/out.h5 
#
#uuid=77635c90-7e76-4e8e-b9c5-3092b1b242f1
#extra="0"
#params=/mmhome/boittier/home/ckpts/ef_run$extra/params-$uuid.json
#mmml ef-evaluate --params $params --data $data --output-dir ./ef_eval$extra --output-h5 ./ef_eval$extra/out.h5 

#uuid=38f21a4f-8ebc-4df3-bb62-0ef2328ff619
#extra="3"
#params=/mmhome/boittier/home/ckpts/ef_run$extra/params-$uuid.json
#mmml ef-evaluate --params $params --data $data --output-dir ./ef_eval$extra --output-h5 ./ef_eval$extra/out.h5 
#
#uuid=62b7a42a-b5c2-4fab-bb62-4585055820d3
uuid=a273c107-6d5e-4a1e-98bc-2191e8ac0c42
extra="4"

uuid=be95b0e3-5c84-45c7-add4-a026022f3baf
extra="0"

uuid=714cc439-f4e9-4973-9af4-08098d9dd810
extra=2

uuid=8a9ff4aa-0c48-4a8e-b8f4-504eae6276d7
extra=3

uuid=30b3a438-c568-4670-bc4c-0f4b78b655a4
extra=0
params=/mmhome/boittier/home/ckpts/ef_run$extra/params-$uuid.json
mmml ef-evaluate --params $params --data $data --output-dir ./ef0_eval$extra --output-h5 ./ef0_eval$extra/out.h5 

