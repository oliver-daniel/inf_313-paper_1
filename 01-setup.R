#### Preamble ####
# Purpose: Fetch, clean, and augment Open Data Toronto city tree data.
# Author: Oliver Daniel
# Date: 2022-02-06
# Contact: via Quercus or email
# License: WTFPL
# Prerequisites:
#  - install tidyverse

#### Workplace setup & compile-time constants ####
library(tidyverse)
library(dplyr)
library(stringr)

DATA_URL <- "https://ckan0.cf.opendata.inter.prod-toronto.ca/download_resource/80e3b9b6-6c1a-49b3-a44b-a129683419ae"
DATA_PATH <- "data/raw_data.csv"

# Ad-hoc list of suffixes to remove
# from streets, leaving only desired
# suffixes (AVE, RD, ST, etc.)
SUFFIXES_TO_REMOVE <- c(
  "E", "W", "N", "S",        # directional
  "TORONTO", "TO",           # geographical
  "ETOBICOKE", "ET",
  "NORTH YORK", "NY",
  "EAST YORK", "EY",
  "SCARBOROUGH",
  "YORK", "YK"
)

# regex encompassing undesired suffixes
SUFFIX_PATTERN <- paste0(" (", paste(SUFFIXES_TO_REMOVE, collapse = "|"), ")$")

# Toronto geographical data:
# lookup to convert electoral wards
# to Community Council Areas (districts)
DISTRICTS <- 1:25

DISTRICTS[c(1, 2, 3, 5, 7)] <- "Etobicoke York"
DISTRICTS[c(6, 8, 15, 16, 17, 18)] <- "North York"
DISTRICTS[c(4, 9, 10, 11, 12, 13, 14, 19)] <- "Toronto East York"
DISTRICTS[c(20:25)] <- "Scarborough"

#### Data fetching ####

# Check if a cached version of the (very large)
# data file exists. If so, use that instead.
if (!file.exists(DATA_PATH)) {
  print("File not found. Fetching...")
  raw_data <- read_csv(DATA_URL)
  write.csv(raw_data, DATA_PATH)
} else {
  print("File found! Reading from file...")
  raw_data <- read.csv(DATA_PATH)
}

#### Data massaging ####

# get all text before a comma
stripCommas <- function(x) {
  str_split(x, ',') |>
    map(1) |>
    unlist(FALSE, FALSE)
}

data <- raw_data |>
  select(                                  # keep track of desired columns
    STREETNAME,              
    WARD,              
    COMMON_NAME,              
    DBH_TRUNK,              
    geometry              
  ) |>              
  drop_na() |>                             # remove any NA 
  mutate(              
    street_name = gsub(                    # remove any part
      SUFFIX_PATTERN, "",                  # of the street name that
      stripCommas(STREETNAME)              # comes after a comma or undesirable suffix
    ),
    
    street_suffix = word(street_name, -1), # street suffix
    
    district = DISTRICTS[WARD],            # Community Council Area lookup
    
    geometry = geometry |>                 # Geometry data is in a JSON form we can't use. so,
      str_extract_all("\\d+\\.\\d+") |>    # parse out the numerical values,
      map(as.numeric) |>                   # map them to floats,
      map(~ setNames(., c('longitude', 'latitude'))) |>
      bind_rows(),                         # and turn it into a temporary sub-dataframe
    
    longitude = geometry$longitude,        # which we can then use to set
    latitude =  geometry$latitude,         # the actual coordinate data we need.
    
    tree_family = COMMON_NAME |>           # pull out tree family (i.e.,
      stripCommas()                        # species name leading up to comma)
  ) |>
  select(-WARD, -STREETNAME, -geometry)    # Last, throw out the columns we only used for computing


#### Other tables ####
tree_stats <- data |>                      # statistics about tree species
  with_groups(tree_family, mutate,
              subspecies = COMMON_NAME |> unique() |> list(),
              n_subspecies = subspecies[[1]] |> length(),
              mean_diameter = mean(DBH_TRUNK),
              n_occurrences = n(),
  ) |>
  select(tree_family, subspecies, n_subspecies, mean_diameter, n_occurrences) |>
  distinct()


                         