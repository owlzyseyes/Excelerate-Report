library(tidyverse)
library(readr)
library(janitor)

# Loading the data, minor data prep --------------------
# Cleaning was done Google Sheets prior
data <- readr::read_csv("data/opportunities_sheets.csv")

# Clean columns
 data <- data |> 
   janitor::clean_names()


 # Convert character dates to proper datetime formats
 data <- data %>%
   # Forward fill missing opportunity_start_date values
   tidyr::fill(opportunity_start_date, .direction = "down") |> 
   dplyr::mutate(institution_name = if_else(is.na(institution_name), "Unknown", institution_name))

 # Change all "2148" occurrences to 2024
  data$opportunity_start_date <- gsub("2148", "2024", data$opportunity_start_date)

 # Standardize gender capitalization
 data <- data %>%
   dplyr::mutate(gender = str_to_title(gender))

 # Check for missing values across columns
 missing_summary <- sapply(data, function(x) sum(is.na(x)))
 print(missing_summary)

 # Save the cleaned data
 readr::write_csv(data, "data/cleaned_opportunities.csv")
# -----------------------------------------------------