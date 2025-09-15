suppressMessages(library(tidyverse))

dates <- function(data_gh) {

  change_date <- function(data_gh, a) {
    data_gh[[a]] <- as.Date(data_gh[[a]], format = "%d %m %Y")
    data_gh[[a]] <- format(data_gh[[a]], "%d-%m-%Y")
    return(data_gh[[a]])
  }

  date_columns <- c("date_of_visit", "screening_date")

  for (column in date_columns) {
    data_gh[[column]] <- change_date(data_gh, column)
  }
  
  return(data_gh)
}


read.csv('data/ghana/raw/ghana_phase_2.csv') %>%
  as_tibble() %>% dates() -> data_gh


data_gh %>%
  mutate(
    country='Ghana',
    participant_id = participant_id,
    facility_id_screening = 'KUMASI',
   results_poct = case_match(
              as.integer(std_poct_results), 
              1 ~ 'AA',  # Normal
              2 ~ 'AS',  # Sickle Cell Trait
              3 ~ 'AC',  # Hemoglobin C Trait
              4 ~ 'SS',  # Sickle Cell Disease (SS)
              5 ~ 'SC',  # Sickle Cell Disease (SC)
              6 ~ 'CC',  # Hemoglobin C Disease (CC)
              7 ~ 'Indeterminate',  # Uncertain result
              .default = as.character(std_poct_results) 
      ),
    results_dbs = case_match(
              as.integer(dbspoct_test_results), 
              1 ~ 'AA',  # Normal
              2 ~ 'AS',  # Sickle Cell Trait
              3 ~ 'AC',  # Hemoglobin C Trait
              4 ~ 'SS',  # Sickle Cell Disease (SS)
              5 ~ 'SC',  # Sickle Cell Disease (SC)
              6 ~ 'CC',  # Hemoglobin C Disease (CC)
              7 ~ 'Indeterminate',  # Uncertain result
              .default = as.character(dbspoct_test_results) 
      ),
    results_ief = case_match(
              as.integer(ief_test_results), 
              1 ~ 'AA',  # FA → AA (Normal)
              2 ~ 'AA',  # AF → AA (Normal)
              3 ~ 'SS',  # Sickle Cell Disease (SS)
              4 ~ 'SC',  # Sickle Cell Disease (SC)
              5 ~ 'Sβ+', # Sickle Cell Beta(+) Thalassemia
              6 ~ 'AS',  # Sickle Cell Trait
              7 ~ 'AC',  # Hemoglobin C Trait
              8 ~ 'Other',
              .default = as.character(ief_test_results) 
      )
    ) %>%
  select(
    participant_id,
    facility_id_screening,
    country,
    results_poct,
    results_dbs,
    results_ief
    ) -> data_gh_clean

write.csv(data_gh_clean, 'data/ghana/clean/ghana-clean.csv', row.names=FALSE)