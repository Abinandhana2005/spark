#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(sparklyr)
  library(dplyr)
  library(jsonlite)
})

# -----------------------------
# Paths and Spark initialization
# -----------------------------
args <- commandArgs(trailingOnly = TRUE)

query_name <- if (length(args) >= 1) args[[1]] else ""
param1 <- if (length(args) >= 2) args[[2]] else NA_character_
param2 <- if (length(args) >= 3) args[[3]] else NA_character_

`%||%` <- function(a, b) if (!is.null(a)) a else b

# Resolve script directory safely under Rscript.
script_file_arg <- commandArgs(trailingOnly = FALSE)
script_file <- sub("^--file=", "", script_file_arg[grepl("^--file=", script_file_arg)][1] %||% "")

if (!nzchar(script_file)) {
  script_file <- file.path(getwd(), "spark", "run_stats_sparklyr.R")
}

script_dir <- normalizePath(dirname(script_file), winslash = "/", mustWork = FALSE)
if (!grepl("/spark$", script_dir)) {
  script_dir <- normalizePath(file.path(getwd(), "spark"), winslash = "/", mustWork = FALSE)
}

data_path <- file.path(script_dir, "data", "game_sessions.csv")
output_dir <- file.path(script_dir, "output")
if (!dir.exists(output_dir)) dir.create(output_dir)

output_path <- file.path(output_dir, paste0(query_name, ".json"))

safe_number <- function(x, default = 0) {
  n <- suppressWarnings(as.numeric(x))
  ifelse(is.na(n), default, n)
}

to_result <- function(tbl) {
  if (is.data.frame(tbl)) {
    return(tbl)
  }
  as.data.frame(collect(tbl), stringsAsFactors = FALSE)
}

build_base_r_section <- function() {
  # if / ifelse
  sample_score <- 1200
  grade <- if (sample_score >= 1000) "high" else "low"
  bonus_flags <- ifelse(c(800, 1100, 1300) >= 1000, "bonus", "no_bonus")

  # for loop + seq()
  seq_values <- seq(1, 5, by = 1)
  for_total <- 0
  for (i in seq_values) {
    for_total <- for_total + i
  }

  # while loop
  counter <- 1
  while_total <- 0
  while (counter <= 3) {
    while_total <- while_total + counter
    counter <- counter + 1
  }

  # sort() + rev(sort())
  nums <- c(7, 2, 9, 4)
  nums_sorted <- sort(nums)
  nums_desc <- rev(sort(nums))

  # list() + matrix()
  sample_list <- list(player = "Alice", score = 1200, win = TRUE)
  sample_matrix <- matrix(seq(1, 6), nrow = 2, byrow = TRUE)

  # factor(), levels(), nlevels()
  region_factor <- factor(c("India", "USA", "India", "UK"))

  list(
    if_example = list(input_score = sample_score, grade = grade),
    ifelse_example = as.list(bonus_flags),
    for_loop_sum = for_total,
    while_loop_sum = while_total,
    seq_example = as.list(seq_values),
    sort_example = as.list(nums_sorted),
    rev_sort_example = as.list(nums_desc),
    list_example = sample_list,
    matrix_example = unname(split(sample_matrix, row(sample_matrix))),
    factor_example = as.list(as.character(region_factor)),
    factor_levels = as.list(levels(region_factor)),
    factor_nlevels = nlevels(region_factor)
  )
}

run_query <- function(df, q, p1 = NA_character_, p2 = NA_character_) {
  result_tbl <- NULL
  section <- "unknown"
  message <- "Query executed."

  if (q == "avg_score") {
    section <- "game_analytics"
    result_tbl <- df %>%
      filter(game_name == p1) %>%
      summarise(avg_score = mean(score, na.rm = TRUE))
  } else if (q == "max_score") {
    section <- "game_analytics"
    result_tbl <- df %>%
      filter(game_name == p1) %>%
      summarise(max_score = max(score, na.rm = TRUE))
  } else if (q == "min_score") {
    section <- "game_analytics"
    result_tbl <- df %>%
      filter(game_name == p1) %>%
      summarise(min_score = min(score, na.rm = TRUE))
  } else if (q == "total_score") {
    section <- "game_analytics"
    result_tbl <- df %>%
      filter(game_name == p1) %>%
      summarise(total_score = sum(score, na.rm = TRUE))
  } else if (q == "player_stats") {
    section <- "player_analytics"
    result_tbl <- df %>%
      filter(player_name == p1) %>%
      select(player_id, player_name, game_name, score, win, matches_played, rank, timestamp)
  } else if (q == "win_count") {
    section <- "player_analytics"
    result_tbl <- df %>%
      filter(player_name == p1) %>%
      summarise(win_count = sum(win, na.rm = TRUE))
  } else if (q == "matches_played") {
    section <- "player_analytics"
    result_tbl <- df %>%
      filter(player_name == p1) %>%
      summarise(matches_played = max(matches_played, na.rm = TRUE))
  } else if (q == "filter_by_game") {
    section <- "filters"
    result_tbl <- df %>%
      filter(game_name == p1) %>%
      select(session_id, player_name, game_name, score, win, region)
  } else if (q == "filter_by_score") {
    section <- "filters"
    min_score_value <- safe_number(p1, default = 0)
    result_tbl <- df %>%
      filter(score >= min_score_value) %>%
      select(session_id, player_name, game_name, score, rank)
  } else if (q == "group_by_game_avg") {
    section <- "group_by"
    result_tbl <- df %>%
      group_by(game_name) %>%
      summarise(avg_score = mean(score, na.rm = TRUE)) %>%
      arrange(desc(avg_score))
  } else if (q == "group_by_game_count") {
    section <- "group_by"
    result_tbl <- df %>%
      group_by(game_name) %>%
      summarise(session_count = n()) %>%
      arrange(desc(session_count))
  } else if (q == "top_players") {
    section <- "sorting"
    result_tbl <- df %>%
      group_by(player_name) %>%
      summarise(best_score = max(score, na.rm = TRUE)) %>%
      arrange(desc(best_score)) %>%
      select(player_name, best_score)
  } else if (q == "bottom_players") {
    section <- "sorting"
    result_tbl <- df %>%
      group_by(player_name) %>%
      summarise(best_score = max(score, na.rm = TRUE)) %>%
      arrange(best_score) %>%
      select(player_name, best_score)
  } else if (q == "sd_score") {
    section <- "statistics"
    result_tbl <- df %>%
      summarise(sd_score = sd(score, na.rm = TRUE))
  } else if (q == "mean_score") {
    section <- "statistics"
    result_tbl <- df %>%
      summarise(mean_score = mean(score, na.rm = TRUE))
  } else if (q == "median_score") {
    section <- "statistics"
    median_value <- df %>%
      select(score) %>%
      collect() %>%
      pull(score) %>%
      median(na.rm = TRUE)
    result_tbl <- data.frame(median_score = median_value)
  } else if (q == "sum_score") {
    section <- "statistics"
    result_tbl <- df %>%
      summarise(sum_score = sum(score, na.rm = TRUE))
  } else if (q == "distinct_players") {
    section <- "statistics"
    result_tbl <- df %>%
      summarise(distinct_players = n_distinct(player_name))
  } else if (q == "first_score") {
    section <- "position"
    result_tbl <- df %>%
      slice_min(order_by = timestamp, n = 1) %>%
      select(player_name, game_name, score, timestamp)
  } else if (q == "last_score") {
    section <- "position"
    result_tbl <- df %>%
      slice_max(order_by = timestamp, n = 1) %>%
      select(player_name, game_name, score, timestamp)
  } else if (q == "score_band_distribution") {
    section <- "statistics"
    result_tbl <- df %>%
      mutate(score_band = ifelse(score >= 1500, "high", "normal")) %>%
      group_by(score_band) %>%
      summarise(player_count = n()) %>%
      arrange(desc(player_count))
  } else if (q == "wins_by_game") {
    section <- "group_by"
    result_tbl <- df %>%
      group_by(game_name) %>%
      summarise(total_wins = sum(win, na.rm = TRUE)) %>%
      arrange(desc(total_wins))
  }   # ---------------- NEW REQUIRED QUERIES ----------------

  else if (q == "mutate_bonus_score") {
    section <- "mutate"
    result_tbl <- df %>%
      mutate(score_bonus = score + 100) %>%
      select(player_name, game_name, score, score_bonus)
  }

  else if (q == "mutate_flag_highscore") {
    section <- "mutate"
    result_tbl <- df %>%
      mutate(high_score_flag = ifelse(score >= 1500, 1, 0)) %>%
      select(player_name, score, high_score_flag)
  }

  else if (q == "select_starts_with") {
    section <- "select"
    result_tbl <- df %>%
      select(starts_with("player"))
  }

  else if (q == "select_ends_with") {
    section <- "select"
    result_tbl <- df %>%
      select(ends_with("name"))
  }

  else if (q == "complex_filter") {
    section <- "filters"
    result_tbl <- df %>%
      filter(score >= 1000 & win == TRUE | region == "India") %>%
      select(player_name, game_name, score, win, region)
  }

  else if (q == "multi_summary") {
    section <- "statistics"
    result_tbl <- df %>%
      summarise(
        avg_score = mean(score, na.rm = TRUE),
        max_score = max(score, na.rm = TRUE),
        min_score = min(score, na.rm = TRUE),
        total = n()
      )
  }

  else if (q == "first_last_summary") {
    section <- "statistics"

    first_row <- df %>%
      slice_min(order_by = timestamp, n = 1) %>%
      collect()

    last_row <- df %>%
      slice_max(order_by = timestamp, n = 1) %>%
      collect()

    result_tbl <- data.frame(
      first_score = first_row$score,
      last_score = last_row$score
    )
  }

  else if (q == "count_sessions") {
    section <- "statistics"
    result_tbl <- df %>%
      summarise(total_sessions = n())
  }

  else if (q == "group_multi_agg") {
    section <- "group_by"
    result_tbl <- df %>%
      group_by(game_name) %>%
      summarise(
        avg_score = mean(score, na.rm = TRUE),
        total_sessions = n(),
        max_score = max(score, na.rm = TRUE)
      ) %>%
      arrange(desc(avg_score))
  } else {
    section <- "error"
    message <- "Unknown query_name. Please provide a supported query."
    result_tbl <- data.frame(error = message, stringsAsFactors = FALSE)
  }

  list(
    result = to_result(result_tbl),
    section = section,
    message = message
  )
}

main <- function() {
  if (query_name == "") {
    payload <- list(
      query = query_name,
      result = list(),
      meta = list(
        status = "error",
        message = "Missing query_name argument.",
        params = list(param1 = param1, param2 = param2),
        baseR = build_base_r_section()
      )
    )
    write(toJSON(payload, auto_unbox = TRUE, pretty = TRUE, null = "null"), output_path)
    quit(save = "no", status = 1)
  }

  sc <- spark_connect(master = "local")
  on.exit(spark_disconnect(sc), add = TRUE)

  game_df <- spark_read_csv(
    sc = sc,
    name = "game_sessions",
    path = data_path,
    header = TRUE,
    infer_schema = TRUE,
    memory = FALSE
  )

  query_out <- run_query(game_df, query_name, param1, param2)

  payload <- list(
    query = query_name,
    result = query_out$result,
    meta = list(
      status = if (query_out$section == "error") "error" else "success",
      section = query_out$section,
      message = query_out$message,
      params = list(param1 = param1, param2 = param2),
      row_count = nrow(query_out$result),
      baseR = build_base_r_section()
    )
  )

  write(toJSON(payload, auto_unbox = TRUE, pretty = TRUE, null = "null"), output_path)
}

main()
