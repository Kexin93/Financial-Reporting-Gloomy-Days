clear
else if "`c(username)'" == "kexin"{
global maindir "E:\21. Air Pollution and Accounting\DATA"

global dofile "E:\21. Air Pollution and Accounting\CODE"
}

* 1) Keep US stations: zip code, lat, lon, station names, county, state等, 生成`US_stations_7334'
do "$dofile\2. Station_Zipcode.do"

* 2) Firm side: merge firm with zipcode --> conv生成`firm_zipcode' (firm year)
do "$dofile\1. Merge_File_Firm_Zipcode.do"

* 3) Combine firm with stations --> 生成"firm_zipcode_date": firm-year-station (multiple stations)
do "$dofile\4. Combine_Firm_Loc_with_Stations.do"

* 4) Assign each firm-year with station, therefore weather --> 生成firm-year-station-weather (23170 observations, multiple stations)
do "$dofile\6. Merge_Firm_Weather_OneYear.do"
do "$dofile\7. Merge_Firm_Weather_TwoYears.do"

* 5) Collapse by firm_ID --> 生成firm-year-weather (23139 firm-year observations)
* Firm_Multiple_Stations: append all firm_year_station_weather data --> 生成Firm_Multiple_Stations
* Merge firm_zipcode_date with Firm_Multiple_Stations --> 生成firm-year-station-weather数据，包括financial data
* Collapse by firm_FID: 生成firm-year-weather data with financial information -> Firm_Visibility_Data
* Merge firm_zipcode (firm-year observation) with Firm_Visibility_Data --> 生成Firm_Year_Weather
do "$dofile\5. Merge_Firm_Weather.do"
