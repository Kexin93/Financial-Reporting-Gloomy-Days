clear
else if "`c(username)'" == "kexin"{
global maindir "D:\Research材料\21. Air Pollution and Accounting\DATA"
}

else if "`c(username)'" == "Huaxi"{
global maindir "E:\Dropbox\Air Pollution and Accounting\Data"
}

	use "$maindir\firm_zipcode_date", replace
	
	keep if Firm_START_YEAR != Firm_END_YEAR

	global obs = _N
	forvalues i = 1/$obs{		
		keep if Num2 == `i'
		
		* for each firm-station, merge with visibility data just for particular year(s) for that station
		preserve
			local start_date = Firm_START_DATE[1]
			local end_date = Firm_END_DATE[1]
			
			local start_year = Firm_START_YEAR[1]
			local end_year = Firm_END_YEAR[1]
			
			local station_id = station
						
			cd "$maindir\Visibility Data"
			clear
			use `start_year'
				capture drop month
			append using `end_year'.dta, gen(append)
			drop append

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
			collapse (mean) firm_FID Num (mean) temp dewp slp stp visib wdsp (max) mxspd gust max (min) min (mean) prcp (mean) sndp (mean)fog rain snow hail thunder tornado, by(station)
			local j = Num
			cd "$maindir\TempFirmStation3"
			save "`j'", replace
		}
		
			clear
		use "$maindir\firm_zipcode_date", replace
	}
