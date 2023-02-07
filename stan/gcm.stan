//
// Generalized Context Model (GCM)
// 
// NB: only works with two categories!
// NB: No multilevel modelling

data {
    int<lower=1> ntrials;
    int<lower=1> nfeatures;
    array[ntrials] int<lower=0, upper=1> cat_one;
    array[ntrials] int<lower=0, upper=1> y;  // true reponses
    array[ntrials, nfeatures] int<lower=0, upper=1> obs;
    real<lower=0, upper=2> b;  // bias for category one over two

    // priors
    vector<lower=1>[nfeatures] w_prior_values;  // concentration parameters for dirichlet distribution
    array[2] int c_prior_values;  // mean and variance for logit-normal distribution
}

transformed data {
    array[ntrials] int<lower=0, upper=1> cat_two;
    array[sum(cat_one)] int<lower=1, upper=ntrials> cat_one_idx;
    array[ntrials-sum(cat_one)] int<lower=1, upper=ntrials> cat_two_idx;

    int idx_one = 1;
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
    array[ntrials] real<lower=0, upper=1> r;

    for (i in 1:ntrials) {

        // calculate distance from obs to all exemplars
        array[(i-1)] real exemplar_dist;
        for (e in 1:(i-1)){
            array[nfeatures] real tmp_dist;
            for (j in 1:nfeatures) {
                tmp_dist[j] = w[j]*abs(obs[e,j] - obs[i,j]);
            }
            exemplar_dist[e] = sum(tmp_dist);
        }

        if (sum(cat_one[:(i-1)])==0 || sum(cat_two[:(i-1)])==0){  // if there are no examplars in one of the categories
            r[i] = 0.5;

        } else {
            // calculate similarity
            array[2] real similarities;
            
            array[sum(cat_one[:(i-1)])] int tmp_idx_one = cat_one_idx[:sum(cat_one[:(i-1)])];
            array[sum(cat_two[:(i-1)])] int tmp_idx_two = cat_two_idx[:sum(cat_two[:(i-1)])];
            similarities[1] = exp(-c * sum(exemplar_dist[tmp_idx_one]));
            similarities[2] = exp(-c * sum(exemplar_dist[tmp_idx_two]));

            // calculate r[i]
            r[i] = (b*similarities[1]) / (b*similarities[1] + (1-b)*similarities[2]);
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

   // prior pred
    array[ntrials] real<lower=0, upper=1> r_prior;
    for (i in 1:ntrials) {

        // calculate distance from obs to all exemplars
        array[(i-1)] real exemplar_dist;
        for (e in 1:(i-1)){
            array[nfeatures] real tmp_dist;
            for (j in 1:nfeatures) {
                tmp_dist[j] = w_prior[j]*abs(obs[e,j] - obs[i,j]);
            }
            exemplar_dist[e] = sum(tmp_dist);
        }

        if (sum(cat_one[:(i-1)])==0 || sum(cat_two[:(i-1)])==0){  // if there are no examplars in one of the categories
            r_prior[i] = 0.5;

        } else {
            // calculate similarity
            array[2] real similarities;
            
            array[sum(cat_one[:(i-1)])] int tmp_idx_one = cat_one_idx[:sum(cat_one[:(i-1)])];
            array[sum(cat_two[:(i-1)])] int tmp_idx_two = cat_two_idx[:sum(cat_two[:(i-1)])];
            similarities[1] = exp(-c_prior * sum(exemplar_dist[tmp_idx_one]));
            similarities[2] = exp(-c_prior * sum(exemplar_dist[tmp_idx_two]));

            // calculate r[i]
            r_prior[i] = (b*similarities[1]) / (b*similarities[1] + (1-b)*similarities[2]);
        }
    }

    array[ntrials] int<lower=0, upper=1> priorpred = bernoulli_rng(r_prior);


   // posterior pred
   array[ntrials] int<lower=0, upper=1> posteriorpred = bernoulli_rng(r);

}
