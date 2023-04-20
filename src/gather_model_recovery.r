## Gather model recovery files ##

library(pacman)
pacman::p_load(
  tidyverse
)

# load data
true_models <- c("gcm", "rl", "rl_simple")

for (true_model in true_models) {
  tmp_compare <- read_csv(paste(
    "data/recovery/model_recovery_loo_compare_",
    true_model, ".csv", sep = ""
  ))
  
  if (exists("compare_df")) {
    compare_df <- rbind(compare_df, tmp_compare)
  } else {
    compare_df <- tmp_compare
  }
  
  tmp_pointwise <- read_csv(paste(
    "data/recovery/model_recovery_loo_pointwise_",
    true_model, ".csv", sep = ""
  )) %>%
    group_by(index, model) %>%
    mutate(
      trial = seq_len(104)
    )
  
  if (exists("pointwise_df")) {
    pointwise_df <- rbind(pointwise_df, tmp_pointwise)
  } else {
    pointwise_df <- tmp_pointwise
  }
}

# write files
write.csv(pointwise_df, "data/recovery/model_recovery_pointwise.csv")
write.csv(compare_df, "data/recovery/model_recovery_compare.csv")