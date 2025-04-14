# Load the packages
library(gstat)
library(sp)
library(ggplot2)
library(sf)
library(raster)
library(viridisLite)
library(viridis)
library(ggspatial)

# Load the CSV file that conatain rainfall data
rainfall_data <- read.csv("precipitation.csv")

# Convert to Spatial Points DataFrame
coordinates(rainfall_data) <- ~longitude+latitude
proj4string(rainfall_data) <- CRS("+proj=longlat +datum=WGS84")

# Load the required shapefile
rathnapura_shapefile <- st_read("rathnapura district.shp")

# Ensure CRS is the same for both the rainfall point data and shapefile
rathnapura_shapefile <- st_transform(rathnapura_shapefile, crs = st_crs(rainfall_data))

# Create a grid for interpolation within the shapefile extent
raster_template <- raster(extent(rathnapura_shapefile), res=0.001)  # High resolution
raster_template <- rasterize(rathnapura_shapefile, raster_template, field=1)
grid <- as(raster_template, 'SpatialPixelsDataFrame')

# Ensure CRS is the same for both the grid and point data
proj4string(grid) <- proj4string(rainfall_data)

# IDW interpolation for annual rainfall(with power 2)
idw_model <- gstat::idw(annual_rainfall ~ 1, rainfall_data, grid, idp = 2)

# Convert to Raster Layer
raster_idw <- raster(idw_model)

# Mask the raster using the shape file
raster_masked <- mask(raster_idw, rathnapura_shapefile)

# Save the raster as a GeoTIFF file
writeRaster(raster_masked, filename="mean_annual_rainfall_rathnapura.tif", format="GTiff", overwrite=TRUE)



# Remove Not avalable values for plotting
raster_df_clipped <- as.data.frame(raster_masked, xy = TRUE)
colnames(raster_df_clipped) <- c("longitude", "latitude", "mean_rainfall")
raster_df_clipped <- raster_df_clipped[!is.na(raster_df_clipped$mean_rainfall), ]


# Define equal intervals
num_intervals <- 5  # Number of intervals
breaks <- seq(min(raster_df_clipped$mean_rainfall), max(raster_df_clipped$mean_rainfall), length.out = num_intervals + 1)

# Assign intervals to the data
raster_df_clipped$interval <- cut(raster_df_clipped$mean_rainfall, breaks = breaks, include.lowest = TRUE, labels = FALSE)

# Create custom labels for the legend
interval_labels <- sapply(1:num_intervals, function(i) {
  paste0(round(breaks[i]), " - ", round(breaks[i + 1]))
})

# Define colors for the intervals
interval_colors <- viridis::viridis(num_intervals)

# Plot the map
ggplot() +
  geom_raster(data = raster_df_clipped, aes(x = longitude, y = latitude, fill = factor(interval))) +
  geom_sf(data = rathnapura_shapefile, fill = NA, color = "black") +  # Shapefile boundary
  scale_fill_manual(values = interval_colors, name = "Rainfall (mm)", labels = interval_labels) +  # Apply equal interval colors with custom labels
  coord_sf(expand = FALSE) +
  theme_minimal() +
  labs(title = "Annual Rainfall Rathnapura District (2019-2023)") +  # Remove axis titles
  theme(panel.grid.major = element_line(color = "grey", size = 0.4),  # Add latitude and longitude grid lines
        panel.grid.minor = element_blank(),  # Remove minor grid lines
        axis.text.x = element_text(size = 6, angle = 0),  # Add x-axis labels without angle
        axis.text.y = element_text(size = 6),  # Add y-axis labels
        axis.title.x = element_blank(),  # Remove x-axis title
        axis.title.y = element_blank())  # Remove y-axis title
