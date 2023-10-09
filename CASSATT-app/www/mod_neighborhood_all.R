library(cowplot)
library(grid)
library(gridExtra)

# # install python packages 
# py_install(c("numpy","pandas","scipy","grispy","matplotlib","seaborn"))
# source_python("www/neighbor_functions.py")

# decagons = read.csv("www/decagons.csv")
# coords = neighborhood_data[, c("Global_x","Global_y")]


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
             actionButton(ns("plotdisplay"), "test"))
    )
  )
}


all_neighborhood_server <- function(input, output, session, server_rv) {
  rv <- reactiveValues(plotmode = "decagons")
  
  
  observeEvent(input$plotdisplay, {
    if (input$plotdisplay %% 2 == 1) {
      rv$plotmode <<- "boxwhisker"
      print('test')
      # output$allplots <- renderImage({
      #   neighborhood_whisker_all(server_rv$colormode)
      #   list(src = "all_box_whisker.png")
      # }, deleteFile = T)
      # 
      updateActionButton(session, "plotdisplay", label = "show box and whisker plots")

    } else {
      rv$plotmode <<- "decagons"
      print('test2')
      # output$allplots <- renderPlot({
      #   l_plots = list()
      #   l_colors = deca_all(neighborhood_data, server_rv$colormode)
      #   for (index in seq_along(l_colors)) {
      #     plot = ggplot(decagons)
      #     for (i in 1:10) {
      #       indxes = which(decagons$name == as.character(i))
      #       plot <- plot + geom_polygon(
      #         data = decagons[indxes, ], aes(x = x, y = y),
      #         fill = l_colors[[index]][[i]],
      #         color = "black", linewidth = 1.25
      #       )
      #     }    
      #     plot <- plot +
      #       coord_fixed() +
      #       theme_deca()
      #     
      #     l_plots[[index]] <-plot
      #   }
      #   
      #   
      #   allplot = plot_grid(plotlist = l_plots, nrow = 3)
      #   return(allplot)
      # })
      
      updateActionButton(session, "plotdisplay", label = "show decagon plots")
    }
  })

  # output$decagons <- renderPlot({
  #   l_plots = list()
  #   l_colors = deca_all(neighborhood_data, server_rv$colormode)
  #   for (index in seq_along(l_colors)) {
  #     plot = ggplot(decagons)
  #     for (i in 1:10) {
  #       indxes = which(decagons$name == as.character(i))
  #       plot <- plot + geom_polygon(
  #         data = decagons[indxes, ], aes(x = x, y = y),
  #         fill = l_colors[[index]][[i]],
  #         color = "black", linewidth = 1.25
  #       )
  #     }
  #     plot <- plot +
  #     coord_fixed() +
  #     theme_deca()
  # 
  #     l_plots[[index]] <-plot
  #   }
  #   allplot = plot_grid(plotlist = l_plots, nrow = 3)
  #   return(allplot)
  # })
  # 
  # 
  # # Box and Whisker Plot
  # output$whisker <- renderImage({
  #   neighborhood_whisker_all(server_rv$colormode)
  #   list(src = "all_box_whisker.png")
  # }, deleteFile = T)
  # observeEvent(rv$plotmode, {
  #   output$allplots <- 
  #     if (rv$plotmode == "boxwhisker"){
  #       renderImage({
  #         neighborhood_whisker_all(server_rv$colormode)
  #         list(src = "all_box_whisker.png")
  #       }, deleteFile = T)
  #     } else {
  #       renderPlot({
  #         l_plots = list()
  #         l_colors = deca_all(neighborhood_data, server_rv$colormode)
  #         for (index in seq_along(l_colors)) {
  #           plot = ggplot(decagons)
  #           for (i in 1:10) {
  #             indxes = which(decagons$name == as.character(i))
  #             plot <- plot + geom_polygon(
  #               data = decagons[indxes, ], aes(x = x, y = y),
  #               fill = l_colors[[index]][[i]],
  #               color = "black", linewidth = 1.25
  #             )
  #           }
  #           plot <- plot +
  #             coord_fixed() +
  #             theme_deca()
  #           
  #           l_plots[[index]] <-plot
  #         }
  #         
  #         
  #         allplot = plot_grid(plotlist = l_plots, nrow = 3)
  #         return(allplot)
  #       })
  #     }
  # })
  
  observeEvent(rv$plotmode, {
    if (rv$plotmode == 'boxwhisker') {
      print(input$plotdisplay)
      print('test3')
      output$allplots <- renderImage({
        neighborhood_whisker_all(server_rv$colormode)
        list(src = "all_box_whisker.png")
      }, deleteFile = T)
    } else {
      print(input$plotdisplay)
      print('test4')
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

}

