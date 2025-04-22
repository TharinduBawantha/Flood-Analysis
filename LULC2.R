# Load necessary libraries
library(raster)
library(sf)
library(terra)
library(ggplot2)
library(classInt)
library(RColorBrewer)

# Load LULC raster
lulc <- rast("LULC.tif")

# Load the Rathnapura district shapefile
rathnapura <- st_read("rathnapura district.shp")

# Ensure the LULC and shapefile have the same CRS
rathnapura <- st_transform(rathnapura, crs = crs(lulc))

# Clip the LULC raster to the Rathnapura district boundary
lulc_rathnapura <- mask(crop(lulc, rathnapura), rathnapura)

# Save the clipped raster
writeRaster(lulc_rathnapura, "lulc_rathnapura.tif", overwrite = TRUE)

# Convert the clipped raster to a data frame
lulc_df_clipped <- as.data.frame(lulc_rathnapura, xy = TRUE)
colnames(lulc_df_clipped) <- c("longitude", "latitude", "lulc_value")

# Create a mapping of LULC numeric values to descriptive classes
lulc_labels <- c(
  "1" = "Water",
  "2" = "Trees",
  "4" = "Flooded Vegetation",
  "5" = "Crops",
  "7" = "Built Area",
  "8" = "Bare Ground",
  "10" = "Clouds",
  "11" = "Rangeland"
)

# Add a column for descriptive classes
lulc_df_clipped$lulc_class <- factor(lulc_df_clipped$lulc_value, 
                                     levels = names(lulc_labels), 
                                     labels = lulc_labels)

# Define a color palette for LULC classes
color_palette <- brewer.pal(length(lulc_labels), "Accent")

# Plot the LULC map
ggplot() +
  geom_raster(data = lulc_df_clipped, aes(x = longitude, y = latitude, fill = lulc_class)) +
  geom_sf(data = rathnapura, fill = NA, color = "black", size = 0.5) +  # Add district boundary
  scale_fill_manual(values = color_palette, name = "LULC Classes") +
  coord_sf(expand = FALSE) +
  theme_minimal() +
  labs(title = "Land Use/Land Cover (LULC) Map - Rathnapura District") +
  theme(
    panel.grid.major = element_line(color = "grey", size = 0.4),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(size = 8),
    axis.text.y = element_text(size = 8),
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    legend.position = "right"
  )
