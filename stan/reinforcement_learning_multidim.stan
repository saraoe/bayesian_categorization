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
  matrix[2, nfeatures] initValues;  // initial value
  initValues = rep_matrix(0, 2, nfeatures);

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
    matrix[2, nfeatures] values;
    vector[nfeatures] value_sum;
    real theta;
    int f_val;

    // priors
    target += normal_lpdf(logit_alpha | alpha_prior_values[1], alpha_prior_values[2]);
    
    values = initValues; 
    
    for (t in 1:ntrials){  // loop over each trial
        for (f in 1:nfeatures){
            f_val = obs[t, f]+1;
            value_sum[f] = values[f_val, f];

            pe = feedback[t] - values[f_val, f];
            values[f_val, f] = values[f_val, f] + alpha*pe;  //only update value for the observed feature
        }

        theta = inv_logit(sum(value_sum));
        target += bernoulli_lpmf(y[t] | theta);
    
    }
}

generated quantities {
   real logit_alpha_prior = normal_rng(alpha_prior_values[1], alpha_prior_values[2]);
   real alpha_prior = inv_logit(logit_alpha_prior);
}
