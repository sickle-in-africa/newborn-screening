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

# Function to create contingency tables (excluding NA values)
get_table_dbs_XX <- function(input_table, XX) {
    input_table %>%
        filter(!is.na(result_dbs) & !is.na(result_poct)) %>%  # Exclude NA values
        mutate(
            result_dbs_XX = ifelse(result_dbs == XX, 'XX', 'not XX'),
            result_poct_XX = ifelse(result_poct == XX, 'XX', 'not XX')
        ) %>%
        group_by(result_dbs_XX, result_poct_XX) %>%
        summarize(count = n(), .groups = "drop") -> table_XX
    
    return(table_XX)
}

# Function to calculate diagnostic metrics safely
get_diagnostics_XX <- function(input_table, XX) {
    if (nrow(input_table) < 4) {
        return(tibble(
            genotype = XX,
            sensitivity_estimate = NA, sensitivity_low = NA, sensitivity_high = NA,
            specificity_estimate = NA, specificity_low = NA, specificity_high = NA,
            ppv_estimate = NA, ppv_low = NA, ppv_high = NA,
            npv_estimate = NA, npv_low = NA, npv_high = NA
        ))
    }

    # Initialize metrics
    sensitivity_XX <- list(estimate = NA, conf.int = c(NA, NA))
    specificity_XX <- list(estimate = NA, conf.int = c(NA, NA))
    ppv_XX <- list(estimate = NA, conf.int = c(NA, NA))
    npv_XX <- list(estimate = NA, conf.int = c(NA, NA))

    # Check before running binom.test() to avoid errors
    if (sum(input_table$count[c(1, 3)]) > 0) {
        sensitivity_XX <- binom.test(input_table$count[1], sum(input_table$count[c(1, 3)]))
    }
    if (sum(input_table$count[c(4, 2)]) > 0) {
        specificity_XX <- binom.test(input_table$count[4], sum(input_table$count[c(4, 2)]))
    }
    if (sum(input_table$count[c(1, 2)]) > 0) {
        ppv_XX <- binom.test(input_table$count[1], sum(input_table$count[c(1, 2)]))
    }
    if (sum(input_table$count[c(4, 3)]) > 0) {
        npv_XX <- binom.test(input_table$count[4], sum(input_table$count[c(4, 3)]))
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

# Function to export cross tables
export_cross_tables <- function(input_table, genotypes, save_dir, prefix) {
    if (!dir.exists(save_dir)) {
        dir.create(save_dir, recursive = TRUE)
    }
    
    for (genotype in genotypes) {
        cross_table <- input_table %>%
            filter(!is.na(result_dbs) & !is.na(result_poct)) %>%  # Exclude NA values
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

# Main Script
args <- get_input_filename_from_command_line()
input_filename <- args$input_file
input_country <- args$analysis_name

# Load data and exclude rows with NA values
data_country <- read.csv(input_filename) %>% as_tibble() %>%
    filter(!is.na(result_dbs) & !is.na(result_poct))  # Drop NA rows

# Define genotype levels
genotype_levels <- c('AA', 'AS', 'SS', 'AC')

# Convert genotype columns to factors
data_country <- data_country %>%
    mutate(
        result_dbs = factor(result_dbs, levels = genotype_levels),
        result_poct = factor(result_poct, levels = genotype_levels)
    )

# Create base contingency table
suppressMessages({
    data_country %>%
        select(result_dbs, result_poct) %>%
        table() %>%
        as_tibble() -> table_base
})

# Generate contingency tables for each genotype
table_AA <- get_table_dbs_XX(table_base, 'AA')
table_SS <- get_table_dbs_XX(table_base, 'SS')
table_AS <- get_table_dbs_XX(table_base, 'AS')
table_AC <- get_table_dbs_XX(table_base, 'AC')

# Combine tables
table_all <- bind_rows(table_AA, table_SS, table_AS, table_AC)

# Calculate diagnostics for each genotype
result <- bind_rows(
    get_diagnostics_XX(table_AA, 'AA'),
    get_diagnostics_XX(table_SS, 'SS'),
    get_diagnostics_XX(table_AS, 'AS'),
    get_diagnostics_XX(table_AC, 'AC'),
    get_diagnostics_XX(table_all, 'all')
)

# Export results
diagnostics_path <- paste0("results/", input_country, "/test-diagnostics-dbs-with-poct.csv")
write.csv(result, diagnostics_path, row.names = FALSE)

# Export contingency table
contingency_path <- paste0("results/", input_country, "/contingency-table-dbs-with-poct.csv")
write.csv(table_base, contingency_path, row.names = FALSE)

# Export cross tables
cross_table_dir <- paste0("results/", input_country, "/cross_tables/2x2_poct/")
export_cross_tables(data_country, genotype_levels, cross_table_dir, "dbs")

cat("./scripts/analysis/analyze_dbs.R executed successfully using POCT as gold standard.\n")











