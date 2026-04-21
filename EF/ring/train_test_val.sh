#mmml fix-and-split --efd interpolated_evaluated.npz --output-dir out/splits --atomic-ref pbe0/def2-tzvp
#mmml fix-and-split --efd interpolated_evaluated_ef.npz sim_evaluated_ef.npz --output-dir out/splits_ef_sim --atomic-ref pbe0/def2-tzvp #--flip-forces 
mmml fix-and-split --efd interpolated_evaluated_ef0.npz sim_evaluated_ef0.npz --output-dir out/splits_ef0_sim --atomic-ref pbe0/def2-tzvp #--flip-forces 


