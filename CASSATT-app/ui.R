# R Shiny app for CASSATT Pipeline 
# created by Cass Mayeda 
# 11/18/2022 

library(shiny)

shinyUI(fluidPage(

  titlePanel("", windowTitle = "CASSATT"),
  tags$head(
    tags$link(rel="stylesheet", type="text/css", href="css/style.css"),
    tags$link(rel="stylesheet", type="text/css", href="css/static-intro.css"),
    # tags$link(rel="stylesheet", href="https://fonts.googleapis.com/css?family=Roboto|Urbanist")
  ),
  
  # -- NAVBAR -- 
  fluidRow(id = "navbar",
      column(12,
          tags$div(id = "cytolab_home",
              tags$img(src = "assets/arrow.png"),
              tags$a(href = "https://cytolab.github.io", "Cytolab Home")
          ), 
          actionButton("hide_help", "Hide help text"),
          # actionButton("clear_session", "CLEAR SESSION"),
          actionButton("colorblind", "colorblind mode")
      )
  ),
  
  # -- TITLE & INTRO -- 
  fluidRow(
      column(10, offset = 1, 
          tags$h1("CASSATT Imaging Analysis Pipeline"),
          tags$p(class = "help_text", "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam nec tellus imperdiet, 
          mollis purus non, ornare lectus. Pellentesque cursus pellentesque magna. Etiam ac turpis bibendum, fermentum 
          enim vitae, feugiat nulla. Morbi pharetra euismod dictum. Class aptent taciti sociosqu ad litora torquent per 
          conubia nostra, per inceptos himenaeos. In tincidunt arcu nisl, vel aliquet magna placerat ultrices. Sed 
          sollicitudin nisl lectus, non congue nibh accumsan non. Vivamus imperdiet bibendum lobortis. Praesent gravida 
          enim a aliquam faucibus. Vivamus gravida gravida ultricies. Cras id sem et purus dapibus fringilla. Nullam 
          porttitor lacus accumsan enim scelerisque gravida. Interdum et malesuada fames ac ante ipsum primis in faucibus. 
          Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Pellentesque purus libero, 
          egestas non turpis ut, ornare dapibus tortor.")
      )
  ),
  
  # -- STEP 1 -- 
  fluidRow(
      column(10, offset = 1, 
          tags$h3("Step 1: Cyclic IHD Data Collection")
      )
  ),
  fluidRow(
      column(10, offset = 1,
          fluidRow(
              column(4,
                  tags$img(src = "assets/fig1-A.jpg")
              ),
              column(4,
                  fluidRow(
                      column(3, tags$img(src = "")),
                      column(3, tags$img(src = "")),
                      column(3, tags$img(src = "")),
                      column(3, tags$img(src = "")),
                  ),
                  fluidRow(
                    column(3, tags$img(src = "")),
                    column(3, tags$img(src = "")),
                    column(3, tags$img(src = "")),
                    column(3, tags$img(src = "")),
                  )
              ),
              column(4,
                  tags$p(class = "help_text", "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam nec tellus imperdiet, 
                  mollis purus non, ornare lectus. Pellentesque cursus pellentesque magna. Etiam ac turpis bibendum, fermentum 
                  enim vitae, feugiat nulla. Morbi pharetra euismod dictum. Class aptent taciti sociosqu ad litora torquent per 
                  conubia nostra, per inceptos himenaeos.")
              ) 
          )
      )
  ),
  
  # -- STEP 2 -- 
  fluidRow(
      column(10, offset = 1, 
          tags$h3("Step 2: Image Registration")
      )
  ),
  fluidRow(
      column(10, offset = 1,
          fluidRow(
              column(8,
                  fluidRow(
                      column(6,
                          tags$img(id = "tissue-reg-cartoon", src = "assets/fig1-B-tissue.jpg"),       
                      ),
                      column(6,
                          tags$img(src = "assets/fig2-A-tissue-reg.jpg"),    
                      )
                  ),
                  fluidRow(
                      column(6,
                          tags$img(id = "cell-reg-cartoon", src = "assets/fig1-B-cell.jpg") 
                      ),
                      column(6,
                          tags$img(src = "assets/fig3-A-keypoints.jpg")
                      )
                  )
              ), 
              column(4,
                  tags$p(class = "help_text", "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam nec tellus imperdiet, 
                  mollis purus non, ornare lectus. Pellentesque cursus pellentesque magna. Etiam ac turpis bibendum, fermentum 
                  enim vitae, feugiat nulla. Morbi pharetra euismod dictum. Class aptent taciti sociosqu ad litora torquent per 
                  conubia nostra, per inceptos himenaeos.")
              )
          )
      )
  ),
  
  # -- STEP 3 -- 
  fluidRow(
      column(10, offset = 1, 
          tags$h3("Step 3: Tile & Tissue Detection")
      )
  ),
  fluidRow(
      column(10, offset = 1,
          fluidRow(
              column(4,
                  tags$img(src = "assets/fig1-A.jpg")
              ),
              column(4,
              ),
              column(4,
                  tags$p(class = "help_text", "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam nec tellus imperdiet, 
                  mollis purus non, ornare lectus. Pellentesque cursus pellentesque magna. Etiam ac turpis bibendum, fermentum 
                  enim vitae, feugiat nulla. Morbi pharetra euismod dictum. Class aptent taciti sociosqu ad litora torquent per 
                  conubia nostra, per inceptos himenaeos.")
              ) 
          )
      )
  ),
  
  # -- STEP 4 -- 
  fluidRow(
      column(10, offset = 1, 
          tags$h3("Step 4: Cell Segmentation")
      )
  ),
  fluidRow(
      column(10, offset = 1,
         fluidRow(
            column(4,
                tags$img(src = "assets/fig1-C-segmentation.jpg")
            ),
            column(4,
                tags$img(src = "assets/fig4-mask.jpg")
            ),
            column(4,
                tags$p(class = "help_text", "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam nec tellus imperdiet, 
                mollis purus non, ornare lectus. Pellentesque cursus pellentesque magna. Etiam ac turpis bibendum, fermentum 
                enim vitae, feugiat nulla. Morbi pharetra euismod dictum. Class aptent taciti sociosqu ad litora torquent per 
                conubia nostra, per inceptos himenaeos.")
            ) 
         )
      )
  ),
    
))
