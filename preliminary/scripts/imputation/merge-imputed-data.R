#!/usr/bin/env Rscript
suppressWarnings(library(tidyverse))

read.csv('data/imputed/nigeria-standard-filtered-imputed.csv') -> data_ng
read.csv('data/imputed/mali-standard-filtered-imputed.csv') -> data_ml
read.csv('data/imputed/uganda-standard-filtered-imputed.csv') -> data_ug
read.csv('data/imputed/tanzania-standard-filtered-imputed.csv') -> data_tz

bind_rows(
    data_ng,
    data_ml,
    data_ug,
    data_tz) %>% as_tibble() -> data_all

data_all %>% write.csv('data/imputed/all-standard-filtered-imputed.csv', row.names=FALSE)