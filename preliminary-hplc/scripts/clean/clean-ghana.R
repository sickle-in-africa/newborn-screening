#!/usr/bin/env Rscript
suppressMessages(library(tidyverse))

# Concerting date columns to date formats
dates <- function(data_gh){
  change_date <- function(data_gh, a) {
    data_gh[[a]] <- as.Date(data_gh[[a]], format = "%d %m %Y")
    data_gh[[a]] <- format(data_gh[[a]], "%d-%m-%Y")
    return(data_gh[[a]])
  }
  
  date_columns <- c("dob_newborn", "date_of_visit", "screening_date", "std_poct_test_date", "std_poct_test_result_date", 
                    "dbspoct_test_date", "dbspoct_test_result_date", "ief_test_date", "ief_test_result_date",
                    "hplc_test_date", "hplc_result_date", "ief_test_date")
  
  for (column in date_columns) {
    data_gh[[column]] <- change_date(data_gh,as.character(column))
  }
  return(data_gh)
}


read.csv('data/ghana/raw/prelims.csv') %>%
  as_tibble() %>% dates() -> data_gh

data_gh %>%
  mutate(
    country='ghana',
    participant_id = record_id,
    facility_id_screening = 'KUMASI',
    results_poct = std_poct_results,
    results_dbs = dbspoct_test_results,
    results_ief = case_match(ief_test_results,
                                  'FA - NO abnormal hemoglobin' ~ 'FA',
                                  'AF - NO abnormal hemoglobin' ~ 'FA',
                                  'FAC - C trait (AC)' ~ 'FAC',
                                  'FAS - Sickle cell trait (AS)' ~ 'FAS',
                                  'Other' ~ 'Other',
                                  'FSC - Sickle cell disease SC (SCD-SC)' ~ 'FSC',
                                  .default=ief_test_results)
    ) %>%
  select(
    participant_id,
    facility_id_screening,
    country,
    results_poct,
    results_dbs,
    results_ief) -> data_gh_clean

write.csv(data_gh_clean, 'data/ghana/clean/ghana-clean.csv', row.names=FALSE)