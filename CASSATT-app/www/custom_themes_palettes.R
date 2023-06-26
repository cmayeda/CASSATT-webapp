# ggplot theme for clickable plot 
theme_clickable <- function() {
  theme_bw() %+replace%
  theme(
    axis.title = element_blank(),
    axis.ticks = element_blank(),
    axis.text = element_blank(),
    panel.grid = element_blank(),
    plot.margin = grid::unit(c(0,0,0,0), "mm"),
    panel.spacing = element_blank(),
    panel.background = element_rect(fill = "transparent", color = NA),
    panel.border = element_blank(),
    legend.text = element_text(size = 11)
  )
}

# CASSATT Summertime for Step 7 
summertime_pal = c(
  "Tumor A" = "#3d3456",
  "Tumor B" = "#75647a",
  "CD4T A" = "#971a00",
  "CD4T B" = "#702512",
  "CD4T C" = "#4b220a",
  "CD8T A" = "#41657c",
  "CD8T B" = "#223d63",
  "DNT A" = "#e6c170",
  "DNT B" = "#c28200",
  "Microglia A" = "#354953",
  "Microglia B" = "#1d2b22",
  "Macrophage A" = "#d06a24",
  "Macrophage B" = "#9e4200"
)
summertime_expanded = c(
  "#474278","#3d3456","#75647a",
  "#971a00","#702512","#4b220a",
  "#41657c","#223d63",
  "#e6c170","#c28200","#614500",
  "#354953","#1d2b22",
  "#d06a24","#9e4200"
)
set.seed(3)
summertime_expanded <- sample(summertime_expanded)
names(summertime_expanded) <- as.character(1:15)










