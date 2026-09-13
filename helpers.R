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
      popup = ~popup,
      group = 'Tribes'
    ) %>%
    addPolygons(
      data = buffer_lands,
      color = 'darkolivegreen',
      fillColor = 'yellowgreen',
      fillOpacity = 0.5,
      weight = 1,
      group = 'Tribes'
    ) %>%
    addCircleMarkers(
      lng = within_35_mi$lng,
      lat = within_35_mi$lat,
      popup = within_35_mi$SITE_NAME,
      radius = 3,
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
      radius = 3,
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
      radius = 3,
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
      popup = ~popup,
      group = 'Tribes'
    ) %>%
    addPolygons(
      data = buffer_lands,
      color = 'darkolivegreen',
      fillColor = 'yellowgreen',
      fillOpacity = 0.5,
      weight = 1,
      group = 'Tribes'
    ) %>%
    addCircleMarkers(
      lng = more_than_35_mi$lng,
      lat = more_than_35_mi$lat,
      popup = more_than_35_mi$PopupInfo,
      radius = 3,
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
      radius = 3,
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
      radius = 3,
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

build_mrds_mineral_table <- function(mineral_summary) {
  mineral_summary %>%
    rename(
      "Commodity"       = Commodity,
      "Total Deposits"  = Total_Deposits,
      "On Tribal Land"  = On_Tribal_Land,
      "Within 35mi"     = Within_35mi_Buffer,
      "% On Land"       = Pct_On_Tribal_Land,
      "% Within 35mi"   = Pct_Within_35mi,
      "% Any Proximity" = Pct_Any_Proximity
    ) %>%
    datatable(
      rownames = FALSE,
      options  = list(
        dom        = "ft",
        pageLength = -1,
        scrollX    = TRUE,
        ordering   = TRUE
      )
    ) %>%
    formatStyle(
      "% Any Proximity",
      background         = styleColorBar(c(0, 100), "#a8d08d"),
      backgroundSize     = "100% 90%",
      backgroundRepeat   = "no-repeat",
      backgroundPosition = "center"
    )
}

build_mrds_stakeholder_table <- function(stakeholder_map) {
  stakeholder_map %>%
    rename(
      "Tribe"                 = Tribe_Name,
      "Intersecting Deposits" = Total_Intersecting_Deposits
    ) %>%
    datatable(
      rownames = FALSE,
      options  = list(
        dom        = "ft",
        pageLength = -1,
        scrollX    = TRUE,
        ordering   = TRUE
      )
    ) %>%
    formatStyle(
      "Intersecting Deposits",
      background         = styleColorBar(range(stakeholder_map$Total_Intersecting_Deposits), "#7cb5d4"),
      backgroundSize     = "100% 90%",
      backgroundRepeat   = "no-repeat",
      backgroundPosition = "center"
    )
}

build_usmin_mineral_table <- function(mineral_summary) {
  mineral_summary %>%
    mutate(Commodity = str_to_title(Commodity)) %>%
    rename(
      "Commodity"       = Commodity,
      "Total Deposits"  = Total_Deposits,
      "On Tribal Land"  = On_Tribal_Land,
      "Within 35mi"     = Within_35mi_Buffer,
      "% On Land"       = Pct_On_Tribal_Land,
      "% Within 35mi"   = Pct_Within_35mi,
      "% Any Proximity" = Pct_Any_Proximity
    ) %>%
    datatable(
      rownames = FALSE,
      options  = list(
        dom        = "ft",
        pageLength = -1,
        scrollX    = TRUE,
        ordering   = TRUE
      )
    ) %>%
    formatStyle(
      "% Any Proximity",
      background         = styleColorBar(c(0, 100), "#a8d08d"),
      backgroundSize     = "100% 90%",
      backgroundRepeat   = "no-repeat",
      backgroundPosition = "center"
    )
}

build_usmin_stakeholder_table <- function(stakeholder_map) {
  stakeholder_map %>%
    rename(
      "Tribe"                 = Tribe_Name,
      "Intersecting Deposits" = Total_Intersecting_Deposits
    ) %>%
    datatable(
      rownames = FALSE,
      options  = list(
        dom        = "ft",
        pageLength = -1,
        scrollX    = TRUE,
        ordering   = TRUE
      )
    ) %>%
    formatStyle(
      "Intersecting Deposits",
      background         = styleColorBar(range(stakeholder_map$Total_Intersecting_Deposits), "#7cb5d4"),
      backgroundSize     = "100% 90%",
      backgroundRepeat   = "no-repeat",
      backgroundPosition = "center"
    )
}