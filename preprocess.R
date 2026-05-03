library(sf)
library(dplyr)

prep_polygons <- function(x, simplify = FALSE, tol = 1500) {
  x <- x |>
    st_make_valid() |>
    st_transform(5070)
  
  if (simplify) {
    x <- st_simplify(x, dTolerance = tol, preserveTopology = TRUE)
  }
  
  x |> st_transform(4326)
}

buffer_lands <- readRDS("data/reservation_shapes/buffer_lands.rds")

buffer_lands_fixed <- buffer_lands %>%
  st_make_valid() %>%
  st_transform(5070) %>%
  st_simplify(dTolerance = 500, preserveTopology = TRUE) %>%
  st_make_valid() %>%
  st_transform(4326)

saveRDS(buffer_lands_fixed,
        "data/reservation_shapes/buffer_lands.rds",
        compress = FALSE)

reservations <- st_read("data/reservation_shapes/TribalLands_fo_ExportFeature.shp",
                        quiet = TRUE)

reservations_fixed <- reservations %>%
  st_make_valid() %>%
  st_transform(5070) %>%
  st_simplify(dTolerance = 500, preserveTopology = TRUE) %>%
  st_make_valid() %>%
  st_transform(4326)

saveRDS(reservations_fixed,
        "data/reservation_shapes/reservations.rds",
        compress = FALSE)


# =========================
# 1. COMMODITY CODE DICTIONARY
# =========================

code_dict <- list(
  'ABR' = 'Abrasive',
  'ABR_C' = 'Abrasive, Corundum',
  'ABR_E' = 'Abrasive, Emery',
  'ABR_G' = 'Abrasive, Garnet',
  'AG' = 'Silver',
  'AG_R' = 'Silver, Refinery',
  'AL' = 'Aluminum',
  'AL_C' = 'Aluminum, Contained Or Metal',
  'AL_CLY' = 'Aluminum, High Alumina Clay',
  'AND' = 'Andalusite',
  'AS' = 'Arsenic',
  'ASB' = 'Asbestos',
  'ASH' = 'Ash',
  'AU' = 'Gold',
  'AU_R' = 'Gold, Refinery',
  'B' = 'Boron-Borates',
  'BA' = 'Barium-Barite',
  'BE' = 'Beryllium',
  'BI' = 'Bismuth',
  'BR' = 'Bromine',
  'CA' = 'Calcium',
  'CD' = 'Cadmium',
  'CEM' = 'Cement Rock',
  'CL' = 'Chlorine',
  'CLY' = 'Clay',
  'CLY_BC' = 'Clay, Ball Clay',
  'CLY_BK' = 'Clay, Brick',
  'CLY_BM' = 'Clay, Bloating Material',
  'CLY_BN' = 'Clay, Bentonite',
  'CLY_C' = 'Clay, Chlorite',
  'CLY_FE' = 'Clay, Fullers Earth',
  'CLY_FR' = 'Clay, Fire (Refractory)',
  'CLY_GL' = 'Clay, Glauconite',
  'CLY_GN' = 'Clay, General',
  'CLY_H' = 'Clay, Hectorite',
  'CLY_K' = 'Clay, Kaolin',
  'CLY_M' = 'Clay, Montmorillonite',
  'CO' = 'Cobalt',
  'CO2' = 'Carbon Dioxide',
  'COA' = 'Coal',
  'COA_A' = 'Coal, Anthracite',
  'COA_B' = 'Coal, Bituminous',
  'COA_L' = 'Coal, Lignite',
  'COA_S' = 'Coal, Subbituminous',
  'CR' = 'Chromium',
  'CR_F' = 'Chromium, Ferrochrome',
  'CS' = 'Cesium',
  'CU' = 'Copper',
  'CU_O' = 'Copper, Oxide',
  'CU_S' = 'Copper, Sulfide',
  'DIT' = 'Diatomite',
  'DOL' = 'Dolomite',
  '_E' = 'Energy',
  'F' = 'Fluorine-Fluorite',
  'FE' = 'Iron',
  'FE_P' = 'Iron, Pig Iron',
  'FE_PYR' = 'Iron, Pyrite',
  'FLD' = 'Feldspar',
  'FLN' = 'Flint',
  'GA' = 'Gallium',
  'GAS' = 'Natural Gas',
  'GE' = 'Germanium',
  'GEM' = 'Gemstone',
  'GRF' = 'Graphite',
  'GYP' = 'Gypsum-Anhydrite',
  'H' = 'Hydrogen',
  'HG' = 'Mercury',
  'IN' = 'Indium',
  'K' = 'Potassium',
  'LI' = 'Lithium',
  'LST' = 'Limestone',
  'MG' = 'Magnesite',
  'MN' = 'Manganese',
  'MO' = 'Molybdenum',
  'N' = 'Nitrogen-Nitrates',
  'NA' = 'Sodium',
  'NB' = 'Niobium',
  'NI' = 'Nickel',
  'OIL' = 'Petroleum (Oil)',
  'P' = 'Phosphorus-Phosphates',
  'PB' = 'Lead',
  'PEA' = 'Peat',
  'REE' = 'Rare Earth Elements',
  'S' = 'Sulfur',
  'SN' = 'Tin',
  'SR' = 'Strontium',
  'TA' = 'Tantalum',
  'TI' = 'Titanium',
  'U' = 'Uranium',
  'V' = 'Vanadium',
  'W' = 'Tungsten',
  'ZN' = 'Zinc',
  'ZR' = 'Zirconium'
)

code_dict_tbl <- tibble(CODE = names(code_dict), Commodity = unname(code_dict))

# =========================
# 2. CREATE CSVS WITH POPUPS
# =========================

res_shapes  <- readRDS('data/reservation_shapes/reservations.rds')
mrds_master <- read_csv('data/MRDS_Analysis/MRDS_Master_Deposits.csv',
                        show_col_types = FALSE) %>%
  mutate(DEP_ID = as.character(DEP_ID))
usmin_master <- read_csv('data/USMIN_Analysis/USMIN_Master_Deposits.csv',
                         show_col_types = FALSE)

build_mrds_res_layer <- function(res_shapes, master) {
  master_long <- master %>%
    filter(!is.na(Tribes_List) & Tribes_List != "") %>%
    separate_rows(Tribes_List, sep = ";") %>%
    mutate(Tribes_List = str_trim(Tribes_List))
  
  mineral_by_tribe <- master_long %>%
    filter(!is.na(CODE_LIST) & CODE_LIST != "") %>%
    separate_rows(CODE_LIST, sep = "\\s+") %>%
    mutate(CODE_LIST = str_trim(CODE_LIST)) %>%
    left_join(code_dict_tbl, by = c("CODE_LIST" = "CODE")) %>%
    filter(!is.na(Commodity), Commodity != "NULL") %>%
    mutate(Commodity = as.character(Commodity)) %>%
    group_by(Tribes_List) %>%
    summarise(Minerals_List = paste(sort(unique(Commodity)), collapse = ", "),
              .groups = "drop")
  
  tribe_summary <- master_long %>%
    group_by(Tribes_List) %>%
    summarise(
      Total_Deposits = n_distinct(SITE_NAME),
      On_Tribal_Land = sum(On_Tribal_Land, na.rm = TRUE),
      Within_35mi = sum(Within_35mi_Buffer, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    left_join(mineral_by_tribe, by = "Tribes_List") %>%
    mutate(
      popup = glue(
        "<div style='font-size:13px'>",
        "<b>Tribe:</b> {Tribes_List}",
        "<hr>",
        "<b>Total Deposits:</b> {Total_Deposits}<br>",
        "<b>On Tribal Land:</b> {On_Tribal_Land}<br>",
        "<b>Within 35 mi:</b> {Within_35mi}<br>",
        "<hr>",
        "<b>Minerals:</b><br>{Minerals_List}<br>",
        "</div>"
      )
    )
  
  res_shapes %>%
    left_join(tribe_summary, by = c("NAME" = "Tribes_List"))
}

mrds_res_layer <- build_mrds_res_layer(res_shapes, mrds_master)

saveRDS(mrds_res_layer,
        "data/reservation_shapes/mrds_reservations.rds",
        compress = FALSE)

# ------------------------------------------------------------------------------

build_usmin_res_layer <- function(res_shapes, master) {
  master_long <- master %>%
    filter(!is.na(Tribes_List) & Tribes_List != "") %>%
    separate_rows(Tribes_List, sep = ";") %>%
    mutate(Tribes_List = str_trim(Tribes_List)) %>%
    distinct(Name, Tribes_List, .keep_all = TRUE)
  
  mineral_by_tribe <- master_long %>%
    filter(!is.na(`Commodity (From popup info)`) &
             `Commodity (From popup info)` != "") %>%
    separate_rows(`Commodity (From popup info)`, sep = ";") %>%
    mutate(`Commodity (From popup info)` = str_to_title(str_trim(`Commodity (From popup info)`))) %>%
    filter(`Commodity (From popup info)` != "") %>%
    group_by(Tribes_List) %>%
    summarise(Minerals_List = paste(sort(unique(
      `Commodity (From popup info)`
    )), collapse = ", "),
    .groups = "drop")
  
  tribe_summary <- master_long %>%
    group_by(Tribes_List) %>%
    summarise(
      Total_Deposits = n_distinct(Name),
      On_Tribal_Land = sum(On_Tribal_Land, na.rm = TRUE),
      Within_35mi = sum(Within_35mi_Buffer, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    left_join(mineral_by_tribe, by = "Tribes_List") %>%
    mutate(
      popup = glue(
        "<div style='font-size:13px'>",
        "<b>Tribe:</b> {Tribes_List}",
        "<hr>",
        "<b>Total Deposits:</b> {Total_Deposits}<br>",
        "<b>On Tribal Land:</b> {On_Tribal_Land}<br>",
        "<b>Within 35 mi:</b> {Within_35mi}<br>",
        "<hr>",
        "<b>Minerals:</b><br>{Minerals_List}<br>",
        "</div>"
      )
    )
  
  res_shapes %>%
    left_join(tribe_summary, by = c("NAME" = "Tribes_List"))
}

usmin_res_layer <- build_usmin_res_layer(res_shapes, usmin_master)

saveRDS(usmin_res_layer,
        "data/reservation_shapes/usmin_reservations.rds",
        compress = FALSE)
