# Data for Bayesian Categorization project

## Organization
````
├── data 
│   ├── recovery                <- csv-files from model and parameter recovery
│   │   └── ...
│   ├── AlienData.csv           <- empirical data
│   ├── rl_*_samples.csv        <- samples from rl model fitted to AlienData
│   ├── rl_simple*_samples.csv  <- samples from rl simple model fitted to AlienData
│   ├── gcm_*_samples.csv       <- samples from gcm model fitted to AlienData
│   ├── model_comparison_pointwise_*.csv <- pointwise loo estimates
│   └── model_comparison_compare_*.csv       <- output from loo compare
````

## Alien data
Data collected in experiment where participants categorized Aliens as dangerous/not-dangerous and notrious/non-notriuous in a 2x2 design. Participants did so either individually or in pairs (Tylén, Fusaroli, Smith, & Arnoldi, 2020). 

**Columns in data:**
- "condition": dyad or individual condition (correspondingly, 1 or 2)
- "subject": Subject ID
- "session": Session ID (1,2,3)
- "cycle": Number of cycle in training (all stimuli was shown three times, i.e. three cycles).
- "trial": Trial ID
- "test": test or training (boolean)
- "stimulus": jpg-name for the stimulus. Includes the values of the features in the name.
- "category": correct category
- "response": response category (category chosen by the participant)
- "dangerous": dangerous or not (boolean)
- "nutricious": nutricious or not (boolean)
- "correct": correct response or not, i.e. response==category (boolean)
- "cumulative": cumulative score (+100 correct, -100 incorrect)
- "RT": reaction time
- "motivation", "competence": participants rating their motivation and competence during the task
- "communication", "complement": participants rating communication and complement if they were in pairs

## Samples
The sampled values from fitting the models on the empirical data are called ```[model name]_[session number]_samples.csv```. Thus, the file ```gcm_1_samples.csv``` are the samples from fitting the GCM model to the data in the first session. The models are fitted using the script ``src/fit_models.r``. The models only uses one category, and it has been fitted to *nutricious* over *dangerous* as this category were more balanced in the empiracal data.

## Model Comparison
The data output for model comparison are divided into two distinct files: 
- ```model_comparison_pointwise_[session number].csv```: Contains the pointwise estimates from fitting loo, e.g. elpd and Parekto k values.
- ```model_comparison_compare_[session number].csv```: Contains the output of comparing the three models after being fitted on each participant, thus, the LOOIC values.

## Recovery
Output of models in simulation conditions for model and parameter recovery. 

### Parameter Recovery
The models have been run on either simulated feautures that are binary or continuous between 0 and 1, or the emperical data. The categorization rules were manually specified so the category depended on the value of features 1 and 2 only, thus, resembling a low complexity condition.

The files a named as follows ``parameter_recovery_[model name]_[data type][n observations]_[index].csv``. Thus, the files ``parameter_recovery_gcm_binary104_1.csv`` includes samples from parameter recovery of the GCM model using simulated binary features and 104 trials. The index allows for multiple runs with identical arguments but new seed.

*Explanation of files that were run before systematic naming:*
| file name | model | data | n observations | n participants |
| --- | --- | --- | --- | --- | 
| parameter_recovery_gcm_aliendata.csv | ``stan/gcm.stan`` | Alien data | 104 | 1 | 
| parameter_recovery_gcm_binary208.csv | ``stan/gcm.stan`` | Binary data | 208 | 1 | 
| parameter_recovery_gcm_continuous208.csv | ``stan/gcm.stan`` | Continuous data | 208 | 1 | 
| parameter_recovery_rl_300.csv | ``stan/reinforcement_learning.stan`` | Binary data | 300 | 1 | 

### Model Recovery
The data output for model recovery are divided into two distinct files: 
- ```model_recovery_loo_pointwise_[true model]_[index].csv```: Contains the pointwise estimates from fitting loo, e.g. elpd and Parekto k values.
- ```model_recovery_loo_compare_[true model]_[index].csv```: Contains the output of comparing the three models after being fitted on each participant, thus, the LOOIC values.

The ``true model`` in the model names, indicate which model generated the data. For each index, new parameter values were sampled.


## References
Tylén, K., Fusaroli, R., Smith, P., & Arnoldi, J. (2020, August). The social route to abstraction: interaction and diversity enhance performance and transfer in a rule-based categorization task.