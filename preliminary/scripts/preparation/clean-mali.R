library(tidyverse)

read.csv('data/raw/Mali/NBS_research_data/SPARCO_MALI_NBS_DATA/NewBornScreening_DATA_brutes_2024-01-17_1143.csv', sep=';') %>% 
	as_tibble() -> data_ml

data_ml %>%
	mutate(
		country='mali') %>%
	select(
		participant_id,
		facility_id_screening,
		country,
		std_poct_results,
		dbspoct_test_results,
		ief_test_results,
		hplc_results,
		add_molecula_test_results) -> data_ml_clean

write.csv(data_ml_clean, 'data/clean/mali-clean.csv')