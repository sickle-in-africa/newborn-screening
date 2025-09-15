#!/usr/bin/env Rscript
suppressMessages(library(tidyverse))
suppressMessages(library(lubridate))

# Function to convert date columns to proper date format
dates <- function(data_gh) {
  change_date <- function(data_gh, a) {
    if (a %in% colnames(data_gh)) {  # Check if column exists
      data_gh[[a]] <- as.character(data_gh[[a]])  # Convert to character before parsing
      data_gh[[a]][data_gh[[a]] == ""] <- NA  # Convert empty strings to NA
      data_gh[[a]] <- suppressWarnings(as.Date(data_gh[[a]], format = "%d %m %Y"))  # Handle conversion
      data_gh[[a]] <- format(data_gh[[a]], "%d-%m-%Y")  # Keep date format consistent
    }
    return(data_gh[[a]])
  }

  date_columns <- c("dob_newborn", "date_of_visit", "screening_date", "std_poct_test_date", 
                    "std_poct_test_result_date", "dbspoct_test_date", "dbspoct_test_result_date", 
                    "ief_test_date", "ief_test_result_date", "hplc_test_date", "hplc_result_date")

  for (column in date_columns) {
    data_gh[[column]] <- change_date(data_gh, column)
  }
  return(data_gh)
}

# Function to calculate the difference in months between two date columns
calculate_month_diff <- function(data, date_col1, date_col2, new_col_name, file_path) {
  if (!all(c(date_col1, date_col2) %in% colnames(data))) {  # Ensure both columns exist
    cat("Skipping calculation: One or both date columns are missing\n")
    return(data)  # Return unchanged data
  }

  # Convert empty strings to NA and ensure proper date format
  data[[date_col1]] <- as.character(data[[date_col1]])
  data[[date_col1]][data[[date_col1]] == ""] <- NA
  data[[date_col1]] <- suppressWarnings(as.Date(data[[date_col1]], format = "%Y-%m-%d"))

  data[[date_col2]] <- as.character(data[[date_col2]])
  data[[date_col2]][data[[date_col2]] == ""] <- NA
  data[[date_col2]] <- suppressWarnings(as.Date(data[[date_col2]], format = "%Y-%m-%d"))

  # Remove rows where either date is missing
  data <- data %>% filter(!is.na(data[[date_col1]]) & !is.na(data[[date_col2]]))

  # Proceed with calculations only if valid data remains
  if (nrow(data) == 0) {
    cat("No valid date pairs found, skipping month difference calculation.\n")
    return(data)
  }

  # Compute month difference
  data[[new_col_name]] <- interval(data[[date_col1]], data[[date_col2]]) %/% months(1)

  # Remove negative age values
  data <- data %>% filter(data[[new_col_name]] >= 0)

  # Handle NA values and calculate average & confidence interval
  valid_data <- data[[new_col_name]][!is.na(data[[new_col_name]])]
  avg <- round(mean(valid_data, na.rm = TRUE), 2)
  stderr <- round(sd(valid_data, na.rm = TRUE) / sqrt(length(valid_data)), 2)
  conf_interval <- round(stderr * qt(0.975, df = length(valid_data) - 1), 2)  # 95% CI

  # Print results
  cat("Average:", avg, "\n")
  cat("95% Confidence Interval:", avg - conf_interval, "to", avg + conf_interval, "\n")

  # Write results to file
  write(paste("Average Age in Months:", avg), file = file_path, append = TRUE)
  write(paste("95% Confidence Interval:", avg - conf_interval, "to", avg + conf_interval), file = file_path, append = TRUE)

  return(data)
}

# Load datasets
data_gh <- read.csv('data/ghana/standardize/ghana-standard.csv') %>% as_tibble()
data_ml <- read.csv('data/mali/standardize/mali-standard.csv') %>% as_tibble()
data_ng <- read.csv('data/nigeria/standardize/nigeria-standard.csv') %>% as_tibble()
data_tn <- read.csv('data/tanzania/standardize/tanzania-standard.csv') %>% as_tibble()
data_ug <- read.csv('data/uganda/standardize/uganda-standard.csv') %>% as_tibble()
data_zm <- read.csv('data/zim_zam/standardize/zim-zam-standard.csv') %>% as_tibble()

# Process date formats
data_gh <- dates(data_gh)
data_ml <- dates(data_ml)
data_ng <- dates(data_ng)
data_tn <- dates(data_tn)
data_ug <- dates(data_ug)
data_zm <- dates(data_zm)

# Calculate age difference
calculate_month_diff(data_gh, "dob_newborn", "date_of_visit", "age_in_months", "results/analysis_ghana/summary_statistics_ghana.txt")

# Define function to create summary statistics
creating_summary_statistics <- function(data, file_path) {
  if (nrow(data) == 0) {
    cat("Skipping summary statistics: No data found in dataset.\n")
    return()
  }

  row_count <- nrow(data)
  col_count <- ncol(data)

  title <- paste("Summary Statistics:", file_path)
  row_text <- paste("Row count:", row_count)
  col_text <- paste("Column count:", col_count)

  # Ensure column exists before computing table
  create_table_text <- function(column) {
    if (column %in% colnames(data)) {
      return(capture.output(table(data[[column]])))
    } else {
      return(paste("Column", column, "not found in dataset."))
    }
  }

  sex_table_text <- create_table_text("sex_newborn")
  ief_test_results_table_text <- create_table_text("result_gs")
  hplc_results_table_text <- create_table_text("result_gs")
  dbspoct_test_results_table_text <- create_table_text("result_dbs")
  std_poct_results_table_text <- create_table_text("result_poct")

  # Write to file
  write(c(title, row_text, col_text, 
          "Table of 'sex_newborn':", sex_table_text, 
          "Table of 'ief_test_results':", ief_test_results_table_text, 
          "Table of 'hplc_results':", hplc_results_table_text, 
          "Table of 'dbspoct_test_results':", dbspoct_test_results_table_text, 
          "Table of 'std_poct_results':", std_poct_results_table_text), 
        file = file_path, append = FALSE)
}

# Generate summary statistics
creating_summary_statistics(data_gh, "results/analysis_ghana/summary_statistics_ghana.txt")
creating_summary_statistics(data_ml, "results/analysis_mali/summary_statistics_mali.txt")
creating_summary_statistics(data_ng, "results/analysis_nigeria/summary_statistics_nigeria.txt")
creating_summary_statistics(data_tn, "results/analysis_tanzania/summary_statistics_tanzania.txt")
creating_summary_statistics(data_ug, "results/analysis_uganda/summary_statistics_uganda.txt")
creating_summary_statistics(data_zm, "results/analysis_zim_zam/summary_statistics_zim_zam.txt")
