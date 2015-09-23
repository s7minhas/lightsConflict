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
mapNames = nightMaps %>% strsplit(.,'/') %>% lapply(., function(x) x[7]) %>% unlist()
mapNames = setdiff(mapNames, 'satAll.rda')
####################

#################### Data for plotting
# Get africa shapefile
africa = readOGR(path.expand(paste0(dPath,'Data/AfricanCountries')), layer='AfricanCountires')

# Crop raster file to africa region
aoi = c(-20,50,-40,40) 

# Get maps and rasterize/crop
if( !file.exists( paste0(dPath,'Data/nighttimeLightComp/satAll.rda') ) ){
	satAll = lapply(nightMaps, function(x){
		data = raster(x)
		slice = crop(data, aoi)
		return(slice) })
	save(satAll, file=paste0(dPath,'Data/nighttimeLightComp/satAll.rda'))
} else { load( paste0(dPath,'Data/nighttimeLightComp/satAll.rda') ) }
####################

#################### Plot and save
# Raster coloring
cols=c('#969696', brewer.pal(9, 'YlOrRd')[c(1,3,5,7)])
rasTheme = rasterTheme(region=cols)
rasTheme$regions$col = rasTheme$regions$col[c(1,25:100)]

# Levelplot
for(ii in 1:length(satAll)){
	lights = levelplot(satAll[[ii]], par.settings=rasTheme, 
		main=list(label=substr(mapNames[ii], 4, 7), cex=4.375),
		xlab=list(label='Latitude', cex=4.375),
		ylab=list(label='Longitude', cex=4.375)
		)
	lights = lights + layer(sp.lines(africa, lwd=0.5, col='white'))
	jpeg(file=paste0(dPath, 'Graphics/satLight/',mapNames[ii], '.jpg'), width=1900, height=1900)
	print( lights )
	dev.off()
}

# Turn into gif
setwd(paste0(dPath, 'Graphics/satLight/'))
system("convert -delay 50 -quality 60 *.jpg satLight.gif")
####################