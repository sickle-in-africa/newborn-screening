library(tidyverse)

read.csv('data/raw/Uganda/NBS_research_data/NewBornScreening-UGANDA_DATA_2024-01-30_1539.csv') %>%
	filter(Event.Name=='Event 1 (Arm 1: Arm 1_Guardians)') %>%
	as_tibble() -> data_ug

data_ug %>%
	mutate(
		country='uganda') %>%
	mutate(across(where(is.character), ~ na_if(.,""))) %>%
	select(Study.participant.ID,
		Facility.ID,
		country,
		Standard.POCT.Results,
		X.DBS.POCT.Results,
		HPLC.Results,
		IEF.Results,
		Additional.molecular.test.results) -> data_ug_clean

write.csv(data_ug_clean, 'data/clean/uganda-clean.csv', row.names=FALSE)