#!/usr/bin/env Rscript
suppressWarnings(library(tidyverse))

get_input_filename_from_command_line <- function() {
    command_line_args = commandArgs(trailingOnly=TRUE)
    {if (!file.exists(command_line_args[1])) {stop("Error: input data file not found")}}
    return(command_line_args[1])
}

get_table_XX <- function(input_table, XX) {
    input_table %>% 
        mutate(
            result_poct_XX = ifelse(result_poct==XX, 'XX', 'not XX'),
            result_gs_XX = ifelse(result_gs==XX, 'XX', 'not XX')) %>%
        group_by(result_poct_XX, result_gs_XX) %>%
        summarize(count=sum(n)) -> table_XX
    return(table_XX)
}

get_diagnostics_XX <- function(input_table, XX) {
    try(binom.test(input_table$count[1],(input_table$count[1]+input_table$count[3])), silent=TRUE) -> sensitivity_XX
    try(binom.test(input_table$count[4],(input_table$count[4]+input_table$count[2]))) -> specificity_XX
    try(binom.test(input_table$count[1],(input_table$count[1]+input_table$count[2])), silent=TRUE) -> ppv_XX
    try(binom.test(input_table$count[4],(input_table$count[4]+input_table$count[3]))) -> npv_XX

    if (inherits(sensitivity_XX, 'try-error')) {
        print(paste0('sensitivity score undefined for ', XX))
        sensitivity_XX <- list(NA, c(NA, NA))
        names(sensitivity_XX) <- c('estimate', 'conf.int')
    }

    if (inherits(ppv_XX, 'try-error')) {
        print(paste0('PPV score undefined for ', XX))
        ppv_XX <- list(NA, c(NA, NA))
        names(ppv_XX) <- c('estimate', 'conf.int')
    }

    return(tibble(
        genotype = c(XX),
        sensitivity_estimate = c(sensitivity_XX$estimate),
        sensitivity_low = c(sensitivity_XX$conf.int[1]),
        sensitivity_high = c(sensitivity_XX$conf.int[2]),
        specificity_estimate = c(specificity_XX$estimate),
        specificity_low = c(specificity_XX$conf.int[1]),
        specificity_high = c(specificity_XX$conf.int[2]),
        ppv_estimate = c(ppv_XX$estimate),
        ppv_low = c(ppv_XX$conf.int[1]),
        ppv_high = c(ppv_XX$conf.int[2]),
        npv_estimate = c(npv_XX$estimate),
        npv_low = c(npv_XX$conf.int[1]),
        npv_high = c(npv_XX$conf.int[2])))
}

input_filename <- get_input_filename_from_command_line()
# input_filename <- 'data/imputed/nigeria-standard-filtered-imputed.csv'

read.csv(input_filename) %>% as_tibble() -> data_country

genotype_levels <- c('AA', 'AS', 'SS', 'AC')

data_country %>%
    mutate(
        result_poct = factor(result_poct, levels=genotype_levels),
        result_gs = factor(result_gs, levels=genotype_levels)) %>%
    select(result_poct, result_gs) %>%
    table() %>%
    as_tibble() -> table_all

get_table_XX(table_all, 'AA') -> table_AA

get_table_XX(table_all, 'SS') -> table_SS

get_table_XX(table_all, 'AS') -> table_AS

get_table_XX(table_all, 'AC') -> table_AC

bind_rows(
    get_diagnostics_XX(table_AA, 'AA'),
    get_diagnostics_XX(table_SS, 'SS'),
    get_diagnostics_XX(table_AS, 'AS'),
    get_diagnostics_XX(table_AC, 'AC')) -> result

write.csv(table_all, 'media/analysis/contingency-table-poct.csv', row.names=FALSE)
write.csv(result, 'media/analysis/test-diagnostics-poct.csv', row.names=FALSE)



