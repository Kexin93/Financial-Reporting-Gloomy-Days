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

global summ_vars dacck dac rank_dac rem rank_rem stdz_rem d_cfo_neg rank_d_cfo_neg d_prod rank_d_prod ///
d_discexp_neg rank_d_discexp_neg size bm roa lev firm_age rank au_years loss sale salesgrowth lit InstOwn_Perc   stockreturn sale_sd oa_scale hhi_sale cover pollutant_value

global control_variables_aem fog size bm roa lev firm_age rank au_years loss salesgrowth lit InstOwn_Perc stockreturn sale_sd oa_scale rem

global control_variables_rem fog size bm roa lev firm_age rank au_years loss salesgrowth lit InstOwn_Perc stockreturn sale_sd hhi_sale dac

global control_variables fog size bm roa lev firm_age /*rank au_years oa_scale*/ hhi_sale loss salesgrowth /*lit*/ InstOwn_Perc /*sale_sd*/ 

use "$output\final_data_47662", replace
	capture drop _merge
merge m:1 state city fyear using "$maindir\US_PM25_weightedannualmean.dta"
keep if _m == 1 | _m == 3 //3583 observations, or 762 state-city-fyears
label var pollutant_value "PM 2.5"
rename pollutant_value pollutant_value_PM25

	capture drop _merge
merge m:1 state city fyear using "$maindir\US_PM10_2ndMax.dta"
keep if _m == 1 | _m == 3 //3583 observations, or 762 state-city-fyears
label var pollutant_value "PM 10"
rename pollutant_value pollutant_value_PM10

	capture drop _merge
merge m:1 state city fyear using "$maindir\US_NO2_annualmean.dta"
keep if _m == 1 | _m == 3 //3583 observations, or 762 state-city-fyears
label var pollutant_value "NO2"
rename pollutant_value pollutant_value_NO2

	capture drop _merge
merge m:1 state city fyear using "$maindir\US_O3_4thMax.dta"
keep if _m == 1 | _m == 3 //3583 observations, or 762 state-city-fyears
label var pollutant_value "O3"
rename pollutant_value pollutant_value_O3

	capture drop _merge
merge m:1 state city fyear using "$maindir\US_SO2_99Perc.dta"
keep if _m == 1 | _m == 3 //3583 observations, or 762 state-city-fyears
label var pollutant_value "SO2"
rename pollutant_value pollutant_value_SO2

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

	capture drop lit
gen lit = 1 if (sic >= 2833 & sic <= 2836) | (sic >= 3570 & sic <= 3577) | (sic >= 3600 & sic <=3674) | (sic >= 5200 & sic <= 5961) | (sic >= 7370 & sic <= 7379) | (sic >= 8731 & sic <= 8734)
replace lit = 0 if mi(lit) & !mi(sic)

label var lit "Litigious"
replace InstOwn_Perc = 0 if mi(InstOwn_Perc)

label var loss "Loss"
label var salesgrowth "Sales Growth"
label var lit "Litigious"
label var InstOwn_Perc "INST\%"
label var stockreturn "RET"
label var sale_sd "StdSales"
label var sale "Sales"
label var cover "ANAL"
label var hhi_sale "HHI"

global first_stage size bm roa lev firm_age rank au_years oa_scale hhi_sale /*xrd_int*/

/*
reghdfe visib pollutant_value $control_variables_aem, absorb(i.fyear i.ff_48) vce(cluster i.lpermno#i.fyear)
predict visib_PM2_5_aem, xb
label var visib_PM2_5_aem "Fitted visibility (AEM)"

reghdfe visib pollutant_value $control_variables_rem, absorb(i.fyear i.ff_48) vce(cluster i.lpermno#i.fyear)
predict visib_PM2_5_rem, xb
label var visib_PM2_5_rem "Fitted visibility (REM)"
*/

gen utilities_industry = (inrange(sic, 4900, 4999)) if !mi(sic)

drop if utilities_industry == 1

reghdfe visib pollutant_value_PM25 pollutant_value_PM10 /*pollutant_value_NO2*/ pollutant_value_O3 pollutant_value_SO2 $first_stage, absorb(i.fyear i.ff_48) vce(cluster i.lpermno#i.fyear)
predict visib_pollutants1, xb
label var visib_pollutants1 "Fitted Visibility"

reghdfe visib pollutant_value_PM25 pollutant_value_PM10 /*pollutant_value_NO2*/ pollutant_value_O3 /*pollutant_value_SO2*/ $first_stage, absorb(i.fyear i.ff_48) vce(cluster i.lpermno#i.fyear)
predict visib_pollutants2, xb
label var visib_pollutants2 "Fitted Visibility"

reghdfe visib pollutant_value_PM25 pollutant_value_PM10 /*pollutant_value_NO2 pollutant_value_O3 pollutant_value_SO2*/ $first_stage, absorb(i.fyear i.ff_48) vce(cluster i.lpermno#i.fyear)
predict visib_pollutants3, xb
label var visib_pollutants3 "Fitted Visibility"

**# Table 5
label var dac "AEM"
label var pollutant_value_PM25 "PM 2.5 (Weighted Annual Mean)"

*==================== Regression (Signed) =============================
	eststo clear
eststo regression1: reghdfe dacck visib_pollutants1 $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
	
eststo regression2: reghdfe dac visib_pollutants1 $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression3: reghdfe rank_dac visib_pollutants1 $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression4: reghdfe rem visib_pollutants1 $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression5: reghdfe rank_rem visib_pollutants1 $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 using "$output\table4_alternativePollutionM.tex", replace fragment ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
mtitles("\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jones)}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") collabels(none) booktabs label scalar(ymean) keep(visib_pollutants1)  ///
stats(yearfe indfe N ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{Results using alternative air pollution measures}\label{tab: table4Alternative}\tabcolsep=0.1cm\scalebox{0.6}{\begin{tabular}{lccccc}\toprule")  ///
posthead("\midrule &\multicolumn{5}{c}{\textbf{Panel A: Fitted Visibility using PM 2.5, PM 10, O3, and SO2}}\\") 

*==================== Regression (Signed) =============================
	eststo clear
eststo regression1: reghdfe dacck visib_pollutants2 $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
	
eststo regression2: reghdfe dac visib_pollutants2 $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression3: reghdfe rank_dac visib_pollutants2 $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression4: reghdfe rem visib_pollutants2 $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression5: reghdfe rank_rem visib_pollutants2 $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 using "$output\table4_alternativePollutionM.tex", append nonumbers fragment nomtitles collabels(none) booktabs label scalar(ymean) keep(visib_pollutants2) ///
stats(yearfe indfe N ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Adjusted R-sq")) posthead("\midrule &\multicolumn{5}{c}{\textbf{Panel B: Fitted Visibility using PM 2.5, PM 10, and O3}}\\") 

*==================== Regression (Signed) =============================
	eststo clear
eststo regression1: reghdfe dacck visib_pollutants3 $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
	
eststo regression2: reghdfe dac visib_pollutants3 $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression3: reghdfe rank_dac visib_pollutants3 $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression4: reghdfe rem visib_pollutants3 $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression5: reghdfe rank_rem visib_pollutants3 $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 using "$output\table4_alternativePollutionM.tex", append fragment nomtitles nonumbers collabels(none) booktabs label scalar(ymean) keep(visib_pollutants3) ///
stats(yearfe indfe N ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Adjusted R-sq")) posthead("\midrule &\multicolumn{5}{c}{\textbf{Panel C: Fitted Visibility using PM 2.5 and PM 10}}\\") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table presents the main regression results to test our hypotheses on the effect of the fitted visibility using PM 2.5, PM 10, O3, and SO2 on AEM and REM. See Appendix A for detailed variable definitions. Numbers in parentheses represent t-statistics calculated based on standard errors clustered at the industry-year level. ***, **, and * indicate statistical significance at the 1\%, 5\%, and 10\% levels, respectively.}\end{table}") 
