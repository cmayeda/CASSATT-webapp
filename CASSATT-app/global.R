suppressPackageStartupMessages({
  library(shiny)
  library(shinyjs)
  library(ggplot2)
  library(ggiraph)
  library(reticulate)
})

source("www/mod_neighborhood_clickable.R")
source("www/mod_pop_clickable.R")
source("www/custom_themes_palettes.R")

neighborhood_data = read.csv("www/neighborhood_data.csv")
neighborhood_data$kmeans_cluster <- as.factor(neighborhood_data$kmeans_cluster)

dot_size = 2
