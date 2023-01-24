library(shiny)
library(shinyjs)
library(reticulate)

shinyServer(function(input, output, session) {

  # virtualenv_create("py_env")
  # use_virtualenv("py_env", required = TRUE)
  
  # source_python("guessing_functions.py")

  # -- Help Text -- 
  observeEvent(input$hide_help, {
    toggle(selector = ".help_text", anim = TRUE, animType = "slide")
    if (input$hide_help %% 2 == 1) {
      updateActionButton(session, "hide_help", label = "show help text") 
    } else {
      updateActionButton(session, "hide_help", "hide help text")
    }
  })
  
  
})
