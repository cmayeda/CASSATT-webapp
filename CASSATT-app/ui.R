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
          tags$p(class = "help_text", "Welcome to an interactive web-based demo of CASSATT!  This pipeline will serve as an introduction to 
                 the major steps involved in processing high dimensional imaging datasets for single cell-based analyses and then quantifying
                 the spatial relationships between identified cell populations. While CASSATT was initially built to process cyclic immunohistochemistry
                 datasets, the downstream analysis (Steps 5-9) can be applied to any high dimensional imaging modality. A far more extensive exploration
                 of CASSATT’s functions than presented in this demo is available at (https://pubmed.ncbi.nlm.nih.gov/36748312).")
      )
  ),
  fluidRow(
      column(10, offset = 1,
          tags$h3("Tile-Based Analysis of Whole Slides"),
          fluidRow(
              column(6, 
                  tags$img(src = "assets/whole_slide.jpg")
              ),
              column(6,
                  tags$p(class = "help_text", "To efficiently analyze large scanned slide images from multiple rounds of staining, CASSATT is 
                  designed to parallel process data on a per-tile basis.  The dataset provided for this demonstration is a four-tile subset of a larger dataset.") 
              )
          )
      )
  ), 
  
  # -- STEP 1: Cyclic IHC data collection -- 
  fluidRow(
      column(10, offset = 1, 
          tags$h3("Step 1: Cyclic IHC Data Collection")
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
                  tags$p(class = "help_text", "CASSATT was first designed to process whole slide scan images from cyclic immunohistochemistry (cycIHC)
                         datasets. cycIHC utilizes sequential rounds of colorimetric immunostaining and imaging on the same tissue section for quantitative
                         mapping of location and number of cells of interest. Amino ethyl carbazol (AEC) is a red colored chromogen commonly used for
                         its contrast with blue hematoxylin counter stain and ability to be easily stripped from tissue using ethanol. 
                         Here we show eight rounds of AEC staining for common immune markers on a glioblastoma tumor tissue section. 
                         As tissue loss can often be observed across the rounds of staining, CASSATT automatically detects and analyzes only
                         tissue areas that persist through all rounds of staining")
              ) 
          )
      )
  ),
  
  # -- STEP 2: Gross Tissue Registration -- 
  fluidRow(
      column(10, offset = 1, 
          tags$h3("Step 2: Gross Tissue Registration")
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
                  tags$p(class = "help_text", "To analyze single cell expression data from a cyclic IHC experiment, near pixel 
                         perfect registration across all rounds of staining is crucial. To that end, first rounds of staining 
                         are registered at a lower resolution that captures the presence and shape of the gross tissue section. 
                         Registration at this level is more robust to large scale shifts in the tissue position within the imaged 
                         area, as well as loss of tissue due to repeated handling of slides required for cyclic staining.")
              )
          )
      )
  ),
  
  # -- STEP 3: Image Tiling & Tissue Detection -- 
  fluidRow(
      column(10, offset = 1, 
          tags$h3("Step 3: Image Tiling & Tissue Detection")
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
                  tags$p(class = "help_text", "After tissue registration, each image file is split into a grid of tiles of user-defined size. 
                         The fraction of each tile containing analyzable tissue is computed (shown here in blue squares), and only tiles meeting
                         a user defined threshold for tissue composition will be analyzed - further minimizing unnecessary computation load.")
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
                  tags$p(class = "help_text", "For each tile containing sufficient tissue for analysis, a keypoints detection and 
                         matching registration strategy is used to achieve pixel-level registration of individual cells. In each image, 
                         keypoints are detected and their coordinates and descriptors are saved. A transformation is computed that 
                         minimizes the distance between matching keypoints and maximizes the number of keypoint matches that produce 
                         this transformation. Each image is first registered to its corresponding round zero image. Registering all 
                         images in a series back to the original round image eliminates the danger of a ‘drift’ in registration where 
                         registration errors may be propagated down the line of registrations.")
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
                tags$p(class = "help_text", "By default, CASSATT uses a custom trained Stardist segmentation model trained on hematoxylin staining
                       to achieve nuclear segmentation. A pixel expansion of user-defined distance is used to capture 'cytoplasmic' signal around 
                       detected nuclei. Alternate Stardist segmentation models or any segmentation strategy that produces a segmentation mask can 
                       be easily substituted at this step.")
            ) 
         )
      )
  ),
  
  # -- STEP 6: Cell Feature Extraction and Plotting -- 
  fluidRow(
      column(10, offset = 1, 
          tags$h3("Step 6: Cell Feature Extraction and Plotting")
      )
  ),
  fluidRow(
      column(10, offset = 1,
          fluidRow(
              column(8, id = "feature_expr", 
                  fluidRow(
                      column(3,
                          tags$h6("PD-1"),
                          imageOutput("expr_PD", height = "100%")
                      ),
                      column(3,
                          tags$h6("PD-L1"),
                          imageOutput("expr_PDL", height = "100%")
                      ),
                      column(3,
                          tags$h6("CD68"),
                          imageOutput("expr_CD68", height = "100%")
                      ),
                      column(3,
                          tags$h6("CD3"),
                          imageOutput("expr_CD3", height = "100%")
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
                          tags$h6("CD8"),
                          imageOutput("expr_CD8", height = "100%")
                      ),
                      column(3,
                          tags$h6("CD4"),
                          imageOutput("expr_CD4", height = "100%")
                      ),
                    ),
             ),
             column(4,
                  tags$p(class = "help_text", "Marker expression values on each segmented cell are quantified and assembled into an expression table.  
                         Cells can now be plotted by their coordinates with marker expression displayed as heat.")
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
          tags$h3("Step 8: Log Odds Interaction Analysis")
      )
  ),
  fluidRow(
      column(10, offset = 1,
          fluidRow(
              column(8, 
                  imageOutput("log_odds", height = "100%", width = "75%")
              ),
              column(4,
                  tags$p(class = "help_text", "Log odds values represent the relative chance that cells of two populations will interact with 
                         each other given their frequency and distribution within the dataset. A log odds value greater than 1 indicates a 
                         greater than random chance interaction frequency, and conversely a log odds value less than -1 indicates the 
                         interaction frequency is less than what would be expected by random chance.")
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
  
  
  # -- STEP 10: All Neighborhoods Analyzed --
  fluidRow(
    column(10, offset = 1,
           tags$h3("Step 10: All Neighborhoods Analyzed")
    )
  ),
  fluidRow(
    column(10, offset = 1,
           all_neighborhoods_ui("all_neighborhood"),
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
