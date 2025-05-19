#!/usr/bin/env Rscript
suppressMessages(library(DescTools))
suppressMessages(library(tidyverse))
suppressMessages(library(dplyr))

# Running McNemar Test
running_mcnemar_test <- function(){
  
    # Importing consolidated dataset
    read.csv('results/analysis_all/all_sites.csv') %>%
    as_tibble() -> merged_data

    # Categorize the data
    merged_data$result_poct_cat <- ifelse(merged_data$result_poct %in% c("SS", "AS", "SC"), "SCD", "Non-SCD")
    merged_data$result_dbs_cat <- ifelse(merged_data$result_dbs %in% c("SS", "AS", "SC"), "SCD", "Non-SCD")

    # Generate the table
    result_table <- table(merged_data$result_dbs_cat, merged_data$result_poct_cat)
    result_df <- as.data.frame.matrix(result_table)
    result_df <- cbind("result_dbs" = rownames(result_df), result_df)
    colnames(result_df) <- c("result_dbs", "Non-SCD", "SCD")

    statistical_test_path <- paste0("results/analysis_all/mcnemar_test/cross_table.csv")
    data_path <- "results/analysis_all/all_sites.csv"
    mcnemar_test_path <- "results/analysis_all/mcnemar_test/mcnemar_test_results.txt"

    # Running McNemar test on the cross table
    mcnemar_test_result <- mcnemar.test(result_table)

    # Calculating confidence intervals for the odds ratio
    b <- result_table[2, 1]
    c <- result_table[1, 2]
    odds_ratio <- b / c
    conf_int <- exp(log(odds_ratio) + c(-1, 1) * qnorm(0.975) * sqrt(1/b + 1/c))

     # Exporting cross table and McNemar test results to the same file
    sink(mcnemar_test_path)
    cat("Cross Table: result_dbs vs result_poct\n")
    print(result_table)
    cat("\nMcNemar Test Results:\n")
    print(mcnemar_test_result)
    cat("\nConfidence Intervals for the Odds Ratio:\n")
    cat("Odds Ratio: ", odds_ratio, "\n")
    cat("95% Confidence Interval: (", conf_int[1], ", ", conf_int[2], ")\n")
    sink()

    # Exporting cross table: dbs vs poct 
    write.table(t(c("result_dbs", "Non-SCD", "SCD")), statistical_test_path, sep = ",", col.names = FALSE, row.names = FALSE, quote = FALSE)
    write.table(t(c("result_poct", rep("", ncol(result_df)-1))), statistical_test_path, sep = ",", col.names = FALSE, row.names = FALSE, quote = FALSE, append = TRUE)
    write.table(result_df, statistical_test_path, sep = ",", col.names = FALSE, row.names = FALSE, quote = FALSE, append = TRUE)

    # Exporting merged dataset
    write.csv(merged_data, data_path, row.names=FALSE)

  }




running_mcnemar_test()




