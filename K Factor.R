# Load the necessary libraries
library(sf)
library(raster)
library(terra)
library(ggplot2)
library(RColorBrewer)
library(classInt)

#load the K data file
k_factor <- rast("2025-04-22--williams-k-factor--cbc7ab4a-d5f1-4ebe-a217-43f5d6d18e19.tif")

# Load the Rathnapura district shapefile
rathnapura <- st_read("rathnapura district.shp")  # Replace with the path to your shapefile

# Ensure the DEM and shapefile have the same CRS
rathnapura <- st_transform(rathnapura, crs = crs(k_factor))

# Clip the DEM to the Rathnapura district boundary
k_rathnapura <- mask(crop(k_factor, rathnapura), rathnapura)

# Save the clipped DEM as a TIFF file
writeRaster(k_rathnapura, "k_rathnapura.tif", overwrite = TRUE)






# Convert the clipped K-factor raster to a data frame for ggplot2
raster_df_clipped <- as.data.frame(k_rathnapura, xy = TRUE)
colnames(raster_df_clipped) <- c("longitude", "latitude", "k_factor_value")

# Define intervals and colors for K-factor
num_intervals <- 5  # Number of intervals
interval_breaks <- seq(min(raster_df_clipped$k_factor_value, na.rm = TRUE), 
                       max(raster_df_clipped$k_factor_value, na.rm = TRUE), 
                       length.out = num_intervals + 1)
interval_labels <- paste(round(interval_breaks[-length(interval_breaks)], 3), 
                         round(interval_breaks[-1], 3), sep = " - ")

# Assign intervals to the K-factor data
raster_df_clipped$interval <- cut(raster_df_clipped$k_factor_value, breaks = interval_breaks, labels = interval_labels)

# Remove rows with NA values in the interval column
raster_df_clipped <- raster_df_clipped[!is.na(raster_df_clipped$interval), ]

# Define a color palette using RColorBrewer
color_palette <- brewer.pal(num_intervals, "YlOrRd")  # Use "YlOrRd" palette for K-factor

# Plot the K-factor map using ggplot2
ggplot() +
  geom_raster(data = raster_df_clipped, aes(x = longitude, y = latitude, fill = interval)) +
  geom_sf(data = rathnapura, fill = NA, color = "black", size = 0.5) +  # Add Rathnapura boundary
  scale_fill_manual(values = color_palette, name = "K-Factor", labels = interval_labels, na.value = NA) +  # Color scale for K-factor
  coord_sf(expand = FALSE) +  # Prevent map expansion
  theme_minimal() +
  labs(title = "Soil Erodibility (K-Factor) Rathnapura District") +
  theme(
    panel.grid.major = element_line(color = "grey", size = 0.4),  # Add latitude and longitude grid lines
    panel.grid.minor = element_blank(),  # Remove minor grid lines
    axis.text.x = element_text(size = 8, angle = 0),  # Customize x-axis labels
    axis.text.y = element_text(size = 8),  # Customize y-axis labels
    axis.title.x = element_blank(),  # Remove X-axis title
    axis.title.y = element_blank(),  # Remove Y-axis title
    legend.position = "right"  # Place legend on the right
  )
