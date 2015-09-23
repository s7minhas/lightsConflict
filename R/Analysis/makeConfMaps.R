#################### Load setup file
if(Sys.info()['user']=='janus829' | Sys.info()['user']=='s7m'){
	source('~/Research/lightsConflict/R/setup.R') }
####################	

#################### Data for plotting
# Get africa shapefile
africa = readOGR(path.expand(paste0(dPath,'Data/AfricanCountries')), layer='AfricanCountires')

# Create fortified version of africa shapefile
if( !file.exists( paste0(dPath,'Data/AfricanCountries/africa.rda') ) ){
	gpclibPermit()
	cntries = africa@data$COUNTRY %>% unique() %>% data.frame(cntry=.)
	cntries$code = 1:nrow(cntries)
	africa@data$id = cntries$code[match(africa@data$COUNTRY, cntries$cntry)]
	ggAfrica = fortify(africa, region='id')
	save(ggAfrica, file=paste0(dPath,'Data/AfricanCountries/africa.rda'))
	} else { load( paste0(dPath,'Data/AfricanCountries/africa.rda') ) }

# acled shape file
map = readOGR(path.expand(paste0(dPath,'Data/acled_with_prio')), layer='acled_v3_with_PRIOGRID')
####################

#################### Plot and save
# break up conflict data by year
yrs = attributes(map)$'data'$YEAR %>% unique() %>% sort()
confYr = lapply(yrs, function(yr){
	return( map[map$YEAR==yr,] )
	})

# Plot with gg
# Colors
confColor = brewer.pal(9, 'YlOrRd')[c(1,5,9)]
for(ii in 1:length(confYr)){
	# Log fatality data
	confYr[[ii]]@data$lnDeath = log( confYr[[ii]]@data$FATALITIES + 1 )
	confs = ggplot() + geom_polygon(data=africa, aes(x=long, y=lat, group=group), fill='#969696') + geom_path(colour = "white", lwd = 0.5)
	confs = confs + coord_map() + xlab('Latitude') + ylab('Longitude') + xlim(-20,55) + ylim(-35,37) + ggtitle(yrs[ii])
	confs = confs + geom_point(data=confYr[[ii]]@data, aes(x=LONGITUDE,y=LATITUDE,color=lnDeath), size=1)
	confs = confs + scale_colour_gradient2(low=confColor[1],mid=confColor[2],high=confColor[3])
	confs = confs + theme(
		panel.background=element_blank(), panel.grid=element_blank(),
		axis.ticks=element_blank(),
		legend.position='bottom', legend.title=element_blank() )
	ggsave(plot=confs, filename=paste0(dPath, 'Graphics/conflict/conf',yrs[ii], '.jpg'))
}

# Turn into gif
setwd(paste0(dPath, 'Graphics/conflict/'))
system("convert -delay 50 -quality 60 *.jpg conflict.gif")
####################