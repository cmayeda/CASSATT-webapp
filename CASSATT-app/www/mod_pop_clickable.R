library(ggplot2)
library(reticulate)
library(ggiraph)

# -- FOR LOCAL
# use_virtualenv("~/.virtualenvs/r-reticulate")

# -- FOR DEPLOY
# virtualenv_create("CASSATT-reticulate")
# py_install("numpy")
# py_install("pandas")
# py_install("scipy")
# py_install("grispy")
# use_virtualenv("CASSATT-reticulate")

source("www/custom_themes_palettes.R")

neighborhood_data = read.csv("www/neighborhood_data.csv")

pop_clickable_ui <- function(id) {
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
                      label = "Method of population identification",
                      choices = c("expert gating", "automatic clustering"),
                      selected = "expert gating"),
              ),
              tags$p(class = "help_text", "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam 
              nec tellus imperdiet, mollis purus non, ornare lectus. Pellentesque cursus pellentesque magna. 
              Etiam ac turpis bibendum, fermentum enim vitae, feugiat nulla. Morbi pharetra euismod dictum. 
              Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos.")    
          )
        ),
      )
    )
  )
}

dot_size = 2

pop_clickable_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    rv <- reactiveValues(current_pop = NULL,
                         ordered_data = neighborhood_data,
                         gir = NULL)

    gir_options = list(
      opts_toolbar(saveaspng = FALSE),
      opts_hover(css = "stroke:#cece5b2; stroke-width:1px;"),
      opts_hover_key(css = "stroke:#cece5b2; stroke-width:1px;"),
      opts_selection(css = "stroke:#000000; stroke-width:1px;", type = "single"),
      opts_selection_key(css = "stroke:#000000; stroke-width:1px;", type = "single")
    )
    
    # set initial plot data order 
    observeEvent( input$plot_selected, {
      rv$ordered_data <<- neighborhood_data
    }, ignoreInit = FALSE, ignoreNULL = FALSE, once = TRUE)
    
    # set up interactive plot and legend 
    output$plot <- renderGirafe({ 
      gg = ggplot(rv$ordered_data) +
        geom_point_interactive(aes(
          x = Global_x, y = Global_y,
          col = pop_ID, tooltip = pop_ID, data_id = pop_ID
        ), cex = dot_size) +
        scale_color_manual_interactive(
          name = "Population",
          values = summertime_pal,
          breaks = names(summertime_pal),
          data_id = function(breaks) { breaks },
          labels = function(breaks) { lapply(breaks, function(br) {
            label_interactive(br, data_id = br)
          })}
        ) +
        coord_fixed() +
        scale_y_reverse() +
        theme_clickable()
      girafe(ggobj = gg, options = gir_options)
    })
    
    # reorder plot data with clicked population on top 
    selected = NULL
    
    observeEvent( input$plot_key_selected, {
      selected <<- input$plot_key_selected
      indxs = which(neighborhood_data$pop_ID == input$plot_key_selected)
      step = neighborhood_data[-indxs, ]
      rv$ordered_data <<- rbind(step, neighborhood_data[indxs, ])
    }, ignoreInit = TRUE)
    
    observeEvent( input$plot_selected, {
      selected <<- input$plot_selected
      indxs = which(neighborhood_data$pop_ID == input$plot_selected)
      step = neighborhood_data[-indxs, ]
      rv$ordered_data <<- rbind(step, neighborhood_data[indxs, ])
    }, ignoreInit = TRUE)
    
    # after reordering plot, re-select clicked population 
    session$onFlushed(function() {
      session$sendCustomMessage(type = "pop_clickable-plot_set", message = selected)
      session$sendCustomMessage(type = "pop_clickable-plot_key_set", message = selected)
    }, once = FALSE)
    
  })
}

