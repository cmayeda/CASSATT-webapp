library(shiny)

neighborhood_clickable_ui <- function(id) {
  ns <- NS(id)
  tagList(
      fluidRow(
          column(10, offset = 1,
              column(4,
                  plotOutput(ns("neighborhood"), height = "100%", click = "plot_click")
              ),
              column(4, 
                  tags$div(class = "config_menu",
                      selectInput(ns("method"),
                                  label = "Select a neighborhood identification method",
                                  choices = c("voronoi", "shell", "knn"),
                                  selected = "voronoi"),
                      numericInput(ns("cluster_size"), 
                                   label = "Cluster size",
                                   value = 5, min = 3, max = 100),
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

neighborhood_clickable_server <- function(input, output, session) {
  
  rv <- reactiveValues(ggClickable = ggplot())
  
  observe({
    np <- nearPoints(tSNE_plot(), plot_click(), maxpoints = 1, addDist = FALSE)
    if (nrow(np) <= 0) { 
      rv$ggClickable <<- ggplot(tSNE_plot()) + 
        coord_fixed() +
        geom_point(aes(x = x, y = y, color = fSOM_clusters()), cex = 3) +
        scale_color_manual(values = my_magma()) +
        theme_clickable()
    } else {
      rv$ggClickable <<- ggplot(tSNE_plot()) +
        coord_fixed() +
        geom_point(aes(x = x, y = y, color = fSOM_clusters()), cex = 3) +
        scale_color_manual(values = my_magma()) +
        geom_point(cluster_set, mapping = aes(x = x, y = y),
                   fill = fill_color, cex = 3, shape = 21, color = "#005CCB") +
        theme_clickable()
    }
  })
  
  output$neighborhood <- renderPlot({
    rv$ggClickable 
  })

}

