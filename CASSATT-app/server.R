library(shiny)
library(shinyjs)
library(reticulate)

shinyServer(function(input, output, session) {

  # virtualenv_create("py_env")
  # use_virtualenv("py_env", required = TRUE)
  
  # source_python("guessing_functions.py")

  rv <- reactiveValues(
    expr_img_list = paste0("www/assets/feature_expr/", list.files("www/assets/feature_expr/", pattern = ".jpg"))
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
  observeEvent(input$colorblind, {
    if (input$colorblind %% 2 == 1) {
      rv$expr_img_list <<- paste0("www/assets/feature_expr/colorblind/", list.files("www/assets/feature_expr/colorblind/", pattern = ".jpg"))
    } else {
      rv$expr_img_list <<- paste0("www/assets/feature_expr/", list.files("www/assets/feature_expr/", pattern = ".jpg"))
    }
  })
  
  # -- 5: Cell Feature Expression -- 
  output$expr_CD3 <- renderImage({ list(src = rv$expr_img_list[1]) }, deleteFile = FALSE)
  output$expr_CD4 <- renderImage({ list(src = rv$expr_img_list[2]) }, deleteFile = FALSE)
  output$expr_CD8 <- renderImage({ list(src = rv$expr_img_list[3]) }, deleteFile = FALSE)
  output$expr_CD68 <- renderImage({ list(src = rv$expr_img_list[4]) }, deleteFile = FALSE)
  output$expr_FoxP3 <- renderImage({ list(src = rv$expr_img_list[5]) }, deleteFile = FALSE)
  output$expr_Iba1 <- renderImage({ list(src = rv$expr_img_list[6]) }, deleteFile = FALSE)
  output$expr_PD <- renderImage({ list(src = rv$expr_img_list[7]) }, deleteFile = FALSE)
  output$expr_PDL <- renderImage({ list(src = rv$expr_img_list[8]) }, deleteFile = FALSE)
  
})
