### fit parameter recovery ###

# GCM
param_recov_gcm <- function(model_name, n_obs, n_features, type, w, c, seed = 101) {
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
  if (model_name == "gcm") {
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
  } else if (model_name == "gcm_fixed_c") {
    data <- list(
      ntrials = nrow(observations),
      nfeatures = ncol(observations),
      cat_one = danger,
      y = responses,
      obs = as.matrix(observations),
      b = .5, # no bias
      c = c,
      w_prior_values = rep(1, 5)
    )
  }

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

  # update name of weights
  colnames(draws_df) <- ifelse(
    grepl("[", colnames(draws_df), fixed = TRUE),
    paste(str_extract(colnames(draws_df), "\\w+"), "_",
      str_extract(colnames(draws_df), "\\d+"),
      sep = ""
    ),
    colnames(draws_df)
  )
  
  if (model_name == "gcm") {
    relevant_cols <- c("c", "c_prior")
  } else if (model_name == "gcm_fixed_c") {
    relevant_cols <- c()
  }
  for (colname in colnames(draws_df)) {
    if (grepl("w_", colname, fixed = TRUE)) {
      relevant_cols <- c(relevant_cols, colname)
    }
  }

  # make output df
  out_df <- draws_df %>%
    select(relevant_cols)
  out_df$c_parameter <- c
  out_df$w_parameter <- w
  out_df$nobservations <- n_obs

  return(out_df)
}


# Reinforcement Learning
param_recov_rl <- function(
                          model_name,
                          n_obs,
                          n_features, 
                          type, 
                          alpha_pos, 
                          alpha_neg, 
                          temp, 
                          seed = 101) {
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
  if (model_name == "rl") {
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
  } else if (model_name == "rl_simple") {
    data <- list(
      ntrials = nrow(observations),
      nfeatures = ncol(observations),
      cat_one = danger,
      y = responses,
      obs = as.matrix(observations),
      alpha_prior_values = c(0, 1),
      temp_prior_values = c(0, 1)
    )
  }

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

  # make ouput df
  if (model_name == "rl") {
    alpha_cols <- c("alpha_neg", "alpha_neg_prior",
                    "alpha_pos", "alpha_pos_prior")
  } else if (model_name == "rl_simple") {
    alpha_cols <- c("alpha", "alpha_prior")
  }
  
  relevant_cols <- c(alpha_cols, "temp", "temp_prior")

  out_df <- draws_df %>%
    select(relevant_cols)
  
  out_df$nobservations <- n_obs
  out_df$true_temp <- temp
  
  if (model_name == "rl") {
    out_df$true_alpha_pos <- alpha_pos
    out_df$true_alpha_neg <- alpha_neg
  } else if (model_name == "rl_simple") {
    out_df$true_alpha <- alpha_pos
  }

  return(out_df)
}
