#!/usr/bin/env Rscript
suppressWarnings(library(tidyverse))

get_input_filename_from_command_line <- function() {
    command_line_args = commandArgs(trailingOnly=TRUE)
    {if (!file.exists(command_line_args[1])) {stop("Error: input data file not found")}}
    return(command_line_args[1])
}

get_table_XX <- function(input_table, XX) {
    input_table %>% 
        mutate(result_gs_XX = ifelse(result_gs==XX, 'XX', 'not XX')) %>%
        group_by(result_gs_XX) %>%
        summarize(count=sum(n)) -> table_XX
    return(table_XX)
}

get_prevalence_XX <- function(input_table, XX) {
    try(binom.test(input_table$count[1],(input_table$count[1]+input_table$count[2])), silent=TRUE) -> prevalence_XX

    if (inherits(prevalence_XX, 'try-error')) {
        print(paste0('prevalence undefined for ', XX))
        prevalence_XX <- list(NA, c(NA, NA))
        names(prevalence_XX) <- c('estimate', 'conf.int')
    }

    return(tibble(
        genotype = c(XX),
        prevalence_estimate = c(prevalence_XX$estimate),
        prevalence_low = c(prevalence_XX$conf.int[1]),
        prevalence_high = c(prevalence_XX$conf.int[2])))
}

input_filename <- get_input_filename_from_command_line()
# input_filename <- 'data/imputed/nigeria-standard-filtered-imputed.csv'

read.csv(input_filename) %>% as_tibble() -> data_country

genotype_levels <- c('AA', 'AS', 'SS', 'AC')

data_country %>%
    mutate(result_gs = factor(result_gs, levels=genotype_levels)) %>%
    select(result_gs) %>%
    table() %>%
    as_tibble() -> table_all

result <- data.frame()
for (genotype in genotype_levels) {
    get_table_XX(table_all, genotype) -> table_XX
    bind_rows(result, get_prevalence_XX(table_XX, genotype)) -> result
}

write.csv(table_all, 'media/analysis/genotype-frequencies-gs.csv', row.names=FALSE)
write.csv(result, 'media/analysis/genotype-prevalences-gs.csv', row.names=FALSE)
