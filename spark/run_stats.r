args <- commandArgs(trailingOnly = TRUE)

query_type <- ifelse(length(args) >= 1, args[1], "all")
param1 <- ifelse(length(args) >= 2, args[2], NA)
param2 <- ifelse(length(args) >= 3, args[3], NA)

source("spark/jobs/stats_aggregation_batch.r")
run_job(query_type, param1, param2)