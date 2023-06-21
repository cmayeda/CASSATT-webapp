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
                         ordered_data = neighborhood_data)

    # create interactive plot and legend 
    gir <- reactive({
      ggplot(rv$ordered_data) +
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
    })
    
    # place clicked population on top   
    observeEvent( rv$current_pop, {
      indxs = which(neighborhood_data$pop_ID == rv$current_pop)
      step = neighborhood_data[-indxs, ]
      rv$ordered_data <<- rbind(step, neighborhood_data[indxs, ])
    }, ignoreInit = TRUE, ignoreNULL = TRUE)
    
    # set plot to match legend click 
    observeEvent( input$plot_key_selected, {
      if (is.null(input$plot_key_selected)) {
        rv$current_pop <<- NULL
        session$sendCustomMessage(type = "pop_clickable-plot_set", message = character(0))
      } else {
        rv$current_pop <<- input$plot_key_selected
        session$sendCustomMessage(type = "pop_clickable-plot_set", rv$current_pop)
      }
    }, ignoreInit = TRUE, ignoreNULL = FALSE)
    
    # set legend to match plot click 
    observeEvent( input$plot_selected, {
      if (is.null(input$plot_selected)) {
        rv$current_pop <<- NULL
        session$sendCustomMessage(type = "pop_clickable-plot_key_set", message = character(0))
      } else {
        rv$current_pop <<- input$plot_selected
        session$sendCustomMessage(type = "pop_clickable-plot_key_set", message = rv$current_pop)
      }
    }, ignoreInit = TRUE, ignoreNULL = FALSE)
    
    gir_options = list(
      opts_toolbar(saveaspng = FALSE),
      opts_hover(css = "stroke:#cece5b2; stroke-width:1px;"),
      opts_hover_key(css = "stroke:#cece5b2; stroke-width:1px;"),
      opts_selection(css = "stroke:#000000; stroke-width:1px;", type = "single"),
      opts_selection_key(css = "stroke:#000000; stroke-width:1px;", type = "single")
    )
    
    output$plot <- renderGirafe({
      girafe(ggobj = gir(), options = gir_options)
    })
  })
}

