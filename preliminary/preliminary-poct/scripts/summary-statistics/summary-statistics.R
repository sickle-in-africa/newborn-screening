#!/usr/bin/env Rscript
suppressMessages(library(tidyverse))
suppressMessages(library(lubridate))



# Concerting date columns to date formats
dates <- function(data_gh){
  change_date <- function(data_gh, a) {
    data_gh[[a]] <- as.Date(data_gh[[a]], format = "%d %m %Y")
    data_gh[[a]] <- format(data_gh[[a]], "%d-%m-%Y")
    return(data_gh[[a]])
  }
  
  date_columns <- c("dob_newborn", "date_of_visit", "screening_date", "std_poct_test_date", "std_poct_test_result_date", 
                    "dbspoct_test_date", "dbspoct_test_result_date", "ief_test_date", "ief_test_result_date",
                    "hplc_test_date", "hplc_result_date", "ief_test_date")
  
  for (column in date_columns) {
    data_gh[[column]] <- change_date(data_gh,as.character(column))
  }
  return(data_gh)
}




# read.csv('data/ghana/raw/prelims.csv') %>%
#   as_tibble() %>% dates() -> data_gh

read.csv('data/ghana/raw/prelims.csv') %>%
  as_tibble() -> data_gh

read.csv('data/mali/raw/prelims.csv') %>%
  as_tibble() -> data_ml

  read.csv('data/nigeria/raw/prelims.csv') %>%
  as_tibble() -> data_ng

read.csv('data/tanzania/raw/prelims.csv') %>%
  as_tibble() -> data_tn

read.csv('data/uganda/raw/prelims.csv') %>%
  as_tibble() -> data_ug

read.csv('data/zim_zam/standardize/zim-zam-standard.csv') %>%
  as_tibble() -> data_zm




# Define the function to get the number of rows and columns and export to a text file
creating_summary_statistics <- function(data, path) {
  
  # Define the function to get the number of rows and columns and export to a text file
  export_summary_statistics <- function(country, data, file_path) {
    
    # Get the number of rows and columns
    row_count <- nrow(data)
    col_count <- ncol(data)
    
    # Create the text to be written to the file
    title <- paste("Summary Statistics:", country)
    row_text <- paste("Row count:", row_count)
    col_text <- paste("Column count:", col_count)
    
    # Create the table for the 'sex_newborn' column
    if ("sex_newborn" %in% colnames(data)) {
      sex_table <- table(data$sex_newborn)
      sex_table_text <- capture.output(sex_table)
    } else {
      sex_table_text <- "Column 'sex_newborn' not found in the dataset."
    }
    
    # Create the table for the 'sex_newborn' column
    if ("ief_test_results" %in% colnames(data)) {
      ief_test_results_table <- table(data$ief_test_results)
      ief_test_results_table_text <- capture.output(ief_test_results_table)
    } else {
      ief_test_results_table_text <- "Column 'ief_test_results' not found in the dataset."
    }
    
    # Create the table for the 'hplc_results' column
    if ("hplc_results" %in% colnames(data)) {
      hplc_results_table <- table(data$hplc_results)
      hplc_results_table_text <- capture.output(hplc_results_table)
    } else {
      hplc_results_table_text <- "Column 'hplc_results' not found in the dataset."
    }
    
    # Create the table for the 'dbspoct_test_results' column
    if ("dbspoct_test_results" %in% colnames(data)) {
      dbspoct_test_results_table <- table(data$dbspoct_test_results)
      dbspoct_test_results_table_text <- capture.output(dbspoct_test_results_table)
    } else {
      dbspoct_test_results_table_text <- "Column 'dbspoct_test_results' not found in the dataset."
    }
    
    # Create the table for the 'std_poct_results' column
    if ("std_poct_results" %in% colnames(data)) {
      std_poct_results_table <- table(data$std_poct_results)
      std_poct_results_table_text <- capture.output(std_poct_results_table)
    } else {
      std_poct_results_table_text <- "Column 'std_poct_results' not found in the dataset."
    }
    
    
    
    # Write the title, a blank line, row/column count, and the sex_newborn table to a file
    write(title, file = file_path)
    write("", file = file_path, append = TRUE) # Add a blank line
    write("", file = file_path, append = TRUE) # Add a blank line
    write("", file = file_path, append = TRUE) # Add a blank line
    write(row_text, file = file_path, append = TRUE)
    write("", file = file_path, append = TRUE) # Add a blank line
    write(col_text, file = file_path, append = TRUE)
    write("", file = file_path, append = TRUE) # Add a blank line
    write("", file = file_path, append = TRUE) # Add a blank line
    write("", file = file_path, append = TRUE) # Add a blank line
    write("Table of 'sex_newborn':", file = file_path, append = TRUE)
    write(sex_table_text, file = file_path, append = TRUE)
    write("", file = file_path, append = TRUE) # Add a blank line
    write("", file = file_path, append = TRUE) # Add a blank line
    write("", file = file_path, append = TRUE) # Add a blank line
    write("Table of 'ief_test_results':", file = file_path, append = TRUE)
    write(ief_test_results_table_text, file = file_path, append = TRUE)
    write("", file = file_path, append = TRUE) # Add a blank line
    write("", file = file_path, append = TRUE) # Add a blank line
    write("", file = file_path, append = TRUE) # Add a blank line
    write("Table of 'hplc_results':", file = file_path, append = TRUE)
    write(hplc_results_table_text, file = file_path, append = TRUE)
    write("", file = file_path, append = TRUE) # Add a blank line
    write("", file = file_path, append = TRUE) # Add a blank line
    write("", file = file_path, append = TRUE) # Add a blank line
    write("Table of 'dbspoct_test_results':", file = file_path, append = TRUE)
    write(dbspoct_test_results_table_text, file = file_path, append = TRUE)
    write("", file = file_path, append = TRUE) # Add a blank line
    write("", file = file_path, append = TRUE) # Add a blank line
    write("", file = file_path, append = TRUE) # Add a blank line
    write("Table of 'std_poct_results':", file = file_path, append = TRUE)
    write(std_poct_results_table_text, file = file_path, append = TRUE)
  }
  
  export_summary_statistics("Ghana", data_gh, "results/analysis_ghana/summary_statistics_ghana.txt")
  
  
  
  
  
  
  
  
  
  
  
  
  # Define the function to calculate the difference in months between two date columns
  calculate_month_diff <- function(data, date_col1, date_col2, new_col_name, file_path) {
    
    # Define the dates
    data[[date_col1]] <- as.Date(data[[date_col1]], format = "%Y-%m-%d")
    data[[date_col2]] <- as.Date(data[[date_col2]], format = "%Y-%m-%d")
    
    # Create new columns to store the month for each date column
    data$month_dob_newborn <- month(data[[date_col1]])
    data$month_date_of_visit <- month(data[[date_col2]])
    
    data[[new_col_name]] <- data$month_date_of_visit - data$month_dob_newborn
    
    # Remove entries with age below 0
    data <- data[data[[new_col_name]] >= 0, ]
    
    # Remove the intermediate month columns if not needed
    data$month_dob_newborn <- NULL
    data$month_date_of_visit <- NULL
    
    # Handle NA values and calculate the average and confidence intervals
    valid_data <- data[[new_col_name]][!is.na(data[[new_col_name]])]
    avg <- round(mean(valid_data, na.rm = TRUE), 2)
    stderr <- round(sd(valid_data, na.rm = TRUE) / sqrt(length(valid_data)), 2)
    conf_interval <- round(stderr * qt(0.975, df = length(valid_data) - 1), 2) # 95% confidence interval
    
    # Print the results
    cat("Average:", avg, "\n")
    cat("95% Confidence Interval:", avg - conf_interval, "to", avg + conf_interval, "\n")
    
    # Write the results to a text file
    write("", file = file_path, append = TRUE) # Add a blank line
    write("", file = file_path, append = TRUE) # Add a blank line
    write("", file = file_path, append = TRUE) # Add a blank line
    write(paste("Average Age in Months:", avg), file = file_path, append = TRUE)
    write(paste("95% Confidence Interval:", avg - conf_interval, "to", avg + conf_interval), file = file_path, append = TRUE)
    
  }
  
  # Calculate the month difference and add it to the dataset
  calculate_month_diff(data_gh, "dob_newborn", "date_of_visit", "age_in_months", path)
  
  
}




creating_summary_statistics(data_gh, "results/analysis_ghana/summary_statistics_ghana.txt")
creating_summary_statistics(data_ml, "results/analysis_mali/summary_statistics_mali.txt")
creating_summary_statistics(data_ng, "results/analysis_nigeria/summary_statistics_nigeria.txt")
creating_summary_statistics(data_tn, "results/analysis_tanzania/summary_statistics_tanzania.txt")
creating_summary_statistics(data_ug, "results/analysis_uganda/summary_statistics_uganda.txt")
creating_summary_statistics(data_zm, "results/analysis_zim_zam/summary_statistics_zim_zam.txt")
