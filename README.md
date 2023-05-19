# Bayesian Categorization

The ability to form categories is essential for understanding external input and plays an important role in human reasoning and decision-making. Many studies of categorization have focused on modeling categorization performed by individuals however literature investigating groups performing this task is sparse. Humans are social beings, thus, it would be relevant to investigate how categorization are performed during social interactions. In this thesis, we want to extend and evaluate the generalized context model (GCM; Nosofsky, 1986) and models using reinforcement learning on empirical data of interpersonal categorization. 

## Project Organization

````
├── README.md                   <- The top-level README for this project.
├── logs
├── data                        <- all data (empirical, simulated, samples)                    
├── src 
│   ├── stan                    <- stan scripts
│   ├── model_validation.sh  
│   ├── parameter_recovery.sh  
│   ├── model_recovery.sh  
│   ├── fit_models.sh   
│   └── ... 
├── res                         <- rmd-files for results and plots
├── figs                        <- figures
````

## Reproduce results
Clone the repository
````
git clone https://github.com/saraoe/bayesian_categorization.git
cd bayesian_categorization
````

Before running any of the bash scripts:
- Install r-packages ``cmdstanr`` and run ``cmdstanr::install_cmdstanr(dir = "../")`` in an r-script
- Install r-packages ``pacman``, ``tidyverse``, ``loo``, and ``DirichletReg``
- Make directory for logs by running ``mkdir logs`` in a bash terminal

To reproduce all the results run
```
bash run.sh
```

To reproduce parts of the analysis:
- To reproduce model validation run:
``
bash src/model_validation.sh
``

- To reproduce parameter recovery run:
``
bash src/parallel_pr.sh
``

- To reproduce model comparison run:
``
bash src/model_comparison.sh
``

- To reproduce sampling using empirical data run:
``
bash src/fit_models.sh
``
