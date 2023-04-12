# bash script for running all steps
bash src/parameter_recovery.sh
bash src/model_recovery.sh
Rscript src/fit_models.r &> logs/fit_models.log &