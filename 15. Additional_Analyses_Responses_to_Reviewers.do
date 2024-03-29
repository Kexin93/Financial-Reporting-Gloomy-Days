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

// use "$maindir\KLD MSCI", replace
// drop if mi(ENV_str_num) | mi(ENV_con_num) | mi(COM_str_num) | mi(COM_con_num) | ///
// mi(HUM_con_num) | mi(EMP_str_num) | mi(EMP_con_num) | mi(DIV_str_num) | mi(DIV_con_num) ///
// | mi(PRO_str_num) | mi(PRO_con_num) | mi(CGOV_str_num) | mi(CGOV_con_num) | mi(HUM_str_num)
// 	rename Ticker tic
// 	rename year fyear
// 	rename CUSIP cusip8
// 	unique tic fyear cusip8
// 	duplicates drop tic fyear, force 
// tempfile KLD_MSCI_tic
// save `KLD_MSCI_tic', replace
//
// use "$maindir\KLD MSCI", replace
// drop if mi(ENV_str_num) | mi(ENV_con_num) | mi(COM_str_num) | mi(COM_con_num) | ///
// mi(HUM_con_num) | mi(EMP_str_num) | mi(EMP_con_num) | mi(DIV_str_num) | mi(DIV_con_num) ///
// | mi(PRO_str_num) | mi(PRO_con_num) | mi(CGOV_str_num) | mi(CGOV_con_num) | mi(HUM_str_num)
// 	rename Ticker tic
// 	rename year fyear
// 	rename CUSIP cusip8
// 	unique tic fyear cusip8
// 	duplicates drop cusip8 fyear, force 
// tempfile KLD_MSCI_cusip8
// save `KLD_MSCI_cusip8', replace
//
// use "$output\convk.dta", replace
// keep fyear lpermno dacck
// tempfile convk
// save `convk', replace
//
// *br tic cusip ncusip ibes_cusip cusip8
// *use "$maindir\Analysis_102148 observations\Firm_Year_Weather", replace
//
// global control_variables_aem size bm roa lev firm_age rank au_years oa_scale /*xrd_int*/
// global control_variables_rem size bm roa lev firm_age rank au_years hhi_sale /*xrd_int*/
//
// /*Cleaning*/
//
// * Drop observations with duplicate lpermco-fyear
// bysort lpermco fyear: gen dup = _n
// bysort lpermco fyear: egen dup2 = max(dup)
// drop if dup2 > 1 //128
//
// /*Table 1: Summary Statistics*/
// global summ_vars dacck dac rank_dac rem rank_rem stdz_rem d_cfo_neg rank_d_cfo_neg d_prod rank_d_prod ///
// d_discexp_neg rank_d_discexp_neg size bm roa lev firm_age rank au_years /*<--tenure*/ oa_scale hhi_sale cover sale /*<--noa*/ /*xrd_int */ /*cycle*/
//
// *============= Constructing Variables ===================
// gen xrd_int= xrd/ sale
// label var xrd_int "RD Intensity"
//
// * Firm age
// 	preserve
// 	clear
// 	use "$maindir\Firm age\firm age", replace
// 	keep found_yr cusip fyear firm_age
// 	rename firm_age firm_age_old
// 	tempfile firm_age
// 	save `firm_age', replace
// 	restore
//	
// 	capture drop _merge
// merge 1:1 cusip fyear using `firm_age', gen(_merge)
// 	drop if _merge == 2
// 	drop _merge
//	
// 	gen cyear = year(apdedate)
// 	gen firm_age = cyear - found_yr
//
// * Big Eight Auditor
// 	capture drop rank
// destring au, replace
// gen rank = (au >=1 & au <= 8) if !mi(au)
//
// * Tenure / Same auditor years
// sort lpermno fyear
// bysort lpermno au: gen au_years = _n if !mi(au) //number of years firm has been audited by the same auditor
//
// * oa
// gen oa = ceq- che -dlc- dltt // shareholders' equity - cash and marketale securities + total debt
// xtset lpermno fyear
// gen lsale = l1.sale
// gen loa = l1.oa
// gen oa_scale = loa/lsale
//
// /*generate KZ score*/
// *xtset lpermno fyear 
// gen cashflow=dp+ib
// gen CF_lscaled=cashflow/l1.at
// 	label variable CF_lscaled "cashflow/l1.at"
//
// gen cash_dividends=dvc+dvp
// gen Dividends_scaled=cash_dividends/at
// 	label variable Dividends_scaled "cash_dividends/at"
//
// gen Debt_scaled=(dltt+dlc)/at
//
// gen DIV_lscaled=cash_dividends/l1.at
// 	label variable DIV_lscaled "Cash_dividends/l1.at"
//
// gen C_lscaled=che/l1.at
// 	label variable C_lscaled "che/l1.at"
//
// gen BLEV=( dltt + dlc )/(dltt+dlc+seq)
// 	label variable BLEV "( dltt + dlc )/(dltt+dlc+seq)"
//
// gen Tobinq=(at +(csho* prcc_f)-ceq)/at
// 	label variable Tobinq "(at +(csho* prcc_f)-ceq)/at"
//
// *gen Tobinq_2=(at +(csho* prcc_f)-(ceq+txdb))/at
// *label variable Tobinq_2 "(at +(csho* prcc_f)-(ceq+txdb))/at"
// gen KZ=-1.002*CF_lscaled- 39.368*DIV_lscaled- 1.315*C_lscaled+ 3.319*BLEV+ 0.283*Tobinq
//
// * ============ Labeling =================
// label var firm_ID "firm-year ID"
// label var firm_FID "firm FID = firm_ID - 1"
// label var dac "AEM (modified Jone's)"
// label var absdac "|AEM|" 
// label var rank_dac "AEM Rank"
// *label var rank_absdac ""
// label var rem "REM"
// label var absrem "{REM}"
// label var rank_rem "REM Rank"
// *label var rank_absrem ""
// label var stdz_rem "REM Variability"
// label var size "Size"
// label var bm "BM"
// label var roa "ROA"
// label var lev "Leverage"
// label var oa_scale "NOA"
// *label var hhi_sale "HHI"
// label var au_years "Auditor Tenure"
// label var firm_age "Firm Age"
// label var rank "Big N" //binary
// label var visib "Visibility"
// label var cover "ANAL"
// label var KZ "Financial Constraint"
//
// * sales  
// label var rank_d_cfo "Rank($REM_{CFO}$)"
// label var d_cfo "$REM_{CFO}$"
//
// gen d_cfo_neg = - d_cfo
// gen rank_d_cfo_neg = 9- rank_d_cfo
//
// label var d_cfo_neg "$REM_{CFO}$"
// label var rank_d_cfo_neg " Rank($REM_{CFO}$)"
//
// * over-production
//  label var d_prod "$REM_{PROD}$"
//  label var rank_d_prod "Rank($REM_{PROD}$)"
//
// * expenditure
//  label var d_discexp "$REM_{DISX}$"
//  label var rank_d_discexp " Rank($REM_{DISX}$)"
//
// gen d_discexp_neg = -d_discexp
// gen rank_d_discexp_neg = 9-rank_d_discexp
//
//  label var d_discexp_neg "$REM_{DISX}$"
//  label var rank_d_discexp_neg "Rank($REM_{DISX}$)"
// 
//  capture ssc install sicff
// * generate 48 industries based on the 4-digit sic code: sic
// destring sic, replace
// sicff sic, ind(48)
//
// 	* ==================================================================
// 	* ==================== Choose Sample ===============================
// 	* ==================================================================
// 	keep if !mi(dac) & !mi(rem) & !mi(visib) & !mi(size) & !mi(bm) & !mi(roa)  ///
// 	& !mi(lev) & !mi(firm_age) & !mi(rank) & !mi(au_years) & !mi(oa_scale) ///
// 	&  !mi(d_cfo) &  !mi( rank_d_cfo) &  !mi( d_prod ) &  !mi(rank_d_prod ) ///
// 	&  !mi(d_discexp ) &  !mi(rank_d_discexp) & !mi(ff_48) & !mi(fyear)
//	
// hhi5 sale, by(ff_48 fyear) //hhi_sale
// label var hhi_sale "HHI index"		
//
// 	capture drop _merge
// merge 1:1 tic fyear using `KLD_MSCI_tic'
//
// preserve
// keep if _merge == 3
// tempfile data1
// save `data1'
// restore
//
// preserve
// keep if _merge == 1
// 	capture drop _merge
// merge 1:1 cusip8 fyear using `KLD_MSCI_cusip8'
// keep if _merge == 3 | _merge == 1
// tempfile data2
// save `data2'
// restore
//
// use `data1', replace
// append using `data2'
//
// 	capture drop _merge
// merge 1:1 lpermno fyear using `convk'	
//
// drop if _merge == 2
// label var dacck "AEM (performance-adjusted)"
//
// *save "$output\final_data_47662", replace

global control_variables_aem size bm roa lev firm_age rank au_years oa_scale /*xrd_int*/
global control_variables_rem size bm roa lev firm_age rank au_years hhi_sale /*xrd_int*/

use "$output\final_data_47662", replace

**# Reviewer 1 Comment 2: Fog
sort fog
xtile fog_tercile = fog, nq(3)
label var fog "Fog"
*==================== Regression (Signed) =============================
	eststo clear
forvalues i = 1/3{
eststo regressionT`i'_1: reghdfe dacck visib fog $control_variables_aem if fog_tercile == `i', absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dacck if fog_tercile == `i'
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
	
eststo regressionT`i'_2: reghdfe dac visib fog $control_variables_aem if fog_tercile == `i', absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dac if fog_tercile == `i'
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regressionT`i'_3: reghdfe rank_dac visib fog $control_variables_aem if fog_tercile == `i', absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_dac if fog_tercile == `i'
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regressionT`i'_4: reghdfe rem visib fog $control_variables_rem if fog_tercile == `i', absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem if fog_tercile == `i'
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regressionT`i'_5: reghdfe rank_rem visib fog $control_variables_rem if fog_tercile == `i', absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_rem if fog_tercile == `i'
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
}

esttab regressionT1_1 regressionT1_2 regressionT1_3 regressionT1_4 regressionT1_5 using "$output\table_fogTercile.tex", replace fragment label nolines  ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) keep(visib fog) ///
mtitles("\makecell{AEM \\ (performance- \\ adj.)}" "\makecell{AEM \\ (modified \\ Jone's')}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") collabels(none) booktabs ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management by Terciles of Fog}\label{tab: fogTercile}\tabcolsep=0.1cm\scalebox{0.8}{\begin{tabular}{lccccc}\toprule") ///
posthead("\midrule\multicolumn{6}{c}{\textbf{First Tercile}}\\") 

esttab regressionT2_1 regressionT2_2 regressionT2_3 regressionT2_4 regressionT2_5 using "$output\table_fogTercile.tex", append fragment label nolines ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
posthead("\midrule\multicolumn{6}{c}{\textbf{Second Tercile}} \\") keep(visib fog) nonumbers nomtitles

esttab regressionT3_1 regressionT3_2 regressionT3_3 regressionT3_4 regressionT3_5 using "$output\table_fogTercile.tex", append fragment label nolines ///
posthead("\midrule \multicolumn{6}{c}{\textbf{Third Tercile}} \\") keep(visib fog) nonumbers nomtitles ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: The sample is divided into three subsamples by the magnitude of fog, namely, the first tercile, second tercile, and the third tercile. The dependent variables are indicated at the top of each column. The same set of control variables are included as in Table \ref{tab: table4}. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variables in columns (1)-(3) are: a firms' accrual earnings management calculated using the performance-adjusted method, a firm's accrual earnings management calculated using the modified Jone's method, and the rank of the firm's accrual earnings management (modified Jone's), respectively. The dependent variables in columns (4)-(5) are: a firm's real earnings management, and the rank of the firm's real earnings management, respectively. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm-year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

**# Reviewer 1 Comment 4: PM2.5
use "$output\final_data_47662", replace
	capture drop _merge
merge m:1 state city fyear using "$maindir\US_PM25_weightedannualmean.dta"
keep if _m == 3 //3583 observations, or 762 state-city-fyears
label var pollutant_value "PM 2.5 (Weighted Annual Mean)"

global first_stage size bm roa lev firm_age rank au_years oa_scale hhi_sale /*xrd_int*/

reghdfe visib pollutant_value $control_variables_aem, absorb(i.fyear i.ff_48) vce(cluster i.lpermno#i.fyear)
predict visib_PM2_5_aem, xb
label var visib_PM2_5_aem "Fitted visibility (AEM)"

reghdfe visib pollutant_value $control_variables_rem, absorb(i.fyear i.ff_48) vce(cluster i.lpermno#i.fyear)
predict visib_PM2_5_rem, xb
label var visib_PM2_5_rem "Fitted visibility (REM)"

reghdfe visib pollutant_value $first_stage, absorb(i.fyear i.ff_48) vce(cluster i.lpermno#i.fyear)
predict visib_PM2_5, xb
label var visib_PM2_5 "Fitted visibility"

	eststo clear
eststo regression1: reghdfe dacck visib_PM2_5 $control_variables_aem, absorb(i.fyear i.ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression2: reghdfe dac visib_PM2_5 $control_variables_aem, absorb(i.fyear i.ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression3: reghdfe rank_dac visib_PM2_5 $control_variables_aem, absorb(i.fyear i.ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression4: reghdfe rem visib_PM2_5 $control_variables_rem, absorb(i.fyear i.ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression5: reghdfe rank_rem visib_PM2_5 $control_variables_rem, absorb(i.fyear i.ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 using "$output\main_results_visib_PM2_5_fitted.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
mtitles("\makecell{AEM \\ (performance \\ -adj.)}" "\makecell{AEM \\ (modified \\ Jone's)}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") collabels(none) fragment nolines booktabs label keep(visib_PM2_5) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Fitted and Residual Values of Visibility on Earnings Management}\label{tab: visib_fitted_res}\tabcolsep=0.3cm\scalebox{0.8}{\begin{tabular}{lccccc}\toprule")  ///
posthead("\midrule \multicolumn{6}{c}{\textbf{Panel A: Fitted value of Regressing Visibility on PM 2.5}} \\")

gen visib_res_aem = visib - visib_PM2_5_aem
gen visib_res_rem = visib - visib_PM2_5_rem
gen visib_res = visib - visib_PM2_5

label var visib_res "Residual Visibility"
	eststo clear
eststo regression1: reghdfe dacck visib_res $control_variables_aem, absorb(i.fyear i.ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression2: reghdfe dac visib_res $control_variables_aem, absorb(i.fyear i.ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression3: reghdfe rank_dac visib_res $control_variables_aem, absorb(i.fyear i.ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression4: reghdfe rem visib_res $control_variables_rem, absorb(i.fyear i.ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression5: reghdfe rank_rem visib_res $control_variables_rem, absorb(i.fyear i.ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

global first_stage size bm roa lev firm_age rank au_years oa_scale hhi_sale /*xrd_int*/

esttab regression1 regression2 regression3 regression4 regression5 using "$output\main_results_visib_PM2_5_fitted.tex", append ///
booktabs label scalar(ymean) nomtitles nonumbers fragment nolines keep(visib_res) ///
posthead("\midrule \multicolumn{6}{c}{\textbf{Panel B: Residual value of Regressing Visibility on PM 2.5}} \\") ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: The dependent variables are indicated at the top of each column. The dependent variable in column (1) is a firm's accrual earnings management (AEM) calculated using the performance-adjusted modified Jone's model. The dependent variable in column (2) is AEM that is calculated using the modified Jone's model. The dependent variable in column (3) is the rank of the firm's AEM (modified Jone's). The dependent variables in columns (4)-(5) are a firm's real earnings management (REM) and the rank of the firm's REM, respectively. In Panel A, the main regressor is the fitted value of visibility from the regression where we regress visibility on annual PM 2.5 for each city and year and control variables including firm size, book-to-market ratio, returns on assets, leverage, firm age, the auditor being from Big N CPA firms, the number of years of being audited by the same auditor, the firm's operation assets, and Herfindahl–Hirschman Index. In Panel B, the main regressor is the residual value of visibility from the regression where we regress visibility on the variables above. In both panels, the same set of control variables are included as in Table \ref{tab: table4}. A description of all variables can be found in Table \ref{tab: variabledescriptions}. Year fixed effects and industry fixed effects are included in all regressions. The same firm control variables are included as in Table \ref{tab: table4}. Standard errors are clustered at the level of firm and year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 
