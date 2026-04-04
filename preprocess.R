library(sf)
library(dplyr)

# # Points: just extract coords into a plain data frame, no sf object needed
# on_tribal_lands <- st_read("data/MRDS/mrds_directlyontriballands.geojson", quiet = TRUE)
# coords <- st_coordinates(on_tribal_lands)
# on_tribal_lands %>%
#   st_drop_geometry() %>%
#   mutate(lng = coords[,1], lat = coords[,2]) %>%
#   select(DEP_ID, SITE_NAME, DEV_STAT, CODE_LIST, URL, NAME, lng, lat) %>%
#   saveRDS("data/MRDS/on_tribal_lands.rds")
# 
# # Same for buffer points
# near_tribal_lands <- st_read("data/MRDS/mrds_within35mibuffer.geojson", quiet = TRUE)
# coords <- st_coordinates(near_tribal_lands)
# 
# near_tribal_lands %>%
#   st_drop_geometry() %>%
#   mutate(lng = coords[,1], lat = coords[,2]) %>%
#   filter(!is.na(NAME)) %>%   # keep rows with tribe association
#   select(DEP_ID, SITE_NAME, DEV_STAT, CODE_LIST, URL, NAME, lng, lat) %>%
#   saveRDS("data/MRDS/within_35_mi.rds")
# 
# near_tribal_lands %>%
#   st_drop_geometry() %>%
#   mutate(lng = coords[,1], lat = coords[,2]) %>%
#   filter(is.na(NAME)) %>%   # keep rows with no tribe association
#   select(DEP_ID, SITE_NAME, DEV_STAT, CODE_LIST, URL, lng, lat) %>%
#   saveRDS("data/MRDS/more_than_35_mi.rds")
# 
# on_tribal_lands <- st_read("data/USMIN/on_tribal_lands.geojson", quiet = TRUE) %>%
#   st_transform(4326)
# 
# coords <- st_coordinates(on_tribal_lands)
# 
# on_tribal_lands %>%
#   st_drop_geometry() %>%
#   mutate(
#     lng = coords[,1],
#     lat = coords[,2],
#     NAME = NAME_1
#   ) %>%
#   select(Name, PopupInfo, NAME, lng, lat) %>%
#   saveRDS("data/USMIN/on_tribal_lands.rds")
# 
# near_tribal_lands <- st_read("data/USMIN/within_35_mi.geojson", quiet = TRUE) %>%
#   st_transform(4326)
# 
# coords <- st_coordinates(near_tribal_lands)
# 
# near_tribal_lands %>%
#   st_drop_geometry() %>%
#   mutate(
#     lng = coords[,1],
#     lat = coords[,2],
#     NAME = NAME_1
#   ) %>%
#   select(Name, PopupInfo, NAME, lng, lat) %>%
#   saveRDS("data/USMIN/within_35_mi.rds")
# 
# 
# 
# more_than_35_mi <- st_read("data/USMIN/all_points.geojson", quiet = TRUE) %>%
#   st_transform(4326)
# 
# coords <- st_coordinates(more_than_35_mi)
# 
# more_than_35_mi %>%
#   st_drop_geometry() %>%
#   mutate(
#     lng = coords[,1],
#     lat = coords[,2]
#   ) %>%
#   select(Name, PopupInfo, lng, lat) %>%
#   saveRDS("data/USMIN/more_than_35_mi.rds")

buffer_lands <- st_read("data/buffer_lands.geojson", quiet = TRUE) %>%
  st_transform(4326) %>%
  select(OBJECTID, BASENAME, NAME, BUFF_DIST, geometry)

saveRDS(buffer_lands, "data/buffer_lands.rds")