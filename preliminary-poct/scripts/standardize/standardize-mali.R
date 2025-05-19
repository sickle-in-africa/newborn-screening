#!/usr/bin/env Rscript
suppressMessages(library(tidyverse))

read.csv('data/mali/clean/mali-clean.csv') %>% as_tibble() -> data_ml

AA_poct <- c('1')
AS_poct <- c('2')
AC_poct <- c('3')
SS_poct <- c('4')
CC_poct <- c('6')
IN_poct <- c('7')

FA_ief <- c('1', '2')
FS_ief <- c('3')
FAS_ief <- c('6')
FAC_ief <- c('7')
FSC_ief <- c('4')
other_ief <- c('8')

data_ml %>%
	mutate(
		participant_id = paste0('NBS/MAL/',participant_id),
		facility_id = facility_id_screening,
		result_poct = as.character(std_poct_results),
		result_poct = case_match(result_poct,
			AA_poct ~ 'AA',
			AS_poct ~ 'AS',
			AC_poct ~ 'AC',
			SS_poct ~ 'SS',
			CC_poct ~ 'CC',
			IN_poct ~ 'Indeterminate',
			.default=result_poct),
		result_dbs = as.character(dbspoct_test_results),
		result_dbs = case_match(result_dbs,
			AA_poct ~ 'AA',
			AS_poct ~ 'AS',
			AC_poct ~ 'AC',
			SS_poct ~ 'SS',
			CC_poct ~ 'CC',
			IN_poct ~ 'Indeterminate',			
			.default=result_dbs),
		result_gs = as.character(hplc_results),
		result_gs = case_match(result_gs,
			FA_ief ~ 'AA',
			FS_ief ~ 'SS',
			FAS_ief ~ 'AS',
			FAC_ief ~ 'AC',
			FSC_ief ~ 'SC',
			other_ief ~ 'other',
			.default=result_gs),
		gs_test_type = 'hplc',
		.keep='unused') %>%
	select(
		participant_id,
		facility_id,
		country,
		result_poct,
		result_dbs,
		result_gs,
		gs_test_type) -> data_ml_standard

write.csv(data_ml_standard, 'data/mali/standardize/mali-standard.csv', row.names=FALSE)