setwd("./Data") ## Set for AWS
library(terra)
library(dplyr)
library(lubridate)
library(writexl)
#------------------------------------------------------------------------------------------------------------------
#Community Data #Given by the partners in Nicaragua
cLonCoord = c(-86.2621555581,-86.27143686,-86.28678731,-86.283059370199993,
              -86.262830071300002,-86.25762432180,-86.231451938800006,
              -86.238579086900003,-86.2428543454,-86.220968346,
              -86.200151792900002,-86.216204683100003,-86.223584614999993,
              -86.236906157500002) 
cLatCoord = c(13.3816217871,13.403239298,13.418474321,13.4480398529999,
              13.433304676600001,13.42353030500,13.450410462400001,
              13.4388472489,13.4356536734,13.4340268808,13.418812513200001,
              13.4046886612,13.3894606467,13.3881256553)
community = c('El Bramadero','Daraili','La Laguna','San Andres','Las Limas',
              'Venecia','El Bijahual','El Naranjito','San Jeronimo',
              'El Naranjo','Los Planes','El Robledalito','Varonesa',
              'La Palmera')
#------------------------------------------------------------------------------------------------------------------
r = terra::rast('IRI_prob_fcst_lead_1.nc') # AUTO DOWNLOAD HERE

crsdef = "+proj=longlat +datum=WGS84"
crs(r) = crsdef
#------------------------------------------------------------------------------------------------------------------
df.seasA = data.frame()
for (i in 1:length(cLonCoord)) {
  lonLatCity = data.frame(lon=360+cLonCoord[i],lat=cLatCoord[i])
  
  locationVector = vect(lonLatCity, crs = "+proj=longlat +datum=WGS84")
  percentilesFull = terra::extract(r, locationVector, method = "bilinear") #shows the probabilities
  percentiles = subset(percentilesFull, select = -ID)
  percent = t(percentiles)

  dfA = data.frame('Community'=community[i],'probWet1'=percent[1], 'probNormal1'=percent[2],
                  'probDry1' = percent[3])
  df.seasA = rbind(df.seasA,dfA)
}
#------------------------------------------------------------------------------------------------------------------
r = terra::rast('IRI_prob_fcst_lead_2.nc') # AUTO DOWNLOAD HERE

crsdef = "+proj=longlat +datum=WGS84"
crs(r) = crsdef
#------------------------------------------------------------------------------------------------------------------
df.seasB = data.frame()
for (i in 1:length(cLonCoord)) {
  lonLatCity = data.frame(lon=360+cLonCoord[i],lat=cLatCoord[i])
  
  locationVector = vect(lonLatCity, crs = "+proj=longlat +datum=WGS84")
  percentilesFull = terra::extract(r, locationVector, method = "bilinear") #shows the probabilities
  percentiles = subset(percentilesFull, select = -ID)
  percent = t(percentiles)
 
  dfB = data.frame('probWet2'=percent[1], 'probNormal2'=percent[2],
                  'probDry2'=percent[3])
  df.seasB = rbind(df.seasB,dfB)
}
#------------------------------------------------------------------------------------------------------------------
r = terra::rast('IRI_prob_fcst_lead_3.nc') # AUTO DOWNLOAD HERE

crsdef = "+proj=longlat +datum=WGS84"
crs(r) = crsdef
#------------------------------------------------------------------------------------------------------------------
df.seasC = data.frame()
for (i in 1:length(cLonCoord)) {
  lonLatCity = data.frame(lon=360+cLonCoord[i],lat=cLatCoord[i])
  
  locationVector = vect(lonLatCity, crs = "+proj=longlat +datum=WGS84")
  percentilesFull = terra::extract(r, locationVector, method = "bilinear") #shows the probabilities
  percentiles = subset(percentilesFull, select = -ID)
  percent = t(percentiles)
  
  dfC = data.frame('probWet3'=percent[1], 'probNormal3'=percent[2],
                  'probDry3' = percent[3])
  df.seasC = rbind(df.seasC,dfC)
}
#---------------------------------------------------------------------------------------
r = terra::rast('IRI_prob_fcst_lead_4.nc') # AUTO DOWNLOAD HERE

crsdef = "+proj=longlat +datum=WGS84"
crs(r) = crsdef
#------------------------------------------------------------------------------------------------------------------
df.seasD = data.frame()
for (i in 1:length(cLonCoord)) {
  lonLatCity = data.frame(lon=360+cLonCoord[i],lat=cLatCoord[i])
  
  locationVector = vect(lonLatCity, crs = "+proj=longlat +datum=WGS84")
  percentilesFull = terra::extract(r, locationVector, method = "bilinear") #shows the probabilities
  percentiles = subset(percentilesFull, select = -ID)
  percent = t(percentiles)
  
  dfD = data.frame('probWet4'=percent[1], 'probNormal4'=percent[2],
                  'probDry4' = percent[3])
  df.seasD = rbind(df.seasD,dfD)
}
df.seasTotal = cbind(df.seasA,df.seasB,df.seasC,df.seasD)
#------------------------------------------------------------------------------------------------------------------
df.stats = data.frame()
for (i in 1:length(cLonCoord)) {
  lonLatCity = data.frame(lon=cLonCoord[i],lat=cLatCoord[i])
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
  df1 = data.frame('Community'=community[i], 'FiveDayForecast'=precipitation5,'FiveDayMin'=fiveDay15,
                   'FiveDayMax'=fiveDay85, 'TenDayForecast'=precipitation10, 'TenDayMin' =tenDay15,
                   'TenDayMax'=tenDay85, 'FifteenDayForecast'=precipitation15, 'FifteenDayMin'=fifteenDay15,
                   'FifteenDayMax'=fifteenDay85)
  df.stats = rbind(df.stats,df1)
}
#------------------------------------------------------------------------------------------------------------------
write_xlsx(df.seasTotal,"./seasonal.xlsx") ## Print Excel Files
write_xlsx(df.stats,"./stats.xlsx")