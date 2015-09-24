#################### Load setup file
if(Sys.info()['user']=='janus829' | Sys.info()['user']=='s7m'){
	source('~/Research/lightsConflict/R/setup.R') }
####################	

#################### Fortify africa shape file
# Get africa shapefile
africa = readOGR(path.expand(paste0(dPath,'Data/AfricanCountries')), layer='AfricanCountires')

# Create fortified version of africa shapefile
gpclibPermit()
cntries = africa@data$COUNTRY %>% unique() %>% data.frame(cntry=.)
cntries$code = 1:nrow(cntries)
africa@data$id = cntries$code[match(africa@data$COUNTRY, cntries$cntry)]
ggAfrica = fortify(africa, region='id')
####################	

#################### Save
save(ggAfrica, file=paste0(dPath,'Data/AfricanCountries/africa.rda'))
####################	