# =========================
# USMIN Tribal Proximity Analysis
# =========================

library(dplyr)
library(tidyr)
library(readr)
library(stringr)

# -------------------------
# Load spatial join outputs
# -------------------------

on_land_raw <- read_csv(
  "USMIN_DirectlyOnTribalLands.csv",
  show_col_types = FALSE
)

buffer_raw <- read_csv(
  "USMIN_Within35miBuffer.csv",
  show_col_types = FALSE
)

# -------------------------
# Build relationship tables
# -------------------------

on_land_rel <- on_land_raw %>%
  filter(!is.na(BASENAME) & BASENAME != "") %>%
  transmute(
    TARGET_FID,
    Tribe_Name = BASENAME,
    Relationship = "On_Tribal_Land"
  )

buffer_rel <- buffer_raw %>%
  filter(!is.na(NAME_1) & NAME_1 != "") %>%
  transmute(
    TARGET_FID,
    Tribe_Name = NAME_1,
    Relationship = "Within_35mi_Buffer"
  )

relationships <- bind_rows(on_land_rel, buffer_rel) %>%
  distinct()

# -------------------------
# Base deposit table
# -------------------------

deposit_base <- on_land_raw %>%
  distinct(TARGET_FID, .keep_all = TRUE)

# -------------------------
# Aggregate Tribal info
# -------------------------

tribal_summary <- relationships %>%
  group_by(TARGET_FID) %>%
  summarise(
    Tribes_List = paste(sort(unique(Tribe_Name)), collapse = "; "),
    Intersecting_Tribe_Count = n_distinct(Tribe_Name),
    On_Tribal_Land = any(Relationship == "On_Tribal_Land"),
    Within_35mi_Buffer = any(Relationship == "Within_35mi_Buffer"),
    .groups = "drop"
  )

# -------------------------
# Build master table
# -------------------------

usmin_master <- deposit_base %>%
  left_join(tribal_summary, by = "TARGET_FID") %>%
  mutate(
    Tribes_List = replace_na(Tribes_List, ""),
    Intersecting_Tribe_Count =
      replace_na(Intersecting_Tribe_Count, 0),
    On_Tribal_Land =
      replace_na(On_Tribal_Land, FALSE),
    Within_35mi_Buffer =
      replace_na(Within_35mi_Buffer, FALSE),
    Has_Tribal_Proximity =
      ifelse(On_Tribal_Land | Within_35mi_Buffer, 1, 0),
    Multi_Tribe_Flag =
      ifelse(Intersecting_Tribe_Count > 1, 1, 0)
  ) %>%
  # Remove confusing single-Tribe artifact columns
  select(-matches("^(BASENAME|NAME_1|Base|Base_Name)$"))

write_csv(usmin_master, "USMIN_Master_Deposits.csv")

# =========================
# Stakeholder Mapping
# =========================

usmin_stakeholders <- relationships %>%
  group_by(Tribe_Name) %>%
  summarise(
    Total_Intersecting_Deposits =
      n_distinct(TARGET_FID),
    .groups = "drop"
  ) %>%
  arrange(desc(Total_Intersecting_Deposits))

write_csv(
  usmin_stakeholders,
  "USMIN_Stakeholder_Mapping.csv"
)

# =========================
# Commodity Analysis
# =========================

commodity_col <- "Commodity (From popup info)"

commodity_data <- usmin_master %>%
  filter(
    !is.na(.data[[commodity_col]]) &
      .data[[commodity_col]] != ""
  ) %>%
  separate_rows(
    !!sym(commodity_col),
    sep = ";"
  ) %>%
  mutate(
    Commodity = str_trim(.data[[commodity_col]]),
    # Remove numeric qualifiers like "(1)", "(12)", etc.
    Commodity = str_remove_all(
      Commodity,
      "\\s*\\(.*?\\)"
    )
  ) %>%
  filter(Commodity != "")

usmin_mineral_summary <- commodity_data %>%
  group_by(Commodity) %>%
  summarise(
    Total_Deposits =
      n_distinct(TARGET_FID),
    On_Tribal_Land =
      n_distinct(TARGET_FID[On_Tribal_Land]),
    Within_35mi_Buffer =
      n_distinct(TARGET_FID[Within_35mi_Buffer]),
    Pct_On_Tribal_Land =
      round(100 * On_Tribal_Land / Total_Deposits, 2),
    Pct_Within_35mi =
      round(100 * Within_35mi_Buffer / Total_Deposits, 2),
    .groups = "drop"
  ) %>%
  mutate(
    Pct_Any_Proximity =
      round(
        Pct_On_Tribal_Land + Pct_Within_35mi,
        2
      )
  ) %>%
  arrange(desc(Total_Deposits))

write_csv(
  usmin_mineral_summary,
  "USMIN_Mineral_Summary.csv"
)

# =========================
# USER INPUT (OPTIONAL)
# =========================

# Enter a Tribal Nation name exactly as it appears in Tribes_List.
# Leave as "" to skip this step.
USER_TRIBE <- ""

if (USER_TRIBE != "") {
  
  tribe_output <- usmin_master %>%
    filter(
      str_detect(
        Tribes_List,
        paste0("\\b", USER_TRIBE, "\\b")
      )
    )
  
  out_name <- paste0(
    "USMIN_Deposits_For_",
    str_replace_all(
      USER_TRIBE,
      "[^A-Za-z0-9]",
      "_"
    ),
    ".csv"
  )
  
  write_csv(tribe_output, out_name)
  
  message(
    "Tribal-specific deposit file written: ",
    out_name
  )
  
} else {
  message(
    "No Tribal Nation specified. Skipping tribe-specific export."
  )
}
