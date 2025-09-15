#!/usr/bin/env Rscript
suppressMessages(library(tidyverse))

read.csv('data/uganda/raw/uganda_phase_2.csv') %>%
	as_tibble() -> data_ug

data_ug %>%
  mutate(
    Facility.ID = Facility.ID, 
    country = 'uganda'
  ) %>%
  mutate(across(where(is.character), ~ na_if(., ""))) %>%
  select(
    `Study.participant.ID`, 
    Facility.ID,
    country,
    `Standard.POCT.Results`,
    `DBS.POCT.Results`,
    `HPLC.Results`,
    `IEF.Results`,
    `Additional.molecular.test.results`
  ) -> data_ug_clean




write.csv(data_ug_clean, 'data/uganda/clean/uganda-clean.csv', row.names=FALSE)