#!/usr/bin/env bash

# Function to run a script and check for errors
run_script() {
  script=$1
  if Rscript --vanilla $script $args > output.log 2>&1; then
    echo "$script executed successfully."
  else
    echo "Error executing $script. See details below:" >&2
    echo
    cat output.log >&2
    exit 1
  fi
}


# Function to check if required files exist
check_files() {
  files=$@
  for file in $files; do
    if [[ ! -f $file ]]; then
      echo "Required file: $file not found." >&2
      exit 1
    fi
  done
}


echo
echo "Checking imports..."
echo

# # Run configuration script
# ./config.sh
# echo

echo "Starting NBS data processing pipeline..."
echo



# Define required files
clean_files=("data/ghana/raw/prelims.csv"
             "data/mali/raw/prelims.csv"
             "data/nigeria/raw/prelims.csv"
             "data/tanzania/raw/prelims.csv"
             "data/uganda/raw/prelims.csv"
             "data/zim_zam/raw/zim.csv"
             "data/zim_zam/raw/zam.csv")




# Cleaning
echo "Process 1: Cleaning data..."
echo
check_files ${clean_files[@]}
run_script ./scripts/clean/clean-ghana.R
run_script ./scripts/clean/clean-mali.R
run_script ./scripts/clean/clean-nigeria.R
run_script ./scripts/clean/clean-tanzania.R
run_script ./scripts/clean/clean-uganda.R
run_script ./scripts/clean/clean-zim_zam.R
echo
echo "Cleaning Done..."
echo
echo "------------------------------------------------------------------------------------------------------------------"
echo
echo
echo
echo




# Standardizing
echo "Process 2: Standardizing data..."
echo
run_script ./scripts/standardize/standardize-ghana.R
run_script ./scripts/standardize/standardize-mali.R
run_script ./scripts/standardize/standardize-nigeria.R
run_script ./scripts/standardize/standardize-tanzania.R
run_script ./scripts/standardize/standardize-uganda.R
run_script ./scripts/standardize/standardize-zim_zam.R
echo
echo "Standardizing Done..."
echo
echo "------------------------------------------------------------------------------------------------------------------"
echo
echo
echo
echo


# Summary Statistics
echo "Process 3: Performing summary statistics (getting summary statistics of data)..."
echo
run_script ./scripts/summary-statistics/summary-statistics.R 
echo
echo "Summary Statistics Done..."
echo
echo "--------------------------------------"
echo
echo
echo
echo


# Filtering
echo "Process 4: Filtering data..."
echo
run_script ./scripts/filter/filter-ghana.R 
run_script ./scripts/filter/filter-mali.R 
run_script ./scripts/filter/filter-nigeria.R 
run_script ./scripts/filter/filter-tanzania.R 
run_script ./scripts/filter/filter-uganda.R 
run_script ./scripts/filter/filter-zim_zam.R 
echo
echo "Filtering Done..."
echo
echo "------------------------------------------------------------------------------------------------------------------"
echo
echo
echo
echo




# Imputing
echo "Process 5: Imputing data..."
echo
run_script ./scripts/impute/impute-ghana.R 
run_script ./scripts/impute/impute-mali.R 
run_script ./scripts/impute/impute-nigeria.R 
run_script ./scripts/impute/impute-tanzania.R 
run_script ./scripts/impute/impute-uganda.R 
run_script ./scripts/impute/impute-zim_zam.R 
echo
echo "Imputation Done..."
echo
echo "------------------------------------------------------------------------------------------------------------------"
echo
echo
echo
echo




# Analysis
echo "Process 6: Sensitivity and Specificity Analysis: Analyzing data..."
echo
Rscript ./scripts/analysis/analyze_dbs.R data/ghana/imputed/ghana-standard-filtered-imputed.csv analysis_ghana
Rscript ./scripts/analysis/analyze_dbs.R data/mali/imputed/mali-standard-filtered-imputed.csv analysis_mali
Rscript ./scripts/analysis/analyze_dbs.R data/nigeria/imputed/nigeria-standard-filtered-imputed.csv analysis_nigeria
Rscript ./scripts/analysis/analyze_dbs.R data/tanzania/imputed/tanzania-standard-filtered-imputed.csv analysis_tanzania
Rscript ./scripts/analysis/analyze_dbs.R data/uganda/imputed/uganda-standard-filtered-imputed.csv analysis_uganda
Rscript ./scripts/analysis/analyze_dbs.R data/zim_zam/filtered/zim-zam-standard-filtered.csv analysis_zim_zam
echo
echo "Analysis Done..."
echo
echo "------------------------------------------------------------------------------------------------------------------"
echo
echo
echo
echo




# Merging
echo "Process 7: Merging all individual datasets..."
echo
run_script ./scripts/merge/merge.R 
echo
echo "Merging Done..."
echo
echo "------------------------------------------------------------------------------------------------------------------"
echo
echo
echo
echo

# Analysis
echo "Process 8: Sensitivity and Specificity Analysis: Analyzing all sites data..."
echo
Rscript ./scripts/analysis/analyze_all_sites.R results/analysis_all/all_sites.csv analysis_all
echo
echo "All sites analysis Done..."
echo
echo "------------------------------------------------------------------------------------------------------------------"
echo
echo
echo
echo



# McNemar Test
echo "Process 9: Running McNemar Test on all sited dataset..."
echo
run_script ./scripts/merge/mcnemar_test.R 
echo
echo "McNemar Test Done..."
echo
echo "------------------------------------------------------------------------------------------------------------------"
echo
echo
echo
echo




echo "Data processing pipeline completed successfully."


























