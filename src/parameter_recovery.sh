# gcm
Rscript src/parameter_recovery.r gcm 1 104 &> logs/param_recov_gcm_1_104.log &
Rscript src/parameter_recovery.r gcm 1 208 &> logs/param_recov_gcm_1_208.log &
Rscript src/parameter_recovery.r gcm 1 312 &> logs/param_recov_gcm_1_312.log &

# rl
Rscript src/parameter_recovery.r rl 1 104 &> logs/param_recov_rl_1_104.log &
Rscript src/parameter_recovery.r rl 1 208 &> logs/param_recov_rl_1_208.log &
Rscript src/parameter_recovery.r rl 1 312 &> logs/param_recov_rl_1_312.log &

# rl simple
Rscript src/parameter_recovery.r rl_simple 1 104 &> logs/param_recov_rl_simple_1_104.log &
Rscript src/parameter_recovery.r rl_simple 1 208 &> logs/param_recov_rl_simple_1_208.log &
Rscript src/parameter_recovery.r rl_simple 1 312 &> logs/param_recov_rl_simple_1_312.log &