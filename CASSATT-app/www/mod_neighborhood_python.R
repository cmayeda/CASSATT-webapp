library(reticulate)

neighborhood_python_server <- function(input, output, session,
                                          n_data) {

  virtualenv_create("py_env")
  use_virtualenv("py_env", required = TRUE)

  source_python("guessing_functions.py")
} 