#!/usr/bin/env Rscript
suppressWarnings(library(tidyverse))
suppressWarnings(library(missForest))

get_input_filename_from_command_line <- function() {
    command_line_args = commandArgs(trailingOnly=TRUE)
    {if (!file.exists(command_line_args[1])) {stop("Error: input data file not found")}}
    return(command_line_args[1])
}

get_output_filename <- function(filename) {
    tools::file_path_sans_ext(basename(filename)) -> file_label
    return(paste0('data/uganda/imputed/', paste0(file_label,'-imputed.csv')))
}

input_filename <- "data/uganda/filtered/uganda-standard-filtered.csv"
output_filename <- get_output_filename(input_filename)

read.csv(input_filename) -> data

n_missing <- sum(is.na(data$result_poct)) + sum(is.na(data$result_dbs)) + sum(is.na(data$result_gs))

if (n_missing == 0) {
	print('** no missing data, skipping imputation step **')
	write.csv(data, output_filename, row.names=FALSE)
} else {
	print(paste0(n_missing, ' missing values found. Imputing...'))
	data %>% mutate_all(factor) -> data
	data %>% select(-participant_id) %>% missForest() -> data_imp
	data$participant_id -> data_imp$ximp$participant_id
	data_imp$ximp %>%
		select(
			participant_id,
			facility_id,
			country,
			result_poct,
			result_dbs,
			result_gs,
			gs_test_type) %>%
		write.csv(output_filename, row.names=FALSE)
}