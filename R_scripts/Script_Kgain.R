require(raster)
require(rgdal)

### set working directory
WD<-setwd("C:/Users/Bernigaud Nicolas/Dropbox/Article_JAS_Reports_2021/Revision_JAS_reports/DATA/Shapefiles")

###Import shapefile with all archaeological data on viticulture###
Viticulture <- readOGR (dsn = WD, layer = "viticulture_testimony3")
Modele_predictif_vigne_4 <- raster ("Predictive_model.tif")

###Extract value FROM the predictive model TO the points of archaeological data####

Extract_values_PM<-extract(Modele_predictif_vigne_4, Viticulture)
Extract_values_PM[is.na(Extract_values_PM[])] <- 0 
Sites_Number<-as.vector(table(... = Extract_values_PM))###number of sites / predictive model value (0-5)

###Create a dataframe with count of sites and pixels for a given predictive value (0-5), and the Kgain###

Contingence<-freq(Modele_predictif_vigne_4, useNA='no', merge = TRUE)
vecteur1 <- c(0:5)
tableau <- data.frame("Probability level" = vecteur1, "count" = Contingence[,2], "Area Percentage" = NA, "Sites number"=Sites_Number, "Number percentage"= NA, "Kgain"=NA)
Total<-sum(tableau[,2])
Sum_sites<-sum(Sites_Number)

for (i in 1:6) { ###Calculate area percentage
tableau[i,3]<-tableau[i,2]*100/Total
}

for (i in 1:6) {###Calculate sites percentage
  tableau[i,5]<-tableau[i,4]*100/Sum_sites
}

for (i in 1:6) {
  tableau[i,6]<-1-tableau[i,3]/tableau[i,5]###Calculate Kgain (= 1 - Area_percentage/Sites percentage)
}

write.csv(tableau, "C:/Users/Bernigaud Nicolas/Dropbox/Article_JAS_Reports_2021/Revision_JAS_reports/DATA/Tableau.csv")