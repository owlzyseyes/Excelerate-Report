library(tidyverse)
library(readr)
library(janitor)

# Notes: 
# 22 Opportunities of 4 types are offered in this program.
# Either Course, Competition, Internship, Event or Engagement.

# Load the clean stuff.
data <- readr::read_csv("data/cleaned_opportunities.csv")
colnames(data)

# EDA Questions 🤔💭--------------------------------------------------------

# Q1: How does the number of signups compare over the years?

signups_by_year <- data |> 
  mutate(
    learner_sign_up_date_time = parse_date_time(learner_sign_up_date_time, orders = c("mdy", "dmy", "ymd"))
  ) |> 
  mutate(signup_year = year(learner_sign_up_date_time)) |> 
  filter(signup_year >= 2015 & signup_year <= year(Sys.Date())) |>  # Filter out future/malformed years
  group_by(signup_year) |> 
  summarize(signups = n())

differences <- data |> 
  mutate(
    learner_sign_up_date_time = parse_date_time(learner_sign_up_date_time, orders = c("mdy", "dmy", "ymd"))
  ) |> 
  mutate(signup_year = year(learner_sign_up_date_time)) |> 
  filter(signup_year >= 2015 & signup_year <= year(Sys.Date())) |>  # Filter out future/malformed years
  group_by(opportunity_name, signup_year) |> 
  summarize(signups = n(), .groups = "drop") |> 
  pivot_wider(
    names_from = signup_year,
    values_from = signups,
    names_prefix = "signups_",
    values_fill = 0
  ) |> 
  mutate(difference = signups_2024 - signups_2023) |> 
  arrange(desc(difference))

# Q: What are the top countries learners come from?
top_countries <- data |> 
  count(country, sort = TRUE)

# Q: How does gender distribution vary across opportunities?
gender_by_opportunity <- data |> 
  group_by(opportunity_name, gender) |> 
  summarize(count = n(), .groups = "drop") |> 
  arrange(opportunity_name, desc(count)) |> 
  pivot_wider(names_from = gender, values_from = count, values_fill = 0)


# Q: Which opportunities have higher rejection rates than others?

rejection_rates <- data |> 
  group_by(opportunity_name) |> 
  summarize(
    total_applicants = n(),
    rejected_count = sum(str_to_lower(status_description) == "rejected"),
    rejection_rate = rejected_count / total_applicants,
    .groups = "drop"
  ) |> 
  arrange(desc(rejection_rate))

gender_rejection_wide <- data |> 
  mutate(gender = str_to_title(gender)) |> 
  filter(gender %in% c("Male", "Female")) |> # Filtered because result produces lots of missing values
  group_by(opportunity_name, gender) |> 
  summarize(
    total = n(),
    rejected = sum(str_to_lower(status_description) == "rejected"),
    rejection_rate = rejected / total,
    .groups = "drop"
  ) |> 
  select(opportunity_name, gender, rejection_rate) |> 
  pivot_wider(
    names_from = gender,
    values_from = rejection_rate,
    names_prefix = "rejection_rate_"
  )

# 3. Join both
rejection_augmented <- rejection_rates |> 
  left_join(gender_rejection_wide, by = "opportunity_name") |> 
  arrange(desc(rejection_rate))

# Q: How long do opportunities typically last? Have the durations changed between the two years?
# Q: Is there a correlation between signups and rejection rates for opportunities?
# Q: Which country's learners are more likely to secure opportunities? Has this changed
# between the two years? Which country's learners are the most competitive (Competition
# opportunties)? How about internships? 