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
wbt_slope(dem, "slope.tif", units = "radians")
slope <- rast("slope.tif")

# Calculate cell area in square meters (assuming projected CRS)
cell_size <- res(flow_accumulation)[1]  # assumes square cells
cell_area <- cell_size^2

# Calculate drainage area
drainage_area <- flow_accumulation * cell_area

# Calculate SPI using formula: SPI = ln(drainage_area * tan(slope))
spi <- log(drainage_area * tan(slope))

# Load the shapefile for Ratnapura District
rathnapura <- vect("rathnapura district.shp")

# Reproject shapefile to match TWI raster CRS (if needed)
rathnapura <- project(rathnapura, spi)

# Clip SPI raster to Rathnapura shapefile boundaries
spi_clipped <- crop(spi, rathnapura) # Crops SPI to bounding box of Rathnapura
spi_clipped <- mask(spi_clipped, rathnapura) # Masks SPI to exact Rathnapura boundaries

# Save the raster as a GeoTIFF file
writeRaster(spi_clipped, filename = "SPI_rathnapura.tif", overwrite = TRUE)

# Convert SPI raster to dataframe
spi_df <- as.data.frame(spi_clipped, xy = TRUE)
colnames(spi_df) <- c("longitude", "latitude", "spi")

# Convert the vector data to sf object
rathnapura_sf <- st_as_sf(rathnapura)

# Define the number of intervals
num_intervals <- 5  # You can choose the number of intervals as per your requirement


# Classify SPI using Jenks breaks
breaks_spi <- classIntervals(spi_df$spi, n = num_intervals, style = "fisher")$brks
labels_spi <- paste(round(breaks_spi[-length(breaks_spi)], 2), round(breaks_spi[-1], 2), sep = " - ")
spi_df$interval <- cut(spi_df$spi, breaks = breaks_spi, labels = labels_spi)
spi_df <- spi_df[!is.na(spi_df$interval), ]

# Color palette for SPI
spi_colors <- rev(brewer.pal(num_intervals, "PiYG"))

# Plot SPI
ggplot() +
  geom_raster(data = spi_df, aes(x = longitude, y = latitude, fill = interval)) +
  geom_sf(data = st_as_sf(rathnapura), fill = NA, color = "black", size = 0.5) +
  scale_fill_manual(values = spi_colors, name = "SPI", labels = labels_spi) +
  coord_sf(expand = FALSE) +
  theme_minimal() +
  labs(title = "Stream Power Index (SPI) – Rathnapura District") +
  theme(
    panel.grid.major = element_line(color = "grey", size = 0.4),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(size = 8),
    axis.text.y = element_text(size = 8),
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    legend.position = "right"
  )
