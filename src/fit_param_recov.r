### fit parameter recovery ###

# GCM
param_recov_gcm <- function(n_obs, n_features, type, w, c, seed=100){
  set.seed(seed)
  
  print(paste("c =", c))
  print(paste("w = ", w))
  print(paste("n_obs: ", n_obs, ", n_features: ", n_features, ", type: ", type))
  
  # simulate data
  observations <- simulate_observations(n_obs, n_features, type)
  
  # make own simple categorization rule
  # f1 + f2 determines danger (resembles low complexity)
  if (type == "binary") {
    danger <- ifelse(observations$f1 == 1 & observations$f2 == 1, 1, 0)
  } else if (type == "continuous") {
    danger <- ifelse(observations$f1 > .5 & observations$f2 > .5, 1, 0)
  }
  
  # calculate responses
  responses <- gcm(
                   #w = as.list(strsplit(w, ",")[[1]]), 
                   w = c(1,0,0,0,0),
                   c = c,
                   b = .5,
                   ntrials = nrow(observations),
                   obs = observations,
                   cat_one = danger
  )
  
  # prepare data and run model
  data <- list(
    ntrials = nrow(observations),
    nfeatures = ncol(observations),
    cat_one = danger,
    y = responses,
    obs = as.matrix(observations),
    b = .5, # no bias
    w_prior_values = rep(1, 5),
    c_prior_values = c(0, 1)
  )
  
  samples <- mod$sample(
    data = data,
    seed = 123,
    chains = 2,
    parallel_chains = 2,
    threads_per_chain = 2,
    iter_warmup = 1000,
    iter_sampling = 2000,
    refresh = 1000,
    max_treedepth = 20,
    adapt_delta = 0.99
  )
  
  draws_df <- as_draws_df(samples$draws())
  draws_df$c_parameter <- c
  draws_df$w <- w
  
  return(draws_df)
}
