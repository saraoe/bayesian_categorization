# Data for Bayesian Categorization project

## Organization
````
├── data 
│   ├── recovery        <- csv-files from model and parameter recovery
│   │   └── ...
│   └── AlienData.csv   <- csv-file with empirical data
````

## Alien data
Data collected in experiment where participants categorized Aliens as dangerous/not-dangerous and notrious/non-notriuous in a 2x2 design. Participants did so either individually or in pairs (Tylén, Fusaroli, Smith, & Arnoldi, 2020). 

**Columns in data:**
- "condition": individual or pair condition (correspondingly, 1 or 2)
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

## Recovery
Output of models in simulation conditions for model and parameter recovery. 

### Parameter Recovery
The models have been run on either simulated feautures that are binary or continuous between 0 and 1, or the emperical alien data. The categorization rules were manually specified so dangerous depended on the value of features 1 and 2 only, thus, resembling a low complexity condition.

| file name | model | data | n observations | n participants |
| --- | --- | --- | --- | --- | 
| parameter_recovery_gcm_aliendata.csv | ``stan/gcm.stan`` | Alien data | 104 | 1 | 
| parameter_recovery_gcm_binary208.csv | ``stan/gcm.stan`` | Binary data | 208 | 1 | 
| parameter_recovery_gcm_continuous208.csv | ``stan/gcm.stan`` | Continuous data | 208 | 1 | 
| parameter_recovery_rl_300.csv | ``stan/reinforcement_learning.stan`` | Binary data | 300 | 1 | 


## References
Tylén, K., Fusaroli, R., Smith, P., & Arnoldi, J. (2020, August). The social route to abstraction: interaction and diversity enhance performance and transfer in a rule-based categorization task.