# -- FOR LOCAL
# use_virtualenv("~/.virtualenvs/r-reticulate")

# -- FOR DEPLOY
# virtualenv_create("CASSATT-reticulate")
# py_install("numpy")
# py_install("pandas")
# py_install("scipy")
# py_install("grispy")
# use_virtualenv("CASSATT-reticulate")

neighborhood_data = read.csv("www/neighborhood_data.csv")
py$neighborhood_data <- neighborhood_data
coords = neighborhood_data[, c("Global_x","Global_y")]
status = c(rep("unselected", nrow(coords)))

source_python("www/neighbor_functions.py")

neighborhood_clickable_ui <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(
      column(10, offset = 1,
        fluidRow(
          column(7,
            girafeOutput(ns("plot"))
          ),
          column(5, 
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
              tags$div(id = "warning", class = "warning"), 
              actionButton(ns("run_shell"), "Calculate shell neighbors"),
              actionButton(ns("run_knn"), "Calculate nearest neighbors"),
            ),
            plotOutput(ns("decagons"))
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





neighborhood_clickable_server <- function(input, output, session) {
  
  rv <- reactiveValues(ordered_coords = as.data.frame(cbind(coords, status)),
                       s_neighbors = data.frame())
  
  fill_click = "#fbb700"
  fill_hover = "#ddcca1"
  text_click = "#000000"
  
  gir_options = list(
    opts_toolbar(saveaspng = FALSE),
    opts_hover(css = paste0("fill:",fill_hover,";")),
    opts_selection(css = paste0("fill:",fill_click,";"), type = "single")
  )
  
  output$plot <- renderGirafe({
    gg = ggplot(rv$ordered_coords) +
      geom_point_interactive(aes(
        x = Global_x, y = Global_y,
        col = status, 
        tooltip = NULL, 
        data_id = rownames(rv$ordered_coords),
      ), cex = dot_size) +
      scale_color_manual(values = neighbor_palette, name = "Status") + 
      coord_fixed() + 
      scale_y_reverse() +
      theme_clickable()
    girafe(ggobj = gg, options = gir_options) 
  })
  
  # set up for reactive warnings 
  BOOL_SHELL = FALSE
  BOOL_KNN = FALSE
  WPRESENT = FALSE
  
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
    gc()
    rv$ordered_coords <<- isolate(rv$ordered_coords[1:6406, ])
    selected <<- character(0)
  })
  
  # run shell & knn once on load 
  observeEvent( input$run_shell, {
    rv$s_neighbors <<- run_shell(input$distance)
    rv$knn_neighbors <<- run_knn(input$n_neighbors)
  }, ignoreNULL = FALSE, ignoreInit = FALSE, once = TRUE)
  
  # calculate shell neighbors on btn press  
  observeEvent( input$run_shell, {
    if (isTruthy(input$distance) & input$method == "shell") {
      BOOL_SHELL <<- FALSE
      rv$s_neighbors <<- run_shell(input$distance)
      if (WPRESENT == TRUE) {
        removeUI(selector = "#s_warning", immediate = TRUE)
        WPRESENT <<- FALSE
      }
    }
  })
  
  # calculate knn neighbors on btn press 
  observeEvent( input$run_knn, {
    if (isTruthy(input$n_neighbors) & input$method == "knn") {
      BOOL_KNN <<- FALSE
      rv$knn_neighbors <<- run_knn(input$n_neighbors)
      if (WPRESENT == TRUE) {
        removeUI(selector = "#k_warning", immediate = TRUE)
        WPRESENT <<- FALSE
      }
    }
  }, ignoreInit = TRUE)
  
  # color plot based on red clicked cell, and blue neighbor cells
  # add warnings if algos have not been run
  selected = NULL
  observeEvent( input$plot_selected, {
    if (is.null(input$plot_selected)) { 
      selected <<- character(0)
      rv$ordered_coords <<- rv$ordered_coords[1:6406, ]
      
    # do not run if two points get selected simultaneously
    } else if(nchar(input$plot_selected) > 4) {
      selected <<- character(0)
      rv$ordered_coords <<- rv$ordered_coords[1:6406, ]
    } else {
      selected <<- input$plot_selected
      selected_row = rv$ordered_coords[as.numeric(selected), ]
      selected_row$status <- "selected"
      neighbor_data <- data.frame()
      
      if (input$method == "voronoi") {
        neighbor_data <- find_voronoi(selected_row) 
        
      } else if (input$method == "shell") {
        if (BOOL_SHELL & (WPRESENT == FALSE)) {
          insertUI(
            selector = "#warning",
            ui = tags$h5(id = "s_warning", "Warning: shell neighbors has not been run for this distance.")
          )
          WPRESENT <<- TRUE
          rv$ordered_coords <<- rv$ordered_coords[1:6406, ]
        } else if (BOOL_SHELL == FALSE) {
          neighbor_data <- find_shell(rv$s_neighbors, selected_row) 
        }
      } else {
        if (BOOL_KNN & (WPRESENT == FALSE)) {
          insertUI(
            selector = "#warning",
            ui = tags$h5(id = "k_warning", "Warning: knn neighbors has not been run for this k value")
          )
          WPRESENT <<- TRUE
          rv$ordered_coords <<- rv$ordered_coords[1:6406, ] 
        } else if (BOOL_KNN == FALSE) {
          neighbor_data <- find_knn(rv$knn_neighbors, selected_row)
        }
      }

      if (nrow(neighbor_data) > 0 & ncol(neighbor_data) > 1) {
        neighbor_coords <- cbind(
          neighbor_data[, c("Global_x", "Global_y")], 
          status = rep("neighbor", nrow(neighbor_data))
        )
        rv$ordered_coords <<- rbind(rv$ordered_coords[1:6406, ], neighbor_coords, selected_row)
      } else {
        rv$ordered_coords <<- isolate(rv$ordered_coords[1:6406, ])
      }
    }
  }, ignoreInit = TRUE, ignoreNULL = FALSE)
  
  # after reordering plot, re-select clicked population 
  session$onFlushed(function() {
    session$sendCustomMessage(type = "neighborhood_clickable-plot_set", message = selected)
  }, once = FALSE)
  
  # plot decagons of cluster cell types 
  output$decagons <- renderPlot({
    if (nchar(input$plot_selected) < 4) {
      neighbor_indexes <- find_voronoi(vor, input$plot_selected, mode = "indexes")
      my_colors <- deca_colors(neighbor_indexes)
      str(my_colors)
    }
  })
  
}

