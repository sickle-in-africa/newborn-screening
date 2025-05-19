#!/usr/bin/env Rscript
suppressMessages(library(tidyverse))

read.csv('data/mali/raw/prelims.csv') %>% 
	as_tibble() -> data_ml

data_ml %>%
	mutate(
		country='mali',
		facility_id_screening = str_replace(facility_id_screening, ' ', '')) %>%
	select(
		participant_id,
		facility_id_screening,
		country,
		std_poct_results,
		dbspoct_test_results,
		ief_test_results,
		hplc_results,
		add_molecula_test_results) -> data_ml_clean

write.csv(data_ml_clean, 'data/mali/clean/mali-clean.csv', row.names=FALSE)