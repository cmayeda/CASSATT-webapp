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
              column(4,
                  plotOutput(ns("neighborhood"), click = ns("plot_click"))
              ),
              column(4, 
                  tags$div(class = "config_menu",
                      selectInput(ns("method"),
                                  label = "Select a neighborhood identification method",
                                  choices = c("voronoi", "shell", "knn"),
                                  selected = "voronoi"),
                      numericInput(ns("cluster_size"), 
                                   label = "Cluster size",
                                   value = 10, min = 3, max = 100),
                  )
              ),
              column(4, 
                  tags$p(class = "help_text", "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam 
                  nec tellus imperdiet, mollis purus non, ornare lectus. Pellentesque cursus pellentesque magna. 
                  Etiam ac turpis bibendum, fermentum enim vitae, feugiat nulla. Morbi pharetra euismod dictum. 
                  Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos.")
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
  
  observe({
    np <- nearPoints(n_data, input$plot_click, maxpoints = 1, addDist = FALSE)
    np_coords = as.vector(np[1:2])
    
    if (isTruthy(np_coords[["Global_x"]])) { 
      neighbor_coords = data.frame(t(sapply(find_voronoi(np_coords), c)))
      np_plotting = data.frame(t(sapply(np_coords, c)))
      str(np_plotting)
      
      rv$ggClickable <<- ggplot(n_data) +
        coord_fixed() +
        scale_y_reverse() +
        geom_point(aes(x = Global_x, y = Global_y), cex = dot_size, col = "lightgray") +
        geom_point(neighbor_coords, mapping = aes(x = X1, y = X2), cex = dot_size, col = "blue") +
        geom_point(np_plotting, mapping = aes(x = Global_x, y = Global_y), cex = dot_size, col = "red") + 
        theme_clickable()
    } 
    
    # if (nrow(np) <= 0) { 

    # } else {
    #   rv$ggClickable <<- ggplot(tSNE_plot()) +
    #     coord_fixed() +
    #     geom_point(aes(x = x, y = y, color = fSOM_clusters()), cex = 3) +
    #     scale_color_manual(values = my_magma()) +
    #     geom_point(cluster_set, mapping = aes(x = x, y = y),
    #                fill = fill_color, cex = 3, shape = 21, color = "#005CCB") +
    #     theme_clickable()
    # }
  })
  

  
  output$neighborhood <- renderPlot({
    rv$ggClickable 
  })

}

