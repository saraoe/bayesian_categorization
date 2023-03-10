### fit parameter recovery ###

# GCM
param_recov_gcm <- function(n_obs, n_features, type, w, c, seed = 101) {
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
    w = as.numeric(str_split(w, ",")[[1]]),
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

  set_cmdstan_path("/work/MA_thesis/cmdstan-2.31.0")
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
  draws_df$w_parameter <- w
  draws_df$nobservations <- n_obs

  return(draws_df)
}


# Reinforcement Learning
param_recov_rl <- function(n_obs, n_features, type, alpha_pos, alpha_neg, temp, seed = 101) {
  set.seed(seed)

  print(paste("alpha_pos =", alpha_pos))
  print(paste("alpha_neg =", alpha_neg))
  print(paste("temp = ", temp))
  print(paste("n_obs: ", n_obs, ", n_features: ", n_features, ", type: ", type))

  # simulate data
  observations <- simulate_observations(n_obs, n_features, type)

  # make own simple categorization rule
  # f1 + f2 determines danger (resembles low complexity)
  danger <- ifelse(observations$f1 == 1 & observations$f2 == 1, 1, 0)

  # calculate responses
  responses <- reinforcement_learning(
    alpha_pos = alpha_pos,
    alpha_neg = alpha_neg,
    temp = temp,
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
    alpha_neg_prior_values = c(0, 1),
    alpha_pos_prior_values = c(0, 1),
    temp_prior_values = c(0, 1)
  )

  set_cmdstan_path("/work/MA_thesis/cmdstan-2.31.0")
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
  
  out_df <- tibble(
    alpha_neg = draws_df$alpha_neg,
    alpha_pos = draws_df$alpha_pos,
    alpha_neg_prior = draws_df$alpha_neg_prior,
    alpha_pos_propr = draws_df$alpha_pos_prior,
    temp = draws_df$temp,
    temp_prior = draws_df$temp_prior
  )
  out_df$true_alpha_pos <- alpha_pos
  out_df$true_alpha_neg <- alpha_neg
  out_df$nobservations <- n_obs
  out_df$true_temp <- temp

  return(out_df)
}
