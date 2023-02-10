### Util functions ###

# simulate data
binary_observations <- function(n_obs, n_features){
    observations <- tibble(
        f1 = sample(c(0,1), replace=TRUE, size=n_obs)
        )
    for (i in 2:n_features){
        tmp <- sample(c(0,1), replace=TRUE, size=n_obs)
        eval(parse(
            text = paste("observations$f", i, " <- tmp", sep="")
        ))
    }
    return (observations)
}

continuous_observations <- function(n_obs, n_features, range=c(0,1)){
    observations <- tibble(
        f1 = runif(n=n_obs, min=range[1], max=range[2])
        )
    for (i in 2:n_features){
        tmp <- runif(n=n_obs, min=range[1], max=range[2])
        eval(parse(
            text = paste("observations$f", i, " <- tmp", sep="")
        ))
    }
    return (observations)
}

simulate_observations <- function(n_obs, n_feature, type){
    if (type=="binary"){
        return (binary_observations(n_obs, n_features))
    }

    if (type=="continuous"){
        return (continuous_observations(n_obs, n_features))
    }
}

# GCM 
distance <- function(vect1, vect2, w){
    return (sum(w * abs(vect1 - vect2)))
} 

similarity <- function(distance, c) {
    return (exp( -c * distance))
}

gcm <- function(w, c, b, ntrials, obs, cat_one, quiet=T) {

    r <- c()
    for (i in 1:ntrials){
        if (!quiet & i%%10==0){
            print(paste('i =', i))
        }
        
        if (i==1 | sum(cat_one[1:(i-1)])==0 | sum(cat_one[1:(i-1)])==(i-1) ){
            r = c(r,.5)

        } else {
            similarities <- c()
            for (e in 1:(i-1)) {
                sim = similarity(distance(obs[i,], obs[e,], w), c)
                similarities <- c(similarities, sim)
            }

            numerator <- b*sum(similarities[cat_one[1:(i-1)]==1])
            denominator <- b*sum(similarities[cat_one[1:(i-1)]==1]) + (1-b)*sum(similarities[cat_one[1:(i-1)]==0])
            r = c(r, numerator/denominator )
        }

    }

    return (rbinom(ntrials, 1, r))
}

