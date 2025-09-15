#!/usr/bin/env Rscript
suppressWarnings(library(tidyverse))
suppressWarnings(library(missForest))

get_input_filename_from_command_line <- function() {
    command_line_args = commandArgs(trailingOnly=TRUE)
    if (length(command_line_args) == 0 || !file.exists(command_line_args[1])) {
        stop("Error: input data file not found")
    }
    return(command_line_args[1])
}

get_output_filename <- function(filename) {
    file_label <- tools::file_path_sans_ext(basename(filename))
    return(paste0('data/tanzania/imputed/', file_label, '-imputed.csv'))
}

input_filename <- "data/tanzania/filtered/tanzania-standard-filtered.csv"
output_filename <- get_output_filename(input_filename)

# Load data
data <- read.csv(input_filename, na.strings = c("", "NA"))  # Convert empty strings to NA

# Count missing values
n_missing <- sum(is.na(data$result_poct)) + sum(is.na(data$result_dbs)) + sum(is.na(data$result_gs))

if (n_missing == 0) {
    print('** No missing data, skipping imputation step **')
    write.csv(data, output_filename, row.names=FALSE)
} else {
    print(paste0(n_missing, ' missing values found. Imputing...'))

    # Convert only character columns to factors (missForest requires factors for categorical data)
    data <- data %>%
        mutate(across(where(is.character), as.factor))  

    # Save a list of column names before imputation
    original_cols <- colnames(data)

    # Remove participant_id for imputation
    data_imp <- missForest(data %>% select(-participant_id))

    # Retrieve imputed data and add back participant_id
    imputed_df <- data_imp$ximp
    imputed_df$participant_id <- data$participant_id

    # ✅ Ensure completely missing columns are restored (missForest removes them)
    for (col in original_cols) {
        if (!(col %in% colnames(imputed_df))) {
            imputed_df[[col]] <- NA  # Re-add missing column as NA
        }
    }

    # Save imputed dataset
    imputed_df %>%
        select(participant_id, facility_id, country, result_poct, result_dbs, result_gs, gs_test_type) %>%
        write.csv(output_filename, row.names=FALSE)

    print("** Imputation completed and saved successfully **")
}
