shinyServer(function(input, output, session) {

  rv <- reactiveValues(
    expr_img_list = paste0("www/assets/feature_expr/", list.files("www/assets/feature_expr/", pattern = ".jpg")),
    log_odds = paste0("www/assets/summertime_logodds.png"), 
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
  
  # -- Color Deficiency Setting -- 
  observeEvent(input$colormode, {
    if (input$colormode %% 2 == 1) {
      rv$expr_img_list <<- paste0("www/assets/feature_expr/color_deficient/", list.files("www/assets/feature_expr/color_deficient/", pattern = ".jpg"))
      rv$log_odds <<- paste0("www/assets/viridis_logodds.png")
      rv$colormode <<- "viridis"
      rv$hover_color <<- "#ffaaaa"
      rv$selected_color <<- "#ff0202"
      rv$neighbor_color <<- "#ce9810" 
      updateActionButton(session, "colormode", label = "default color mode") 
    } else {
      rv$expr_img_list <<- paste0("www/assets/feature_expr/", list.files("www/assets/feature_expr/", pattern = ".jpg"))
      rv$log_odds <<- paste0("www/assets/pearl_logodds.png")
      rv$colormode <<- "custom"
      rv$hover_color <<- "#ddcca1"
      rv$selected_color <<- "#fbb700"
      rv$neighbor_color <<- "#41657c"
      updateActionButton(session, "colormode", label = "color deficiency mode")
    }
  }, ignoreInit = F, ignoreNULL = F)
  
  # -- 6: Cell Feature Expression -- 
  output$expr_CD3 <- renderImage({ list(src = rv$expr_img_list[1]) }, deleteFile = F)
  output$expr_CD4 <- renderImage({ list(src = rv$expr_img_list[2]) }, deleteFile = F)
  output$expr_CD8 <- renderImage({ list(src = rv$expr_img_list[4]) }, deleteFile = F)
  output$expr_CD68 <- renderImage({ list(src = rv$expr_img_list[3]) }, deleteFile = F)
  output$expr_FoxP3 <- renderImage({ list(src = rv$expr_img_list[5]) }, deleteFile = F)
  output$expr_Iba1 <- renderImage({ list(src = rv$expr_img_list[6]) }, deleteFile = F)
  output$expr_PD <- renderImage({ list(src = rv$expr_img_list[7]) }, deleteFile = F)
  output$expr_PDL <- renderImage({ list(src = rv$expr_img_list[8]) }, deleteFile = F)
  
  # -- 7: Population ID -- 
  pop_clickable_server("pop_clickable", rv)
  
  # -- 8: Bulk Neighborhood Analysis -- 
  output$log_odds <- renderImage ({ list(src = rv$log_odds) }, deleteFile = F)
  
  # -- 7: Neighborhood ID & Analysis -- 
  callModule(neighborhood_clickable_server, "neighborhood_clickable", rv)

})
