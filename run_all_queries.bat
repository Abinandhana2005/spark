@echo off

echo Running ALL Spark Queries...

call :run avg_score Chess
call :run max_score Chess
call :run min_score Chess
call :run total_score Chess

call :run player_stats Alice
call :run win_count Alice
call :run matches_played Alice

call :run filter_by_game Chess
call :run filter_by_score 1000
call :run complex_filter

call :run group_by_game_avg
call :run group_by_game_count
call :run wins_by_game
call :run group_multi_agg

call :run top_players
call :run bottom_players

call :run sd_score
call :run mean_score
call :run median_score
call :run sum_score
call :run distinct_players
call :run score_band_distribution
call :run multi_summary
call :run count_sessions
call :run first_last_summary

call :run first_score
call :run last_score

call :run mutate_bonus_score
call :run mutate_flag_highscore
call :run select_starts_with
call :run select_ends_with

echo All queries completed!
pause
exit /b

:run
echo Running %1 ...
Rscript spark/run_stats_sparklyr.R %1 %2
echo Finished %1
echo -------------------------
exit /b