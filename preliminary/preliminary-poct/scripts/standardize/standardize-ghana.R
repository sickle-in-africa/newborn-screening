#!/usr/bin/env Rscript
suppressMessages(library(tidyverse))

read.csv('data/ghana/clean/ghana-clean.csv') %>% as_tibble() -> data_ng

AA_gs <- c('FA')
SS_gs <- c('FSC')
AC_gs <- c('FAC')
AS_gs <- c('FAS')

data_ng %>%
	mutate(
        facility_id = facility_id_screening,
		result_poct = results_poct,
		result_dbs = results_dbs,
		result_gs = case_match(results_ief,
			AA_gs ~ 'AA',
			SS_gs ~ 'SS',
			AC_gs ~ 'AC',
			AS_gs ~ 'AS',
			.default=results_ief),
		gs_test_type = 'ief',
		.keep = 'unused') %>%
	select(
		participant_id,
		facility_id,
		country,
		result_poct,
		result_dbs,
		result_gs,
		gs_test_type) -> data_ng_standard

write.csv(data_ng_standard, 'data/ghana/standardize/ghana-standard.csv', row.names=FALSE)