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
                      choices = c("expert gating", "kmeans clustering"),
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

pop_clickable_server <- function(id, server_rv) {
  moduleServer(id, function(input, output, session) {
    
    rv <- reactiveValues(ordered_data = neighborhood_data,
                         col = "pop_ID",
                         pal = summertime_pal,
                         breaks = names(summertime_pal))
    
    outline_click = "#fbb700"
    outline_hover = "#ddcca1"
    text_click = "#000000"
    text_hover = "#515151"
    
    gir_options = list(
      opts_toolbar(saveaspng = FALSE),
      opts_hover(css = paste0("stroke:",outline_hover,"; stroke-width:1px;")),
      opts_hover_key(css = girafe_css(
        css = paste0("stroke:",outline_hover,"; stroke-width:1px;"),
        text = paste0("stroke:",text_hover,"; stroke-width:0.5px;")
      )),
      opts_selection(css = paste0("stroke:",outline_click,"; stroke-width:1px;"), type = "single"),
      opts_selection_key(css = girafe_css(
        css = paste0("stroke:",outline_click,"; stroke-width:1px"),
        text = paste0("stroke-width:0.5px; stroke:",text_click,";")
      ), type = "single")
    )
    
    # initial plot data order 
    observeEvent( input$plot_selected, {
      rv$ordered_data <<- neighborhood_data
    }, ignoreInit = FALSE, ignoreNULL = FALSE, once = TRUE)
    
    # toggle method types & colormode
    observeEvent( c(input$method, server_rv$colormode), {
      if(input$method == "kmeans clustering") { 
        rv$col <<- "kmeans_cluster"
        if (server_rv$colormode == "custom") { 
          rv$pal <<- summertime_expanded
        } else {
          rv$pal <<- viridis_kmeans
        }
        rv$breaks <<- as.character(0:15)
      } else {
        rv$col <<- "pop_ID"
        if (server_rv$colormode == "custom") { 
          rv$pal <<- summertime_pal
        } else {
          rv$pal <<- viridis_expert
        }
        rv$breaks <<- names(summertime_pal)
      }
    }, ignoreInit = TRUE)
    
    # interactive plot and legend 
    output$plot <- renderGirafe({ 
      
      # delay updating plot until break order is updated
      req(rv$breaks)
      
      gg = ggplot(rv$ordered_data) +
        geom_point_interactive(aes(
          x = Global_x, y = Global_y,
          col = rv$ordered_data[, rv$col], 
          tooltip = rv$ordered_data[, rv$col], 
          data_id = rv$ordered_data[, rv$col]
        ), cex = dot_size) +
        scale_color_manual_interactive(
          name = "Population",
          values = rv$pal,
          breaks = rv$breaks,
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
      if (!is.null(input$plot_key_selected)) {
        selected <<- input$plot_key_selected
        br_step = rv$breaks[!rv$breaks == selected]
        rv$breaks <<- c(selected, br_step)
        indxs = which(rv$ordered_data[, rv$col] == selected)
        step = rv$ordered_data[-indxs, ]
        rv$ordered_data <<- rbind(step, rv$ordered_data[indxs, ])
      } else {
        selected <<- character(0)
      }
    }, ignoreInit = TRUE, ignoreNULL = FALSE)
    
    observeEvent( input$plot_selected, {
      if (!is.null(input$plot_selected)) {
        selected <<- input$plot_selected
        br_step = rv$breaks[!rv$breaks == selected]
        rv$breaks <<- c(selected, br_step)
        indxs = which(rv$ordered_data[, rv$col] == selected)
        step = rv$ordered_data[-indxs, ]
        rv$ordered_data <<- rbind(step, rv$ordered_data[indxs, ])
      } else {
        selected <<- character(0)
      }
    }, ignoreInit = TRUE, ignoreNULL = FALSE)
    
    # after reordering plot, re-select clicked population 
    session$onFlushed(function() {
      session$sendCustomMessage(type = "pop_clickable-plot_set", message = selected)
      session$sendCustomMessage(type = "pop_clickable-plot_key_set", message = selected)
    }, once = FALSE)
    
  })
}

