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

* sales rolling standard deviation
use "$maindir\Accounting Variables\conv.dta", replace
xtset lpermno fyear
rangestat (sd) sale, interval(fyear -2 0) by(lpermno)  
label var sale_sd "Sales Std3."

gen stockreturn = (prcc_f - l.prcc_f)/l.prcc_f

gen salesgrowth = (sale - l.sale)/l.sale

label var salesgrowth "Sales growth"

gen stockreturn_F1 = f.stockreturn
gen stockreturn_F2 = f2.stockreturn
gen stockreturn_F3 = f3.stockreturn

gen roa_F1 = f.roa
gen roa_F2 = f2.roa
gen roa_F3 = f3.roa

keep lpermno fyear sale sale_sd stockreturn salesgrowth stockreturn_F1 stockreturn_F2 stockreturn_F3 roa_F1 roa_F2 roa_F3

save "$maindir\sale_sd.dta", replace

*Pollutants
clear
import excel "$maindir\US Pollution Indicators\Anualized pollutants by citycounty.xlsx", firstrow

* City names
gsort countycityidentifier -Countiesandcities
unique countycityidentifier 
unique Countiesandcities

split Countiesandcities, parse(,)
rename (Countiesandcities1 Countiesandcities2)(city state)

foreach var of varlist E F G H I J K L M N O P Q R S T U V W X Y Z{
	local v: variable label `var'
	rename `var' yr`v'
}

order state city, after(Countiesandcities)
gsort countycityidentifier -state -city
bysort countycityidentifier: replace state = state[_n-1] if state[_n-1]!=""
bysort countycityidentifier: replace city = city[_n-1] if city[_n-1] != ""

* Drop meaningless observations
drop if mi(countycityidentifier)
drop if strpos(countycityidentifier, " - ")>0 

*1071 observations

reshape long yr, i(countycityidentifier state city Pollutant annulizedmethod) j(fyear)
rename yr pollutant_value

split state, parse(-)
drop state state2-state4
rename state1 state
order state, before(city)

split city, parse(-)
drop city city2-city6
rename city1 city
order city, after(state)

split city, parse(/)
drop city city2
rename city1 city

sort state city
br
replace city = "Boise" if city == "Boise City" & state == "ID"

save "$maindir\US_pollution_indicators.dta", replace

preserve
keep if Pollutant == "PM2.5" & annulizedmethod == "98th Percentile"
count
save "$maindir\US_PM25_98perc.dta", replace
restore

preserve
keep if Pollutant == "PM2.5" & annulizedmethod == "Weighted Annual Mean"
count
save "$maindir\US_PM25_weightedannualmean.dta", replace
restore

preserve
keep if Pollutant == "PM10" & annulizedmethod == "2nd Max"
count
save "$maindir\US_PM10_2ndMax.dta", replace
restore

preserve
keep if Pollutant == "CO" & annulizedmethod == "2nd Max"
count
save "$maindir\US_CO_2ndMax.dta", replace
restore

preserve
keep if Pollutant == "NO2" & annulizedmethod == "98th Percentile"
count
save "$maindir\US_NO2_98perc.dta", replace
restore

preserve
keep if Pollutant == "NO2" & annulizedmethod == "Annual Mean"
count
save "$maindir\US_NO2_annualmean.dta", replace
restore

preserve
keep if Pollutant == "O3" & annulizedmethod == "4th Max"
count
save "$maindir\US_O3_4thMax.dta", replace
restore

preserve
keep if Pollutant == "Pb" & annulizedmethod == "Max 3-Month Average"
count
save "$maindir\US_Pb_Max3MonthAvg.dta", replace
restore

preserve
keep if Pollutant == "SO2" & annulizedmethod == "99th Percentile"
count
save "$maindir\US_SO2_99Perc.dta", replace
restore

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

**# Reviewer 1 Comment 4: Future 3 months (in do-file 16)

**# Reviewer 1 Comment 1: Fog with OLD CONTROLS
global control_variables_aem size bm roa lev firm_age rank au_years oa_scale /*xrd_int*/
global control_variables_rem size bm roa lev firm_age rank au_years hhi_sale /*xrd_int*/

* Aggregate
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

label var grow "Sales growth"
label var loss "Loss"

gen lit = 1 if (sic >= 2833 & sic <= 2836) | (sic >= 3570 & sic <= 3577) | (sic >= 3600 & sic <=3674) | (sic >= 5200 & sic <= 5961) | (sic >= 7370 & sic <= 7379) | (sic >= 8731 & sic <= 8734)
replace lit = 0 if mi(lit) & !mi(sic)

label var lit "Litigious"
replace InstOwn_Perc = 0 if mi(InstOwn_Perc)

*Litigious industry = 1 if 4-digit SIC is Pharmaceuticals (2833-2836), computer (3570-3577), electronics (3600-3674), retailing (5200-5961), programming (7370-7379), R&D services (8731-8734), and 0 otherwise.
xtset lpermno fyear
*==================== Regression (Signed) =============================
	eststo clear
eststo regression1: reghdfe dacck visib fog $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
	
eststo regression2: reghdfe dac visib fog $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression3: reghdfe rank_dac visib fog $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression4: reghdfe rem visib fog $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression5: reghdfe rank_rem visib fog $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 using "$output\table4_fog_oldcontrols.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
mtitles("\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jone's')}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") collabels(none) booktabs label scalar(ymean) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management}\label{tab: table4newcontrols}\tabcolsep=0.1cm\scalebox{0.8}{\begin{tabular}{lccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: The dependent variables are indicated at the top of each column. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variables in columns (1)-(3) are: a firms' accrual earnings management calculated using the performance-adjusted method, a firm's accrual earnings management calculated using the modified Jone's method, and the rank of the firm's accrual earnings management (modified Jone's), respectively. The dependent variables in columns (4)-(5) are: a firm's real earnings management, and the rank of the firm's real earnings management, respectively. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm-year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

* By Terciles
sort fog
xtile fog_tercile = fog, nq(3)
label var fog "Fog"
*==================== Regression (Signed) =============================
	eststo clear
forvalues i = 1/3{
eststo regressionT`i'_1: reghdfe dacck visib $control_variables_aem if fog_tercile == `i', absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dacck if fog_tercile == `i'
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
	
eststo regressionT`i'_2: reghdfe dac visib $control_variables_aem if fog_tercile == `i', absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dac if fog_tercile == `i'
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regressionT`i'_3: reghdfe rank_dac visib $control_variables_aem if fog_tercile == `i', absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_dac if fog_tercile == `i'
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regressionT`i'_4: reghdfe rem visib $control_variables_rem if fog_tercile == `i', absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem if fog_tercile == `i'
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regressionT`i'_5: reghdfe rank_rem visib $control_variables_rem if fog_tercile == `i', absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_rem if fog_tercile == `i'
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
}

esttab regressionT1_1 regressionT1_2 regressionT1_3 regressionT1_4 regressionT1_5 using "$output\table_fogTercile.tex", replace fragment label nolines  ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) keep(visib) ///
mtitles("\makecell{AEM \\ (performance- \\ adj.)}" "\makecell{AEM \\ (modified \\ Jone's')}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") collabels(none) booktabs ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management by Terciles of Fog}\label{tab: fogTercile}\tabcolsep=0.1cm\scalebox{0.8}{\begin{tabular}{lccccc}\toprule") ///
posthead("\midrule\multicolumn{6}{c}{\textbf{First Tercile}}\\") 

esttab regressionT2_1 regressionT2_2 regressionT2_3 regressionT2_4 regressionT2_5 using "$output\table_fogTercile.tex", append fragment label nolines ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
posthead("\midrule\multicolumn{6}{c}{\textbf{Second Tercile}} \\") keep(visib) nonumbers nomtitles

esttab regressionT3_1 regressionT3_2 regressionT3_3 regressionT3_4 regressionT3_5 using "$output\table_fogTercile.tex", append fragment label nolines ///
posthead("\midrule \multicolumn{6}{c}{\textbf{Third Tercile}} \\") keep(visib) nonumbers nomtitles ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: The sample is divided into three subsamples by the magnitude of fog, namely, the first tercile, second tercile, and the third tercile. The dependent variables are indicated at the top of each column. The same set of control variables are included as in Table \ref{tab: table4}. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variables in columns (1)-(3) are: a firms' accrual earnings management calculated using the performance-adjusted method, a firm's accrual earnings management calculated using the modified Jone's method, and the rank of the firm's accrual earnings management (modified Jone's), respectively. The dependent variables in columns (4)-(5) are: a firm's real earnings management, and the rank of the firm's real earnings management, respectively. Year fixed effects and industry fixed effects are included in all regressions. The control variables include: firm size, book-to-market ratio, return on assets, leverage ratio, firm age, Big N auditor, number of years that a firm was audited by the same auditor, net operating assets (with dependent variable being AEM, and Herfindahl–Hirschman index (with dependent variable being REM. Standard errors are clustered at the level of firm-year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

* By Quartiles
sort fog
xtile fog_quartile = fog, nq(4)
label var fog "Fog"
*==================== Regression (Signed) =============================
	eststo clear
forvalues i = 1/4{
eststo regressionT`i'_1: reghdfe dacck visib $control_variables_aem if fog_quartile == `i', absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dacck if fog_quartile == `i'
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
	
eststo regressionT`i'_2: reghdfe dac visib $control_variables_aem if fog_quartile == `i', absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dac if fog_quartile == `i'
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regressionT`i'_3: reghdfe rank_dac visib $control_variables_aem if fog_quartile == `i', absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_dac if fog_quartile == `i'
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regressionT`i'_4: reghdfe rem visib $control_variables_rem if fog_quartile == `i', absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem if fog_quartile == `i'
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regressionT`i'_5: reghdfe rank_rem visib $control_variables_rem if fog_quartile == `i', absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_rem if fog_quartile == `i'
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
}

esttab regressionT1_1 regressionT1_2 regressionT1_3 regressionT1_4 regressionT1_5 using "$output\table_fogQuartile.tex", replace fragment label nolines  ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) keep(visib) ///
mtitles("\makecell{AEM \\ (performance- \\ adj.)}" "\makecell{AEM \\ (modified \\ Jone's')}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") collabels(none) booktabs ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management by Quartiles of Fog}\label{tab: fogTercile}\tabcolsep=0.1cm\scalebox{0.8}{\begin{tabular}{lccccc}\toprule") ///
posthead("\midrule\multicolumn{6}{c}{\textbf{First Quartile}}\\") 

esttab regressionT2_1 regressionT2_2 regressionT2_3 regressionT2_4 regressionT2_5 using "$output\table_fogQuartile.tex", append fragment label nolines ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
posthead("\midrule\multicolumn{6}{c}{\textbf{Second Quartile}} \\") keep(visib) nonumbers nomtitles

esttab regressionT3_1 regressionT3_2 regressionT3_3 regressionT3_4 regressionT3_5 using "$output\table_fogQuartile.tex", append fragment label nolines ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
posthead("\midrule\multicolumn{6}{c}{\textbf{Third Quartile}} \\") keep(visib) nonumbers nomtitles

esttab regressionT4_1 regressionT4_2 regressionT4_3 regressionT4_4 regressionT4_5 using "$output\table_fogQuartile.tex", append fragment label nolines ///
posthead("\midrule \multicolumn{6}{c}{\textbf{Fourth Quartile}} \\") keep(visib) nonumbers nomtitles ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: The sample is divided into four subsamples by the magnitude of fog, namely, the first quartile, second quartile, third quartile, and the fourth quartile. The dependent variables are indicated at the top of each column. The same set of control variables are included as in Table \ref{tab: table4}. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variables in columns (1)-(3) are: a firms' accrual earnings management calculated using the performance-adjusted method, a firm's accrual earnings management calculated using the modified Jone's method, and the rank of the firm's accrual earnings management (modified Jone's), respectively. The dependent variables in columns (4)-(5) are: a firm's real earnings management, and the rank of the firm's real earnings management, respectively. Year fixed effects and industry fixed effects are included in all regressions. The control variables include: firm size, book-to-market ratio, return on assets, leverage ratio, firm age, Big N auditor, number of years that a firm was audited by the same auditor, net operating assets (with dependent variable being AEM, and Herfindahl–Hirschman index (with dependent variable being REM. Standard errors are clustered at the level of firm-year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

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

esttab regressionT1_1 regressionT1_2 regressionT1_3 regressionT1_4 regressionT1_5 using "$output\table_fogQuintile.tex", replace fragment label nolines  ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) keep(visib) ///
mtitles("\makecell{AEM \\ (performance- \\ adj.)}" "\makecell{AEM \\ (modified \\ Jone's')}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") collabels(none) booktabs ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management by Quintiles of Fog}\label{tab: fogTercile}\tabcolsep=0.1cm\scalebox{0.7}{\begin{tabular}{lccccc}\toprule") ///
posthead("\midrule\multicolumn{6}{c}{\textbf{First Quintile}}\\") 

esttab regressionT2_1 regressionT2_2 regressionT2_3 regressionT2_4 regressionT2_5 using "$output\table_fogQuintile.tex", append fragment label nolines ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
posthead("\midrule\multicolumn{6}{c}{\textbf{Second Quintile}} \\") keep(visib) nonumbers nomtitles

esttab regressionT3_1 regressionT3_2 regressionT3_3 regressionT3_4 regressionT3_5 using "$output\table_fogQuintile.tex", append fragment label nolines ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
posthead("\midrule\multicolumn{6}{c}{\textbf{Third Quintile}} \\") keep(visib) nonumbers nomtitles

esttab regressionT4_1 regressionT4_2 regressionT4_3 regressionT4_4 regressionT4_5 using "$output\table_fogQuintile.tex", append fragment label nolines ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
posthead("\midrule\multicolumn{6}{c}{\textbf{Fourth Quintile}} \\") keep(visib) nonumbers nomtitles

esttab regressionT5_1 regressionT5_2 regressionT5_3 regressionT5_4 regressionT5_5 using "$output\table_fogQuintile.tex", append fragment label nolines ///
posthead("\midrule \multicolumn{6}{c}{\textbf{Fifth Quintile}} \\") keep(visib) nonumbers nomtitles ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: The sample is divided into five subsamples by the magnitude of fog, namely, the first, second, third, fourth, and the fifth quintile. The dependent variables are indicated at the top of each column. The same set of control variables are included as in Table \ref{tab: table4}. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variables in columns (1)-(3) are: a firms' accrual earnings management calculated using the performance-adjusted method, a firm's accrual earnings management calculated using the modified Jone's method, and the rank of the firm's accrual earnings management (modified Jone's), respectively. The dependent variables in columns (4)-(5) are: a firm's real earnings management, and the rank of the firm's real earnings management, respectively. Year fixed effects and industry fixed effects are included in all regressions. The control variables include: firm size, book-to-market ratio, return on assets, leverage ratio, firm age, Big N auditor, number of years that a firm was audited by the same auditor, net operating assets (with dependent variable being AEM, and Herfindahl–Hirschman index (with dependent variable being REM. Standard errors are clustered at the level of firm-year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

use "$output\final_data_47662", replace

**# Reviewer 1 Comment 1: Fog with NEW CONTROLS

global control_variables_aem size bm roa lev firm_age rank au_years oa_scale /*xrd_int*/ loss grow Boardindependence lit InstOwn stockreturn sale_sd rem

global control_variables_rem size bm roa lev firm_age rank au_years hhi_sale /*xrd_int*/ loss grow Boardindependence lit InstOwn stockreturn sale_sd dac

xtset lpermno fyear
gen stockreturn = (prcc_f - l.prcc_f)/l.prcc_f

*ssc install rangestat

rangestat (sd) sale, interval(fyear -2 0) by(lpermno)  
label var sale_sd "Sales Std3."

	capture drop _merge
merge 1:1 tic fyear using "$output\board_characteristics"
	keep if _merge == 1 | _merge == 3
	capture drop _merge
merge 1:1 cusip8 fyear using "$output\institutional_ownership_x.dta"
	keep if _merge == 1 | _merge == 3

label var grow "Sales growth"
label var loss "Loss"

gen lit = 1 if (sic >= 2833 & sic <= 2836) | (sic >= 3570 & sic <= 3577) | (sic >= 3600 & sic <=3674) | (sic >= 5200 & sic <= 5961) | (sic >= 7370 & sic <= 7379) | (sic >= 8731 & sic <= 8734)
replace lit = 0 if mi(lit) & !mi(sic)

label var lit "Litigious"

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

esttab regressionT1_1 regressionT1_2 regressionT1_3 regressionT1_4 regressionT1_5 using "$output\table_fogTercile_wNewControls.tex", replace fragment label nolines  ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) keep(visib fog) ///
mtitles("\makecell{AEM \\ (performance- \\ adj.)}" "\makecell{AEM \\ (modified \\ Jone's')}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") collabels(none) booktabs ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management by Terciles of Fog}\label{tab: fogTercile}\tabcolsep=0.1cm\scalebox{0.8}{\begin{tabular}{lccccc}\toprule") ///
posthead("\midrule\multicolumn{6}{c}{\textbf{First Tercile}}\\") 

esttab regressionT2_1 regressionT2_2 regressionT2_3 regressionT2_4 regressionT2_5 using "$output\table_fogTercile_wNewControls.tex", append fragment label nolines ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
posthead("\midrule\multicolumn{6}{c}{\textbf{Second Tercile}} \\") keep(visib fog) nonumbers nomtitles

esttab regressionT3_1 regressionT3_2 regressionT3_3 regressionT3_4 regressionT3_5 using "$output\table_fogTercile_wNewControls.tex", append fragment label nolines ///
posthead("\midrule \multicolumn{6}{c}{\textbf{Third Tercile}} \\") keep(visib fog) nonumbers nomtitles ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: The sample is divided into three subsamples by the magnitude of fog, namely, the first tercile, second tercile, and the third tercile. The dependent variables are indicated at the top of each column. The same set of control variables are included as in Table \ref{tab: table4}. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variables in columns (1)-(3) are: a firms' accrual earnings management calculated using the performance-adjusted method, a firm's accrual earnings management calculated using the modified Jone's method, and the rank of the firm's accrual earnings management (modified Jone's), respectively. The dependent variables in columns (4)-(5) are: a firm's real earnings management, and the rank of the firm's real earnings management, respectively. Year fixed effects and industry fixed effects are included in all regressions. The control variables include: firm size, book-to-market ratio, return on assets, leverage ratio, firm age, Big N auditor, number of years that a firm was audited by the same auditor, sale loss, sale growth, board independence, litigious industry, institutional ownership, stock return, 3-year rolling standard deviation of sales, $REM$ (for $AEM$), $AEM$ (for $REM$), net operating assets (with dependent variable being $AEM$, and Herfindahl–Hirschman index (with dependent variable being $REM$. Standard errors are clustered at the level of firm-year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

**# Reviewer 1 Comment 1: Fog with NEW CONTROLS
global control_variables_aem size bm roa lev firm_age rank au_years oa_scale /*xrd_int*/ loss salesgrowth /*Boardindependence*/ lit InstOwn_Perc stockreturn sale_sd rem

global control_variables_rem size bm roa lev firm_age rank au_years hhi_sale /*xrd_int*/ loss salesgrowth /*Boardindependence*/ lit InstOwn_Perc stockreturn sale_sd dac

* Aggregate
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

label var grow "Sales growth"
label var loss "Loss"

gen lit = 1 if (sic >= 2833 & sic <= 2836) | (sic >= 3570 & sic <= 3577) | (sic >= 3600 & sic <=3674) | (sic >= 5200 & sic <= 5961) | (sic >= 7370 & sic <= 7379) | (sic >= 8731 & sic <= 8734)
replace lit = 0 if mi(lit) & !mi(sic)

label var lit "Litigious"
replace InstOwn_Perc = 0 if mi(InstOwn_Perc)

*Litigious industry = 1 if 4-digit SIC is Pharmaceuticals (2833-2836), computer (3570-3577), electronics (3600-3674), retailing (5200-5961), programming (7370-7379), R&D services (8731-8734), and 0 otherwise.
xtset lpermno fyear
*==================== Regression (Signed) =============================
	eststo clear
eststo regression1: reghdfe dacck visib fog $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
	
eststo regression2: reghdfe dac visib fog $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression3: reghdfe rank_dac visib fog $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression4: reghdfe rem visib fog $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression5: reghdfe rank_rem visib fog $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 using "$output\table4_fog_newcontrols.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
mtitles("\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jone's')}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") collabels(none) booktabs label scalar(ymean) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management}\label{tab: table4newcontrols}\tabcolsep=0.1cm\scalebox{0.8}{\begin{tabular}{lccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: The dependent variables are indicated at the top of each column. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variables in columns (1)-(3) are: a firms' accrual earnings management calculated using the performance-adjusted method, a firm's accrual earnings management calculated using the modified Jone's method, and the rank of the firm's accrual earnings management (modified Jone's), respectively. The dependent variables in columns (4)-(5) are: a firm's real earnings management, and the rank of the firm's real earnings management, respectively. The control variables include: firm size, book-to-market ratio, return on assets, leverage ratio, firm age, Big N auditor, number of years that a firm was audited by the same auditor, sale loss, sale growth, board independence, litigious industry, institutional ownership, stock return, 3-year rolling standard deviation of sales, REM (for AEM), AEM (for REM), net operating assets (with dependent variable being AEM, and Herfindahl–Hirschman index (with dependent variable being REM. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm-year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 


**# Reviewer 1 Comment 3: PM2.5 with OLD CONTROLS
global control_variables_aem size bm roa lev firm_age rank au_years oa_scale /*xrd_int*/
global control_variables_rem size bm roa lev firm_age rank au_years hhi_sale /*xrd_int*/

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
postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: The dependent variables are indicated at the top of each column. The dependent variable in column (1) is a firm's accrual earnings management (AEM) calculated using the performance-adjusted modified Jone's model. The dependent variable in column (2) is AEM that is calculated using the modified Jone's model. The dependent variable in column (3) is the rank of the firm's AEM (modified Jone's). The dependent variables in columns (4)-(5) are a firm's real earnings management (REM) and the rank of the firm's REM, respectively. In Panel A, the main regressor is the fitted value of visibility from the regression where we regress visibility on annual PM 2.5 for each city and year and control variables including firm size, book-to-market ratio, returns on assets, leverage, firm age, the auditor being from Big N CPA firms, the number of years of being audited by the same auditor, the firm's operation assets (for AEM), and Herfindahl–Hirschman Index (for REM). In Panel B, the main regressor is the residual value of visibility from the regression where we regress visibility on the variables above. In both panels, the same set of control variables are included as in Table \ref{tab: table4}. A description of all variables can be found in Table \ref{tab: variabledescriptions}. Year fixed effects and industry fixed effects are included in all regressions. The same firm control variables are included as in Table \ref{tab: table4}. Standard errors are clustered at the level of firm and year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

**# Reviewer 1 Comment 3: PM2.5 with NEW CONTROLS
global control_variables_aem size bm roa lev firm_age rank au_years oa_scale /*xrd_int*/ loss salesgrowth /*Boardindependence*/ lit InstOwn_Perc stockreturn sale_sd rem

global control_variables_rem size bm roa lev firm_age rank au_years hhi_sale /*xrd_int*/ loss salesgrowth /*Boardindependence*/ lit InstOwn_Perc stockreturn sale_sd dac

use "$output\final_data_47662", replace
	capture drop _merge
merge m:1 state city fyear using "$maindir\US_PM25_weightedannualmean.dta"
keep if _m == 3 //3583 observations, or 762 state-city-fyears
label var pollutant_value "PM 2.5 (Weighted Annual Mean)"

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

*Litigious industry = 1 if 4-digit SIC is Pharmaceuticals (2833-2836), computer (3570-3577), electronics (3600-3674), retailing (5200-5961), programming (7370-7379), R&D services (8731-8734), and 0 otherwise.
xtset lpermno fyear

global first_stage size bm roa lev firm_age rank au_years hhi_sale /*xrd_int*/ loss salesgrowth /*Boardindependence*/ lit InstOwn_Perc stockreturn sale_sd dac
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

esttab regression1 regression2 regression3 regression4 regression5 using "$output\main_results_visib_PM2_5_fitted_NewControls.tex", replace ///
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

esttab regression1 regression2 regression3 regression4 regression5 using "$output\main_results_visib_PM2_5_fitted_NewControls.tex", append ///
booktabs label scalar(ymean) nomtitles nonumbers fragment nolines keep(visib_res) ///
posthead("\midrule \multicolumn{6}{c}{\textbf{Panel B: Residual value of Regressing Visibility on PM 2.5}} \\") ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: The dependent variables are indicated at the top of each column. The dependent variable in column (1) is a firm's accrual earnings management (AEM) calculated using the performance-adjusted modified Jone's model. The dependent variable in column (2) is AEM that is calculated using the modified Jone's model. The dependent variable in column (3) is the rank of the firm's AEM (modified Jone's). The dependent variables in columns (4)-(5) are a firm's real earnings management (REM) and the rank of the firm's REM, respectively. In Panel A, the main regressor is the fitted value of visibility from the regression where we regress visibility on annual PM 2.5 for each city and year and control variables including firm size, book-to-market ratio, return on assets, leverage ratio, firm age, Big N auditor, number of years that a firm was audited by the same auditor, sale loss, sale growth, board independence, litigious industry, institutional ownership, stock return, 3-year rolling standard deviation of sales, $REM$ (for $AEM$), $AEM$ (for $REM$), net operating assets (with dependent variable being $AEM$, and Herfindahl–Hirschman index (with dependent variable being $REM$. In Panel B, the main regressor is the residual value of visibility from the regression where we regress visibility on the variables above. In both panels, the same set of control variables are included as in Table \ref{tab: table4}. A description of all variables can be found in Table \ref{tab: variabledescriptions}. Year fixed effects and industry fixed effects are included in all regressions. The same firm control variables are included as in Table \ref{tab: table4}. Standard errors are clustered at the level of firm and year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

**# Reviewer 1 Comment 3: Visibility - PM2.5 / PM10 pollutants correlation
global pollutants visib PM2_5_mean PM2_5_98Perc PM10 CO_2ndMax NO2_98Perc NO2_mean O3_4thMax Pb_mean SO2_99Perc
use "$output\final_data_47662", replace
	capture drop _merge
merge m:1 state city fyear using "$maindir\US_PM25_98perc.dta"
	label var pollutant_value "PM 2.5 98 Percentile"
	rename pollutant_value PM2_5_98Perc
	keep if _merge == 1 | _merge == 3
	
	capture drop _merge
merge m:1 state city fyear using "$maindir\US_PM25_weightedannualmean.dta"
	label var pollutant_value "PM 2.5 weighted annual mean"
	rename pollutant_value PM2_5_mean
	keep if _merge == 1 | _merge == 3
	
	capture drop _merge
merge m:1 state city fyear using "$maindir\US_PM10_2ndMax.dta"
	label var pollutant_value "PM 10 2nd Max"
	rename pollutant_value PM10
	keep if _merge == 1 | _merge == 3

	capture drop _merge
merge m:1 state city fyear using "$maindir\US_CO_2ndMax.dta"
	label var pollutant_value "CO 2nd Max"
	rename pollutant_value CO_2ndMax
	keep if _merge == 1 | _merge == 3
	
	capture drop _merge
merge m:1 state city fyear using "$maindir\US_NO2_98perc.dta"
	label var pollutant_value "NO2 98 Percentile"
	rename pollutant_value NO2_98Perc
	keep if _merge == 1 | _merge == 3
	
	capture drop _merge
merge m:1 state city fyear using "$maindir\US_NO2_annualmean.dta"
	label var pollutant_value "NO2 Annual mean"
	rename pollutant_value NO2_mean
	keep if _merge == 1 | _merge == 3
	
	capture drop _merge
merge m:1 state city fyear using  "$maindir\US_O3_4thMax.dta"
	label var pollutant_value "O3 4th Max"
	rename pollutant_value O3_4thMax
	keep if _merge == 1 | _merge == 3
	
	capture drop _merge
merge m:1 state city fyear using "$maindir\US_Pb_Max3MonthAvg.dta"
	label var pollutant_value "Pb Max 3 Month Average"
	rename pollutant_value Pb_mean
	keep if _merge == 1 | _merge == 3
	
	capture drop _merge
merge m:1 state city fyear using  "$maindir\US_SO2_99Perc.dta"
	label var pollutant_value "SO2 99 Percentile"
	rename pollutant_value SO2_99Perc
	keep if _merge == 1 | _merge == 3

corrtex $pollutants, file(CorrTable_pollutants) replace land sig /*dig(4) star(0.05)*/

**# Reviewer 2 Comment 4: Add controls
**1) add TICKER
use "E:\21. Air Pollution and Accounting\DATA\R&R\board independence(1).dta", replace

gen year = year(Date)
rename TICKER tic

drop if mi(tic)
bysort tic year: egen G29_mean = mean(G_2_9)
bysort tic year: gen diff = (G29_mean != G_2_9) if !mi(G_2_9)
unique tic year if diff == 1

unique tic year G29_mean //163
duplicates drop tic year G29_mean, force
rename year fyear
save "$output\board_independence_x.dta", replace

** 2) female board% (across the US)
use "E:\21. Air Pollution and Accounting\DATA\R&R\BoardEx - Organization Summary - Analytics.dta", replace
gen fyear = year(annualreportdate)
unique ticker fyear //95964
duplicates drop ticker fyear, force
rename ticker tic
save "$output\female_board_x.dta", replace

** 3) dual role
use "E:\21. Air Pollution and Accounting\DATA\R&R\CEO duality.dta", replace
drop if mi(PERMCO) & mi(GVKEY)
drop if mi(datestartrole) & mi(dateendrole)
drop if mi(datestartrole) & !mi(dateendrole)

gen startyear = year(datestartrole)
gen endyear = year(dateendrole)
replace endyear = 2018 if mi(endyear)
drop if endyear < 2002
gen year1= startyear if startyear >= 2002
replace year1 = 2002 if startyear < 2002
gen gap = endyear - year1 // 0-16

forvalues i = 2/17{
	gen year`i' =.
}

forvalues i = 1/16{
	local j = `i' + 1
	replace year`j' = year1 + `i' if gap >= `i'
}

drop datestartrole dateendrole score startyear endyear

gen ID = _n
reshape long year, i(ID) j(obs)
drop if mi(year)

bysort PERMCO year: egen dual_max = max(dual)

unique PERMCO year
duplicates drop PERMCO year, force

rename PERMCO lpermco
rename year fyear

save "$output\CEO_duality_x.dta", replace

** Institutional Ownership
use "E:\21. Air Pollution and Accounting\DATA\R&R\institutional_ownership.dta", replace

gen fyear = year(rdate)
keep rdate cusip fyear ticker Top5InstOwn Top10InstOwn InstOwn InstOwn_HHI InstOwn_Perc

count if mi(fyear) | mi(Top5InstOwn) | mi(Top10InstOwn) | mi(InstOwn) | mi(InstOwn_HHI)

count if mi(cusip)

count if mi(ticker)
drop ticker

foreach var of varlist Top5InstOwn Top10InstOwn InstOwn InstOwn_HHI InstOwn_Perc{
	bysort cusip fyear: egen `var'_mean = mean(`var')
	gen diff_`var' = (`var'_mean != `var')
	tab diff_`var'
}

br cusip rdate fyear Top5InstOwn Top5InstOwn_mean if diff_Top5InstOwn == 1
br cusip rdate fyear Top10InstOwn Top10InstOwn_mean if diff_Top10InstOwn == 1
br cusip rdate fyear InstOwn InstOwn_mean if diff_InstOwn == 1
br cusip rdate fyear InstOwn_HHI InstOwn_HHI_mean if diff_InstOwn_HHI == 1

sort cusip fyear rdate
br cusip fyear rdate Top5InstOwn Top5InstOwn_mean if diff_Top5InstOwn == 1

drop rdate

collapse (mean)Top5InstOwn (mean)Top10InstOwn (mean)InstOwn (mean)InstOwn_HHI (mean)InstOwn_Perc, by(cusip fyear)

rename cusip cusip8

save "$output\institutional_ownership_x.dta", replace

** Knowledge Intensive Industries
import excel using "E:\21. Air Pollution and Accounting\DATA\R&R\knowledge intensive industry.xlsx", firstrow clear
rename SIC sic

bysort sic: gen dup = _n
drop if dup > 1
save "$output\knowledge_intensive_industry.dta", replace

use "$output\final_data_47662", replace
	capture drop _merge
merge m:1 tic fyear using "$output\board_independence_x.dta"

	capture drop _merge
merge m:1 tic fyear using "$output\female_board_x.dta"
	keep if _merge == 1 | _merge == 3

	capture drop _merge
merge 1:1 lpermco fyear using "$output\CEO_duality_x.dta"
	keep if _merge == 3
	
	capture drop _merge
merge 1:1 cusip8 fyear using "$output\instituional_ownership_x.dta"
	keep if _merge == 1 | _merge == 3
	
	capture drop _merge
merge m:1 sic using "$output\knowledge_intensive_industry.dta"
	keep if _merge == 1 | _merge == 3
	gen knowledge_intense = (_merge == 3)
	drop _merge

// erase "$output\board_independence_x.dta"
// erase "$output\female_board_x.dta"
// erase "$output\CEO_duality_x.dta"
// erase "$output\knowledge_intensive_industry.dta"

* G29_mean, gender_ratio, dual, loss, grow, institutional_ownership (4个: institutional_ownership, HHI, 5, 10)

**# Reviewer 2 Comment 2: Knowledge-intensive v.s. Labor-intensive
global control_variables_aem size bm roa lev firm_age rank au_years oa_scale /*xrd_int*/
global control_variables_rem size bm roa lev firm_age rank au_years hhi_sale /*xrd_int*/

** Knowledge Intensive Industries
import excel using "E:\21. Air Pollution and Accounting\DATA\R&R\knowledge intensive industry.xlsx", firstrow clear
rename SIC sic

bysort sic: gen dup = _n
drop if dup > 1
save "$output\knowledge_intensive_industry.dta", replace

use "$output\final_data_47662", replace
	capture drop _merge
merge m:1 sic using "$output\knowledge_intensive_industry.dta"
	keep if _merge == 1 | _merge == 3
	gen knowledge_intense = (_merge == 3)
	drop _merge

*==================== Regression (Signed) =============================
preserve
keep if knowledge_intense == 1
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

esttab regression1 regression2 regression3 regression4 regression5 using "$output\results_knowledge_intensive.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
mtitles("\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jone's')}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") collabels(none) booktabs label scalar(ymean) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management, among Knowledge-intensive Industries}\label{tab: table4}\tabcolsep=0.1cm\scalebox{0.9}{\begin{tabular}{lccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: The dependent variables are indicated at the top of each column. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variables in columns (1)-(3) are: a firms' accrual earnings management calculated using the performance-adjusted method, a firm's accrual earnings management calculated using the modified Jone's method, and the rank of the firm's accrual earnings management (modified Jone's), respectively. The dependent variables in columns (4)-(5) are: a firm's real earnings management, and the rank of the firm's real earnings management, respectively. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm-year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 
restore

preserve
keep if knowledge_intense == 0
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

esttab regression1 regression2 regression3 regression4 regression5 using "$output\results_non_knowledge_intensive.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
mtitles("\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jone's')}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") collabels(none) booktabs label scalar(ymean) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management, among Non-knowledge-intensive Industries}\label{tab: table4}\tabcolsep=0.1cm\scalebox{0.9}{\begin{tabular}{lccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: The dependent variables are indicated at the top of each column. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variables in columns (1)-(3) are: a firms' accrual earnings management calculated using the performance-adjusted method, a firm's accrual earnings management calculated using the modified Jone's method, and the rank of the firm's accrual earnings management (modified Jone's), respectively. The dependent variables in columns (4)-(5) are: a firm's real earnings management, and the rank of the firm's real earnings management, respectively. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm-year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 
restore

**# Reviewer 2 Comment 2: Knowledge-intensive v.s. Labor-intensive, NEW CONTROLS
global control_variables_aem size bm roa lev firm_age rank au_years oa_scale /*xrd_int*/ loss grow Boardindependence lit InstOwn stockreturn sale_sd rem

global control_variables_rem size bm roa lev firm_age rank au_years hhi_sale /*xrd_int*/ loss grow Boardindependence lit InstOwn stockreturn sale_sd dac

** Knowledge Intensive Industries
import excel using "E:\21. Air Pollution and Accounting\DATA\R&R\knowledge intensive industry.xlsx", firstrow clear
rename SIC sic

bysort sic: gen dup = _n
drop if dup > 1
save "$output\knowledge_intensive_industry.dta", replace

use "$output\final_data_47662", replace
	capture drop _merge
merge m:1 sic using "$output\knowledge_intensive_industry.dta"
	keep if _merge == 1 | _merge == 3
	gen knowledge_intense = (_merge == 3)
	drop _merge

xtset lpermno fyear
gen stockreturn = (prcc_f - l.prcc_f)/l.prcc_f

*ssc install rangestat

rangestat (sd) sale, interval(fyear -2 0) by(lpermno)  
label var sale_sd "Sales Std3."

	capture drop _merge
merge 1:1 tic fyear using "$output\board_characteristics", force
	keep if _merge == 1 | _merge == 3
	capture drop _merge
merge 1:1 cusip8 fyear using "$output\institutional_ownership_x.dta", force
	keep if _merge == 1 | _merge == 3

label var grow "Sales growth"
label var loss "Loss"

destring sic, replace

gen lit = 1 if (sic >= 2833 & sic <= 2836) | (sic >= 3570 & sic <= 3577) | (sic >= 3600 & sic <=3674) | (sic >= 5200 & sic <= 5961) | (sic >= 7370 & sic <= 7379) | (sic >= 8731 & sic <= 8734)
replace lit = 0 if mi(lit) & !mi(sic)

label var lit "Litigious"

*==================== Regression (Signed) =============================
preserve
keep if knowledge_intense == 1
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

esttab regression1 regression2 regression3 regression4 regression5 using "$output\results_knowledge_intensive_NEW_CONTROLS.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
mtitles("\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jone's')}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") collabels(none) booktabs label scalar(ymean) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management, among Knowledge-intensive Industries}\label{tab: table4}\tabcolsep=0.1cm\scalebox{0.9}{\begin{tabular}{lccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: The dependent variables are indicated at the top of each column. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variables in columns (1)-(3) are: a firms' accrual earnings management calculated using the performance-adjusted method, a firm's accrual earnings management calculated using the modified Jone's method, and the rank of the firm's accrual earnings management (modified Jone's), respectively. The dependent variables in columns (4)-(5) are: a firm's real earnings management, and the rank of the firm's real earnings management, respectively. The control variables include: firm size, book-to-market ratio, return on assets, leverage ratio, firm age, Big N auditor, number of years that a firm was audited by the same auditor, sale loss, sale growth, board independence, litigious industry, institutional ownership, stock return, 3-year rolling standard deviation of sales, $REM$ (for $AEM$), $AEM$ (for $REM$), net operating assets (with dependent variable being $AEM$, and Herfindahl–Hirschman index (with dependent variable being $REM$. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm-year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 
restore

preserve
keep if knowledge_intense == 0
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

esttab regression1 regression2 regression3 regression4 regression5 using "$output\results_non_knowledge_intensive_NEW_CONTROLS.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
mtitles("\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jone's')}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") collabels(none) booktabs label scalar(ymean) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management, among Non-knowledge-intensive Industries}\label{tab: table4}\tabcolsep=0.1cm\scalebox{0.9}{\begin{tabular}{lccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: The dependent variables are indicated at the top of each column. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variables in columns (1)-(3) are: a firms' accrual earnings management calculated using the performance-adjusted method, a firm's accrual earnings management calculated using the modified Jone's method, and the rank of the firm's accrual earnings management (modified Jone's), respectively. The dependent variables in columns (4)-(5) are: a firm's real earnings management, and the rank of the firm's real earnings management, respectively. The control variables include: firm size, book-to-market ratio, return on assets, leverage ratio, firm age, Big N auditor, number of years that a firm was audited by the same auditor, sale loss, sale growth, board independence, litigious industry, institutional ownership, stock return, 3-year rolling standard deviation of sales, $REM$ (for $AEM$), $AEM$ (for $REM$), net operating assets (with dependent variable being $AEM$, and Herfindahl–Hirschman index (with dependent variable being $REM$. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm-year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 
restore

**# Reviewer 2 Comment 2: Labor-intensive industries with OLD CONTROLS
/*
1. **Agriculture, Forestry, and Fishing (SIC Codes 01-09)**
   - These sectors are traditionally labor-intensive, involving manual cultivation, harvesting, and processing.

2. **Construction (SIC Codes 15-17)**
   - Includes residential and commercial building, which require significant manpower for construction tasks.

3. **Manufacturing, particularly Apparel and Textile Products (SIC Codes 22-23)**
   - These industries involve labor-intensive processes like sewing, cutting, and assembly of textiles and apparel.

4. **Retail Trade (SIC Codes 52-59)**
   - This sector typically requires extensive sales personnel to operate retail stores and manage customer interactions.

5. **Healthcare and Social Assistance (SIC Codes 80-83)**
   - Includes hospitals, nursing care, and social services that are heavily reliant on healthcare professionals and care providers.

6. **Education Services (SIC Code 82)**
   - Schools and educational institutions require a high number of educators and support staff.

7. **Hospitality and Food Services (SIC Codes 70, 75, 58)**
   - Restaurants, hotels, and other service establishments are labor-intensive, requiring staff for operations, customer service, and maintenance.
*/
global control_variables_aem size bm roa lev firm_age rank au_years oa_scale /*xrd_int*/
global control_variables_rem size bm roa lev firm_age rank au_years hhi_sale /*xrd_int*/

** Labor Intensive Industries
use "$output\final_data_47662", replace

gen labor_intensive = ((sic >= 100 & sic <= 999) | (sic >= 1500 & sic <= 1799) | (sic >= 2200 & sic <= 2399) | (sic >= 5200 & sic <= 5999) | (sic >= 8000 & sic <= 8399) | (sic >= 7000 & sic <= 7099) | (sic >= 7500 & sic <= 7599) | (sic >= 5800 & sic <= 5899)) if !mi(sic)

	capture label drop labor_intensive
label define labor_intensive 1 "Labor-intensive" 0 "Non-labor-intensive"
label val labor_intensive labor_intensive

*==================== Regression (Signed) =============================
preserve
keep if labor_intensive == 1
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

esttab regression1 regression2 regression3 regression4 regression5 using "$output\results_labor_intensive.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
mtitles("\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jone's')}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") collabels(none) booktabs label scalar(ymean) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management, among Labor-intensive Industries}\label{tab: table4LaborIntense}\tabcolsep=0.1cm\scalebox{0.9}{\begin{tabular}{lccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: The dependent variables are indicated at the top of each column. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variables in columns (1)-(3) are: a firms' accrual earnings management calculated using the performance-adjusted method, a firm's accrual earnings management calculated using the modified Jone's method, and the rank of the firm's accrual earnings management (modified Jone's), respectively. The dependent variables in columns (4)-(5) are: a firm's real earnings management, and the rank of the firm's real earnings management, respectively. Control variables include: firm size, book-to-market ratio, return on assets, leverage ratio, firm age, Big N auditor, number of years that a firm was audited by the same auditor, net operating assets (with dependent variable being AEM, and Herfindahl–Hirschman index (with dependent variable being REM. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm-year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 
restore

preserve
keep if labor_intensive == 0
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

esttab regression1 regression2 regression3 regression4 regression5 using "$output\results_non_labor_intensive.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
mtitles("\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jone's')}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") collabels(none) booktabs label scalar(ymean) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management, among Non-labor-intensive Industries}\label{tab: table4NonLaborIntense}\tabcolsep=0.1cm\scalebox{0.9}{\begin{tabular}{lccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: The dependent variables are indicated at the top of each column. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variables in columns (1)-(3) are: a firms' accrual earnings management calculated using the performance-adjusted method, a firm's accrual earnings management calculated using the modified Jone's method, and the rank of the firm's accrual earnings management (modified Jone's), respectively. The dependent variables in columns (4)-(5) are: a firm's real earnings management, and the rank of the firm's real earnings management, respectively. Control variables include: firm size, book-to-market ratio, return on assets, leverage ratio, firm age, Big N auditor, number of years that a firm was audited by the same auditor, net operating assets (with dependent variable being AEM, and Herfindahl–Hirschman index (with dependent variable being REM.Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm-year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 
restore

**# Reviewer 2 Comment 2: Labor-intensive industries with NEW CONTROLS
/*
1. **Agriculture, Forestry, and Fishing (SIC Codes 01-09)**
   - These sectors are traditionally labor-intensive, involving manual cultivation, harvesting, and processing.

2. **Construction (SIC Codes 15-17)**
   - Includes residential and commercial building, which require significant manpower for construction tasks.

3. **Manufacturing, particularly Apparel and Textile Products (SIC Codes 22-23)**
   - These industries involve labor-intensive processes like sewing, cutting, and assembly of textiles and apparel.

4. **Retail Trade (SIC Codes 52-59)**
   - This sector typically requires extensive sales personnel to operate retail stores and manage customer interactions.

5. **Healthcare and Social Assistance (SIC Codes 80-83)**
   - Includes hospitals, nursing care, and social services that are heavily reliant on healthcare professionals and care providers.

6. **Education Services (SIC Code 82)**
   - Schools and educational institutions require a high number of educators and support staff.

7. **Hospitality and Food Services (SIC Codes 70, 75, 58)**
   - Restaurants, hotels, and other service establishments are labor-intensive, requiring staff for operations, customer service, and maintenance.
*/
global control_variables_aem size bm roa lev firm_age rank au_years oa_scale /*xrd_int*/ loss grow Boardindependence lit InstOwn stockreturn sale_sd rem

global control_variables_rem size bm roa lev firm_age rank au_years hhi_sale /*xrd_int*/ loss grow Boardindependence lit InstOwn stockreturn sale_sd dac

** Labor Intensive Industries
use "$output\final_data_47662", replace

xtset lpermno fyear
gen stockreturn = (prcc_f - l.prcc_f)/l.prcc_f

*ssc install rangestat

rangestat (sd) sale, interval(fyear -2 0) by(lpermno)  
label var sale_sd "Sales Std3."

	capture drop _merge
merge 1:1 tic fyear using "$output\board_characteristics", force
	keep if _merge == 1 | _merge == 3
	capture drop _merge
merge 1:1 cusip8 fyear using "$output\institutional_ownership_x.dta", force
	keep if _merge == 1 | _merge == 3

label var grow "Sales growth"
label var loss "Loss"

destring sic, replace

gen lit = 1 if (sic >= 2833 & sic <= 2836) | (sic >= 3570 & sic <= 3577) | (sic >= 3600 & sic <=3674) | (sic >= 5200 & sic <= 5961) | (sic >= 7370 & sic <= 7379) | (sic >= 8731 & sic <= 8734)
replace lit = 0 if mi(lit) & !mi(sic)

label var lit "Litigious"

gen labor_intensive = ((sic >= 100 & sic <= 999) | (sic >= 1500 & sic <= 1799) | (sic >= 2200 & sic <= 2399) | (sic >= 5200 & sic <= 5999) | (sic >= 8000 & sic <= 8399) | (sic >= 7000 & sic <= 7099) | (sic >= 7500 & sic <= 7599) | (sic >= 5800 & sic <= 5899)) if !mi(sic)

	capture label drop labor_intensive
label define labor_intensive 1 "Labor-intensive" 0 "Non-labor-intensive"
label val labor_intensive labor_intensive

*==================== Regression (Signed) =============================
preserve
keep if labor_intensive == 1
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

esttab regression1 regression2 regression3 regression4 regression5 using "$output\results_labor_intensive_NEW_CONTROLS.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
mtitles("\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jone's')}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") collabels(none) booktabs label scalar(ymean) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management, among Labor-intensive Industries}\label{tab: table4LaborIntenseNEW}\tabcolsep=0.1cm\scalebox{0.9}{\begin{tabular}{lccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: The dependent variables are indicated at the top of each column. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variables in columns (1)-(3) are: a firms' accrual earnings management calculated using the performance-adjusted method, a firm's accrual earnings management calculated using the modified Jone's method, and the rank of the firm's accrual earnings management (modified Jone's), respectively. The dependent variables in columns (4)-(5) are: a firm's real earnings management, and the rank of the firm's real earnings management, respectively. The control variables include: firm size, book-to-market ratio, return on assets, leverage ratio, firm age, Big N auditor, number of years that a firm was audited by the same auditor, sale loss, sale growth, board independence, litigious industry, institutional ownership, stock return, 3-year rolling standard deviation of sales, REM (for AEM), AEM (for REM), net operating assets (with dependent variable being AEM, and Herfindahl–Hirschman index (with dependent variable being REM. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm-year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 
restore

preserve
keep if labor_intensive == 0
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

esttab regression1 regression2 regression3 regression4 regression5 using "$output\results_non_labor_intensive_NEW_CONTROLS.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
mtitles("\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jone's')}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") collabels(none) booktabs label scalar(ymean) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management, among Non-labor-intensive Industries}\label{tab: table4NonLaborIntenseNEW}\tabcolsep=0.1cm\scalebox{0.9}{\begin{tabular}{lccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: The dependent variables are indicated at the top of each column. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variables in columns (1)-(3) are: a firms' accrual earnings management calculated using the performance-adjusted method, a firm's accrual earnings management calculated using the modified Jone's method, and the rank of the firm's accrual earnings management (modified Jone's), respectively. The dependent variables in columns (4)-(5) are: a firm's real earnings management, and the rank of the firm's real earnings management, respectively. The control variables include: firm size, book-to-market ratio, return on assets, leverage ratio, firm age, Big N auditor, number of years that a firm was audited by the same auditor, sale loss, sale growth, board independence, litigious industry, institutional ownership, stock return, 3-year rolling standard deviation of sales, REM (for AEM), AEM (for REM), net operating assets (with dependent variable being AEM, and Herfindahl–Hirschman index (with dependent variable being REM. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm-year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 
restore


**# Reviewer Comment 6: Corporate Governance - female board%
** female board% (across the US)
use "E:\21. Air Pollution and Accounting\DATA\R&R\BoardEx - Organization Summary - Analytics.dta", replace
gen fyear = year(annualreportdate)
unique ticker fyear //95964
duplicates drop ticker fyear, force
rename ticker tic
save "$output\female_board_x.dta", replace

** dual role
use "E:\21. Air Pollution and Accounting\DATA\R&R\CEO duality.dta", replace
drop if mi(PERMCO) & mi(GVKEY)
drop if mi(datestartrole) & mi(dateendrole)
drop if mi(datestartrole) & !mi(dateendrole)

gen startyear = year(datestartrole)
gen endyear = year(dateendrole)
replace endyear = 2018 if mi(endyear)
drop if endyear < 2002
gen year1= startyear if startyear >= 2002
replace year1 = 2002 if startyear < 2002
gen gap = endyear - year1 // 0-16

forvalues i = 2/17{
	gen year`i' =.
}

forvalues i = 1/16{
	local j = `i' + 1
	replace year`j' = year1 + `i' if gap >= `i'
}

drop datestartrole dateendrole score startyear endyear

gen ID = _n
reshape long year, i(ID) j(obs)
drop if mi(year)

bysort PERMCO year: egen dual_max = max(dual)

unique PERMCO year
duplicates drop PERMCO year, force

rename PERMCO lpermco
rename year fyear

save "$output\CEO_duality_x.dta", replace

* G-index
use "$maindir\GINDEX_ISS.dta", replace
keep TICKER YEAR GINDEX
rename TICKER tic
rename YEAR fyear
save "$output\GINDEX_x.dta", replace

use "$maindir\GOVERNANCE_ISS_07-23", replace
	duplicates drop Year TICKER, force
	rename (Year TICKER)(fyear tic)
	gen gparachute = 1 if GPARACHUTE == "YES"
	replace gparachute = 0 if mi(GPARACHUTE)
		ta gparachute
		
	gen ppill = 1 if PPILL == "YES"
	replace ppill = 0 if mi(PPILL)
		ta ppill
	keep fyear tic gparachute ppill
	label var gparachute "G-parachute"
save "$output\governance_iss_s", replace

** V2 board independence V2 
use "E:\21. Air Pollution and Accounting\DATA\cg variable to kexin", replace
rename ticker tic
rename year fyear
save "$output\board_characteristics", replace

use "$output\final_data_47662", replace
	capture drop _merge
merge m:1 tic fyear using "$output\female_board_x.dta"
	keep if _merge == 1 | _merge == 3
	
	capture drop _merge
merge 1:1 tic fyear using "$output\board_characteristics"
	keep if _merge == 1 | _merge == 3
	drop _merge

* genderratio, median = 0.9
label var genderratio "Gender ratio"
* dual_max, 0/1
* Female board%, dual role
replace boarddiversity = 1 if boarddiversity > 1
	eststo clear
label var boarddiversity "Female board\%"

global control_variables_aem size bm roa lev firm_age rank au_years oa_scale /*xrd_int*/
global control_variables_rem size bm roa lev firm_age rank au_years hhi_sale /*xrd_int*/

**# results 1 with OLD CONTROLS
	eststo clear
eststo regression1: reghdfe dacck visib Boardindependence c.visib#c.Boardindependence $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace
	
eststo regression2: reghdfe dacck visib boarddiversity c.visib#c.boarddiversity $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression3: reghdfe dac visib Boardindependence c.visib#c.Boardindependence $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression4: reghdfe dac visib boarddiversity c.visib#c.boarddiversity $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
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

esttab regression1 regression2 regression3 regression4 regression5 regression6 using "$output\results_governance_Boardind_femalePercent.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) drop($control_variables_rem $control_variables_aem) ///
mtitles("Board independence" "Female board\%" "Board independence" "Female board\%" "Board independence" "Female board\%") collabels(none) booktabs label scalar(ymean) order(visib Boardindependence c.visib#c.Boardindependence boarddiversity c.visib#c.boarddiversity ) ///
stats(yearfe indfe firmcont N ymean ar2, fmt(0 0 0 0 2 2) labels("Year FE" "Industry FE" "Firm Controls" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management by the Degree of Corporate Governance (Alternative Measures)}\label{tab: table15}\tabcolsep=0.1cm\scalebox{0.85}{\begin{tabular}{lcccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table reports how the effects of visibility on AEM and REM differ by the degree of the internal corporate governance. We use board independence and percentage of female board members as two separate measures for the level of corporate governance. The dependent variable in columns (1)-(4) is AEM, and the dependent variable in columns (5) and (6) is REM. The AEM measure in columns (1) and (2) is calculated using the performance-adjusted model, and the AEM measure in columns (3) and (4) is calculated using the modified Jone's model. A description of all variables can be found in Table \ref{tab: variabledescriptions}. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm and year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

**# results 1 with NEW CONTROLS
global control_variables_aem size bm roa lev firm_age rank au_years oa_scale /*xrd_int*/ loss grow /*Boardindependence*/ lit InstOwn stockreturn sale_sd rem

global control_variables_rem size bm roa lev firm_age rank au_years hhi_sale /*xrd_int*/ loss grow /*Boardindependence*/ lit InstOwn stockreturn sale_sd dac

use "$output\final_data_47662", replace

xtset lpermno fyear
gen stockreturn = (prcc_f - l.prcc_f)/l.prcc_f

*ssc install rangestat

rangestat (sd) sale, interval(fyear -2 0) by(lpermno)  
label var sale_sd "Sales Std3."

	capture drop _merge
merge 1:1 tic fyear using "$output\board_characteristics", force
	keep if _merge == 1 | _merge == 3
	capture drop _merge
merge 1:1 cusip8 fyear using "$output\institutional_ownership_x.dta", force
	keep if _merge == 1 | _merge == 3

label var grow "Sales growth"
label var loss "Loss"

destring sic, replace
gen lit = 1 if (sic >= 2833 & sic <= 2836) | (sic >= 3570 & sic <= 3577) | (sic >= 3600 & sic <=3674) | (sic >= 5200 & sic <= 5961) | (sic >= 7370 & sic <= 7379) | (sic >= 8731 & sic <= 8734)
replace lit = 0 if mi(lit) & !mi(sic)

label var lit "Litigious"

replace boarddiversity = 1 if boarddiversity > 1
	eststo clear
label var boarddiversity "Female board\%"
label var CEOduality "CEO dual"

	eststo clear
eststo regression1: reghdfe dacck visib Boardindependence c.visib#c.Boardindependence $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace
	
eststo regression2: reghdfe dacck visib boarddiversity c.visib#c.boarddiversity $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression3: reghdfe dac visib Boardindependence c.visib#c.Boardindependence $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression4: reghdfe dac visib boarddiversity c.visib#c.boarddiversity $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
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

esttab regression1 regression2 regression3 regression4 regression5 regression6 using "$output\results_governance_Boardind_femalePercent_NEW.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) drop($control_variables_rem $control_variables_aem) ///
mtitles("Board independence" "Female board\%" "Board independence" "Female board\%" "Board independence" "Female board\%") collabels(none) booktabs label scalar(ymean) order(visib Boardindependence c.visib#c.Boardindependence boarddiversity c.visib#c.boarddiversity ) ///
stats(yearfe indfe firmcont N ymean ar2, fmt(0 0 0 0 2 2) labels("Year FE" "Industry FE" "Firm Controls" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management by the Degree of Corporate Governance (Alternative Measures)}\label{tab: table15}\tabcolsep=0.1cm\scalebox{0.7}{\begin{tabular}{lcccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table reports how the effects of visibility on AEM and REM differ by the degree of the internal corporate governance. We use board independence and percentage of female board members as two separate measures for the level of corporate governance. The dependent variable in columns (1)-(4) is AEM, and the dependent variable in columns (5) and (6) is REM. The AEM measure in columns (1) and (2) is calculated using the performance-adjusted model, and the AEM measure in columns (3) and (4) is calculated using the modified Jone's model. Control variables include: firm size, book-to-market ratio, return on assets, leverage ratio, firm age, Big N auditor, number of years that a firm was audited by the same auditor, sale loss, sale growth, board independence, litigious industry, institutional ownership, stock return, 3-year rolling standard deviation of sales, $REM$ (for $AEM$), $AEM$ (for $REM$), net operating assets (with dependent variable being $AEM$, and Herfindahl–Hirschman index (with dependent variable being $REM$. A description of all variables can be found in Table \ref{tab: variabledescriptions}. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm and year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

**# Results 2 with OLD CONTROLS
global control_variables_aem size bm roa lev firm_age rank au_years oa_scale /*xrd_int*/
global control_variables_rem size bm roa lev firm_age rank au_years hhi_sale /*xrd_int*/

use "$output\final_data_47662", replace	
	capture drop _merge
merge 1:1 tic fyear using "$output\GINDEX_x.dta"
	keep if _merge == 1 | _merge == 3

	capture drop _merge
merge 1:1 tic fyear using "$output\governance_iss_s"
	keep if _merge == 1 | _merge == 3

	label var ppill "Poison and Pill"
	
eststo regression1: reghdfe dacck visib gparachute c.visib#c.gparachute $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression2: reghdfe dacck visib ppill c.visib#c.ppill $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace
	
eststo regression3: reghdfe dac visib gparachute c.visib#c.gparachute $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression4: reghdfe dac visib ppill c.visib#c.ppill $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression5: reghdfe rem visib gparachute c.visib#c.gparachute $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression6: reghdfe rem visib ppill c.visib#c.ppill $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 regression6 using "$output\results_governance2_gparachute_ppill.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) drop($control_variables_rem $control_variables_aem) ///
mtitles("G-parachute" "Poison and pill" "G-parachute" "Poison and pill" "G-parachute" "Poison and pill") collabels(none) booktabs label scalar(ymean) order(visib gparachute c.visib#c.gparachute ppill c.visib#c.ppill) ///
stats(yearfe indfe firmcont N ymean ar2, fmt(0 0 0 0 2 2) labels("Year FE" "Industry FE" "Firm Controls" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management by the Degree of Corporate Governance (Alternative Measures)}\label{tab: table15}\tabcolsep=0.1cm\scalebox{0.75}{\begin{tabular}{lcccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table reports how the effects of visibility on AEM and REM differ by the degree of the internal corporate governance. We use g-parachute and poison and pill as two separate measures for the level of corporate governance. The dependent variable in columns (1)-(4) is AEM, and the dependent variable in columns (5) and (6) is REM. The AEM measure in columns (1) and (2) is calculated using the performance-adjusted model, and the AEM measure in columns (3) and (4) is calculated using the modified Jone's model. Control variables include: firm size, book-to-market ratio, return on assets, leverage ratio, firm age, Big N auditor, number of years that a firm was audited by the same auditor, net operating assets (with dependent variable being AEM, and Herfindahl–Hirschman index (with dependent variable being REM. A description of all variables can be found in Table \ref{tab: variabledescriptions}. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm and year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

**# Results 2 with NEW CONTROLS
global control_variables_aem size bm roa lev firm_age rank au_years oa_scale /*xrd_int*/ loss grow Boardindependence lit InstOwn stockreturn sale_sd rem

global control_variables_rem size bm roa lev firm_age rank au_years hhi_sale /*xrd_int*/ loss grow Boardindependence lit InstOwn stockreturn sale_sd dac

use "$output\final_data_47662", replace	
	capture drop _merge
merge 1:1 tic fyear using "$output\GINDEX_x.dta"
	keep if _merge == 1 | _merge == 3

	capture drop _merge
merge 1:1 tic fyear using "$output\governance_iss_s"
	keep if _merge == 1 | _merge == 3

	label var ppill "Poison and Pill"

xtset lpermno fyear
gen stockreturn = (prcc_f - l.prcc_f)/l.prcc_f

*ssc install rangestat

rangestat (sd) sale, interval(fyear -2 0) by(lpermno)  
label var sale_sd "Sales Std3."

	capture drop _merge
merge 1:1 tic fyear using "$output\board_characteristics", force
	keep if _merge == 1 | _merge == 3
	capture drop _merge
merge 1:1 cusip8 fyear using "$output\institutional_ownership_x.dta", force
	keep if _merge == 1 | _merge == 3

label var grow "Sales growth"
label var loss "Loss"

destring sic, replace
gen lit = 1 if (sic >= 2833 & sic <= 2836) | (sic >= 3570 & sic <= 3577) | (sic >= 3600 & sic <=3674) | (sic >= 5200 & sic <= 5961) | (sic >= 7370 & sic <= 7379) | (sic >= 8731 & sic <= 8734)
replace lit = 0 if mi(lit) & !mi(sic)

label var lit "Litigious"

eststo regression1: reghdfe dacck visib gparachute c.visib#c.gparachute $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression2: reghdfe dacck visib ppill c.visib#c.ppill $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace
	
eststo regression3: reghdfe dac visib gparachute c.visib#c.gparachute $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression4: reghdfe dac visib ppill c.visib#c.ppill $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression5: reghdfe rem visib gparachute c.visib#c.gparachute $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression6: reghdfe rem visib ppill c.visib#c.ppill $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 regression6 using "$output\results_governance2_gparachute_ppill_NEW.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) drop($control_variables_rem $control_variables_aem) ///
mtitles("G-parachute" "Poison and pill" "G-parachute" "Poison and pill" "G-parachute" "Poison and pill") collabels(none) booktabs label scalar(ymean) order(visib gparachute c.visib#c.gparachute ppill c.visib#c.ppill) ///
stats(yearfe indfe firmcont N ymean ar2, fmt(0 0 0 0 2 2) labels("Year FE" "Industry FE" "Firm Controls" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management by the Degree of Corporate Governance (Alternative Measures)}\label{tab: table15}\tabcolsep=0.1cm\scalebox{0.75}{\begin{tabular}{lcccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table reports how the effects of visibility on AEM and REM differ by the degree of the internal corporate governance. We use g-parachute and poison and pill as two separate measures for the level of corporate governance. The dependent variable in columns (1)-(4) is AEM, and the dependent variable in columns (5) and (6) is REM. The AEM measure in columns (1) and (2) is calculated using the performance-adjusted model, and the AEM measure in columns (3) and (4) is calculated using the modified Jone's model. Control variables include: firm size, book-to-market ratio, return on assets, leverage ratio, firm age, Big N auditor, number of years that a firm was audited by the same auditor, sale loss, sale growth, board independence, litigious industry, institutional ownership, stock return, 3-year rolling standard deviation of sales, REM (for AEM), AEM (for REM), net operating assets (with dependent variable being AEM, and Herfindahl–Hirschman index (with dependent variable being REM. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm and year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

global control_variables_aem size bm roa lev firm_age rank au_years oa_scale /*xrd_int*/
global control_variables_rem size bm roa lev firm_age rank au_years hhi_sale /*xrd_int*/

**# Results 3 with OLD CONTROLS
use "$output\final_data_47662", replace
	capture drop _merge
merge 1:1 lpermco fyear using "$output\CEO_duality_x.dta"
	keep if _merge == 1 | _merge == 3

	capture drop _merge
merge 1:1 tic fyear using "$output\board_characteristics", force
	keep if _merge == 1 | _merge == 3
	
label var dual_max "CEO duality"
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

esttab regression1 regression2 regression3 regression4 regression5 regression6 using "$output\results_governance3_CEOduality.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) drop($control_variables_rem $control_variables_aem) ///
mtitles("CEO dual 1" "CEO dual 2" "CEO dual 1" "CEO dual 2" "CEO dual 1" "CEO dual 2") collabels(none) booktabs label scalar(ymean) order(visib CEOduality c.visib#c.CEOduality dual_max c.visib#c.dual_max) ///
stats(yearfe indfe firmcont N ymean ar2, fmt(0 0 0 0 2 2) labels("Year FE" "Industry FE" "Firm Controls" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management by the Degree of Corporate Governance (Alternative Measures)}\label{tab: table15}\tabcolsep=0.1cm\scalebox{0.85}{\begin{tabular}{lcccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table reports how the effects of visibility on AEM and REM differ by the degree of the internal corporate governance. We use two measures of CEO duality as two measures for the level of corporate governance. The dependent variable in columns (1)-(4) is AEM, and the dependent variable in columns (5) and (6) is REM. The AEM measure in columns (1) and (2) is calculated using the performance-adjusted model, and the AEM measure in columns (3) and (4) is calculated using the modified Jone's model. Control variables include: firm size, book-to-market ratio, return on assets, leverage ratio, firm age, Big N auditor, number of years that a firm was audited by the same auditor, net operating assets (with dependent variable being AEM, and Herfindahl–Hirschman index (with dependent variable being REM. A description of all variables can be found in Table \ref{tab: variabledescriptions}. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm and year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

global control_variables_aem size bm roa lev firm_age rank au_years oa_scale /*xrd_int*/ loss grow /*Boardindependence*/ lit InstOwn stockreturn sale_sd rem

global control_variables_rem size bm roa lev firm_age rank au_years hhi_sale /*xrd_int*/ loss grow /*Boardindependence*/ lit InstOwn stockreturn sale_sd dac

**# Results 3 with NEW CONTROLS
use "$output\final_data_47662", replace
	capture drop _merge
merge 1:1 lpermco fyear using "$output\CEO_duality_x.dta"
	keep if _merge == 1 | _merge == 3

	capture drop _merge
merge 1:1 tic fyear using "$output\board_characteristics", force
	keep if _merge == 1 | _merge == 3
	
label var dual_max "CEO duality"

xtset lpermno fyear
gen stockreturn = (prcc_f - l.prcc_f)/l.prcc_f

*ssc install rangestat

rangestat (sd) sale, interval(fyear -2 0) by(lpermno)  
label var sale_sd "Sales Std3."

	capture drop _merge
merge 1:1 tic fyear using "$output\board_characteristics", force
	keep if _merge == 1 | _merge == 3
	capture drop _merge
merge 1:1 cusip8 fyear using "$output\institutional_ownership_x.dta", force
	keep if _merge == 1 | _merge == 3

label var grow "Sales growth"
label var loss "Loss"

destring sic, replace
gen lit = 1 if (sic >= 2833 & sic <= 2836) | (sic >= 3570 & sic <= 3577) | (sic >= 3600 & sic <=3674) | (sic >= 5200 & sic <= 5961) | (sic >= 7370 & sic <= 7379) | (sic >= 8731 & sic <= 8734)
replace lit = 0 if mi(lit) & !mi(sic)

label var lit "Litigious"

	eststo clear
eststo regression1: reghdfe dacck visib CEOduality c.visib#c.CEOduality $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
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

esttab regression1 regression2 regression3 regression4 regression5 regression6 using "$output\results_governance3_CEOduality_NEW.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) drop($control_variables_rem $control_variables_aem) ///
mtitles("CEO dual 1" "CEO dual 2" "CEO dual 1" "CEO dual 2" "CEO dual 1" "CEO dual 2") collabels(none) booktabs label scalar(ymean) order(visib CEOduality c.visib#c.CEOduality dual_max c.visib#c.dual_max) ///
stats(yearfe indfe firmcont N ymean ar2, fmt(0 0 0 0 2 2) labels("Year FE" "Industry FE" "Firm Controls" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management by the Degree of Corporate Governance (Alternative Measures)}\label{tab: table15}\tabcolsep=0.1cm\scalebox{0.85}{\begin{tabular}{lcccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table reports how the effects of visibility on AEM and REM differ by the degree of the internal corporate governance. We use two measures of CEO duality as two measures for the level of corporate governance. The dependent variable in columns (1)-(4) is AEM, and the dependent variable in columns (5) and (6) is REM. The AEM measure in columns (1) and (2) is calculated using the performance-adjusted model, and the AEM measure in columns (3) and (4) is calculated using the modified Jone's model. Control variables include: firm size, book-to-market ratio, return on assets, leverage ratio, firm age, Big N auditor, number of years that a firm was audited by the same auditor, sale loss, sale growth, board independence, litigious industry, institutional ownership, stock return, 3-year rolling standard deviation of sales, REM (for AEM), AEM (for REM), net operating assets (with dependent variable being AEM, and Herfindahl–Hirschman index (with dependent variable being REM. A description of all variables can be found in Table \ref{tab: variabledescriptions}. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm and year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 


**# Reviewer 2 Comment 2 (cont'd): Firm Productivity Channel
global control_variables_aem size bm roa lev firm_age rank au_years oa_scale /*xrd_int*/
global control_variables_rem size bm roa lev firm_age rank au_years hhi_sale /*xrd_int*/
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

esttab regression1 regression2  using "$output\visib_firm_productivity.tex", replace ///
mtitles("\makecell{Stock compensation \\ balance}" "\makecell{After-tax \\ Stock Compen.}") collabels(none) booktabs label scalar(ymean) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Proxies for Firm Productivity}\label{tab: visib_firmprod}\tabcolsep=0.1cm\scalebox{0.9}{\begin{tabular}{lcc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: The dependent variables are indicated at the top of each column. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variables in columns (1)-(2) are: a firm's stock compensation and a firm's after-tex stock compensation. The control variables include: firm size, book-to-market ratio, return on assets, leverage ratio, firm age, Big N auditor, number of years that a firm was audited by the same auditor, net operating assets (with dependent variable being $AEM$, and Herfindahl–Hirschman index (with dependent variable being $REM$. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm-year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

**# Reviewer 2 Comment 2 (cont'd): Firm Productivity Channel， NEW CONTROLS
global control_variables_aem size bm roa lev firm_age rank au_years oa_scale /*xrd_int*/ loss grow Boardindependence lit InstOwn stockreturn sale_sd rem

global control_variables_rem size bm roa lev firm_age rank au_years hhi_sale /*xrd_int*/ loss grow Boardindependence lit InstOwn stockreturn sale_sd dac

use "$output\final_data_47662", replace

xtset lpermno fyear
gen stockreturn = (prcc_f - l.prcc_f)/l.prcc_f

*ssc install rangestat

rangestat (sd) sale, interval(fyear -2 0) by(lpermno)  
label var sale_sd "Sales Std3."

	capture drop _merge
merge 1:1 tic fyear using "$output\board_characteristics", force
	keep if _merge == 1 | _merge == 3
	capture drop _merge
merge 1:1 cusip8 fyear using "$output\institutional_ownership_x.dta", force
	keep if _merge == 1 | _merge == 3

label var grow "Sales growth"
label var loss "Loss"

destring sic, replace
gen lit = 1 if (sic >= 2833 & sic <= 2836) | (sic >= 3570 & sic <= 3577) | (sic >= 3600 & sic <=3674) | (sic >= 5200 & sic <= 5961) | (sic >= 7370 & sic <= 7379) | (sic >= 8731 & sic <= 8734)
replace lit = 0 if mi(lit) & !mi(sic)

label var lit "Litigious"


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

esttab regression1 regression2  using "$output\visib_firm_productivity_NEW_CONTROLS.tex", replace ///
mtitles("\makecell{Stock compensation \\ balance}" "\makecell{After-tax \\ Stock Compen.}") collabels(none) booktabs label scalar(ymean) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Proxies for Firm Productivity}\label{tab: visib_firmprod}\tabcolsep=0.1cm\scalebox{0.9}{\begin{tabular}{lcc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: The dependent variables are indicated at the top of each column. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variables in columns (1)-(2) are: a firm's stock compensation and a firm's after-tex stock compensation. The control variables include: firm size, book-to-market ratio, return on assets, leverage ratio, firm age, Big N auditor, number of years that a firm was audited by the same auditor, sale loss, sale growth, board independence, litigious industry, institutional ownership, stock return, 3-year rolling standard deviation of sales, $REM$ (for $AEM$), $AEM$ (for $REM$), net operating assets (with dependent variable being $AEM$, and Herfindahl–Hirschman index (with dependent variable being $REM$. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm-year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

**# Reviewer 2 Comment 2 (cont'd): Firm Productivity Channel，RET & ROA with NEW CONTROLS
global control_variables size bm lev firm_age rank au_years oa_scale hhi_sale /*xrd_int*/ loss salesgrowth /*Boardindependence*/ lit InstOwn_Perc sale_sd 

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

label var lit "Litigious"
replace InstOwn_Perc = 0 if mi(InstOwn_Perc)

*Litigious industry = 1 if 4-digit SIC is Pharmaceuticals (2833-2836), computer (3570-3577), electronics (3600-3674), retailing (5200-5961), programming (7370-7379), R&D services (8731-8734), and 0 otherwise.
xtset lpermno fyear

	eststo clear
eststo regression1: reghdfe roa visib $control_variables, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression2: reghdfe roa_F1 visib $control_variables, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression3: reghdfe roa_F2 visib $control_variables, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression4: reghdfe roa_F3 visib $control_variables, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression5: reghdfe stockreturn visib $control_variables, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression6: reghdfe stockreturn_F1 visib $control_variables, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression7: reghdfe stockreturn_F2 visib $control_variables, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression8: reghdfe stockreturn_F3 visib $control_variables, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 regression6 regression7 regression8 using "$output\visib_firm_productivity_roa_ret.tex", replace ///
mtitles("t" "t+1" "t+2" "t+3" "t" "t+1" "t+2" "t+3") collabels(none) booktabs label scalar(ymean) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Proxies for Firm Productivity}\label{tab: visib_firmprod2}\tabcolsep=0.1cm\scalebox{0.9}{\begin{tabular}{lcccccccc}\toprule")  ///
mgroups("Returns on assets" "Stock return", pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: The dependent variables are indicated at the top of each column. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variables in columns (1)-(4) are the current and forward values of a firm's returns on assets. The dependent variables in columns (5)-(8) are the current and forward values of a firm's stock returns. The control variables include: firm size, book-to-market ratio, leverage ratio, firm age, Big N auditor, number of years that a firm was audited by the same auditor, loss, sale growth, litigious industry, institutional ownership, 3-year rolling standard deviation of sales, net operating assets, and Herfindahl–Hirschman index. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm-year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

**# Reviewer 2 Comment 2 (cont'd): Firm Productivity

global control_variables size bm roa lev firm_age /*rank au_years oa_scale*/ hhi_sale /*xrd_int*/ loss salesgrowth /*Boardindependence*/ /*lit*/ InstOwn_Perc /*sale_sd*/ 

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

label var lit "Litigious"
replace InstOwn_Perc = 0 if mi(InstOwn_Perc)

*Litigious industry = 1 if 4-digit SIC is Pharmaceuticals (2833-2836), computer (3570-3577), electronics (3600-3674), retailing (5200-5961), programming (7370-7379), R&D services (8731-8734), and 0 otherwise.

*Operating Income
replace uopi = 0 if uopi < 0 
gen log_uopi = log(uopi+1)
replace log_uopi = 0 if mi(log_uopi)
label var log_uopi "Output level of the enterprise" // operating income

* Net fixed assets
gen log_ppent = log(ppent+1)
label var log_ppent "Capital input"

* Intermediate input
gen lnm = log(cogs + xsga + tie - dp + 1)
replace lnm = 0 if mi(lnm)
label var lnm "Intermediate input"

* Number of employees
gen lemp = log(emp + 1)
label var lemp "Number of employees"

* TFP as residuals
gen tfp = log_uopi - log_ppent - lnm - lemp
label var tfp "Total factor productivity"
sum tfp
local minimum_tfp = r(min)
replace tfp = tfp + (-1)*`minimum_tfp'
gen log_tfp = log(tfp)

	eststo clear
eststo regression1: reghdfe log_tfp visib $control_variables, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

esttab regression1 using "$output\visib_firm_productivity_tfp.tex", replace ///
mtitles("TFP") collabels(none) booktabs label scalar(ymean) starlevels(* 0.2 ** 0.1 *** 0.02) compress style(tab) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Firm TFP}\label{tab: visibTFP}\tabcolsep=0.1cm\scalebox{0.9}{\begin{tabular}{lcc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: The dependent variables are indicated at the top of each column. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variables in column (1) is a firm's TFP. The control variables include: firm size, book-to-market ratio, return on assets, leverage ratio, firm age, Herfindahl–Hirschman index, loss, sales growth, and institutional ownship. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm-year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

**# Reviewer 2 Comment 4: Add Controls (Table 5)
global control_variables_aem size bm roa lev firm_age rank au_years oa_scale /*xrd_int*/ loss salesgrowth /*Boardindependence*/ lit InstOwn_Perc stockreturn sale_sd rem

global control_variables_rem size bm roa lev firm_age rank au_years hhi_sale /*xrd_int*/ loss salesgrowth /*Boardindependence*/ lit InstOwn_Perc stockreturn sale_sd dac

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

label var grow "Sales growth"
label var loss "Loss"

gen lit = 1 if (sic >= 2833 & sic <= 2836) | (sic >= 3570 & sic <= 3577) | (sic >= 3600 & sic <=3674) | (sic >= 5200 & sic <= 5961) | (sic >= 7370 & sic <= 7379) | (sic >= 8731 & sic <= 8734)
replace lit = 0 if mi(lit) & !mi(sic)

label var lit "Litigious"
replace InstOwn_Perc = 0 if mi(InstOwn_Perc)

*Litigious industry = 1 if 4-digit SIC is Pharmaceuticals (2833-2836), computer (3570-3577), electronics (3600-3674), retailing (5200-5961), programming (7370-7379), R&D services (8731-8734), and 0 otherwise.
xtset lpermno fyear
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

esttab regression1 regression2 regression3 regression4 regression5 using "$output\table4_newcontrols.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
mtitles("\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jone's')}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") collabels(none) booktabs label scalar(ymean) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management}\label{tab: table4newcontrols}\tabcolsep=0.1cm\scalebox{0.8}{\begin{tabular}{lccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: The dependent variables are indicated at the top of each column. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variables in columns (1)-(3) are: a firms' accrual earnings management calculated using the performance-adjusted method, a firm's accrual earnings management calculated using the modified Jone's method, and the rank of the firm's accrual earnings management (modified Jone's), respectively. The dependent variables in columns (4)-(5) are: a firm's real earnings management, and the rank of the firm's real earnings management, respectively. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm-year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 


