#################### Load setup file
if(Sys.info()['user']=='janus829' | Sys.info()['user']=='s7m'){
	source('~/Research/lightsConflict/R/setup.R') }
####################

#################### Data for plotting
# Get africa shapefile
africa = readOGR(path.expand(paste0(dPath,'Data/AfricanCountries')), layer='AfricanCountires')
load( paste0(dPath,'Data/nighttimeLightComp/satAll.rda') )
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