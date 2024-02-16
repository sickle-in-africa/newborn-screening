library(tidyverse)

read.csv('data/raw/Tanzania/NBS_research_data/NBS_Tanzania_2024_01_18/NBSProject_DATA_2024-01-18.csv') %>%
	as_tibble() -> data_tz

AA_poct <- c('1')
AS_poct <- c('2')
AC_poct <- c('3')
SS_poct <- c('4')
IN_poct <- c('7')

FA_ief <- c('1')
FS_ief <- c('3')
FAS_ief <- c('6')
FAC_ief <- c('7')

data_tz %>%
	mutate(
		facility_id = str_trim(facility_id_screening),
		country = 'tanzania',
		std_poct_results = as.character(std_poct_results),
		dbspoct_test_results = as.character(dbspoct_test_results),
		ief_test_results = as.character(ief_test_results),
		std_poct_results = case_match(std_poct_results,
			AA_poct ~ 'AA',
			AS_poct ~ 'AS',
			AC_poct ~ 'AC',
			SS_poct ~ 'SS',
			IN_poct ~ 'Indeterminate',
			.default=std_poct_results),
		dbspoct_test_results = case_match(dbspoct_test_results,
			AA_poct ~ 'AA',
			AS_poct ~ 'AS',
			AC_poct ~ 'AC',
			SS_poct ~ 'SS',
			IN_poct ~ 'Indeterminate',
			.default=dbspoct_test_results),
		ief_test_results = case_match(ief_test_results,
			FA_ief ~ 'FA',
			FS_ief ~ 'FS',
			FAS_ief ~ 'FAS',
			FAC_ief ~ 'FAC',
			.default=ief_test_results)) %>%
	select(
		participant_id,
		facility_id,
		country,
		std_poct_results,
		dbspoct_test_results,
		ief_test_results) -> data_tz_clean

write.csv(data_tz_clean, 'data/clean/tanzania-clean.csv', row.names=FALSE)