@echo off

echo Running ALL Spark Queries...

REM Game
Rscript spark/run_stats_sparklyr.R avg_score Chess
Rscript spark/run_stats_sparklyr.R max_score Chess
Rscript spark/run_stats_sparklyr.R min_score Chess
Rscript spark/run_stats_sparklyr.R total_score Chess

REM Player
Rscript spark/run_stats_sparklyr.R player_stats Alice
Rscript spark/run_stats_sparklyr.R win_count Alice
Rscript spark/run_stats_sparklyr.R matches_played Alice

REM Filters
Rscript spark/run_stats_sparklyr.R filter_by_game Chess
Rscript spark/run_stats_sparklyr.R filter_by_score 1000
Rscript spark/run_stats_sparklyr.R complex_filter

REM Group
Rscript spark/run_stats_sparklyr.R group_by_game_avg
Rscript spark/run_stats_sparklyr.R group_by_game_count
Rscript spark/run_stats_sparklyr.R wins_by_game
Rscript spark/run_stats_sparklyr.R group_multi_agg

REM Sorting
Rscript spark/run_stats_sparklyr.R top_players
Rscript spark/run_stats_sparklyr.R bottom_players

REM Stats
Rscript spark/run_stats_sparklyr.R sd_score
Rscript spark/run_stats_sparklyr.R mean_score
Rscript spark/run_stats_sparklyr.R median_score
Rscript spark/run_stats_sparklyr.R sum_score
Rscript spark/run_stats_sparklyr.R distinct_players
Rscript spark/run_stats_sparklyr.R score_band_distribution
Rscript spark/run_stats_sparklyr.R multi_summary
Rscript spark/run_stats_sparklyr.R count_sessions
Rscript spark/run_stats_sparklyr.R first_last_summary

REM Position
Rscript spark/run_stats_sparklyr.R first_score
Rscript spark/run_stats_sparklyr.R last_score

REM Mutate + Select
Rscript spark/run_stats_sparklyr.R mutate_bonus_score
Rscript spark/run_stats_sparklyr.R mutate_flag_highscore
Rscript spark/run_stats_sparklyr.R select_starts_with
Rscript spark/run_stats_sparklyr.R select_ends_with

echo Done! Check spark/output folder
pause