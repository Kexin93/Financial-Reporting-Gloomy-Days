clear
else if "`c(username)'" == "kexin"{
global maindir "D:\Research材料\21. Air Pollution and Accounting\DATA"
}

else if "`c(username)'" == "Huaxi"{
global maindir "E:\Dropbox\Air Pollution and Accounting\Data"
}

clear
import delimited "$maindir\US Stations Location\isd-history.csv"
* Station identifier (in the station data set)
*WBAN number where applicable--this is the historical "Weather Bureau Air Force Navy"  number - with WBAN being the acronym. STN Station number (WMO/DATSAV3 number) for the location.
*
		tostring wban, replace
		gen station = usaf + wban
		*ctry state lat lon
		
		drop if mi(lat) & mi(lon) & mi(state) & mi(ctry) //749 deleted - cannot locate the station at all
		drop if lat == 0 & lon == 0 & mi(state) & mi(ctry) //59 deleted
		drop if ctry != "US" & !mi(ctry) //21,057 deleted, 7,456 remaining, 130 missing country names
		
		*Drop observations with missing country but non-missing Lat/lon, only keep observations located within the US
		*==== Lat, Long limits ========
			tempvar lat_min_temp lat_max_temp lon_min_temp lon_max_temp
		egen `lat_min_temp' = min(lat) if !mi(lat) & ctry == "US"
		egen `lat_max_temp' = max(lat) if !mi(lat) & ctry == "US"
		
		egen `lon_min_temp' = min(lon) if !mi(lon) & ctry == "US"
		egen `lon_max_temp' = max(lon) if !mi(lon) & ctry == "US"
		
		egen lat_min = mean(`lat_min_temp')
		egen lat_max = mean(`lat_max_temp')
		egen lon_min = mean(`lon_min_temp')
		egen lon_max = mean(`lon_max_temp')
		
		* drop the outliers in terms of their lat/lon!!! not described
		drop if (lat < lat_min | lat > lat_max | lon < lon_min | lon > lon_max) & mi(ctry) // 5 dropped (including missing)
		
		* drop stations in the US with missing lat/lon - unable to locate them with info on country and state only
		drop if mi(lat) | mi(lon) // 117 observations dropped

* Now remaining: 7,334 stations in the US, with lat & lon information
	
		tempfile US_stations_7334
		save `US_stations_7334'
		save "$maindir\US_stations_7334", replace
		
		preserve
			keep station stationname state lat lon
			export excel "$maindir\US_stations_7334.xlsx", firstrow(variables) replace
		restore
