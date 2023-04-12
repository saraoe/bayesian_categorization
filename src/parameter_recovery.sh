# gcm
Rscript src/parameter_recovery.r gcm 1 104 binary &> logs/param_recov_gcm_1_104_binary.log &
Rscript src/parameter_recovery.r gcm 1 208 binary &> logs/param_recov_gcm_1_208_binary.log &
Rscript src/parameter_recovery.r gcm 1 312 binary &> logs/param_recov_gcm_1_312_binary.log &
Rscript src/parameter_recovery.r gcm 1 104 continuous &> logs/param_recov_gcm_1_104_continuous.log &
Rscript src/parameter_recovery.r gcm 1 208 continuous &> logs/param_recov_gcm_1_208_continuous.log &

# rl
Rscript src/parameter_recovery.r rl 1 104 binary &> logs/param_recov_rl_1_104_binary.log &
Rscript src/parameter_recovery.r rl 1 208 binary &> logs/param_recov_rl_1_208_binary.log &
Rscript src/parameter_recovery.r rl 1 312 binary &> logs/param_recov_rl_1_312_binary.log &

Rscript src/parameter_recovery.r rl_simple 1 104 binary &> logs/param_recov_rl_simple_1_104_binary.log &
Rscript src/parameter_recovery.r rl_simple 1 208 binary &> logs/param_recov_rl_simple_1_208_binary.log &
Rscript src/parameter_recovery.r rl_simple 1 312 binary &> logs/param_recov_rl_simple_1_312_binary.log &