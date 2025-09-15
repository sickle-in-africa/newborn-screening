#!/usr/bin/env Rscript
suppressMessages(library(tidyverse))

read.csv('data/tanzania/raw/tanzania_phase_2.csv') %>%
	as_tibble() -> data_tz

AA_poct <- c('1')
AS_poct <- c('2')
AC_poct <- c('3')
SS_poct <- c('4')
IN_poct <- c('7')

FA_ief <- c('1')
FS_ief <- c('3')
FAS_ief <- c('6')
FAC_ief <- c('7')


data_tz %>%
    mutate(
        facility_id = str_trim(facility_id_screening),
        country = 'tanzania',

        # Ensure all column names are present
        std_poct_results = case_match(as.character(get("std_poct_results", data_tz, inherits = TRUE)),  
            AA_poct ~ 'AA',
            AS_poct ~ 'AS',
            AC_poct ~ 'AC',
            SS_poct ~ 'SS',
            IN_poct ~ 'Indeterminate',
            .default = as.character(get("std_poct_results", data_tz, inherits = TRUE))
        ),

        dbspoct_test_results = case_match(as.character(get("dbspoct_test_results", data_tz, inherits = TRUE)),  
            AA_poct ~ 'AA',
            AS_poct ~ 'AS',
            AC_poct ~ 'AC',
            SS_poct ~ 'SS',
            IN_poct ~ 'Indeterminate',
            .default = as.character(get("dbspoct_test_results", data_tz, inherits = TRUE))
        ),

        # Corrected IEF Mapping (Only the Specified Values)
        ief_test_results = case_match(as.character(get("ief_test_results", data_tz, inherits = TRUE)),  
            FA_ief  ~ 'AA',   # FA → Normal (AA)
            FS_ief  ~ 'SS',   # FS → Sickle Cell Disease (SS)
            FAC_ief ~ 'AC',   # FAC → Hemoglobin C Trait (AC)
            FAS_ief ~ 'AS',   # FAS → Sickle Cell Trait (AS)
            .default = as.character(get("ief_test_results", data_tz, inherits = TRUE))  # Preserve unknown values
        )
    ) %>%
    select(
        participant_id,
        facility_id,
        country,
        std_poct_results,
        dbspoct_test_results,
        ief_test_results
    ) -> data_tz_clean


# data_tz %>%
# 	mutate(
# 		facility_id = str_trim(facility_id_screening),
# 		country = 'tanzania',
# 		std_poct_results = as.character(std_poct_results),
# 		dbspoct_test_results = as.character(dbspoct_test_results),
# 		ief_test_results = as.character(ief_test_results),
# 		results_poct = case_match(std_poct_results,
# 			AA_poct ~ 'AA',
# 			AS_poct ~ 'AS',
# 			AC_poct ~ 'AC',
# 			SS_poct ~ 'SS',
# 			IN_poct ~ 'Indeterminate',
# 			.default=std_poct_results),
# 		results_dbs = case_match(dbspoct_test_results,
# 			AA_poct ~ 'AA',
# 			AS_poct ~ 'AS',
# 			AC_poct ~ 'AC',
# 			SS_poct ~ 'SS',
# 			IN_poct ~ 'Indeterminate',
# 			.default=dbspoct_test_results),
# 		results_ief = case_match(ief_test_results,
# 			FA_ief ~ 'AA',
# 			FS_ief ~ 'AA',
# 			FAS_ief ~ 'AS',
# 			FAC_ief ~ 'AC',
# 			.default=ief_test_results)) %>%
# 	select(
# 		participant_id,
# 		facility_id,
# 		country,
# 		results_poct,
# 		results_dbs,
# 		results_ief
# 	) -> data_tz_clean

write.csv(data_tz_clean, 'data/tanzania/clean/tanzania-clean.csv', row.names=FALSE)