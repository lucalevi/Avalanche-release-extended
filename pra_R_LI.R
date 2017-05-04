# PRA definition by Jochen Veitinger 2015
# New features by Luca Iacolettig 2016-2017

#### User-defined parameters ####

## Directories ##
# Common directory path
# You will use a similar directory to load and save your files, maybe...
commonPath = "D:/Progetti/Valanghe/GIS/workspace/Canin"

# Input raster #
# "...[path].../nameofDTM.asc"
inputRas = file.path(commonPath, "dtm/canin10.asc")

# Forest mask #
forest = file.path(commonPath, "forest/forest10.asc")

# Working directory #
# To save intermediate results
work_dir = file.path(commonPath, "ModelOutput/20170205")

# SAGA GIS path
# SAGA directory
SAGApath = "D:/Progetti/Valanghe/Programmi/Tool_ArcGIS_PRA/PRA_definition/SAGA-GIS"

# SAGA modules
SAGAmodules = "D:/Progetti/Valanghe/Programmi/Tool_ArcGIS_PRA/PRA_definition/SAGA-GIS/modules"

## Model parameters ##
# Snow depth in [m] #
HS = 0.8		

# Snowpack stability #
# Type 1, 2, 3, 4 or 5 to define snowpack stability degree (1 stable, 5 unstable)
sStability = 3 

# More hazardous aspect #
# Type "N", "S", "E", "W" to define an higher snowpack stability degree to different aspects
# Type "KD" if snowpack stabilty is the same at every aspect 
sWhere = "N"	

# Smoothing degree # 
# Type "Regular" or "Low" to define degree of terrain smoothing (see manual of Veitinger)
# "Low"  for low snow distribution, e.g. little wind influence		
smooth = "Regular" 		

# Wind direction in [degrees] #
# N= 0, W =90, S=180
wind = 45 		
windTol = 30		# wind tolerance in [degrees]

# Altitude limits for wind effect #
zWind1 = 1500		# altitude limit, above which wind effects do matter
zWind2 = 1300		# altitude limit, under which wind effects do not matter

# Snow cover limits in [m] above sea level #
sLimN = 700			# northern aspects
sLimE = 800			# eastern aspects
sLimS = 900			# southern aspects
sLimW = 800			# western aspects

# Altitude limits for avalanche hazard #
# These limits provide the buffer dimension for the height fuzzy membership function
zLim1 = 1700		# upper limit: above zLim1 there is avalanche hazard
zLim2 = 1300		# lower limit: under zLim2 there is not avalanche hazard 
zwhere = "Above"	# type "Above" or "Under" to define if avalanche increases above or under the altitudes limits zLim1 and zLim2

# Name of output raster #
# outPRA = "PRA_fuzzy.asc"	
PRA_param <- paste(
	"Snow depth [m]",
	HS,
	"Snowpack stability degree",
	sStability,
	"More hazardous aspects",
	sWhere,
	"Smoothing degree",
	smooth,
	"Wind direction",
	wind,
	"Wind tolerance",
	windTol,
	"Altitude limits for wind effect [m]",
	zWind1,
	zWind2,
	"Snow cover limits in [m] above sea level (N,E,S,W)" ,
	sLimN,
	sLimE,
	sLimS,
	sLimW,
	"Altitude limits for avalanche hazard [m]",
	zLim1,
	zLim2,
	zwhere,
	"Forest mask",
	forest,
	"Working directory",
	work_dir,
	sep = "\t"
	)
outPRA <- paste("PRA", sep = " ")


#### Using R libraries ####
# Remember to install in R the following libraries before running the algorithm!
print("Loading libraries...")

library(sp)
library(gstat)
library(shapefiles)
library(foreign)
library(methods)

library(plyr)
#library(rgdal)
library(raster)
library(RSAGA)
#library(maptools)


####  Preliminary calculations ####
# Let's run!

# Working environment
myenv = rsaga.env(workspace = work_dir,
                  path = SAGApath,
                  modules = SAGAmodules)

setwd(work_dir)

# Coordinate reference system
# epsg:3004 is Gauss-Boaga projection, fuse E
sr = CRS("+init=epsg:3004")

print("Begin Calculations...")

# Input raster
asc <- raster(inputRas)
asc.extent <- extent(asc)
asc.res <- res(asc)
head <- read.ascii.grid.header(inputRas)
writeRaster(asc, "outputRas", format = "SAGA", overwrite = TRUE)

####  Experimental function to relate snow depth with scale ####
if (smooth == "Regular") {
  cv = 0.35
} else {
  cv = 0.2
}

i_max = 2 * ceiling(HS ^ 2 * cv) + 1

#### Windshelter index ####

# DTM for windshelter calculation
windRaster <- aggregate(asc, fact = 5, expand = TRUE)

# Wind raster
if (i_max > 2) {
	windRaster_new <- aggregate(asc, fact = 2 * i_max, expand = TRUE)
	windRaster <-
	resample(windRaster_new, windRaster, method = "bilinear")
}

writeRaster(
	windRaster,
	"windRaster",
	format = "ascii",
	datatype = 'FLT4S',
	overwrite = TRUE
)

# Calculate windshelter index
ctrl = wind.shelter.prep(5, (wind * pi) / 180, (windTol * pi) / 180 , 2 * i_max)

focal.function(
  "windRaster.asc",
  fun = wind.shelter,
  prob = 0.5,
  control = ctrl,
  radius = 5,
  search.mode = "circle"
)

f <- list.files(pattern = 'windshelter.asc$', full.names = TRUE)
windshelter <- raster(f)
windshelter <- resample(windshelter, asc, method = "bilinear")

#### Ruggedness ####
# Calculate at different scales
for (i in 1:i_max) {
	# Calculate slope and aspect
	slope_name <- paste("slope", i, sep = "")
	aspect_name <- paste("aspect", i, sep = "")

	rsaga.geoprocessor(
		"ta_morphometry",
		23,
		env = myenv,
		list(
			  DEM = "outputRas.sgrd",
			  SLOPE = slope_name,
			  ASPECT = aspect_name,
			  SIZE = i,
			  TOL_SLOPE = "1.00000",
			  TOL_CURVE = "0.000100",
			  EXPONENT = "0.00000",
			  ZSCALE = "1.000000",
			  CONSTRAIN = FALSE
		)
	)

	rsaga.sgrd.to.esri(
		slope_name,
		slope_name,
		format = "ascii",
		georef = "corner",
		prec = 2
	)

	rsaga.sgrd.to.esri(
		aspect_name,
		aspect_name,
		format = "ascii",
		georef = "corner",
		prec = 2
	)

	# Create raster object of slope raster
	f <- list.files(pattern = paste(slope_name, ".asc$", sep = ""),
					full.names = TRUE)
	slope <- raster(f)

	f <- list.files(pattern = paste(aspect_name, ".asc$", sep = ""),
					full.names = TRUE)
	aspect <- raster(f)

	# Convert to radians
	slope_rad <- slope * pi / 180
	aspect_rad <- aspect * pi / 180

	# Calculate xyz components
	xy_raster <- sin(slope_rad)
	z_raster <- cos(slope_rad)
	x_raster <- sin(aspect_rad) * xy_raster
	y_raster <- cos(aspect_rad) * xy_raster

	xsum_raster <- focal(x_raster, w = matrix(1, 3, 3), fun = sum)
	ysum_raster <- focal(y_raster, w = matrix(1, 3, 3), fun = sum)
	zsum_raster <- focal(z_raster, w = matrix(1, 3, 3), fun = sum)

	result_raster <- sqrt((xsum_raster) ^ 2 + (ysum_raster) ^ 2 + (zsum_raster) ^ 2)

	ruggedness_raster <- (1 - (result_raster / 9))
	rugg_name <- paste("ruggedness", i, sep = "")

	writeRaster(ruggedness_raster,
	          rugg_name,
	          format = "ascii",
	          overwrite = TRUE)
}

# Correction of snow surface roughness with slope
f <- list.files(pattern = paste("ruggedness", i_max, ".asc$", sep = ""),
            	full.names = TRUE)
rugg <- raster(f)

if (i_max > 1) {
	f <- list.files(pattern = paste("slope", i_max, ".asc$", sep = ""),
	          		full.names = TRUE)

	slp_coef <- as.matrix(raster(f))
	slp_coef <- 1 - ((slp_coef - 30) / 30)
	slp_coef[slp_coef < 0] <- 0
	slp_coef[slp_coef > 1] <- 1
	slp_coef <- 1 + (slp_coef * (i_max - 1))
	slp_coef <- round(slp_coef, digits = 0)

	for (i in 1:(i_max - 1)) {
		f <- list.files(pattern = paste("ruggedness", i, ".asc$", sep = ""),
		            	full.names = TRUE)
		rugg_i <- raster(f)
		rugg[which(slp_coef == i)] <- rugg_i[which(slp_coef == i)]
	}
}

#### Definition of membership functions #####

# Bell curve parameters for ruggedness #
a <- 0.01
b <- 5
c <- -0.007

# Membership function for ruggedness
rugg1 <- 1 / (1 + ((rugg - c) / a) ^ (2 * b))

# Uncomment following line, if you want 0 values under ruggedness = 0.01
# rugg1[rugg > 0.01] <- 0

# Bell curve parameters for slope #
# Snowpack stability varies according to aspect
asp <- aspect

if (sWhere == "N") {
	asp[asp <= 45] <- 1
	asp[asp > 45] <- 0
	asp[asp >= 315] <- 1
} else if (sWhere == "S") {
	asp[asp > 0] <- 0
	asp[asp >= 135] <- 1
	asp[asp > 225] <- 0
} else if (sWhere == "E") {
	asp[asp > 0] <- 0
	asp[asp >= 45] <- 1
	asp[asp > 135] <- 0
} else if (sWhere == "W") {
	asp[asp > 0] <- 0
	asp[asp >= 225] <- 1
	asp[asp > 315] <- 0
}

# Curve parameters
c <- 40

if (sStability <= 4) {
	a <- 8
	b <- 3
} else {
	a <- 13
	b <- 5 
}


# Function numerator changes according to snowpack stability degree sStability
param_switch <- function(i) {
  switch(i,
         0.2,		# sStability = 1
         0.5,		# sStability = 2
         0.9,		# sStability = 3
         1,			# sStability = 4
         1)			# sStability = 5
}

# Function numeratore for the choosen sStability
num = param_switch(sStability)				
if (sStability <= 4) {
	# an higher snowpack stability degree
	num2 = param_switch(sStability + 1)		
} else {
	# if sStability = 5, do nothing
	num2 = num								
}

# Create a copy matrix of zeros
slopeMatrix <- as.matrix(slope)
slope1 <- matrix(0,
         ncol = ncol(slopeMatrix),
         nrow = nrow(slopeMatrix))

# Aspect matrix
asp <- as.matrix(asp)
asp[is.na(asp)] <- 0

# Calculate memberhip function for slope
# It varies among aspects with different snowpack stability
for (j in 1:ncol(asp)) {
  for (i in 1:nrow(asp)) {
    if (asp[i, j] == 0) {
      slope1[i, j] <- num / (1 + ((slopeMatrix[i, j] - c) / a) ^ (2 * b))
    } else {
      slope1[i, j] <- num2 / (1 + ((slopeMatrix[i, j] - c) / a) ^ (2 * b))
    }
  }
}

# Uncomment following lines if:
# there are not avalanches under 25 and above 60 degrees
# slope1[slope < 25] <- 0			
# slope1[slope > 60] <- 0		

# Create a raster of fuzzy memberhip of slope
slope1 <- raster(slope1)
extent(slope1) <- asc.extent
res(slope1) <- asc.res[1]

writeRaster(slope1,
            "fuzzy_slope",
            format = "ascii",
            overwrite = TRUE)

# Bell curve parameters for windshelter #
a <- 2
b <- 5
c <- 2

windshelter <- 1 / (1 + ((windshelter - c) / a) ^ (2 * b))

# Windshelter index weighting
# Random numbers 
set.seed(1872)

# Data for linear regression
x <- c(zWind2, zWind1)
y <- c(0, 1)
df <- data.frame(x, y)

# Linear regression model
lrm <- lm (y ~ x, data = df)
q <- lrm$coef[1]
m <- lrm$coef[2]

# Fuzzy function to weight windshelter
windWeight <- m * asc + q
windWeight[windWeight < 0] <- 0
windWeight[windWeight > 1] <- 1

# Weight windshelter index
windshelter <- windshelter * windWeight

# Windshelter raster
writeRaster(windshelter,
            "fuzzy_windshelter",
            format = "ascii",
            overwrite = TRUE)

#### Fuzzy logic operator ####

minvar <- min(slope1, rugg1, windshelter)
gamma <- (1 - minvar)

PRA <- gamma * minvar + ((1 - gamma) * (slope1 + rugg1 + windshelter)) /  3

# Membership function for height #
# Random numbers generation
set.seed(3872)

# Data
x <- c(zLim2, zLim1)
if (zwhere == "Under") {
	y <- c(1, 0)
} else {
	y <- c(0, 1)
}
df <- data.frame(x, y)

# Linear regression model
lrm <- lm (y ~ x, data = df)
q <- lrm$coef[1]
m <- lrm$coef[2]

# Fuzzy linear function for height
height <- m * asc + q
height[height < 0] <- 0
height[height > 1] <- 1

# Height raster
writeRaster(height,
            "fuzzy_height",
            format = "ascii",
            overwrite = TRUE)

# Weighting PRA raster with height
PRA <- PRA * height

# Forest mask #
# Uncomment following lines if you would use a forest mask
forest <- raster(forest)
PRA <- crop(PRA, forest)
PRA <- PRA * (1-forest)

# Snow cover mask #
# Create a matrix of zeros
snowlim <- matrix(0, ncol = ncol(asc), nrow = nrow(asc))	
asp <- as.matrix(aspect)
asp[is.na(asp)] <- 0

# An efficient function for the following calculations
fun <- function(a, b) {
	tmp = 0.00	# temporary value
	if(a >= b){
		tmp <- 1.00
	}
	return(tmp)
}

# Raster matrix
ascMatrix <- as.matrix(asc)
ascMatrix[is.na(ascMatrix)] <- 0

# Calculate snow limit accoring to aspect:
# the previous function is being used
for(j in 1:ncol(asp)){
	for(i in 1:nrow(asp)){
		if(asp[i,j] >= 315 | asp[i,j] < 45 ){
			snowlim[i,j] <- fun(ascMatrix[i,j], sLimN)
		} else if(asp[i,j] >= 45 & asp[i,j] < 135 ) {
			snowlim[i,j] <- fun(ascMatrix[i,j], sLimE)
		} else if(asp[i,j] >= 135 & asp[i,j] < 225 ) {
			snowlim[i,j] <- fun(ascMatrix[i,j], sLimS)
		} else if(asp[i,j] >= 225 & asp[i,j] < 315 ) {
			snowlim[i,j] <- fun(ascMatrix[i,j], sLimW)
		}
	}
}

# Snow cover raster
snowlim <- raster(snowlim)
extent(snowlim) <- asc.extent
res(snowlim) <- asc.res[1]

writeRaster(snowlim, "snowlim", format = "ascii", overwrite = TRUE)

# Exclude cells without snow
PRA <- PRA * snowlim

# Final raster #
print("Raster of Potential Release Areas")
PRA.expand <- extend(PRA, asc.extent, value = NA)

# Project raster
proj4string(PRA.expand) <- sr
writeRaster(PRA.expand, outPRA, format = "ascii", overwrite = TRUE)


#### Dangerous steep slopes ####
# Extract PRA > 0.50
PRA.expand[PRA.expand >  0.50] <- 1
PRA.expand[PRA.expand <= 0.50] <- 0

# name of PRA binary raster
outPRA_bin <- paste(outPRA, 
					"binary", 
					#PRA_param, 
					sep = "_"
)

# PRA binary raster	
# Project raster
proj4string(PRA.expand) <- sr
writeRaster(PRA.expand,
            outPRA_bin,
            format = "ascii",
            overwrite = TRUE)

# Calculate PRA area over total DTM area
# exclude NA values at borders
PRA1 <- PRA.expand
PRA1[is.na(PRA1)] <- 0

# crop slope by PRA extent
slope2 <- slope

# Select steep slopes: 0 no steep, 1 steep
# Here, steep slopes are between 30 and 60 degrees
slope2[slope2 >= 60.00] <- 0
slope2[slope2 <  30.00] <- 0
slope2[slope2 >= 30.00] <- 1

# Only steep slopes with snow
slope2 <- slope2 * snowlim		

# Without forest
slope2 <- crop(slope2, forest)
slope2 <- slope2 * (1-forest)

# Convert everything to a matrix
PRA1 <- as.matrix(PRA1)
slope2 <- as.matrix(slope2)

# Artificial NA values removing
PRA1[is.na(PRA1)] <- 0
slope2[is.na(slope2)] <- 0

# Sum the 1s
# PRA1 has 1 only in PRA cells
# slope2 has 1 only in steep slopes
PRA_sum <- sum(PRA1)
slp_sum <- sum(slope2)

# Ratio between PRA and steep slopes areas
# Provide the percent with 2 decimal digits
percent <- (PRA_sum / slp_sum) * 100
percent <- round(percent, digits = 2)

print("Percent of snowy steep slopes affected by PRAs [%]")
print(percent)

# Write data
data <- c(inputRas, PRA_param, "Percent of snowy steep slopes affected by PRAs [%]", percent)
write(data, file.path(work_dir, "Data.txt"))


print("Calculations complete!")

# Compliments, my friend: this is the code ending.
# Enjoy it! :)

# Luca Iacolettig
# 2017.02.08