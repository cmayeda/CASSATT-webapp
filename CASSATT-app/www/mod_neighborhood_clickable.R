# -- FOR LOCAL
# use_virtualenv("~/.virtualenvs/r-reticulate")

# -- FOR DEPLOY
# virtualenv_create("CASSATT-reticulate")
# py_install("numpy")
# py_install("pandas")
# py_install("scipy")
# py_install("grispy")
# use_virtualenv("CASSATT-reticulate")

library(cowplot)
library(grid)
library(gridExtra)
source_python("www/neighbor_functions.py")

decagons = read.csv("www/decagons.csv")
neighborhood_data = read.csv("www/neighborhood_data.csv")
r_to_py(neighborhood_data)
coords = neighborhood_data[, c("Global_x","Global_y")]
status = c(rep("unselected", nrow(coords)))

neighborhood_clickable_ui <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(
      column(6,
        girafeOutput(ns("plot"))
      ),
      column(6, 
        fluidRow(
          column(6, 
            tags$div(class = "config_menu",
              selectInput(ns("method"), label = "Select an identification method",
                          choices = c("voronoi", "shell", "knn"), selected = "voronoi"),
              numericInput(ns("num"), label = "Number of nearest neighbors", value = 10, min = 5, max = 30),
              tags$div(id = "warning", class = "warning"), 
              actionButton(ns("run"), "Calculate nearest neighbors")
            )
          ),
          column(6,
            tags$p(class = "help_text", "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam 
            nec tellus imperdiet, mollis purus non, ornare lectus. Pellentesque cursus pellentesque magna. 
            Etiam ac turpis bibendum, fermentum enim vitae, feugiat nulla.")
          )
        ),
        fluidRow(
          tags$h5("Decagon visualization"), 
          column(4, id = "decagons_col", 
            plotOutput(ns("decagons"), height = "200px")
          ),
          column(4, id = "deca_key_col", 
            plotOutput(ns("deca_key"), height = "200px")
          )
        )
      )
    )
  )
}

neighborhood_clickable_server <- function(input, output, session, server_rv) {
  
  rv <- reactiveValues(ordered_coords = as.data.frame(cbind(coords, status)),
                       knn_neighbors = data.frame(), 
                       s_neighbors = data.frame(),
                       neighbor_data = data.frame(),
                       d_colors = as.list(rep("#ffffff", 10)),
                       deca_key = NULL)
  
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
  
  # hide and show controls based on neighbor ID method
  observe({
    if (input$method == "knn") {
      updateNumericInput(session, "num", label = "Number of nearest neighbors", value = 10, min = 5, max = 30)
      updateActionButton(session, "run", label = "Calculate nearest neighbors")
      showElement("num")
      showElement("run")
    } else if (input$method == "shell") {
      updateNumericInput(session, "num", label = "Distance in pixels", value = 70, min = 1, max = 300)
      updateActionButton(session, "run", label = "Calculate shell neighbors")
      showElement("num")
      showElement("run")
    } else {
      hideElement("num")
      hideElement("run")
    }
    
    # wipe output on method change
    gc()
    rv$ordered_coords <<- isolate(rv$ordered_coords[1:6406, ])
    selected <<- character(0)
    rv$d_colors <<- as.list(rep("#ffffff", 10))
  })
  
  # set up warnings 
  RUN_NEEDED = FALSE
  WPRESENT = FALSE
  observeEvent( input$num, {
    RUN_NEEDED <<- TRUE
  }, ignoreInit = TRUE)
  
  # run method on btn press 
  observeEvent( input$run, {
    if (isTruthy(input$num) & RUN_NEEDED) {
      selected <<- character(0)
      rv$ordered_coords <<- rv$ordered_coords[1:6406, ]
      
      if (input$method == "shell") {
        rv$s_neighbors <<- run_shell(input$num)
      } else {
        rv$knn_neighbors <<- run_knn(input$num)
      }
      RUN_NEEDED <<- FALSE
      if (WPRESENT) { # remove warning 
        removeUI(selector = "#warning h5", immediate = TRUE)
        WPRESENT <<- FALSE
      }
    } 
  })
  
  # color plot based on red clicked cell, and blue neighbor cells
  selected = NULL
  observeEvent( input$plot_selected, {
    if (nchar(input$plot_selected) > 4 | RUN_NEEDED) { 
      selected <<- character(0)
      rv$ordered_coords <<- rv$ordered_coords[1:6406, ]
      rv$d_colors <<- as.list(rep("#ffffff", 10))
      
      # add warning
      if (!WPRESENT & RUN_NEEDED) { 
        if (input$method == "shell") {
          insertUI(selector = "#warning",
            ui = tags$h5(id = "s_warning", "Warning: shell neighbors has not been run for this distance."))
        } else {
          insertUI(selector = "#warning",
            ui = tags$h5(id = "k_warning", "Warning: knn neighbors has not been run for this k value"))
        }
        WPRESENT <<- TRUE
      }
    } else {
      selected <<- input$plot_selected
      selected_row = rv$ordered_coords[as.numeric(selected), ]
      selected_row$status <- "selected"
      
      if (input$method == "voronoi") {
        rv$neighbor_data <<- find_voronoi(selected_row) 
      } else if (input$method == "shell") {
        rv$neighbor_data <- find_shell(rv$s_neighbors, selected_row) 
      } else if (input$method == "knn") {
        rv$neighbor_data <- find_knn(rv$knn_neighbors, selected_row)
      }

      if (nrow(rv$neighbor_data) > 0 & ncol(rv$neighbor_data) > 1) {
        rv$d_colors <<- deca_colors(rv$neighbor_data, server_rv$colormode)
        neighbor_coords <- cbind(
          rv$neighbor_data[, c("Global_x", "Global_y")], 
          status = rep("neighbor", nrow(rv$neighbor_data))
        )
        rv$ordered_coords <<- rbind(rv$ordered_coords[1:6406, ], neighbor_coords, selected_row)
      } else {
        rv$ordered_coords <<- isolate(rv$ordered_coords[1:6406, ])
      }
    }
  }, ignoreInit = TRUE, ignoreNULL = TRUE)
  
  # on colormode change, get new colors 
  observeEvent( server_rv$colormode, {
    if (nrow(rv$neighbor_data) > 0) {
      rv$d_colors <<- deca_colors(rv$neighbor_data, server_rv$colormode)
    } else {
      rv$d_colors <<- as.list(rep("#ffffff", 10))
    }
  }, ignoreInit = TRUE) 
  
  # after reordering plot, re-select clicked population 
  session$onFlushed(function() {
    session$sendCustomMessage(type = "neighborhood_clickable-plot_set", message = selected)
  }, once = FALSE)
  
  # plot decagons of cluster cell types 
  output$decagons <- renderPlot({
    plot = ggplot(decagons)
    for (i in 1:10) {
      indxes = which(decagons$name == as.character(i))
      plot <- plot + geom_polygon(
        data = decagons[indxes, ], aes(x = x, y = y),
        fill = rv$d_colors[[i]],
        color = "black", linewidth = 1.25
      )
    }
    plot <- plot + 
      coord_fixed() + 
      theme_deca()
    return(plot)
  })
  
  observeEvent( rv$d_colors, {
    colors = unique(unlist(rv$d_colors))
    if (server_rv$colormode == "custom") { 
      types = sapply(colors, function(x) { as.numeric(which(summertime_pal == x)) })
      types <- names(summertime_pal)[types]
    } else {
      types = sapply(colors, function(x) { as.numeric(which(viridis_expert == x)) })
      types <- names(viridis_expert)[types]
    }
    df = data.frame(x = c(1:length(colors)))
    plot = ggplot(df, aes(x = x, y = 1, col = as.factor(x))) +
      geom_point() +
      scale_color_manual(values = colors, labels = types, name = "Population") +
      theme_bw() +
      theme(
        legend.title = element_text(size = 14.5, lineheight = 1.3),
        legend.text = element_text(size = 14.5, lineheight = 1.3),
        legend.justification = "left"
      )
    rv$deca_key <<- get_legend(plot)
  }, ignoreInit = FALSE)
  
  output$deca_key <- renderPlot({ grid.draw(rv$deca_key) })
  
}

