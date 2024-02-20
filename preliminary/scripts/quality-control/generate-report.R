#!/usr/bin/env Rscript

args = commandArgs(trailingOnly=TRUE)
{if (!file.exists(args[1])) {stop("Error: input data file not found")}}

rmarkdown::render(
	input = './scripts/quality-control/quality-report.Rmd',
	output_dir = 'media/quality-control/quality-report',
	params = list(input_filename = args[1], output_directory='media/quality-control/quality-report/'))

rmarkdown::render(
	input = './scripts/quality-control/quality-certificate.Rmd',
	output_dir = 'media/quality-control/quality-report',
	output_file = 'quality-certificate.html',
	params = list(input_filename = args[1], output_directory='media/quality-control/quality-report/'))