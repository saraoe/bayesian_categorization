// 
// Rescorla-Wagner Reinforcement Learning
// 
// NB: Only works with binary features
// NB: Only works with two categories!
// NB: No multilevel modelling

data {
    int<lower=1> ntrials;
    int<lower=1> nfeatures;
    array[ntrials] int<lower=0, upper=1> cat_one;
    array[ntrials] int<lower=0, upper=1> y;  // true reponses
    array[ntrials, nfeatures] int<lower=0, upper=1> obs;

    //priors
    array[2] real alpha_prior_values;
}

transformed data {
  vector[2] initValues;  // initial value
  initValues = rep_vector(0.5, 2);

  array[ntrials] int<lower=-1, upper=1> feedback;
  for (t in 1:ntrials){
    if (cat_one[t]==y[t]){
        feedback[t] = 1;
    } else {
        feedback[t] = -1;
    }
  }
}

parameters {
    real logit_alpha;
}

transformed parameters {
    // alpha parameter
   real<lower=0, upper=1> alpha = inv_logit(logit_alpha);
}

model {
    real pe;
    vector[2, nfeatures] values;
    real theta;
    int f;

    // priors
    target += normal_lpdf(logit_alpha | alpha_prior_values[1], alpha_prior_values[2]);
    
    values = initValues; 
    
    for (t in 1:ntrials){  // loop over each trial
        f = obs[t]+1;
        theta = inv_logit(values[f]);
        target += bernoulli_lpmf(y[t] | theta);
      
        pe = feedback[t] - values[f];
        values[f] = values[f] + alpha*pe;  //only update value for the chosen category
    
    }
}

generated quantities {
   real logit_alpha_prior = normal_rng(alpha_prior_values[1], alpha_prior_values[2]);
   real alpha_prior = inv_logit(logit_alpha_prior);
}