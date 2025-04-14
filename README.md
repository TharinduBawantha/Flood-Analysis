**01. TWI map**

The Topographic Wetness Index (TWI) is a valuable tool in GIS. It measures the influence of topography on hydrological processes and identifies regions that, given their landscape location, are probably wetter. 
            
            TWI = ln(adjusted_flow_accumulation / tan_slope)

a. DEM visualisation

![DEM](https://github.com/user-attachments/assets/1061200f-0376-4ee2-bb9f-de3b8bc5bcac)

b. Fill the DEM

This guarantees that there are no depressions or sinks in the DEM that can impede water movement.

![Filled DEM](https://github.com/user-attachments/assets/c29481c6-f563-438d-b6fe-bc0e2c1e8cac)

c. Calculate Flow Direction

![Flow Direction](https://github.com/user-attachments/assets/e192b0d1-53e6-4c0b-bc29-1aef5ad46f9b)

d. Compute Flow Accumulation

![Flow Accumulation](https://github.com/user-attachments/assets/b82b3a4c-283a-46cf-ba5c-eb6178ffe9df)

e. Determine Slope

![Slope (Degrees)](https://github.com/user-attachments/assets/7ad2793c-016d-41cc-ba58-1a9847eda5b2)

f. Convert Slope to Radians


![Slope (Radians)](https://github.com/user-attachments/assets/14a71e50-bf46-41f2-a523-2a5ca8a8519e)

g. Calculate the Tangent of the Slope

![Tangent of Slope](https://github.com/user-attachments/assets/8286e2a1-efa1-4023-bf3b-446455ed02cc)

h. Adjust Flow Accumulation

![Adjusted Flow Accumulation](https://github.com/user-attachments/assets/64104995-a88d-4ed4-912f-d72aa57685b9)

i. Compute Topographic Wetness Index (TWI)

![TWI](https://github.com/user-attachments/assets/4dc0e0b0-dd6a-4707-9b26-662d62c24498)

j. Clip TWI Raster to Shapefile

![TWI](https://github.com/user-attachments/assets/4c0ea690-6a90-4507-834b-4960ab7af3aa)



