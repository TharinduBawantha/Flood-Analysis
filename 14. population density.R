#load the libraries
library(sf)
library(terra)
library(ggplot2)
library(classInt)
library(RColorBrewer)

# Load files
pop <- rast("lka_pd_2020_1km_UNadj.tif") 

# Load the Rathnapura district shapefile
rathnapura <- st_read("rathnapura district.shp")  # Replace with the path to your shapefile

# Ensure the DEM and shapefile have the same CRS
rathnapura <- st_transform(rathnapura, crs = crs(pop))

# Clip the DEM to the Rathnapura district boundary
pop_rathnapura <- mask(crop(pop, rathnapura), rathnapura)

# Save the clipped DEM as a TIFF file
writeRaster(pop_rathnapura, "pop_density_rathnapura.tif", overwrite = TRUE)






# Convert the clipped population density raster to a data frame for ggplot2
pop_df_clipped <- as.data.frame(pop_rathnapura, xy = TRUE)
colnames(pop_df_clipped) <- c("longitude", "latitude", "population_density")

# Define intervals and colors for population density
num_intervals <- 5  # Number of intervals
interval_breaks <- seq(min(pop_df_clipped$population_density, na.rm = TRUE), 
                       max(pop_df_clipped$population_density, na.rm = TRUE), 
                       length.out = num_intervals + 1)
interval_labels <- paste(round(interval_breaks[-length(interval_breaks)]), 
                         round(interval_breaks[-1]), sep = " - ")

# Assign intervals to the population density data
pop_df_clipped$interval <- cut(pop_df_clipped$population_density, breaks = interval_breaks, labels = interval_labels)

# Remove rows with NA values in the interval column
pop_df_clipped <- pop_df_clipped[!is.na(pop_df_clipped$interval), ]

color_palette <- brewer.pal(num_intervals, "PuRd")


# Plot the population density map using ggplot2
ggplot() +
  geom_raster(data = pop_df_clipped, aes(x = longitude, y = latitude, fill = interval)) +
  geom_sf(data = rathnapura, fill = NA, color = "black", size = 0.5) +  # Add shapefile boundary
  scale_fill_manual(values = color_palette, name = "Population Density", labels = interval_labels, na.value = NA) +  # Use RColorBrewer palette
  coord_sf(expand = FALSE) +  # Prevent expansion of the map
  theme_minimal() +
  labs(title = "Population Density Rathnapura District") +
  theme(
    panel.grid.major = element_line(color = "grey", size = 0.4),  # Add latitude and longitude grid lines
    panel.grid.minor = element_blank(),  # Remove minor grid lines
    axis.text.x = element_text(size = 8, angle = 0),  # Customize x-axis labels
    axis.text.y = element_text(size = 8),  # Customize y-axis labels
    axis.title.x = element_blank(),  # Remove x-axis title
    axis.title.y = element_blank(),  # Remove y-axis title
    legend.position = "right"  # Place legend on the right
  )
