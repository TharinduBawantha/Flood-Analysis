# Load libraries
library(terra)
library(whitebox)
library(ggplot2)
library(RColorBrewer)
library(classInt)
library(sf)

# Load the DEM file
dem <- rast("DEM.tif")

# Compute Terrain Ruggedness Index (TRI) using WhiteboxTools
wbt_ruggedness_index(dem ,"terrain_ruggedness_index.tif")

# Load the resulting TRI raster
tri <- rast("terrain_ruggedness_index.tif")

#load shape file
rathnapura <- vect("rathnapura district.shp")

# Mask the raster using the shape file
rathanapura_tri <- mask(tri, rathnapura)
plot(rathanapura_tri)

# Save the raster as a GeoTIFF file
writeRaster(rathanapura_tri, filename="tri_rathnapura.tif", overwrite=TRUE)

# Convert Clipped Raster to DataFrame for Visualization
tri_df <- as.data.frame(rathanapura_tri, xy = TRUE)
colnames(tri_df) <- c("longitude", "latitude", "terrain_ruggedness_index ")

# Classify Curvature and Define Color Palette
num_intervals <- 5  # Set number of intervals
tri_breaks <- seq(min(tri_df$terrain_ruggedness_index, na.rm = TRUE), max(tri_df$terrain_ruggedness_index, na.rm = TRUE), length.out = num_intervals + 1)
tri_labels <- paste(round(curvature_breaks[-length(curvature_breaks)], 2), round(curvature_breaks[-1], 2), sep = " - ")

tri_df$interval <- cut(tri_df$terrain_ruggedness_index, breaks = tri_breaks, labels = tri_labels)
tri_df <- tri_df[!is.na(tri_df$interval), ]

# Define a color palette using RColorBrewer
color_palette <- brewer.pal(num_intervals, "BrBG")  # Use diverging palette for curvature

# Plot Curvature Map
ggplot() +
  geom_raster(data = tri_df, aes(x = longitude, y = latitude, fill = interval)) +
  geom_sf(data = st_as_sf(rathnapura), fill = NA, color = "black", size = 0.5) +
  scale_fill_manual(values = color_palette, name = "TRI", labels = tri_labels) +
  coord_sf(expand = FALSE) +
  theme_minimal() +
  labs(title = "Terrain Ruggedness Index Rathnapura District") +
  theme(
    panel.grid.major = element_line(color = "grey", size = 0.4),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(size = 8),
    axis.text.y = element_text(size = 8),
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    legend.position = "right"
  )