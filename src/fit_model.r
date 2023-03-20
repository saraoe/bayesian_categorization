### Fit models ###

# libraries
library(pacman)
pacman::p_load(
    tidyverse,
    cmdstanr,
    posterior
)

# input arguments
args <- commandArgs(trailingOnly = TRUE)

if (length(args) != 1) {
    stop("wrong number of inputs!", call. = FALSE)
}

# Get input arguments
model <- args[1] 

print(paste("Fitting", model))
print("------------")

# load data
df <- read_csv("data/AlienData.csv") %>%
    mutate( # add feature values
        f1 = as.numeric(substr(stimulus, 1, 1)),
        f2 = as.numeric(substr(stimulus, 2, 2)),
        f3 = as.numeric(substr(stimulus, 3, 3)),
        f4 = as.numeric(substr(stimulus, 4, 4)),
        f5 = as.numeric(substr(stimulus, 5, 5)),
        danger_response = ifelse(response == 3 | response == 4, 1, 0),
        nutri_response = ifelse(response == 2 | response == 4, 1, 0)
    ) %>%
    filter( # include only conditions with individuals and low complexity session
        condition == 1 & session == 1
    )


# load model
print("Compiling model")
if (model == "gcm") {
    file <- file.path("src/stan/gcm.stan")
} else if (model == "rl") {
    file <- file.path("src/stan/reinforcement_learning.stan")
}
mod <- cmdstan_model(
    file,
    cpp_options = list(stan_threads = TRUE)
)
print("Done compiling!")

print("Fitting model")
for (sub in unique(df$subject)) {
    print(paste("Subject =", sub))

    # filter data
    tmp <- df %>%
        filter(subject == sub)
    observations <- tmp %>%
        select(
            c("f1", "f2", "f3", "f4", "f5")
        )

    # input data for model
    if (model == "gcm") {
        print("script can run with GCM yet")
    } else if (model == "rl") {
        data <- list(
            ntrials = nrow(observations),
            nfeatures = ncol(observations),
            cat_one = tmp$nutricious,
            y = tmp$nutri_response,
            obs = as.matrix(observations),
            alpha_neg_prior_values = c(0, 1),
            alpha_pos_prior_values = c(0, 1),
            temp_prior_values = c(0, 1)
        )
    }


    # sample model
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

    # save results
    draws_df <- as_draws_df(samples$draws())
    draws_df$subject <- sub

    if (exists("output_df")) {
        output_df <- rbind(output_df, draws_df)
    } else {
        output_df <- draws_df
    }
}
print("------------")

# write results
out_path <- paste("data/", model, "_samples.csv", sep = "")
write.csv(output_df, out_path)
print("output_df written to path:", out_path)
print("DONE")
