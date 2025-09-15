#!/usr/bin/env Rscript
suppressMessages(library(tidyverse))

# Load data
read.csv('data/zim_zam/raw/zim.csv') %>% 
  as_tibble() -> data_zim

read.csv('data/zim_zam/raw/zam.csv') %>% 
  as_tibble() -> data_zam

# Clean zam data
data_zam %>%
  mutate(
    Facility.ID = '',
    country = 'zim/zam',
    StudyID = as.character(StudyID)  # Ensure StudyID is character
  ) %>%
  mutate(across(where(is.character), ~ na_if(., ""))) %>%
  select(
    StudyID,
    Facility.ID,
    country,
    Standard.POCT.Results,
    DBS.POCT.Results,
    IEF.Results
  ) -> data_zam_clean

# Clean zim data
data_zim %>%
  mutate(
    country = 'zim/zam',
    StudyID = as.character(StudyID)  # Ensure StudyID is character
  ) %>%
  mutate(across(where(is.character), ~ na_if(., ""))) %>%
  select(
    StudyID,
    Facility.ID,
    country,
    Standard.POCT.Results,
    DBS.POCT.Results,
    IEF.Results
  ) -> data_zim_clean

# Combine the two datasets
data_zim_zam_clean <- bind_rows(data_zam_clean, data_zim_clean)

# Export the combined dataframe
write.csv(data_zim_zam_clean, 'data/zim_zam/clean/zim-zam-clean.csv', row.names = FALSE)
