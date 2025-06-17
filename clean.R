library(tidyverse)
library(lubridate)
library(readr)
library(janitor)

# Loading the data, minor data prep --------------------
# Cleaning was done Google Sheets prior
data <- readr::read_csv("data/opportunities_sheets.csv")

# Clean columns
data <- data |> 
   janitor::clean_names()


# Convert character dates to proper datetime formats
data <- data |> 
   # Forward fill missing opportunity_start_date values
   tidyr::fill(opportunity_start_date, .direction = "down") |> 
   dplyr::mutate(institution_name = if_else(is.na(institution_name), "Unknown", institution_name,
if_else(is.na(opportunity_category), "Unknown", opportunity_category)))

# Change all 2148 and 2149 occurrences to 2024
data$opportunity_start_date <- gsub("2148", "2024", data$opportunity_start_date)
data$opportunity_end_date <- gsub("2149", "2024", data$opportunity_end_date)
# Parse to Date format
# Step 1: Extract first 10 characters before parsing
raw_dates <- substr(data$apply_date, 1, 10)

# Step 2: Parse to Date format
data$apply_date <- mdy(raw_dates)

# Step 3: Find rows where parsing failed
bad_rows <- is.na(data$apply_date)

# Step 4: View the original (raw) values that failed
raw_dates[bad_rows]
# Fix the bad rows
data$apply_date[bad_rows] <- dmy(raw_dates[bad_rows])

# Identify rows with invalid years (2146-2149)
bad_years <- !(year(data$apply_date) %in% c(2022, 2023, 2024))

# Loop through bad rows and replace year with year from the row above
for (i in which(bad_years)) {
  if (i > 1 && !is.na(data$apply_date[i - 1])) {
    # Replace just the year, preserving month and day
    fixed_date <- update(data$apply_date[i], year = year(data$apply_date[i - 1]))
    data$apply_date[i] <- fixed_date
  }
}

# Apply same procedure to the Learner Sign Up column 
data <- data |> 
   mutate(learner_sign_up_date_time = mdy(learner_sign_up_date_time))

bad_years_1<- !(year(data$learner_sign_up_date_time) %in% c(2023, 2024))
for (j in which(bad_years_1)) {
  if (j > 1 && !is.na(data$learner_sign_up_date_time[j - 1])) {
    # Replace just the year, preserving month and day
    fixed_date_1 <- update(data$learner_sign_up_date_time[j],
       year = year(data$learner_sign_up_date_time[j - 1]))
    data$learner_sign_up_date_time[j] <- fixed_date_1
  }
}





# Standardize gender capitalization
data <- data %>%
   dplyr::mutate(gender = str_to_title(gender))

# Check for missing values across columns
missing_summary <- sapply(data, function(x) sum(is.na(x)))
print(missing_summary)

# Save the cleaned data
readr::write_csv(data, "data/cleaned_opportunities.csv")
# -----------------------------------------------------

# Investigating opportunties that only go for hours.
# of_interest <- c("Freelance Mastery workshop", "Startup Mastery Workshop")
# test <- readr::read_csv("data/opportunities.csv")
# test <- test |> 
#    janitor::clean_names() |> 
#    filter(opportunity_name %in% of_interest) |> 
#    select(opportunity_name, opportunity_start_date, opportunity_end_date)
