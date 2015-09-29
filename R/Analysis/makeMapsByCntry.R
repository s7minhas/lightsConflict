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

# Loop params
cntries = africa@data$COUNTRY %>% unique() %>% char()
cntries = c('Algeria', 'Nigeria', 'South Africa')

for(cntry in cntries){
	slice = africa[africa$COUNTRY == cntry,]
	dims = extent(slice) %>% as.vector()
	for(ii in 1:length(mapNames)){
		tmp = ggplot()
		# Add africa lines
		tmp=tmp + geom_polygon(data=slice, aes(x=long, y=lat, group=group), fill='white')
		tmp=tmp + geom_path(data=slice, aes(x=long, y=lat, group=group), colour = "lightgrey", lwd = .3)
		# Add lights
		tmp=tmp + geom_raster(data=satAll[[ii]], aes(fill=Lights,y=Latitude, x=Longitude))	
		tmp=tmp + scale_fill_gradient2(low=lightColor[1],mid=lightColor[2],high=lightColor[3], limits=c(0,60))
		# Add conflict points
		confYr[[ii]]@data$Deaths = log( confYr[[ii]]@data$FATALITIES + 1 ) # Log fatality data
		tmp=tmp + geom_point(data=confYr[[ii]]@data, aes(x=LONGITUDE,y=LATITUDE,color=Deaths), size=1, alpha=.5)
		tmp=tmp + scale_colour_gradient2('Log(Deaths)',low=confColor[1],mid=confColor[2],high=confColor[3], limits=c(0,10))
		# Cleanup
		tmp=tmp + xlab('Latitude') + ylab('Longitude') + ggtitle(paste0(cntry, ', ', yrs[ii]))
		# Limit to selected cntry
		tmp=tmp + xlim(dims[1], dims[2]) + ylim(dims[3], dims[4])	
		tmp=tmp + theme(
				panel.background=element_blank(), panel.grid=element_blank(),
				axis.ticks=element_blank(),
				legend.position='right' )
		ggsave(plot=tmp, filename=paste0(dPath, 'Graphics/',cntry,'/',yrs[ii], '.jpg'))
	}
	# Turn into gif
	setwd(paste0(dPath, 'Graphics/',cntry,'/'))
	bashCmd = paste0("convert -delay 50 -quality 60 *.jpg", " ", gsub(' ', '', tolower(cntry) ),"LightsConflict.gif")
	system(bashCmd)
}

####################