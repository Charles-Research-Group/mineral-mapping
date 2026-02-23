minerals_map <- function(buffer_lands, near_tribal_lands, on_tribal_lands) {
  coords_on <- st_coordinates(on_tribal_lands)
  coords_near <- st_coordinates(near_tribal_lands)
  
  leaflet() %>%
    addTiles() %>%
    addPolygons(
      data = buffer_lands,
      color = "darkolivegreen",
      fillColor = "yellowgreen",
      fillOpacity = 0.5,
      weight = 1,
      popup = buffer_lands$NAME
    ) %>%
    addCircleMarkers(
      lng = coords_near[, 1],
      lat = coords_near[, 2],
      popup = near_tribal_lands$SITE_NAME,
      radius = 2.5,
      fillColor = "firebrick",
      fillOpacity = 1,
      stroke = TRUE,
      color = "black",
      weight = 0.5
    ) %>%
    addCircleMarkers(
      lng = coords_on[, 1],
      lat = coords_on[, 2],
      popup = on_tribal_lands$SITE_NAME,
      radius = 2.5,
      fillColor = "yellowgreen",
      fillOpacity = 1,
      stroke = TRUE,
      color = "black",
      weight = 0.5
    ) %>%
    addLegend(
      title = "Legend",
      position = "bottomright",
      colors = c("yellowgreen", "firebrick"),
      labels = c("Directly on tribal lands", "Within 35-mile buffer")
    )
}

tribe_table <- function(data, tribe) {
  if (tribe == "All tribes") return(NULL)
  data %>%
    filter(str_detect(Tribes_List, paste0("\\b", fixed(tribe), "\\b"))) %>%
    select(-any_of(c("NAME", "BASENAME")))
}