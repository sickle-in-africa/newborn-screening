#!/usr/bin/env Rscript
suppressMessages(library(tidyverse))

get_input_filename_from_command_line <- function() {
    command_line_args = commandArgs(trailingOnly=TRUE)
    {if (!file.exists(command_line_args[1])) {stop("Error: input data file not found")}}
    return(command_line_args[1])
}

get_output_filename <- function(filename) {
    tools::file_path_sans_ext(basename(filename)) -> file_label
    return(paste0('data/uganda/filtered/', paste0(file_label,'-filtered.csv')))
}

input_filename <- "data/uganda/standardize/uganda-standard.csv"
output_filename <- get_output_filename(input_filename)

read.csv(input_filename) %>% as_tibble() -> data

data$participant_id %>% duplicated() -> data$duplicated
data %>% 
	filter(!duplicated) %>%
	select(-duplicated) -> data_filtered

write.csv(data_filtered, output_filename, row.names=FALSE)
