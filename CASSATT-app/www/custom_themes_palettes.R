library(RColorBrewer)

# summertime discrete palette
summertime = c(
  '#652133','#714c61','#b49daa',
  '#75637c','#3f3458','#223d63',
  '#41657c','#354953','#1d2b22',
  '#614500','#c28200','#e6c170',  
  '#d79668','#d06a24','#9e4200',
  '#971a00','#702512','#4b220a'
)

summertime_palette <- function(num_colors) {
  set.seed(4)
  if (num_colors > length(summertime)) {
    return(colorRampPalette(brewer.pal(summertime)(num_colors)))
  } else {
    return(sample(summertime, size = num_colors))
  }
}

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
    panel.border = element_blank()
  )
}










