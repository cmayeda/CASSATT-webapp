# R Shiny app for CASSATT Pipeline 
# created by Cass Mayeda 
# 11/18/2022 

library(shiny)

shinyUI(fluidPage(

    fluidRow(
      tags$h1("CASSATT Image Analysis Pipeline"),
    ), 
  
    fluidRow(
      column(3,
        numericInput("user_guess", "Guess a number: ", value = 0),
        actionButton("submit", "submit")
      ), 
    )
    
))
