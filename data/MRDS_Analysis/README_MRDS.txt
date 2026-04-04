===============================================================================
ANALYSIS OF MINERAL DEPOSITS AND PROXIMITY TO TRIBAL LANDS
Supplementary Dataset for MRDS Integration
===============================================================================

DATASET DESCRIPTION
-------------------
This dataset provides a spatial analysis of tribal proximity to mineral deposits documented in the USGS Mineral Resources Data System (MRDS), last updated in 2011. It identifies deposits located on or near U.S. federally recognized Tribal lands, including those within a 35-mile buffer zone of Tribal land boundaries.

The dataset enhances the MRDS database by adding Tribal affiliations by name to each deposit and proximity classifications (within Tribal lands or within the buffer zone) for policy analysis and resource management.

SUMMARY STATISTICS
------------------
- Total Global Deposits: 32,892
- US Deposits (excluding Puerto Rico): 25,959
- Deposits on Tribal Lands: 832 (3.2% of US total)
- Deposits within 35 miles of Tribal Lands: 13,672 (52.5% of US total)
- Deposits outside Tribal Influence: 11,455 (44.3% of US total)
- Cross-border Buffer Deposits (Canada/Mexico): 16


OVERVIEW
------------------
This repository contains processed data products and an accompanying R script used to analyze the spatial relationship between U.S. mineral deposits recorded in the USGS MRDS and federally-recognized Tribal lands.

The analysis identifies and summarizes:
- mineral deposits directly intersecting Tribal lands
- mineral deposits located within a 35-mile buffer of Tribal lands
- deposits associated with one or multiple Tribal Nations.

The resulting datasets are intended to support transparent, reproducible analyses relevant to Tribal Nations, researchers, policymakers, and other stakeholders interested in mineral development patterns and Tribal proximity.

CONTENTS
------------------
- MRDS_Master_Deposits.csv
A master table with one row per mineral deposit, containing complete Tribal proximity indicators and a list of all Tribal Nations associated with each deposit.

- MRDS_Stakeholder_Mapping.csv
A Tribe-level summary table ranking Tribal Nations by the total number of distinct mineral deposits that intersect Tribal lands and/or fall within a 35-mile buffer.

- MRDS_Mineral_Summary.csv
A commodity-level summary showing the number and percentage of mineral deposits associated with Tribal lands and buffer regions.

- MRDS_Tribal_Analysis.R
A fully self-contained R script that: builds the three summary tables above and also includes a user-function to pull all the deposit data for a specific Tribe of interest.

COLUMN DEFINITIONS
------------------
- MRDS_Master_Deposits.csv
Directly provided by MRDS: 
DEP_ID: Unique deposit identifier (merge key for MRDS integration)
SITE_NAME: Mineral deposit site name
DEV_STAT: Development status (Occurrence, Prospect, Producer as defined by MRDS)
URL: Link to detailed deposit information
CODE_LIST: Mineral commodity codes
GRADE: Data quality classificationMRDS_Master_Deposits.csv — column descriptions

Unique to our analysis:
Tribes_List: Semicolon-delimited list of all Tribal Nations associated with the deposit
Intersecting_Tribe_Count: Number of distinct Tribal Nations associated with the deposit
On_Tribal_Land: TRUE if the deposit intersects Tribal land
Within_35mi_Buffer: TRUE if the deposit is within 35 miles of Tribal land
Has_Tribal_Proximity: 1 if the deposit is on Tribal land or within the buffer, 0 otherwise
Multi_Tribe_Flag: 1 if the deposit is associated with more than one Tribe, 0 otherwise


- MRDS_Stakeholder_Mapping.csv 
Tribe_Name: Tribal Nation name as represented in the Tribal land boundary dataset
Total_Intersecting_Deposits: Number of distinct deposits associated with the Tribe (direct intersection and/or within 35 miles)

Interpretation note:
A single deposit may be associated with multiple Tribal Nations. In such cases, the deposit is counted once for each relevant Tribe in this table.

- MRDS_Mineral_Summary.csv
Commodity: Common name of the mineral or material
Total_Deposits: Number of distinct deposits containing this commodity
On_Tribal_Land: Deposits containing this commodity that intersect Tribal lands
Within_35mi_Buffer: Deposits containing this commodity within 35 miles of Tribal lands
Pct_On_Tribal_Land: Percentage of deposits directly on Tribal lands
Pct_Within_35mi: Percentage of deposits within 35 miles of Tribal lands
Pct_Any_Proximity: Sum of the above two percentages

Interpretation note:
Each row represents a mineral or material (commodity), not an individual deposit.

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
MRDS_Within35miBuffer.csv
MRDS_DirectlyOnTribalLands.csv
MRDS_Tribal_Analysis.R

Open R or RStudio and set the working directory to that location.

Run: source("MRDS_Tribal_Analysis.R")

The script will generate:
MRDS_Master_Deposits.csv
MRDS_Stakeholder_Mapping.csv
MRDS_Mineral_Summary.csv

Helper function (optional)
The script includes a helper function in the last section (7.) to retrieve all deposits associated with a given Tribal Nation:
Example use: 
USER_TRIBE <- "Navajo Nation Reservation and Off-Reservation Trust Land"

If it is left blank: USER_TRIBE <- ""
Nothing will happen. This function searches the Tribes_List field and correctly handles deposits associated with multiple Tribes.

DATA USE AND INTERPRETATION
------------------
All data used in this repository are derived from publicly available federal sources. All processing steps are documented to support reproducibility and transparency.

This dataset has not been formally reviewed or endorsed by any Tribal Nation. It was developed to support Tribal data sovereignty by providing localized, transparent, and reproducible information that Tribal Nations and governing bodies may use, adapt, or reinterpret according to their own priorities, governance processes, and knowledge systems.