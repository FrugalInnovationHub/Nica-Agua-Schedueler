setwd("./Data") ## Modify for your system
# library(terra)
# library(writexl)
if (!require("writexl")) install.packages("writexl")
if (!require("terra")) install.packages('terra', repos='https://rspatial.r-universe.dev')
#------------------------------------------------------------------------------------------------------------------
#Community Data
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
  r5 = terra::rast('5 day.tif') # AUTO DOWNLOAD HERE
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
  r10 = terra::rast('10 day.tif') # AUTO DOWNLOAD HERE
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
  r15 = terra::rast('15 day.tif') #AUTO DOWNLOAD HERE
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
  r = terra::rast('Historical.nc') # AUTO DOWNLOAD HERE
  #------------------------------------------------------------------------------------------------------------------
  crsdef = "+proj=longlat +datum=WGS84"
  crs(r) = crsdef
  #------------------------------------------------------------------------------------------------------------------
  locationHist = vect(lonLatCity, crs = "+proj=longlat +datum=WGS84")
  historicalData = terra::extract(r, locationHist, method = 'bilinear')
  historicalData[historicalData < 0] = 0 
  historicalData = t(t(subset(historicalData, select = -c(1))))
  #------------------------------------------------------------------------------------------------------------------
  currentDay = as.character(Sys.Date()) 
  currentDay = gsub("-", " ", currentDay) 
  currentDay = read.table(text=currentDay,col.names =c('Year','Month','Day'))
  currentDay = subset(currentDay, select = -c(Year))
  
  monthDays = c(0,31,59,90,120,151,181,212,243,273,304,334)
  
  for (k in 1:12) {
    if (currentDay$Month == k) {
      currentDay$Month = monthDays[k]}}
  
  CDV = sum(t(currentDay)) #Days Since January 1, CurrentDayValue
  #------------------------------------------------------------------------------------------------------------------
  #Five Day Statistics
  historicalData = data.frame(historicalData)
  
  OneDaySequence = seq(CDV, ncol(historicalData), by = 365)
  TwoDaySequence = seq(CDV+1, ncol(historicalData), by = 365)
  ThreeDaySequence = seq(CDV+2, ncol(historicalData), by = 365)
  FourDaySequence = seq(CDV+3, ncol(historicalData), by = 365)
  FiveDaySequence = seq(CDV+4, ncol(historicalData), by = 365)
  
  OneDaySequence = historicalData[OneDaySequence]
  OneDaySequence = data.matrix(OneDaySequence)
  TwoDaySequence = historicalData[TwoDaySequence]
  TwoDaySequence = data.matrix(TwoDaySequence)
  ThreeDaySequence = historicalData[ThreeDaySequence]
  ThreeDaySequence = data.matrix(ThreeDaySequence)
  FourDaySequence = historicalData[FourDaySequence]
  FourDaySequence = data.matrix(FourDaySequence)
  FiveDaySequence = historicalData[FiveDaySequence]
  FiveDaySequence = data.matrix(FiveDaySequence)
  
  df.5Day = data.frame()
  for (k in 1:41) {
    FiveDayAverage = sum(OneDaySequence[k],TwoDaySequence[k],ThreeDaySequence[k],FourDaySequence[k],FiveDaySequence[k])
    df.Temp5 = data.frame('FiveDayTemp' = FiveDayAverage)
    df.5Day = rbind(df.5Day,df.Temp5)
  }
  df.5Day = data.matrix(df.5Day)
  FiveDay25 = quantile(df.5Day, prob=c(.25))
  FiveDay75 = quantile(df.5Day, prob=c(.75))
  
  #------------------------------------------------------------------------------------------------------------------
  #Ten Day Statistics
  historicalData = data.frame(historicalData)
  
  SixDaySequence = seq(CDV+5, ncol(historicalData), by = 365)
  SevenDaySequence = seq(CDV+6, ncol(historicalData), by = 365)
  EightDaySequence = seq(CDV+7, ncol(historicalData), by = 365)
  NineDaySequence = seq(CDV+8, ncol(historicalData), by = 365)
  TenDaySequence = seq(CDV+9, ncol(historicalData), by = 365)
  
  SixDaySequence = historicalData[SixDaySequence]
  SixDaySequence = data.matrix(SixDaySequence)
  SevenDaySequence = historicalData[SevenDaySequence]
  SevenDaySequence = data.matrix(SevenDaySequence)
  EightDaySequence = historicalData[EightDaySequence]
  EightDaySequence = data.matrix(ThreeDaySequence)
  NineDaySequence = historicalData[NineDaySequence]
  NineDaySequence = data.matrix(NineDaySequence)
  TenDaySequence = historicalData[TenDaySequence]
  TenDaySequence = data.matrix(TenDaySequence)
  
  df.10Day = data.frame()
  for (k in 1:41) {
    TenDayAverage = sum(OneDaySequence[k],TwoDaySequence[k],ThreeDaySequence[k],FourDaySequence[k],FiveDaySequence[k],
                        SixDaySequence[k],SevenDaySequence[k],EightDaySequence[k],NineDaySequence[k],TenDaySequence[k])
    df.Temp10 = data.frame('TenDayTemp' = TenDayAverage)
    df.10Day = rbind(df.10Day,df.Temp10)
  }
  df.10Day = data.matrix(df.10Day)
  TenDay25 = quantile(df.10Day, prob=c(.25))
  TenDay75 = quantile(df.10Day, prob=c(.75))
  
  #------------------------------------------------------------------------------------------------------------------
  #Fifteen Day Statistics
  historicalData = data.frame(historicalData)
  
  ElevenDaySequence = seq(CDV+10, ncol(historicalData), by = 365)
  TwelveDaySequence = seq(CDV+11, ncol(historicalData), by = 365)
  ThirteenDaySequence = seq(CDV+12, ncol(historicalData), by = 365)
  FourteenDaySequence = seq(CDV+13, ncol(historicalData), by = 365)
  FifteenDaySequence = seq(CDV+14, ncol(historicalData), by = 365)

  ElevenDaySequence = historicalData[ElevenDaySequence]
  ElevenDaySequence = data.matrix(ElevenDaySequence)
  TwelveDaySequence = historicalData[TwelveDaySequence]
  TwelveDaySequence = data.matrix(TwelveDaySequence)
  ThirteenDaySequence = historicalData[ThirteenDaySequence]
  ThirteenDaySequence = data.matrix(ThirteenDaySequence)
  FourteenDaySequence = historicalData[FourteenDaySequence]
  FourteenDaySequence = data.matrix(FourteenDaySequence)
  FifteenDaySequence = historicalData[FifteenDaySequence]
  FifteenDaySequence = data.matrix(FifteenDaySequence)
  
  df.15Day = data.frame()
  for (k in 1:41) {
    FifteenDayAverage = sum(OneDaySequence[k],TwoDaySequence[k],ThreeDaySequence[k],FourDaySequence[k],FiveDaySequence[k],
                        SixDaySequence[k],SevenDaySequence[k],EightDaySequence[k],NineDaySequence[k],TenDaySequence[k],
                        ElevenDaySequence[k],TwelveDaySequence[k],ThirteenDaySequence[k],FourteenDaySequence[k],FifteenDaySequence[k])
    df.Temp15 = data.frame('FifteenDayTemp' = FifteenDayAverage)
    df.15Day = rbind(df.15Day,df.Temp15)
  }
  df.15Day = data.matrix(df.15Day)
  FifteenDay25 = quantile(df.15Day, prob=c(.25))
  FifteenDay75 = quantile(df.15Day, prob=c(.75))
  #------------------------------------------------------------------------------------------------------------------
  #Final Organization
  df1 = data.frame('Community'=community[i], 'FiveDayForecast'=precipitation5,'FiveDayMin'=FiveDay25,
                   'FiveDayMax'=FiveDay75, 'TenDayForecast'=precipitation10, 'TenDayMin' =TenDay25,
                   'TenDayMax'=TenDay75, 'FifteenDayForecast'=precipitation15, 'FifteenDayMin'=FifteenDay25,
                   'FifteenDayMax'=FifteenDay75)
  df.stats = rbind(df.stats,df1)
}
df.stats[df.stats < 0] = 0 #Shouldn't be necessary, but added just in case
#------------------------------------------------------------------------------------------------------------------
write_xlsx(df.seasTotal,"./seasonal.xlsx") ## Modify for your system
write_xlsx(df.stats,"./stats.xlsx") ## Modify for your system