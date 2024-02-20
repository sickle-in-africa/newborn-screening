suppressMessages(library(tidyverse))
suppressMessages(library(rstatix))
suppressMessages(library(modi))
suppressMessages(library(outliers))
suppressMessages(library(kableExtra))
suppressMessages(library(knitr))
suppressMessages(library(fmsb))

ggplot <- function(...) ggplot2::ggplot(...) + theme(text=element_text(size=15))

import_data <- function(filename) {
	read.csv(filename) %>%
	as_tibble() %>%
	return()
}

test_record_completeness <- function(input_data) {
	TYPE = "record\ncompleteness"
	input_data %>%
	    mutate(record_length = ncol(input_data) - rowSums(is.na(input_data))) %>%
	    mutate(max_record_length = ncol(input_data)) %>%
	    mutate(completeness = record_length/max_record_length) %>%
	   	mutate(id = participant_id) %>%
	    mutate(type = TYPE) %>%
	    mutate(value = completeness) %>%
	    select(id, value, type) -> output_data

	    output_data %>%
	    	mutate(value = 100*value) %>%
	    	ggplot(aes(x=value)) +
	    		geom_histogram(bins=10) +
	    			labs(x='record completeness (%)') -> output_plot

	    output_data %>%
	    	filter(value <= 0.999) %>%
	    	select(id, value) -> output_queries

	    list(
	    	TYPE,
	    	output_data,
	    	output_plot,
	    	fivenum(output_data$value),
	    	output_queries) -> output
	    names(output) <- c('type','data', 'plot', 'fivenum', 'queries')

	    return(output)
}

test_column_completeness <- function(input_data) {
	TYPE = 'column\ncompleteness'
	data.frame() %>% as_tibble() -> output_data
	for (i in 1:ncol(input_data)){
		rbind(
			output_data,
			c(
				colnames(input_data[i]),
				sum(!is.na(input_data[i]))/nrow(input_data))) %>%
		as_tibble() -> output_data
	}
	colnames(output_data) <- c('id', 'value')
	as.factor(output_data$id) -> output_data$id
	as.numeric(output_data$value) -> output_data$value
	output_data %>% 
		mutate(type = TYPE) -> output_data

	output_data %>%
		mutate(value = 100*value) %>%
		ggplot(aes(y=reorder(id, value), x=value)) + 
			geom_bar(stat='identity') + 
			labs(x='column completeness (%)', y=element_blank()) + theme(text=element_text(size=15)) -> output_plot

	output_data %>% 
		filter(value < 0.999) %>% 
		select(id, value) -> output_queries

	list(
		TYPE,
		output_data,
		output_plot,
		fivenum(output_data$value),
		output_queries) -> output
	names(output) <- c('type', 'data', 'plot', 'fivenum', 'queries')

	return(output)
}

test_duplicates <- function(input_data) {
	TYPE = 'record\nuniqueness'

	input_data %>% select(participant_id) %>% duplicated() -> input_data$duplicated

	input_data %>% filter(!duplicated) %>% nrow() -> number_duplicate_records

	data.frame(
		id=1:nrow(input_data),
		value=c(
			rep(1,number_duplicate_records),
			rep(2,nrow(input_data) - number_duplicate_records)),
		type=TYPE) %>%
		as_tibble() %>%
		mutate(value = as.integer(value)) -> output_data

	output_data %>%
		ggplot(aes(x=value)) + 
			geom_bar() +
			labs(x='number of record copies') +
			scale_x_discrete(limits=c("1","2")) -> output_plot

	output_data %>%
		mutate(value = 1/value) -> output_data

	input_data %>% filter(duplicated) %>% select(!duplicated) -> queries

	list(
		TYPE,
		output_data,
		output_plot,
		fivenum(output_data$value),
		queries) -> output
	names(output) <- c('type','data', 'plot', 'fivenum', 'queries')

	return(output)
}

quality_score <- function(input_fivenum) {
	sort(input_fivenum) -> input_fivenum
	#weights <- c(1,2,3,2,1)
	weights <- c(1,1,1,1,1)
	return(round(100 * sum(weights * input_fivenum) / sum(weights), digits=1))
}

get_quality_grade <- function(input_quality_score) {
	ifelse(input_quality_score >= 80, 'A',
		ifelse(input_quality_score >= 60, 'B', 
			ifelse(input_quality_score >= 40, 'C',
				ifelse(input_quality_score >= 20, 'D', 'E'))))
}

merge_boxplot_data <- function(input_results) {
	get_composite_fivenum(input_results) -> total_fivenum
	data.frame(id = c(1:5), value = total_fivenum, type = 'total') %>% as_tibble() -> output_data
	for(result in results) {
		rbind(output_data, result$data) -> output_data
	}
	return(as_tibble(output_data))
}

plot_quality_fivenum_boxes <- function(input_boxplot_data) {
	input_boxplot_data %>%
		mutate(value = 100*value) %>%
	 	ggplot(aes(x=value, y=type)) +
	 		geom_boxplot() + labs(x='quality index', y=element_blank()) %>%
		return()
}

get_quality_scores <- function(input_results) {
	type = c()
	quality_score = c()
	for(result in input_results) {
		c(type, result$type) -> type
		c(quality_score, quality_score(result$fivenum)) -> quality_score
	}
	data.frame(
		type = type,
		quality_score = quality_score,
		quality_grade = get_quality_grade(quality_score)
		) %>%
		as_tibble() %>%
		return()
}

get_composite_fivenum <- function(input_results) {
	fivenums = c()
	for (result in input_results) {
		c(fivenums, result$fivenum) -> fivenums
	}
	fivenums %>%
		fivenum() %>%
		return()
}

plot_quality_fivenum_box <- function(input_fivenum) {
	boxplot(input_fivenum, range=0)
}

firstup <- function(x) {
  substr(x, 1, 1) <- toupper(substr(x, 1, 1))
  x
}

get_summary_table <- function(input_data, input_fivenum) {
	c(
		'Study type',
		'Phase', 
		'Sparco site(s)', 
		'Number of records', 
		'Number of columns',
		'Overall grade') -> names
	c(
		'Newborn Screening',
		'0 (preliminary)',
		firstup(c(paste(unique(input_data$country), collapse=', '))),
		# paste(unique(input_data$country), collapse=', '), 
		as.character(nrow(input_data)), 
		as.character(ncol(input_data)),
		get_quality_grade(quality_score(input_fivenum))) -> values

	data.frame(Names = names, Values = values) %>%
		as_tibble() %>%
		return()
}

plot_quality_score_lollipop <- function(input_results) {
	get_quality_scores(input_results) %>%
		as_tibble() %>%
		ggplot(aes(x=quality_score, y=reorder(type, quality_score))) +
    		geom_point(size=5) +
    		geom_segment(aes(x=0, xend=quality_score, y=type, yend=type)) +
    		xlim(0,100) +
    		labs(x='quality score', y=element_blank()) %>%
    	return()
}