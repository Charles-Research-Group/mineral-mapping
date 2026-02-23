library(shiny)
library(leaflet)
library(sf)

source('helpers.R')

# Load data ----
on_tribal_lands <- st_read("data/MRDS/mrds_directlyontriballands.geojson", quiet = TRUE)
near_tribal_lands <- st_read("data/MRDS/mrds_within35mibuffer.geojson", quiet = TRUE)
buffer_lands <- st_read("data/MRDS/buffer_lands_only.geojson", quiet = TRUE) %>%
  st_make_valid() %>%
  st_transform(4326) %>%
  st_simplify(dTolerance = 0.01)

mrds_master <- read_csv("data/MRDS-Analysis/MRDS_Master_Deposits.csv", show_col_types = FALSE) %>%
  mutate(DEP_ID = as.character(DEP_ID))
stakeholder_map <- read_csv("data/MRDS-Analysis/MRDS_Stakeholder_Mapping.csv", show_col_types = FALSE)

tribe_list <- c("All tribes", sort(stakeholder_map$Tribe_Name))

# UI layout ----
ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      width = 3,
      selectInput("tribe", "Tribe", choices = tribe_list)
    ),
    mainPanel(
      width = 9,
      leafletOutput("map", height = "40vh"),
      tableOutput("tribe_table")
    )
  )
)

# Define server logic ----
server <- function(input, output) {
  output$map <- renderLeaflet({
    minerals_map(buffer_lands, near_tribal_lands, on_tribal_lands)
  })
  
  output$tribe_table <- renderTable({
    tribe_table(mrds_master, input$tribe)
  })
}

shinyApp(ui, server)