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

**# Prepare data set
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

**# Table A1
global control_variables_aem fog size bm roa lev firm_age rank au_years oa_scale /*xrd_int*/ loss salesgrowth /*Boardindependence*/ lit InstOwn_Perc stockreturn sale_sd rem

global control_variables_rem fog size bm roa lev firm_age rank au_years hhi_sale /*xrd_int*/ loss salesgrowth /*Boardindependence*/ lit InstOwn_Perc stockreturn sale_sd dac

* By Quintiles
sort fog
xtile fog_quintile = fog, nq(5)
label var fog "Fog"
*==================== Regression (Signed) =============================
	eststo clear
forvalues i = 1/5{
eststo regressionT`i'_1: reghdfe dacck visib $control_variables_aem if fog_quintile == `i', absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dacck if fog_quintile == `i'
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
	
eststo regressionT`i'_2: reghdfe dac visib $control_variables_aem if fog_quintile == `i', absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dac if fog_quintile == `i'
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regressionT`i'_3: reghdfe rank_dac visib $control_variables_aem if fog_quintile == `i', absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_dac if fog_quintile == `i'
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regressionT`i'_4: reghdfe rem visib $control_variables_rem if fog_quintile == `i', absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem if fog_quintile == `i'
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regressionT`i'_5: reghdfe rank_rem visib $control_variables_rem if fog_quintile == `i', absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_rem if fog_quintile == `i'
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
}
esttab regressionT1_1 regressionT1_2 regressionT1_3 regressionT1_4 regressionT1_5 using "$output\table_Bottom_fogQuintile.tex", replace fragment label nolines  ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
mtitles("\makecell{AEM \\ (performance- \\ adj.)}" "\makecell{AEM \\ (modified \\ Jones)}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") collabels(none) booktabs ///
stats(yearfe indfe N ar2, fmt(0 0 0 2) labels("Year FE" "Industry FE" "N" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{\textbf{The Effect of Visibility on AEM/REM When Fog Does Not Exist (in the Bottom Fog Quintile)}}\label{tab: fogTercile}\tabcolsep=0.1cm\scalebox{0.55}{\begin{tabular}{lccccc}\toprule") ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\end{table}")
exit

**# Cloud Cover
* See do-file 18

**# Reviewer 2
**# 1) Table B1
global control_variables_aem /*fog*/ size bm roa lev firm_age rank au_years oa_scale /*xrd_int*/
global control_variables_rem /*fog*/ size bm roa lev firm_age rank au_years hhi_sale /*xrd_int*/
use "$output\final_data_47662", replace

 *==================== Regression (Signed) =============================
	eststo clear
eststo regression1: reghdfe stkco visib $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression2: reghdfe stkcpa visib $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

esttab regression1 regression2  using "$output\visib_stock_compensation.tex", replace ///
mtitles("\makecell{Stock compensation \\ balance}" "\makecell{After-tax \\ Stock Compensation}") collabels(none) booktabs label scalar(ymean) ///
stats(yearfe indfe N /*ymean*/ ar2, fmt(0 0 0 /*2*/ 2) labels("Year FE" "Industry FE" "N" /*"Dep mean"*/ "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{\textbf{The Effect of Visibility on Managers' Productivity}}\label{tab: visib_firmprod}\tabcolsep=0.1cm\scalebox{0.75}{\begin{tabular}{lcc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\end{table}") 

**# 2) Table B2
global control_variables_aem fog size bm roa lev firm_age rank au_years oa_scale /*xrd_int*/ loss salesgrowth Boardindependence lit InstOwn_Perc stockreturn sale_sd rem

global control_variables_rem fog size bm roa lev firm_age rank au_years hhi_sale /*xrd_int*/ loss salesgrowth Boardindependence lit InstOwn_Perc stockreturn sale_sd dac

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
label var fog "Fog"

*==================== Regression (Signed) =============================
	eststo clear
eststo regression1: reghdfe dacck visib $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
	
eststo regression2: reghdfe dac visib $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression3: reghdfe rank_dac visib $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression4: reghdfe rem visib $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression5: reghdfe rank_rem visib $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 using "$output\table4_newcontrols_boardind.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
mtitles("\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jones)}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") collabels(none) booktabs label stats(yearfe indfe N /*ymean*/ ar2, fmt(0 0 0 /*2*/ 2) labels("Year FE" "Industry FE" "N" /*"Dep mean"*/ "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{\textbf{The Effect of Visibility on AEM/REM with Additional Control of Board Independence}}\label{tab: table4newcontrols}\tabcolsep=0.1cm\scalebox{0.55}{\begin{tabular}{lccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\end{table}") 

**# 3) Table B3
global control_variables_aem /*fog*/ size bm roa lev firm_age rank au_years oa_scale /*xrd_int*/ loss salesgrowth /*Boardindependence*/ /*lit*/ InstOwn_Perc_D stockreturn sale_sd rem

global control_variables_rem /*fog*/ size bm roa lev firm_age rank au_years hhi_sale /*xrd_int*/ loss salesgrowth /*Boardindependence*/ /*lit*/ InstOwn_Perc_D stockreturn sale_sd dac

use "$output\final_data_47662", replace

xtset lpermno fyear

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

label var salesgrowth "Sales growth"
label var loss "Loss"

gen lit = 1 if (sic >= 2833 & sic <= 2836) | (sic >= 3570 & sic <= 3577) | (sic >= 3600 & sic <=3674) | (sic >= 5200 & sic <= 5961) | (sic >= 7370 & sic <= 7379) | (sic >= 8731 & sic <= 8734)
replace lit = 0 if mi(lit) & !mi(sic)

replace InstOwn_Perc = 0 if mi(InstOwn_Perc)

drop if fyear >= 2007 & fyear <= 2011

gen post = (fyear >= 2012) if !mi(fyear)
label var post "$CAA\_Amend$"
sum InstOwn_Perc, d
local median = r(p50)
gen InstOwn_Perc_D = (InstOwn_Perc >= `median') if !mi(InstOwn_Perc)

label var loss "Loss"
label var salesgrowth "Sales Growth"
label var lit "Litigious"
label var InstOwn_Perc "INST\%"
label var stockreturn "RET"
label var sale_sd "StdSales"
label var sale "Sales"
label var cover "ANAL"
label var hhi_sale "HHI"
label var InstOwn_Perc_D "$INST\%\ge median"

	eststo clear
eststo regression0: reghdfe visib post $control_variables_aem, absorb(ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize visib
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace	

eststo regression1: reghdfe dacck post $control_variables_aem, absorb(ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
	
eststo regression2: reghdfe dac post $control_variables_aem, absorb(ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression3: reghdfe rank_dac post $control_variables_aem, absorb(ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression4: reghdfe rem post $control_variables_rem, absorb(ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression5: reghdfe rank_rem post $control_variables_rem, absorb(ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

esttab regression0 regression1 regression2 regression3 regression4 regression5 using "$output\results_event.tex", replace ///
mgroups("Visibility" "Accrual Earnings Management" "Real Earnings Management", pattern(1 1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) starlevels(* 0.2 ** 0.1 *** 0.02)  ///
mtitles("Visibility" "\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jones)}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") collabels(none) booktabs label scalar(ymean) ///
stats(yearfe indfe N /*ymean*/ ar2, fmt(0 0 0 /*2*/ 2) labels("Year FE" "Industry FE" "N" /*"Dep mean"*/ "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{\textbf{Addressing Endogeneity Using a Policy Event – Clean Air Act Amendment}}\label{tab: table4}\tabcolsep=0.1cm\scalebox{0.55}{\begin{tabular}{lcccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\end{table}") 

**# 4) Table B4
global control_variables_aem fog size bm roa lev firm_age rank au_years oa_scale /*xrd_int*/ loss salesgrowth /*Boardindependence*/ lit InstOwn_Perc stockreturn sale_sd rem

global control_variables_rem fog size bm roa lev firm_age rank au_years hhi_sale /*xrd_int*/ loss salesgrowth /*Boardindependence*/ lit InstOwn_Perc stockreturn sale_sd dac

label var dac "AEM"

use "$output\final_data_47662", replace

xtset lpermno fyear

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

label var salesgrowth "Sales growth"
label var loss "Loss"

gen lit = 1 if (sic >= 2833 & sic <= 2836) | (sic >= 3570 & sic <= 3577) | (sic >= 3600 & sic <=3674) | (sic >= 5200 & sic <= 5961) | (sic >= 7370 & sic <= 7379) | (sic >= 8731 & sic <= 8734)
replace lit = 0 if mi(lit) & !mi(sic)

replace InstOwn_Perc = 0 if mi(InstOwn_Perc)

foreach var of varlist $control_variables_aem dacck dac rank_dac rank_rem hhi_sale visib{
	bysort lpermno (fyear): gen `var'_c = `var' - l1.`var'
}

global change_control_variables_aem size_c bm_c roa_c lev_c firm_age_c rank_c au_years_c oa_scale_c loss_c salesgrowth_c lit_c InstOwn_Perc_c stockreturn_c sale_sd_c rem_c

global change_control_variables_rem size_c bm_c roa_c lev_c firm_age_c rank_c au_years_c hhi_sale_c loss_c salesgrowth_c lit_c InstOwn_Perc_c stockreturn_c sale_sd_c dac_c
*==================== Regression (Signed) =============================
	eststo clear
eststo regression1: reghdfe dacck_c visib_c $change_control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) noconstant
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
	
eststo regression2: reghdfe dac_c visib_c $change_control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) noconstant
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression3: reghdfe rank_dac_c visib_c $change_control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) noconstant
estadd scalar ar2 = e(r2_a)
summarize rank_dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression4: reghdfe rem_c visib_c $change_control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) noconstant
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression5: reghdfe rank_rem_c visib_c $change_control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) noconstant
estadd scalar ar2 = e(r2_a)
summarize rank_rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 using "$output\table4_change.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
mtitles("\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jones)}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") collabels(none) booktabs label scalar(ymean) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{\textbf{The Effect of Visibility on AEM/REM – Change Specification}}\label{tab: table4}\tabcolsep=0.1cm\scalebox{0.55}{\begin{tabular}{lccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: The dependent variables are indicated at the top of each column. The dependent variables in columns 1-3 are: the change in a firms' accrual earnings management calculated using the performance-adjusted modified Jones method, the change in a firm's accrual earnings management calculated using the modified Jones method, and the change in the rank of the firm's accrual earnings management (modified Jones) within the same industry and year, respectively. The dependent variables in columns 4-5 are: the change in a firm's real earnings management and the change in the rank of the firm's real earnings management within the same industry and year, respectively. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm-year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

**# 5) Table B5
global control_variables_aem fog size bm roa lev firm_age rank au_years oa_scale /*xrd_int*/ loss salesgrowth /*Boardindependence*/ lit InstOwn_Perc stockreturn sale_sd rem

global control_variables_rem fog size bm roa lev firm_age rank au_years hhi_sale /*xrd_int*/ loss salesgrowth /*Boardindependence*/ lit InstOwn_Perc stockreturn sale_sd dac

use "$output\final_data_47662", replace

xtset lpermno fyear

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

label var salesgrowth "Sales growth"
label var loss "Loss"

gen lit = 1 if (sic >= 2833 & sic <= 2836) | (sic >= 3570 & sic <= 3577) | (sic >= 3600 & sic <=3674) | (sic >= 5200 & sic <= 5961) | (sic >= 7370 & sic <= 7379) | (sic >= 8731 & sic <= 8734)
replace lit = 0 if mi(lit) & !mi(sic)

replace InstOwn_Perc = 0 if mi(InstOwn_Perc)

sort visib
xtile visib_tercile = visib, nq(3)

*==================== Regression (Signed) =============================
/** Terciles
	eststo clear
forvalues i = 3/3{
eststo regressionT`i'_1: reghdfe dacck visib $control_variables_aem if visib_tercile == `i', absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dacck if visib_tercile == `i'
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
	
eststo regressionT`i'_2: reghdfe dac visib $control_variables_aem if visib_tercile == `i', absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dac if visib_tercile == `i'
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regressionT`i'_3: reghdfe rank_dac visib $control_variables_aem if visib_tercile == `i', absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_dac if visib_tercile == `i'
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regressionT`i'_4: reghdfe rem visib $control_variables_rem if visib_tercile == `i', absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem if visib_tercile == `i'
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regressionT`i'_5: reghdfe rank_rem visib $control_variables_rem if visib_tercile == `i', absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_rem if visib_tercile == `i'
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
}

esttab regressionT3_1 regressionT3_2 regressionT3_3 regressionT3_4 regressionT3_5 using "$output\table_visibTercile.tex", append fragment label nolines ///
posthead("\midrule \multicolumn{6}{c}{\textbf{Top Tercile}} \\") keep(visib) nonumbers nomtitles ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{\textbf{The Effect of Visibility on AEM/REM – Extreme Level of Visibility (Top Tercile)}}\label{tab: visbTercile}\tabcolsep=0.1cm\scalebox{0.8}{\begin{tabular}{lccccc}\toprule") ///
postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: The sample is divided into three subsamples by the magnitude of visibility, and we conduct our main analysis in the top tercile. The dependent variables are indicated at the top of each column. The dependent variables in columns 1-3 are: a firms' accrual earnings management calculated using the performance-adjusted method, a firm's accrual earnings management calculated using the modified Jones method, and the rank of the firm's accrual earnings management (modified Jones), respectively. The dependent variables in columns 4-5 are: a firm's real earnings management, and the rank of the firm's real earnings management, respectively. A description of all regressors can be found in Table A1 in the manuscript. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm-year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

*==================== Regression (Signed) =============================
global control_variables_aem fog size bm roa lev firm_age rank au_years oa_scale /*xrd_int*/ loss salesgrowth /*Boardindependence*/ lit InstOwn_Perc stockreturn sale_sd rem

global control_variables_rem fog size bm roa lev firm_age rank au_years hhi_sale /*xrd_int*/ loss salesgrowth /*Boardindependence*/ lit InstOwn_Perc stockreturn sale_sd dac

use "$output\final_data_47662", replace

xtset lpermno fyear

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

label var salesgrowth "Sales growth"
label var loss "Loss"

gen lit = 1 if (sic >= 2833 & sic <= 2836) | (sic >= 3570 & sic <= 3577) | (sic >= 3600 & sic <=3674) | (sic >= 5200 & sic <= 5961) | (sic >= 7370 & sic <= 7379) | (sic >= 8731 & sic <= 8734)
replace lit = 0 if mi(lit) & !mi(sic)

replace InstOwn_Perc = 0 if mi(InstOwn_Perc)


sort visib
xtile visib_quartile = visib, nq(4)

**# Quartiles
	eststo clear
forvalues i = 4/4{
eststo regressionT`i'_1: reghdfe dacck visib $control_variables_aem if visib_quartile == `i', absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dacck if visib_quartile == `i'
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
	
eststo regressionT`i'_2: reghdfe dac visib $control_variables_aem if visib_quartile == `i', absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dac if visib_quartile == `i'
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regressionT`i'_3: reghdfe rank_dac visib $control_variables_aem if visib_quartile == `i', absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_dac if visib_quartile == `i'
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regressionT`i'_4: reghdfe rem visib $control_variables_rem if visib_quartile == `i', absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem if visib_quartile == `i'
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regressionT`i'_5: reghdfe rank_rem visib $control_variables_rem if visib_quartile == `i', absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_rem if visib_quartile == `i'
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
}

esttab regressionT4_1 regressionT4_2 regressionT4_3 regressionT4_4 regressionT4_5 using "$output\table_visibQuartile.tex", replace fragment label nolines ///
posthead("\midrule \multicolumn{6}{c}{\textbf{Top Quartile}} \\") keep(visib) nonumbers nomtitles ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{\textbf{The Effect of Visibility on AEM/REM – Extreme Level of Visibility (Top Tercile)}}\label{tab: visbTercile}\tabcolsep=0.1cm\scalebox{0.8}{\begin{tabular}{lccccc}\toprule") ///
postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: The sample is divided into four subsamples by the magnitude of visibility, and we conduct our main analysis in the top quartile. The dependent variables are indicated at the top of each column. The dependent variables in columns 1-3 are: a firms' accrual earnings management calculated using the performance-adjusted method, a firm's accrual earnings management calculated using the modified Jones method, and the rank of the firm's accrual earnings management (modified Jones), respectively. The dependent variables in columns 4-5 are: a firm's real earnings management, and the rank of the firm's real earnings management, respectively. A description of all regressors can be found in Table A1 in the manuscript. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm-year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

**# Quintiles
*==================== Regression (Signed) =============================
global control_variables_aem fog size bm roa lev firm_age rank au_years oa_scale /*xrd_int*/ loss salesgrowth /*Boardindependence*/ lit InstOwn_Perc stockreturn sale_sd rem

global control_variables_rem fog size bm roa lev firm_age rank au_years hhi_sale /*xrd_int*/ loss salesgrowth /*Boardindependence*/ lit InstOwn_Perc stockreturn sale_sd dac

use "$output\final_data_47662", replace

xtset lpermno fyear

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

label var salesgrowth "Sales growth"
label var loss "Loss"

gen lit = 1 if (sic >= 2833 & sic <= 2836) | (sic >= 3570 & sic <= 3577) | (sic >= 3600 & sic <=3674) | (sic >= 5200 & sic <= 5961) | (sic >= 7370 & sic <= 7379) | (sic >= 8731 & sic <= 8734)
replace lit = 0 if mi(lit) & !mi(sic)

replace InstOwn_Perc = 0 if mi(InstOwn_Perc)


sort visib
xtile visib_quintile = visib, nq(5)

	eststo clear
forvalues i = 5/5{
eststo regressionT`i'_1: reghdfe dacck visib $control_variables_aem if visib_quintile == `i', absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dacck if visib_quintile == `i'
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
	
eststo regressionT`i'_2: reghdfe dac visib $control_variables_aem if visib_quintile == `i', absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dac if visib_quintile == `i'
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regressionT`i'_3: reghdfe rank_dac visib $control_variables_aem if visib_quintile == `i', absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_dac if visib_quintile == `i'
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regressionT`i'_4: reghdfe rem visib $control_variables_rem if visib_quintile == `i', absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem if visib_quintile == `i'
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regressionT`i'_5: reghdfe rank_rem visib $control_variables_rem if visib_quintile == `i', absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_rem if visib_quintile == `i'
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
}

esttab regressionT5_1 regressionT5_2 regressionT5_3 regressionT5_4 regressionT5_5 using "$output\table_visibQuintile.tex", replace fragment label nolines ///
posthead("\midrule \multicolumn{6}{c}{\textbf{Top Quartile}} \\") keep(visib) nonumbers nomtitles ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{\textbf{The Effect of Visibility on AEM/REM – Extreme Level of Visibility (Top Tercile)}}\label{tab: visbTercile}\tabcolsep=0.1cm\scalebox{0.8}{\begin{tabular}{lccccc}\toprule") ///
postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: The sample is divided into five subsamples by the magnitude of visibility, and we conduct our main analysis in the top quintile. The dependent variables are indicated at the top of each column. The dependent variables in columns 1-3 are: a firms' accrual earnings management calculated using the performance-adjusted method, a firm's accrual earnings management calculated using the modified Jones method, and the rank of the firm's accrual earnings management (modified Jones), respectively. The dependent variables in columns 4-5 are: a firm's real earnings management, and the rank of the firm's real earnings management, respectively. A description of all regressors can be found in Table A1 in the manuscript. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm-year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 
**/

**# Deciles
*==================== Regression (Signed) =============================
global control_variables_aem fog size bm roa lev firm_age rank au_years oa_scale /*xrd_int*/ loss salesgrowth /*Boardindependence*/ lit InstOwn_Perc stockreturn sale_sd rem

global control_variables_rem fog size bm roa lev firm_age rank au_years hhi_sale /*xrd_int*/ loss salesgrowth /*Boardindependence*/ lit InstOwn_Perc stockreturn sale_sd dac

use "$output\final_data_47662", replace
label var fog "Fog"
xtset lpermno fyear

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

gen lit = 1 if (sic >= 2833 & sic <= 2836) | (sic >= 3570 & sic <= 3577) | (sic >= 3600 & sic <=3674) | (sic >= 5200 & sic <= 5961) | (sic >= 7370 & sic <= 7379) | (sic >= 8731 & sic <= 8734)
replace lit = 0 if mi(lit) & !mi(sic)

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

sort visib
xtile visib_decile = visib, nq(10)

	eststo clear
forvalues i = 10/10{
eststo regressionT`i'_1: reghdfe dacck visib $control_variables_aem if visib_decile == `i', absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dacck if visib_decile == `i'
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
	
eststo regressionT`i'_2: reghdfe dac visib $control_variables_aem if visib_decile == `i', absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dac if visib_decile == `i'
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regressionT`i'_3: reghdfe rank_dac visib $control_variables_aem if visib_decile == `i', absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_dac if visib_decile == `i'
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regressionT`i'_4: reghdfe rem visib $control_variables_rem if visib_decile == `i', absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem if visib_decile == `i'
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regressionT`i'_5: reghdfe rank_rem visib $control_variables_rem if visib_decile == `i', absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_rem if visib_decile == `i'
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
}

esttab regressionT10_1 regressionT10_2 regressionT10_3 regressionT10_4 regressionT10_5 using "$output\table_visibDecile.tex", replace fragment label nolines ///
posthead("\midrule") nonumbers ///
stats(yearfe indfe N /*ymean*/ ar2, fmt(0 0 0 /*2*/ 2) labels("Year FE" "Industry FE" "N" /*"Dep mean"*/ "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{\textbf{The Effect of Visibility on AEM/REM – Extreme Level of Visibility (Top Decile)}}\label{tab: visbTercile}\tabcolsep=0.1cm\scalebox{0.6}{\begin{tabular}{lccccc}\toprule") ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
mtitles("\makecell{AEM \\ (performance- \\ adj.)}" "\makecell{AEM \\ (modified \\ Jones)}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") collabels(none) booktabs ///
postfoot("\bottomrule\end{tabular}}\end{center}\end{table}") 