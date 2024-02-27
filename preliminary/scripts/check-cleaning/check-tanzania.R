library(tidyverse)

read.csv('data/imputed/tanzania-standard-filtered-imputed.csv') %>%
	as_tibble() -> data_tz_imputed

read.csv('data/raw/Tanzania/NBS_research_data/NBS_Tanzania_2024_01_18/NBSProject_DATA_2024-01-18.csv') %>% 
	as_tibble() %>%
	select(
		participant_id,
		facility_id_screening,
		std_poct_results,
		dbspoct_test_results,
		ief_test_results) -> data_tz_raw

full_join(data_tz_raw, data_tz_imputed, by='participant_id') -> data_tz_merged

data_tz_merged %>% ggplot(aes(x=result_poct, y=std_poct_results)) + geom_point()
data_tz_merged %>% ggplot(aes(x=result_dbs, y=dbspoct_test_results)) + geom_point()
data_tz_merged %>% ggplot(aes(x=result_gs, y=ief_test_results)) + geom_point()