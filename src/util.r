### Util functions ###

# GCM 
distance <- function(vect1, vect2, w){
    return (sum(w * abs(vect1 - vect2)))
} 

similarity <- function(distance, c) {
    return (exp( -c * distance))
}

gcm <- function(w, c, b, ntrials, obs, cat_one) {

    r <- c()
    for (i in 1:ntrials){
        if (i%%10==0){
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

