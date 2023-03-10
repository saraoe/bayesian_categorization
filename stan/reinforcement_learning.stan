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
    array[2] real alpha_neg_prior_values;
    array[2] real alpha_pos_prior_values;
    array[2] real temp_prior_values;
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
    real logit_alpha_neg;
    real logit_alpha_pos;
    real logit_temp;
}

transformed parameters {
    // alpha parameters
   real<lower=0, upper=1> alpha_neg = inv_logit(logit_alpha_neg);
   real<lower=0, upper=1> alpha_pos = inv_logit(logit_alpha_pos);
   // temperature parameter
   real<lower=0, upper=20> temp = inv_logit(logit_temp)*20;  // upper bound is 20
}

model {
    real pe;
    real alpha;
    matrix[2, nfeatures] values;
    vector[nfeatures] value_sum;
    real theta;
    int f_val;

    // priors
    target += normal_lpdf(logit_alpha_neg | alpha_neg_prior_values[1], alpha_neg_prior_values[2]);
    target += normal_lpdf(logit_alpha_pos | alpha_pos_prior_values[1], alpha_pos_prior_values[2]);
    target += normal_lpdf(logit_temp | temp_prior_values[1], temp_prior_values[2]);
    
    values = initValues; 
    
    for (t in 1:ntrials){  // loop over each trial
        for (f in 1:nfeatures){
            f_val = obs[t, f]+1;
            value_sum[f] = values[f_val, f];

            pe = feedback[t] - values[f_val, f];

            if (feedback[t]==-1){
                alpha = alpha_neg;
            } else if (feedback[t]==1){
                alpha = alpha_pos;
            }
            values[f_val, f] = values[f_val, f] + alpha*pe;  //only update value for the observed feature
        }

        theta = inv_logit(temp * sum(value_sum));
        target += bernoulli_lpmf(y[t] | theta);
    
    }
}

generated quantities {
    // priors
   real logit_alpha_neg_prior = normal_rng(alpha_neg_prior_values[1], alpha_neg_prior_values[2]);
   real<lower=0, upper=1> alpha_neg_prior = inv_logit(logit_alpha_neg_prior);

   real logit_alpha_pos_prior = normal_rng(alpha_pos_prior_values[1], alpha_pos_prior_values[2]);
   real<lower=0, upper=1> alpha_pos_prior = inv_logit(logit_alpha_pos_prior);

   real logit_temp_prior = normal_rng(temp_prior_values[1], temp_prior_values[2]);
   real<lower=0, upper=20> temp_prior = inv_logit(logit_temp_prior)*20;
}
