# R Shiny app for CASSATT Pipeline 
# created by Cass Mayeda 
# 11/18/2022 

suppressPackageStartupMessages({
  library(shiny)
  library(shinyjs)
})

source("www/mod_neighborhood_clickable.R")

shinyUI(fluidPage(
  useShinyjs(),
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
  
  # -- STEP 1: Data Collection -- 
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
              column(4, id = "raw_thumbnails", 
                  fluidRow(
                      column(3,
                          tags$h6("CD3"),
                          tags$img(src = "assets/raw_thumbnails/raw_CD3_thumbnail.jpg")
                      ),
                      column(3,
                          tags$h6("CD4"),
                          tags$img(src = "assets/raw_thumbnails/raw_CD4_thumbnail.jpg")
                      ),
                      column(3,
                          tags$h6("CD8"),
                          tags$img(src = "assets/raw_thumbnails/raw_CD8_thumbnail.jpg")
                      ),
                      column(3,
                          tags$h6("CD68"),
                          tags$img(src = "assets/raw_thumbnails/raw_CD68_thumbnail.jpg")
                      ),
                  ),
                  fluidRow(
                    column(3, 
                        tags$h6("FoxP3"),
                        tags$img(src = "assets/raw_thumbnails/raw_FoxP3_thumbnail.jpg")
                    ),
                    column(3, 
                        tags$h6("Iba-1"),
                        tags$img(src = "assets/raw_thumbnails/raw_Iba-1_thumbnail.jpg")
                    ),
                    column(3, 
                        tags$h6("PD-1"),
                        tags$img(src = "assets/raw_thumbnails/raw_PD-1_thumbnail.jpg")
                    ),
                    column(3,
                        tags$h6("PD-L1"),
                        tags$img(src = "assets/raw_thumbnails/raw_PD-L1_thumbnail.jpg")
                    ),
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
  
  # -- STEP 2: Image Registration -- 
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
                          tags$img(src = "assets/fig2-A-tissue-modified.jpg"),    
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
  
  # -- STEP 3: Tile & Tissue Detection -- 
  fluidRow(
      column(10, offset = 1, 
          tags$h3("Step 3: Tile & Tissue Detection")
      )
  ),
  fluidRow(
      column(10, offset = 1,
          fluidRow(
              column(4, id = "tiled",
                  tags$img(src = "assets/tiled_PD-1.jpg")
              ),
              column(4,
                  tags$img(src = "assets/tissue_detection.jpg")
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
  
  # -- STEP 4: Cell Segmentation -- 
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
            column(4, id = "stardist",
                tags$img(src = "assets/stardist_mask.jpg")
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
  
  # -- STEP 5: Cell Feature Expression -- 
  fluidRow(
      column(10, offset = 1, 
          tags$h3("Step 5: Cell Feature Expression")
      )
  ),
  fluidRow(
      column(10, offset = 1,
          fluidRow(
              column(8, id = "feature_expr", 
                  fluidRow(
                      column(3,
                          tags$h6("CD3"),
                          plotOutput("expr_CD3", height = "100%")
                      ),
                      column(3,
                          tags$h6("CD4"),
                          plotOutput("expr_CD4", height = "100%")
                      ),
                      column(3,
                          tags$h6("CD8"),
                          plotOutput("expr_CD8", height = "100%")
                      ),
                      column(3,
                          tags$h6("CD68"),
                          plotOutput("expr_CD68", height = "100%")
                      ),
                  ),
                  fluidRow(
                      column(3, 
                          tags$h6("FoxP3"),
                          plotOutput("expr_FoxP3", height = "100%")
                      ),
                      column(3, 
                          tags$h6("Iba-1"),
                          plotOutput("expr_Iba1", height = "100%")
                      ),
                      column(3, 
                          tags$h6("PD-1"),
                          plotOutput("expr_PD", height = "100%")
                      ),
                      column(3,
                          tags$h6("PD-L1"),
                          plotOutput("expr_PDL", height = "100%")
                      ),
                    ),
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
  
  # -- STEP 6: Population ID -- 
  fluidRow(
      column(10, offset = 1, 
          tags$h3("Step 6: Population Identification")
      )
  ),
  fluidRow(
      column(10, offset = 1, 
          fluidRow(
              column(4,
                  plotOutput("cluster_plot", height = "100%")
              ),
              column(2, 
                  plotOutput("cluster_legend", height = "100%")
              ),
              column(4, offset = 2, 
                  tags$p(class = "help_text", "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam nec tellus imperdiet, 
                  mollis purus non, ornare lectus. Pellentesque cursus pellentesque magna. Etiam ac turpis bibendum, fermentum 
                  enim vitae, feugiat nulla. Morbi pharetra euismod dictum. Class aptent taciti sociosqu ad litora torquent per 
                  conubia nostra, per inceptos himenaeos.")
              ) 
          )
      )
  ),
  
  # -- STEP 7: Neighborhood ID & Analysis -- 
  fluidRow(
      column(10, offset = 1, 
          tags$h3("Step 7: Neighborhood Identification & Analysis")
      )
  ),
  neighborhood_clickable_ui("neighborhood_clickable")

))
