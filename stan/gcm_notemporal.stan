//
// Generalized Context Model (GCM)
// 
// NB: No temporal dimension - takes all stimuli into account
// NB: only works with two categories!
// NB: No multilevel modelling

data {
    int<lower=1> ntrials;  // number of trials
    int<lower=1> nfeatures;  // number of predefined relevant features
    array[ntrials] int<lower=0, upper=1> cat_one; // true responses on a trial by trial basis
    array[ntrials] int<lower=0, upper=1> y;  // decisions on a trial by trial basis
    array[ntrials, nfeatures] int<lower=0, upper=1> obs; // stimuli as vectors of features
    real<lower=0, upper=1> b;  // initial bias for category one over two

    // priors
    vector[nfeatures] w_prior_values;  // concentration parameters for dirichlet distribution <lower=1>
    array[2] int c_prior_values;  // mean and variance for logit-normal distribution
}

transformed data {
    array[ntrials] int<lower=0, upper=1> cat_two; // dummy variable for category two over cat 1
    array[sum(cat_one)] int<lower=1, upper=ntrials> cat_one_idx; // array of which stimuli are cat 1
    array[ntrials-sum(cat_one)] int<lower=1, upper=ntrials> cat_two_idx; //  array of which stimuli are cat 2
    int idx_one = 1; // Initializing 
    int idx_two = 1;
    for (i in 1:ntrials){
        cat_two[i] = abs(cat_one[i]-1);

        if (cat_one[i]==1){
            cat_one_idx[idx_one] = i;
            idx_one +=1;
        } else {
            cat_two_idx[idx_two] = i;
            idx_two += 1;
        }
    }
}

parameters {
    simplex[nfeatures] w;  // simplex means sum(w)=1
    real logit_c;
}

transformed parameters {
    // parameter c 
    real<lower=0, upper=5> c = inv_logit(logit_c)*5;  // times 5 as c is bounded between 0 and 5

    // parameter r (probability of response = category 1)
    array[ntrials] real<lower=0.0001, upper=0.9999> r;
    array[ntrials] real rr;

    for (i in 1:ntrials) {

        // calculate distance from obs to all exemplars
        array[ntrials] real exemplar_dist;
        for (e in 1:ntrials){
            array[nfeatures] real tmp_dist;
            for (j in 1:nfeatures) {
                tmp_dist[j] = w[j]*abs(obs[e,j] - obs[i,j]);
            }
            exemplar_dist[e] = sum(tmp_dist);
        }

        // calculate similarity
        array[2] real similarities;
        
        similarities[1] = exp(-c * sum(exemplar_dist[cat_one_idx]));
        similarities[2] = exp(-c * sum(exemplar_dist[cat_two_idx]));

        // calculate r[i]
        rr[i] = (b*similarities[1]) / (b*similarities[1] + (1-b)*similarities[2]);

        // to make the sampling work
        if (rr[i] > 0.9999){
            r[i] = 0.9999;
        } else if (rr[i] < 0.0001) {
            r[i] = 0.0001;
        } else if (rr[i] > 0.0001 && rr[i] < 0.9999) {
            r[i] = rr[i];
        } else {
            r[i] = 0.5;
        }
    }
}

model {
    // Priors
    target += dirichlet_lpdf(w | w_prior_values);
    target += normal_lpdf(logit_c | c_prior_values[1], c_prior_values[2]);
    
    
    // Decision Data
    target += bernoulli_lpmf(y | r);
}

generated quantities {
    // priors
    simplex[nfeatures] w_prior = dirichlet_rng(w_prior_values);
    real logit_c_prior = normal_rng(c_prior_values[1], c_prior_values[2]);
    real<lower=0, upper=5> c_prior = inv_logit(logit_c_prior)*5;

}
