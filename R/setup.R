# Clear workspace
rm(list=ls())

# Set paths
if(Sys.info()['user']=='janus829' | Sys.info()['user']=='s7m'){
	dPath= '~/Dropbox/Research/lightsConflict/'
	gPath= '~/Research/lightsConflict/'
}

# General functions/libraries
loadPkg=function(toLoad){
	for(lib in toLoad){
	  if(!(lib %in% installed.packages()[,1])){ 
	    install.packages(lib, repos='http://cran.rstudio.com/') }
	  library(lib, character.only=TRUE)
	}
}

toLoad=c(
	'ggplot2', 'reshape2', 'RColorBrewer',
	'magrittr',
	'rgdal', 'raster', 'rasterVis', 'maptools', 'mapproj'
	)
loadPkg(toLoad)

# Set a theme for gg
theme_set(theme_bw())