library(ggplot2)
library(reticulate)

# -- FOR LOCAL
# use_virtualenv("~/.virtualenvs/r-reticulate")

# -- FOR DEPLOY
# virtualenv_create("CASSATT-reticulate")
# py_install("numpy")
# py_install("pandas")
# py_install("scipy")
# py_install("grispy")
# use_virtualenv("CASSATT-reticulate")

source_python("www/neighbor_functions.py")
source("www/custom_themes_palettes.R")

neighborhood_data = read.csv("www/neighborhood_data.csv")
coords = neighborhood_data[, c("Global_x","Global_y")]
vor = run_voronoi(coords)

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
                           label = "Distance in pixels",
                           value = 70, min = 0, max = 300),
              tags$div(id = "shell_warning", class = "warning"), 
              actionButton(ns("run_shell"), "Calculate shell neighbors"),
              tags$div(id = "knn_warning", class = "warning"), 
              actionButton(ns("run_knn"), "Calculate nearest neighbors"),
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

neighborhood_clickable_server <- function(input, output, session) {
  
  rv <- reactiveValues(ggClickable = ggplot(),
                       s_neighbors = list())
  
  # plot for first load 
  observeEvent( input$plot_click, {
    rv$ggClickable <<- ggplot(coords) + 
      coord_fixed() + 
      scale_y_reverse() + 
      geom_point(aes(x = Global_x, y = Global_y), cex = dot_size, col = "lightgray") + 
      theme_clickable() 
  }, ignoreNULL = FALSE, ignoreInit = FALSE, once = TRUE)
  
  # color plot based on red clicked cell, and blue neighbor cells 
  observeEvent( input$plot_click, {
    np <- nearPoints(coords, input$plot_click, maxpoints = 1, addDist = FALSE)
    np_coords = array(unlist(np[1:2]))
    
    if (isTruthy(np_coords)) {
      np_plotting = data.frame(t(sapply(np_coords, c)))
      
      if (input$method == "voronoi") {
        neighbor_coords = as.data.frame(t(sapply(find_voronoi(vor, np_plotting), c)))
      } else if(input$method == "shell") {
        if (BOOL_SHELL == TRUE) {
          neighbor_coords <<- as.data.frame(x = c(NULL), y = c(NULL))
          if (SHELL_WPRESENT == FALSE) {
            insertUI(
              selector = "#shell_warning", 
              ui = tags$h5(id = "s_warning", "Warning: shell neighbors has not been run for this distance")
            )
            SHELL_WPRESENT <<- TRUE
          }
        } else {
          neighbor_coords = as.data.frame(t(sapply(find_shell(coords, rv$s_neighbors, np_plotting), c)))
        }
      } else {
        if (BOOL_KNN == TRUE) {
          neighbor_coords <<- as.data.frame(x = c(NULL), y = c(NULL))
          if (KNN_WPRESENT == FALSE) {
            insertUI(
              selector = "#knn_warning", 
              ui = tags$h5(id = "k_warning", "Warning: knn neighbors has not been run for this k value")
            )
            KNN_WPRESENT <<- TRUE
          }
        } else {
          neighbor_coords = as.data.frame(t(sapply(find_knn(coords, rv$knn_neighbors, np_plotting), c)))
        }
      }

      if (ncol(neighbor_coords) > 0) {
        colnames(neighbor_coords) <- c("V1","V2")
        rv$ggClickable <<- ggplot(coords) +
          coord_fixed() +
          scale_y_reverse() +
          geom_point(aes(x = Global_x, y = Global_y), cex = dot_size, col = "lightgray") +
          geom_point(neighbor_coords, mapping = aes(x = V1, y = V2), cex = dot_size, col = "blue") +
          geom_point(np_plotting, mapping = aes(x = X1, y = X2), cex = dot_size, col = "red") +
          theme_clickable()
      } else {
        rv$ggClickable <<- ggplot(coords) +
          coord_fixed() +
          scale_y_reverse() +
          geom_point(aes(x = Global_x, y = Global_y), cex = dot_size, col = "lightgray") +
          geom_point(np_plotting, mapping = aes(x = X1, y = X2), cex = dot_size, col = "red") +
          theme_clickable()
      }

    }
  }, ignoreInit = TRUE)

  output$neighborhood <- renderPlot({
    rv$ggClickable 
  })
  
  # run shell & knn once on load 
  observeEvent( input$run_shell, {
    rv$s_neighbors <<- run_shell(coords, input$distance)
    rv$knn_neighbors <<- run_knn(coords, input$n_neighbors)
  }, ignoreNULL = FALSE, ignoreInit = FALSE, once = TRUE)
  
  # calculate shell neighbors on btn press  
  observeEvent( input$run_shell, {
    if (isTruthy(input$distance) & input$method == "shell") {
      BOOL_SHELL <<- FALSE
      rv$s_neighbors <<- run_shell(coords, input$distance)
      if (SHELL_WPRESENT == TRUE) {
        removeUI(selector = "#s_warning", immediate = TRUE)
        SHELL_WPRESENT <<- FALSE
      }
    }
  })
  
  # calculate knn neighbors on btn press 
  observeEvent( input$run_knn, {
    if (isTruthy(input$n_neighbors) & input$method == "knn") {
      BOOL_KNN <<- FALSE 
      rv$knn_neighbors <<- run_knn(coords, input$n_neighbors)
      if (KNN_WPRESENT == TRUE) {
        removeUI(selector = "#k_warning", immediate = TRUE)
        KNN_WPRESENT <<- FALSE 
      }
    }
  }, ignoreInit = TRUE)
  
  # reactive warnings 
  BOOL_SHELL = FALSE
  SHELL_WPRESENT = FALSE 
  BOOL_KNN = FALSE 
  KNN_WPRESENT = FALSE
  
  observeEvent( input$distance, {
    BOOL_SHELL <<- TRUE
  }, ignoreInit = TRUE)
  observeEvent( input$n_neighbors, {
    BOOL_KNN <<- TRUE
  }, ignoreInit = TRUE)
  
  # hide and show controls based on neighbor ID method
  observe({
    if (input$method == "knn") {
      showElement("n_neighbors")
      showElement("run_knn")
    } else {
      hideElement("n_neighbors")
      hideElement("run_knn")
    }
    if (input$method == "shell") {
      showElement("distance")
      showElement("run_shell")
    } else {
      hideElement("distance")
      hideElement("run_shell")
    }
    
    # wipe plot on method change 
    rv$ggClickable <<- ggplot(coords) +
      coord_fixed() +
      scale_y_reverse() +
      geom_point(aes(x = Global_x, y = Global_y), cex = dot_size, col = "lightgray") +
      theme_clickable()
  })

}

