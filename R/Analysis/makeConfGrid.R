#################### Load setup file
if(Sys.info()['user']=='janus829' | Sys.info()['user']=='s7m'){
	source('~/Research/lightsConflict/R/setup.R') }
####################	

#################### Data for plotting
confGrid = readOGR(path.expand(paste0(dPath,'Data/Shapefiles')), layer='ACLED_GIS_2015')
####################

#################### Plot
plot(confGrid)
####################