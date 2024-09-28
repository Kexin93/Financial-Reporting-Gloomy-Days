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
	capture drop _merge
merge m:1 state city fyear using "$maindir\US_PM25_weightedannualmean.dta"
keep if _m == 1 | _m == 3 //3583 observations, or 762 state-city-fyears
label var pollutant_value "PM 2.5"

*ssc install rangestat
	capture drop _merge
merge 1:1 lpermno fyear using "$maindir\sale_sd.dta"
keep if _merge == 1 | _merge == 3

	capture drop _merge
merge 1:1 tic fyear using "$output\board_characteristics"
	keep if _merge == 1 | _merge == 3
	capture drop _merge
merge 1:1 cusip8 fyear using "$output\institutional_ownership_x.dta"
	keep if _merge == 1 | _merge == 3
	replace InstOwn_Perc = 1 if InstOwn_Perc > 1
	replace InstOwn_Perc = 0 if mi(InstOwn_Perc)
	
	capture drop lit
gen lit = 1 if (sic >= 2833 & sic <= 2836) | (sic >= 3570 & sic <= 3577) | (sic >= 3600 & sic <=3674) | (sic >= 5200 & sic <= 5961) | (sic >= 7370 & sic <= 7379) | (sic >= 8731 & sic <= 8734)
replace lit = 0 if mi(lit) & !mi(sic)

label var lit "Litigious"
label var loss "Loss"
label var salesgrowth "Sales Growth"
label var lit "Litigious"
label var InstOwn_Perc "INST\%"
label var stockreturn "RET"
label var sale_sd "StdSales"
label var sale "Sales"
label var cover "ANAL"
label var hhi_sale "HHI"

	gen fyrday = .
	replace fyrday = 31 if inlist(fyr, 1, 3, 5, 7, 8, 10, 12)
	replace fyrday = 30 if inlist(fyr, 4, 6, 9, 11)
	replace fyrday = 28 if fyr == 2
	
	gen fyrdate = mdy(fyr, fyrday, fyear)
	format fyrdate %td
	
	gen Firm_START_DATE = fyrdate - 365
	gen Firm_END_DATE = fyrdate
	format Firm_START_DATE Firm_END_DATE %td

keep fyear fyr Firm_START_DATE Firm_END_DATE lpermno ZipCodeLatitude ZipCodeLongitude ZipCodeState ZipCodeCounty ZipCodeCity city

label var fyear "Fiscal Year"
label var fyr "Month"
label var Firm_START_DATE "Pollution Start Date"
label var Firm_END_DATE "Pollution End Date"
label var lpermno "Firm ID"
label var ZipCodeLatitude "Firm latitude"
label var ZipCodeLongitude "Firm Longitude"
label var ZipCodeState "State"
label var ZipCodeCounty "County"
label var ZipCodeCity "City"
label var city "city"

order lpermno fyear fyr Firm_START_DATE Firm_END_DATE ZipCodeLatitude ZipCodeLongitude, before(ZipCodeCity)
order city, after(ZipCodeCity)

save "$maindir\Firm Data-for Pollution Data\FirmData.dta", replace