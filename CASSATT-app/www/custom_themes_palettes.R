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
    legend.position = "none"
  )
}










