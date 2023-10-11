library(cowplot)
library(grid)
library(gridExtra)


all_neighborhoods_ui <- function(id) {
  ns <- NS(id)
  tagList(
    # column structure to align exactly with pop clickable 
    fluidRow(
      column(8,
             fluidRow(
               column(11, plotOutput(ns("allplots")))
             )
      ),

      column(4,
             tags$p(class = "help_text", "In addition to examining the neighborhoods of individual cells, CASSATT clusters the dataset into 
                    'Neighbor Clusters', each of which is a subset of cells that have a similar neighbor cell composition." ),
      ),
      
      column(4, 
             actionButton(ns("plotdisplay"), "Show Box and Whisker Plots")
      ),
      column(4, id = "deca_key_col", 
             plotOutput(ns("deca_key"), height = "200px")
      )
    )
  )
}


all_neighborhood_server <- function(input, output, session, server_rv) {
  rv <- reactiveValues(
    plotmode = "decagons",
    deca_colors = NULL
    )
  
  
  observeEvent(input$plotdisplay, {
    if (input$plotdisplay %% 2 == 1) {
      rv$plotmode <<- "boxwhisker"
      updateActionButton(session, "plotdisplay", label = "Show Decagon Plots")

    } else {
      rv$plotmode <<- "decagons"
      updateActionButton(session, "plotdisplay", label = "Show Box and Whisker Plots")
    }
  })

  
  observeEvent(rv$plotmode, {
    if (rv$plotmode == 'boxwhisker') {
      output$allplots <- renderImage({
        neighborhood_whisker_all(server_rv$colormode)
        list(src = "all_box_whisker.png")
      }, deleteFile = T)
    } else {
      output$allplots <- renderPlot({
        l_plots = list()
        l_colors = deca_all(neighborhood_data, server_rv$colormode)
        for (index in seq_along(l_colors)) {
          plot = ggplot(decagons)
          for (i in 1:10) {
            indxes = which(decagons$name == as.character(i))
            plot <- plot + geom_polygon(
              data = decagons[indxes, ], aes(x = x, y = y),
              fill = l_colors[[index]][[i]],
              color = "black", linewidth = 1.25
            )
          }
          plot <- plot +
            coord_fixed() +
            theme_deca() 

          l_plots[[index]] <-plot
        }


        allplot = plot_grid(plotlist = l_plots, nrow = 3)
        return(allplot)
      })
    }
  })

  
  observeEvent(server_rv$colormode, {
    colors = unique(unlist(deca_all(neighborhood_data, server_rv$colormode)))
    if (server_rv$colormode == "custom") {
      types = sapply(colors, function(x) { as.numeric(which(summertime_pal == x)) })
      types <- names(summertime_pal)[types]
    } else {
      types = sapply(colors, function(x) { as.numeric(which(viridis_expert == x)) })
      types <- names(viridis_expert)[types]
    }
    df = data.frame(x = c(1:length(colors)))
    plot = ggplot(df, aes(x = x, y = 1, col = as.factor(x))) +
      geom_point(size = 5) +
      scale_color_manual(values = colors, labels = types, name = "Population") +
      theme_bw() +
      theme(
        legend.title = element_text(size = 14.5, lineheight = 1.3),
        legend.text = element_text(size = 14.5, lineheight = 1.3),
        legend.justification = "left"
      )
    rv$deca_key <<- get_legend(plot)
    
  })
  
  output$deca_key <- renderPlot({ grid.draw(rv$deca_key) })
  
}

