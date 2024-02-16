library(tidyverse)

read.csv('data/raw/Nigeria/NBS_research_data/NBSPROJECT_DATA_2023-12-18_1524.csv') %>% 
	as_tibble() -> data_ng

uath <- c('uath', 'nbs/fct/uath')

AA_poct <- c('1')
AS_poct <- c('2')
SS_poct <- c('4')

FA_ief <- c('1')
FS_ief <- c('3')
FAS_ief <- c('6')
FAC_ief <- c('7')

data_ng %>%
	mutate(
		participant_id = record_id,
		facility_id = toupper(str_trim(facility_id_screening)),
		results_poct = as.character(results_poct),
		results_dbs = as.character(results_2),
		results_ief = as.character(results_ief),
		site_name = case_match(site_name,
			uath ~ 'uath',
			.default=site_name),
		country = 'nigeria',
		results_poct = case_match(results_poct,
			AA_poct ~ 'AA',
			AS_poct ~ 'AS',
			SS_poct ~ 'SS',
			.default = results_poct),
		results_dbs = case_match(results_dbs,
			AA_poct ~ 'AA',
			AS_poct ~ 'AS',
			SS_poct ~ 'SS',
			.default = results_dbs),
		results_ief = case_match(results_ief,
			FA_ief ~ 'FA',
			FS_ief ~ 'FS',
			FAS_ief ~ 'FAS',
			FAC_ief ~ 'FAC',
			.default = results_ief),
		results_mol = results_4) %>%
	select(
		participant_id,
		facility_id,
		country,
		results_poct,
		results_dbs,
		results_ief,
		results_hplc,
		results_mol) -> data_ng_clean

write.csv(data_ng_clean, 'data/clean/nigeria-clean.csv', row.names=FALSE)