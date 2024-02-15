# Sets current working directory and loads required packages for script to run
setwd("./Data")
library(terra)
library(dplyr)
library(lubridate)
library(writexl)

#-------------------------------------------------------------------------------
# Inputs Spatial/Written Data for Nicaragua Communities

# Nicaragua Community Longitude Coordinates
comLonCoord = c(-86.2621555581,-86.27143686,-86.28678731,-86.283059370199993,
                -86.262830071300002,-86.25762432180,-86.231451938800006,
                -86.238579086900003,-86.2428543454,-86.220968346,
                -86.200151792900002,-86.216204683100003,-86.223584614999993,
                -86.236906157500002)
comLonCoord = as.data.frame(comLonCoord)

# Nicaragua Community Latitude Coordinates
comLatCoord = c(13.3816217871,13.403239298,13.418474321,13.4480398529999,
                13.433304676600001,13.42353030500,13.450410462400001,
                13.4388472489,13.4356536734,13.4340268808,13.418812513200001,
                13.4046886612,13.3894606467,13.3881256553)
comLatCoord = as.data.frame(comLatCoord)

# Nicaragua Community Names
comNames = c('El Bramadero','Daraili','La Laguna','San Andres','Las Limas',
             'Venecia','El Bijahual','El Naranjito','San Jeronimo',
             'El Naranjo','Los Planes','El Robledalito','Varonesa',
             'La Palmera')

#-------------------------------------------------------------------------------
# Loads Raster Forecast Data for Four Rainfall Forecasts and Defines CRS

# Loads Four Seasonal Leads for Nicaragua Area
rainProbForecast1 = terra::rast('IRI_prob_fcst_lead_1.nc')
rainProbForecast4 = terra::rast('IRI_prob_fcst_lead_4.nc')

# Defines Coordinate Reference System
comCRS = "+proj=longlat +datum=WGS84"
crs(rainProbForecast1) = comCRS
crs(rainProbForecast4) = comCRS

# Defines Forecast Lead Times
if (day(today()) >= 15) {
  date1 = today() %m+% months(0) %m+% days(15 - day(today()))
  date2 = date1 + months(3)
  date3 = date2 + months(6) 
} else {
  date1 = today() %m-% months(1) %m+% days(15 - day(today()))
  date2 = date1 + months(3)
  date3 = date2 + months(6) }

#-------------------------------------------------------------------------------
# Creates First Seasonal Forecast Lead for All Communities

# Creates empty data frame to store first seasonal forecast lead data
df.seasA = data.frame()

# Loop runs through commands for every community
for (i in 1:length(t(comLonCoord))) {
  lonLatCity = data.frame(lon=360+comLonCoord[i, "comLonCoord"],lat=comLatCoord[i, "comLatCoord"])
  
  # Vectorizes spatial data and utilizes raster to extract forecast percentile
  # data. Also formats data to be more readable
  lonLatCityVector = vect(lonLatCity, crs = comCRS)
  rainProbPercentilesFull = extract(rainProbForecast1, lonLatCityVector, method = "bilinear")
  rainProbPercentiles = subset(rainProbPercentilesFull, select = -ID)
  rainProbPercent = t(rainProbPercentiles)
  
  # Stores data for first seasonal lead
  dfA = data.frame('Community'=comNames[i],'probWet1'=rainProbPercent[1], 'probNormal1'=rainProbPercent[2],
                   'probDry1'=rainProbPercent[3])
  df.seasA = rbind(df.seasA,dfA)
}

#-------------------------------------------------------------------------------
# Creates Second Seasonal Forecast Lead for All Communities

# Creates empty data frame to store fourth seasonal forecast lead data
df.seasD = data.frame()

# Loop runs through commands for every community
for (i in 1:length(t(comLonCoord))) {
  lonLatCity = data.frame(lon=360+comLonCoord[i, "comLonCoord"],lat=comLatCoord[i, "comLatCoord"])
  
  # Vectorizes spatial data and utilizes raster to extract forecast percentile
  # data. Also formats data to be more readable
  lonLatCityVector = vect(lonLatCity, crs = comCRS)
  rainProbPercentilesFull = extract(rainProbForecast4, lonLatCityVector, method = "bilinear")
  rainProbPercentiles = subset(rainProbPercentilesFull, select = -ID)
  rainProbPercent = t(rainProbPercentiles)
  
  # Stores data for second seasonal lead
  dfD = data.frame('probWet4'=rainProbPercent[1], 'probNormal4'=rainProbPercent[2],
                   'probDry4' = rainProbPercent[3])
  df.seasD = rbind(df.seasD,dfD)
}

#-------------------------------------------------------------------------------
# Provides written explanation for first seasonal lead

# Creates empty data frame to store first seasonal forecast lead data
df.descA = data.frame()

# Loop runs through commands for each community
for (i in 1:length(t(comLonCoord))) {
  
  if ((df.seasA[i, 'probWet1'] >= 33) & (df.seasA[i, 'probDry1'] >= 33)) { 
    case1 = '1'
  } else if ((df.seasA[i, 'probWet1'] >= 33) & (df.seasA[i, 'probWet1'] < 50) & (df.seasA[i, 'probNormal1'] >= 33) & (df.seasA[i, 'probNormal1'] < 50)) {
    case1 = '2.1'
  } else if ((df.seasA[i, 'probDry1'] >= 33) & (df.seasA[i, 'probDry1'] < 50) & (df.seasA[i, 'probNormal1'] >= 33) & (df.seasA[i, 'probNormal1'] < 50)) {
    case1 = '2.2'
  } else if ((df.seasA[i, 'probWet1'] >= 40) & (df.seasA[i, 'probNormal1'] < 33) & (df.seasA[i, 'probDry1'] < 33)) {
    case1 = '3.1'
  } else if ((df.seasA[i, 'probNormal1'] >= 40) & (df.seasA[i, 'probWet1'] < 33) & (df.seasA[i, 'probDry1'] < 33)) {
    case1 = '3.2'
  } else if ((df.seasA[i, 'probDry1'] >= 40) & (df.seasA[i, 'probNormal1'] < 33) & (df.seasA[i, 'probWet1'] < 33)) {
    case1 = '3.3'
  } else if ((df.seasA[i, 'probWet1'] >= 50) & (df.seasA[i, 'probNormal1'] >= 33) & (df.seasA[i, 'probDry1'] <= 17)) {
    case1 = '4.1'
  } else if ((df.seasA[i, 'probDry1'] >= 50) & (df.seasA[i, 'probNormal1'] >= 33) & (df.seasA[i, 'probWet1'] <= 17)) {
    case1 = '4.2'
  } else if ((df.seasA[i, 'probNormal1'] >= 50) & (df.seasA[i, 'probWet1'] >= 33) & (df.seasA[i, 'probDry1'] <= 17)) {
    case1 = '4.3'
  } else if ((df.seasA[i, 'probNormal1'] >= 50) & (df.seasA[i, 'probDry1'] >= 33) & (df.seasA[i, 'probWet1'] <= 17)) {
    case1 = '4.4'
  } else
    case1 = 'NULL'
  
  dfdA = data.frame('desc1'=case1)
  df.descA = rbind(df.descA,dfdA)
}

#-------------------------------------------------------------------------------
# Provides written explanation for second seasonal lead

# Creates empty data frame to store second seasonal forecast lead data
df.descD = data.frame()

# Loop runs through commands for each community
for (i in 1:length(t(comLonCoord))) {
  
  if ((df.seasD[i, 'probWet4'] >= 33) & (df.seasD[i, 'probDry4'] >= 33)) { 
    case2 = '1'
  } else if ((df.seasD[i, 'probWet4'] >= 33) & (df.seasD[i, 'probWet4'] < 50) & (df.seasD[i, 'probNormal4'] >= 33) & (df.seasD[i, 'probNormal4'] < 50)) {
    case2 = '2.1'
  } else if ((df.seasD[i, 'probDry4'] >= 33) & (df.seasD[i, 'probDry4'] < 50) & (df.seasD[i, 'probNormal4'] >= 33) & (df.seasD[i, 'probNormal4'] < 50)) {
    case2 = '2.2'
  } else if ((df.seasD[i, 'probWet4'] >= 40) & (df.seasD[i, 'probNormal4'] < 33) & (df.seasD[i, 'probDry4'] < 33)) {
    case2 = '3.1'
  } else if ((df.seasD[i, 'probNormal4'] >= 40) & (df.seasD[i, 'probWet4'] < 33) & (df.seasD[i, 'probDry4'] < 33)) {
    case2 = '3.2'
  } else if ((df.seasD[i, 'probDry4'] >= 40) & (df.seasD[i, 'probNormal4'] < 33) & (df.seasD[i, 'probWet4'] < 33)) {
    case2 = '3.3'
  } else if ((df.seasD[i, 'probWet4'] >= 50) & (df.seasD[i, 'probNormal4'] >= 33) & (df.seasD[i, 'probDry4'] <= 17)) {
    case2 = '4.1'
  } else if ((df.seasD[i, 'probDry4'] >= 50) & (df.seasD[i, 'probNormal4'] >= 33) & (df.seasD[i, 'probWet4'] <= 17)) {
    case2 = '4.2'
  } else if ((df.seasD[i, 'probNormal4'] >= 50) & (df.seasD[i, 'probWet4'] >= 33) & (df.seasD[i, 'probDry4'] <= 17)) {
    case2 = '4.3'
  } else if ((df.seasD[i, 'probNormal4'] >= 50) & (df.seasD[i, 'probDry4'] >= 33) & (df.seasD[i, 'probWet4'] <= 17)) {
    case2 = '4.4'
  } else
    case2 = 'NULL'
  
  dfdD = data.frame('desc4'=case2)
  df.descD = rbind(df.descD,dfdD)
}
#------------------------------------------------------------------------------------------------------------------
df.seasTotal = cbind(df.seasA, df.seasD, df.descA, df.descD)
#------------------------------------------------------------------------------------------------------------------
df.stats = data.frame()
for (i in 1:length(t(comLonCoord))) {
  lonLatCity = data.frame(lon=comLonCoord[i, "comLonCoord"],lat=comLatCoord[i, "comLatCoord"])
#------------------------------------------------------------------------------------------------------------------
  #5 Day
  # Load file 1 using terra::rast and plot contents
  r5 = terra::rast('5 Day.tif')
  # Use defined projection for lon/lat coordinates
  crsdef = "+proj=longlat +datum=WGS84"
  crs(r5) = crsdef
  
  location5 = vect(lonLatCity, crs = "+proj=longlat +datum=WGS84")
  precipitationMatrix5 = terra::extract(r5, location5, method = 'bilinear') 
  precipitation5 = subset(precipitationMatrix5, select = -ID)
  precipitation5 = as.numeric(precipitation5)
  #------------------------------------------------------------------------------------------------------------------
  #10 Day
  # Load file 2 using terra::rast and plot contents
  r10 = terra::rast('10 Day.tif') 
  # Use defined projection for lon/lat coordinates
  crsdef = "+proj=longlat +datum=WGS84"
  crs(r10) = crsdef
  
  location10 = vect(lonLatCity, crs = "+proj=longlat +datum=WGS84")
  precipitationMatrix10 = terra::extract(r10, location10, method = 'bilinear') 
  precipitation10 = subset(precipitationMatrix10, select = -ID)
  precipitation10 = as.numeric(precipitation10)
  #------------------------------------------------------------------------------------------------------------------
  #15 Day
  # Load file 3 using terra::rast and plot contents
  r15 = terra::rast('15 Day.tif')
  # Use defined projection for lon/lat coordinates
  crsdef = "+proj=longlat +datum=WGS84"
  crs(r15) = crsdef
  
  location15 = vect(lonLatCity, crs = "+proj=longlat +datum=WGS84")
  precipitationMatrix15 = terra::extract(r15, location15, method = 'bilinear')
  precipitation15 = subset(precipitationMatrix15, select = -ID)
  precipitation15 = as.numeric(precipitation15)
  #------------------------------------------------------------------------------------------------------------------
  allForecasts = cbind(precipitation5,precipitation10,precipitation15)
  allForecasts = t(allForecasts)
  allForecasts = data.frame(Days = (5*c(1:3)), X = (allForecasts))
  colnames(allForecasts) = c('# Days','rainfall mm') 
  #------------------------------------------------------------------------------------------------------------------
  #Prepare Dates
  r = terra::rast('Historical.nc') #This file has 41 years of rainfall data
  locationHist = vect(lonLatCity, crs = "+proj=longlat +datum=WGS84") #Cceate a vector for the community
  historicalData = terra::extract(r, locationHist, method = 'bilinear') #extract historical rainfall data for community
  historicalData[historicalData < 0] = 0 #replace any negative, errant value with a 0
  historicalData = subset(historicalData, select = -c(1))
  #------------------------------------------------------------------------------------------------------------------
  #Prepare Dates
  dates = as.Date(terra::time(r)) %>% #read in dates from historical data netcdf
    data.frame()
  today = as.Date(Sys.Date()) %>% #read in and format system date for data maniupulation
    format(format="%m-%d-0000")
  startYear = format(dates[1,1], format="%Y") #find the first year from the historical data file
  endYear = format(dates[nrow(dates), length(dates)], format="%Y") #find the last year from the historical data file
  yearsSeq = seq(startYear, endYear, by = 1) #create a sequence listing all years that the historical data file encompasses
  janFirst = ("01-01-0000") #create a constant value for the first of the year
  CDV = difftime(mdy(today), mdy(janFirst), units = "days") %>%
    as.numeric() #CDV = CurrentDayValue. Converts date to a numeric value equal to the amount of days today is from Jan 1
  #------------------------------------------------------------------------------------------------------------------
  #Find Data for Statistics
  # Each sequence finds the rainfall data from today's date across all years encompassed by the historical data file. 
  oneDaySequence = seq(CDV, ncol(historicalData), by = 365) #sequence from today's CDV to the data's final year CDV
  oneDayData = historicalData[oneDaySequence] %>% 
    data.matrix() #get rainfall data into a data matrix from today's date across all years
  twoDayData = historicalData[(oneDaySequence+1)] %>% 
    data.matrix() #get rainfall data into a data matrix from tomorrow's date across all years
  threeDayData = historicalData[(oneDaySequence+2)] %>% 
    data.matrix() #get rainfall data into a data matrix from day after tomorrow's date across all years
  fourDayData = historicalData[(oneDaySequence+3)] %>% 
    data.matrix() #get rainfall data in a data matrix from 4 days from today's date across all years
  fiveDayData = historicalData[(oneDaySequence+4)] %>% 
    data.matrix() #get rainfall data in a data matrix from 5 days from today's date across all years
  sixDayData = historicalData[(oneDaySequence+5)] %>% 
    data.matrix() #get rainfall data in a data matrix from 6 days from today's date across all years
  sevenDayData = historicalData[(oneDaySequence+6)] %>% 
    data.matrix() #get rainfall data in a data matrix from 7 days from today's date across all years
  eightDayData = historicalData[(oneDaySequence+7)] %>% 
    data.matrix() #get rainfall data in a data matrix from 8 days from today's date across all years
  nineDayData = historicalData[(oneDaySequence+8)] %>% 
    data.matrix() #get rainfall data in a data matrix from 9 days from today's date across all years
  tenDayData = historicalData[(oneDaySequence+9)] %>% 
    data.matrix() #get rainfall data in a data matrix from 10 days from today's date across all years
  elevenDayData = historicalData[(oneDaySequence+10)] %>% 
    data.matrix() #get rainfall data in a data matrix from 11 days from today's date across all years
  twelveDayData = historicalData[(oneDaySequence+11)] %>% 
    data.matrix() #get rainfall data in a data matrix from 12 days from today's date across all years
  thirteenDayData = historicalData[(oneDaySequence+12)] %>% 
    data.matrix() #get rainfall data in a data matrix from 13 days from today's date across all years
  fourteenDayData = historicalData[(oneDaySequence+13)] %>% 
    data.matrix() #get rainfall data in a data matrix from 14 days from today's date across all years
  fifteenDayData = historicalData[(oneDaySequence+14)] %>% 
    data.matrix() #get rainfall data in a data matrix from 15 days from today's date across all years
  
  df.5Day = data.frame() #create empty data frames for future modification
  df.10Day = data.frame()
  df.15Day = data.frame()
  
  for (k in 1:length(yearsSeq)) { #run for every year that there is data
    #compile all years of data in chunks of 5/10/15 for one year, then add the next year's data into the same data frame
    fiveDayOutput = sum(oneDayData[k],twoDayData[k],threeDayData[k],fourDayData[k],fiveDayData[k])
    df.Temp5 = data.frame('FiveDayTemp' = fiveDayOutput)
    df.5Day = rbind(df.5Day,df.Temp5)
    
    tenDayOutput = sum(oneDayData[k],twoDayData[k],threeDayData[k],fourDayData[k],fiveDayData[k],sixDayData[k],
                       sevenDayData[k],eightDayData[k],nineDayData[k],tenDayData[k])
    df.Temp10 = data.frame('TenDayTemp' = tenDayOutput)
    df.10Day = rbind(df.10Day,df.Temp10)
    
    fifteenDayOutput = sum(oneDayData[k],twoDayData[k],threeDayData[k],fourDayData[k],fiveDayData[k],sixDayData[k],
                           sevenDayData[k],eightDayData[k],nineDayData[k],tenDayData[k],elevenDayData[k],
                           twelveDayData[k],thirteenDayData[k],fourteenDayData[k],fifteenDayData[k])
    df.Temp15 = data.frame('FifteenDayTemp' = fifteenDayOutput)
    df.15Day = rbind(df.15Day,df.Temp15)
  }
  #------------------------------------------------------------------------------------------------------------------
  #Perform Statistics Calculations on Data Frames
  #create a data matrix for all previously attained rainfall data, then perform statistics calculations
  df.5Day = data.matrix(df.5Day)
  fiveDay15 = quantile(df.5Day, prob=c(.15)) #15th percentile of data = historical lower end of range
  fiveDay85 = quantile(df.5Day, prob=c(.85)) #85th percentile of data = historical upper end of range
  
  df.10Day = data.matrix(df.10Day)
  tenDay15 = quantile(df.10Day, prob=c(.15))
  tenDay85 = quantile(df.10Day, prob=c(.85))
  
  df.15Day = data.matrix(df.15Day)
  fifteenDay15 = quantile(df.15Day, prob=c(.15))
  fifteenDay85 = quantile(df.15Day, prob=c(.85))
  #------------------------------------------------------------------------------------------------------------------
  #Final Organization
  df1 = data.frame('Community'=comNames[i], 'FiveDayForecast'=precipitation5,'FiveDayMin'=fiveDay15,
                   'FiveDayMax'=fiveDay85, 'TenDayForecast'=precipitation10, 'TenDayMin' =tenDay15,
                   'TenDayMax'=tenDay85, 'FifteenDayForecast'=precipitation15, 'FifteenDayMin'=fifteenDay15,
                   'FifteenDayMax'=fifteenDay85)
  df.stats = rbind(df.stats,df1)
}
#------------------------------------------------------------------------------------------------------------------
#Rainfall Constants
# All of these values were found using a separate script that calculated the percentiles (shown in the column headers) of historical data.
# Five Day Parameters
fiveNoRain = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
fiveVeryLightRain = c(1.45, 1.62, 1.87, 2.09, 2.04, 2.09, 2.15, 2.19, 2.21, 2.15, 2.19, 2.19, 2.14, 2.14)
fiveLightRain = c(5.07, 5.17, 5.44, 5.56, 5.52, 5.53, 5.60, 5.63, 5.64, 5.62, 5.68, 5.70, 5.66, 5.65)
fiveModerateRain = c(12.65, 12.64, 12.94, 13.19, 13.19, 13.24, 13.39, 13.46, 13.49, 13.51, 13.63, 13.66, 13.63, 13.60)
fiveHeavyRain = c(24.16, 24.33, 24.79, 25.26, 25.32, 25.37, 25.65, 25.77, 25.84, 25.91, 26.16, 26.19, 26.13, 26.05)
fiveVeryHeavyRain = c(38.15, 38.49, 39.28, 40.14, 40.21, 40.17, 40.45, 40.51, 40.57, 40.62, 40.82, 40.82, 40.72, 40.60)
fiveExtremeRain = c(125.71, 130.65, 132.10, 135.56, 135.92, 135.80, 137.64, 139.46, 139.38, 139.64, 140.92, 140.81, 139.27, 138.51)
fiveDays = data.frame(comNames, fiveNoRain, fiveVeryLightRain, fiveLightRain,
                      fiveModerateRain, fiveHeavyRain, fiveVeryHeavyRain, fiveExtremeRain)
colnames(fiveDays) = c("Community", "No Rain (0%)", "Very Light Rain (10%)", "Light Rain (25%)", "Moderate Rain (50%)",
                       "Heavy Rain (75%)", "Very Heavy Rain (90%)", "Extreme Rain (99.9%)")
# Ten Day Parameters
tenNoRain = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
tenVeryLightRain = c(1.41, 1.71, 2.09, 2.30, 2.29, 2.33, 2.44, 2.48, 2.49, 2.46, 2.50, 2.50, 2.48, 2.47)
tenLightRain = c(6.18, 6.22, 6.63, 6.78, 6.65, 6.69, 6.75, 6.78, 6.80, 6.71, 6.78, 6.78, 6.72, 6.72)
tenModerateRain = c(20.11, 19.99, 20.37, 20.70, 20.69, 20.79, 21.08, 21.20, 21.30, 21.32, 21.57, 21.62, 21.60, 21.58)
tenHeavyRain = c(40.62, 40.65, 41.47, 42.24, 42.32, 42.33, 42.83, 43.02, 43.10, 43.19, 43.52, 43.58, 43.45, 43.35)
tenVeryHeavyRain = c(63.84, 64.11, 65.26, 66.48, 66.51, 66.38, 66.87, 67.00, 67.03, 67.11, 67.46, 67.48, 67.26, 67.08)
tenExtremeRain = c(190.16, 195.90, 197.17, 204.28, 204.28, 204.04, 204.24, 204.16, 203.77, 202.76, 201.71, 199.11, 197.87, 196.83)
tenDays = data.frame(comNames, tenNoRain, tenVeryLightRain, tenLightRain,
                     tenModerateRain, tenHeavyRain, tenVeryHeavyRain, tenExtremeRain)
colnames(tenDays) = c("Community", "No Rain (0%)", "Very Light Rain (10%)", "Light Rain (25%)", "Moderate Rain (50%)",
                      "Heavy Rain (75%)", "Very Heavy Rain (90%)", "Extreme Rain (99.9%)")
# Fifteen Day Parameters
fifteenNoRain = c(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
fifteenVeryLightRain = c(1.41, 1.71, 2.16, 2.37, 2.38, 2.44, 2.56, 2.62, 2.66, 2.63, 2.71, 2.71, 2.70, 2.68)
fifteenLightRain = c(6.50, 6.50, 7.11, 7.30, 7.18, 7.25, 7.34, 7.36, 7.37, 7.25, 7.34, 7.34, 7.26, 7.26)
fifteenModerateRain = c(27.35, 27.37, 28.11, 28.66, 28.63, 28.69, 29.13, 29.30, 29.41, 29.42, 29.71, 29.77, 29.69, 29.66)
fifteenHeavyRain = c(56.07, 56.41, 57.72, 58.98, 58.91, 58.87, 59.45, 59.60, 59.65, 59.69, 60.17, 60.17, 59.95, 59.80)
fifteenVeryHeavyRain = c(87.37, 87.78, 89.19, 90.86, 90.89, 90.83, 91.43, 91.67, 91.82, 91.90, 92.35, 92.30, 92.00, 91.72)
fifteenExtremeRain = c(244.78, 250.87, 257.55, 266.44, 266.64, 266.07, 265.80, 265.56, 265.14, 263.78, 263.05, 260.73, 257.87, 255.24)
fifteenDays = data.frame(comNames, fifteenNoRain, fifteenVeryLightRain, fifteenLightRain,
                         fifteenModerateRain, fifteenHeavyRain, fifteenVeryHeavyRain, fifteenExtremeRain)
colnames(fifteenDays) = c("Community", "No Rain (0%)", "Very Light Rain (10%)", "Light Rain (25%)", "Moderate Rain (50%)",
                          "Heavy Rain (75%)", "Very Heavy Rain (90%)", "Extreme Rain (99.9%)")
#------------------------------------------------------------------------------------------------------------------
#Rainfall Classification
classification = data.frame(comNames)
#Five Days
for (community in 1:length(comNames)) {
  if(df.stats[community,2] <= fiveDays[community,2]){
    classification[community,1] = "No Rain"
  } else if (df.stats[community,2] > fiveDays[community,2] & df.stats[community,2] <= fiveDays[community,3]){
    classification[community,1] = "Very Light Rain"
  } else if (df.stats[community,2] > fiveDays[community,3] & df.stats[community,2] <= fiveDays[community,4]){
    classification[community,1] = "Light Rain"
  } else if (df.stats[community,2] > fiveDays[community,4] & df.stats[community,2] <= fiveDays[community,5]){
    classification[community,1] = "Moderate Rain"
  } else if (df.stats[community,2] > fiveDays[community,5] & df.stats[community,2] <= fiveDays[community,6]){
    classification[community,1] = "Heavy Rain"
  } else if (df.stats[community,2] > fiveDays[community,6] & df.stats[community,2] <= fiveDays[community,7]){
    classification[community,1] = "Very Heavy Rain"
  } else
    classification[community,1] = "Extreme Rain"
}
#Ten Days
for (community in 1:length(comNames)) {
  if(df.stats[community,2] == tenDays[community,2]){
    classification[community,2] = "No Rain"
  } else if (df.stats[community,2] > tenDays[community,2] & df.stats[community,2] <= tenDays[community,3]){
    classification[community,2] = "Very Light Rain"
  } else if (df.stats[community,2] > tenDays[community,3] & df.stats[community,2] <= tenDays[community,4]){
    classification[community,2] = "Light Rain"
  } else if (df.stats[community,2] > tenDays[community,4] & df.stats[community,2] <= tenDays[community,5]){
    classification[community,2] = "Moderate Rain"
  } else if (df.stats[community,2] > tenDays[community,5] & df.stats[community,2] <= tenDays[community,6]){
    classification[community,2] = "Heavy Rain"
  } else if (df.stats[community,2] > tenDays[community,6] & df.stats[community,2] <= tenDays[community,7]){
    classification[community,2] = "Very Heavy Rain"
  } else
    classification[community,2] = "Extreme Rain"
}

#Fifteen Days
for (community in 1:length(comNames)) {
  if(df.stats[community,2] == tenDays[community,2]){
    classification[community,3] = "No Rain"
  } else if (df.stats[community,2] > tenDays[community,2] & df.stats[community,2] <= tenDays[community,3]){
    classification[community,3] = "Very Light Rain"
  } else if (df.stats[community,2] > tenDays[community,3] & df.stats[community,2] <= tenDays[community,4]){
    classification[community,3] = "Light Rain"
  } else if (df.stats[community,2] > tenDays[community,4] & df.stats[community,2] <= tenDays[community,5]){
    classification[community,3] = "Moderate Rain"
  } else if (df.stats[community,2] > tenDays[community,5] & df.stats[community,2] <= tenDays[community,6]){
    classification[community,3] = "Heavy Rain"
  } else if (df.stats[community,2] > tenDays[community,6] & df.stats[community,2] <= tenDays[community,7]){
    classification[community,3] = "Very Heavy Rain"
  } else
    classification[community,3] = "Extreme Rain"
}
df.classification = data.frame(classification)
colnames(df.classification) = c("Five Day Classification", "Ten Day Classification", "Fifteen Day Classification")
df.stats = cbind(df.stats, df.classification)
#------------------------------------------------------------------------------------------------------------------
write_xlsx(df.seasTotal,"./seasonal.xlsx") ## Print Excel Files
write_xlsx(df.stats,"./stats.xlsx")