#!/usr/bin/env bash
# For this script you need to pass an imputed data file, for example:
#
# ./scripts/analysis/analyze.sh data/imputed/nigeria-standard-filtered-imputed.csv 

input_data_file=$1

./scripts/analysis/analyze_gs.R $input_data_file
./scripts/analysis/analyze_poct.R $input_data_file 
./scripts/analysis/analyze_dbs.R $input_data_file