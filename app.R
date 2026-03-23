library(shiny)
library(leaflet)
library(sf)
library(readr)
library(dplyr)

source('helpers.R')

# Load data ----
mrds_on_tribal_lands <- readRDS('data/MRDS/on_tribal_lands.rds')
mrds_within_35_mi <- readRDS('data/MRDS/within_35_mi.rds')
mrds_more_than_35_mi <- readRDS('data/MRDS/more_than_35_mi.rds')
mrds_master <- read_csv('data/MRDS-Analysis/MRDS_Master_Deposits.csv',
                        show_col_types = FALSE) %>%
  mutate(DEP_ID = as.character(DEP_ID))
stakeholder_map <- read_csv('data/MRDS-Analysis/MRDS_Stakeholder_Mapping.csv',
                            show_col_types = FALSE)

usmin_on_tribal_lands <- readRDS('data/USMIN/on_tribal_lands.rds')
usmin_within_35_mi <- readRDS('data/USMIN/within_35_mi.rds')
usmin_more_than_35_mi <- readRDS('data/USMIN/more_than_35_mi.rds')

res_shapes  <- readRDS('data/reservation-shapes/reservations.rds')
buffer_lands <- readRDS('data/reservation-shapes/buffer_lands.rds')
tribe_list <- c('All Tribes', sort(stakeholder_map$Tribe_Name))

# UI layout ----
ui <- fluidPage(sidebarLayout(
  sidebarPanel(width = 3, selectInput('tribe', 'Tribe', choices = tribe_list)),
  tabsetPanel(
    id = 'page',
    tabPanel('MRDS', width = 9, leafletOutput('mrds_map', height = '80vh')),
    tabPanel('USMIN', width = 9, leafletOutput('usmin_map', height = '80vh'))
  )
))

# Define server logic ----
server <- function(input, output) {
  filtered_buffer_lands <- reactive({
    map_by_tribe(buffer_lands, input$tribe)
  })
  
  filtered_mrds_on_tribal_lands <- reactive({
    map_by_tribe(mrds_on_tribal_lands, input$tribe)
  })
  
  filtered_mrds_within_35_mi <- reactive({
    map_by_tribe(mrds_within_35_mi, input$tribe)
  })
  
  filtered_mrds_more_than_35_mi <- reactive({
    if (input$tribe == 'All Tribes') {
      mrds_more_than_35_mi
    } else {
      mrds_more_than_35_mi[0, ]
    }
  })
  
  filtered_usmin_on_tribal_lands <- reactive({
    map_by_tribe(usmin_on_tribal_lands, input$tribe)
  })
  
  filtered_usmin_within_35_mi <- reactive({
    map_by_tribe(usmin_within_35_mi, input$tribe)
  })
  
  filtered_usmin_more_than_35_mi <- reactive({
    if (input$tribe == 'All Tribes') {
      usmin_more_than_35_mi
    } else {
      usmin_more_than_35_mi[0, ]
    }
  })
  
  selected_res_shapes <- reactive({
    req(input$tribe)
    if (input$tribe == 'All Tribes') {
      res_shapes
    } else {
      res_shapes %>%
        filter(TRIBE_NAME == input$tribe)
    }
  })
  
  output$mrds_map <- renderLeaflet({
    mrds_map(
      filtered_buffer_lands(),
      filtered_mrds_on_tribal_lands(),
      filtered_mrds_within_35_mi(),
      filtered_mrds_more_than_35_mi(),
      selected_res_shapes()
    )
  })
  
  output$usmin_map <- renderLeaflet({
    usmin_map(
      filtered_buffer_lands(),
      filtered_usmin_on_tribal_lands(),
      filtered_usmin_within_35_mi(),
      filtered_usmin_more_than_35_mi(),
      selected_res_shapes()
      )
  })
}

shinyApp(ui, server)