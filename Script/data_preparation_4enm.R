library(geodata)
library(kuenm2)
library(ENMeval)

# data
sp_data <- read.csv("Results/data_virtual_species.csv")

marea <- vect("Data/vector/accessible_area.gpkg")

variables <- worldclim_global(var = "bio", res = 5, path = "Data")

## variables in M area
mvars <- crop(variables, marea, mask = TRUE)

names(mvars) <- gsub("wc2.1_5m_", "", names(mvars))
names(mvars) 

# preparing data for models using kuenm2
d <- prepare_data(algorithm = "maxnet", occ = sp_data[, c("x", "y")], x = "x",
                  y = "y", raster_variables = mvars[[c(1, 12)]], 
                  n_background = 5000, features = c("l", "lq", "lqp"), 
                  partition_method = "kfolds", 
                  r_multiplier = c(0.1, 0.25, 0.5, 0.75, 1:5))

dk <- d  # k will represent kflods in our next objects

d

d$formula_grid

# blocks ENMeval
## calibration data from the prepared_data object and separate presence and background records
calib_occ <- d$data_xy[d$calibration_data$pr_bg == 1,] #Presences
calib_bg <- d$data_xy[d$calibration_data$pr_bg == 0,] #Background

## apply spatial block partitioning using ENMeval
enmeval_block <- get.block(occs = calib_occ, bg = calib_bg)


# Identify unique spatial blocks
id_blocks <- sort(unique(unlist(enmeval_block)))

# Create a list of test indices for each spatial block
new_part_data <- lapply(id_blocks, function(i) {
  # Indices of occurrence records in group i
  rep_i_presence <- which(enmeval_block$occs.grp == i)
  
  # Indices of background records in group i
  rep_i_bg <- which(enmeval_block$bg.grp == i)
  # To get the right indices, we need to sum the number of records
  rep_i_bg <- rep_i_bg + nrow(sp_data)
  
  # Combine presence and background indices for the test set
  c(rep_i_presence, rep_i_bg)
})

# Assign names to each partition
names(new_part_data) <- paste0("Partition_", id_blocks)

# Inspect the structure of the new partitioned data
str(new_part_data)


# put it back to prepared_data object
d$part_data <- new_part_data

# Update the partitioning method to reflect the new approach
d$partition_method <- "Spatial block (ENMeval)"  # You can use any descriptive name

# Print the updated prepared_data object
print(d)

# Exploring partitions in geography
d_exp <- explore_partition_geo(data = d, raster_variables = mvars[[c(1, 12)]], 
                               show_partitions = T)

x11()
plot(d_exp)
plot(d_exp$Background)
plot(d_exp$Presence)


dk_exp <- explore_partition_geo(data = dk, raster_variables = mvars[[c(1, 12)]], 
                                show_partitions = T)

x11()
plot(dk_exp)
plot(dk_exp$Background)
plot(dk_exp$Presence)


# model calibration
cal <- calibration(data = d, error_considered = 5, remove_concave = FALSE,
                   proc_for_all = TRUE)

calk <- calibration(data = dk, error_considered = 5, remove_concave = FALSE,
                    proc_for_all = TRUE)

View(cal$selected_models)

# response curves for partitions
partition_response_curves(calibration_results = cal, modelID = 19)

partition_response_curves(calibration_results = calk, modelID = 19)

# saving results
saveRDS(d, "Results/prepared_data.RDS")
saveRDS(cal, "Results/calibration_results.RDS")
saveRDS(dk, "Results/prepared_datak.RDS")
saveRDS(calk, "Results/calibration_resultsk.RDS")
writeRaster(d_exp, "Results/prep_data_exploration.tiff")
writeRaster(dk_exp, "Results/prep_data_explorationk.tiff")
