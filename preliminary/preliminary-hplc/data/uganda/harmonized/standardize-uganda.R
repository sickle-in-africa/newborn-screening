#!/usr/bin/env Rscript
suppressMessages(library(tidyverse))

read.csv('data/clean/uganda-clean.csv') %>% as_tibble() -> data_ug

AA_ief <- c("FA - NO abnormal hemoglobin")
SS_ief <- c("FS - Sickle cell disease SS (SCD-SS)/Sickle cell disease beta-0-thalassemia")
AS_ief <- c("FAS - Sickle cell trait (AS)")

data_ug %>%
	mutate(
		participant_id = Study.participant.ID,
		facility_id = Facility.ID,
		result_poct = Standard.POCT.Results,
		result_dbs = X.DBS.POCT.Results,
		result_gs = ifelse(
			!is.na(Additional.molecular.test.results), 
			Additional.molecular.test.results, 
			ifelse(
				!is.na(IEF.Results), 
				IEF.Results, 
				HPLC.Results)),
		result_gs = case_match(result_gs,
			AA_ief ~ 'AA',
			SS_ief ~ 'SS',
			AS_ief ~ 'AS',
			.default=result_gs),
		gs_test_type = ifelse(
			!is.na(Additional.molecular.test.results), 
			'molecular', 
			ifelse(
				!is.na(IEF.Results), 
				'ief', 
				ifelse(
					!is.na(HPLC.Results),
					'hplc',
					NA))),
		.keep='unused') %>%
	select(
		participant_id,
		facility_id,
		country,
		result_poct,
		result_dbs,
		result_gs,
		gs_test_type) -> data_ug_standard

write.csv(data_ug_standard, 'data/standard/uganda-standard.csv', row.names=FALSE)