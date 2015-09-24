#################### Load setup file
if(Sys.info()['user']=='janus829' | Sys.info()['user']=='s7m'){
	source('~/Research/lightsConflict/R/setup.R') }
####################

#################### Data for plotting
# Get africa shapefile
africa = readOGR(path.expand(paste0(dPath,'Data/AfricanCountries')), layer='AfricanCountires')

# Light data
load(paste0(dPath,'Data/nighttimeLightComp/satAll.rda')) # adds object named satAll & mapNames

# acled shape file
map = readOGR(path.expand(paste0(dPath,'Data/acled_with_prio')), layer='acled_v3_with_PRIOGRID')

yrs = attributes(map)$'data'$YEAR %>% unique() %>% sort()
confYr = lapply(yrs, function(yr){
	return( map[map$YEAR==yr,] ) })
####################

#################### Plot and save
# Colors
confColor = brewer.pal(9, 'Reds')[c(1,5,9)]
lightColor = brewer.pal(9, 'Blues')[c(1,5,9)]

for(ii in 1:length(mapNames)){
	tmp = ggplot()
	# Add africa lines
	tmp=tmp + geom_polygon(data=africa, aes(x=long, y=lat, group=group), fill='white')
	tmp=tmp + geom_path(data=africa, aes(x=long, y=lat, group=group), colour = "lightgrey", lwd = .1)
	# Add lights
	tmp=tmp + geom_raster(data=satAll[[ii]], aes(fill=Lights,y=Latitude, x=Longitude))	
	tmp=tmp + scale_fill_gradient2(low=lightColor[1],mid=lightColor[2],high=lightColor[3], limits=c(0,60))
	# Add conflict points
	confYr[[ii]]@data$Deaths = log( confYr[[ii]]@data$FATALITIES + 1 ) # Log fatality data
	tmp=tmp + geom_point(data=confYr[[ii]]@data, aes(x=LONGITUDE,y=LATITUDE,color=Deaths), size=1, alpha=.5)
	tmp=tmp + scale_colour_gradient2('Log(Deaths)',low=confColor[1],mid=confColor[2],high=confColor[3], limits=c(0,10))
	# Cleanup
	tmp=tmp + xlab('Latitude') + ylab('Longitude') + xlim(-20,55) + ylim(-35,37) + ggtitle(yrs[ii])
	tmp=tmp + theme(
			panel.background=element_blank(), panel.grid=element_blank(),
			axis.ticks=element_blank(),
			legend.position='right' )
	ggsave(plot=tmp, filename=paste0(dPath, 'Graphics/maps/LC',yrs[ii], '.jpg'))
}

# Turn into gif
setwd(paste0(dPath, 'Graphics/maps/'))
system("convert -delay 50 -quality 60 *.jpg lightsConflict.gif")
####################