library(dplyr)
library(scales)
library(ggplot2)
library(stringr)

rejections <- readr::read_csv("data/plotting/rejection_rates.csv")

# how high should our grid lines go?
max_app  <- max(rejections$total_applicants)
grid_df  <- data.frame(y = seq(0, max_app, by = 200))

plt <- ggplot(rejections) +
  # 1) background grid
  geom_hline(aes(yintercept = y),
             data = grid_df,
             color = "lightgrey") +
  # 2) bars = total applicants, filled by rejected count
  geom_col(aes(
    x    = reorder(str_wrap(opportunity_name, 15), total_applicants),
    y    = total_applicants,
    fill = rejection_rate
  ),
  alpha = .9) +
  # 3) make it circular
  coord_polar() +
  # 4) color scale for rejected counts
  scale_fill_gradientn(
    "Rejection Rate",  # 
    colours = c("#6C5B7B", "#C06C84", "#F67280", "#F8B195"),
    labels = scales::percent_format(accuracy = 1)
  ) +
  # 5) y-axis scaling
  scale_y_continuous(
    limits = c(-200, max_app + 100),
    expand = c(0, 0),
    breaks = seq(0, max_app, by = 200)
  ) +
  # 6) make the fill legend into a stepped bar
  guides(
    fill = guide_colorsteps(
      barwidth      = 15,
      barheight    = .8,
      title.position = "top",
      title.hjust   = .5,
      label.theme = element_text(size = 14)
    )
  ) +
  # 7) clean up the theme with increased text sizes and margins
  theme_minimal() +
  theme(
    axis.title    = element_blank(),
    axis.ticks    = element_blank(),
    axis.text.y   = element_blank(),
    axis.text.x   = element_text(color = "gray12", size = 16),
    legend.title  = element_text(size = 14),
    legend.text   = element_text(size = 12),
    legend.position = "bottom",
    panel.grid     = element_blank(),
    # Add generous margins (top, right, bottom, left)
    plot.margin = margin(30, 30, 30, 30, "pt")
  )

# Add annotation for what the bars represent
n_opps <- nrow(rejections)
plt2 <- plt +
  # Move "Total Applicants" label slightly inward
  annotate(
    x      = n_opps,
    y      = max_app * 0.95,
    label  = "Total Applicants",
    geom   = "text",
    angle  = 20,
    color  = "gray12",
    size   = 3.5,
    family = "Bell MT"
  ) +
  # Move tick labels slightly inward
  annotate(
    x     = n_opps + 0.2,
    y     = seq(200, 800, by = 200),
    label = seq(200, 800, by = 200),
    geom  = "text",
    color = "gray12",
    size  = 5,
    family= "Bell MT"
  ) +
  # Add labels
  labs(
    title = "\nOpportunity Applications Overview",
     subtitle = paste(
      "\nThis visualization shows the total number of applications",  # Added \n for spacing
      "and rejection counts across different opportunities offered by SLU via Excelerate.",
      "\nProject Management and Data Visualization roles appear to be the most competitive,",
      "with higher application volumes and rejection counts.",
      sep = "\n"
    ),
    caption = paste(
      "\n\nData Visualization by", "Brian Mubia",
      format(Sys.time(), "\nCreated on %Y-%m-%d"),
      sep = " "
    )
  ) +
  # Customize general theme
  theme(
    # Set default color and font family
    text = element_text(color = "gray12", family = "Bell MT"),
    
    # Customize title, subtitle, and caption
    plot.title = element_text(face = "bold", size = 30, hjust = 0.05),
    plot.subtitle = element_text(size = 19, hjust = 0.05, lineheight = 1.2),
    plot.caption = element_text(size = 15, hjust = 0.5),
    
    # Proper margins
    panel.background = element_blank(),
    plot.background = element_rect(fill = "white", color = NA),
    plot.margin = margin(50, 50, 50, 50, "pt"),
    panel.grid = element_blank(),
    panel.grid.major.x = element_blank()
  )

# Save with adjusted dimensions
ggsave("test.png", 
       plt2, 
       width = 12,
       height = 14,
       units = "in",
       dpi = 300)

# Export for editing in Illustrator
ggsave("visualization.pdf", 
       plt2, 
       width = 14,
       height = 16,
       units = "in",
       device = cairo_pdf)
