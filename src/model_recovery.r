### Model Recovery ###

# libraries
library(pacman)
pacman::p_load(
    tidyverse,
    cmdstanr,
    posterior,
    loo
)

# load functions
source("src/generative_models.r")
source("src/util.r")


## INPUT ARGUMENTS ##
args <- commandArgs(trailingOnly = TRUE)

if (length(args) != 3) {
    stop("Input missing!", call. = FALSE)
}

# Get input arguments
true_model <- args[1]
index <- as.integer(args[2])
n_obs <- as.integer(args[3])

# Get a random seed
seed <- sample(c(1:1000000), 1)
set.seed(seed)

print("--------------")
print(paste("Running true", true_model, "with:"))
print(paste("Index =", index))
print(paste("N observations = ", n_obs))
print(paste("Seed =", seed))
print("--------------")

## Simulate Observations ##
observations <- simulate_observations(
    n_obs,
    n_features = 5,
    type = "binary"
)
danger <- ifelse(observations$f1 == 1 & observations$f2 == 1, 1, 0)

## Parameters and Simulate responses ##
print("True parameters:")
if (true_model == "gcm") {
    c <- runif(1, min = 0.1, max = 2)
    print(paste("c =", c))
    w <- rep(1 / 5, 5)
    print(paste("w =", w))

    responses <- gcm(
        w = w,
        c = c,
        b = 0.5,
        ntrials = n_obs,
        obs = observations,
        cat_one = danger
    )
} else if (true_model == "rl") {
    alpha_pos <- runif(1, min = 0.1, max = 0.5)
    print(paste("alpha_pos =", alpha_pos))
    alpha_neg <- runif(1, min = 0.5, max = 0.9)
    print(paste("alpha_neg =", alpha_neg))
    temp <- runif(1, min = 0.1, max = 3)
    print(paste("temperature =", temp))

    responses <- reinforcement_learning(
        alpha_pos = alpha_pos,
        alpha_neg = alpha_neg,
        temp = temp,
        observations = observations,
        cat_one = danger
    )
} else if (true_model == "rl_simple") {
    alpha <- runif(1, min = 0.1, max = 0.9)
    print(paste("alpha =", alpha))
    temp <- runif(1, min = 0.1, max = 3)
    print(paste("temperature =", temp))

    responses <- reinforcement_learning(
        alpha_pos = alpha,
        alpha_neg = alpha,
        temp = temp,
        observations = observations,
        cat_one = danger
    )
}
print("--------------")


## Load and Fit Models ##

for (model in c("gcm", "rl", "rl_simple")) {
    print(paste("Now fitting", model))

    # compile model
    set_cmdstan_path("/work/MA_thesis/cmdstan-2.31.0")
    if (model == "gcm") {
        file <- file.path("src/stan/gcm.stan")
    } else if (model == "rl") {
        file <- file.path("src/stan/reinforcement_learning.stan")
    } else if (model == "rl_simple") {
        file <- file.path("src/stan/reinforcement_learning_simple.stan")
    }
    mod <- cmdstan_model(
        file,
        cpp_options = list(stan_threads = TRUE)
    )

    if (model == "gcm") {
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
    } else if (model == "rl") {
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
    } else if (model == "rl_simple") {
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

    # loo
    samples_loo <- samples$loo(save_psis = TRUE, cores = 4)
    assign(paste(model, "_loo", sep = ""), samples_loo)

    tmp <- as.data.frame(samples_loo$pointwise)
    tmp$model <- model
    tmp$index <- index
    tmp$true_model <- true_model
    if (exists("loo_output_df")) {
        loo_output_df <- rbind(loo_output_df, tmp)
    } else {
        loo_output_df <- tmp
    }
}

### Save LOO Output ###
print("--------------")
output_path <- paste(
    "data/recovery/model_recovery_loo_pointwise_",
    true_model, "_", index, ".csv",
    sep = ""
)
write.csv(loo_output_df, output_path)
print(paste("loo pointwise file save in", output_path))

print("Compare:")
compare <- loo_compare(gcm_loo, rl_loo, rl_simple_loo)
print(compare)

compare <- as.data.frame(compare)
compare$true_model <- true_model
compare$index <- index
output_path <- paste(
    "data/recovery/model_recovery_loo_compare_",
    true_model, "_", index, ".csv",
    sep = ""
)
write.csv(compare, output_path)
print(paste("loo pointwise file save in", output_path))

print("DONE!")
