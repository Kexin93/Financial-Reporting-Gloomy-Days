clear
else if "`c(username)'" == "kexin"{
global maindir "D:\Research材料\21. Air Pollution and Accounting\DATA"
}

else if "`c(username)'" == "Huaxi"{
global maindir "E:\Dropbox\Air Pollution and Accounting\Data"
}


clear
	use "$maindir\firm_zipcode" //102,148 firms with zipcode, lat, and lon

	* firm-station
	preserve
	clear 
	import excel "$maindir\Firm-Station\Firm_NearTable_Station_withID.xlsx", firstrow
		assert IN_FID == firm_FID
		assert NEAR_FID == station_FI
		keep if NEAR_RANK == 1
		tempfile firm_near_station
		save `firm_near_station'
	restore
	
		capture drop _merge
	merge 1:m firm_ID using `firm_near_station'
		keep if _m == 3 

	* For each firm, find the weather information in the PAST THREE MONTHS from ALL THREE stations
	* For each station, only report visibility data during this period: apdedate-90 ~ apdedate
	drop if mi(apdedate)
	gen Firm_START_DATE = apdedate - 365
	gen Firm_END_DATE = apdedate
	format Firm_START_DATE Firm_END_DATE %td
	
	sort Firm_START_DATE Firm_END_DATE firm_FID
	br Firm_START_DATE Firm_END_DATE

	* Years to keep in the weather data
	gen Firm_START_YEAR = year(Firm_START_DATE)
	gen Firm_END_YEAR = year(Firm_END_DATE)

	gen Num = _n
	
	gen group = 1 if Firm_START_YEAR == Firm_END_YEAR
	replace group = 2 if Firm_START_YEAR != Firm_END_YEAR

	sort Num group
	bysort group (Num): gen Num_temp = _n
	gen Num1 = Num_temp if group == 1
	gen Num2 = Num_temp if group == 2
	drop Num_temp
	
	save "$maindir\One-year Analysis\firm_zipcode_date", replace

