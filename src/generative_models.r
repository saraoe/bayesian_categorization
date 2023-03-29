### generative models ###

# GCM
distance <- function(vect1, vect2, w) {
  return(sum(w * abs(vect1 - vect2)))
}

similarity <- function(distance, c) {
  return(exp(-c * distance))
}

gcm <- function(w, c, b, ntrials, obs, cat_one, quiet = TRUE) {
  r <- c()
  for (i in 1:ntrials) {
    if (!quiet && i %% 10 == 0) {
      print(paste("i =", i))
    }

    if (i == 1 || sum(cat_one[1:(i - 1)]) == 0 || sum(cat_one[1:(i - 1)]) == (i - 1)) {
      r <- c(r, .5)
    } else {
      similarities <- c()
      for (e in 1:(i - 1)) {
        sim <- similarity(distance(obs[i, ], obs[e, ], w), c)
        similarities <- c(similarities, sim)
      }

      numerator <- b * sum(similarities[cat_one[1:(i - 1)] == 1])
      denominator <- b * sum(similarities[cat_one[1:(i - 1)] == 1]) + (1 - b) * sum(similarities[cat_one[1:(i - 1)] == 0])
      r <- c(r, numerator / denominator)
    }
  }

  return(rbinom(ntrials, 1, r))
}


# Reinforcement learning
reinforcement_learning <- function(alpha_pos, alpha_neg, temp, observations, cat_one) {
  ntrials <- nrow(observations)
  nfeatures <- ncol(observations)

  values <- matrix(0, nrow = 2, ncol = nfeatures)
  responses <- c()
  for (t in 1:ntrials) {
    value_sum <- 0
    for (f in 1:nfeatures) {
      # value for feature
      f_val <- as.integer(observations[t, f]) + 1
      value_sum <- value_sum + values[f_val, f]
    }
    # response
    response <- rbinom(1, 1, prob = boot::inv.logit(temp * value_sum))
    feedback <- ifelse(cat_one[t] == 1, 1, -1)
    # feedback <- cat_one[t] - boot::inv.logit(temp * value_sum)
    responses <- c(responses, response)

    for (f in 1:nfeatures) {
      # update values
      f_val <- as.integer(observations[t, f]) + 1
      alpha <- ifelse(feedback == 1, alpha_pos, alpha_neg)
      values[f_val, f] <- values[f_val, f] + alpha * (feedback - values[f_val, f])
    }
  }
  return(responses)
}
