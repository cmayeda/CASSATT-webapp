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

neighborhood_clickable_server <- function(input, output, session) {
  
  coords = neighborhood_data[, c("Global_x","Global_y")]
  vor = run_voronoi(coords)
  status = c(rep("unselected", nrow(coords)))
  
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
  
  selected = NULL
  
  # color plot based on red clicked cell, and blue neighbor cells 
  observeEvent( input$plot_selected, {
    if (nchar(input$plot_selected) > 4) {
      selected <<- character(0)
      rv$ordered_coords <<- rv$ordered_coords[1:6406, ]
    } else {
      selected <<- input$plot_selected
      selected_row = rv$ordered_coords[as.numeric(selected), ]
      selected_row$status <- "selected"
      
      neighbor_points <- data.frame()
      if (input$method == "voronoi") {
        neighbor_points <- as.data.frame(t(sapply(find_voronoi(vor, selected_row), c)))
      } else if (input$method == "shell") {
        if (BOOL_SHELL & (SHELL_WPRESENT == FALSE)) {
          insertUI(
            selector = "#shell_warning",
            ui = tags$h5(id = "s_warning", "Warning: shell neighbors has not been run for this distance.")
          )
          SHELL_WPRESENT <<- TRUE
          rv$ordered_coords <<- rv$ordered_coords[1:6406, ]
        } else if (BOOL_SHELL == FALSE) {
          neighbor_points <- as.data.frame(t(sapply(find_shell(coords, rv$s_neighbors, selected_row), c)))
          if (nrow(neighbor_points) == 1) {
            if (neighbor_points == "None") { 
              neighbor_points <- data.frame()
            }
          }
        }
      } else {
        if (BOOL_KNN & (KNN_WPRESENT == FALSE)) {
          insertUI(
            selector = "#knn_warning",
            ui = tags$h5(id = "k_warning", "Warning: knn neighbors has not been run for this k value")
          )
          KNN_WPRESENT <<- TRUE
          rv$ordered_coords <<- rv$ordered_coords[1:6406, ] 
        } else if (BOOL_KNN == FALSE) {
          neighbor_points = as.data.frame(t(sapply(find_knn(coords, rv$knn_neighbors, selected_row), c)))
        }
      }

      if (nrow(neighbor_points) > 0) {
        neighbor_points <- cbind(neighbor_points, rep("neighbor", nrow(neighbor_points)))
        colnames(neighbor_points) <- c("Global_x","Global_y","status")
        rv$ordered_coords <<- rbind(rv$ordered_coords[1:6406, ], neighbor_points, selected_row)
      }
    }
  }, ignoreInit = TRUE, ignoreNULL = FALSE)
  
  # after reordering plot, re-select clicked population 
  session$onFlushed(function() {
    session$sendCustomMessage(type = "neighborhood_clickable-plot_set", message = selected)
  }, once = FALSE)
  
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
    rv$ordered_coords <<- isolate(rv$ordered_coords[1:6406, ])
    selected <<- character(0)
  })

}

