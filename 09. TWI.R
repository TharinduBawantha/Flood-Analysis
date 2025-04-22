# Load libraries
library(terra)
library(whitebox)
library(ggplot2)
library(RColorBrewer)
library(classInt)
library(sf)

# Load the DEM
dem <- rast("DEM.tif")

# Use WhiteboxTools to fill depressions in the DEM
wbt_fill_depressions(dem, "filled_DEM.tif")
filled_dem <- rast("filled_DEM.tif") #load the filled dem file

# Use WhiteboxTools to calculate the flow direction (D8 method)
wbt_d8_pointer(filled_dem, "flow direction.tif")
flow_direction <- rast("flow direction.tif") # Load the flow direction raster

# Use WhiteboxTools to calculate flow accumulation
wbt_d8_flow_accumulation(input = flow_direction, "flow accumulation.tif")
flow_accumulation <- rast("flow accumulation.tif") # Load the flow accumulation raster

# Calculate slope in degrees using WhiteboxTools
wbt_slope(dem, "slope.tif", units = "degrees")
slope <- rast("slope.tif")

# Convert slope from degrees to radians
slope_rad <- slope * (pi / 180)

# Calculate the tangent of the slope in radians
tan_slope <- tan(slope_rad)

# Add 1 to each cell in the flow accumulation raster
adjusted_flow_accum <- flow_accumulation + 1

# Compute the Topographic Wetness Index
twi <- log(flow_accumulation / tan_slope)

# Load the shapefile for Ratnapura District
rathnapura <- vect("rathnapura district.shp")

# Reproject shapefile to match TWI raster CRS (if needed)
rathnapura <- project(rathnapura, twi)

# Clip SPI raster to Rathnapura shapefile boundaries
twi_clipped <- crop(twi, rathnapura) # Crops SPI to bounding box of Rathnapura
twi_clipped <- mask(twi_clipped, rathnapura) # Masks SPI to exact Rathnapura boundaries

# Save the raster as a GeoTIFF file
writeRaster(twi_clipped, filename = "TWI_rathnapura.tif", overwrite = TRUE)




# Convert SPI raster to dataframe
twi_df <- as.data.frame(twi_clipped, xy = TRUE)
colnames(twi_df) <- c("longitude", "latitude", "twi")



# Convert the vector data to sf object
rathnapura_sf <- st_as_sf(rathnapura)

# Define the number of intervals
num_intervals <- 5  # You can choose the number of intervals as per your requirement


# Classify SPI using Jenks breaks
breaks_twi <- classIntervals(twi_df$twi, n = num_intervals, style = "fisher")$brks
labels_twi <- paste(round(breaks_twi[-length(breaks_twi)], 2), round(breaks_twi[-1], 2), sep = " - ")
twi_df$interval <- cut(twi_df$twi, breaks = breaks_twi, labels = labels_twi)
twi_df <- twi_df[!is.na(twi_df$interval), ]

# Color palette for SPI
twi_colors <- rev(brewer.pal(num_intervals, "BrBG"))

# Plot SPI
ggplot() +
  geom_raster(data = twi_df, aes(x = longitude, y = latitude, fill = interval)) +
  geom_sf(data = st_as_sf(rathnapura), fill = NA, color = "black", size = 0.5) +
  scale_fill_manual(values = twi_colors, name = "TWI", labels = labels_twi) +
  coord_sf(expand = FALSE) +
  theme_minimal() +
  labs(title = "Topogrphic Wetness Index Rathnapura District") +
  theme(
    panel.grid.major = element_line(color = "grey", size = 0.4),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(size = 8),
    axis.text.y = element_text(size = 8),
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    legend.position = "right"
  )
