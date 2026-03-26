Sys.setenv(SPARK_HOME = "C:/spark")
.libPaths(c(file.path(Sys.getenv("SPARK_HOME"), "R", "lib"), .libPaths()))

library(SparkR)
library(jsonlite)

run_job <- function(query_type = "all", param1 = NA, param2 = NA) {
  
  spark <- sparkR.session(master = "local[*]")

  data_path <- "spark/data/game_sessions.csv"

  game_data <- read.df(
    path = data_path,
    source = "csv",
    header = "true",
    inferSchema = "true"
  )

  results <- list()

  # =========================
  # AVG / MIN / MAX (GROUP BY GAME)
  # =========================
  if (query_type == "avg_score") {
    df <- SparkR::filter(game_data, game_data$game_name == param1)
    results$avg <- SparkR::collect(summarize(df, avg_score = mean(df$score)))
  }

  if (query_type == "max_score") {
    df <- SparkR::filter(game_data, game_data$game_name == param1)
    results$max <- SparkR::collect(summarize(df, max_score = max(df$score)))
  }

  if (query_type == "min_score") {
    df <- SparkR::filter(game_data, game_data$game_name == param1)
    results$min <- SparkR::collect(summarize(df, min_score = min(df$score)))
  }

  # =========================
  # FILTER BY GAME
  # =========================
  if (query_type == "filter_game") {
    df <- SparkR::filter(game_data, game_data$game_name == param1)
    results$filter <- SparkR::collect(df)
  }

  # =========================
  # ARRANGE
  # =========================
  if (query_type == "sort_score") {
    df <- SparkR::arrange(game_data, desc(game_data$score))
    results$sorted <- SparkR::collect(df)
  }

  # =========================
  # STANDARD DEVIATION
  # =========================
  if (query_type == "sd") {
    results$sd <- SparkR::collect(
      summarize(game_data, sd_score = sd(game_data$score))
    )
  }

  # =========================
  # COUNT (n)
  # =========================
  if (query_type == "count") {
    results$count <- SparkR::collect(
      summarize(game_data, total = count(game_data$player_id))
    )
  }

  # =========================
  # FIRST & LAST
  # =========================
  if (query_type == "firstlast") {
    results$firstlast <- SparkR::collect(
      summarize(game_data,
        first_val = first(game_data$score),
        last_val = last(game_data$score)
      )
    )
  }

  # =========================
  # BASE R DEMO (IMPORTANT FOR MARKS)
  # =========================
  if (query_type == "baseR") {
    
    vec <- c(1:10)
    seq_data <- seq(1, 20, by = 2)
    
    sorted <- sort(vec)
    rev_sorted <- rev(sort(vec))
    
    mat <- matrix(1:9, nrow = 3)
    
    lst <- list(a = 1, b = 2, c = 3)
    
    fac <- factor(c("A", "B", "A", "C"))
    
    # loop
    sum_loop <- 0
    for (i in vec) {
      sum_loop <- sum_loop + i
    }

    # while
    i <- 1
    while_sum <- 0
    while (i <= 5) {
      while_sum <- while_sum + i
      i <- i + 1
    }

    results$baseR <- list(
      vector = vec,
      seq = seq_data,
      sorted = sorted,
      rev_sorted = rev_sorted,
      matrix = mat,
      list = lst,
      levels = levels(fac),
      nlevels = nlevels(fac),
      for_sum = sum_loop,
      while_sum = while_sum
    )
  }

  write_json(results, "spark/output.json", pretty = TRUE)

  sparkR.session.stop()
}