library(tidyverse)
library(readr)
library(ggthemes)
library(glue)

countries <- readr::read_csv("data/plotting/learners_country.csv")

ggplot(countries, aes(x = fct_reorder(country, percent), y = percent)) +
  geom_text(aes(label = scales::percent(percent, accuracy = 0.1)),
            hjust = -0.2,
            family = 'Roboto Mono',
            color = '#ebdbb2',
            size = 5)  +
  geom_bar(
    fill = '#ebdbb2', 
    stat = 'identity',
    width = .3) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  labs(
    title = "Global Distribution of Learner Signups",
    caption = "",
    x = "Country",
    y = "Percentage of Signups"
  ) +
  coord_flip() +
  theme_wsj() +
  theme(
    axis.line.x = element_line(color = '#ebdbb2'),
    axis.ticks.x = element_line(color = '#ebdbb2'),
    axis.text.x = element_text(color = '#ebdbb2', size = 19),
    axis.text.y = element_text(color = '#ebdbb2', size = 19),
    axis.title = element_text(color = '#ebdbb2'),
    panel.background = element_rect(fill = '#364355', color = '#364355'),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_line(color = '#ebdbb2'),
    plot.background = element_rect(fill = '#364355', color = '#364355'),
    plot.title = element_text(color = '#ebdbb2', family = 'Roboto Mono', margin = margin(b =20), size = 30),
    plot.margin = margin(t = 20, r = 20, b = 20, l = 20),
    text = element_text(family = 'Roboto Mono', color = '#ebdbb2')
)

ggsave("countries.png", width = 20, height = 12)