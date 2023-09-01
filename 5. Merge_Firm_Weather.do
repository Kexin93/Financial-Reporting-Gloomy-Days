clear
else if "`c(username)'" == "kexin"{
global maindir "E:\21. Air Pollution and Accounting\DATA"
}

else if "`c(username)'" == "Huaxi"{
global maindir "E:\Dropbox\Air Pollution and Accounting\Data"
}

/*
	use "$maindir\firm_zipcode_date", replace

	global obs = _N
	forvalues i = 4089/5000{		
		keep if Num == `i'
		
		* for each firm-station, merge with visibility data just for particular year(s) for that station
		preserve
			local start_date = Firm_START_DATE[1]
			local end_date = Firm_END_DATE[1]
			
			local start_year = Firm_START_YEAR[1]
			local end_year = Firm_END_YEAR[1]
			
			local station_id = station
			
			if(Firm_START_YEAR != Firm_END_YEAR){
				clear
				cd "$maindir\Visibility Data"
				use `start_year'
				append using `end_year'.dta, gen(append)
				drop append
			}
			else {
				clear
				cd "$maindir\Visibility Data"
				use `start_year'
			}
			
			keep if station == "`station_id'"
			gen station_year = substr(yearmoda, 1, 4)
			gen station_month = substr(yearmoda, 5, 2)
			gen station_day = substr(yearmoda, 7, 2)
			destring station_year station_month station_day, replace
			gen station_opdate = mdy(station_month, station_day, station_year)
				format station_opdate %td
			
			keep if inrange(station_opdate, `start_date', `end_date')

			keep station_opdate station temp dewp slp stp visib wdsp mxspd gust max min prcp sndp fog rain snow hail thunder tornado
						
			tempfile station_Visibility
			save `station_Visibility', replace
		restore
		
			capture drop _merge
		merge 1:m station using `station_Visibility'
		
		summarize _merge
		local merge_max = r(max)
		
		if(`merge_max' == 3){
			keep if _merge == 3
			collapse (mean) firm_FID Num (mean) temp dewp slp stp visib wdsp (max) mxspd gust max (min) min (sum) prcp (mean) sndp (mean)fog rain snow hail thunder tornado, by(station)
			
			cd "$maindir\TempFirmStation3"
			save "`i'", replace
		}
		
			clear
		use "$maindir\firm_zipcode_date", replace
	}
	*/
	
		* For each firm, collapse weather data by firm
		cd "$maindir\Analysis_102148 observations\TempFirmStation1yr"
		clear 
		fs "*.dta"
		append using `r(files)',force
		sort Num
		save "$maindir\Analysis_102148 observations\Firm_Multiple_Stations", replace //23170

		clear
		use "$maindir\Analysis_102148 observations\firm_zipcode_date", replace
			capture drop _merge
		merge 1:1 Num using "$maindir\Analysis_102148 observations\Firm_Multiple_Stations"
		keep if _merge == 3
		
		collapse (mean) temp dewp slp stp visib wdsp (max) mxspd gust max (min) min (mean) prcp (mean) sndp (mean) fog rain snow hail thunder tornado, by(firm_FID) //or firm_ID
		save "$maindir\Analysis_102148 observations\Firm_Visibility_Data", replace
		// 23139 unique firm year with 1 weather
		
		
		clear
		use "$maindir\firm_zipcode", replace
			capture drop _merge
		gen firm_FID = firm_ID - 1 //can delete
		merge 1:1 firm_FID using "$maindir\Analysis_102148 observations\Firm_Visibility_Data"
			keep if _merge == 3
		save "$maindir\Analysis_102148 observations\Firm_Year_Weather", replace
		
		
		
		
		
		
		* In the end, each firm has the visibility data during the particular period from 3 stations
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
