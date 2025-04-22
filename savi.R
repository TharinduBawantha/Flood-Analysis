# Load the necessary libraries
library(sf)
library(terra)
library(raster)
library(ggplot2)
library(RColorBrewer)
library(classInt)

# load the raster data
red <- rast("Band 4.tif")
nir <- rast("Band 5.tif")

# Calculate SAVI
savi <- 1.5 * (nir - red) / (nir + red + 0.5)

# Load the Rathnapura district shapefile
rathnapura <- st_read("rathnapura district.shp")  # Replace with the path to your shapefile

# Ensure the DEM and shapefile have the same CRS
rathnapura <- st_transform(rathnapura, crs = crs(savi))

# Clip the DEM to the Rathnapura district boundary
savi_rathnapura <- mask(crop(savi, rathnapura), rathnapura)

# Save the clipped DEM as a TIFF file
writeRaster(savi_rathnapura, "savi_rathnapura.tif", overwrite = TRUE)

# Convert the clipped SAVI raster to a data frame for ggplot2
raster_df_clipped <- as.data.frame(savi_rathnapura, xy = TRUE)
colnames(raster_df_clipped) <- c("longitude", "latitude", "savi_value")

# Define intervals and colors for SAVI
num_intervals <- 5  # Number of intervals
interval_breaks <- seq(min(raster_df_clipped$savi_value, na.rm = TRUE), 
                       max(raster_df_clipped$savi_value, na.rm = TRUE), 
                       length.out = num_intervals + 1)
interval_labels <- paste(round(interval_breaks[-length(interval_breaks)], 2), 
                         round(interval_breaks[-1], 2), sep = " - ")

# Assign intervals to the SAVI values
raster_df_clipped$interval <- cut(raster_df_clipped$savi_value, breaks = interval_breaks, labels = interval_labels)

# Remove rows with NA values in the interval column
raster_df_clipped <- raster_df_clipped[!is.na(raster_df_clipped$interval), ]

# Define a color palette using RColorBrewer
color_palette <- brewer.pal(num_intervals, "YlGn")  # Use "YlGn" palette for SAVI intervals

# Plot the SAVI map using ggplot2
ggplot() +
  geom_raster(data = raster_df_clipped, aes(x = longitude, y = latitude, fill = interval)) +
  geom_sf(data = rathnapura, fill = NA, color = "black", size = 0.5) +  # Add Rathnapura boundary
  scale_fill_manual(values = color_palette, name = "SAVI", labels = interval_labels, na.value = NA) +  # Color scale for SAVI
  coord_sf(expand = FALSE) +  # Prevent map expansion
  theme_minimal() +
  labs(title = "Soil Adjusted Vegetation Index (SAVI) Rathnapura District") +
  theme(
    panel.grid.major = element_line(color = "grey", size = 0.4),  # Grid lines
    panel.grid.minor = element_blank(),  # Remove minor grid lines
    axis.text.x = element_text(size = 8, angle = 0),  # X-axis labels
    axis.text.y = element_text(size = 8),  # Y-axis labels
    axis.title.x = element_blank(),  # Remove X-axis title
    axis.title.y = element_blank(),  # Remove Y-axis title
    legend.position = "right"  # Place legend on the right
  )

