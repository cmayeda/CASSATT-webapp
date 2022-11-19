library(shiny)
library(reticulate)

shinyServer(function(input, output) {

  virtualenv_create("py_env")
  use_virtualenv("py_env", required = TRUE)
  
  # source_python("guessing_functions.py")

  
})
