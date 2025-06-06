
<h3> 01. Annual rainfall </h3>

Interpolating the monthly precipitation point data for each year creates a spatially continuous representation of annual rainfall. Common interpolation methods like Inverse Distance Weighting (IDW) are used to transform point data into a smooth rainfall map.

![precipitation](https://github.com/user-attachments/assets/fdc135d5-5060-46fb-abb3-47c8bbf8b7c3)


<h3> 02. SPI - Stream Power Index map </h3>

     SPIi = ln(DAi * tan(Gi)) 

where SPI is the stream power index at gridcell i, DA is the upstream drainage area (flow accumulation at gridcell i multiplied by gridcell area), and G is the slope at a grid cell i in radians.

a. load the DEM file

![DEM](https://github.com/user-attachments/assets/86a51e2b-2b85-4140-8a25-f697a03d9e22)

b. Fill the DEM

This ensure that the DEM doesn’t have any sinks or depressions that could affect the flow of water.

![filled DEM](https://github.com/user-attachments/assets/ec7ba91c-401a-41dd-b9bc-6adb41f52ebe)

c. Calculate Flow Direction

Shows the direction of flow out of each cell. 

![flow direction](https://github.com/user-attachments/assets/17bd1498-b4b6-494b-9e41-4047bf330811)

d. Compute Flow Accumulation

Flow accumulation calculates the number of cells that contribute flow to each cell in the DEM.

![flow accumulation](https://github.com/user-attachments/assets/6ee5f5eb-b269-4736-a1df-3d14238d1bb6)

e. slope in degrees

![slope in degrees](https://github.com/user-attachments/assets/82a449e8-97d1-4fd3-96cf-2b36a2f30287)

f. generate the SPI from the formula

![SPI](https://github.com/user-attachments/assets/30fc3dc8-1201-4b7f-bb5d-6b51e9b04d4d)


<h3> 03. Elevation </h3>

![Elevation Rathnapura](https://github.com/user-attachments/assets/0c187e15-d99d-4606-b0ef-67a17b848604)


<h3> 04. Slope </h3>

![Slope Rathnapura](https://github.com/user-attachments/assets/26826a26-294c-48a2-87ae-6f426dfd0f67)


<h3> 05. Profile curvature </h3>

![curvature](https://github.com/user-attachments/assets/e3f84313-f257-4b9c-90f5-1083738ee558)


<h3> 06. Topographic Roughness Index (TRI)  </h3>

![TRI](https://github.com/user-attachments/assets/7072ce11-9885-4197-b7bd-b86227b3f411)


<h3> 07. Distance from rivers  </h3>

Distcance from river generate from the Euclidean distance function. Calculate Euclidean distance determine the straight-line distance from each raster cell to the nearest feature, such as rivers, roads, or other elements.

![Distance from River Rathnapura](https://github.com/user-attachments/assets/9eca81ed-0daf-4013-9961-b11792f0825a)


<h3> 08. Soil Erodibility - K Factor  </h3>

The Williams K-Factor is a measure of soil erodibility, which quantifies the susceptibility of soil particles to detachment and transport by rainfall and runoff. It is influenced by factors such as soil texture, organic matter content, structure, and permeability. The K-Factor is widely used in erosion models to predict soil loss and assess land vulnerability.

![K factor Rathnapura](https://github.com/user-attachments/assets/6c236ceb-cff2-4f5d-b030-01d1977bb4ff)


<h3> 09. TWI   </h3>

The Topographic Wetness Index (TWI) is a valuable tool in GIS. It measures the influence of topography on hydrological processes and identifies regions that, given their landscape location, are probably wetter. 
            
            TWI = ln(adjusted_flow_accumulation / tan_slope)

a. DEM visualisation

![DEM](https://github.com/user-attachments/assets/1061200f-0376-4ee2-bb9f-de3b8bc5bcac)

b. Fill the DEM

This guarantees that there are no depressions or sinks in the DEM that can impede water movement.

![Filled DEM](https://github.com/user-attachments/assets/c29481c6-f563-438d-b6fe-bc0e2c1e8cac)

c. Calculate Flow Direction

In the context of hydrology and GIS, "flow direction" refers to the path that water takes across a landscape, typically determined by the steepest slope or direction of greatest elevation difference. It's essentially the direction water flows from a point on the land surface under the influence of gravity. This determines the direction of flow for each cell in the DEM.

![Flow Direction](https://github.com/user-attachments/assets/e192b0d1-53e6-4c0b-bc29-1aef5ad46f9b)

d. Compute Flow Accumulation

The accumulated flow is based on the number of total or a fraction of cells flowing into each cell in the output raster. The current processing cell is not considered in this accumulation. Output cells with a high flow accumulation are areas of concentrated flow and can be used to identify stream channels. This calculates the number of cells that contribute flow to each cell in the DEM.

![Flow Accumulation](https://github.com/user-attachments/assets/b82b3a4c-283a-46cf-ba5c-eb6178ffe9df)

e. Determine Slope

Slope calculate by the maximum rate of change between each cell and its neighbors.

![Slope (Degrees)](https://github.com/user-attachments/assets/7ad2793c-016d-41cc-ba58-1a9847eda5b2)

f. Convert Slope to Radians

Convert radians due to TWI calculations requiring slope values in radians.

![Slope (Radians)](https://github.com/user-attachments/assets/14a71e50-bf46-41f2-a523-2a5ca8a8519e)

g. Calculate the Tangent of the Slope

         tan_slope = tan(slope_radians)

![Tangent of Slope](https://github.com/user-attachments/assets/8286e2a1-efa1-4023-bf3b-446455ed02cc)

h. Adjust Flow Accumulation

         adjusted_flow_accumulation = flow_accumulation + 1

![Adjusted Flow Accumulation](https://github.com/user-attachments/assets/64104995-a88d-4ed4-912f-d72aa57685b9)

i. Compute Topographic Wetness Index (TWI)

         TWI = ln(adjusted_flow_accumulation / tan_slope)

![TWI](https://github.com/user-attachments/assets/4dc0e0b0-dd6a-4707-9b26-662d62c24498)

j. Clip TWI Raster to Shapefile

![TWI](https://github.com/user-attachments/assets/4c0ea690-6a90-4507-834b-4960ab7af3aa)

<h3> 10. Rainfall erosivity factor (R)  </h3>

![R factor Rathnapura](https://github.com/user-attachments/assets/07192ad5-decd-488a-9c1d-fc3b1d786139)

<h3> 11. Land use and land cover  </h3>

![LULC Rathnapura](https://github.com/user-attachments/assets/38d67fc0-3c4d-4ebe-bbe8-045765c2702d)

<h3> 12. SAVI  </h3>

The Soil Adjusted Vegetation Index (SAVI) is a vegetation index designed to minimize the influence of soil brightness in areas with sparse vegetation cover. It is particularly useful in regions where vegetation is intermixed with exposed soil, as it adjusts the Normalized Difference Vegetation Index (NDVI) by incorporating a soil brightness correction factor.

      SAVI =1.5 (NIR RED)/(NIR +RED+0.5)

![SAVI Rathnapura](https://github.com/user-attachments/assets/c3d2127c-36d1-4771-9f67-7bdd832cbc6e)


<h3> 13. NDVI  </h3>

The Normalized Difference Vegetation Index (NDVI) is a widely used metric for assessing vegetation health and density. It measures the difference between near-infrared (NIR) light, which vegetation strongly reflects, and red light, which vegetation absorbs.

      NDVI=(NIR RED)/(NIR+RED)

![NDVI Rathnapura](https://github.com/user-attachments/assets/814e00ea-7618-468b-8b03-4366445b64a7)

<h3> 14. Population density  </h3>

![Population Density Rathnapura](https://github.com/user-attachments/assets/fdc0ce50-f6d3-46d8-8e7e-771d796f711d)

<h3> 15. Build-Up Index  </h3>

The Build-Up Index (BUI) is a remote sensing index used to identify and map urban or built-up areas. It is particularly effective in distinguishing impervious surfaces, such as concrete and asphalt, from natural vegetation.

     BU = NDBI - NDVI
     NDBI = (SWIR - NIR) /(SWIR + NIR)

![BU index Rathnapura](https://github.com/user-attachments/assets/5665c1b0-5f02-4f8c-9e3f-6f40e505b8d2)

