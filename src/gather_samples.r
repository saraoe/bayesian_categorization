## gather samples ##

# load packages
library(pacman)
pacman::p_load(
  tidyverse
)

source("src/util.r")

# relevant columns
relevant_col_names <- function(model_name) {
  if (model_name == "gcm") {
    relevant_cols <- c(
      "c", "c_prior",
      ".iteration", ".chain",
      "condition", "subject", "session"
    )

    for (f in seq_len(5)) {
      weight <- paste("w[", f, "]", sep = "")
      weight_prior <- paste("w_prior[", f, "]", sep = "")
      relevant_cols <- c(
        relevant_cols,
        weight, weight_prior
      )
    }
  } else if (model_name == "rl") {
    relevant_cols <- c(
      "alpha_neg", "alpha_neg_prior",
      "alpha_pos", "alpha_pos_prior",
      "temp", "temp_prior",
      ".iteration", ".chain",
      "condition", "subject", "session"
    )
  } else if (model_name == "rl_simple") {
    relevant_cols <- c(
      "alpha", "alpha_prior",
      "temp", "temp_prior",
      ".iteration", ".chain",
      "condition", "subject", "session"
    )
  }

  # add posterior correct
  for (t in seq_len(104)) {
    colname <- paste("posteriorcorrect[", t, "]", sep = "")
    relevant_cols <- c(relevant_cols, colname)
  }
  return(relevant_cols)
}


# loop though samples
models <- c("gcm", "rl", "rl_simple")
sessions <- c(1, 2, 3)

for (model in models) {
  relevant_cols <- relevant_col_names(model)
  for (ses in sessions) {
    tmp_draws_df <- read_csv(
      paste("data/", model, "_", ses, "_samples.csv", sep = "")
    ) %>%
      select(relevant_cols) %>%
      mutate(
        session = ses
      )

    if (exists("draws_df")) {
      draws_df <- rbind(draws_df, tmp_draws_df)
    } else {
      draws_df <- tmp_draws_df
    }
  }
  # update colnames
  colnames(draws_df) <- update_colnames(draws_df)

  # save df
  out_path <- paste("data/", model, "_samples.csv", sep = "")
  write.csv(draws_df, out_path)
  print(paste(model, "draws_df written to path:", out_path))

  rm(draws_df)
}
