# Excelerate Report Analysis

A comprehensive analysis of student opportunities offered by Saint Louis University through the Excelerate platform. This project examines application patterns, participation trends, and demographic distributions to understand student engagement with various career development opportunities.

## 📊 Project Overview

This analysis focuses on opportunities provided through the Excelerate platform, including:
- **Courses** - Extended learning programs
- **Competitions** - Skill-based challenges
- **Internships** - Professional work experiences  
- **Events** - Short-term workshops (typically 2.5 hours for Mastery Workshops)
- **Engagements** - Interactive sessions

## 📄 Final Report

The complete analysis is available in multiple formats:

### **📊 [View Full Report (PDF)](./report/report.pdf)**
### **🌐 [Interactive HTML Version](./report/report.html)**

**Report Title:** *"Excelerate Program Analysis: A Two-Year Comparative Study of Global Learner Engagement and Outcomes (2023-2024)"*

The report presents a comprehensive two-year comparative study analyzing:
- Global learner engagement patterns
- Sign-up and application trends
- Success and rejection rates
- Geographic distribution of participants
- Demographic analysis across opportunity types
- Program competitiveness insights

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
- **Finding**: 28% increase from 3,737 applications (2023) to 4,777 applications (2024)

### 2. **Geographic Distribution**
- **Question**: What are the top countries learners come from?
- **Analysis**: Identified primary geographic sources of participants, with countries representing <1% grouped as "Others"

### 3. **Program Growth**
- **Question**: How do learner sign-ups compare between years?
- **Finding**: 5,794 sign-ups in 2023, with 2,764 additional sign-ups in 2024

### 4. **Program Competitiveness**
- **Question**: Which opportunities have higher rejection rates?
- **Key Finding**: Project Management and Data Visualization roles appear to be the most competitive opportunities

### 5. **Gender Representation**
- **Question**: How does gender distribution vary across different opportunities?
- **Insight**: Examined participation patterns by gender across various program types

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

## 📁 Project Structure

```
├── README.md                       # Project documentation
├── clean.R                         # Data cleaning script
├── explore.R                       # Exploratory data analysis
├── renv.lock                       # R package dependencies
├── data/
│   ├── opportunities_sheets.csv    # Raw data
│   ├── cleaned_opportunities.csv   # Processed data
│   └── plotting/                   # Analysis outputs
│       ├── app_differences.csv
│       ├── learners_country.csv
│       └── rejection_rates.csv
├── report/                         # Final report and outputs
│   ├── report.qmd                  # Quarto source document
│   ├── report.pdf                  # 📄 FINAL PDF REPORT
│   ├── report.html                 # 🌐 Interactive HTML version
│   ├── report.log                  # LaTeX compilation log
│   ├── images/                     # Report visualizations
│   └── report_files/               # Supporting web assets
└── Assets/                         # Web assets and fonts
    └── Fonts/
        └── fontawesome/            # Icon fonts for web display
```

## 🔧 Usage

1. **Data Cleaning**: Run `clean.R` to process raw data
2. **Analysis**: Execute `explore.R` for comprehensive EDA
3. **Report Generation**: Use Quarto to render `report.qmd` to PDF/HTML
4. **View Results**: Open `report/report.pdf` or `report/report.html`

## 📋 Data Quality Notes

- **Initial Data Issues**: Raw data contained systematic date errors and formatting inconsistencies
- **Cleaning Impact**: Processed dataset provides reliable foundation for analysis
- **Missing Data**: Handled through forward-filling and "Unknown" categorization where appropriate
- **Validation**: Cross-referenced cleaned data against original sources to ensure accuracy

## 🎯 Key Insights

The analysis reveals important patterns in student engagement with Excelerate opportunities:

- **Strong Growth**: 28% increase in applications and significant growth in learner sign-ups
- **Global Reach**: Diverse international participation with clear geographic patterns
- **Program Competitiveness**: Varying rejection rates across different opportunity types
- **Demographic Trends**: Insights into gender distribution and participation patterns

The comprehensive data cleaning process was crucial for ensuring accurate temporal analysis, particularly given the systematic date errors in the original dataset.

## 👨‍💻 Author

**Brian Mubia** - [GitHub](https://github.com/owlzyseyes) | [LinkedIn](https://linkedin.com/in/brian1001)

---

**🔗 Quick Links:**
- **[📊 Full PDF Report](./report/report.pdf)**
- **[🌐 Interactive HTML Report](./report/report.html)**
- **[📈 Data Visualizations](./report/images/)**
