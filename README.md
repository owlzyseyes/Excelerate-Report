# Excelerate Report Analysis

A comprehensive analysis of student opportunities offered by Saint Louis University through the Excelerate platform. This project examines application patterns, participation trends, and demographic distributions to understand student engagement with various career development opportunities.

## 📊 Project Overview

This analysis focuses on opportunities provided through the Excelerate platform, including:
- **Courses** - Extended learning programs
- **Competitions** - Skill-based challenges
- **Internships** - Professional work experiences  
- **Events** - Short-term workshops (typically 2.5 hours for Mastery Workshops)
- **Engagements** - Interactive sessions

## 🧹 Data Cleaning Process

The raw data underwent extensive cleaning to ensure accurate analysis. The cleaning process is documented in `clean.R` and addressed several key issues:

### Date Formatting Issues
- **Problem**: Inconsistent date formats and erroneous years (2146-2149 instead of 2022-2024)
- **Solution**: 
  - Standardized date parsing using multiple formats (MDY, DMY)
  - Corrected invalid years by replacing with previous valid year entries
  - Applied forward-fill for missing opportunity start dates

### Data Standardization
- **Column Names**: Applied `janitor::clean_names()` for consistent snake_case formatting
- **Gender Values**: Standardized capitalization using `str_to_title()`
- **Missing Values**: Replaced NA institution names with "Unknown"
- **Date Corrections**: Fixed systematic errors where 2148→2024 and 2149→2024

### Key Cleaning Steps
```r
# Date correction example
data$opportunity_start_date <- gsub("2148", "2024", data$opportunity_start_date)
data$opportunity_end_date <- gsub("2149", "2024", data$opportunity_end_date)

# Year correction for invalid entries
for (i in which(bad_years)) {
  if (i > 1 && !is.na(data$apply_date[i - 1])) {
    fixed_date <- update(data$apply_date[i], year = year(data$apply_date[i - 1]))
    data$apply_date[i] <- fixed_date
  }
}
```

## 🔍 Key Research Questions Answered

### 1. **Application Trends Over Time**
- **Question**: How do application numbers compare between 2023 and 2024?
- **Finding**: Analysis shows year-over-year changes in application volumes across different opportunity types

### 2. **Geographic Distribution**
- **Question**: What are the top countries learners come from?
- **Analysis**: Identified primary geographic sources of participants, with countries representing <1% grouped as "Others"

### 3. **Gender Representation**
- **Question**: How does gender distribution vary across different opportunities?
- **Insight**: Examined participation patterns by gender across various program types

### 4. **Program Competitiveness**
- **Question**: Which opportunities have higher rejection rates?
- **Key Finding**: Project Management and Data Visualization roles appear to be the most competitive opportunities

### 5. **Sign-up Patterns**
- **Question**: How do learner sign-ups compare between 2023 and 2024?
- **Analysis**: Tracked enrollment trends to understand program growth and popularity

## 📈 Analysis Components

### Data Exploration (`explore.R`)
- Application difference calculations between years
- Country-based learner distribution analysis
- Gender distribution across opportunities
- Rejection rate calculations by program type

### Visualization (`data/plotting/`)
- **Rejection Rates**: Circular bar chart showing total applicants with rejection rate color coding
- **Application Differences**: Year-over-year comparison data
- **Geographic Distribution**: Country-wise learner participation data

## 🛠 Technical Stack

- **R**: Primary analysis language (19.7% of codebase)
- **JavaScript**: Interactive visualizations (71% of codebase)
- **HTML**: Report presentation (9.3% of codebase)

### Key R Packages Used
- `readr`: Data import/export
- `dplyr`: Data manipulation
- `tidyr`: Data tidying
- `janitor`: Data cleaning
- `lubridate`: Date handling
- `ggplot2`: Data visualization

## 📁 Project Structure

```
├── clean.R                    # Data cleaning script
├── explore.R                  # Exploratory data analysis
├── data/
│   ├── opportunities_sheets.csv    # Raw data
│   ├── cleaned_opportunities.csv   # Processed data
│   └── plotting/                   # Analysis outputs
│       ├── app_differences.csv
│       ├── learners_country.csv
│       └── rejection_rates.csv
└── Assets/                    # Web assets and fonts
```

## 🔧 Usage

1. **Data Cleaning**: Run `clean.R` to process raw data
2. **Analysis**: Execute `explore.R` for comprehensive EDA
3. **Visualization**: Generated CSV files in `data/plotting/` feed into visualization components

## 📋 Data Quality Notes

- **Initial Data Issues**: Raw data contained systematic date errors and formatting inconsistencies
- **Cleaning Impact**: Processed dataset provides reliable foundation for analysis
- **Missing Data**: Handled through forward-filling and "Unknown" categorization where appropriate

## 🎯 Key Insights

The analysis reveals important patterns in student engagement with Excelerate opportunities, highlighting the competitive nature of certain programs and geographic diversity of participants. The data cleaning process was crucial for ensuring accurate temporal analysis, particularly given the systematic date errors in the original dataset.

---
