library(shiny)
library(leaflet)
library(sf)
library(readr)
library(dplyr)
library(lobstr)
library(glue)
library(stringr)
library(tidyr)
library(lwgeom)
library(DT)

source('helpers.R')

# Load data ----
mrds_on_tribal_lands <- readRDS('data/MRDS/on_tribal_lands.rds')
mrds_within_35_mi <- readRDS('data/MRDS/within_35_mi.rds')
mrds_more_than_35_mi <- readRDS('data/MRDS/more_than_35_mi.rds')
mrds_master <- read_csv('data/MRDS_Analysis/MRDS_Master_Deposits.csv',
                        show_col_types = FALSE) %>%
  mutate(DEP_ID = as.character(DEP_ID))
mrds_mineral_summary <- read_csv('data/MRDS_Analysis/MRDS_Mineral_Summary.csv',
                                 show_col_types = FALSE)
mrds_stakeholder_map <- read_csv('data/MRDS_Analysis/MRDS_Stakeholder_Mapping.csv',
                                 show_col_types = FALSE)
mrds_res_shapes <- readRDS('data/reservation_shapes/mrds_reservations.rds')

usmin_on_tribal_lands <- readRDS('data/USMIN/on_tribal_lands.rds')
usmin_within_35_mi <- readRDS('data/USMIN/within_35_mi.rds')
usmin_more_than_35_mi <- readRDS('data/USMIN/more_than_35_mi.rds')
usmin_master <- read_csv('data/USMIN_Analysis/USMIN_Master_Deposits.csv',
                         show_col_types = FALSE)
usmin_mineral_summary <- read_csv('data/USMIN_Analysis/USMIN_Mineral_Summary.csv',
                                  show_col_types = FALSE)
usmin_stakeholder_map <- read_csv('data/USMIN_Analysis/USMIN_Stakeholder_Mapping.csv',
                                  show_col_types = FALSE)
usmin_res_shapes <- readRDS('data/reservation_shapes/usmin_reservations.rds')

buffer_lands <- readRDS('data/reservation_shapes/buffer_lands.rds')
tribe_list <- c('All Tribes', sort(mrds_stakeholder_map$Tribe_Name))

print(
  obj_sizes(
    mrds_on_tribal_lands,
    mrds_within_35_mi,
    mrds_more_than_35_mi,
    usmin_on_tribal_lands,
    usmin_within_35_mi,
    usmin_more_than_35_mi,
    res_shapes,
    buffer_lands
  )
)

# UI layout ----
ui <- fluidPage(sidebarLayout(
  sidebarPanel(width = 3, selectInput('tribe', 'Tribe', choices = tribe_list)),
  tabsetPanel(
    id = 'page',
    tabPanel(
      'MRDS',
      width = 9,
      div(
        style = "padding: 20px;",
      leafletOutput('mrds_map', height = '80vh'),
        br(),
        h4("Mineral Proximity Summary"),
        div(style = "height:350px; overflow-y:auto;", DTOutput("mrds_mineral_tbl")),
        br(),
        h4("Tribal Stakeholder Mapping"),
        div(style = "height:350px; overflow-y:auto;", DTOutput("mrds_stakeholder_tbl"))
      )
    ),
    tabPanel(
      'USMIN',
      width = 9,
      div(
        style = "padding: 20px;",
        leafletOutput('usmin_map', height = '80vh'),
        br(),
        h4("Mineral Proximity Summary"),
        div(style = "height:350px; overflow-y:auto;", DTOutput("usmin_mineral_tbl")),
        br(),
        h4("Tribal Stakeholder Mapping"),
        div(style = "height:350px; overflow-y:auto;", DTOutput("usmin_stakeholder_tbl"))
      )
    )
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
  
  selected_mrds_res_shapes <- reactive({
    req(input$tribe)
    if (input$tribe == 'All Tribes') {
      mrds_res_shapes
    } else {
      mrds_res_shapes %>%
        filter(NAME == input$tribe)
    }
  })
  
  selected_usmin_res_shapes <- reactive({
    req(input$tribe)
    if (input$tribe == 'All Tribes') {
      usmin_res_shapes
    } else {
      usmin_res_shapes %>%
        filter(NAME == input$tribe)
    }
  })
  
  # mrds_res_layer <- build_mrds_res_layer(res_shapes, mrds_master)
  
  output$mrds_map <- renderLeaflet({
    mrds_map(
      filtered_buffer_lands(),
      filtered_mrds_on_tribal_lands(),
      filtered_mrds_within_35_mi(),
      filtered_mrds_more_than_35_mi(),
      selected_mrds_res_shapes()
    )
  })
  
  output$mrds_mineral_tbl <- renderDT({
    build_mrds_mineral_table(mrds_mineral_summary)
  }, server = FALSE)
  
  output$mrds_stakeholder_tbl <- renderDT({
    build_mrds_stakeholder_table(mrds_stakeholder_map)
  }, server = FALSE)
  
  output$usmin_mineral_tbl <- renderDT({
    build_usmin_mineral_table(usmin_mineral_summary)
  }, server = FALSE)
  
  output$usmin_stakeholder_tbl <- renderDT({
    build_usmin_stakeholder_table(usmin_stakeholder_map)
  }, server = FALSE)
  
  output$usmin_map <- renderLeaflet({
    usmin_map(
      filtered_buffer_lands(),
      filtered_usmin_on_tribal_lands(),
      filtered_usmin_within_35_mi(),
      filtered_usmin_more_than_35_mi(),
      selected_usmin_res_shapes()
    )
  })
}

shinyApp(ui, server)