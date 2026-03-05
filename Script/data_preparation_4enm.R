library(geodata)
library(kuenm2)
library(ENMeval)

# set working directory
#setwd("YOUR/DIRECTORY")

# data
## occurrence records from virtual niche
sp_data <- read.csv("Results/data_virtual_species.csv")

## area for model calibration
marea <- vect("Data/vector/accessible_area.gpkg")

## bioclimatic variables
variables <- worldclim_global(var = "bio", res = 5, path = "Data")

## variables in M area
mvars <- crop(variables, marea, mask = TRUE)

names(mvars) <- gsub("wc2.1_5m_", "", names(mvars))
names(mvars) 


# preparing data for models using kuenm2
d <- prepare_data(algorithm = "maxnet", occ = sp_data[, c("x", "y")], x = "x",
                  y = "y", raster_variables = mvars[[c(1, 12)]], 
                  n_background = 5000,  # make sure 5000 does not exceed the number of pixels in the calibration area
                  features = c("l", "lq", "lqp"),  
                  partition_method = "kfolds", n_partitions = 4,
                  r_multiplier = c(0.1, 0.25, 0.5, 0.75, 1:5))

dk <- d  # k will represent kflods in our next objects

dk


# ENMeval blocks
## Separate presence and background records
calib_occ <- d$data_xy[d$calibration_data$pr_bg == 1, ]  # Presences
calib_bg <- d$data_xy[d$calibration_data$pr_bg == 0, ]  # Background

## Apply spatial block partitioning using ENMeval
enmeval_block <- get.block(occs = calib_occ, bg = calib_bg)

## Identify unique spatial blocks
id_blocks <- sort(unique(unlist(enmeval_block)))

## Create a list of test indices for each spatial block
new_part_data <- lapply(id_blocks, function(i) {
  ### Indices of occurrence records in group i
  rep_i_presence <- which(enmeval_block$occs.grp == i)
  
  ### Indices of background records in group i
  rep_i_bg <- which(enmeval_block$bg.grp == i)
  
  ### To get the right indices for background, 
  ### we need to sum the total number of records to background indices
  rep_i_bg <- rep_i_bg + nrow(sp_data)
  
  ### Combine presence and background indices for the test set
  c(rep_i_presence, rep_i_bg)
})

## Assign names to each partition
names(new_part_data) <- paste0("Partition_", id_blocks)

## Replace the original partition data with the new spatial blocks
d_block <- d
d_block$part_data <- new_part_data

## Update the partitioning method to reflect the new approach
d_block$partition_method <- "Blocks (ENMeval)"  # You can use any descriptive name


# ENMeval checkerboard
## Apply checkerboard partitioning using ENMeval
enmeval_check <- get.checkerboard(occs = calib_occ, envs = mvars[[c(1, 12)]], 
                                  bg = calib_bg, aggregation.factor = c(4, 8))

## Identify unique spatial blocks
id_checks <- sort(unique(unlist(enmeval_check)))

## Create a list of test indices for each spatial block
new_part_check <- lapply(id_checks, function(i) {
  ### Indices of occurrence records in group i
  rep_i_presence <- which(enmeval_check$occs.grp == i)
  
  ### Indices of background records in group i
  rep_i_bg <- which(enmeval_check$bg.grp == i)
  
  ### To get the right indices for background, 
  ### we need to sum the total number of records to background indices
  rep_i_bg <- rep_i_bg + nrow(sp_data)
  
  ### Combine presence and background indices for the test set
  c(rep_i_presence, rep_i_bg)
})

## Assign names to each partition
names(new_part_check) <- paste0("Partition_", id_blocks)

## Replace the original partition data with the new spatial blocks
d_check <- d
d_check$part_data <- new_part_check

## Update the partitioning method to reflect the new approach
d_check$partition_method <- "Checkerboard (ENMeval)"  # You can use any descriptive name
