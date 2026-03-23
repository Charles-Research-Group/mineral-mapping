map_by_tribe <- function(data, tribe) {
  if (tribe == 'All Tribes') {
    return(data)
  }
  
  data %>%
    filter(NAME == tribe)
}

mrds_map <- function(buffer_lands,
                     on_tribal_lands,
                     within_35_mi,
                     more_than_35_mi,
                     res_shapes) {
  leaflet() %>%
    addTiles() %>%
    addPolygons(
      data = res_shapes,
      color = 'black',
      weight = 1,
      fillColor = 'yellowgreen',
      fillOpacity = 1,
      popup = res_shapes$TRIBE_NAME,
      group = 'Tribes'
    ) %>%
    addPolygons(
      data = buffer_lands,
      color = 'darkolivegreen',
      fillColor = 'yellowgreen',
      fillOpacity = 0.5,
      weight = 1,
      popup = buffer_lands$NAME,
      group = 'Tribes'
    ) %>%
    addCircleMarkers(
      lng = within_35_mi$lng,
      lat = within_35_mi$lat,
      popup = within_35_mi$SITE_NAME,
      radius = 2,
      fillColor = 'firebrick',
      fillOpacity = 1,
      stroke = TRUE,
      color = 'black',
      weight = 0.5,
      group = 'Deposit within 35 miles of tribal land'
    ) %>%
    addCircleMarkers(
      lng = more_than_35_mi$lng,
      lat = more_than_35_mi$lat,
      popup = more_than_35_mi$SITE_NAME,
      radius = 2,
      fillColor = 'royalblue',
      fillOpacity = 1,
      stroke = TRUE,
      color = 'black',
      weight = 0.5,
      group = 'Deposit more than 35 miles from tribal land'
    ) %>%
    addCircleMarkers(
      lng = on_tribal_lands$lng,
      lat = on_tribal_lands$lat,
      popup = on_tribal_lands$SITE_NAME,
      radius = 2,
      fillColor = 'yellowgreen',
      fillOpacity = 1,
      stroke = TRUE,
      color = 'black',
      weight = 0.5,
      group = 'Directly on tribal lands'
    ) %>%
    addLegend(
      title = 'Legend',
      position = 'bottomright',
      colors = c('yellowgreen', 'firebrick', 'royalblue'),
      labels = c(
        'Directly on tribal lands',
        'Deposit within 35 miles of tribal land',
        'Deposit more than 35 miles from tribal land'
      )
    ) %>%
    addLayersControl(
      overlayGroups = c(
        'Tribes',
        'Directly on tribal lands',
        'Deposit within 35 miles of tribal land',
        'Deposit more than 35 miles from tribal land'),
      options = layersControlOptions(collapsed = FALSE)
    )
}

usmin_map <- function(buffer_lands,
                      on_tribal_lands,
                      within_35_mi,
                      more_than_35_mi,
                      res_shapes) {
  leaflet() %>%
    addTiles() %>%
    addPolygons(
      data = res_shapes,
      color = 'black',
      weight = 1,
      fillColor = 'yellowgreen',
      fillOpacity = 1,
      popup = res_shapes$TRIBE_NAME,
      group = 'Tribes'
    ) %>%
    addPolygons(
      data = buffer_lands,
      color = 'darkolivegreen',
      fillColor = 'yellowgreen',
      fillOpacity = 0.5,
      weight = 1,
      popup = buffer_lands$NAME,
      group = 'Tribes'
    ) %>%
    addCircleMarkers(
      lng = more_than_35_mi$lng,
      lat = more_than_35_mi$lat,
      popup = more_than_35_mi$PopupInfo,
      radius = 2,
      fillColor = 'royalblue',
      fillOpacity = 1,
      stroke = TRUE,
      color = 'black',
      weight = 0.5,
      group = 'Deposit more than 35 miles from tribal land'
    ) %>%
    addCircleMarkers(
      lng = within_35_mi$lng,
      lat = within_35_mi$lat,
      popup = within_35_mi$PopupInfo,
      radius = 2,
      fillColor = 'firebrick',
      fillOpacity = 1,
      stroke = TRUE,
      color = 'black',
      weight = 0.5,
      group = 'Deposit within 35 miles of tribal land'
    ) %>%
    addCircleMarkers(
      lng = on_tribal_lands$lng,
      lat = on_tribal_lands$lat,
      popup = on_tribal_lands$PopupInfo,
      radius = 2,
      fillColor = 'yellowgreen',
      fillOpacity = 1,
      stroke = TRUE,
      color = 'black',
      weight = 0.5,
      group = 'Directly on tribal lands'
    ) %>%
    addLegend(
      title = 'Legend',
      position = 'bottomright',
      colors = c('yellowgreen', 'firebrick', 'royalblue'),
      labels = c(
        'Directly on tribal lands',
        'Deposit within 35 miles of tribal land',
        'Deposit more than 35 miles from tribal land'
      )
    ) %>%
    addLayersControl(
      overlayGroups = c(
        'Tribes',
        'Directly on tribal lands',
        'Deposit within 35 miles of tribal land',
        'Deposit more than 35 miles from tribal land'),
      options = layersControlOptions(collapsed = FALSE)
    )
}