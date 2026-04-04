############################################################
# MRDS Tribal Proximity Analysis
# Fully self-contained, Zenodo-ready script
############################################################

# =========================
# 0. SETUP
# =========================
library(dplyr)
library(tidyr)
library(readr)
library(stringr)
library(tibble)

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

code_dict_tbl <- tibble(
  CODE = names(code_dict),
  Commodity = unname(code_dict)
)

# =========================
# 2. READ INPUT DATA (GIS OUTPUTS)
# =========================

buffer_raw  <- read_csv("MRDS_Within35miBuffer.csv", show_col_types = FALSE)
on_land_raw <- read_csv("MRDS_DirectlyOnTribalLands.csv", show_col_types = FALSE)

# =========================
# 3. RELATIONSHIP TABLE (MANY-TO-MANY)
# =========================

on_land_rel <- on_land_raw %>%
  filter(!is.na(`NAME`) & `NAME` != "") %>%
  transmute(
    DEP_ID,
    Tribe_Name = `NAME`,
    Relationship = "On_Tribal_Land"
  )

buffer_rel <- buffer_raw %>%
  filter(!is.na(NAME) & NAME != "") %>%
  transmute(
    DEP_ID,
    Tribe_Name = NAME,
    Relationship = "Within_35mi_Buffer"
  )

relationships <- bind_rows(on_land_rel, buffer_rel) %>%
  distinct()

# =========================
# 4. MASTER DEPOSIT TABLE (OUTPUT 1)
# =========================

# Build relationship table (many-to-many)
on_land_rel <- on_land_raw %>%
  filter(!is.na(NAME) & NAME != "") %>%
  transmute(
    DEP_ID,
    Tribe_Name = NAME,
    Relationship = "On_Tribal_Land"
  )

buffer_rel <- buffer_raw %>%
  filter(!is.na(NAME) & NAME != "") %>%
  transmute(
    DEP_ID,
    Tribe_Name = NAME,
    Relationship = "Within_35mi_Buffer"
  )

relationships <- bind_rows(on_land_rel, buffer_rel) %>%
  distinct()

# Base deposit table (authoritative list of all deposits)
deposit_base <- buffer_raw %>%
  distinct(DEP_ID, .keep_all = TRUE)

# Aggregate Tribal relationships to deposit level
tribal_summary <- relationships %>%
  group_by(DEP_ID) %>%
  summarise(
    Tribes_List = paste(sort(unique(Tribe_Name)), collapse = "; "),
    Intersecting_Tribe_Count = n_distinct(Tribe_Name),
    On_Tribal_Land = any(Relationship == "On_Tribal_Land"),
    Within_35mi_Buffer = any(Relationship == "Within_35mi_Buffer"),
    .groups = "drop"
  )

# Join and finalize master table
mrds_master <- deposit_base %>%
  left_join(tribal_summary, by = "DEP_ID") %>%
  mutate(
    Tribes_List = replace_na(Tribes_List, ""),
    Intersecting_Tribe_Count = replace_na(Intersecting_Tribe_Count, 0),
    On_Tribal_Land = replace_na(On_Tribal_Land, FALSE),
    Within_35mi_Buffer = replace_na(Within_35mi_Buffer, FALSE),
    
    # Explicit, publication-safe indicators
    Has_Tribal_Proximity =
      ifelse(On_Tribal_Land | Within_35mi_Buffer, 1, 0),
    
    Multi_Tribe_Flag =
      ifelse(Intersecting_Tribe_Count > 1, 1, 0)
  ) %>%
  # Drop single-Tribe artifact columns entirely
  select(-any_of(c("BASENAME", "NAME")))

# Write final master CSV
write_csv(mrds_master, "MRDS_Master_Deposits.csv")

# =========================
# 5. STAKEHOLDER MAPPING (OUTPUT 2)
# =========================

stakeholder_mapping <- relationships %>%
  group_by(Tribe_Name) %>%
  summarise(
    Total_Intersecting_Deposits = n_distinct(DEP_ID),
    .groups = "drop"
  ) %>%
  arrange(desc(Total_Intersecting_Deposits))

write_csv(stakeholder_mapping, "MRDS_Stakeholder_Mapping.csv")

# =========================
# 6. AUTOMATED MINERAL SUMMARY (ALL COMMODITIES)
# =========================

mineral_data <- mrds_master %>%
  separate_rows(CODE_LIST, sep = "\\s+") %>%   # split on spaces
  mutate(
    CODE_LIST = str_trim(CODE_LIST)
  ) %>%
  left_join(code_dict_tbl, by = c("CODE_LIST" = "CODE")) %>%
  mutate(
    Commodity = purrr::map_chr(
      Commodity,
      ~ ifelse(length(.x) == 0, NA_character_, .x)
    )
  ) %>%
  filter(!is.na(Commodity)) %>%
  mutate(
    operation_status = case_when(
      DEV_STAT == "Producer" ~ "In Operation",
      DEV_STAT %in% c("Occurrence", "Prospect") ~ "Proposed Operation",
      TRUE ~ "Unknown"
    )
  )

mineral_summary <- mineral_data %>%
  group_by(Commodity) %>%
  summarise(
    Total_Deposits =
      n_distinct(DEP_ID),
    On_Tribal_Land =
      n_distinct(DEP_ID[On_Tribal_Land]),
    Within_35mi_Buffer =
      n_distinct(DEP_ID[Within_35mi_Buffer]),
    Pct_On_Tribal_Land =
      round(100 * On_Tribal_Land / Total_Deposits, 2),
    Pct_Within_35mi =
      round(100 * Within_35mi_Buffer / Total_Deposits, 2),
    Pct_Any_Proximity =
      round(Pct_On_Tribal_Land + Pct_Within_35mi, 2),
    .groups = "drop"
  ) %>%
  arrange(desc(Total_Deposits))

write_csv(mineral_summary, "MRDS_Mineral_Summary.csv")

# =========================
# 7. USER HELPER: QUERY BY TRIBE
# =========================

# Enter a Tribal Nation name exactly as it appears in Tribes_List.
# Leave as "" to skip this step.
USER_TRIBE <- ""

if (USER_TRIBE != "") {
  
  tribe_output <- mrds_master %>%
    filter(
      str_detect(
        Tribes_List,
        paste0("\\b", USER_TRIBE, "\\b")
      )
    ) %>%
    # Remove single-Tribe artifact columns if present
    select(-any_of(c("NAME", "BASENAME")))
  
  out_name <- paste0(
    "MRDS_Deposits_For_",
    str_replace_all(USER_TRIBE, "[^A-Za-z0-9]", "_"),
    ".csv"
  )
  
  write_csv(tribe_output, out_name)
  
  message(
    "Tribal-specific deposit file written: ",
    out_name
  )
  
} else {
  message(
    "No Tribal Nation specified (USER_TRIBE == \"\"). Skipping tribe-specific export."
  )
}

############################################################
# END SCRIPT
############################################################
