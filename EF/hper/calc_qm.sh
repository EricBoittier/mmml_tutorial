#mmml pyscf-evaluate -i interpolated.npz -o interpolated_evaluated.npz --esp
#mmml pyscf-evaluate -i interpolated.npz -o interpolated_evaluated_ef0.npz --EF --add-random-noise 0.05 --seed 42 --efield-sigma 0.0
mmml pyscf-evaluate -i sim.npz -o sim_evaluated_ef0.npz --EF --add-random-noise 0.05 --seed 42 --efield-sigma 0.0
