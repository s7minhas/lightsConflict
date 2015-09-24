#################### Load setup file
if(Sys.info()['user']=='janus829' | Sys.info()['user']=='s7m'){
	source('~/Research/lightsConflict/R/setup.R') }
####################

#################### Get path names for data
nightDir = paste0(dPath,'Data/nighttimeLightComp/')
nightSubDir = list.files( nightDir )
nightMaps = NULL
for(ii in 1:length(nightSubDir)){
	map = list.files( paste0(nightDir, nightSubDir[ii]) )[1]
	mapPath = paste0(nightDir, nightSubDir[ii], '/', map)
	nightMaps = append(nightMaps, mapPath)
}
nightMaps = nightMaps[!grepl('satAll.rda', nightMaps)]
mapNames = nightMaps %>% strsplit(.,'/') %>% lapply(., function(x) x[7]) %>% unlist()
####################

#################### Process data
# Crop raster file to africa region
aoi = c(-20,50,-40,40) 

# Get maps and rasterize/crop
cl = makeCluster(4)
registerDoParallel(cl)
satAll = foreach(x = nightMaps, .packages=c('raster', 'magrittr')) %dopar% {
	data = raster(x) %>% crop(., aoi) %>% replaceVal(.,0,NA) %>% rasterToPoints(.) %>% data.frame()
	colnames(data) <- c("Longitude", "Latitude", "Lights")
	return(data)
}

# Free my clusters
stopCluster(cl)
####################

#################### Save
save(mapNames, satAll, file=paste0(dPath,'Data/nighttimeLightComp/satAll.rda'))
####################