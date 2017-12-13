# Setup
setwd("C:/Users/PyroGeo/Refugia/Synthesis/")
library(rgeos)
library(rgdal)
library(raster)

# Make template
template.unclipped <- raster("1km_template.tif")
studyarea <- readOGR("study_area3_NAD83z11_area.shp")
studyarea <- spTransform(studyarea, proj4string(template.unclipped))
template <- mask(template.unclipped, studyarea)

# Create unburned islands raster
fireperim <- readOGR("mtbs_perims_1984_2014_clp_utm_farea.shp")
ui <- readOGR("unburned_areas_database/unburned_areas_gt1pixel_clp.shp")
fires <- fireperim@data$Fire_ID
fires <- unique(as.character(fires))

# Delete when complete
#####################################
fireperim.full <- fireperim
ui.full <- ui
fireperim <- fireperim[1:10,]
fires <- fireperim@data$Fire_ID
fires <- unique(as.character(fires))
ui <- ui[ui@data$fire_id %in% fires,]
#####################################

# Make blank study area template
landsat <- raster("LE07_L1TP_042028_20171201_20171201_01_RT_B7.tif") #landsat image for reference
values(landsat) = NA
studyarea.proj <- spTransform(studyarea, proj4string(fireperim))
blank.1 <- projectRaster(landsat, crs = proj4string(fireperim))
blank <- extend(blank.1, extent(studyarea.proj), value = NA)
writeRaster(blank, "blank", 'GTiff')

# Build function: 
name <- fires[1]
UiToRaster <- function(name) {
  ui.poly <- ui[ui@data$fire_id == name,]
  perim.poly <- fireperim[fireperim@data$Fire_ID == name,]
  perim.raster <- crop(blank, perim.poly)
  perim.raster1 <- rasterize(perim.poly, perim.raster, field = 0)
  ui.raster <- rasterize(ui.poly, perim.raster, field = 1)
  ui.raster1 <- perim.raster1 + ui.raster
  r <- stack(perim.raster1, ui.raster)
  r2 <- sum(r)

  } 
plot(r2)
writeRaster(ui.raster, "ui_raster", "GTiff")

# Clip template
template <- mask(template.unclipped, studyarea)
