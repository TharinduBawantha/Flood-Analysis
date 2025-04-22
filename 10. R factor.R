# Load the packages
library(raster)
library(gstat)
library(ggplot2)
library(sf)
library(viridis)
library(ggspatial)

# Load the mean annual rainfall data
mean_rainfall_raster <- raster("precipitation_rathnapura.tif")

# Calculate the Rainfall Erosivity Factor (R factor)
erosivity_raster <- calc(mean_rainfall_raster, fun = function(MAR) {
  (972.75 + 9.95 * MAR) / 100
})
plot(erosivity_raster)


# Save the raster as a GeoTIFF file
writeRaster(erosivity_raster, filename = "erosivity_rathnapura.tif", overwrite = TRUE)

# Load the shapefile
rathnapura <- st_read("rathnapura district.shp")


# Convert the masked R factor raster to a dataframe
R_df <- as.data.frame(erosivity_raster, xy = TRUE)
colnames(R_df) <- c("longitude", "latitude", "R_factor")

# Classify the R factor using Jenks breaks
num_intervals <- 5  # Define the number of intervals
breaks_R <- classIntervals(R_df$R_factor, n = num_intervals, style = "fisher")$brks
labels_R <- paste(round(breaks_R[-length(breaks_R)], 2), round(breaks_R[-1], 2), sep = " - ")
R_df$interval <- cut(R_df$R_factor, breaks = breaks_R, labels = labels_R)
R_df <- R_df[!is.na(R_df$interval), ]

# Define a color palette for R factor visualization
R_colors <- viridis(num_intervals, option = "magma")

# Plot the Rainfall Erosivity Factor (R factor)
ggplot() +
  geom_raster(data = R_df, aes(x = longitude, y = latitude, fill = interval)) +
  geom_sf(data = rathnapura_shapefile, fill = NA, color = "black", size = 0.5) +
  scale_fill_manual(values = R_colors, name = "R Factor", labels = labels_R) +
  coord_sf(expand = FALSE) +
  theme_minimal() +
  labs(title = "Rainfall Erosivity Factor (R)  Rathnapura District") +
  theme(
    panel.grid.major = element_line(color = "grey", size = 0.4),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(size = 8),
    axis.text.y = element_text(size = 8),
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    legend.position = "right"
  )
