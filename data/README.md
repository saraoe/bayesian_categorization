# Data for Bayesian Categorization project

## Organization
````
├── data 
│   ├── recovery        <- csv-files from model and parameter recovery
│   │   └── ...
│   └── AlienData.csv   <- csv-file with empirical data
````

### Alien data
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

### Recovery
Output of models in simulation conditions for model and parameter recovery.

**parameter_recovery_gcm_aliendata.csv**: Parameter recovery of the GCM model (``stan/gcm.stan``) using the aliendata as stimuli (i.e. 104 trials). Only using one participant. The categorization rule was manually specified as dangerous if (f1==1 and f2==1), thus, resembling a low complexity condition.

**parameter_recovery_RL_binarydata.csv**: Parameter recovery of the reinforcement learning model (``stan/reinforcement_learning_multidim.stan``) using simulated binary data. Only using one participant. Fitted to multiple number of observations (between 104-520 trials). The categorization rule was manually specified as dangerous if (f1==1 and f2==1), thus, resembling a low complexity condition.

### References
Tylén, K., Fusaroli, R., Smith, P., & Arnoldi, J. (2020, August). The social route to abstraction: interaction and diversity enhance performance and transfer in a rule-based categorization task.