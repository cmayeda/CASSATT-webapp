library(ggplot2)

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

neighborhood_clickable_server <- function(input, output, session,
                                          n_data) {
  
  rv <- reactiveValues(ggClickable = ggplot())
  
  # plot for first load 
  observeEvent( input$plot_click, {
    rv$ggClickable <<- ggplot(n_data, aes(x = Global_x, y = Global_y)) + 
      coord_fixed() + 
      geom_point(cex = 2.5, col = "lightgray") + 
      scale_y_reverse() + 
      theme_clickable() 
  }, ignoreNULL = FALSE, ignoreInit = FALSE, once = TRUE)
  
  observe({
    np <- nearPoints(n_data, input$plot_click, maxpoints = 1, addDist = FALSE)
    str(np)
    
    # if (nrow(np) <= 0) { 
    #   rv$ggClickable <<- ggplot(tSNE_plot()) + 
    #     coord_fixed() +
    #     geom_point(aes(x = x, y = y, color = fSOM_clusters()), cex = 3) +
    #     scale_color_manual(values = my_magma()) +
    #     theme_clickable()
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

