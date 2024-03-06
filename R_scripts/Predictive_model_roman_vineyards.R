###This script allows to build a predictive model for location of wineyards in Gaul; it's related to the publish paper Bernigaud et al. "Name of the paper" in JAS reports###
require(rgdal)
require (raster)
library(sp)
require(rgeos)
require(tiff)
require (gstat)
require(fields)
library(RColorBrewer)

####Importation of shapefiles and rasters###

### set working directory
WD<-setwd("C:/Users/Bernigaud Nicolas/Dropbox/Article_JAS_Reports_2021/Revision_JAS_reports/DATA/Shapefiles")

###France polygone###
France<-readOGR(dsn=WD, layer="France")
France<-spTransform(France, crs("+init=epsg:4326"))

###Create boundaries of study area###
Studyarea<-extent(France)
Myraster<-raster(ext=Studyarea, resolution=0.1) ###Create a raster for the study area (10 km resolution)###

###DEM###
DEM<-raster("MNT90m_l931.tif")
crs(DEM) <- CRS('+init=EPSG:2154')###reassign L93 projection
DEM<-projectRaster(DEM, crs=CRS('+init=EPSG:4326'))###transform in Lat Long
DEM<-crop(DEM, France)

###Transform DEM in exposition map###
Res_DEM<-resample(DEM, Myraster)###Resample DEM from 90 m resolution to 10 km
Expositions<-terrain(Res_DEM, opt="aspect", unit="degrees", neighbors=8)
Expositions[Expositions<67.5]<-0###Select expositions east and south (67.5 - 202.5 degrees)
Expositions[Expositions>202.5]<-0###assign 0 value for undesired expositions
Expositions[Expositions>0]<-1###value 1 for east and south expositions
Exposition_south_east<-crop(Expositions, Studyarea)###for expositions raster

###European hydrographic network: https://tapiquen-sig.jimdofree.com/english-version/free-downloads/europe/###
Hydrographic_Network<-readOGR(dsn=WD, layer="Europe_Hydrography")
Hydrographic_Network<-crop(Hydrographic_Network, Studyarea)

###Coastline SHP###
Coastline<-readOGR(dsn=WD, layer="Europe_coastline")
Coastline<-spTransform(Coastline, crs("+init=epsg:4326"))###same projection as DEM
Coastline<-crop(Coastline, Studyarea)

###Roman roads SHP: https://docs.google.com/file/d/0B4KitLDpLpYfN3hKM3E2YWltWm8/edit### 
Roman_roads<-readOGR(dsn=WD, layer="roman_roads_v2008")
Roman_roads<-spTransform(Roman_roads, crs("+init=epsg:4326"))###Reprojection in Lat Long
Roman_roads<-crop(Roman_roads, Studyarea)

###Roman capitals of cities in Gaul SHP (P. Ouzoulias)###
Capitals_of_cities<-readOGR(dsn=WD, layer="Capitals_of_cities")
Capitals_of_cities<-spTransform(Capitals_of_cities, crs("+init=epsg:4326"))
Capitals_of_cities<-crop(Capitals_of_cities, Studyarea)

###Create control map###
plot(DEM)
plot(Roman_roads,col="red", add=TRUE)
plot(Coastline, add=TRUE)
plot(Hydrographic_Network,col="blue",add=TRUE)
plot(Capitals_of_cities,pch=15, add=TRUE)
plot(Studyarea, add=TRUE)

###Creation of buffer zones around capitals of cities###
Buf_Capitals_cities<-buffer(Capitals_of_cities, width=30000)### = 30 km around

###rasterization of shapefiles at 10 km resolution###
R_Coastline<-rasterize(Coastline, Myraster, field=1, background=0)###Rasterize Coastline
R_Roman_roads<-rasterize(Roman_roads, Myraster, field=1, background=0)###Rasterize roman roads
R_Buf_Capitals_cities<-rasterize(Buf_Capitals_cities, Myraster, field=1, background=0)###Rasterize buffer area at 30 km around towns

###create a map of actual july temperature using ALADIN data###
Tempe_REF_mensuel<-read.table(file="https://www.data.gouv.fr/s/resources/indices-mensuels-de-temperature-et-nombre-de-jours-de-temperature-issus-du-modele-aladin-pour-la-periode-de-reference/20150930-200335/Tempe_REF_mensuel.txt", sep=";")
colnames(Tempe_REF_mensuel)<-c("Point", "Latitude", "Longitude", "Contexte", "Integration", "Mois", "NORTAV","NORTNAV", "NORTXAV", "NORTRAV", "NORTXQ90", "NORTXQ10","NORTNQ10","NORTNQ90","NORTXND","NORTNND","NORTNHT", "NORTXHWD", "NORTNCWD", "NORTNFD", "NORTXFD", "NORSD", "NORTR", "NORHDD", "NORCDD")
NORTAV_7<-matrix(nrow = 8602,ncol=4)
colnames(NORTAV_7)<-c("Point", "Lat", "Long", "T7")
seq1<-seq(1,103224, by=12)
NORTAV_7[,1]<-Tempe_REF_mensuel[seq1,1]
NORTAV_7[,2]<-Tempe_REF_mensuel[seq1,2]
NORTAV_7[,3]<-Tempe_REF_mensuel[seq1,3]
NORTAV_7[,4]<-Tempe_REF_mensuel[seq1 + 6,7]
NORTAV_7_DF<-as.data.frame(NORTAV_7)
MyRaster4<-raster(ext=extent(France), resolution=0.12)
R_NORTAV_7<-rasterize(NORTAV_7_DF[,3:2], MyRaster4, NORTAV_7_DF[,4] )
crs(R_NORTAV_7)<-CRS("+init=epsg:4326")
R_NORTAV_7<-mask(R_NORTAV_7, France)
plot(R_NORTAV_7)###check if the map is OK

###create a map of T anomalies for the 1st c. AD###
Base_Guiot<-load("reclim2_co2.Rdata") #Import climate reconstruction data from Guiots array
Temp_July_Ier_ap<-reco2[20,,26] #Anomalies for july T in 1900 BP (1st c. AD)
MyRaster3<-raster(ext=extent(France), resolution=0.12)
Climat_Interpol<-interpolate(MyRaster3, Tps(refco2[,3:4], reco2[20,,26]), ext=France)###Interpolation of Climat's points
crs(Climat_Interpol)<-CRS("+init=epsg:4326")
Climat_Interpol<-resample(Climat_Interpol, DEM)
Climat_Interpol<-mask(Climat_Interpol, France)
plot(Climat_Interpol, add=T)#Check if the raster is OK

###addition of raster of actual T of July + paleoclimatic anomalies###
R_Tempe_REF_mensuel_Juillet_Ier_ap<- R_NORTAV_7 + Climat_Interpol
R_Tempe_REF_mensuel_Juillet_Ier_ap[R_Tempe_REF_mensuel_Juillet_Ier_ap<18]<-0
R_Tempe_REF_mensuel_Juillet_Ier_ap[R_Tempe_REF_mensuel_Juillet_Ier_ap>18]<-1
plot(R_Tempe_REF_mensuel_Juillet_Ier_ap)#check the raster
R_Tempe_REF_mensuel_Juillet_Ier_ap<-resample(R_Tempe_REF_mensuel_Juillet_Ier_ap, Myraster)

###Creation of predictive model by addition of the differents rasters###
Predictive_model<-sum(R_Roman_roads, R_Hydrographic_Network, R_Coastline, R_Buf_Capitals_cities, Expositions, R_Tempe_REF_mensuel_Juillet_Ier_ap)
plot(Predictive_model)###check if the model is OK
writeRaster(Predictive_model, filename="C:/Users/Bernigaud Nicolas/Dropbox/Article_JAS_Reports_2021/Revision_JAS_reports/DATA/Shapefiles/Predictive_model_vineyards", format="GTiff", overwrite=TRUE)

###Validation of the model by Kvam's statistics test###
#Importation of archaeological data#

Winemakers_tools<-readOGR(dsn=WD, layer="Winemakers_tools")#Import shapefile of winemaking tools
###crs(Winemakers_tools) <- CRS('+init=EPSG:2154')#L93 projection
Winemakers_tools<-spTransform(Winemakers_tools, crs("+init=epsg:4326"))
names(Winemakers_tools)[2]<-"id"
Winemakers_tools$id<-seq(1:197)
##Winemakers_tools<-Winemakers_tools[,-(1;3)]

Winemakers_tools2<-readOGR(dsn=WD, layer="Winemakers_tools2")#Import shapefile of winemaking tools
crs(Winemakers_tools2) <- CRS('+init=EPSG:4326')#LatLong projection
Winemakers_tools2<-Winemakers_tools2[,-1]

Vine_planting_holes<-readOGR(dsn=WD, layer="Vine_planting_holes")#Import wine planting holes
crs(Vine_planting_holes) <- CRS('+init=EPSG:2154')#L93 projection
Vine_planting_holes<-spTransform(Vine_planting_holes, crs("+init=epsg:4326"))
#Vine_planting_holes<-Vine_planting_holes[,-(1:3)]

Wine_amphorae<-readOGR(dsn=WD, layer="Wine_amphorae")#Import wine amphorae
crs(Wine_amphorae) <- CRS('+init=EPSG:4326')#LatLong projection

Wine_amphorae_workshops<-readOGR(dsn=WD, layer="Wine_amphorae_workshops")#Import wine_amphorae_workshop
crs(Wine_amphorae_workshops) <- CRS('+init=EPSG:4326')#LatLong projection

Wineries_remains<-readOGR(dsn=WD, layer="Wineries_remains")#Import Wineries_remains
crs(Wineries_remains) <- CRS('+init=EPSG:4326')#LatLong projection

Biological_remains<-readOGR(dsn=WD, layer="Biological_remains")#Import Biological_remains
crs(Biological_remains) <- CRS('+init=EPSG:2154')#L93 projection
Biological_remains<-spTransform(Biological_remains, crs("+init=epsg:4326"))

###Plot all the shapefiles in the same view to check###
plot(Winemakers_tools, pch=8,  col= "red")
plot(Vine_planting_holes, col="Blue", add=T)
plot(Wine_amphorae, col="Purple", add=T)
plot(Wine_amphorae_workshops, add=T)
plot(Wineries_remains, col="yellow", add=T)
plot(Biological_remains, col="Green", add=T)
