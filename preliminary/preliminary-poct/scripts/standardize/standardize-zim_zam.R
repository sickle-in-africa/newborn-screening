#!/usr/bin/env Rscript
suppressMessages(library(tidyverse))

# Load the cleaned data
read.csv('data/zim_zam/clean/zim-zam-clean.csv') %>% 
  as_tibble() -> data_zim_zam

# Define result mappings
AA_ief <- c("FA - NO abnormal hemoglobin")
AA_ief1 <- c("AF - NO abnormal hemoglobin")
AA_ief2 <- c("Fa")
AA_ief3 <- c("FA")
SS_ief <- c("FS - Sickle cell disease SS (SCD-SS)/Sickle cell disease beta-0-thalassemia")
SS_ief1 <- c("FS")
AS_ief <- c("FAS - Sickle cell trait (AS)")
AS_ief1 <- c("FAS")

# Standardize data
data_zim_zam %>%
  mutate(
    participant_id = StudyID,
    facility_id = Facility.ID,
    result_poct = Standard.POCT.Results,
    result_dbs = DBS.POCT.Results,
    result_gs = ifelse(
      !is.na(IEF.Results), 
      IEF.Results, 
      HPLC.Results),
    result_gs = case_match(result_gs,
      AA_ief ~ 'AA',
      SS_ief ~ 'SS',
	  SS_ief1 ~ 'SS',
      AS_ief ~ 'AS',
	  AA_ief1 ~ 'AA',
	  AA_ief2 ~ 'AA',
	  AA_ief3 ~ 'AA',
	  AS_ief1 ~ 'AS',
      .default = result_gs),
    gs_test_type = ifelse(
      !is.na(IEF.Results), 
      'ief', 
      ifelse(
        !is.na(HPLC.Results),
        'hplc',
        NA))
  ) %>%
  select(
    participant_id,
    facility_id,
    country,
    result_poct,
    result_dbs,
    result_gs,
    gs_test_type
  ) -> data_zim_zam_standard

# Export the standardized data
write.csv(data_zim_zam_standard, 'data/zim_zam/standardize/zim-zam-standard.csv', row.names = FALSE)
