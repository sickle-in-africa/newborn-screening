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
    return(paste0('data/ghana/imputed/', file_label, '-imputed.csv'))
}

input_filename <- "data/ghana/filtered/ghana-standard-filtered.csv"
output_filename <- get_output_filename(input_filename)

# Load Data
data <- read.csv(input_filename, na.strings = c("", "NA"))  # Ensure missing values are recognized
data[data == ""] <- NA

# Count missing values
n_missing <- sum(is.na(data$result_poct)) + sum(is.na(data$result_dbs)) + sum(is.na(data$result_gs))

if (n_missing == 0) {
    print('** no missing data, skipping imputation step **')
    write.csv(data, output_filename, row.names=FALSE)
} else {
    print(paste0(n_missing, " missing values found. Imputing..."))

    # Separate categorical and numerical columns
    categorical_cols <- c("result_poct", "result_dbs", "result_gs", "gs_test_type", "country", "facility_id")  
    numerical_cols <- setdiff(names(data), c("participant_id", categorical_cols))

    # Convert categorical columns to factors
    data[categorical_cols] <- lapply(data[categorical_cols], as.factor)

    # Convert data to a dataframe
    data <- as.data.frame(data)

    # Perform missForest imputation (without participant_id)
    imputed_data <- missForest(data[, !names(data) %in% "participant_id"])

    # Retrieve imputed dataset
    imputed_df <- imputed_data$ximp

    # Add back participant_id column
    imputed_df$participant_id <- data$participant_id

    # Ensure categorical variables remain as characters
    imputed_df[categorical_cols] <- lapply(imputed_df[categorical_cols], as.character)

    # Save output
    imputed_df %>%
        select(participant_id, facility_id, country, result_poct, result_dbs, result_gs, gs_test_type) %>%
        write.csv(output_filename, row.names=FALSE)

    print("** Imputation completed and saved successfully **")
}










