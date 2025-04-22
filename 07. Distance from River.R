# Load the necessary libraries
library(sf)
library(raster)
library(ggplot2)
library(RColorBrewer)
library(classInt)

# Load the shapefiles
rathnapura_district <- st_read("rathnapura district.shp")  # District boundary shapefile
rathnapura_river <- st_read("rathnapura river.shp")        # River shapefile

# Transform the CRS to ensure compatibility
rathnapura_district <- st_transform(rathnapura_district, crs = st_crs(rathnapura_river))
rathnapura_river <- st_transform(rathnapura_river, crs = st_crs(rathnapura_river))

# Create a raster layer covering the extent of the district
raster_template <- raster(extent(rathnapura_district), 
                          resolution = 100,  # Adjust resolution for detail
                          crs = st_crs(rathnapura_district)$proj4string)

# Rasterize the river shapefile (mark river cells as 1, others as NA)
river_raster <- rasterize(rathnapura_river, raster_template, field = 1)

# Calculate Euclidean distance from the river
distance_raster <- distance(river_raster)

# Mask the distances to the district extent
distance_raster_masked <- mask(distance_raster, rasterize(rathnapura_district, raster_template))

# Save the raster as a GeoTIFF file
writeRaster(distance_raster_masked, filename = "distance_from_river_rathnapura.tif", format = "GTiff", overwrite = TRUE)

# Convert the raster to a data frame for ggplot2
distance_df <- as.data.frame(distance_raster_masked, xy = TRUE)
colnames(distance_df) <- c("longitude", "latitude", "distance")
distance_df <- distance_df[!is.na(distance_df$distance), ]  # Remove NA values

# Apply quantile-based classification
num_intervals <- 5  # Number of intervals
breaks <- classIntervals(distance_df$distance, n = num_intervals, style = "quantile")$brks
interval_labels <- paste(round(breaks[-length(breaks)]), 
                         round(breaks[-1]), sep = " - ")

# Assign intervals to the distance data
distance_df$interval <- cut(distance_df$distance, breaks = breaks, labels = interval_labels, include.lowest = TRUE)

# Define a color palette for the intervals
color_palette <- brewer.pal(num_intervals, "GnBu")  # Purple to Greenish-Blue palette

# Plot the distance map using ggplot2
ggplot() +
  geom_raster(data = distance_df, aes(x = longitude, y = latitude, fill = interval)) +
  geom_sf(data = rathnapura_district, fill = NA, color = "black", size = 0.5) +  # Add district boundary
  scale_fill_manual(values = color_palette, name = "Distance from River (m)", labels = interval_labels, na.value = NA) +  # Quantile intervals
  coord_sf(expand = FALSE) +
  theme_minimal() +
  labs(title = "Distance from River Rathnapura District") +
  theme(
    panel.grid.major = element_line(color = "grey", size = 0.4),  # Add grid lines
    panel.grid.minor = element_blank(),  # Remove minor grid lines
    axis.text.x = element_text(size = 8),  # Customize x-axis labels
    axis.text.y = element_text(size = 8),  # Customize y-axis labels
    axis.title.x = element_blank(),  # Remove x-axis title
    axis.title.y = element_blank(),  # Remove y-axis title
    legend.position = "right"  # Place legend on the right
  )
