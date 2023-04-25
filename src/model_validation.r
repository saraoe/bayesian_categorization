## Model validation ##
## performance of models with different parameters

## libraries
library(pacman)
pacman::p_load(
    tidyverse
)

source("src/generative_models.r")
source("src/util.r")
set.seed("2018")

## input arguments
args <- commandArgs(trailingOnly = TRUE)

if (length(args) != 1) {
    stop("Input missing!", call. = FALSE)
}

model <- args[1]

## seed
set.seed("010309")

## simulate data
observations <- simulate_observations(
    n_obs = 104,
    n_features = 5,
    type = "binary"
)

true_category <- ifelse(observations$f1 == 1, 1, 0)

# Run models
if (model == "gcm") {
    c_parameters <- c(0.1, seq(from = 1, to = 5, length.out = 5))
    w_parameters <- c("1,0,0,0,0", "0.2,0.2,0.2,0.2,0.2", "0.5,0.5,0,0,0")

    for (c in c_parameters) {
        for (w in w_parameters) {
            responses <- gcm(
                w = as.numeric(str_split(w, ",")[[1]]),
                c = c,
                b = 0.5,
                ntrials = nrow(observations),
                obs = observations,
                cat_one = true_category
            )

            tmp <- tibble(
                response = responses,
                c = c,
                ws = w,
                trial = seq_len(nrow(observations)),
                true_cat = true_category
            )

            if (exists("out_df")) {
                out_df <- rbind(out_df, tmp)
            } else {
                out_df <- tmp
            }
        }
    }
} else if (model == "rl") {
    alpha_parameters <- seq(from = 0, to = 1, length.out = 4)
    temp_parameters <- c(0.1, 1, 2, 3)

    for (temp in temp_parameters) {
        for (alpha_pos in alpha_parameters) {
            for (alpha_neg in alpha_parameters) {
                responses <- reinforcement_learning(
                    alpha_pos = alpha_pos,
                    alpha_neg = alpha_neg,
                    temp = temp,
                    observations = observations,
                    cat_one = true_category
                )

                tmp <- tibble(
                    response = responses,
                    alpha_pos = alpha_pos,
                    alpha_neg = alpha_neg,
                    temp = temp,
                    trial = seq_len(nrow(observations)),
                    true_cat = true_category
                )

                if (exists("out_df")) {
                    out_df <- rbind(out_df, tmp)
                } else {
                    out_df <- tmp
                }
            }
        }
    }
} else if (model == "rl_simple") {
    alpha_parameters <- seq(from = 0.1, to = 1, length.out = 4)
    temp_parameters <- c(0.1, 1, 2, 3)

    for (temp in temp_parameters) {
        for (alpha in alpha_parameters) {
            responses <- reinforcement_learning(
                alpha_pos = alpha,
                alpha_neg = alpha,
                temp = temp,
                observations = observations,
                cat_one = true_category
            )

            tmp <- tibble(
                response = responses,
                alpha = alpha,
                temp = temp,
                trial = seq_len(nrow(observations)),
                true_cat = true_category
            )

            if (exists("out_df")) {
                out_df <- rbind(out_df, tmp)
            } else {
                out_df <- tmp
            }
        }
    }
}

# save csv
out_path <- paste(
    "data/recovery/model_validation_responses_",
    model, ".csv",
    sep = ""
)
write.csv(out_df, out_path)
print(
    paste("Responses for", model, "saved in", out_path)
)
print("Done!")
