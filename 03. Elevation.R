# Load necessary libraries
library(tidyverse)
library(raster)
library(sf)
library(ggplot2)
library(RColorBrewer)  # For RColorBrewer color scales

# Load the DEM file
dem <- raster("DEM.tif")  # Replace with the path to your DEM file

# Load the Rathnapura district shapefile
rathnapura <- st_read("rathnapura district.shp")  # Replace with the path to your shapefile

# Ensure the DEM and shapefile have the same CRS
rathnapura <- st_transform(rathnapura, crs = crs(dem))

# Clip the DEM to the Rathnapura district boundary
dem_rathnapura <- mask(crop(dem, rathnapura), rathnapura)

# Save the clipped DEM as a TIFF file
writeRaster(dem_rathnapura, "dem_rathnapura.tif", overwrite = TRUE)


# Convert the clipped DEM to a data frame for ggplot2
raster_df_clipped <- as.data.frame(dem_rathnapura, xy = TRUE)
colnames(raster_df_clipped) <- c("longitude", "latitude", "elevation")

# Define intervals and colors for elevation
num_intervals <- 5  # Number of intervals
interval_breaks <- seq(min(raster_df_clipped$elevation, na.rm = TRUE), 
                       max(raster_df_clipped$elevation, na.rm = TRUE), 
                       length.out = num_intervals + 1)
interval_labels <- paste(round(interval_breaks[-length(interval_breaks)]), 
                         round(interval_breaks[-1]), sep = " - ")

# Assign intervals to the elevation data
raster_df_clipped$interval <- cut(raster_df_clipped$elevation, breaks = interval_breaks, labels = interval_labels)

# Remove rows with NA values in the interval column
raster_df_clipped <- raster_df_clipped[!is.na(raster_df_clipped$interval), ]

# Define a color palette using RColorBrewer
color_palette <- brewer.pal(num_intervals, "YlOrBr")  # Use "YlOrBr" palette for 5 intervals

# Plot the map using ggplot2 with RColorBrewer color scale
ggplot() +
  geom_raster(data = raster_df_clipped, aes(x = longitude, y = latitude, fill = interval)) +
  geom_sf(data = rathnapura, fill = NA, color = "black", size = 0.5) +  # Add shapefile boundary
  scale_fill_manual(values = color_palette, name = "Elevation (m)", labels = interval_labels, na.value = NA) +  # Use RColorBrewer palette
  coord_sf(expand = FALSE) +  # Prevent expansion of the map
  theme_minimal() +
  labs(title = "Elevation Rathnapura District") +
  theme(
    panel.grid.major = element_line(color = "grey", size = 0.4),  # Add latitude and longitude grid lines
    panel.grid.minor = element_blank(),  # Remove minor grid lines
    axis.text.x = element_text(size = 8, angle = 0),  # Customize x-axis labels
    axis.text.y = element_text(size = 8),  # Customize y-axis labels
    axis.title.x = element_blank(),  # Remove x-axis title
    axis.title.y = element_blank(),  # Remove y-axis title
    legend.position = "right"  # Place legend on the right
  )
