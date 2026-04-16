map_by_tribe <- function(data, tribe) {
  if (tribe == 'All Tribes') {
    return(data)
  }
  
  data %>%
    filter(NAME == tribe)
}

# build_mrds_res_layer <- function(res_shapes, master) {
#   master_long <- master %>%
#     filter(!is.na(Tribes_List) & Tribes_List != "") %>%
#     separate_rows(Tribes_List, sep = ";") %>%
#     mutate(Tribes_List = str_trim(Tribes_List))
#   
#   tribe_summary <- master_long %>%
#     group_by(Tribes_List) %>%
#     summarise(
#       Total_Deposits = n_distinct(SITE_NAME),
#       On_Tribal_Land = sum(On_Tribal_Land, na.rm = TRUE),
#       Within_35mi = sum(Within_35mi_Buffer, na.rm = TRUE),
#       .groups = "drop"
#     ) %>%
#     mutate(
#       popup = glue(
#         "<div style='font-size:13px'>",
#         "<b>Tribe:</b> {Tribes_List}",
#         "<hr>",
#         "<b>Total Deposits:</b> {Total_Deposits}<br>",
#         "<b>On Tribal Land:</b> {On_Tribal_Land}<br>",
#         "<b>Within 35 mi:</b> {Within_35mi}<br>"
#       )
#     )
#   
#   res_shapes %>%
#     left_join(tribe_summary, by = c("NAME" = "Tribes_List"))
# }

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
      popup = ~popup,
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