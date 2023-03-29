### Util functions ###

# simulate data
binary_observations <- function(n_obs, n_features) {
    observations <- dplyr::tibble(
        f1 = sample(c(0, 1), replace = TRUE, size = n_obs)
    )
    if (n_features > 1) {
        for (i in 2:n_features) {
            tmp <- sample(c(0, 1), replace = TRUE, size = n_obs)
            eval(parse(
                text = paste("observations$f", i, " <- tmp", sep = "")
            ))
        }
    }
    return(observations)
}

continuous_observations <- function(n_obs, n_features, range = c(0, 1)) {
    observations <- dplyr::tibble(
        f1 = runif(n = n_obs, min = range[1], max = range[2])
    )
    for (i in 2:n_features) {
        tmp <- runif(n = n_obs, min = range[1], max = range[2])
        eval(parse(
            text = paste("observations$f", i, " <- tmp", sep = "")
        ))
    }
    return(observations)
}

simulate_observations <- function(n_obs, n_features, type) {
    if (type == "binary") {
        return(binary_observations(n_obs, n_features))
    }

    if (type == "continuous") {
        return(continuous_observations(n_obs, n_features))
    }
}
