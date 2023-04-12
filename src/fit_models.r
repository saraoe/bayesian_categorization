### Fit models ###

# libraries
library(pacman)
pacman::p_load(
    tidyverse,
    cmdstanr,
    posterior,
    loo
)

# input arguments
args <- commandArgs(trailingOnly = TRUE)

if (length(args) != 1) {
    stop("wrong number of inputs!", call. = FALSE)
}

# Get input arguments
ses <- args[1]

print(paste("Fitting Models on Session", ses))
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
        nutricious_response = ifelse(response == 2 | response == 4, 1, 0)
    ) %>%
    filter(
        session == ses
    ) %>%
    mutate( # make unique subject ids
        subject = ifelse(condition == 2,
            subject + 100,
            subject
        )
    )

for (sub in unique(df$subject)) {
    print(paste("Subject =", sub))

    for (model in c("gcm", "rl", "rl_simple")) {
        print(paste("Fitting", model))

        # load model
        print("Compiling model")
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
        print("Done compiling!")

        # filter data
        tmp <- df %>%
            filter(
                subject == sub,
                session == ses
            )
        observations <- tmp %>%
            select(
                c("f1", "f2", "f3", "f4", "f5")
            )

        # input data for model
        if (model == "gcm") {
            data <- list(
                ntrials = nrow(observations),
                nfeatures = ncol(observations),
                cat_one = tmp$nutricious,
                y = tmp$nutricious_response,
                obs = as.matrix(observations),
                b = .5, # no bias
                w_prior_values = rep(1, 5),
                c_prior_values = c(0, 1)
            )
        } else if (model == "rl") {
            data <- list(
                ntrials = nrow(observations),
                nfeatures = ncol(observations),
                cat_one = tmp$nutricious,
                y = tmp$nutricious_response,
                obs = as.matrix(observations),
                alpha_neg_prior_values = c(0, 1),
                alpha_pos_prior_values = c(0, 1),
                temp_prior_values = c(0, 1)
            )
        } else if (model == "rl_simple") {
            data <- list(
                ntrials = nrow(observations),
                nfeatures = ncol(observations),
                cat_one = tmp$nutricious,
                y = tmp$nutricious_response,
                obs = as.matrix(observations),
                alpha_prior_values = c(0, 1),
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

        # save draws
        tmp_draws_df <- as_draws_df(samples$draws())
        tmp_draws_df$condition <- ifelse(sub > 100, 2, 1)
        tmp_draws_df$subject <- sub
        tmp_draws_df$session <- ses
        tmp_draws_df$model <- model
        
        name_draws_df <- paste(model, "_draws_df", sep = "")
        if (exists(name_draws_df)) {
            assign(
                name_draws_df,
                rbind(eval(parse(text = name_draws_df)),
                      tmp_draws_df)
            )
        } else {
            assign(
                name_draws_df,
                tmp_draws_df
            )
        }

        # save loo
        samples_loo <- samples$loo(save_psis = TRUE, cores = 3)
        assign(paste(model, "_loo", sep = ""), samples_loo)

        tmp_loo <- as.data.frame(samples_loo$pointwise)
        tmp_loo$model <- model
        if (exists("loo_df")) {
            loo_df <- rbind(loo_df, tmp_loo)
        } else {
            loo_df <- tmp_loo
        }
    }

    # compare loo
    print("Compare:")
    compare <- loo_compare(gcm_loo, rl_loo, rl_simple_loo)
    print(compare)

    compare <- as.data.frame(compare)
    compare$condition <- ifelse(sub > 100, 2, 1)
    compare$subject <- sub
    compare$session <- ses

    if (exists("compare_df")) {
        compare_df <- rbind(compare_df, compare)
    } else {
        compare_df <- compare
    }
}
print("------------")

# write results
for (model in c("gcm", "rl", "rl_simple")) {
    out_path <- paste("data/", model, "_", ses, "_samples.csv", sep = "")
    model_draws_df <- eval(parse(text = paste(model, "_draws_df", sep = "")))
    write.csv(model_draws_df, out_path)
    print(paste(model, "draws_df written to path:", out_path))
}

out_path <- paste("data/model_comparison_pointwise", "_", ses, ".csv", sep = "")
write.csv(loo_df, out_path)
print(paste("Loo pointwise df written to path:", outpath))

out_path <- paste("data/model_comparison_compare", "_", ses, ".csv", sep = "")
write.csv(compare_df, out_path)
print(paste("Loo compare df written to path:", outpath))

print("DONE!")
