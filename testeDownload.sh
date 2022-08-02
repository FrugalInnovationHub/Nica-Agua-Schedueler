#!/bin/bash

#Downloads seasonal forecast data from IRI
#These are updated on the 15th of each month, or the next business day following the 15th

#key is obtained here: https://wiki.iri.columbia.edu/index.php?n=Climate.S2S-IRIDL
key="733039b0e02ed5acf2d45931d7b7810daa8b90f5d2cc6981ffe381ece6ca757bfcf27c92e817f0a4d5ba3005be5f1ea3cd1e654e"
#"665e98f2050c0aa3d13d221bd7937f66db7c7a3e088b274f371f94e023a08406cc231cd316435b274edc176c8cb4c0b66292d9b3"

# creating the authentication string with the provided access key
auth="__dlauth_id=${key}"

# downloading using curl
#raw link is 
#https://iridl.ldeo.columbia.edu/SOURCES/.IRI/.FD/.NMME_Seasonal_Forecast/.Precipitation_ELR/.prob/data.nc

#remove old raw data if necessary
rawfile="raw_data.nc"
[[ -f $rawfile ]] && rm -f "$rawfile"

curl -L -k -b $auth 'https://iridl.ldeo.columbia.edu/SOURCES/.IRI/.FD/.NMME_Seasonal_Forecast/.Precipitation_ELR/.prob/data.nc' > raw_data.nc

#then compare as.Date(file.info('data.nc')$mtime) to Sys.Date() and file.info('data.nc')$size > 387000000