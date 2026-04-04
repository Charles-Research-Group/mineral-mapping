===============================================================================
ANALYSIS OF MINERAL DEPOSITS AND PROXIMITY TO TRIBAL LANDS
Supplementary Dataset for USMIN Integration
===============================================================================

DATASET DESCRIPTION
-------------------
This dataset provides a spatial analysis of tribal proximity to mineral-related features documented in the U.S. Geological Survey (USGS) Mineral Deposit Database (USMIN), last updated in 2023. USMIN is a spatially explicit database designed to support mineral resource assessment, land-use planning, and geologic research by representing locations of known mineral deposits, mining districts, mines, prospects, underground workings, and related features across the United States. 

Unlike MRDS, which is primarily deposit-centric, USMIN represents a broader set of mineral-related features, many of which may co-occur at or near the same geographic location. As a result, a single active or historic mining area may be represented by multiple spatial features (e.g., a deposit point, mine shaft, portal, underground workings, or mining district).

This dataset enhances the USMIN database by adding Tribal affiliations by name to each feature and classifying proximity to federally recognized Tribal lands, including direct intersections with Tribal lands and locations within a 35-mile buffer of Tribal land boundaries.

SUMMARY STATISTICS
------------------
- Total Global Deposits: 1,777
- US Deposits (excluding Puerto Rico): 1,763
- Deposits on Tribal Lands: 22 (1.2% of US total)
- Deposits within 35 miles of Tribal Lands: 917 (51.6% of US total)
- Deposits outside Tribal Influence: 838 (47.1% of US total)

OVERVIEW
------------------
This repository contains processed data products and an accompanying R script used to analyze the spatial relationship between U.S. mineral-related features recorded in the USGS USMIN database and federally recognized Tribal lands.

The analysis identifies and summarizes:
- mineral-related features directly intersecting Tribal lands
- mineral-related features located within a 35-mile buffer of Tribal lands
- features associated with one or multiple Tribal Nations.

The resulting datasets are intended to support transparent, reproducible analyses relevant to Tribal Nations, researchers, policymakers, and other stakeholders interested in mineral development patterns and Tribal proximity.

CONTENTS
------------------
- USMIN_Master_Deposits.csv  
A master table with one row per USMIN feature, containing complete Tribal proximity indicators and a list of all Tribal Nations associated with each feature.

- USMIN_Stakeholder_Mapping.csv  
A Tribe-level summary table ranking Tribal Nations by the total number of distinct USMIN features that intersect Tribal lands and/or fall within a 35-mile buffer.

- USMIN_Mineral_Summary.csv  
A commodity-level summary showing the number and percentage of USMIN features associated with Tribal lands and buffer regions.

- USMIN_Analysis.R  
A fully self-contained R script that builds the three summary tables above and includes a user-function to export all feature-level data associated with a specific Tribal Nation of interest.

COLUMN DEFINITIONS
------------------
- USMIN_Master_Deposits.csv  

Directly provided by USMIN / ArcGIS export:
TARGET_FID: Unique feature identifier assigned during spatial processing (merge key for USMIN integration)  
Name: Feature name as provided by USMIN  
Commodity (From popup info): Text field listing commodities associated with the feature (semicolon-delimited)  
Snippet: Feature type classification (e.g., Deposit, Mining District, Underground Workings, Prospect, Portal Mine, Mine Shaft)  
PopupInfo: URL linking to additional USMIN information for the specific feature  

Unique to this analysis:
Tribes_List: Semicolon-delimited list of all Tribal Nations associated with the feature  
Intersecting_Tribe_Count: Number of distinct Tribal Nations associated with the feature  
On_Tribal_Land: TRUE if the feature intersects Tribal land  
Within_35mi_Buffer: TRUE if the feature is within 35 miles of Tribal land  
Has_Tribal_Proximity: 1 if the feature is on Tribal land or within the buffer, 0 otherwise  
Multi_Tribe_Flag: 1 if the feature is associated with more than one Tribe, 0 otherwise  

Interpretation note:
Because USMIN represents mineral-related features rather than unique deposits, multiple rows in this table may correspond to the same mining operation or geographic site.

- USMIN_Stakeholder_Mapping.csv  
Tribe_Name: Tribal Nation name as represented in the Tribal land boundary dataset  
Total_Intersecting_Deposits: Number of distinct USMIN features associated with the Tribe (direct intersection and/or within 35 miles)

Interpretation note:
A single USMIN feature may be associated with multiple Tribal Nations. In such cases, the feature is counted once for each relevant Tribe in this table.

- USMIN_Mineral_Summary.csv  
Commodity: Common name of the mineral or material (parsed from popup metadata)  
Total_Deposits: Number of distinct USMIN features associated with the commodity  
On_Tribal_Land: Features associated with the commodity that intersect Tribal lands  
Within_35mi_Buffer: Features associated with the commodity within 35 miles of Tribal lands  
Pct_On_Tribal_Land: Percentage of features directly on Tribal lands  
Pct_Within_35mi: Percentage of features within 35 miles of Tribal lands  
Pct_Any_Proximity: Sum of the above two percentages  

Interpretation note:
Each row represents a mineral or material category, not a unique mining operation or deposit.

USING THE R SCRIPT
------------------
Requirements  
R (version 4.0 or later recommended)

R packages:
dplyr  
tidyr  
readr  
stringr  
tibble  
purrr  

Steps  
Place the following files in the same folder:
USMIN_Within35miBuffer.csv  
USMIN_DirectlyOnTribalLands.csv  
USMIN_Tribal_Analysis.R  

Open R or RStudio and set the working directory to that location.

Run:
source("USMIN_Tribal_Analysis.R")

The script will generate:
USMIN_Master_Deposits.csv  
USMIN_Stakeholder_Mapping.csv  
USMIN_Mineral_Summary.csv  

Helper function (optional)  
The script includes a helper function in the final section to retrieve all USMIN features associated with a given Tribal Nation.

Example use:
USER_TRIBE <- "Navajo Nation Reservation and Off-Reservation Trust Land"

If left blank:
USER_TRIBE <- ""
No additional output will be generated.

This function searches the Tribes_List field and correctly handles features associated with multiple Tribal Nations.

DATA USE AND INTERPRETATION
------------------
All data used in this repository are derived from publicly available federal sources. All processing steps are documented to support reproducibility and transparency. USMIN statistical summaries should be interpreted with particular care, as the database represents mineral-related features rather than unique deposits; multiple features may correspond to a single mining operation or geographic site.

This dataset has not been formally reviewed or endorsed by any Tribal Nation. It was developed to support Tribal data sovereignty by providing localized, transparent, and reproducible information that Tribal Nations and governing bodies may use, adapt, or reinterpret according to their own priorities, governance processes, and knowledge systems.
