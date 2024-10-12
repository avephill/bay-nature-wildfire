library(tidyverse)
library(sf)

# Download fire data
# Got the URL from this link
# https://www.fire.ca.gov/what-we-do/fire-resource-assessment-program/fire-perimeters

# Replace this in the future
download_link <- "https://34c031f8-c9fd-4018-8c5a-4159cdff6b0d-cdn-endpoint.azureedge.net/-/media/calfire-website/what-we-do/fire-resource-assessment-program---frap/gis-data/april-2023/fire23-1gdb.zip'?rev=852b1296fecc483380284f7aad868659"
file_name <- "frap-calfire.zip" # Don't need to change this

# Download and unzip
curl::curl_download(download_link, destfile = file_name)
unzip(file_name)
file.remove(file_name)

# Read in .gdb file
fire_gdb <- list.files() |> str_subset(".gdb")
fires <- st_read(fire_gdb)

# Filter fires
filter_fires <- fires |> 
  rename(geom = Shape) |> 
  filter(GIS_ACRES > 500,
         YEAR_ > 2000,
         st_is_valid(geom))

# Now limit fires to bay area
sfbayarea <- st_read("bay_area.gpkg") |> # Don't worry about where I got this
  st_transform(st_crs(filter_fires))

bayarea_fires <- filter_fires |> 
  st_crop(sfbayarea) |>
  st_intersection(sfbayarea)

write_sf(bayarea_fires, "bayarea_fires.gpkg")
