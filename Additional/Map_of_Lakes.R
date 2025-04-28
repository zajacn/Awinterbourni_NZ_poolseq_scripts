library(leaflet)
library(dplyr)
# Define coordinates for the lakes, including Lake Mapourika
lakes_coords <- data.frame(
  name = c("Lake Alexandrina", "Lake Middleton", "Lake Paringa", "Lake Selfe", "Lake Mapourika"),
  lat = c(-43.95, -44.28, -43.7, -43.24, -43.32),
  lng = c(170.46, 169.84, 169.4, 171.5, 170.18),
  color = c("orange", "gold", "purple", "darkgreen", "cornflowerblue")
)

# Create a leaflet map
leaflet() %>%
  # Set the view to the South Island, focusing on the general area of the lakes
  setView(lng = 170.0, lat = -43.8, zoom = 7) %>%
  
  # Add a tile layer (OpenStreetMap)
  addTiles() %>%
  
  # Add markers and circles for each lake
  addMarkers(data = lakes_coords, ~lng, ~lat, 
             popup = ~name,
             label = ~name) %>%
  
  addCircles(data = lakes_coords, ~lng, ~lat,
             radius = 5000, # 5 km radius for each lake
             color = ~color, weight = 2, opacity = 0.8, fillOpacity = 0.4)%>%
  
  # Add labels to each lake
  addLabelOnlyMarkers(data = lakes_coords, ~lng, ~lat,
                      label = ~name,
                      labelOptions = labelOptions(noHide = TRUE, direction = 'right', 
                                                  textOnly = TRUE, style = list(
                                                    "color" = "black", "font-size" = "20px", 
                                                    "font-weight" = "bold")))


#Create a map of Mapourika Pools
Map_coords <- data.frame(
  name = c("Mapourika Jetty", "Mapourika Otto", "Mapourika Mix"),
  lat = c(-43.33,-43.29,-43.3165),
  lng = c(170.212,170.22,170.2035),
  color = c("cornflowerblue", "cornflowerblue", "cornflowerblue"))

leaflet() %>%
  # Set the view to the South Island, focusing on the general area of the lakes
  setView(lng = 170.2, lat = -43.3, zoom = 12) %>%
  
  # Add a tile layer (OpenStreetMap)
  addTiles() %>%
  
  # Add markers and circles for each lake
  addMarkers(data = Map_coords, ~lng, ~lat, 
             popup = ~name,
             label = ~name) %>%
  
  addCircles(data = Map_coords, ~lng, ~lat,
             radius = 200, # 5 km radius for each lake
             color = ~color, weight = 2, opacity = 0.8, fillOpacity = 0.4)%>%
  
  # Add labels to each lake
  addLabelOnlyMarkers(data = Map_coords, ~lng, ~lat,
                      label = ~name,
                      labelOptions = labelOptions(noHide = TRUE, direction = 'right', 
                                                  textOnly = TRUE, style = list(
                                                    "color" = "black", "font-size" = "14px", 
                                                    "font-weight" = "bold")))


## Map Alexandrina
Alex_coords <- data.frame(
  name = c("Alexandrina MW", "Alexandrina NE", "Alexandrina Camp2ndWP"),
  lat = c(-43.9405,-43.9078,-43.9692),
  lng = c(170.4433,170.45909,170.4487),
  color = c("orange", "orange", "orange"))


leaflet() %>%
  # Set the view to the South Island, focusing on the general area of the lakes
  setView(lng = 170.4, lat = -43.9, zoom = 12) %>%
  
  # Add a tile layer (OpenStreetMap)
  addTiles() %>%
  
  # Add markers and circles for each lake
  addMarkers(data = Alex_coords, ~lng, ~lat, 
             popup = ~name,
             label = ~name) %>%
  
  addCircles(data = Alex_coords, ~lng, ~lat,
             radius = 200, # 5 km radius for each lake
             color = ~color, weight = 2, opacity = 0.8, fillOpacity = 0.4)%>%
  
  # Add labels to each lake
  addLabelOnlyMarkers(data = Alex_coords, ~lng, ~lat,
                      label = ~name,
                      labelOptions = labelOptions(noHide = TRUE, direction = 'right', 
                                                  textOnly = TRUE, style = list(
                                                    "color" = "black", "font-size" = "14px", 
                                                    "font-weight" = "bold")))

## Map Middleton
Middleton_coords <- data.frame(
  name = c("Middleton Site1", "Middleton Site2"),
  lat = c(-44.274658,-44.281075),
  lng = c(169.849213,169.850869),
  color = c("gold", "gold"))


leaflet() %>%
  # Set the view to the South Island, focusing on the general area of the lakes
  setView(lng = 169.4, lat = -44.2, zoom = 12) %>%
  
  # Add a tile layer (OpenStreetMap)
  addTiles() %>%
  
  # Add markers and circles for each lake
  addMarkers(data = Middleton_coords, ~lng, ~lat, 
             popup = ~name,
             label = ~name) %>%
  
  addCircles(data = Middleton_coords, ~lng, ~lat,
             radius = 100, # 5 km radius for each lake
             color = ~color, weight = 2, opacity = 0.8, fillOpacity = 0.4)%>%
  
  # Add labels to each lake
  addLabelOnlyMarkers(data = Middleton_coords, ~lng, ~lat,
                      label = ~name,
                      labelOptions = labelOptions(noHide = TRUE, direction = 'right', 
                                                  textOnly = TRUE, style = list(
                                                    "color" = "black", "font-size" = "14px", 
                                                    "font-weight" = "bold")))
#Paringa - sampling sites -43.721256, 169.410977 | -43.714945, 169.422745
#Selfe - sampling sites -43.246631, 171.525426 | -43.238596, 171.513829
#Middleton - sampling sites - -44.274658, 169.849213 | -44.281075, 169.850869


## Map Paringa
Paringa_coords <- data.frame(
  name = c("Paringa Site1", "Paringa Site2"),
  lat = c(-43.721256,-43.714945),
  lng = c(169.410977,169.422745),
  color = c("purple", "purple"))


leaflet() %>%
  # Set the view to the South Island, focusing on the general area of the lakes
  setView(lng = 169.4, lat = -43.7, zoom = 12) %>%
  
  # Add a tile layer (OpenStreetMap)
  addTiles() %>%
  
  # Add markers and circles for each lake
  addMarkers(data = Paringa_coords, ~lng, ~lat, 
             popup = ~name,
             label = ~name) %>%
  
  addCircles(data = Paringa_coords, ~lng, ~lat,
             radius = 100, # 5 km radius for each lake
             color = ~color, weight = 2, opacity = 0.8, fillOpacity = 0.4)%>%
  
  # Add labels to each lake
  addLabelOnlyMarkers(data = Paringa_coords, ~lng, ~lat,
                      label = ~name,
                      labelOptions = labelOptions(noHide = TRUE, direction = 'right', 
                                                  textOnly = TRUE, style = list(
                                                    "color" = "black", "font-size" = "14px", 
                                                    "font-weight" = "bold")))
## Map Selfe
Selfe_coords <- data.frame(
  name = c("Selfe Site1", "Selfe Site2"),
  lat = c(-43.246631,-43.238596),
  lng = c(171.525426,171.513829),
  color = c("green", "green"))


leaflet() %>%
  # Set the view to the South Island, focusing on the general area of the lakes
  setView(lng = 171.5, lat = -43.2, zoom = 12) %>%
  
  # Add a tile layer (OpenStreetMap)
  addTiles() %>%
  
  # Add markers and circles for each lake
  addMarkers(data = Selfe_coords, ~lng, ~lat, 
             popup = ~name,
             label = ~name) %>%
  
  addCircles(data = Selfe_coords, ~lng, ~lat,
             radius = 100, # 5 km radius for each lake
             color = ~color, weight = 2, opacity = 0.8, fillOpacity = 0.4)%>%
  
  # Add labels to each lake
  addLabelOnlyMarkers(data = Selfe_coords, ~lng, ~lat,
                      label = ~name,
                      labelOptions = labelOptions(noHide = TRUE, direction = 'right', 
                                                  textOnly = TRUE, style = list(
                                                    "color" = "black", "font-size" = "14px", 
                                                    "font-weight" = "bold")))


#General map
library(sf)
library(terra)
library(dplyr)
library(spData)
library(spDataLarge)
library(tmap)    # for static and interactive maps
library(leaflet) # for interactive maps
library(ggplot2)
nz_elev = rast(system.file("raster/nz_elev.tif", package = "spDataLarge"))
map_nz = tm_shape(nz) + tm_polygons()
bbox_coords <- st_bbox(c(xmin = 169, xmax = 172, ymin = -44.5, ymax = -43), crs = st_crs(4326))  # WGS84 (lat/lon)

# Convert bbox to an sf object
bbox_sf <- st_as_sfc(bbox_coords)

# Ensure that both the map and the bounding box are in the same CRS (WGS84)
nz <- st_transform(nz, crs = 4326)  # Transform the 'nz' data to the same CRS if necessary
nz_elev <- st_transform(nz_elev, crs = 4326)  # If 'nz_elev' has a CRS, transform it too

# Create the map with the bounding box
map_nz <- tm_shape(nz) + 
  tm_polygons() +
  tm_graticules() +
  tm_compass(type = "8star", position = c("left", "top")) +
  tm_scalebar(breaks = c(0, 100, 200), text.size = 1, position = c("left", "top")) +
  tm_title("New Zealand") +
  tm_shape(nz_elev) + tm_raster(col_alpha = 1) +
  tm_shape(bbox_sf) + tm_borders(col = "red", lwd = 2)  # Add the bounding box in red

# Plot the map
tmap_mode("plot")
map_nz