# Load libraries
library(terra)
library(whitebox)
library(ggplot2)
library(RColorBrewer)
library(classInt)
library(sf)

# Load the DEM file
dem <- rast("DEM.tif")

# Calculate profile curvature using WhiteboxTools
wbt_profile_curvature(dem , "profile_curvature.tif") # Output units

# Load the profile curvature raster for further analysis
profile_curvature <- rast("profile_curvature.tif")

#load shape file
rathnapura <- vect("rathnapura district.shp")

# Mask the raster using the shape file
rathanapura_curvature <- mask(profile_curvature, rathnapura)
plot(raster_masked)

# Save the raster as a GeoTIFF file
writeRaster(rathanapura_curvature, filename="curvature_rathnapura.tif", overwrite=TRUE)

# Convert Clipped Raster to DataFrame for Visualization
curvature_df <- as.data.frame(rathanapura_curvature, xy = TRUE)
colnames(curvature_df) <- c("longitude", "latitude", "curvature")

# Classify Curvature and Define Color Palette
num_intervals <- 5  # Set number of intervals
curvature_breaks <- seq(min(curvature_df$curvature, na.rm = TRUE), max(curvature_df$curvature, na.rm = TRUE), length.out = num_intervals + 1)
curvature_labels <- paste(round(curvature_breaks[-length(curvature_breaks)], 2), round(curvature_breaks[-1], 2), sep = " - ")

curvature_df$interval <- cut(curvature_df$curvature, breaks = curvature_breaks, labels = curvature_labels)
curvature_df <- curvature_df[!is.na(curvature_df$interval), ]

# Define a color palette using RColorBrewer

color_palette <- brewer.pal(num_intervals, "OrRd")  # Use diverging palette for curvature

# Plot Curvature Map
ggplot() +
  geom_raster(data = curvature_df, aes(x = longitude, y = latitude, fill = interval)) +
  geom_sf(data = st_as_sf(rathnapura), fill = NA, color = "black", size = 0.5) +
  scale_fill_manual(values = color_palette, name = "Curvature (radians/m)", labels = curvature_labels) +
  coord_sf(expand = FALSE) +
  theme_minimal() +
  labs(title = "Profile Curvature Rathnapura District") +
  theme(
    panel.grid.major = element_line(color = "grey", size = 0.4),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(size = 8),
    axis.text.y = element_text(size = 8),
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    legend.position = "right"
  )
