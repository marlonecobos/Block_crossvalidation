# install packages if needed
install.packages("mapedit")

library(mapedit)
library(mapview)
#library(sf)
library(terra)

# data
## prediction
prediction <- rast("Results/prediction.tif")  # prediction to North America

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

plot(new_spatvector)

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
writeVector(marea, "Results/calibration_area_sm_vs1.gpkg", overwrite = TRUE)


# Sampling occurrence records from prediction masked to M
## mask prediction to M
pred_m <- crop(prediction, marea, mask = TRUE)

plot(pred_m)

## prediction masked to data frame
pred_df <- as.data.frame(pred_m, xy = TRUE)

## sampling points
sp_rec <- sample(seq_len(nrow(pred_df)), size = 200, replace = FALSE, 
                 prob = pred_df$suitability_trunc)

occ <- pred_df[sp_rec, 1:2]

## visualize points 
plot(pred_m)
points(occ, col = "red")

## save occurrence points
write.csv(occ, "Results/occurrence_records_sm_vs1.csv", row.names = FALSE)
