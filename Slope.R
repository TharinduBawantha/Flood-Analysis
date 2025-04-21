# Load necessary libraries
library(tidyverse)
library(raster)
library(sf)
library(ggplot2)
library(RColorBrewer)
library(classInt)  # For natural breaks classification

# Load the DEM file
dem <- raster("DEM.tif")  # Replace with the path to your DEM file

# Calculate the slope from the DEM
slope <- terrain(dem, opt = "slope", unit = "degrees")  # Calculate slope in degrees

# Load the Rathnapura district shapefile
rathnapura <- st_read("rathnapura district.shp")  # Replace with the path to your shapefile

# Ensure the DEM and shapefile have the same CRS
rathnapura <- st_transform(rathnapura, crs = crs(slope))

# Clip the slope raster to the Rathnapura district boundary
slope_rathnapura <- mask(crop(slope, rathnapura), rathnapura)

# Save the clipped slope map as a TIFF file
writeRaster(slope_rathnapura, "slope_rathnapura.tif", overwrite = TRUE)

# Convert the clipped slope raster to a data frame for ggplot2
slope_df_clipped <- as.data.frame(slope_rathnapura, xy = TRUE)
colnames(slope_df_clipped) <- c("longitude", "latitude", "slope")

# Classify slope data using natural breaks (Jenks)
num_intervals <- 5  # Number of intervals
breaks <- classIntervals(slope_df_clipped$slope, n = num_intervals, style = "jenks")$brks
interval_labels <- paste(round(breaks[-length(breaks)]), round(breaks[-1]), sep = " - ")

# Assign intervals to the slope data
slope_df_clipped$interval <- cut(slope_df_clipped$slope, breaks = breaks, labels = interval_labels)

# Remove rows with NA values in the interval column
slope_df_clipped <- slope_df_clipped[!is.na(slope_df_clipped$interval), ]

# Define a different color palette (e.g., "RdYlGn" - Red to Yellow to Green)
color_palette <- brewer.pal(num_intervals, "RdYlGn")  # Use "RdYlGn" palette for 5 intervals

# Plot the slope map using ggplot2
ggplot() +
  geom_raster(data = slope_df_clipped, aes(x = longitude, y = latitude, fill = interval)) +
  geom_sf(data = rathnapura, fill = NA, color = "black", size = 0.5) +  # Add shapefile boundary
  scale_fill_manual(values = color_palette, name = "Slope (°)", labels = interval_labels, na.value = NA) +  # Use new color palette
  coord_sf(expand = FALSE) +  # Prevent expansion of the map
  theme_minimal() +
  labs(title = "Slope Map of Rathnapura District") +
  theme(
    panel.grid.major = element_line(color = "grey", size = 0.4),  # Add grid lines
    panel.grid.minor = element_blank(),  # Remove minor grid lines
    axis.text.x = element_text(size = 8),  # Customize x-axis labels
    axis.text.y = element_text(size = 8),  # Customize y-axis labels
    axis.title.x = element_blank(),  # Remove x-axis title
    axis.title.y = element_blank(),  # Remove y-axis title
    legend.position = "right"  # Place legend on the right
  )
