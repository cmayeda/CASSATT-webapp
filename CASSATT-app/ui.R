# R Shiny app for CASSATT Pipeline 
# created by Cass Mayeda, protocol by Asa Brockman
# Last updated 08/30/2023

shinyUI(fluidPage(
  useShinyjs(),
  titlePanel("", windowTitle = "CASSATT"),
  tags$head(
    tags$link(rel="stylesheet", type="text/css", href="css/style.css"),
    tags$link(rel="stylesheet", type="text/css", href="css/static-intro.css"),
    tags$link(rel="stylesheet", href="https://fonts.googleapis.com/css?family=Roboto")
  ),
  
  # -- NAVBAR -- 
  fluidRow(id = "navbar",
      column(12,
          tags$div(id = "cytolab_home",
              tags$img(src = "assets/arrow.png"),
              tags$a(href = "https://cytolab.github.io", "Cytolab Home")
          ), 
          actionButton("hide_help", "Hide help text"),
          actionButton("colormode", "adaptive color mode")
      )
  ),
  
  # -- TITLE & INTRO -- 
  fluidRow(
      column(10, offset = 1, 
          tags$h1("CASSATT Imaging Analysis Pipeline"),
          tags$p(class = "help_text", "Welcome to an interactive web-based demo of CASSATT!  This pipeline will serve as an 
                 introduction to the major steps involved in processing high dimensional imaging datasets for single cell based 
                 analyses as well as quantifying the spatial relationships between identified cell populationsl 
                 A far more extensive exploration of CASSATT’s functions than presented in this demo is available at 
                 (https://pubmed.ncbi.nlm.nih.gov/36748312).")
      )
  ),
  fluidRow(
      column(10, offset = 1,
          tags$h3("Tile-based analysis of whole slides"),
          fluidRow(
              column(6, 
                  tags$img(src = "assets/whole_slide.jpg")
              ),
              column(6,
                  tags$p(class = "help_text", "To efficiently analyze large scanned slide images from multiple rounds of staining, CASSATT is designed to parallel process data on a 
                         per-tile basis.  The dataset provided for this demonstration is a four-tile subset of a larger dataset.") 
              )
          )
      )
  ), 
  
  # -- STEP 1: Data Collection -- 
  fluidRow(
      column(10, offset = 1, 
          tags$h3("Step 1: Cyclic IHC data collection")
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
                          tags$h6("PD-1"),
                          tags$img(src = "assets/raw_thumbnails/raw_PD-1_thumbnail.jpg")
                      ),
                      column(3,
                          tags$h6("PD-L1"),
                          tags$img(src = "assets/raw_thumbnails/raw_PD-L1_thumbnail.jpg")
                      ),
                      column(3,
                          tags$h6("CD68"),
                          tags$img(src = "assets/raw_thumbnails/raw_CD68_thumbnail.jpg")
                      ),
                      column(3,
                          tags$h6("CD3"),
                          tags$img(src = "assets/raw_thumbnails/raw_CD3_thumbnail.jpg")
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
                        tags$h6("CD8"),
                        tags$img(src = "assets/raw_thumbnails/raw_CD8_thumbnail.jpg")
                    ),
                    column(3,
                        tags$h6("CD4"),
                        tags$img(src = "assets/raw_thumbnails/raw_CD4_thumbnail.jpg")
                    ),
                  )
              ),
              column(4,
                  tags$p(class = "help_text", "CASSATT is designed to process whole slide scan images from cyclic immunohistochemistry (cycIHC) datasets.  
                  cycIHC utilizes sequential rounds of colorimetric immunostaining and imaging for quantitative mapping of location and number of cells of interest. Amino ethyl carbazol (AEC) is a 
                         red colored chromogen commonly used for its contrast with blue hematoxylin counter stain and ability to be easily stripped from tissue using ethanol. Here we show eight 
                         rounds of AEC staining for common immune markers on a glioblastoma tumor tissue section. Seeing as tissue loss can often be observed across the rounds of staining, CASSATT
                         automatically detects and analyzes only tissue areas that persist through all rounds of staining")
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
                  tags$img(src = "assets/tissue_detection.png")
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
  
  
  # -- STEP 4: Cell Registration -- 
  fluidRow(
      column(10, offset = 1, 
          tags$h3("Step 4: Cell Registration")
      )
  ),
  fluidRow(
      column(10, offset = 1,
          fluidRow(
              column(8,
                  fluidRow(
                      column(6,
                          tags$img(id = "cell-reg-cartoon", src = "assets/fig1-B-cell.jpg")
                      ),
                      column(6,
                          tags$img(src = "assets/keypoints.jpg")
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
  
  # -- STEP 5: Cell Segmentation -- 
  fluidRow(
      column(10, offset = 1, 
          tags$h3("Step 5: Cell Segmentation")
      )
  ),
  fluidRow(
      column(10, offset = 1,
         fluidRow(
            column(4, class = "stardist",
                tags$img(src = "assets/stardist_mask.jpg")
            ),
            column(4, class = "stardist",
                tags$img(src = "assets/cell_segmentation.jpg")
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
  
  # -- STEP 6: Cell Feature Expression -- 
  fluidRow(
      column(10, offset = 1, 
          tags$h3("Step 6: Cell Feature Expression")
      )
  ),
  fluidRow(
      column(10, offset = 1,
          fluidRow(
              column(8, id = "feature_expr", 
                  fluidRow(
                      column(3,
                          tags$h6("CD3"),
                          imageOutput("expr_CD3", height = "100%")
                      ),
                      column(3,
                          tags$h6("CD4"),
                          imageOutput("expr_CD4", height = "100%")
                      ),
                      column(3,
                          tags$h6("CD8"),
                          imageOutput("expr_CD8", height = "100%")
                      ),
                      column(3,
                          tags$h6("CD68"),
                          imageOutput("expr_CD68", height = "100%")
                      ),
                  ),
                  fluidRow(
                      column(3, 
                          tags$h6("FoxP3"),
                          imageOutput("expr_FoxP3", height = "100%")
                      ),
                      column(3, 
                          tags$h6("Iba-1"),
                          imageOutput("expr_Iba1", height = "100%")
                      ),
                      column(3, 
                          tags$h6("PD-1"),
                          imageOutput("expr_PD", height = "100%")
                      ),
                      column(3,
                          tags$h6("PD-L1"),
                          imageOutput("expr_PDL", height = "100%")
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
  
  # -- STEP 7: Population ID -- 
  fluidRow(
      column(10, offset = 1, 
          tags$h3("Step 7: Population Identification")
      )
  ),
  fluidRow(
      column(10, offset = 1,
          pop_clickable_ui("pop_clickable")       
      )
  ),
  
  # -- STEP 8: Neighborhood ID & Analysis --
  fluidRow(
      column(10, offset = 1, 
          tags$h3("Step 8: Bulk Neighborhood Analysis")
      )
  ),
  fluidRow(
      column(10, offset = 1,
          fluidRow(
              column(8, 
                  imageOutput("log_odds", height = "100%", width = "75%")
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
  
  # -- STEP 9: Neighborhood ID & Analysis -- 
  fluidRow(
      column(10, offset = 1, 
          tags$h3("Step 9: Neighborhood Identification & Analysis")
      )
  ),
  fluidRow(
      column(10, offset = 1, 
          neighborhood_clickable_ui("neighborhood_clickable"),       
      )
  ), 

  # -- Footer -- 
  fluidRow(id = "footer", 
    column(10, offset = 1, 
      tags$p("© Copyright 2023 by Cass Mayeda, Asa Brockman, Rebecca Ihrie, and Jonathan Irish. All Rights Reserved."),
      tags$p("The CASSATT analysis pipeline is named after the American painter Mary Cassatt. The color palettes used on 
             web page are inspired by her works, in particular ", 
             tags$span(style="font-style:italic","Woman with a Pearl Necklace in a Loge"), 
             " and ", tags$span(style="font-style:italic", "Summertime"), "."),
      tags$p("Adaptive color mode uses the ", tags$a(href = "https://sjmgarnier.github.io/viridis/", "viridis"),
             " color palette with improved graph readability for people with a range of different color perceiving abilities.")
    )
  )
))
