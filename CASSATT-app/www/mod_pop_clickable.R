pop_clickable_ui <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(
      column(8, 
        fluidRow(
          column(11, id = "pop_click_col",  girafeOutput(ns("plot"))),
          column(1, id = "pop_boxes_col", checkboxGroupInput(ns("visible_pops"), NULL, choices = c())),
        )
      ),
      column(4,
        fluidRow(
          column(12, 
            tags$p(class = "help_text", "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam 
            nec tellus imperdiet, mollis purus non, ornare lectus."),  
          ), 
          column(10,
            tags$div(class = "config_menu",
              selectInput(ns("method"), 
                label = "Method of population identification",
                choices = c("expert gating", "kmeans clustering"),
                selected = "expert gating"
              ),
            ), 
            imageOutput(ns("percent"), width = "100%", height = "100%")
          )   
        )
      ) 
    )
  )
}

text_click = "#000000"
text_hover = "#515151"

pop_clickable_server <- function(id, server_rv) {
  moduleServer(id, function(input, output, session) {
    
    rv <- reactiveValues(ordered_data = neighborhood_data,
                         col = "pop_ID",
                         pal = summertime_pal,
                         breaks = names(summertime_pal)[1:14],
                         visible = names(summertime_pal)[1:14],
                         percent_asset = "www/assets/pop_fractions_summertime.jpg")
    
    # initial plot data order 
    observeEvent( input$plot_selected, {
      rv$ordered_data <<- neighborhood_data
    }, ignoreInit = FALSE, ignoreNULL = FALSE, once = TRUE)

    # change color modes, reset plot on method change  
    observeEvent( c(input$method, server_rv$colormode), {
      rv$ordered_data <<- neighborhood_data
      selected <<- character(0)
      
      if (server_rv$colormode == "custom") {
        rv$percent_asset <<- "www/assets/clust_fractions_summertime.jpg"
        if (input$method == "expert gating") {
          rv$pal <<- summertime_pal
          rv$percent_asset <<- "www/assets/pop_fractions_summertime.jpg"
          rv$col <<- "pop_ID"
          rv$visible <<- names(summertime_pal)[1:14]
          rv$breaks <<- names(summertime_pal)[1:14]
        } else {
          rv$pal <<- summertime_expanded
          rv$percent_asset <<- "www/assets/clust_fractions_summertime.jpg"
          rv$col <<- "kmeans_cluster"
          rv$visible <<- c(0:14)
          rv$breaks <<- as.character(0:14)
        }
      } else {
        rv$percent_asset <<- "www/assets/clust_fractions_summertime.jpg"
        if (input$method == "expert gating") {
          rv$pal <<- viridis_expert
          rv$percent_asset <<- "www/assets/pop_fractions_viridis.jpg"
          rv$col <<- "pop_ID"
          rv$visible <<- names(summertime_pal)[1:14]
          rv$breaks <<- names(summertime_pal)[1:14]
        } else {
          rv$pal <<- viridis_kmeans
          rv$percent_asset <<- "www/assets/clust_fractions_kmeans.jpg"
          rv$col <<- "kmeans_cluster"
          rv$visible <<- c(0:14)
          rv$breaks <<- as.character(0:14)
        }
      }
    }, ignoreInit = F)
    
    # show/hide populations by checkbox selection 
    observeEvent( rv$breaks, {
      updateCheckboxGroupInput(
        session, "visible_pops", label = NULL, 
        choices = rv$breaks, selected = rv$visible)
    })
    
    observeEvent( input$visible_pops, {
      
      # remove a population, keep a blank row for legend 
      rm = setdiff(rv$visible, input$visible_pops)
      
      if (length(rm) > 0) { 
        indxs = which(rv$ordered_data[, rv$col] == rm)
        blank_row = as.data.frame(matrix(ncol = 18))
        colnames(blank_row) <- colnames(rv$ordered_data)
        blank_row$Global_x <- 500
        blank_row$Global_y <- 51
        blank_row[, rv$col] <- unique(rv$ordered_data[indxs, rv$col])
        rv$ordered_data <<- rbind(rv$ordered_data[-indxs, ], blank_row)
        
        # reorder breaks  
        br_step = rv$breaks[!rv$breaks == rm]
        rv$breaks <<- c(br_step, rm)
        
        # set color to white 
        rv$pal[rm] <<- "#ffffff"
        
        # unselect in key
        if (length(selected) > 0) {
          if (rm == selected) {
            selected <<- character(0)
          }
        }
      }
       
      # add back a population, remove blank row 
      ad = setdiff(input$visible_pops, rv$visible) 
      if (length(ad) > 0) {
        blank_indx = which(rv$ordered_data[, rv$col] == ad)
        step = rv$ordered_data[-blank_indx, ]
        ad_indxs = which(neighborhood_data[, rv$col] == ad)
        rv$ordered_data <<- rbind(step, neighborhood_data[ad_indxs, ]) 
        
        # reorder breaks 
        br_step = rv$breaks[!rv$breaks == ad]
        rv$breaks <<- c(ad, br_step)
        
        # replace color 
        if (server_rv$colormode == "custom") {
          rv$pal[ad] <<- summertime_pal[ad]
        } else {
          rv$pal[ad] <<- viridis_expert[ad]
        }
        
        # select in key and on plot
        selected <<- ad
      }
      rv$visible <<- input$visible_pops
    }, ignoreInit = TRUE, ignoreNULL = TRUE)
    
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
      girafe(ggobj = gg, options = list(
        opts_toolbar(saveaspng = FALSE),
        opts_hover(css = paste0("stroke:",server_rv$hover_color,"; stroke-width:1px;")),
        opts_hover_key(css = girafe_css(
          css = paste0("stroke:",server_rv$hover_color,"; stroke-width:1px;"),
          text = paste0("stroke:",text_hover,"; stroke-width:0.5px;")
        )),
        opts_selection(css = paste0("stroke:",server_rv$selected_color,"; stroke-width:1px;"), type = "single"),
        opts_selection_key(css = girafe_css(
          css = paste0("stroke:",server_rv$selected_color,"; stroke-width:1px"),
          text = paste0("stroke-width:0.5px; stroke:",text_click,";")
        ), type = "single"))
      )
    })
    
    # reorder plot data with clicked population on top 
    selected = character(0)
    
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
    
    # Whole slide population / cluster percent of total cells 
    output$percent <- renderImage({ list(src = rv$percent_asset) }, deleteFile = F)
    
  })
}

