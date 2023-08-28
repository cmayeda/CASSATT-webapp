shinyServer(function(input, output, session) {

  rv <- reactiveValues(
    expr_img_list = paste0("www/assets/feature_expr/", list.files("www/assets/feature_expr/", pattern = ".jpg")),
    colormode = "custom",
    hover_color = "",
    selected_color = "",
    neighbor_color = ""
  )
  
  # -- Help Text -- 
  observeEvent(input$hide_help, {
    toggle(selector = ".help_text", anim = TRUE, animType = "slide")
    if (input$hide_help %% 2 == 1) {
      updateActionButton(session, "hide_help", label = "show help text") 
    } else {
      updateActionButton(session, "hide_help", "hide help text")
    }
  })
  
  # -- Colorblind Setting -- 
  observeEvent(input$colormode, {
    if (input$colormode %% 2 == 1) {
      rv$expr_img_list <<- paste0("www/assets/feature_expr/colorblind/", list.files("www/assets/feature_expr/colorblind/", pattern = ".jpg"))
      rv$colormode <<- "viridis"
      rv$hover_color <<- "#ffaaaa"
      rv$selected_color <<- "#ff0202"
      rv$neighbor_color <<- "#ce9810" 
      updateActionButton(session, "colormode", label = "default color mode") 
    } else {
      rv$expr_img_list <<- paste0("www/assets/feature_expr/", list.files("www/assets/feature_expr/", pattern = ".jpg"))
      rv$colormode <<- "custom"
      rv$hover_color <<- "#ddcca1"
      rv$selected_color <<- "#fbb700"
      rv$neighbor_color <<- "#41657c"
      updateActionButton(session, "colormode", label = "colorblind mode")
    }
  }, ignoreInit = F, ignoreNULL = F)
  
  # -- 5: Cell Feature Expression -- 
  output$expr_CD3 <- renderImage({ list(src = rv$expr_img_list[1]) }, deleteFile = FALSE)
  output$expr_CD4 <- renderImage({ list(src = rv$expr_img_list[2]) }, deleteFile = FALSE)
  output$expr_CD8 <- renderImage({ list(src = rv$expr_img_list[4]) }, deleteFile = FALSE)
  output$expr_CD68 <- renderImage({ list(src = rv$expr_img_list[3]) }, deleteFile = FALSE)
  output$expr_FoxP3 <- renderImage({ list(src = rv$expr_img_list[5]) }, deleteFile = FALSE)
  output$expr_Iba1 <- renderImage({ list(src = rv$expr_img_list[6]) }, deleteFile = FALSE)
  output$expr_PD <- renderImage({ list(src = rv$expr_img_list[7]) }, deleteFile = FALSE)
  output$expr_PDL <- renderImage({ list(src = rv$expr_img_list[8]) }, deleteFile = FALSE)
  
  # -- 6: Population ID -- 
  pop_clickable_server("pop_clickable", rv)
  
  # -- 7: Neighborhood ID & Analysis -- 
  callModule(neighborhood_clickable_server, "neighborhood_clickable", rv)

})
