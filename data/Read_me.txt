These files are linked to the article Bernigaud et al. 2021
"Understanding The Developement Of Viticulture In Roman Gaul During And After The Roman Climate Optimum: The Contribution Of Spatial Analysis and Agro-Ecosystem Modeling"
JAS: reports

-folder R_scripts:

	1-Predictive_model_roman_vineyards : by this R script you can redo the predictive model for roman vineyards (for this you need to import the shapefiles and rasters listed bellow)
	2-Script_Kgain : you can redo by this script the Kvamme's gain statistical test

	For running theses scripts you need to download the free R software: https://cran.r-project.org/bin/windows/base/

-folder SHAPEFILES:

5 shapefiles and 1 raster necessary for predictive model (work with R script "Predictive_model_roman_vineyards"):

	3- roman_roads_v2008 : https://docs.google.com/file/d/0B4KitLDpLpYfN3hKM3E2YWltWm8/edit
	4- MNT90m_l931 : Digital Elevation Model from SRTM product (90 m resolution): http://srtm.csi.cgiar.org/srtmdata/
		Raster processed by the assemblage of 9 tiles (srtm_36_02, 37_02, 38_02, 36_03, 37_03, 38_03, 36_04, 37_04, 38_04)
	5- Europe_coastline.shp :  https://www.eea.europa.eu/data-and-maps/data/eea-coastline-for-analysis-1/gis-data/europe-coastline-shapefile
	6- Europe_Hydrography.shp: https://www.eea.europa.eu/data-and-maps/data/wise-large-rivers-and-large-lakes
	7- Capitals_of_cities.shp: shapefile of capitals of cities in Gaul made by P. Ouzoulias (CNRS)
	8- France.shp: administrative boundaries of France from GEOFLA(IGN): 

5 shapefiles of archaeological data about winemaking (Fig. 4 in the article):

	9-Winemaker_tools.shp: shapefile of roman winemaker tool. Most of the data for Gaul came from the database Outagr http://outagr.huma-num.fr/Outagr/
	10-Biological_remains.shp: shapefile with discoveries of remains of vine (grape seeds essentialy). Most of the data are taken from:
		->"Viticulture et viniculture dans le nord du bassin parisien d'après les données archéobotaniques" (Zech-Matterne et al. 2011).
		->"La vigne et les débuts de la viticulture en France : apports de l'archéobotanique" (Bouby et Marinval 2001) https://www.persee.fr/doc/galia_0016-4119_2001_num_58_1_3171
	11-Wine_amphorae.shp : discoveries of wine amphorae
	12-Wine_amphorae_workshop.shp : discoveries of roman amphora kilns
	13-Vine_planting_holes.shp : discories of planting holes of roman vineyards
	14-Winerie_remains.shp : discoveries of villae with dolia for wine

	data of 9-10-11-12 shapefiles are mainly extracted of:
		->La viticulture en Gaule (Brun et Laubenheimer 2001) : https://gallia.cnrs.fr/publications/gallia/58-1/
		->La vigne et le vin dans les Trois Gaules (Poux, Brun, Hervé-Monteil 2011), revue Gallia 68.1

	15-viticulture_testimony3.shp: in this shapefile, all the data of 9-14 are merged. This file works with the R Script_Kgain
	
Other files:

	16-reclim2_co2: this R files contains the big climatic reconstruction made by J. Guiot for all the Holocene in Europe (Guiot et Kaniewski 2015)
		-> These data are associated with the article "The Mediterranean Basin and Southern Europe in a warmer world: what can we learn from the past?" https://www.frontiersin.org/articles/10.3389/feart.2015.00028/full

	17-Predictive_model.tiff : this predictive model is processed by the R script Predictive_model_roman_vineyards (see folder R_scripts)

	

	
	


