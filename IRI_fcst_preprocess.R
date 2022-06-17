#' ---
#' title: "Preprocessing IRI Raw Forecast"
#' author: "Ed Maurer"
#' date: "`r Sys.Date()`"
#' ---

#' Preprocess IRI forecast - reduce file dimensionality to three

#Raw data obtained from http://iridl.ldeo.columbia.edu/
#A single point may be extracted at:
#http://iridl.ldeo.columbia.edu/maproom/Global/Forecasts/NMME_Seasonal_Forecasts/Precipitation_ELR.html
#and used for checking output.

#' Install packages if needed
if (!require("ncdf4")) install.packages("ncdf4")
if (!require("lubridate")) install.packages("lubridate")

#' load required libraries
library(ncdf4)
library(lubridate)

#Reads in raw_data.nc file downloaded by download_IRI_seas_scst.sh
#Most common failure of download is a need to re-generate the auth key.

#' variable name prob has 5 dimensions: prob(F,L,C,Y,X)
#Tercile Classes
#grid: /C (ids) unordered [ (Below_Normal) (Normal) (Above_Normal)] :grid 
#Month Forecast Issued
#grid: /F (months since 1960-01-01) ordered (Feb 2017) to (current forecast month) by 1.0 N~ 60 pts :grid 
#Forecast Lead Time in Months
#grid: /L (months) ordered (1.0 months) to (4.0 months) by 1.0 N= 4 pts :grid 
#Longitude (longitude)
#grid: /X (degree_east) periodic (0) to (1W) by 1.0 N= 360 pts :grid 
#Latitude (latitude)
#grid: /Y (degree_north) ordered (90S) to (90N) by 1.0 N= 181 pts :grid 

seasons <- c("JFM","FMA","MAM","AMJ","MJJ","JJA","JAS","ASO","SON","OND","NDJ","DJF")

#' Check raw data file

# datadir <- file.path("Z:/projects/nicaragua/hydroclimate/seasonal_prediction/R-fcst")
#datadir <- file.path("C:/Users/Ed/Documents/projects/hydroclimate/seasonal_prediction/data")

datadir <- file.path("./")
mf <- file.path(datadir, "raw_data.nc")

#check downloaded data file for size and download date


download_dt <- as.Date(file.info(mf)$mtime)
if(download_dt < Sys.Date()) {
  ndays = length(seq(from = download_dt, to = Sys.Date(), by = "day"))
  if(ndays > 7) {
    message("Downloaded input file is over one week old -- check if current")
  }
}
if (file.info(mf)$size < 390000000 ) {
  stop("input file is too small to have valid seasonal forecast data")
}

#open file
nc <- nc_open(mf)
#atts <- ncatt_get(nc, attributes(nc$var)$names[1])

#' Find date most recent forecast was issued
fcstdates <- nc[['dim']]$F$vals
fcstdateunits <- nc[['dim']]$F$units
tstr <- unlist(strsplit(fcstdateunits, " ")[1]) #units ("months since YYYY-MM-DD)
if(tolower(tstr[1]) != "months") {
  stop("Time axis must have months as interval")
}
#extract partial month
extradays <- (fcstdates[length(fcstdates)] - as.integer(fcstdates[length(fcstdates)]))*30
origindate <- as.POSIXct(tstr[3],format="%Y-%m-%d")
fcstdate <- origindate %m+% months(as.integer(fcstdates[length(fcstdates)]))
fcstdate <- fcstdate %m+% days(as.integer(extradays)-1)

#' get dimensions from raw data file
lon <- nc[['dim']]$X$vals
lonunits <- nc[['dim']]$X$units
lat <- nc[['dim']]$Y$vals
latunits <- nc[['dim']]$Y$units
terc <- c(1,2,3)
tercunits <- 'tercile'
# define dimensions
londim <- ncdim_def("lon", lonunits, as.double(lon))
latdim <- ncdim_def("lat", latunits, as.double(lat))
tercdim <- ncdim_def("tercile", tercunits, as.double(terc))

#' Extract data for a single forecast and lead time
vn <- 'prob'
x <- ncvar_get(nc,vn)
#extract only the most recent forecast that was issued
n_months <- dim(x)[5]
#use forecasts for 1-4 months ahead - save each to independent file
leads <- c(1,2,3,4)
for (lead in leads) {
  fcst <- x[,,,lead,n_months]
  #same thing would be produced using  
  #fcst <- ncvar_get(nc,vn, start = c(1,1,1,lead,n_months), count = c(-1,-1,-1,1,1))
  
  # Create a new file with only the last forecast issued for current lead
  # define variables
  varname="prob"
  units="percent"
  dlname <- "tercile_probabilities"
  fillvalue <- 1e20
  tmp.def <- ncvar_def(varname, units, list(londim, latdim, tercdim), fillvalue, 
                       dlname, prec = "single")
  # create a netCDF file 
  ncfname <- paste0("IRI_prob_fcst_", as.character(fcstdate),"_lead_",lead,".nc")
  ncout <- nc_create(ncfname, list(tmp.def))
  # put the array into the file
  ncvar_put(ncout, tmp.def, fcst)
  # add additional attributes into dimension and data variables
  ncatt_put(ncout, "lon", "axis", "X")  
  ncatt_put(ncout, "lat", "axis", "Y")
  ncatt_put(ncout, "prob", "lead", lead)
  season_forecast <- month(fcstdate) + lead
  if(season_forecast > 12) season_forecast <- season_forecast - 12
  ncatt_put(ncout, "prob", "forecast_season", as.character(seasons[season_forecast]))
  ncatt_put(ncout, "prob", "proj4", "+proj=longlat +datum=WGS84")
  # add global attributes
  title <- paste0("Tercile Probabilities for Lead ",lead," months")
  ncatt_put(ncout, 0, "title", title)
  ncatt_put(ncout, 0, "forecast_issued", as.character(fcstdate))
  ncatt_put(ncout, 0, "source_data", "IRI FD NMME_Seasonal_Forecast Precipitation_ELR")
  # close the file, writing data to disk
  nc_close(ncout)
}
