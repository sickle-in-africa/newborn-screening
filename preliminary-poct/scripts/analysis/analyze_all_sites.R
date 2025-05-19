#!/usr/bin/env Rscript
suppressPackageStartupMessages({
    library(tidyverse)
})

# Function to get command line arguments
get_input_filename_from_command_line <- function() {
    command_line_args <- commandArgs(trailingOnly = TRUE)
    
    if (length(command_line_args) < 2) {
        stop("Error: Two arguments are required - input data file and analysis name")
    }
    if (!file.exists(command_line_args[1])) {
        stop("Error: Input data file not found")
    }
    
    return(list(input_file = command_line_args[1], analysis_name = command_line_args[2]))
}

# Function to create contingency tables
get_table_dbs_XX <- function(input_table, XX) {
    suppressMessages({
        input_table %>% 
            mutate(
                result_dbs_XX = ifelse(result_dbs == XX, 'XX', 'not XX'),
                result_poct_XX = ifelse(result_poct == XX, 'XX', 'not XX')
            ) %>%
            group_by(result_dbs_XX, result_poct_XX) %>%
            summarize(count = sum(n), .groups = "drop") -> table_XX
    })
    return(table_XX)
}

# Function to calculate diagnostic metrics
get_diagnostics_XX <- function(input_table, XX) {
    sensitivity_XX <- list(estimate = NA, conf.int = c(NA, NA))
    specificity_XX <- list(estimate = NA, conf.int = c(NA, NA))
    ppv_XX <- list(estimate = NA, conf.int = c(NA, NA))
    npv_XX <- list(estimate = NA, conf.int = c(NA, NA))

    if (input_table$count[1] + input_table$count[3] > 0) {
        sensitivity_XX <- try(binom.test(input_table$count[1], (input_table$count[1] + input_table$count[3])), silent = TRUE)
    }
    if (input_table$count[4] + input_table$count[2] > 0) {
        specificity_XX <- try(binom.test(input_table$count[4], (input_table$count[4] + input_table$count[2])), silent = TRUE)
    }
    if (input_table$count[1] + input_table$count[2] > 0) {
        ppv_XX <- try(binom.test(input_table$count[1], (input_table$count[1] + input_table$count[2])), silent = TRUE)
    }
    if (input_table$count[4] + input_table$count[3] > 0) {
        npv_XX <- try(binom.test(input_table$count[4], (input_table$count[4] + input_table$count[3])), silent = TRUE)
    }

    return(tibble(
        genotype = XX,
        sensitivity_estimate = sensitivity_XX$estimate,
        sensitivity_low = sensitivity_XX$conf.int[1],
        sensitivity_high = sensitivity_XX$conf.int[2],
        specificity_estimate = specificity_XX$estimate,
        specificity_low = specificity_XX$conf.int[1],
        specificity_high = specificity_XX$conf.int[2],
        ppv_estimate = ppv_XX$estimate,
        ppv_low = ppv_XX$conf.int[1],
        ppv_high = ppv_XX$conf.int[2],
        npv_estimate = npv_XX$estimate,
        npv_low = npv_XX$conf.int[1],
        npv_high = npv_XX$conf.int[2]
    ))
}

# Function to create and export cross tables for each genotype
export_cross_tables <- function(input_table, genotypes, save_dir, prefix) {
    if (!dir.exists(save_dir)) {
        dir.create(save_dir, recursive = TRUE)
    }
    
    for (genotype in genotypes) {
        cross_table <- input_table %>%
            mutate(
                test_result = ifelse(result_dbs == genotype, genotype, paste0("not_", genotype)),
                gold_standard_result = ifelse(result_poct == genotype, genotype, paste0("not_", genotype))
            ) %>%
            group_by(test_result, gold_standard_result) %>%
            summarize(count = n(), .groups = "drop") %>%
            pivot_wider(names_from = gold_standard_result, values_from = count, values_fill = 0)
        
        file_path <- file.path(save_dir, paste0(prefix, "_cross_table_", genotype, ".txt"))
        
        write.table(
            cross_table,
            file = file_path,
            sep = "\t",
            row.names = FALSE,
            col.names = TRUE,
            quote = FALSE
        )
        
        cat("Cross table exported for genotype:", genotype, "to", file_path, "\n")
    }
}

# Function to create and save cross tables for DBS vs POCT
creating_crosstables <- function(data_country, save_dir) {
    suppressWarnings(suppressMessages({
        if (!dir.exists(save_dir)) {
            dir.create(save_dir, recursive = TRUE)
        }

        cross_table_dbs_poct <- table(data_country$result_dbs, data_country$result_poct)
        cross_table_dbs_poct <- as.data.frame.matrix(cross_table_dbs_poct)
        cross_table_dbs_poct <- cbind("dbs" = rownames(cross_table_dbs_poct), cross_table_dbs_poct)
        cross_table_dbs_poct_path <- file.path(save_dir, "cross-table-dbs-poct.csv")
        
        write.csv(cross_table_dbs_poct, cross_table_dbs_poct_path, row.names = FALSE)
        cat("Cross table exported for DBS vs POCT to", cross_table_dbs_poct_path, "\n")
    }))
}

# Main Script
args <- get_input_filename_from_command_line()
input_filename <- args$input_file
input_country <- args$analysis_name

read.csv(input_filename) %>% as_tibble() -> data_country

genotype_levels <- c('AA', 'AS', 'SS', 'AC')

data_country <- data_country %>%
    mutate(
        result_dbs = factor(result_dbs, levels = genotype_levels),
        result_poct = factor(result_poct, levels = genotype_levels)
    )

# Create contingency table and calculate diagnostics for DBS against POCT
suppressMessages({
    data_country %>%
        select(result_dbs, result_poct) %>%
        table() %>%
        as_tibble() -> table_base
})

get_table_dbs_XX(table_base, 'AA') -> table_AA
get_table_dbs_XX(table_base, 'SS') -> table_SS
get_table_dbs_XX(table_base, 'AS') -> table_AS
get_table_dbs_XX(table_base, 'AC') -> table_AC

table_all <- table_AA
table_all$count <- table_AA$count + table_SS$count + table_AS$count + table_AC$count

result <- bind_rows(
    get_diagnostics_XX(table_AA, 'AA'),
    get_diagnostics_XX(table_SS, 'SS'),
    get_diagnostics_XX(table_AS, 'AS'),
    get_diagnostics_XX(table_AC, 'AC'),
    get_diagnostics_XX(table_all, 'all')
)

# Export diagnostics results
diagnostics_path <- paste0("results/", input_country, "/test-diagnostics-dbs-with-poct.csv")
write.csv(result, diagnostics_path, row.names = FALSE)

contingency_path <- paste0("results/", input_country, "/contingency-table-dbs-with-poct.csv")
write.csv(table_base, contingency_path, row.names = FALSE)

# Create and export cross tables for DBS vs POCT
cross_table_dir <- paste0("results/", input_country, "/cross_tables/2x2_poct/")
export_cross_tables(data_country, genotype_levels, cross_table_dir, "dbs")

# Create and export general cross table for DBS vs POCT
creating_crosstables(data_country, cross_table_dir)

cat("./scripts/analysis/analyze_all_sites.R executed successfully using POCT as gold standard.\n")





