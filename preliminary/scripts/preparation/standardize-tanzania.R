#!/usr/bin/env Rscript
suppressMessages(library(tidyverse))

read.csv('data/clean/tanzania-clean.csv') %>% as_tibble() -> data_tz

AA_gs <- c('FA')
SS_gs <- c('FS')
AC_gs <- c('FAC')
AS_gs <- c('FAS')

data_tz %>%
	mutate(
		result_poct = std_poct_results,
		result_dbs = dbspoct_test_results,
		result_gs = case_match(ief_test_results,
			AA_gs ~ 'AA',
			SS_gs ~ 'SS',
			AC_gs ~ 'AC',
			AS_gs ~ 'AS',
			.default=ief_test_results),
		gs_test_type = 'ief',
		.keep='unused') -> data_tz_standard

write.csv(data_tz_standard, 'data/standard/tanzania-standard.csv', row.names=FALSE)