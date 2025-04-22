# Load the necessary libraries
library(sf)
library(terra)
library(raster)
library(ggplot2)
library(viridis)
library(classInt)

# Load the raster bands
red <- rast("Band 4.tif")  # Red band
nir <- rast("Band 5.tif")  # Near-Infrared (NIR) band
swir <- rast("Band 6.tif")

# Calculate NDVI
ndvi <- (nir - red) / (nir + red)

# calculate NDBI
ndbi <- (swir - nir)/(swir + nir)

#calculate bu
bu <- ndbi - ndvi

# Load the Rathnapura district shapefile
rathnapura <- st_read("rathnapura district.shp")  # Replace with the path to your shapefile

# Ensure the NDVI raster and shapefile have the same CRS
rathnapura <- st_transform(rathnapura, crs = crs(bu))

# Clip the NDVI raster to the Rathnapura district boundary
bu_rathnapura <- mask(crop(bu, rathnapura), rathnapura)

# Save the clipped NDVI raster as a TIFF file
writeRaster(bu_rathnapura, "bu_rathnapura.tif", overwrite = TRUE)



# Convert the clipped BU Index raster to a data frame for ggplot2
raster_df_clipped <- as.data.frame(bu_rathnapura, xy = TRUE)
colnames(raster_df_clipped) <- c("longitude", "latitude", "bu_value")

# Define intervals and colors for BU Index
num_intervals <- 5  # Number of intervals
interval_breaks <- seq(min(raster_df_clipped$bu_value, na.rm = TRUE), 
                       max(raster_df_clipped$bu_value, na.rm = TRUE), 
                       length.out = num_intervals + 1)
interval_labels <- paste(round(interval_breaks[-length(interval_breaks)], 2), 
                         round(interval_breaks[-1], 2), sep = " - ")

# Assign intervals to the BU Index values
raster_df_clipped$interval <- cut(raster_df_clipped$bu_value, breaks = interval_breaks, labels = interval_labels)

# Remove rows with NA values in the interval column
raster_df_clipped <- raster_df_clipped[!is.na(raster_df_clipped$interval), ]

# Define a color palette
color_palette <- rev(brewer.pal(num_intervals, "YlOrRd"))

color_palette <- brewer.pal(num_intervals, "PRGn")

# Plot the BU Index map using ggplot2
ggplot() +
  geom_raster(data = raster_df_clipped, aes(x = longitude, y = latitude, fill = interval)) +
  geom_sf(data = rathnapura, fill = NA, color = "black", size = 0.5) +  # Add Rathnapura boundary
  scale_fill_manual(values = color_palette, name = "BU Index", labels = interval_labels, na.value = NA) +  # Color scale for BU Index
  coord_sf(expand = FALSE) +  # Prevent map expansion
  theme_minimal() +
  labs(title = "Built-up Index (BU) Rathnapura District") +
  theme(
    panel.grid.major = element_line(color = "grey", size = 0.4),  # Grid lines
    panel.grid.minor = element_blank(),  # Remove minor grid lines
    axis.text.x = element_text(size = 8, angle = 0),  # X-axis labels
    axis.text.y = element_text(size = 8),  # Y-axis labels
    axis.title.x = element_blank(),  # Remove X-axis title
    axis.title.y = element_blank(),  # Remove Y-axis title
    legend.position = "right"  # Place legend on the right
  )