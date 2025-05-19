#!/usr/bin/env Rscript
library(pagedown)

args = commandArgs(trailingOnly=TRUE)
{if (!file.exists(args[1])) {stop("Error: input data file not found")}}

rmarkdown::render(
	input = './scripts/quality-control/quality-report.Rmd',
	output_dir = 'media/quality-control/quality-report',
	params = list(input_filename = args[1], output_directory='media/quality-control/quality-report/'))

import_data(args[1]) -> data
list(
	test_record_completeness(data),
	test_column_completeness(data),
	test_duplicates(data)) -> results
merge_boxplot_data(results) -> boxplot_data
get_composite_fivenum(results) -> total_fivenum
grade <- get_quality_grade(quality_score(total_fivenum))

if(grade == "A"){
  
  rmarkdown::render(
    input = './scripts/quality-control/quality-certificate-gold.Rmd',
    output_dir = 'media/quality-control/quality-report',
    output_file = 'quality-certificate.html',
    params = list(input_filename = args[1], output_directory='media/quality-control/quality-report/'))
  
}else if(grade == "B"){
  
  rmarkdown::render(
    input = './scripts/quality-control/quality-certificate-silver.Rmd',
    output_dir = 'media/quality-control/quality-report',
    params = list(input_filename = args[1], output_directory='media/quality-control/quality-report/'))
  
}else{
  
  rmarkdown::render(
    input = './scripts/quality-control/quality-certificate-bronze.Rmd',
    output_dir = 'media/quality-control/quality-report',
    params = list(input_filename = args[1], output_directory='media/quality-control/quality-report/'))
  
}