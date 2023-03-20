# Bayesian Categorization

The ability to form categories is essential for understanding external input and plays an important role in human reasoning and decision-making. Many studies of categorization have focused on modeling categorization performed by individuals however literature investigating groups performing this task is sparse. Humans are social beings, thus, it would be relevant to investigate how categorization are performed during social interactions. In this thesis, we want to extend and evaluate the generalized context model (GCM; Nosofsky, 1986) on empirical data of interpersonal categorization. 

## Project Organization

````
├── README.md           <- The top-level README for this project.
├── logs
├── data                <- emprical data, samples, and parameter recovery                     
├── src 
│   ├── stan            <- stan scripts
│   ├── parallel_pr.sh  <- parameter recovery
│   ├── fit_models.sh   <- fit models to data
│   └── ... 
├── vis                 <- rmd-files for visualizations
├── figs                <- figures
````

## Reproduce results
Firstly, clone the repository
````
git clone https://github.com/saraoe/bayesian_categorization.git
````
````
cd bayesian_categorization
````
*NB: Then make a folder in ``bayesian_categorization/`` called ``logs`` before running the bash scripts*

To reproduce parameter recovery run
```` 
bash src/parallel_pr.sh
````

To reproduce sampling using empirical data run
```` 
bash src/fit_models.sh
````