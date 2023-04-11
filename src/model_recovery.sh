Rscript src/model_recovery.r gcm 1 104 &> logs/model_recovery_gcm_1.log &
Rscript src/model_recovery.r gcm 2 104 &> logs/model_recovery_gcm_2.log &
Rscript src/model_recovery.r gcm 3 104 &> logs/model_recovery_gcm_3.log &

Rscript src/model_recovery.r rl 1 104 &> logs/model_recovery_rl_1.log &
Rscript src/model_recovery.r rl 2 104 &> logs/model_recovery_rl_2.log &
Rscript src/model_recovery.r rl 3 104 &> logs/model_recovery_rl_3.log &

Rscript src/model_recovery.r rl_simple 1 104 &> logs/model_recovery_rl_simple_1.log &
Rscript src/model_recovery.r rl_simple 2 104 &> logs/model_recovery_rl_simple_2.log &
Rscript src/model_recovery.r rl_simple 3 104 &> logs/model_recovery_rl_simple_3.log &