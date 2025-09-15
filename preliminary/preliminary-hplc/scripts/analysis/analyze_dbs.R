#!/usr/bin/env Rscript
suppressPackageStartupMessages({
    library(tidyverse)
})

# Function to get command line arguments
get_input_filename_from_command_line <- function() {
    # Get command line arguments
    command_line_args <- commandArgs(trailingOnly = TRUE)
    
    # Check if at least two arguments are provided
    if (length(command_line_args) < 2) {
        stop("Error: Two arguments are required - input data file and analysis name")
    }
    
    # Check if the input data file exists
    if (!file.exists(command_line_args[1])) {
        stop("Error: input data file not found")
    }
    
    # Return the arguments as a list
    return(list(input_file = command_line_args[1], analysis_name = command_line_args[2]))
}

get_table_dbs_XX <- function(input_table, XX) {
    suppressMessages({
        input_table %>% 
            mutate(
                result_dbs_XX = ifelse(result_dbs == XX, 'XX', 'not XX'),
                result_gs_XX = ifelse(result_gs == XX, 'XX', 'not XX')) %>%
            group_by(result_dbs_XX, result_gs_XX) %>%
            summarize(count = sum(n), .groups = "drop") -> table_XX
    })
    return(table_XX)
}

get_table_poct_XX <- function(input_table, XX) {
    suppressMessages({
        input_table %>% 
            mutate(
                result_poct_XX = ifelse(result_poct == XX, 'XX', 'not XX'),
                result_gs_XX = ifelse(result_gs == XX, 'XX', 'not XX')) %>%
            group_by(result_poct_XX, result_gs_XX) %>%
            summarize(count = sum(n), .groups = "drop") -> table_XX
    })
    return(table_XX)
}

get_diagnostics_XX <- function(input_table, XX) {
    # Initialize variables to avoid undefined errors
    sensitivity_XX <- list(estimate = NA, conf.int = c(NA, NA))
    specificity_XX <- list(estimate = NA, conf.int = c(NA, NA))
    ppv_XX <- list(estimate = NA, conf.int = c(NA, NA))
    npv_XX <- list(estimate = NA, conf.int = c(NA, NA))

    # Perform tests only if counts are valid
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

    # Handle possible errors
    if (inherits(sensitivity_XX, 'try-error')) {
        cat('Warning: sensitivity score undefined for', XX, '\n')
        sensitivity_XX <- list(estimate = NA, conf.int = c(NA, NA))
    }
    if (inherits(ppv_XX, 'try-error')) {
        cat('Warning: PPV score undefined for', XX, '\n')
        ppv_XX <- list(estimate = NA, conf.int = c(NA, NA))
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

creating_crosstables <- function(data_country) {
    # Suppress messages and warnings while creating cross tables
    suppressWarnings(suppressMessages({

        cross_table_dbs_rs <- table(data_country$result_dbs, data_country$result_gs)
        cross_table_dbs_rs <- as.data.frame.matrix(cross_table_dbs_rs)
        cross_table_dbs_rs <- cbind("result_gs" = rownames(cross_table_dbs_rs), cross_table_dbs_rs)
        cross_table_dbs_rs_path <- paste0("results/", input_country, "/cross_tables/cross-table-dbs-rs.csv")
        write.table(t(c("dbs", colnames(cross_table_dbs_rs)[-1])), cross_table_dbs_rs_path, sep = ",", col.names = FALSE, row.names = FALSE, quote = FALSE)
        write.table(t(c("result_rs", rep("", ncol(cross_table_dbs_rs) - 1))), cross_table_dbs_rs_path, sep = ",", col.names = FALSE, row.names = FALSE, quote = FALSE, append = TRUE)
        write.table(cross_table_dbs_rs, cross_table_dbs_rs_path, sep = ",", col.names = FALSE, row.names = FALSE, quote = FALSE, append = TRUE)

        cross_table_poct_rs <- table(data_country$result_poct, data_country$result_gs)
        cross_table_poct_rs <- as.data.frame.matrix(cross_table_poct_rs)
        cross_table_poct_rs <- cbind("result_gs" = rownames(cross_table_poct_rs), cross_table_poct_rs)
        cross_table_poct_rs_path <- paste0("results/", input_country, "/cross_tables/cross-table-poct-rs.csv")
        write.table(t(c("poct", colnames(cross_table_poct_rs)[-1])), cross_table_poct_rs_path, sep = ",", col.names = FALSE, row.names = FALSE, quote = FALSE)
        write.table(t(c("result_rs", rep("", ncol(cross_table_poct_rs) - 1))), cross_table_poct_rs_path, sep = ",", col.names = FALSE, row.names = FALSE, quote = FALSE, append = TRUE)
        write.table(cross_table_poct_rs, cross_table_poct_rs_path, sep = ",", col.names = FALSE, row.names = FALSE, quote = FALSE, append = TRUE)

        cross_table_dbs_poct <- table(data_country$result_dbs, data_country$result_poct)
        cross_table_dbs_poct <- as.data.frame.matrix(cross_table_dbs_poct)
        cross_table_dbs_poct <- cbind("dbs" = rownames(cross_table_dbs_poct), cross_table_dbs_poct)
        cross_table_dbs_poct_path <- paste0("results/", input_country, "/cross_tables/cross-table-dbs-poct.csv")
        write.table(t(c("dbs", colnames(cross_table_dbs_poct)[-1])), cross_table_dbs_poct_path, sep = ",", col.names = FALSE, row.names = FALSE, quote = FALSE)
        write.table(t(c("poct", rep("", ncol(cross_table_dbs_poct) - 1))), cross_table_dbs_poct_path, sep = ",", col.names = FALSE, row.names = FALSE, quote = FALSE, append = TRUE)
        write.table(cross_table_dbs_poct, cross_table_dbs_poct_path, sep = ",", col.names = FALSE, row.names = FALSE, quote = FALSE, append = TRUE)

    }))
}


# Input arguments
args <- get_input_filename_from_command_line()

input_filename <- args$input_file
input_country <- args$analysis_name

read.csv(input_filename) %>% as_tibble() -> data_country

genotype_levels <- c('AA', 'AS', 'SS', 'AC')
















# DBS
suppressMessages({
    data_country %>%
        mutate(
            result_dbs = factor(result_dbs, levels = genotype_levels),
            result_gs = factor(result_gs, levels = genotype_levels)) %>%
        select(result_dbs, result_gs) %>%
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

# Creating cross tables
creating_crosstables(data_country)


# Function to create and export cross tables for each genotype
export_cross_tables <- function(input_table, genotypes, save_dir, prefix, result_gs) {
    # Ensure the save directory exists
    if (!dir.exists(save_dir)) {
        dir.create(save_dir, recursive = TRUE)
    }
    
    # Loop through each genotype
    for (genotype in genotypes) {
        # Create cross table for the genotype
        cross_table <- input_table %>%
            mutate(
                test_result = ifelse(result_dbs == genotype, genotype, paste0("not_", genotype)),
                gold_standard_result = ifelse(result_gs == genotype, genotype, paste0("not_", genotype))
            ) %>%
            group_by(test_result, gold_standard_result) %>%
            summarize(count = n(), .groups = "drop") %>%
            pivot_wider(names_from = gold_standard_result, values_from = count, values_fill = 0)
        
        # Create the file path for the export
        file_path <- file.path(save_dir, paste0(prefix, "_cross_table_", genotype, ".txt"))
        
        # Export the table to a text file
        write.table(
            cross_table,
            file = file_path,
            sep = "\t",
            row.names = FALSE,
            col.names = TRUE,
            quote = FALSE
        )
        
        # Print a message to confirm export
        cat("Cross table exported for genotype:", genotype, "to", file_path, "\n")
    }
}


# Creating contingency tables
contingency_path <- paste0("results/", input_country, "/contingency-table-dbs.csv")
diagnostics_path <- paste0("results/", input_country, "/test-diagnostics-dbs.csv")

write.csv(table_base, contingency_path, row.names = FALSE)
write.csv(result, diagnostics_path, row.names = FALSE)











# POCT
suppressMessages({
    data_country %>%
        mutate(
            result_poct = factor(result_poct, levels = genotype_levels),
            result_gs = factor(result_gs, levels = genotype_levels)) %>%
        select(result_poct, result_gs) %>%
        table() %>%
        as_tibble() -> table_base
})

get_table_poct_XX(table_base, 'AA') -> table_AA
get_table_poct_XX(table_base, 'SS') -> table_SS
get_table_poct_XX(table_base, 'AS') -> table_AS
get_table_poct_XX(table_base, 'AC') -> table_AC

table_all <- table_AA
table_all$count <- table_AA$count + table_SS$count + table_AS$count + table_AC$count

result <- bind_rows(
    get_diagnostics_XX(table_AA, 'AA'),
    get_diagnostics_XX(table_SS, 'SS'),
    get_diagnostics_XX(table_AS, 'AS'),
    get_diagnostics_XX(table_AC, 'AC'),
    get_diagnostics_XX(table_all, 'all')
)

# Creating cross tables
creating_crosstables(data_country)

# Creating contingency tables
contingency_path <- paste0("results/", input_country, "/contingency-table-poct.csv")
diagnostics_path <- paste0("results/", input_country, "/test-diagnostics-poct.csv")

write.csv(table_base, contingency_path, row.names = FALSE)
write.csv(result, diagnostics_path, row.names = FALSE)





# Export cross tables for DBS: ief/hplc
dbs_save_dir <- paste0("results/", input_country, "/cross_tables/2x2_ief")
export_cross_tables(data_country, genotype_levels, dbs_save_dir, "dbs", result_gs)

# Export cross tables for POCT: ief/hplc
poct_save_dir <- paste0("results/", input_country, "/cross_tables/2x2_ief")
export_cross_tables(data_country, genotype_levels, poct_save_dir, "poct", result_gs)




# Print success message with input details
cat("./scripts/analysis/analyze_dbs.R executed successfully.","\n")



















































