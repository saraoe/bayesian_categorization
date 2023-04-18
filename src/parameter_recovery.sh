# gcm
Rscript src/parameter_recovery.r gcm 1 104 binary &> logs/param_recov_gcm_1_104_binary.log &
Rscript src/parameter_recovery.r gcm 1 208 binary &> logs/param_recov_gcm_1_208_binary.log &
Rscript src/parameter_recovery.r gcm 1 312 binary &> logs/param_recov_gcm_1_312_binary.log &

# rl
Rscript src/parameter_recovery.r rl 1 104 binary &> logs/param_recov_rl_1_104_binary.log &
Rscript src/parameter_recovery.r rl 1 208 binary &> logs/param_recov_rl_1_208_binary.log &
Rscript src/parameter_recovery.r rl 1 312 binary &> logs/param_recov_rl_1_312_binary.log &

# rl simple
Rscript src/parameter_recovery.r rl_simple 1 104 binary &> logs/param_recov_rl_simple_1_104_binary.log &
Rscript src/parameter_recovery.r rl_simple 1 208 binary &> logs/param_recov_rl_simple_1_208_binary.log &
Rscript src/parameter_recovery.r rl_simple 1 312 binary &> logs/param_recov_rl_simple_1_312_binary.log &