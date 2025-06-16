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

# Q: Is there a correlation between signups and rejection rates in general?
cor(rejection_augmented$total_applicants, rejection_augmented$rejection_rate)
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

# Closer look into internships with extreme rejection rates
extreme_internship_rejections <- rejection_augmented |>
  filter(
    opportunity_category == "Internship",
    rejection_rate < 0.5 | rejection_rate > 0.8
  ) |>
  left_join(
    opportunity_durations |> select(opportunity_name, duration_days, start_year),
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




# Q: How long do opportunities typically last? Have the durations changed between the two years?
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

summary(opportunity_durations$duration_days)

# Q: Which country's learners are more likely to secure opportunities? Has this changed
# between the two years? Which country's learners are the most competitive (Competition
# opportunties)? Which country's learners are more likey to secure internships? 