#!/usr/bin/env bash

# # Function to create required directories
# create_directories() {
#   directories=("results/processing" "results/eda/maps" "results/analysis")
#   for dir in "${directories[@]}"; do
#     if [[ ! -d $dir ]]; then
#       mkdir -p $dir
#       echo "Created directory: $dir"
#     fi
#   done
# }

# Function to ensure necessary R packages are installed
install_packages() {
  Rscript --vanilla -e "
    packages <- c('tidyverse','dplyr', 'readxl', 'sf', 'writexl', 'ggplot2', 'corrplot', 'naniar', 'reshape2', 'geodata', 'dots', 
                  'stringr', 'ggspatial', 'terra', 'elevatr', 'magick', 'rgl', 'rnaturalearth', 'rnaturalearthdata', 'tidyr',
                  'tidygeocoder', 'ggmap')
    install_if_missing <- function(p) {
      if (!requireNamespace(p, quietly = TRUE)) {
        install.packages(p, repos = 'https://cran.rstudio.com/')
      }
    }
    invisible(sapply(packages, install_if_missing))
  "
}

echo "Running configuration setup..."
echo

# # Create required directories
# create_directories


# Install necessary R packages
echo "Installing necessary R packages..."
echo
install_packages
echo "R packages installed."
echo
echo "Configuration setup completed successfully."
echo
echo "--------------------------------------"
echo
echo

# conda install -c conda-forge r-DescTools