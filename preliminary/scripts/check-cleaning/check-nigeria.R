library(tidyverse)

read.csv('data/imputed/nigeria-standard-filtered-imputed.csv') %>%
	as_tibble() -> data_ng_imputed

read.csv('data/raw/Nigeria/NBS_research_data/NBSPROJECT_DATA_2023-12-18_1524.csv') %>% 
	as_tibble() %>%
	select(
		record_id,
		facility_id_screening,
		site_name,
		results_poct,
		results_2,
		results_ief) -> data_ng_raw

data_ng_imputed %>% mutate(record_id = participant_id) -> data_ng_mapped

full_join(data_ng_raw, data_ng_mapped, by='record_id') -> data_ng_merged

data_ng_merged %>% ggplot(aes(x=result_poct, y=results_poct)) + geom_point()
data_ng_merged %>% ggplot(aes(x=result_dbs, y=results_2)) + geom_point()
data_ng_merged %>% ggplot(aes(x=result_gs, y=results_ief)) + geom_point()