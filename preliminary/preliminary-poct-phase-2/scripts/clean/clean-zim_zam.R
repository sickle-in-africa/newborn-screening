#!/usr/bin/env Rscript
suppressMessages(library(tidyverse))

# Load data
read.csv('data/zim_zam/raw/zim_phase_2.csv') %>% 
  as_tibble() -> data_zim

read.csv('data/zim_zam/raw/zam_phase_2.csv') %>% 
  as_tibble() -> data_zam

data_zam %>%
  mutate(
    Facility.ID = Facility.ID, 
    country = 'zim/zam'
  ) %>%
  mutate(across(where(is.character), ~ na_if(., ""))) %>%
  select(
    `Study.participant.ID`, 
    Facility.ID,
    country,
    `Standard.POCT.Results`,
    `DBS.POCT.Results`
  ) -> data_zam_clean

data_zam %>%
  mutate(
    Facility.ID = Facility.ID, 
    country = 'zim/zam'
  ) %>%
  mutate(across(where(is.character), ~ na_if(., ""))) %>%
  select(
    `Study.participant.ID`, 
    Facility.ID,
    country,
    `Standard.POCT.Results`,
    `DBS.POCT.Results`
  ) -> data_zim_clean

# Combine the two datasets
data_zim_zam_clean <- bind_rows(data_zam_clean, data_zim_clean)

# Export the combined dataframe
write.csv(data_zim_zam_clean, 'data/zim_zam/clean/zim-zam-clean.csv', row.names = FALSE)
