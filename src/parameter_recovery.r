### Parallel Parameter Recovery ###

## INPUT ARGUMENTS ##
args <- commandArgs(trailingOnly = TRUE)

if (length(args) != 3) {
  stop("Input missing!", call. = FALSE)
}

# Get input arguments
model <- args[1]
index <- as.integer(args[2])
n_obs <- as.integer(args[3])
feature_type <- "binary"

# Get a random seed
seed <- sample(c(1:1000000), 1)
set.seed(seed)

print("--------------")
print(paste("Running", model, "with:"))
print(paste("Index =", index))
print(paste("N observations = ", n_obs))
print(paste("Seed =", seed))
print("--------------")

## PACKAGES AND FUNCTIONS ##
# libraries
library(pacman)
pacman::p_load(
  tidyverse,
  cmdstanr,
  posterior
)

# Load functions
source("src/fit_param_recov.r")
source("src/generative_models.r")
source("src/util.r")

## LOAD MODEL ##
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
  cpp_options = list(stan_threads = TRUE),
  # stanc_options = list("O1")
)
print("Done compiling!")

## RUN PARAMETER RECOVERY ##
print("--------------")
print("RUNNING PARAMETER RECOVERY")

if (model == "gcm") {
  # parameters
  c_parameters <- seq(from = 0, to = 2, length.out = 6)
  w_parameters <- c("1,0,0,0,0", "0.2,0.2,0.2,0.2,0.2")

  for (c in c_parameters) {
    for (w in w_parameters) {
      tmp <- param_recov_gcm(
        n_obs = n_obs,
        n_features = 5,
        type = feature_type,
        c = c,
        w = w,
        seed = seed
      )

      if (exists("recovery_df")) {
        recovery_df <- rbind(recovery_df, tmp)
      } else {
        recovery_df <- tmp
      }
    }
  }
}


if (model == "rl") {
  # parameters
  alpha_parameters <- seq(from = 0, to = 1, length.out = 4)
  temp_parameters <- seq(from = 0, to = 3, length.out = 4)

  for (alpha_pos in alpha_parameters) {
    for (alpha_neg in alpha_parameters) {
      for (temp in temp_parameters) {
        # trycatch to continue if sampling fails
        tryCatch(
          {
            tmp <- param_recov_rl(
              model_name = model,
              n_obs = n_obs,
              n_features = 5,
              type = feature_type,
              alpha_pos = alpha_pos,
              alpha_neg = alpha_neg,
              temp = temp,
              seed = seed
            )

            if (exists("recovery_df")) {
              recovery_df <- rbind(recovery_df, tmp)
            } else {
              recovery_df <- tmp
            }
          },
          error = function(e) {
            print(e)
            print("continuing")
          }
        )
      }
    }
  }
}

if (model == "rl_simple") {
  # parameters
  alpha_parameters <- seq(from = 0, to = 1, length.out = 4)
  temp_parameters <- seq(from = 0, to = 3, length.out = 4)

  for (alpha in alpha_parameters) {
    for (temp in temp_parameters) {
      # trycatch to continue if sampling fails
      tryCatch(
        {
          tmp <- param_recov_rl(
            model_name = model,
            n_obs = n_obs,
            n_features = 5,
            type = feature_type,
            alpha_pos = alpha,
            alpha_neg = alpha,
            temp = temp,
            seed = seed
          )

          if (exists("recovery_df")) {
            recovery_df <- rbind(recovery_df, tmp)
          } else {
            recovery_df <- tmp
          }
        },
        error = function(e) {
          print(e)
          print("continuing")
        }
      )
    }
  }
}


### SAVE RESULTS ##
save_path <- paste(
  "data/recovery/parameter_recovery_",
  model,
  "_",
  feature_type,
  n_obs,
  "_",
  index,
  ".csv",
  sep = ""
)
write.csv(recovery_df, save_path)

print("--------------")
print(paste("Results saved in:", save_path))
print("DONE")
