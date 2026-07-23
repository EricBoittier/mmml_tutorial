#mmml fix-and-split --efd interpolated_evaluated.npz --output-dir out/splits --atomic-ref pbe0/def2-tzvp
#mmml fix-and-split --efd interpolated_evaluated_ef.npz sim_evaluated_ef.npz --output-dir out/splits_ef_sim --atomic-ref pbe0/def2-tzvp #--flip-forces 
#mmml fix-and-split --efd qP_samples/*ef0*npz --output-dir out/splits_ef0_ring --atomic-ref pbe0/def2-tzvp #--flip-forces 
mmml fix-and-split --efd qP_samples/*ef1*npz --output-dir out/splits_ef1_ring --atomic-ref pbe0/def2-tzvp #--flip-forces 
mmml fix-and-split --efd qP_samples/*ef*npz --output-dir out/splits_ef_ring --atomic-ref pbe0/def2-tzvp #--flip-forces 


