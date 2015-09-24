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
	'ggplot2', 'reshape2', 'RColorBrewer', # shaping/plotting
	'magrittr', # coding niceties
	'rgdal', 'raster', 'rasterVis', 'maptools', 'mapproj', # spatial
	'foreach', 'doParallel' # parallelization
	)
loadPkg(toLoad)

# Set a theme for gg
theme_set(theme_bw())

# Helpful functions
replaceVal = function(obj, value, newValue){ obj[obj==value] <- newValue; return(obj) }
char = function(x){ as.character(x) }
num = function(x){ as.numeric(char(x)) }