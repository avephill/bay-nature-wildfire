# Load necessary libraries
library(shiny)
library(leaflet)
library(sf)

# Define UI
ui <- fluidPage(
  titlePanel("Recent Fires in the San Francisco Bay Area"),
  leafletOutput("map", height = "100vh") # height is 100 view height
)

# Define Server
server <- function(input, output, session) {
  # Read the GeoPackage file
  fires <- st_read("bayarea_fires.gpkg", quiet = TRUE)
  
  # Ensure the coordinate reference system is WGS84 for Leaflet
  fires <- st_transform(fires, crs = 4326)
  
  # Render the Leaflet map
  output$map <- renderLeaflet({
    leaflet(fires) %>%
      addTiles() %>%
      addPolygons(
        fillColor = "orange",
        weight = 1,
        opacity = 1,
        color = "red",
        fillOpacity = 0.5,
        popup = ~paste(
          "<strong>Fire Name:</strong>", FIRE_NAME, "<br>",
          "<strong>Date:</strong>", YEAR_, "<br>",
          "<strong>Area Burned:</strong>", GIS_ACRES, "acres"
        )
      )
  })
}

# Run the application
shinyApp(ui = ui, server = server)
