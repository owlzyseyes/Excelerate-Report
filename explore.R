library(tidyverse)
library(readr)
library(janitor)

# Notes: 
# 22 Opportunities of 4 types are offered in this program.
# Either Course, Competition, Internship, Event or Engagement.
# Events, specifically Mastery Workshops, go for 2h 30min. 

# Load the clean stuff.
data <- readr::read_csv("data/cleaned_opportunities.csv")
colnames(data)

# EDA Questions 🤔💭--------------------------------------------------------

# Q1: How does the number of signups compare between 2023 and 2024?
signups_by_year <- data |> 
  mutate(
    learner_sign_up_date_time = parse_date_time(learner_sign_up_date_time, orders = c("mdy", "dmy", "ymd"))
  ) |> 
  mutate(signup_year = year(learner_sign_up_date_time)) |> 
  filter(signup_year >= 2015 & signup_year <= year(Sys.Date())) |>  # Filter out future/malformed years
  group_by(signup_year) |> 
  summarize(signups = n())

# Q2: How do applications compare for the last two years?
differences <- data |>
  mutate(apply_year = year(apply_date)) |> 
  filter(apply_year %in% c(2023, 2024)) |> 
  group_by(opportunity_name, apply_year) |> 
  summarize(applications = n(), .groups = "drop") |> 
  pivot_wider(
    names_from = apply_year,
    values_from = applications,
    names_prefix = "applications_",
    values_fill = 0
  ) |> 
  mutate(difference = applications_2024 - applications_2023) |> 
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

# Q: Is there a correlation between applications and rejection rates in general?
cor(rejection_augmented$total_applicants, rejection_augmented$rejection_rate)

# Q: How long do opportunities typically last?
opportunity_durations <- data |>
  select(opportunity_name, opportunity_category, opportunity_start_date, opportunity_end_date) |>
  distinct() |>
  mutate(
    opportunity_start_date = as_date(parse_date_time(opportunity_start_date, orders = c("mdy HMS", "mdy HM", "mdy"))),
    opportunity_end_date   = as_date(parse_date_time(opportunity_end_date, orders = c("mdy HMS", "mdy HM", "mdy"))),
    duration_days          = abs(as.numeric(opportunity_end_date - opportunity_start_date)),
    start_year             = year(opportunity_start_date)
  ) |> 
  # Filter out extremely long durations
  filter(duration_days <= 150) |> 
  mutate(duration_days = if_else(duration_days == 0, 2.5/24, duration_days))

# Stratifying by opportunity category
rejection_augmented <- rejection_augmented |>
  left_join(
    opportunity_durations |> select(opportunity_name, opportunity_category),
    by = "opportunity_name"
  )

rejection_augmented|> 
  filter(opportunity_category == "Internship") |>
  summarize(
    correlation = cor(total_applicants, rejection_rate),
    .groups = "drop"
  )


opportunity_durations_unique <- opportunity_durations |>
  distinct(opportunity_name, .keep_all = TRUE)


# Closer look into internships with extreme rejection rates
extreme_internship_rejections <- rejection_augmented |>
  filter(
    opportunity_category == "Internship",
    rejection_rate < 0.5 | rejection_rate > 0.8
  ) |>
  left_join(
    opportunity_durations_unique |> select(opportunity_name, duration_days, start_year),
    by = "opportunity_name"
  ) |>
  select(
    opportunity_name,
    total_applicants,
    rejected_count,
    rejection_rate,
    rejection_rate_Female,
    rejection_rate_Male,
    duration_days,
    start_year
  )

# Note: Internships in Health Care Management have the lowest rejection rates (42%)
# while those in Business Consulting are outstandingly difficult to secure, at 82%.

ggplot(rejection_augmented, aes(x = total_applicants, y = rejection_rate, color = opportunity_category)) +
  geom_point(size = 3, alpha = 0.8) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(
    title = "Rejection Rate vs Signups by Opportunity Category",
    x = "Total Applicants",
    y = "Rejection Rate",
    color = "Category"
  ) +
  theme_minimal()

summary(opportunity_durations$duration_days)

# Q: Which country's learners are more likely to secure opportunities? Has this changed
# between the two years? 
secure_statuses <- c("Started", "Team Allocated", "Rewards Award")

country_success <- data |>
  group_by(country) |>
  summarize(
    total_applications = n(),
    successful = sum(status_description %in% secure_statuses),
    success_rate = successful / total_applications,
    .groups = "drop"
  ) |>
  arrange(desc(success_rate)) |> 
  filter(total_applications >= 20)


# Which country's learners are more likey to secure internships?
success_statuses <- c("Started", "Team Allocated")

country_internship_success <- data |> 
  filter(opportunity_category == "Internship") |>
  group_by(country) |> 
  summarize(
    total_applications = n(),
    successful = sum(status_description %in% success_statuses),
    success_rate = successful / total_applications
  ) |>
  filter(total_applications >= 10) |>  # Filter noisy countries
  arrange(desc(success_rate))

country_success_by_year <- data |>
  filter(opportunity_category == "Internship") |>
  mutate(apply_year = year(apply_date)) |>
  group_by(country, apply_year) |>
  summarize(
    total_applications = n(),
    successful = sum(status_description %in% success_statuses),
    success_rate = successful / total_applications,
    .groups = "drop"
  )

# Which country's learners are the most competitive (Competition
# opportunties)?  

compete <- data |> 
  filter(opportunity_category == "Competition",
  status_description %in% c("Team Allocated", "Applied")) |>
  group_by(country) |> 
  summarize(total_applications = n(), .groups = "drop") |> 
  arrange(desc(total_applications))

