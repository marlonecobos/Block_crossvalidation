# install packages if needed
install.packages("mapedit")

library(mapedit)
library(mapview)
library(sf)
library(terra)

# data
## prediction
prediction <- rast("Results/prediction.tif")

## area of interest
my_polygon <- vect("Data/vector/accessible_area.gpkg")

## mask variables to north america
prediction <- crop(prediction, my_polygon, mask = TRUE)

# interactive Mapview base 
view_base <- mapview(prediction, layer.name = "Suitability") 

# drawing interface
drawn_poly_sf <- editMap(view_base)

## start drawing
## finish polygon
## press Done button

# capture polygon as a SpatVector
new_spatvector <- vect(drawn_poly_sf$finished)

new_spatvector

# project to original CRS if needed
#new_spatvector <- project(new_spatvector, crs(my_polygon))

# crop draw with area of interest
marea <- intersect(new_spatvector, my_polygon)

# verify
plot(prediction)
plot(my_polygon, border = "red", add = TRUE)
plot(new_spatvector, border = "black", lwd = 2, add = TRUE)
plot(marea, border = "blue", lwd = 3, add = TRUE)

# save calibration area
writeVector(marea, "Results/calibration_area_sp_vs1.gpkg")
