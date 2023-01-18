# R Shiny app for CASSATT Pipeline 
# created by Cass Mayeda 
# 11/18/2022 

library(shiny)

shinyUI(fluidPage(

  titlePanel("", windowTitle = "CASSATT"),
  tags$head(
    tags$link(rel="stylesheet", type="text/css", href="css/style.css"),
    # tags$link(rel="stylesheet", href="https://fonts.googleapis.com/css?family=Roboto|Urbanist")
  ),
  
  # -- NAVBAR -- 
  fluidRow(id = "navbar",
      column(12,
          tags$div(id = "cytolab_home",
              tags$img(src = "assets/arrow.png"),
              tags$a(href = "https://cytolab.github.io", "Cytolab Home")
          ), 
          actionButton("hide_help", "Hide help text"),
          # actionButton("clear_session", "CLEAR SESSION"),
          actionButton("colorblind", "colorblind mode")
      )
  ),
    
))
