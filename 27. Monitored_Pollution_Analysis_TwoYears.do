clear all

else if "`c(username)'" == "kexin"{
global maindir "E:\21. Air Pollution and Accounting\DATA"
global output "E:\21. Air Pollution and Accounting\RESULTS"
}

else if "`c(username)'" == "Huaxi"{
global maindir "G:\Research材料\21. Air Pollution and Accounting\DATA"

global output "G:\Research材料\21. Air Pollution and Accounting\RESULTS"
}

else if "`c(username)'" == "86156"{
global maindir "E:\Research材料\21. Air Pollution and Accounting\DATA"
global output "E:\Research材料\21. Air Pollution and Accounting\RESULTS"
}

else if "`c(username)'" == "Kexin Zhang"{
global maindir "E:\21. Air Pollution and Accounting\DATA"
global output "E:\21. Air Pollution and Accounting\RESULTS"
set matsize 11000
}

use "$output\final_data_47662", replace

gen utilities_industry = (inrange(sic, 4900, 4999)) if !mi(sic)

drop if utilities_industry == 1

sort lpermno fyear
unique lpermno fyear

gen Num = _n

save "$output\final_data_47662_utilitiesDelete.dta", replace

foreach year of numlist 2002/2017{
clear
import delimited using "$maindir\PMdata\daily_88101_`year'.csv"

gen year_str = substr(datelocal, 1, 4)
gen month_str = substr(datelocal, 6, 2)
gen day_str = substr(datelocal, 9, 2)

destring year_str, gen(year)
destring month_str, gen(month)
destring day_str, gen(day)

gen date = mdy(month, day, year)
format date  %td

keep latitude longitude arithmeticmean stmaxvalue aqi date
save "$maindir\PMdata\PM25_stata\daily`year'.dta", replace
}

forvalues i = 1/11590{
	use "$output\final_data_47662_utilitiesDelete.dta", replace
	keep if Num == `i'
		
	gen fyrday = .
	replace fyrday = 31 if inlist(fyr, 1, 3, 5, 7, 8, 10, 12)
	replace fyrday = 30 if inlist(fyr, 4, 6, 9, 11)
	replace fyrday = 28 if fyr == 2 & mod(fyear, 4) != 0
	replace fyrday = 29 if fyr == 2 & mod(fyear, 4) == 0
	
	gen fyrdate = mdy(fyr, fyrday, fyear)
	format fyrdate %td
	
	gen Firm_START_DATE = fyrdate - 365
	gen Firm_END_DATE = fyrdate
	format Firm_START_DATE Firm_END_DATE %td		

	local Firm_START_DATE = Firm_START_DATE
	local Firm_END_DATE = Firm_END_DATE

	gen Firm_START_YEAR = year(Firm_START_DATE)
	gen Firm_END_YEAR = year(Firm_END_DATE)
	
	local year1 = Firm_START_YEAR
	local year2 = Firm_END_YEAR
	
	local firm_latitude = ZipCodeLatitude 
	local firm_longitude = ZipCodeLongitude

if (Firm_START_YEAR != Firm_END_YEAR){
	use "$maindir\PMdata\PM25_stata\daily`year1'.dta", replace
	append using "$maindir\PMdata\PM25_stata\daily`year2'.dta",gen(append)

	keep if inrange(date, `Firm_START_DATE', `Firm_END_DATE')
	
	gen distance = (latitude - `firm_latitude')^2 + (longitude - `firm_longitude')^2
	
	egen distance_min = min(distance)
	gen station_latitude = latitude if distance == distance_min
	gen station_longitude = longitude if distance == distance_min
	keep if latitude == station_latitude & longitude == station_longitude
	
	count 
	
	collapse arithmeticmean aqi
	
	cd "E:\21. Air Pollution and Accounting\DATA\PMdata\PM2_5_output_files"
	save "`i'", replace
}
}