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

global control_variables_aem size bm roa lev firm_age rank au_years oa_scale /*xrd_int*/ loss salesgrowth /*Boardindependence*/ lit InstOwn_Perc stockreturn sale_sd rem

global control_variables_rem size bm roa lev firm_age rank au_years hhi_sale /*xrd_int*/ loss salesgrowth /*Boardindependence*/ lit InstOwn_Perc stockreturn sale_sd dac

use "$output\final_data_47662", replace
	capture drop _merge
merge 1:1 lpermno fyear using "$maindir\sale_sd.dta"
keep if _merge == 1 | _merge == 3

	capture drop _merge
merge 1:1 tic fyear using "$output\board_characteristics"
	keep if _merge == 1 | _merge == 3
	capture drop _merge
merge 1:1 cusip8 fyear using "$output\institutional_ownership_x.dta"
	keep if _merge == 1 | _merge == 3

	label var loss "Loss"

gen lit = 1 if (sic >= 2833 & sic <= 2836) | (sic >= 3570 & sic <= 3577) | (sic >= 3600 & sic <=3674) | (sic >= 5200 & sic <= 5961) | (sic >= 7370 & sic <= 7379) | (sic >= 8731 & sic <= 8734)
replace lit = 0 if mi(lit) & !mi(sic)

label var lit "Litigious"
replace InstOwn_Perc = 0 if mi(InstOwn_Perc)

* Firm latitude-longitude
sum ZipCodeLongitude ZipCodeLatitude
sum fyear // 2003-2017
br fyear fyr // 2023.01 - 2017.06

**# 1) Split Excel sheets, 2) For each year and month: change to panel structure

	local startrow = 122749
forvalues year = 2002/2017{
forvalues month = 1/12{
	local endrow = `startrow' + 192 
import excel using "$maindir\cloud cover\cloud_cover.xlsx", cellrange(A`startrow':CQ`endrow') clear firstrow

local i = 1
foreach var of varlist B-CQ{
	rename `var' v`i'
	local ++i
}

rename *`year' longitude
label var longitude "Longitude"
reshape long v, i(longitude) j(latitude_N)
rename v cloud_cover
label var cloud_cover "Cloud cover"

gen latitude = .
replace latitude = 88.542 if  latitude_N == 1
replace latitude = 86.6532 if  latitude_N == 2
replace latitude = 84.7532 if  latitude_N == 3
replace latitude = 82.8508 if  latitude_N == 4
replace latitude = 80.9474 if  latitude_N == 5
replace latitude = 79.0435 if  latitude_N == 6
replace latitude = 77.1394 if  latitude_N == 7
replace latitude = 75.2351 if  latitude_N == 8
replace latitude = 73.3307 if  latitude_N == 9
replace latitude = 71.4262 if  latitude_N == 10
replace latitude = 69.5217 if  latitude_N == 11
replace latitude = 67.6171 if  latitude_N == 12
replace latitude = 65.7125 if  latitude_N == 13
replace latitude = 63.8079 if  latitude_N == 14
replace latitude = 61.9033 if  latitude_N == 15
replace latitude = 59.9986 if  latitude_N == 16
replace latitude = 58.0939 if  latitude_N == 17
replace latitude = 56.1893 if  latitude_N == 18
replace latitude = 54.2846 if  latitude_N == 19
replace latitude = 52.3799 if  latitude_N == 20
replace latitude = 50.4752 if  latitude_N == 21
replace latitude = 48.5705 if  latitude_N == 22
replace latitude = 46.6658 if  latitude_N == 23
replace latitude = 44.7611 if  latitude_N == 24
replace latitude = 42.8564 if  latitude_N == 25
replace latitude = 40.9517 if  latitude_N == 26
replace latitude = 39.047 if  latitude_N == 27
replace latitude = 37.1423 if  latitude_N == 28
replace latitude = 35.2375 if  latitude_N == 29
replace latitude = 33.3328 if  latitude_N == 30
replace latitude = 31.4281 if  latitude_N == 31
replace latitude = 29.5234 if  latitude_N == 32
replace latitude = 27.6186 if  latitude_N == 33
replace latitude = 25.7139 if  latitude_N == 34
replace latitude = 23.8092 if  latitude_N == 35
replace latitude = 21.9044 if  latitude_N == 36
replace latitude = 19.9997 if  latitude_N == 37
replace latitude = 18.095 if  latitude_N == 38
replace latitude = 16.1902 if  latitude_N == 39
replace latitude = 14.2855 if  latitude_N == 40
replace latitude = 12.3808 if  latitude_N == 41
replace latitude = 10.476 if  latitude_N == 42
replace latitude = 8.57131 if  latitude_N == 43
replace latitude = 6.66657 if  latitude_N == 44
replace latitude = 4.76184 if  latitude_N == 45
replace latitude = 2.8571 if  latitude_N == 46
replace latitude = 0.952368 if  latitude_N == 47
replace latitude = -0.952368 if  latitude_N == 48
replace latitude = -2.8571 if  latitude_N == 49
replace latitude = -4.76184 if  latitude_N == 50
replace latitude = -6.66657 if  latitude_N == 51
replace latitude = -8.57131 if  latitude_N == 52
replace latitude = -10.476 if  latitude_N == 53
replace latitude = -12.3808 if  latitude_N == 54
replace latitude = -14.2855 if  latitude_N == 55
replace latitude = -16.1902 if  latitude_N == 56
replace latitude = -18.095 if  latitude_N == 57
replace latitude = -19.9997 if  latitude_N == 58
replace latitude = -21.9044 if  latitude_N == 59
replace latitude = -23.8092 if  latitude_N == 60
replace latitude = -25.7139 if  latitude_N == 61
replace latitude = -27.6186 if  latitude_N == 62
replace latitude = -29.5234 if  latitude_N == 63
replace latitude = -31.4281 if  latitude_N == 64
replace latitude = -33.3328 if  latitude_N == 65
replace latitude = -35.2375 if  latitude_N == 66
replace latitude = -37.1423 if  latitude_N == 67
replace latitude = -39.047 if  latitude_N == 68
replace latitude = -40.9517 if  latitude_N == 69
replace latitude = -42.8564 if  latitude_N == 70
replace latitude = -44.7611 if  latitude_N == 71
replace latitude = -46.6658 if  latitude_N == 72
replace latitude = -48.5705 if  latitude_N == 73
replace latitude = -50.4752 if  latitude_N == 74
replace latitude = -52.3799 if  latitude_N == 75
replace latitude = -54.2846 if  latitude_N == 76
replace latitude = -56.1893 if  latitude_N == 77
replace latitude = -58.0939 if  latitude_N == 78
replace latitude = -59.9986 if  latitude_N == 79
replace latitude = -61.9033 if  latitude_N == 80
replace latitude = -63.8079 if  latitude_N == 81
replace latitude = -65.7125 if  latitude_N == 82
replace latitude = -67.6171 if  latitude_N == 83
replace latitude = -69.5217 if  latitude_N == 84
replace latitude = -71.4262 if  latitude_N == 85
replace latitude = -73.3307 if  latitude_N == 86
replace latitude = -75.2351 if  latitude_N == 87
replace latitude = -77.1394 if  latitude_N == 88
replace latitude = -79.0435 if  latitude_N == 89
replace latitude = -80.9474 if  latitude_N == 90
replace latitude = -82.8508 if  latitude_N == 91
replace latitude = -84.7532 if  latitude_N == 92
replace latitude = -86.6532 if  latitude_N == 93
replace latitude = -88.542 if  latitude_N == 94

label var latitude "Latitude"
drop latitude_N
gen year = `year'
gen month = `month'
label var year "Year"
label var month "Month"
order year month latitude longitude cloud_cover
count // 18048 = 192 * 94
local startrow = `endrow' + 1
cd "$maindir\cloud cover\monthly data"
save "`year'm`month'.dta", replace
}
}

**# 3) For each firm, allocate the latitude + longitude pair, average cloud cover over 12 months
use "$output\final_data_47662", replace
sum ZipCodeLongitude ZipCodeLatitude
sum fyear fyr // 2003-2017

rename (fyear fyr)(year month)
unique lpermno year //12191
sort year month lpermno
gen Num = _n

* Convert longitude from (-180, 180) to (0,360) format
replace ZipCodeLongitude = ZipCodeLongitude + 360 if ZipCodeLongitude <0
sum ZipCodeLongitude

forvalues i = 1/12191{	
		keep if Num == `i'
		
		sum ZipCodeLatitude ZipCodeLongitude
		sum year month
		preserve
			gen fyrday = .
			replace fyrday = 31 if inlist(month, 1, 3, 5, 7, 8, 10, 12)
			replace fyrday = 30 if inlist(month, 4, 6, 9, 11)
			replace fyrday = 28 if month == 2
			
			gen fyrdate = mdy(month, fyrday, year)
			format fyrdate %td
			
			gen firm_start_date = fyrdate - 365
			gen firm_end_date = fyrdate
			format firm_start_date firm_end_date %td
			
			local start_year = year(firm_start_date)
			local start_month = month(firm_start_date)
			local end_year = year(firm_end_date)
			local end_month = month(firm_end_date)
			
			local firm_latitude = ZipCodeLatitude
			local firm_longitude = ZipCodeLongitude
			
			clear
				cd "$maindir\cloud cover\monthly data"
				
				* Open any data set, find the latitude & longitude to be used for this firm
				use 2003m1.dta, replace
				gen distance = sqrt((latitude - `firm_latitude')^2 + (longitude - `firm_longitude')^2)
				egen distance_min = min(distance)
				gen cloud_latitude = latitude if distance == distance_min
					sum cloud_latitude
					local cloud_latitude = r(mean)
				gen cloud_longitude = longitude if distance == distance_min
					sum cloud_longitude
					local cloud_longitude = r(mean)

				local k = 1
				local loop_start_month = `start_month'+1
				
				forvalues year = `start_year'/`end_year'{
					if `loop_start_month' > 12{
						local loop_start_month = 1
					}
					while `loop_start_month' <= 12 & `k' <= 12 {
					use `year'm`loop_start_month', replace
					keep if latitude == `cloud_latitude' & longitude == `cloud_longitude'
					tempfile data`k'
					save `data`k''
					local ++k
					
					local loop_start_month = `loop_start_month' + 1
					}
				}
				
				use `data1', replace
				forvalues x = 2/12{
					append using `data`x'', gen(append)
					drop append
				}
				di `end_year'
				di `end_month'
				ta year
				ta month
				ta year month
				
				replace year = `end_year'
				replace month = `end_month'
				tempfile cloud_cover_12mths
				save `cloud_cover_12mths', replace
		restore
		
			capture drop _merge
		merge 1:m year month using `cloud_cover_12mths'
		
		keep if _merge == 3
		drop _merge
		collapse (mean) cloud_cover Num
			
			local j = Num
			cd "$maindir\cloud cover\firm_level_cloudcover"
			save "`j'", replace
			
			
		clear 
		use "$output\final_data_47662", replace

		rename (fyear fyr)(year month)
		unique year month lpermno //12191
		sort year month lpermno
		gen Num = _n

		* Convert longitude from (-180, 180) to (0,360) format
		replace ZipCodeLongitude = ZipCodeLongitude + 360 if ZipCodeLongitude <0
		sum ZipCodeLongitude

		}
		
		
* Append all files
		cd "$maindir\cloud cover\firm_level_cloudcover"
		clear 
		fs "*.dta"
		append using `r(files)',force
		sort Num
		save "$maindir\cloud cover\firm_level_cloudcover\cloud_cover_12191_firms", replace //22590
		
* Merge 12191 firms with cloud cover data
use "$output\final_data_47662", replace
	capture drop _merge
merge 1:1 lpermno fyear using "$maindir\sale_sd.dta"
keep if _merge == 1 | _merge == 3

	capture drop _merge
merge 1:1 tic fyear using "$output\board_characteristics"
	keep if _merge == 1 | _merge == 3
	capture drop _merge
merge 1:1 cusip8 fyear using "$output\institutional_ownership_x.dta"
	keep if _merge == 1 | _merge == 3

	label var loss "Loss"

gen lit = 1 if (sic >= 2833 & sic <= 2836) | (sic >= 3570 & sic <= 3577) | (sic >= 3600 & sic <=3674) | (sic >= 5200 & sic <= 5961) | (sic >= 7370 & sic <= 7379) | (sic >= 8731 & sic <= 8734)
replace lit = 0 if mi(lit) & !mi(sic)

label var lit "Litigious"
replace InstOwn_Perc = 0 if mi(InstOwn_Perc)

		rename (fyear fyr)(year month)
		unique year month lpermno //12191
		sort year month lpermno
		gen Num = _n

		* Convert longitude from (-180, 180) to (0,360) format
		replace ZipCodeLongitude = ZipCodeLongitude + 360 if ZipCodeLongitude <0
		sum ZipCodeLongitude

merge 1:1 Num using "$maindir\cloud cover\firm_level_cloudcover\cloud_cover_12191_firms", gen(m)
	keep if m == 3
	drop m

* Tercile analysis using cloud cover
global control_variables_aem fog size bm roa lev firm_age rank au_years loss salesgrowth lit InstOwn_Perc stockreturn sale_sd oa_scale rem

global control_variables_rem fog size bm roa lev firm_age rank au_years loss salesgrowth lit InstOwn_Perc stockreturn sale_sd hhi_sale dac

sort cloud_cover
xtile cloud_cover_tercile = cloud_cover, nq(3)
label var cloud_cover "Cloud cover"
label var loss "Loss"
label var salesgrowth "Sales Growth"
label var lit "Litigious"
label var InstOwn_Perc "INST\%"
label var stockreturn "RET"
label var sale_sd "StdSales"
label var sale "Sales"
label var cover "ANAL"
label var hhi_sale "HHI"


rename (year month)(fyear fyr)
*==================== Regression (Signed) =============================
	eststo clear
forvalues i = 1/3{
eststo regressionT`i'_1: reghdfe dacck visib $control_variables_aem fog if cloud_cover_tercile == `i', absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dacck if cloud_cover_tercile == `i'
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace
	
eststo regressionT`i'_2: reghdfe dac visib $control_variables_aem fog if cloud_cover_tercile == `i', absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dac if cloud_cover_tercile == `i'
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regressionT`i'_3: reghdfe rank_dac visib $control_variables_aem fog if cloud_cover_tercile == `i', absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_dac if cloud_cover_tercile == `i'
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regressionT`i'_4: reghdfe rem visib $control_variables_rem if cloud_cover_tercile == `i', absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem if cloud_cover_tercile == `i'
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regressionT`i'_5: reghdfe rank_rem visib $control_variables_rem if cloud_cover_tercile == `i', absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_rem if cloud_cover_tercile == `i'
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace
}

esttab regressionT1_1 regressionT1_2 regressionT1_3 regressionT1_4 regressionT1_5 using "$output\table_CloudCoverTercile.tex", replace fragment label nolines  ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) keep(visib) ///
mtitles("\makecell{AEM \\ (performance- \\ adj.)}" "\makecell{AEM \\ (modified \\ Jones')}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") collabels(none) booktabs ///
stats(firmcont yearfe indfe N ymean ar2, fmt(0 0 0 0 2 2) labels("Baseline Controls" "Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{\textbf{The Effect of Visibility on Earnings Management by Terciles of Cloud Cover}}\label{tab: CloudCoverTercile}\tabcolsep=0.1cm\scalebox{0.8}{\begin{tabular}{lccccc}\toprule") ///
posthead("\midrule\multicolumn{6}{c}{\textbf{First Tercile}}\\") 

esttab regressionT2_1 regressionT2_2 regressionT2_3 regressionT2_4 regressionT2_5 using "$output\table_CloudCoverTercile.tex", append fragment label nolines ///
stats(firmcont yearfe indfe N ymean ar2, fmt(0 0 0 0 2 2) labels("Baseline Controls" "Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
posthead("\midrule\multicolumn{6}{c}{\textbf{Second Tercile}} \\") keep(visib) nonumbers nomtitles

esttab regressionT3_1 regressionT3_2 regressionT3_3 regressionT3_4 regressionT3_5 using "$output\table_CloudCoverTercile.tex", append fragment label nolines ///
posthead("\midrule \multicolumn{6}{c}{\textbf{Third Tercile}} \\") keep(visib) nonumbers nomtitles ///
stats(firmcont yearfe indfe N ymean ar2, fmt(0 0 0 0 2 2) labels("Baseline Controls" "Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: The sample is divided into three subsamples by the magnitude of cloud cover over the 12 months prior to each firm's fiscal year end, namely, the first tercile, second tercile, and the third tercile. The dependent variables are indicated at the top of each column. The same set of baseline control variables are included as in Table 5 of the manuscript. The dependent variables in columns 1-3 are: a firms' accrual earnings management calculated using the performance-adjusted method, a firm's accrual earnings management calculated using the modified Jones method, and the rank of the firm's accrual earnings management (modified Jones), respectively. The dependent variables in columns 4-5 are: a firm's real earnings management, and the rank of the firm's real earnings management, respectively. Year fixed effects and industry fixed effects are included in all regressions. Refer to Appendices A to C for detailed variable definitions and measurements. A description of all variables can be found in Table A1 in the main manuscript. Standard errors are clustered at the level of firm-year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 
exit

**# Include cloud cover as an additional control variable
*==================== Regression (Signed) =============================
	eststo clear
eststo regression1: reghdfe dacck visib cloud_cover $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
	
eststo regression2: reghdfe dac visib cloud_cover $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression3: reghdfe rank_dac visib cloud_cover $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression4: reghdfe rem visib cloud_cover $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression5: reghdfe rank_rem visib cloud_cover $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 using "$output\table4_cloud_cover_newcontrols.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
mtitles("\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jones')}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") collabels(none) booktabs label scalar(ymean) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management}\label{tab: table4newcontrols}\tabcolsep=0.1cm\scalebox{0.8}{\begin{tabular}{lccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: The dependent variables are indicated at the top of each column. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variables in columns (1)-(3) are: a firms' accrual earnings management calculated using the performance-adjusted method, a firm's accrual earnings management calculated using the modified Jones method, and the rank of the firm's accrual earnings management (modified Jones), respectively. The dependent variables in columns (4)-(5) are: a firm's real earnings management, and the rank of the firm's real earnings management, respectively. The control variables include: firm size, book-to-market ratio, return on assets, leverage ratio, firm age, Big N auditor, number of years that a firm was audited by the same auditor, sale loss, sale growth, board independence, litigious industry, institutional ownership, stock return, 3-year rolling standard deviation of sales, REM (for AEM), AEM (for REM), net operating assets (with dependent variable being AEM, and Herfindahl–Hirschman index (with dependent variable being REM. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm-year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

