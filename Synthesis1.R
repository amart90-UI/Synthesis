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

# Delete when done testing
#####################################
fireperim.full <- fireperim
ui.full <- ui
fireperim <- fireperim[1:10,]
fires <- fireperim@data$Fire_ID
fires <- unique(as.character(fires))
ui <- ui[ui@data$fire_id %in% fires,]
#####################################  End deletion

# Make blank study area template (aligned to Landsat 7)
landsat <- raster("LE07_L1TP_042028_20171201_20171201_01_RT_B7.tif") #landsat image for reference
values(landsat) = NA
studyarea.proj <- spTransform(studyarea, proj4string(fireperim))
blank.1 <- projectRaster(landsat, crs = proj4string(fireperim))
blank <- extend(blank.1, extent(studyarea.proj), value = NA)

# Create 30m x 30m ui raster
perims.raster <- rasterize(fireperim, blank, field = 0, background = NA)
uis.raster <-  rasterize(ui, perims.raster, field = 1, background = NA, update = T)
 #writeRaster(uis.raster, "ui_raster_test2", 'GTiff')

# Calculate proportional cover for 1 km pixels
prop <- extract(template, uis.raster, fun = mean, na.rm = T)


