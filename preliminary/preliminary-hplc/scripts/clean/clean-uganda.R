#!/usr/bin/env Rscript
suppressMessages(library(tidyverse))

read.csv('data/uganda/raw/prelims.csv') %>%
	filter(Event.Name=='Event 1 (Arm 1: Arm 1_Guardians)') %>%
	as_tibble() -> data_ug

data_ug %>%
	mutate(
		Facility.ID = 'LHHR',
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

write.csv(data_ug_clean, 'data/uganda/clean/uganda-clean.csv', row.names=FALSE)