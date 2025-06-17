library(tidyverse)
library(showtext)
library(ggtext)
library(glue)
library(showtext)
library(patchwork)

# Example input: differences dataframe
# differences has: opportunity_name, applications_2023, applications_2024, difference

# Add fonts
font_add_google("Poppins", "pop", regular.wt = 200)
showtext_auto()

# Basic colors and formatting
txt <- "white"
accent <- txt
bg <- "grey20"
bg1 <- "grey20"
bg2 <- "grey10"
line <- "grey30"
sunset <- c("#355070", "#6d597a", "#b56576", "#e56b6f", "#eaac8b")
pal <- c("#ee4266", "#3bceac")

font_add("fa-brands", regular = "Assets/Fonts/Fontawesome/webfonts/fa-brands-400.ttf")
font_add("fa-solid", regular = "Assets/Fonts/Fontawesome/webfonts/fa-solid-900.ttf")

ft <- "pop"
showtext_auto()

# Reorder opportunities by 2024 applications for better visual sorting
df <- readr::read_csv("data/plotting/app_differences.csv") 
df <- df |> 
  mutate(opportunity_name = fct_reorder(opportunity_name, applications_2024))

df <- df |>
  mutate(increasing = applications_2024 > applications_2023,
         order = applications_2023 + ifelse(increasing, 1e6, 0)) |>
  mutate(opportunity_name = fct_reorder(opportunity_name, order))

df <- df |> mutate(increasing = applications_2024 > applications_2023)

# Add this manually when adjusting for the plot,Then add it to the chart using geom_text()
df_text <- tibble(
  x = 650,
  y = factor(c("AI Ethics Challenge", "UrbanRenew Challenge")),
  increasing = c(FALSE, TRUE),
  text = str_wrap(c("Declining interest in opportunity", "Rising interest in opportunity"), 10)
)

df_increasing <- df |>
  mutate(increasing = applications_2024 > applications_2023) |>
  distinct(opportunity_name, increasing) |>
  mutate(col = pal[as.integer(increasing) + 1])


df <- df |> mutate(opportunity_name = fct_relabel(opportunity_name, ~ str_wrap(.x, width = 20)))


caption <- make_caption(c(txt, sunset[c(2, 5)]), bg)

subtitle <- "The Excelerate program has continued to attract increasing learner engagement, with more signups and opportunity applications in 2024 compared to 2023. While some opportunities saw steady interest, others experienced sharp increases in applications, highlighting shifting learner priorities and program visibility."
title <- "Excelerate Program: Shifts in Opportunity Applications"


# Plot 
df |> 
ggplot() +
  geom_segment(aes(x = applications_2023, xend = applications_2024, y = fct_reorder(opportunity_name, difference), yend = opportunity_name),
               colour = "gray70", linewidth = 1.5) +
  geom_point(aes(x = applications_2023, y = opportunity_name),
             colour = sunset[2], size = 5) +
  geom_point(aes(x = applications_2024, y = opportunity_name),
             colour = sunset[5], size = 5) +
  geom_text(aes(x, y, label = text), df_text, family = ft, size = 33, hjust = 0, vjust = 1, lineheight = 0.25, fontface = "bold", colour = pal) +
  scale_x_continuous(breaks = scale_x, labels = scale_x) +
  scale_colour_manual(values = sunset[c(2, 5)]) +
  labs(
    title = title,
    subtitle = str_wrap(subtitle, 120),
    caption = caption,
    x = "Number of Applications",
    colour = ""
  ) +
  theme_void() +
  theme(
    text = element_text(family = ft, size = 48, lineheight = 0.3, colour = txt),
    plot.background = element_rect(fill = grid::radialGradient(c(bg1, bg2)), colour = bg),
    plot.title = element_text(size = 100, hjust = 0, face = "bold"),
    plot.subtitle = element_text(hjust = 0, margin = margin(t = 10, b = 10)),
    plot.caption = element_markdown(colour = txt, hjust = 0.5, margin = margin(t = 20)),
    plot.margin = margin(b = 20, t = 50, r = 50, l = 50),
    legend.position = "top",
    axis.text = element_text(hjust = 1, margin = margin(r = 5)),
    axis.text.x = element_text(hjust = 1, margin = margin(t = 10, b = 10)),
    # axis.text.y = element_text(hjust = 1, margin = margin(r = 10), colour = txt, size = 38),
    axis.title.x = element_text(face = "bold"),
    panel.grid.major.y = element_line(linewidth = 0.5, linetype = 3, colour = line)
  ) +
  facet_wrap(~increasing, nrow = 1, scales = "free_y")

ggsave("test.png", height = 12, width = 20)
