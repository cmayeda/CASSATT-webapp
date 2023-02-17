library(ggplot2)
library(reticulate)

# python setup 
use_virtualenv("~/.virtualenvs/r-reticulate")
source_python("www/neighbor_functions.py")

source("www/custom_themes_palettes.R")
neighborhood_data = read.csv("www/neighborhood_data.csv")

neighborhood_clickable_ui <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(
      column(10, offset = 1,
        fluidRow(
          column(6,
            plotOutput(ns("neighborhood"), click = ns("plot_click"), height = "600px")
          ),
          column(6, 
            tags$div(class = "config_menu",
              selectInput(ns("method"),
                          label = "Select a neighborhood identification method",
                          choices = c("voronoi", "shell", "knn"),
                          selected = "voronoi"),
              numericInput(ns("n_neighbors"), 
                           label = "Number of nearest neighbors",
                           value = 10, min = 5, max = 30),
              numericInput(ns("distance"),
                           label = "Distance in microns",
                           value = 10, min = 0, max = 50)
              )
            ),
          ),
          fluidRow(
            column(8, offset = 2, 
              tags$p(class = "help_text", "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam 
              nec tellus imperdiet, mollis purus non, ornare lectus. Pellentesque cursus pellentesque magna. 
              Etiam ac turpis bibendum, fermentum enim vitae, feugiat nulla. Morbi pharetra euismod dictum. 
              Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos.")
            )        
          )
        )
      )
  )
}

dot_size = 2

neighborhood_clickable_server <- function(input, output, session,
                                          n_data) {
  
  rv <- reactiveValues(ggClickable = ggplot())
  
  # plot for first load 
  observeEvent( input$plot_click, {
    rv$ggClickable <<- ggplot(n_data) + 
      coord_fixed() + 
      scale_y_reverse() + 
      geom_point(aes(x = Global_x, y = Global_y), cex = dot_size, col = "lightgray") + 
      theme_clickable() 
  }, ignoreNULL = FALSE, ignoreInit = FALSE, once = TRUE)
  
  # color plot based on red clicked cell, and blue neighbor cells 
  observe({
    np <- nearPoints(n_data, input$plot_click, maxpoints = 1, addDist = FALSE)
    np_coords = as.vector(np[1:2])
    
    if (isTruthy(np_coords[["Global_x"]])) { 
      neighbor_coords = data.frame(t(sapply(find_voronoi(np_coords), c)))
      np_plotting = data.frame(t(sapply(np_coords, c)))
      
      rv$ggClickable <<- ggplot(n_data) +
        coord_fixed() +
        scale_y_reverse() +
        geom_point(aes(x = Global_x, y = Global_y), cex = dot_size, col = "lightgray") +
        geom_point(neighbor_coords, mapping = aes(x = X1, y = X2), cex = dot_size, col = "blue") +
        geom_point(np_plotting, mapping = aes(x = Global_x, y = Global_y), cex = dot_size, col = "red") + 
        theme_clickable()
    } 
  })
  
  # hide and show controls based on neighbor ID method
  observe({
    if (input$method == "knn") {
      showElement("n_neighbors")
    } else {
      hideElement("n_neighbors")
    }
    if (input$method == "shell") {
      showElement("distance")
    } else {
      hideElement("distance")
    }
  })

  
  output$neighborhood <- renderPlot({
    rv$ggClickable 
  })

}

