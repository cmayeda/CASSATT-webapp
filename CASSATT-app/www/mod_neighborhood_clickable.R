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
        girafeOutput(ns("plot"), width = "97.06%")
      ),
      column(5, offset = 1, 
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
          column(12, tags$h5("Decagon visualization")),
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

empty_row = data.frame(
  "Global_x" = numeric(),
  "Global_y" = numeric(),
  "orig_indx" = numeric()
)

neighborhood_clickable_server <- function(input, output, session, server_rv) {
  
  rv <- reactiveValues(selected_point = empty_row,
                       selected_neighbors = empty_row, 
                       knn_neighbors = data.frame(), 
                       s_neighbors = data.frame(),
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
    gg = ggplot() +
      geom_point_interactive(
        data = neighborhood_data, 
        cex = dot_size, col = "lightgray", 
        aes(x = Global_x, y = Global_y, data_id = rownames(neighborhood_data))
      ) +
      geom_point_interactive(
        data = rv$selected_neighbors, cex = dot_size, col = "#41657c", 
        aes(x = Global_x, y = Global_y, data_id = orig_indx)
      ) +
      geom_point_interactive(
        data = rv$selected_point, cex = dot_size, col = "#fbb700", 
        aes(x = Global_x, y = Global_y, data_id = orig_indx)
      ) +
      coord_fixed() + 
      scale_y_reverse() +
      theme_clickable()
    girafe(ggobj = gg, options = gir_options) 
  })
  
  # hide and show controls based on neighbor ID method
  observeEvent( input$method, {
    RUN_NEEDED <<- TRUE
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
    selected <<- character(0)
    rv$selected_point <<- empty_row
    rv$selected_neighbors <<- empty_row
  }, ignoreInit = T)
  
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
      rv$selected_point <<- empty_row
      rv$selected_neighbors <<- empty_row
      
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
    if (is.null(input$plot_selected)) { 
      selected <<- character(0)
      rv$selected_point <<- empty_row
      rv$selected_neighbors <<- empty_row
    } else {
      if (RUN_NEEDED) {
        selected <<- character(0)
        rv$selected_point <<- empty_row
        rv$selected_neighbors <<- empty_row
        if (!WPRESENT & input$method == "shell") {
          insertUI(
            selector = "#warning",
            ui = tags$h5(id = "s_warning", "Warning: shell neighbors has not been run for this distance.")
          )
          WPRESENT <<- TRUE
        } else if (!WPRESENT & input$method == "knn") {
          insertUI(
            selector = "#warning",
            ui = tags$h5(id = "k_warning", "Warning: knn neighbors has not been run for this k value")
          )
          WPRESENT <<- TRUE
        }
      } else {
        selected <<- input$plot_selected
        orig_indx = as.numeric(input$plot_selected)
        c = neighborhood_data[orig_indx, c("Global_x","Global_y")]
        rv$selected_point <<- cbind(c, orig_indx)
        neighbors = data.frame()
        if (input$method == "voronoi") {
          neighbors <- find_voronoi(rv$selected_point)
        } else if (input$method == "shell") {
          neighbors <- find_shell(rv$s_neighbors, rv$selected_point)
        } else if (input$method == "knn") { 
          neighbors <- find_knn(rv$knn_neighbors, rv$selected_point)
        }
        
        # retrieve r indx from py attribute
        if (nrow(neighbors) > 0) {
          indx_att = attributes(neighbors)[["pandas.index"]]
          r_indx = c()
          for (i in 1:length(indx_att)) {
            r_indx[i] <- as.numeric(paste(indx_att[i - 1])) + 1
          }
          rv$selected_neighbors <<- cbind(neighbors, orig_indx = r_indx)
        } else {
          rv$selected_neighbors <<- empty_row
        }
      }
    }
  }, ignoreInit = T, ignoreNULL = F)
  
  # after reordering plot, re-select clicked population 
  # selected cannot be a reactive variable, because 
  # session$onFlushed is not reactive
  session$onFlushed(function() {
    session$sendCustomMessage(type = "neighborhood_clickable-plot_set", message = selected)
  }, once = FALSE)
  
  # on colormode change, get new colors 
  observeEvent( server_rv$colormode, {
    if (nrow(rv$selected_neighbors) > 0) {
      rv$d_colors <<- deca_colors(rv$selected_neighbors, server_rv$colormode)
    } else {
      rv$d_colors <<- as.list(rep("#ffffff", 10))
    }
  }, ignoreInit = T) 
  
  # plot decagons of cluster cell types 
  observeEvent(rv$selected_neighbors, {
    if (nrow(rv$selected_neighbors) >= 1) {
      rv$d_colors <<- deca_colors(rv$selected_neighbors, server_rv$colormode)
    } else {
      rv$d_colors <<- as.list(rep("#ffffff", 10))
    }
  }, ignoreInit = T)
  
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

