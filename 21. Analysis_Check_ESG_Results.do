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

use "$maindir\KLD MSCI", replace
	rename Ticker tic
	rename year fyear
	rename CUSIP cusip8
	unique tic fyear cusip8
	duplicates drop tic fyear, force 
	sum fyear
tempfile KLD_MSCI_tic
save `KLD_MSCI_tic', replace

use "$maindir\KLD MSCI", replace
	rename Ticker tic
	rename year fyear
	rename CUSIP cusip8
	unique tic fyear cusip8
	duplicates drop cusip8 fyear, force 
	sum fyear
tempfile KLD_MSCI_cusip8
save `KLD_MSCI_cusip8', replace

use "$output\final_data_47662", replace
	capture drop CGOV_str_num CGOV_con_num
**# merge with KLD_MSCI indicators
	capture drop _merge
merge 1:1 tic fyear using `KLD_MSCI_tic'

preserve
keep if _merge == 3
tempfile data1
save `data1'
restore

preserve
keep if _merge == 1
	capture drop _merge
merge 1:1 cusip8 fyear using `KLD_MSCI_cusip8'
keep if _merge == 3 | _merge == 1
tempfile data2
save `data2'
restore

use `data1', replace
append using `data2'

* ============ Labeling =================
label var dacck "AEM (performance-adjusted)"
label var firm_ID "firm-year ID"
label var firm_FID "firm FID = firm_ID - 1"
label var dac "AEM (modified Jone's)"
label var absdac "|AEM|" 
label var rank_dac "AEM Rank"
*label var rank_absdac ""
label var rem "REM"
label var absrem "{REM}"
label var rank_rem "REM Rank"
*label var rank_absrem ""
label var stdz_rem "REM Variability"
label var size "Size"
label var bm "BM"
label var roa "ROA"
label var lev "Leverage"
label var oa_scale "NOA"
*label var hhi_sale "HHI"
label var au_years "Auditor Tenure"
label var firm_age "Firm Age"
label var rank "Big N" //binary
label var visib "Visibility"
label var cover "ANAL"
label var KZ "Financial Constraint"

* sales  
label var rank_d_cfo "Rank(REM_CFO)"
label var d_cfo "REM_CFO"

label var d_cfo_neg "REM_CFO"
label var rank_d_cfo_neg "Rank(REM_CFO)"

* over-production
 label var d_prod "REM_PROD"
 label var rank_d_prod "Rank(REM_PROD)"

* expenditure
 label var d_discexp "REM_DISX"
 label var rank_d_discexp " Rank(REM_DISX)"

 label var d_discexp_neg "REM_DISX"
 label var rank_d_discexp_neg "Rank(REM_DISX)"
 
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

label var grow "Sales growth"
label var loss "Loss"

	capture drop lit
gen lit = 1 if (sic >= 2833 & sic <= 2836) | (sic >= 3570 & sic <= 3577) | (sic >= 3600 & sic <=3674) | (sic >= 5200 & sic <= 5961) | (sic >= 7370 & sic <= 7379) | (sic >= 8731 & sic <= 8734)
replace lit = 0 if mi(lit) & !mi(sic)

label var lit "Litigious"
replace InstOwn_Perc = 0 if mi(InstOwn_Perc)

label var loss "Loss"
label var salesgrowth "Sales growth"
label var lit "Litigious"
label var InstOwn_Perc "Institutional Ownership"
label var stockreturn "Stock return"
label var sale_sd "Sales rolling std."

**# Table 8
global control_variables_aem fog size bm roa lev firm_age rank au_years loss salesgrowth lit InstOwn_Perc stockreturn sale_sd oa_scale rem

global control_variables_rem fog size bm roa lev firm_age rank au_years loss salesgrowth lit InstOwn_Perc stockreturn sale_sd hhi_sale dac

global control_variables_aem_t78 size bm roa lev firm_age rank au_years oa_scale /*xrd_int*/
global control_variables_rem_t78 size bm roa lev firm_age rank au_years hhi_sale /*xrd_int*/

*========== Table 15: visibility interacts with internal monitoring to REM ======================== 
* Panel A
label var CGOV_str_num "CG Strengths"
label var CGOV_con_num "CG Concerns"
replace CGOV_str_num = 0 if mi(CGOV_str_num)
replace CGOV_con_num = 0 if mi(CGOV_con_num)
	eststo clear
eststo regression1: reghdfe dacck visib CGOV_str_num c.visib#c.CGOV_str_num $control_variables_aem_t78, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression2: reghdfe dacck visib CGOV_con_num c.visib#c.CGOV_con_num $control_variables_aem_t78, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace
	
eststo regression3: reghdfe dac visib CGOV_str_num c.visib#c.CGOV_str_num $control_variables_aem_t78, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression4: reghdfe dac visib CGOV_con_num c.visib#c.CGOV_con_num $control_variables_aem_t78, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression5: reghdfe rem visib CGOV_str_num c.visib#c.CGOV_str_num $control_variables_rem_t78, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression6: reghdfe rem visib CGOV_con_num c.visib#c.CGOV_con_num $control_variables_rem_t78, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 regression6 using "$output\table15_panelAB.tex", replace fragment ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) drop($control_variables_rem_t78 $control_variables_aem_t78) mtitles("\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jones)}" "\makecell{AEM \\ (modified Jones)}" "REM" "REM") collabels(none) booktabs label scalar(ymean) order(visib CGOV_str_num c.visib#c.CGOV_str_num CGOV_con_num c.visib#c.CGOV_con_num) starlevels(* 0.2 ** 0.1 *** 0.02) ///
stats(firmcont yearfe indfe N ar2, fmt(0 0 0 0 2 2) labels("Baseline Controls" "Year FE" "Industry FE" "N" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Mediating Effect of Corporate Governance on the Relation between Visibility and Earnings Management}\label{tab: table15}\tabcolsep=0.1cm\scalebox{0.65}{\begin{tabular}{lcccccc}\toprule") posthead("\midrule&\multicolumn{6}{c}{\textbf{Panel A: CG =  CG Strengths and Concerns}}\\")

* Panel B
label var boarddiversity "Female Board\%"
label var Boardindependence "Board Ind."
	eststo clear
eststo regression1: reghdfe dacck visib Boardindependence c.visib#c.Boardindependence $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) 
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace
	
eststo regression2: reghdfe dacck visib boarddiversity c.visib#c.boarddiversity $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression3: reghdfe dac visib Boardindependence c.visib#c.Boardindependence $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) 
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression4: reghdfe dac visib boarddiversity c.visib#c.boarddiversity $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression5: reghdfe rem visib Boardindependence c.visib#c.Boardindependence $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression6: reghdfe rem visib boarddiversity c.visib#c.boarddiversity $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 regression6 using "$output\table15_panelAB.tex", append fragment ///
drop($control_variables_rem $control_variables_aem) ///
nomtitles nonumbers collabels(none) booktabs label order(visib Boardindependence c.visib#c.Boardindependence boarddiversity c.visib#c.boarddiversity) starlevels(* 0.2 ** 0.1 *** 0.02) ///
stats(firmcont yearfe indfe N ar2, fmt(0 0 0 0 2 2) labels("Baseline Controls" "Year FE" "Industry FE" "N" "Adjusted R-sq")) ///
posthead("\midrule&\multicolumn{6}{c}{\textbf{Panel B: CG = Board Independence or Female Board\%}}\\") postfoot("\bottomrule\end{tabular}}\end{center}\end{table}") 


* Panel C
	capture drop _merge
merge 1:1 tic fyear using "$output\GINDEX_x.dta"
	keep if _merge == 1 | _merge == 3

	capture drop _merge
merge 1:1 tic fyear using "$output\governance_iss_s"
	keep if _merge == 1 | _merge == 3

	label var ppill "Poison Pill"
	
eststo regression1: reghdfe dacck visib gparachute c.visib#c.gparachute $control_variables_aem_t78, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression2: reghdfe dacck visib ppill c.visib#c.ppill $control_variables_aem_t78, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace
	
eststo regression3: reghdfe dac visib gparachute c.visib#c.gparachute $control_variables_aem_t78, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression4: reghdfe dac visib ppill c.visib#c.ppill $control_variables_aem_t78, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression5: reghdfe rem visib gparachute c.visib#c.gparachute $control_variables_rem_t78, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression6: reghdfe rem visib ppill c.visib#c.ppill $control_variables_rem_t78, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 regression6 using "$output\table15_panelCD.tex", replace fragment ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) drop($control_variables_rem_t78 $control_variables_aem_t78) mtitles("\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jones)}" "\makecell{AEM \\ (modified Jones)}" "REM" "REM")  collabels(none) booktabs label stats(firmcont yearfe indfe N ar2, fmt(0 0 0 0 2 2) labels("Baseline Controls" "Year FE" "Industry FE" "N" "Adjusted R-sq")) order(visib gparachute c.visib#c.gparachute ppill c.visib#c.ppill) prehead("\begin{table}\begin{center}\scalebox{0.6}{\begin{tabular}{lcccccc}\toprule") posthead("\midrule&\multicolumn{6}{c}{\textbf{Panel C: CG = Golden Parachute or Poison Pill}}\\") /*starlevels(* 0.2 ** 0.1 *** 0.02)*/

* Panel D
	capture drop _merge
merge 1:1 lpermco fyear using "$output\CEO_duality_x.dta"
	keep if _merge == 1 | _merge == 3

	capture drop _merge
merge 1:1 tic fyear using "$output\board_characteristics", force
	keep if _merge == 1 | _merge == 3
	
label var dual_max "CEO-Chairman Duality"
	eststo clear
eststo regression1: reghdfe dacck  visib CEOduality c.visib#c.CEOduality $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression2: reghdfe dacck visib dual_max c.visib#c.dual_max $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace
	
eststo regression3: reghdfe dac visib CEOduality c.visib#c.CEOduality $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression4: reghdfe dac visib dual_max c.visib#c.dual_max $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression5: reghdfe rem visib CEOduality c.visib#c.CEOduality $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression6: reghdfe rem visib dual_max c.visib#c.dual_max $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 regression6 using "$output\table15_panelCD.tex", append fragment ///
drop($control_variables_rem $control_variables_aem) ///
mtitles("Duality 1" "Duality 2" "Duality 1" "Duality 2" "Duality 1" "Duality 2") nonumbers collabels(none) booktabs label order(visib CEOduality c.visib#c.CEOduality dual_max c.visib#c.dual_max) ///
stats(firmcont yearfe indfe N ar2, fmt(0 0 0 0 2 2) labels("Baseline Controls" "Year FE" "Industry FE" "N" "Adjusted R-sq")) starlevels(* 0.2 ** 0.1 *** 0.02) ///
posthead("\midrule&\multicolumn{6}{c}{\textbf{Panel D: CG = CEO-Chairman Duality}}\\") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table presents the regression results to test the mediating effect of corporate governance on the relation between Visibility and AEM/REM. We use CG Strengths and CG Concerns in Panel A, Board Independence and Female Ratio on Boards in Panel B, Golden Parachute and Poison Pill in Panel C, and CEO-Chairman Duality in Panel D, respectively, as the proxy for corporate governance. See Appendix A for detailed variable definitions. Numbers in parentheses represent t-statistics calculated based on standard errors clustered at the industry-year level. ***, **, and * indicate statistical significance at the 1\%, 5\%, and 10\% levels, respectively.}\end{table}") 
