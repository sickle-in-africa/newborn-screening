#!/usr/bin/env Rscript
suppressMessages(library(DescTools))
suppressMessages(library(tidyverse))
suppressMessages(library(dplyr))

# Importing cleaned-standardised-filtered-imputed data from all sites
merging_all_datasets <- function(){

    read.csv('data/ghana/imputed/ghana-standard-filtered-imputed.csv') %>%
    as_tibble() -> data_gh

    read.csv('data/mali/imputed/mali-standard-filtered-imputed.csv') %>%
    as_tibble() -> data_ml

    read.csv('data/nigeria/imputed/nigeria-standard-filtered-imputed.csv') %>%
    as_tibble() -> data_ng

    read.csv('data/tanzania/imputed/tanzania-standard-filtered-imputed.csv') %>%
    as_tibble() -> data_tn

    read.csv('data/uganda/imputed/uganda-standard-filtered-imputed.csv') %>%
    as_tibble() -> data_ug

    read.csv('data/zim_zam/imputed/zim-zam-standard-filtered-imputed.csv') %>%
    as_tibble() -> data_zim_zam

    # read.csv('data/ghana/raw/prelims.csv') %>%
    # as_tibble() -> data_zm

    # Merging all individual site datasets
    merged_data <- bind_rows(data_gh, data_ml, data_ng, data_tn, data_ug, data_zim_zam) 
    # merged_data <- bind_rows(data_gh, data_ml, data_ng, data_tn, data_ug) 
    data_path <- "results/analysis_all/all_sites.csv"
    write.csv(merged_data, data_path, row.names=FALSE)

  }




merging_all_datasets()




