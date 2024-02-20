#!/usr/bin/env Rscript
suppressMessages(library(tidyverse))

read.csv('data/standard/nigeria-standard.csv') %>% as_tibble() -> data_ng
read.csv('data/standard/tanzania-standard.csv') %>% as_tibble() -> data_tz
read.csv('data/standard/mali-standard.csv') %>% as_tibble() -> data_ml
read.csv('data/standard/uganda-standard.csv') %>% as_tibble() -> data_ug

bind_rows(data_ng, data_tz, data_ml, data_ug) -> data_all

write.csv(data_all, 'data/standard/merged-standard.csv', row.names=FALSE)