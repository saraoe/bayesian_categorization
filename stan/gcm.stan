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
    //vector<lower=0, upper=1>[nfeatures] prior_w_mean;
    //vector<lower=0, upper=1>[nfeatures] prior_w_var;
    //real<lower=0> prior_c_mean;
    //real<lower=0> prior_c_var;
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
    vector<lower=0, upper=1>[nfeatures] w;
    real<lower=0> c;
}

transformed parameters {
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

        if (i==3 || sum(cat_one[:(i-1)])==0 || sum(cat_two[:(i-1)])==0){  // if there are no examplars in one of the categories
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
    // fix this - add custom priors
    // Prior
    target += beta_lpdf(w | 1, 1);
    // Missing a prior for c
    target += beta_lpdf(c | 1, 1); //Figure out how to bound at 0-5
    
    
    // Decision Data
    target += binomial_lpmf(y | ntrials, r);
}
