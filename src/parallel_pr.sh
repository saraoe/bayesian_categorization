# gcm
Rscript parallel_pr.R gcm 1 104 binary &> ../logs/param_recov_gcm_1_104_binary &
Rscript parallel_pr.R gcm 1 208 binary &> ../logs/param_recov_gcm_1_208_binary &
Rscript parallel_pr.R gcm 1 312 binary &> ../logs/param_recov_gcm_1_312_binary &
Rscript parallel_pr.R gcm 1 104 continuous &> ../logs/param_recov_gcm_1_104_continuous &
Rscript parallel_pr.R gcm 1 208 continuous &> ../logs/param_recov_gcm_1_208_continuous &

# rl
Rscript parallel_pr.R rl 1 104 binary &> ../logs/param_recov_rl_1_104_binary &
Rscript parallel_pr.R rl 1 208 binary &> ../logs/param_recov_rl_1_208_binary &
Rscript parallel_pr.R rl 1 312 binary &> ../logs/param_recov_rl_1_312_binary &