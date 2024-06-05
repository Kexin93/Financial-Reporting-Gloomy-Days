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

**# Prepare data sets with control variables
* 1) sales rolling standard deviation
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

* 2) board independence
use "E:\21. Air Pollution and Accounting\DATA\cg variable to kexin", replace
rename ticker tic
rename year fyear
save "$output\board_characteristics", replace

* 3) Institutional Ownership
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

* 4) G-index
use "$maindir\GINDEX_ISS.dta", replace
keep TICKER YEAR GINDEX
rename TICKER tic
rename YEAR fyear
save "$output\GINDEX_x.dta", replace

* 5) G-parachute
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

* 6) Knowledge-intensive industries
import excel using "E:\21. Air Pollution and Accounting\DATA\R&R\knowledge intensive industry.xlsx", firstrow clear
rename SIC sic

bysort sic: gen dup = _n
drop if dup > 1
save "$output\knowledge_intensive_industry.dta", replace

* 7) CEO-chairman duality
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

**# Define control variables
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

**# Table 2
eststo summ_stats: estpost sum $summ_vars

eststo obs: estpost summarize $summ_vars

ereturn list 

eststo Mean: estpost summarize $summ_vars

ereturn list 

eststo p25: estpost summarize $summ_vars, detail

ereturn list 

eststo p50: estpost summarize $summ_vars, detail

ereturn list 

eststo p75: estpost summarize $summ_vars, detail

ereturn list 

eststo std: estpost summarize $summ_vars

ereturn list 

eststo Median: estpost summarize $summ_vars

ereturn list 

* .tex
esttab obs Mean std p25 p50 p75 using "$output\summ_stats_firm.tex", fragment  ///
label cells("count(pattern(1 0 0 0 0 0)) mean(pattern(0 1 0 0 0 0) fmt(3)) sd(pattern(0 0 1 0 0 0) fmt(3)) p25(pattern(0 0 0 1 0 0) fmt(3)) p50(pattern(0 0 0 0 1 0) fmt(3)) p75(pattern(0 0 0 0 0 1) fmt(3))") noobs  ///
nonumbers replace booktabs collabels(none) mtitles("N" "Mean" "Std. Dev." "Bottom 25\%" "Median" "Top 25\%") ///
prehead("\begin{table}\begin{center}\caption{Summary Statistics of Firm Characteristics}\label{tab: summstats1}\tabcolsep=0.1cm\scalebox{0.6}{\begin{tabular}{lcccccc}\toprule")  ///
postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table reports the descriptive statistics of firm-level characteristics for 12,191 firm-year observations from 2003 to 2017. Firm characteristics are obtained from Compustat and I/B/E/S databases. We restrict the sample to be within a year before the actual period end date of each firm's financial report. Refer to Appendices A to C for detailed variable definitions and measurements. Descriptions of each variable can be found in Table \ref{tab: variabledescriptions}.}\end{table}")

**# Table 3

* ==============================================================================
* ============================ Other weather Summary Statistics ==========================
* ==============================================================================
label var temp "Temp."
label var dewp "Dew" 
label var slp  "Sea-level Pressure"
label var visib "Visibility"
label var wdsp  "Wind"
label var mxspd  "Max Wind"
label var min  "Min Temp."
label var fog  "Fog"
label var rain  "Rain"
label var thunder  "Thunder"
label var gust  "Gust"
label var max  "Max Temp."
label var prcp  "Total Precip."
label var sndp  "Snow Depth"
label var snow  "Snow"
label var hail  "Hail"
label var tornado "Tornado"

replace prcp = . if prcp > 99

global summ_vars_weather temp dewp slp visib wdsp ///
				 gust mxspd prcp sndp max min fog rain snow   ///
				  hail thunder tornado
				  
* Summary statistics continued
	eststo clear
eststo summ_stats: estpost sum $summ_vars_weather

eststo obs: estpost summarize $summ_vars_weather

ereturn list 

eststo Mean: estpost summarize $summ_vars_weather

ereturn list 

eststo p25: estpost summarize $summ_vars_weather, detail

ereturn list 

eststo p50: estpost summarize $summ_vars_weather, detail

ereturn list 

eststo p75: estpost summarize $summ_vars_weather, detail

ereturn list 

eststo std: estpost summarize $summ_vars_weather

ereturn list 

eststo Median: estpost summarize $summ_vars_weather

ereturn list 

* .tex
esttab obs Mean std p25 p50 p75 using "$output\summ_stats_weather.tex", fragment  ///
label cells("count(pattern(1 0 0 0 0 0)) mean(pattern(0 1 0 0 0 0) fmt(3)) sd(pattern(0 0 1 0 0 0) fmt(3)) p25(pattern(0 0 0 1 0 0) fmt(3)) p50(pattern(0 0 0 0 1 0) fmt(3)) p75(pattern(0 0 0 0 0 1) fmt(3))") noobs  ///
nonumbers replace booktabs collabels(none) mtitles("N" "Mean" "Std. Dev." "Bottom 25\%" "Median" "Top 25\%") ///
prehead("\begin{table}\begin{center}\caption{Summary Statistics of Weather-related Characteristics}\label{tab: summstats2}\tabcolsep=0.1cm\scalebox{0.67}{\begin{tabular}{lcccccc}\toprule")  ///
postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table reports the descriptive statistics of weather-related characteristics for 12,191 firm-year observations from 2003 to 2017. Details of each weather-related variable, including the definition and unit, can be found in Table \ref{tab: variabledescriptions2}.}\end{table}") 

**# Table 4
*========= t-test table ========================
summarize visib if !mi(visib), d
local visib_median = r(p50) 
gen polluted = (visib < `visib_median') if !mi(visib)

eststo allsample: estpost summarize $summ_vars

eststo polluted_sample: estpost summarize $summ_vars if polluted == 1

eststo unpolluted_sample: estpost summarize $summ_vars if polluted == 0

gen unpolluted = -polluted
eststo difference:  estpost ttest $summ_vars, by(unpolluted)

esttab allsample polluted_sample unpolluted_sample difference using "$output\ttest.tex", ///
replace cells("mean(pattern(1 1 1 0)  fmt(3)) b(star pattern(0 0 0 1) fmt(3)) ") ///
label mtitles("All" "Polluted" "Unpolluted" "Polluted-Unpolluted") collabels(none) nonumbers booktabs ///
prehead("\begin{table}\begin{center}\caption{Uni-variate Test}\label{tab: ttest}\tabcolsep=0.1cm\begin{tabular}{lcccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}\end{center}\footnotesize{Notes: This table shows the univarite test of the difference between firms that are exposed to better air quality and those that are exposed to worse air quality (which is characterized by lower-than-median visibility over the years between 2003 and 2017). A description of all variables can be found in Table \ref{tab: variabledescriptions}. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

**# Table 5
label var dac "AEM"
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

esttab regression1 regression2 regression3 regression4 regression5 using "$output\table4.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
mtitles("\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jones')}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") collabels(none) booktabs label scalar(ymean) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management}\label{tab: table4}\tabcolsep=0.1cm\scalebox{0.9}{\begin{tabular}{lccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: The dependent variables are indicated at the top of each column. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variables in columns 1-3 are: a firms' accrual earnings management calculated using the performance-adjusted modified Jones method, a firm's accrual earnings management calculated using the modified Jones method, and the rank of the firm's accrual earnings management (modified Jones) within the same industry and year, respectively. The dependent variables in columns 4-5 are: a firm's real earnings management and the rank of the firm's real earnings management within the same industry and year, respectively. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm-year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

**# Table 6
*======================= Decomposition of REM ========================
eststo sales1: reghdfe d_cfo_neg visib $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize d_cfo_neg
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo sales2: reghdfe rank_d_cfo_neg visib $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) 
estadd scalar ar2 = e(r2_a)
summarize rank_d_cfo_neg
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo overprod1: reghdfe d_prod visib $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize d_prod
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo overprod2: reghdfe rank_d_prod visib $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_d_prod
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo expenditure1: reghdfe d_discexp_neg visib $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize d_discexp_neg
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo expenditure2: reghdfe rank_d_discexp_neg visib $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_d_discexp_neg
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

esttab sales1 sales2 overprod1 overprod2 expenditure1 expenditure2 using "$output\table5.tex", replace ///
depvars collabels(none) booktabs label scalar(ymean) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effects of Visibility on Individual REM Measures}\label{tab: table5}\tabcolsep=0.1cm\scalebox{0.62}{\begin{tabular}{lcccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: The table reports the effects of visibility on each component of the aggregate measure of real earnings management (REM). A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variables are indicated at the top of each column. The dependent variables in columns 1-2 are: the discretionary cash flow component of a firm's REM, and the rank of this component within the same industry and year. To be consistent with the sign of the aggregate measure of REM, we take the negative value of discretionary cash flows. The dependent variables in columns 3-4 are: the production cost component of a firm's REM, and the rank of this component within the same industry and year. The dependent variables in columns 5-6 are: the discretionary expense component of a firm's REM, and the rank of this component within the same industry and year. To be consistent with the sign of the aggregate REM, we take the negative value of discretionary expenses. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm and year.  *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

global control_variables_aem_t78 size bm roa lev firm_age rank au_years oa_scale /*xrd_int*/
global control_variables_rem_t78 size bm roa lev firm_age rank au_years hhi_sale /*xrd_int*/
**# Table 7
*================================== External Monitoring? Analyst ================================
	eststo clear
eststo regression1: reghdfe dacck visib cover c.visib#c.cover $control_variables_aem_t78, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace	

eststo regression2: reghdfe dac visib cover c.visib#c.cover $control_variables_aem_t78, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression3: reghdfe rank_dac visib cover c.visib#c.cover $control_variables_aem_t78, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression4: reghdfe rem visib cover c.visib#c.cover $control_variables_rem_t78, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression5: reghdfe rank_rem visib cover c.visib#c.cover $control_variables_rem_t78, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 using "$output\table8.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) drop($control_variables_rem_t78 $control_variables_aem_t78) ///
mtitles("\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jones)}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") collabels(none) booktabs label scalar(ymean) order(visib cover c.visib#c.cover) starlevels(* 0.2 ** 0.1 *** 0.02) ///
stats(firmcont yearfe indfe N ymean ar2, fmt(0 0 0 0 2 2) labels("Baseline Controls" "Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management by the Degree of External Control}\label{tab: table8}\tabcolsep=0.1cm\scalebox{0.82}{\begin{tabular}{lccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table reports how the effects of visibility on AEM, the rank of AEM, REM, and the rank of REM differ by the degree of external monitoring. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variable in column 1 is the performance-adjusted AEM measure, the dependent variable in column 2 is the AEM measure that is calculated using the modified Jones model, the dependent variable in column 3 is the rank of AEM (modified Jones) within the same industry and year, the dependent variable in column 4 is REM, and the dependent variable in column 5 is the rank of REM within the same industry and year. Baseline controls are the same as in Table \ref{tab: table4}.  Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm and year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

**# Table 8
*========== Table 15: visibility interacts with internal monitoring to REM ======================== 
* Panel A
label var CGOV_str_num "CG Strengths"
label var CGOV_con_num "CG Concerns"
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
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) drop($control_variables_rem_t78 $control_variables_aem_t78) mtitles("\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jones)}" "\makecell{AEM \\ (modified Jones)}" "REM" "REM") nonumbers collabels(none) booktabs label scalar(ymean) order(visib CGOV_str_num c.visib#c.CGOV_str_num CGOV_con_num c.visib#c.CGOV_con_num) starlevels(* 0.2 ** 0.1 *** 0.02) ///
stats(firmcont yearfe indfe N ymean ar2, fmt(0 0 0 0 2 2) labels("Baseline Controls" "Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management by the Degree of Corporate Governance}\label{tab: table15}\tabcolsep=0.1cm\scalebox{0.65}{\begin{tabular}{lcccccc}\toprule") posthead("\midrule&\multicolumn{6}{c}{\textbf{Panel A: CG Strengths and CG Concerns}}\\")

* Panel B
label var boarddiversity "Female board\%"
label var Boardindependence "Board ind."
	eststo clear
eststo regression1: reghdfe dacck visib Boardindependence c.visib#c.Boardindependence $control_variables_aem_t78, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) 
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace
	
eststo regression2: reghdfe dacck visib boarddiversity c.visib#c.boarddiversity $control_variables_aem_t78, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression3: reghdfe dac visib Boardindependence c.visib#c.Boardindependence $control_variables_aem_t78, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) 
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression4: reghdfe dac visib boarddiversity c.visib#c.boarddiversity $control_variables_aem_t78, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression5: reghdfe rem visib Boardindependence c.visib#c.Boardindependence $control_variables_rem_t78, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression6: reghdfe rem visib boarddiversity c.visib#c.boarddiversity $control_variables_rem_t78, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 regression6 using "$output\table15_panelAB.tex", append fragment ///
drop($control_variables_rem_t78 $control_variables_aem_t78) ///
nomtitles nonumbers collabels(none) booktabs label scalar(ymean) order(visib Boardindependence c.visib#c.Boardindependence boarddiversity c.visib#c.boarddiversity) starlevels(* 0.2 ** 0.1 *** 0.02) ///
stats(firmcont yearfe indfe N ymean ar2, fmt(0 0 0 0 2 2) labels("Baseline Controls" "Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
posthead("\midrule&\multicolumn{6}{c}{\textbf{Panel B: Board Independence and Percentage of Female Board Members}}\\") postfoot("\bottomrule\end{tabular}}\end{center}\end{table}") 


* Panel C
	capture drop _merge
merge 1:1 tic fyear using "$output\GINDEX_x.dta"
	keep if _merge == 1 | _merge == 3

	capture drop _merge
merge 1:1 tic fyear using "$output\governance_iss_s"
	keep if _merge == 1 | _merge == 3

	label var ppill "Poison pill"
	
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
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) drop($control_variables_rem_t78 $control_variables_aem_t78) mtitles("\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jones)}" "\makecell{AEM \\ (modified Jones)}" "REM" "REM")  nonumbers collabels(none) booktabs label stats(firmcont yearfe indfe N ymean ar2, fmt(0 0 0 0 2 2) labels("Baseline Controls" "Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) order(visib gparachute c.visib#c.gparachute ppill c.visib#c.ppill) prehead("\begin{table}\begin{center}\scalebox{0.65}{\begin{tabular}{lcccccc}\toprule") posthead("\midrule&\multicolumn{6}{c}{\textbf{Panel C: G-parachute and Poison Pill}}\\") starlevels(* 0.2 ** 0.1 *** 0.02)

* Panel D
	capture drop _merge
merge 1:1 lpermco fyear using "$output\CEO_duality_x.dta"
	keep if _merge == 1 | _merge == 3

	capture drop _merge
merge 1:1 tic fyear using "$output\board_characteristics", force
	keep if _merge == 1 | _merge == 3
	
label var dual_max "CEO duality"
	eststo clear
eststo regression1: reghdfe dacck  visib CEOduality c.visib#c.CEOduality $control_variables_aem_t78, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression2: reghdfe dacck visib dual_max c.visib#c.dual_max $control_variables_aem_t78, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace
	
eststo regression3: reghdfe dac visib CEOduality c.visib#c.CEOduality $control_variables_aem_t78, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression4: reghdfe dac visib dual_max c.visib#c.dual_max $control_variables_aem_t78, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression5: reghdfe rem visib CEOduality c.visib#c.CEOduality $control_variables_rem_t78, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression6: reghdfe rem visib dual_max c.visib#c.dual_max $control_variables_rem_t78, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 regression6 using "$output\table15_panelCD.tex", append fragment ///
drop($control_variables_rem_t78 $control_variables_aem_t78) ///
nomtitles nonumbers collabels(none) booktabs label scalar(ymean) order(visib CEOduality c.visib#c.CEOduality dual_max c.visib#c.dual_max) ///
stats(firmcont yearfe indfe N ymean ar2, fmt(0 0 0 0 2 2) labels("Baseline Controls" "Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) starlevels(* 0.2 ** 0.1 *** 0.02) ///
posthead("\midrule&\multicolumn{6}{c}{\textbf{Panel D: CEO-Chairman Duality}}\\") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table reports how the effects of visibility on AEM and REM differ by the degree of the internal corporate governance (measured by CGOV Strengths, CGOV Concerns, board independence, percentage of female board members, G-parachute, Poison and Pill, and CEO-chairman duality. The dependent variable in columns 1-4 is AEM, and the dependent variable in columns 5-6 is REM. The AEM measure in columns 1 and 2 is calculated using the performance-adjusted model, and the AEM measure in columns 3 and 4 is calculated using the modified Jones model. The same baseline control variables are included as in Table \ref{tab: table4}. Refer to Appendices A to C for detailed variable definitions and measurements. A description of all variables can be found in Table \ref{tab: variabledescriptions}. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm and year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

**# Table 9
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
estadd local firmcont "Yes", replace

eststo regression2: reghdfe dac visib $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression3: reghdfe rank_dac visib $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression4: reghdfe rem visib $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression5: reghdfe rank_rem visib $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 using "$output\table9_panelAB.tex", replace fragment keep(visib) ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
mtitles("\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jones)}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") collabels(none) booktabs label ///
stats(firmcon yearfe indfe N ymean ar2, fmt(0 0 0 0 2 2) labels("Baseline Controls" "Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management: Knowledge-Intensive vs. Labor-Intensive Industries}\label{tab: table9}\tabcolsep=0.1cm\scalebox{0.65}{\begin{tabular}{lccccc}\toprule") posthead("\midrule & \multicolumn{5}{c}{\textbf{Panel A: Knowledge-Intensive Industries Subsample}}\\") 
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
estadd local firmcont "Yes", replace
	
eststo regression2: reghdfe dac visib $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression3: reghdfe rank_dac visib $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression4: reghdfe rem visib $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression5: reghdfe rank_rem visib $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 using "$output\table9_panelAB.tex", append fragment keep(visib) ///
nomtitles nonumbers collabels(none) booktabs label ///
stats(firmcon yearfe indfe N ymean ar2, fmt(0 0 0 0 2 2) labels("Baseline Controls" "Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) posthead("\midrule& \multicolumn{5}{c}{\textbf{Panel B: Non-Knowledge-Intensive Industries Subsample}}\\") ///
postfoot("\bottomrule\end{tabular}}\end{center}\end{table}") 
restore

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
estadd local firmcont "Yes", replace

eststo regression2: reghdfe dac visib $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression3: reghdfe rank_dac visib $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression4: reghdfe rem visib $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace 
estadd local firmcont "Yes", replace

eststo regression5: reghdfe rank_rem visib $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 using "$output\table9_panelCD.tex", replace fragment keep(visib) /// 
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
mtitles("\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jones)}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") collabels(none) booktabs label ///
stats(firmcon yearfe indfe N ymean ar2, fmt(0 0 0 0 2 2) labels("Baseline Controls" "Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\\tabcolsep=0.1cm\scalebox{0.9}{\begin{tabular}{lccccc}\toprule") posthead("\midrule& \multicolumn{5}{c}{\textbf{Panel C: Labor-Intensive Industries Subsample}}\\") 
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
estadd local firmcont "Yes", replace

eststo regression2: reghdfe dac visib $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression3: reghdfe rank_dac visib $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression4: reghdfe rem visib $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression5: reghdfe rank_rem visib $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 using "$output\table9_panelCD.tex", append fragment keep(visib) ///
nomtitles nonumbers collabels(none) booktabs label ///
stats(firmcon yearfe indfe N ymean ar2, fmt(0 0 0 0 2 2) labels("Baseline Controls" "Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) posthead("\midrule& \multicolumn{5}{c}{\textbf{Panel D: Non-Labor-Intensive Industries Subsample}}\\") ///
postfoot("\bottomrule\end{tabular}}\end{center}\end{table}") 
restore

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

label var fog "Fog"
	eststo clear
eststo regression1: reghdfe log_tfp visib $control_variables, absorb(fyear) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "No", replace
estadd local firmcont "Yes", replace

eststo regression2: reghdfe log_tfp visib $control_variables, absorb(ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "No", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression3: reghdfe log_tfp visib $control_variables, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

esttab regression1 regression2 regression3 using "$output\table9_panelE.tex", replace fragment ///
nomtitles collabels(none) booktabs label ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\tabcolsep=0.1cm\scalebox{0.8}{\begin{tabular}{lccc}\toprule") /*starlevels(* 0.2 ** 0.1 *** 0.02)*/ compress style(tab) posthead("\midrule &\multicolumn{3}{c}{\textbf{Panel E: Total Factor Productivity}}\\") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: The dependent variables are indicated at the top of each column. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variables in columns 1-3 of Panels A-D are: a firms' accrual earnings management calculated using the performance-adjusted method, a firm's accrual earnings management calculated using the modified Jones method, and the rank of the firm's accrual earnings management (modified Jones), respectively. The dependent variables in columns 4-5 of panels A-D are: a firm's real earnings management, and the rank of the firm's real earnings management, respectively. The dependent variable in panel E is each firm's total factor productivity. Baseline variables that are included in Panel A to Panel D are the same as in Table \ref{tab: table4}. Year fixed effects and industry fixed effects are included in all regressions. Refer to Appendices A to C for detailed variable definitions and measurements. Descriptions of each variable can be found in Table \ref{tab: variabledescriptions}. Standard errors are clustered at the level of firm-year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

**# Table 11
preserve
clear
use "$maindir\costal and inland", replace
gen ZipCodeState=""
replace ZipCodeState="AL" if state_full =="Alabama"
replace ZipCodeState="AK" if state_full =="Alaska"
replace ZipCodeState="AZ" if state_full =="Arizona"
replace ZipCodeState="AR" if state_full =="Arkansas"
replace ZipCodeState="CA" if state_full =="California"
replace ZipCodeState="CZ" if state_full =="Canal Zone"
replace ZipCodeState="CO" if state_full =="Colorado"
replace ZipCodeState="CT" if state_full =="Connecticut"
replace ZipCodeState="DE" if state_full =="Delaware"
replace ZipCodeState="DC" if state_full =="District of Columbia"
replace ZipCodeState="FL" if state_full =="Florida"
replace ZipCodeState="GA" if state_full =="Georgia"
replace ZipCodeState="GU" if state_full =="Guam"
replace ZipCodeState="HI" if state_full =="Hawaii"
replace ZipCodeState="ID" if state_full =="Idaho"
replace ZipCodeState="IL" if state_full =="Illinois"
replace ZipCodeState="IN" if state_full =="Indiana"
replace ZipCodeState="IA" if state_full =="Iowa"
replace ZipCodeState="KS" if state_full =="Kansas"
replace ZipCodeState="KY" if state_full =="Kentucky"
replace ZipCodeState="LA" if state_full =="Louisiana"
replace ZipCodeState="ME" if state_full =="Maine"
replace ZipCodeState="MD" if state_full =="Maryland"
replace ZipCodeState="MA" if state_full =="Massachusetts"
replace ZipCodeState="MI" if state_full =="Michigan"
replace ZipCodeState="MN" if state_full =="Minnesota"
replace ZipCodeState="MS" if state_full =="Mississippi"
replace ZipCodeState="MO" if state_full =="Missouri"
replace ZipCodeState="MT" if state_full =="Montana"
replace ZipCodeState="NE" if state_full =="Nebraska"
replace ZipCodeState="NV" if state_full =="Nevada"
replace ZipCodeState="NH" if state_full =="New Hampshire"
replace ZipCodeState="NJ" if state_full =="New Jersey"
replace ZipCodeState="NM" if state_full =="New Mexico"
replace ZipCodeState="NY" if state_full =="New York"
replace ZipCodeState="NC" if state_full =="North Carolina"
replace ZipCodeState="ND" if state_full =="North Dakota"
replace ZipCodeState="OH" if state_full =="Ohio"
replace ZipCodeState="OK" if state_full =="Oklahoma"
replace ZipCodeState="OR" if state_full =="Oregon"
replace ZipCodeState="PA" if state_full =="Pennsylvania"
replace ZipCodeState="PR" if state_full =="Puerto Rico"
replace ZipCodeState="RI" if state_full =="Rhode Island"
replace ZipCodeState="SC" if state_full =="South Carolina"
replace ZipCodeState="SD" if state_full =="South Dakota"
replace ZipCodeState="TN" if state_full =="Tennessee"
replace ZipCodeState="TX" if state_full =="Texas"
replace ZipCodeState="UT" if state_full =="Utah"
replace ZipCodeState="VT" if state_full =="Vermont"
replace ZipCodeState="VI" if state_full =="Virgin Islands"
replace ZipCodeState="VA" if state_full =="Virginia"
replace ZipCodeState="WA" if state_full =="Washington"
replace ZipCodeState="WV" if state_full =="West Virginia"
replace ZipCodeState="WI" if state_full =="Wisconsin"
replace ZipCodeState="WY" if state_full =="Wyoming"
tempfile state_short_name
save `state_short_name', replace
restore

capture drop _merge
merge m:1 ZipCodeState using `state_short_name'
keep if _merge == 3

label var coastal "Coastal"

	eststo clear
eststo regression1: reghdfe rem visib $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace

eststo regression2: reghdfe rem visib $control_variables_rem coastal, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace

eststo regression3: reghdfe rem visib $control_variables_rem coastal c.visib#c.coastal, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace

eststo regression4: reghdfe rank_rem visib $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace

eststo regression5: reghdfe rank_rem visib $control_variables_rem coastal, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace

eststo regression6: reghdfe rank_rem visib $control_variables_rem coastal c.visib#c.coastal, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace
		
esttab regression1 regression2 regression3 regression4 regression5 regression6 using "$output\table22.tex", replace ///
mgroups("Real Earnings Management" "Rank of Real Earnings Management", pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
nomtitles collabels(none) booktabs label scalar(ymean) drop($control_variables_rem) ///
stats(blcontrols yearfe indfe N ymean ar2, fmt(0 0 0 0 2 2) labels("Baseline Controls" "Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Real Earnings Management in Coastal Regions}\label{tab: table22}\tabcolsep=0.1cm\scalebox{0.8}{\begin{tabular}{lcccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table reports the effects of visibility on the aggregate measure of real earnings management (REM) and the rank of REM. A description of all variables can be found in Table \ref{tab: variabledescriptions}. Columns 1-3 report the effects of visibility on REM, and columns 4-6 report the effects of visibility on the rank of REM. Columns 1 and 4 are the baseline specifications. Columns 2 and 5 include an indicator for whether the state the firm is located in is coastal. Columns 3 and 6 further include the interaction term between the coastal indicator variable and visiblity as an additional control. Baseline controls are the same as in Table \ref{tab: table4}. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm and year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

**# Table 12
	capture drop _merge
	capture drop pollutant_value
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
estadd local firmcont "Yes", replace

eststo regression2: reghdfe dac visib_PM2_5 $control_variables_aem, absorb(i.fyear i.ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression3: reghdfe rank_dac visib_PM2_5 $control_variables_aem, absorb(i.fyear i.ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression4: reghdfe rem visib_PM2_5 $control_variables_rem, absorb(i.fyear i.ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression5: reghdfe rank_rem visib_PM2_5 $control_variables_rem, absorb(i.fyear i.ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 using "$output\table12.tex", replace fragment ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
mtitles("\makecell{AEM \\ (performance \\ -adj.)}" "\makecell{AEM \\ (modified \\ Jones)}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") nonumbers collabels(none) nolines booktabs label keep(visib_PM2_5) ///
stats(firmcont yearfe indfe N ymean ar2, fmt(0 0 0 0 2 2) labels("Baseline Controls" "Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management: Using Actual Air Pollution Measures}\label{tab: table12}\tabcolsep=0.3cm\scalebox{0.8}{\begin{tabular}{lccccc}\toprule")  ///
posthead("\midrule &\multicolumn{5}{c}{\textbf{Panel A: Using Visibility Explained by PM 2.5 and Residual}} \\")

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
estadd local firmcon "Yes", replace

eststo regression2: reghdfe dac visib_res $control_variables_aem, absorb(i.fyear i.ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcon "Yes", replace

eststo regression3: reghdfe rank_dac visib_res $control_variables_aem, absorb(i.fyear i.ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcon "Yes", replace

eststo regression4: reghdfe rem visib_res $control_variables_rem, absorb(i.fyear i.ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcon "Yes", replace

eststo regression5: reghdfe rank_rem visib_res $control_variables_rem, absorb(i.fyear i.ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcon "Yes", replace

global first_stage size bm roa lev firm_age rank au_years oa_scale hhi_sale /*xrd_int*/

esttab regression1 regression2 regression3 regression4 regression5 using "$output\table12.tex", append  ///
booktabs label scalar(ymean) nomtitles nonumbers fragment nolines keep(visib_res) ///
posthead("\midrule") ///
stats(firmcon yearfe indfe N ymean ar2, fmt(0 0 0 0 2 2) labels("Baseline Controls" "Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) postfoot("\midrule")

	eststo clear
eststo regression1: reghdfe dacck pollutant_value $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcon "Yes", replace

eststo regression2: reghdfe dac pollutant_value $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcon "Yes", replace

eststo regression3: reghdfe rank_dac pollutant_value $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcon "Yes", replace

eststo regression4: reghdfe rem pollutant_value $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcon "Yes", replace

eststo regression5: reghdfe rank_rem pollutant_value $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcon "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 using "$output\table12.tex", append fragment ///
nomtitles nonumbers collabels(none) booktabs label ///
stats(firmcon yearfe indfe N ymean ar2, fmt(0 0 0 0 2 2) labels("Baseline Controls" "Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) keep(pollutant_value) ///
posthead("&\multicolumn{5}{c}{\textbf{Panel B: Using PM 2.5 Instead of Visibility}} \\") ///
postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: The dependent variables are indicated at the top of each column. The dependent variable in column 1 is a firm's accrual earnings management (AEM) calculated using the performance-adjusted modified Jones model. The dependent variable in column 2 is AEM that is calculated using the modified Jones model. The dependent variable in column 3 is the rank of the firm's AEM (modified Jones). The dependent variables in columns 4-5 are a firm's real earnings management (REM) and the rank of the firm's REM, respectively. In both panels, the same set of baseline control variables are included as in Table \ref{tab: table4}. Refer to Appendices A to C for detailed variable definitions and measurements. A description of all variables can be found in Table \ref{tab: variabledescriptions}. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm and year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

**# Table D1
*======== Correlation Table ==============================

global summ_vars dacck dac rem size bm roa lev firm_age rank au_years loss salesgrowth lit InstOwn_Perc stockreturn sale_sd oa_scale hhi_sale cover 

*ssc install corrtex
corrtex $summ_vars, file(CorrTable) replace land sig /*dig(4) star(0.05)*/


**# Table OA1
	eststo clear
eststo regression1: reghdfe rem visib $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression2: reghdfe rem visib $control_variables_rem  temp, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression3: reghdfe rem visib $control_variables_rem  dewp, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression4: reghdfe rem visib $control_variables_rem slp, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression5: reghdfe rem visib $control_variables_rem wdsp, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression6: reghdfe rem visib $control_variables_rem mxspd , absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression7: reghdfe rem visib $control_variables_rem min, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression8: reghdfe rem visib $control_variables_rem rain, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression9: reghdfe rem visib $control_variables_rem temp dewp slp wdsp mxspd min rain, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

esttab regression1 regression2 regression3 regression4  regression5 regression6 regression7 regression8 regression9 using "$output\table7.tex", replace  drop($control_variables_rem) ///
nomtitles collabels(none) booktabs label scalar(ymean) stats(firmcont yearfe indfe N ymean ar2, fmt(0 0 0 0 2 2) labels("Baseline Controls"  "Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{Controlling for Additional Measures of Unpleasant Weather}\label{tab: table7}\tabcolsep=0.1cm\scalebox{0.65}{\begin{tabular}{lcccccccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table reports the effects of visibility on the aggregate measure of real earnings management (REM) with a series of additional weather control variables from NOAA. Column 1 is the baseline regression with no other weather controls. Column 2 includes the mean temperature reported by the firm's nearest station over the one-year period. Column 3 includes the mean dew point reported by the firm's nearest station over the one-year period. Column 4 includes the mean sea level pressure reported by the firm's nearest station over the one-year period. Column 5 includes the mean wind speed reported by the firm's nearest station over the one-year period. Column 6 includes the maximum wind speed reported by the firm's nearest station over the one-year period. Column 7 includes the minimum temprature reported by the firm's nearest station over the one-year period. Column 8 includes the mean rain occurrence reported by the firm's nearest station over the one-year period. Column 9 includes all the above-mentioned weather controls. Baseline controls are the same as in Table \ref{tab: table4}. A description of all variables can be found in Table \ref{tab: variabledescriptions}. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm-year. *** p < 1\%, ** p < 5\%, * p < 10\% }\end{table}")

**# Table 10: PSM (last)
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

	capture drop visib_median
	capture drop visib_binary
	capture drop visib_binary_neg
egen visib_median = median(visib)
gen visib_binary = (visib < visib_median) if !mi(visib)
gen visib_binary_neg = -visib_binary

global control_variables_psm size bm roa lev firm_age rank au_years hhi_sale oa_scale

*set seed 12345678
*psmatch2 visib_binary $control_variables, outcome(rem) noreplacement ties radius caliper(0.00001)
psmatch2 visib_binary $control_variables_psm, outcome(rem) ai(3) ///
                     caliper(0.03) noreplacement descending common odds index logit ties ///
                     warnings quietly ate


psgraph
pstest $control_variables_psm

eststo treatall: estpost sum $control_variables_psm if visib < visib_median
eststo controlall: estpost sum $control_variables_psm if visib >= visib_median
eststo diffall: estpost ttest $control_variables_psm, by(visib_binary_neg) 
eststo treatpsm: estpost sum $control_variables_psm if visib < visib_median & _support == 1
eststo controlpsm: estpost sum $control_variables_psm if visib >= visib_median  & _support == 1
eststo diffpsm: estpost ttest $control_variables_psm if _support == 1, by(visib_binary_neg) 

esttab treatall controlall diffall treatpsm controlpsm diffpsm using "$output\ttest_psm1.tex", ///
replace cells("mean(pattern(1 1 0 1 1 0)  fmt(3)) b(star pattern(0 0 1 0 0 1) fmt(3)) ") ///
mgroups("Pooled Sample" "PSM Sample", pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
label mtitles("More Polluted" "Less Polluted" "Difference" "More Polluted" "Less Polluted" "Difference") collabels(none) nonumbers booktabs ///
prehead("\begin{table}\begin{center}\caption{Propensity Score Matching Sample}\label{tab: ttestpsm}\tabcolsep=0.1cm\scalebox{0.47}{\begin{tabular}{lcccccc}\toprule") starlevels(* 0.2 ** 0.1 *** 0.02) ///
posthead("\midrule \multicolumn{7}{c}{\textbf{Panel A: Descriptive Statistics for the Sample before and after PSM}}\\") ///
postfoot("\end{tabular}}") 

sum _support
keep if _support == 1 //10846

label var fog "Fog"
*======== Table 4: Regression (Signed) =============================
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

esttab regression1 regression2 regression3 regression4 regression5 using "$output\ttest_psm2.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
mtitles("\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jones)}" "AEM Rank" "REM" "REM Rank") collabels(none) booktabs label scalar(ymean) starlevels(* 0.2 ** 0.1 *** 0.02) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{Propensity Score Matching Sample}\label{tab: ttestpsm}\tabcolsep=0.1cm\scalebox{0.6}{\begin{tabular}{lcccccc}\toprule") posthead("\midrule") ///
postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: The analysis is conducted among the obtained sample after PSM. The dependent variables are indicated at the top of each column. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variables in columns 1-3 are: a firm's accrual earnings management (AEM) calculated using the performance-adjusted model, a firm's AEM calculated using the modified Jones model, and the rank of the firm's AEM (modified Jones), respectively. The dependent variables in columns 4-5 are: a firm's real earnings management (REM), and the rank of the firm's REM, respectively. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm and year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

**# Table OA2-OA4
use "$output\convk.dta", replace
keep fyear lpermno dacck
tempfile convk
save `convk', replace

use "$maindir\Analysis Future 3 months\Firm_Year_Weather", replace

duplicates drop tic fyear, force
duplicates drop cusip8 fyear, force
	capture drop _merge
merge 1:1 lpermno fyear using "$maindir\sale_sd.dta"
keep if _merge == 1 | _merge == 3

	capture drop _merge
merge 1:1 tic fyear using "$output\board_characteristics", force
	keep if _merge == 1 | _merge == 3
	capture drop _merge
merge 1:1 cusip8 fyear using "$output\institutional_ownership_x.dta", force
	keep if _merge == 1 | _merge == 3

label var loss "Loss"
label var salesgrowth "Sales Growth"
label var InstOwn_Perc "INST\%"
label var stockreturn "RET"
label var sale_sd "StdSales"
label var sale "Sales"
label var cover "ANAL"

destring sic, replace
gen lit = 1 if (sic >= 2833 & sic <= 2836) | (sic >= 3570 & sic <= 3577) | (sic >= 3600 & sic <=3674) | (sic >= 5200 & sic <= 5961) | (sic >= 7370 & sic <= 7379) | (sic >= 8731 & sic <= 8734)
replace lit = 0 if mi(lit) & !mi(sic)

label var lit "Litigious"
replace InstOwn_Perc = 0 if mi(InstOwn_Perc)

capture drop _merge
merge m:1 state city fyear using "$maindir\US_PM25_weightedannualmean.dta"
keep if _m == 3 //3583 observations, or 762 state-city-fyears
label var pollutant_value "PM 2.5 (Weighted Annual Mean)"

xtset lpermno fyear

/*Cleaning*/

* Drop observations with duplicate lpermco-fyear
bysort lpermco fyear: gen dup = _n
bysort lpermco fyear: egen dup2 = max(dup)
drop if dup2 > 1 //87

	capture drop _merge
merge 1:1 lpermno fyear using `convk'	
keep if _merge == 1 | _merge == 3
drop _merge

 capture ssc install sicff
* generate 48 industries based on the 4-digit sic code: sic
destring sic, replace
sicff sic, ind(48)

replace sale = . if sale <0
hhi5 sale, by(ff_48 fyear) //hhi_sale
label var hhi_sale "HHI index"		

label var dacck "AEM (performance-adjusted)"


* Firm age
	preserve
	clear
	use "$maindir\Firm age\firm age", replace
	keep found_yr cusip fyear firm_age
	rename firm_age firm_age_old
	tempfile firm_age
	save `firm_age', replace
	restore
	
	capture drop _merge
merge 1:1 cusip fyear using `firm_age', gen(_merge)
	drop if _merge == 2
	drop _merge
	
	gen cyear = year(apdedate)
	gen firm_age = cyear - found_yr

* Big Eight Auditor
	capture drop rank
destring au, replace
gen rank = (au >=1 & au <= 8) if !mi(au)

* Tenure / Same auditor years
sort lpermno fyear
bysort lpermno au: gen au_years = _n if !mi(au) //number of years firm has been audited by the same auditor
*bysort lpermno: gen num_years = _N //number of years with data per firm

* oa
gen oa = ceq- che -dlc- dltt // shareholders' equity - cash and marketale securities + total debt
xtset lpermno fyear
gen lsale = l1.sale
gen loa = l1.oa
gen oa_scale = loa/lsale

* ============ Labeling =================
label var firm_ID "firm-year ID"
label var firm_FID "firm FID = firm_ID - 1"
label var dac "AEM (modified Jones)"
label var absdac "|AEM|" 
label var rank_dac "AEM Rank"
label var rem "REM"
label var absrem "{REM}"
label var rank_rem "REM Rank"
label var stdz_rem "REM Variability"
label var size "Size"
label var bm "BM"
label var roa "ROA"
label var lev "Leverage"
label var oa_scale "NOA"
label var au_years "Auditor Tenure"
label var firm_age "Firm Age"
label var rank "Big N" //binary
label var visib "Visibility"
label var cover "ANAL"

* sales  
label var rank_d_cfo "Rank($REM_{CFO}$)"
label var d_cfo "$REM_{CFO}$"

gen d_cfo_neg = - d_cfo
gen rank_d_cfo_neg = 9- rank_d_cfo

label var d_cfo_neg "$REM_{CFO}$"
label var rank_d_cfo_neg " Rank($REM_{CFO}$)"

* over-production
 label var d_prod "$REM_{PROD}$"
 label var rank_d_prod "Rank($REM_{PROD}$)"

* expenditure
 label var d_discexp "$REM_{DISX}$"
 label var rank_d_discexp " Rank($REM_{DISX}$)"

gen d_discexp_neg = -d_discexp
gen rank_d_discexp_neg = 9-rank_d_discexp

 label var d_discexp_neg "$REM_{DISX}$"
 label var rank_d_discexp_neg "Rank($REM_{DISX}$)"

* 1) Table OA2: Firm characteristics using actual period end date and three-month exposure

eststo summ_stats: estpost sum $summ_vars

eststo obs: estpost summarize $summ_vars

ereturn list 

eststo Mean: estpost summarize $summ_vars

ereturn list 

eststo p25: estpost summarize $summ_vars, detail

ereturn list 

eststo p50: estpost summarize $summ_vars, detail

ereturn list 

eststo p75: estpost summarize $summ_vars, detail

ereturn list 

eststo std: estpost summarize $summ_vars

ereturn list 

eststo Median: estpost summarize $summ_vars

ereturn list 

* .tex
esttab obs Mean std p25 p50 p75 using "$output\summ_stats_firm_8294.tex", fragment  ///
label cells("count(pattern(1 0 0 0 0 0)) mean(pattern(0 1 0 0 0 0) fmt(3)) sd(pattern(0 0 1 0 0 0) fmt(3)) p25(pattern(0 0 0 1 0 0) fmt(3)) p50(pattern(0 0 0 0 1 0) fmt(3)) p75(pattern(0 0 0 0 0 1) fmt(3))") noobs  ///
nonumbers replace booktabs collabels(none) mtitles("N" "Mean" "Std. Dev." "Bottom 25\%" "Median" "Top 25\%") ///
prehead("\begin{table}\begin{center}\caption{Summary Statistics of Firm Characteristics (three months after fiscal year-end)}\label{tab: summstats18294}\tabcolsep=0.1cm\scalebox{0.67}{\begin{tabular}{lcccccc}\toprule")  ///
postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table reports the descriptive statistics of firm-level characteristics for 8,294 firm-year observations from 2003 to 2017. Firm characteristics are obtained from Compustat and I/B/E/S databases. We restrict the sample to be within three months after the actual period end date of each firm's financial report. Refer to Appendices A to C for detailed variable definitions and measurements. Descriptions of each variable can be found in Table \ref{tab: variabledescriptions}.}\end{table}")  

* 2) Table OA3: Weather characteristics using actual period end date and three-month exposure
label var temp "Temp."
label var dewp "Dew" 
label var slp  "Sea-level Pressure"
label var visib "Visibility"
label var wdsp  "Wind"
label var mxspd  "Max Wind"
label var min  "Min Temp."
label var fog  "Fog"
label var rain  "Rain"
label var thunder  "Thunder"
label var gust  "Gust"
label var max  "Max Temp"
label var prcp  "Total Precip."
label var sndp  "Snow Depth"
label var snow  "Snow"
label var hail  "Hail"
label var tornado "Tornado"

replace prcp =. if prcp > 99
global summ_vars_weather temp dewp slp visib wdsp ///
				 gust mxspd prcp sndp max min fog rain snow   ///
				  hail thunder tornado
* Summary statistics continued
	eststo clear
eststo summ_stats: estpost sum $summ_vars_weather

eststo obs: estpost summarize $summ_vars_weather

ereturn list 

eststo Mean: estpost summarize $summ_vars_weather

ereturn list 

eststo p25: estpost summarize $summ_vars_weather, detail

ereturn list 

eststo p50: estpost summarize $summ_vars_weather, detail

ereturn list 

eststo p75: estpost summarize $summ_vars_weather, detail

ereturn list 

eststo std: estpost summarize $summ_vars_weather

ereturn list 

eststo Median: estpost summarize $summ_vars_weather

ereturn list 

* .tex
esttab obs Mean std p25 p50 p75 using "$output\summ_stats_weather_8294.tex", fragment  ///
label cells("count(pattern(1 0 0 0 0 0)) mean(pattern(0 1 0 0 0 0) fmt(3)) sd(pattern(0 0 1 0 0 0) fmt(3)) p25(pattern(0 0 0 1 0 0) fmt(3)) p50(pattern(0 0 0 0 1 0) fmt(3)) p75(pattern(0 0 0 0 0 1) fmt(3))") noobs  ///
nonumbers replace booktabs collabels(none) mtitles("N" "Mean" "Std. Dev." "Bottom 25\%" "Median" "Top 25\%") ///
prehead("\begin{table}\begin{center}\caption{Summary Statistics of Weather-Related Characteristics (three months after fiscal year-end)}\label{tab: summstats28294}\tabcolsep=0.1cm\scalebox{0.67}{\begin{tabular}{lcccccc}\toprule")  ///
postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table reports the descriptive statistics of weather-related characteristics for 8,294 firm-year observations from 2003 to 2017. Details of each weather-related variable, including the definition, unit, can be found in Table \ref{tab: variabledescriptions2}.}\end{table}") 

* 3) Table OA4: The Effect of Visibility on Earnings Management (actual period end date and three-month exposure)
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

esttab regression1 regression2 regression3 using "$output\table4_8294.tex", replace ///
mtitles("\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jones')}" "\makecell{AEM \\ Rank}") collabels(none) booktabs label scalar(ymean) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on AEM (three months after fiscal year-end)}\label{tab: table48294}\tabcolsep=0.1cm\scalebox{0.9}{\begin{tabular}{lccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: The dependent variables are indicated at the top of each column. Visibility refers to the visibility that is recorded by the firm's closest NOAA weather station during the three months after each firm's actual period end date. The dependent variables in columns 1-3 are: a firm's accrual earnings management calculated using the performance-adjusted model, a firm's accrual earnings management calculated using the modified Jones model, and the rank of the firm's accrual earnings management (modified Jones), respectively. A description of all variables can be found in Table \ref{tab: variabledescriptions}. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm-year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

**# Table OA5-OA7
*======================== One-year Exposure =============================
use "$output\convk.dta", replace
keep fyear lpermno dacck
tempfile convk
save `convk', replace

use "$output\OLD DOCUMENTS\final_data_11283.dta", replace

hhi5 sale, by(ff_48 fyear) //hhi_sale
label var hhi_sale "HHI index"		

	capture drop _merge
merge 1:1 lpermno fyear using `convk'	

label var dacck "AEM (performance-adjusted)"

keep if _merge == 1 | _merge == 3
drop _merge

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

	capture drop pollutant_value
	capture drop _merge
merge m:1 state city fyear using "$maindir\US_PM25_weightedannualmean.dta"
keep if _m == 1 | _merge == 3 //3583 observations, or 762 state-city-fyears
label var pollutant_value "PM 2.5 (Weighted Annual Mean)"


* 4) Table OA5: Firm characteristics using actual period end date and one-year exposure
eststo summ_stats: estpost sum $summ_vars

eststo obs: estpost summarize $summ_vars

ereturn list 

eststo Mean: estpost summarize $summ_vars

ereturn list 

eststo p25: estpost summarize $summ_vars, detail

ereturn list 

eststo p50: estpost summarize $summ_vars, detail

ereturn list 

eststo p75: estpost summarize $summ_vars, detail

ereturn list 

eststo std: estpost summarize $summ_vars

ereturn list 

eststo Median: estpost summarize $summ_vars

ereturn list 

* .tex
esttab obs Mean std p25 p50 p75 using "$output\summ_stats_firm_11283.tex", fragment  ///
label cells("count(pattern(1 0 0 0 0 0)) mean(pattern(0 1 0 0 0 0) fmt(3)) sd(pattern(0 0 1 0 0 0) fmt(3)) p25(pattern(0 0 0 1 0 0) fmt(3)) p50(pattern(0 0 0 0 1 0) fmt(3)) p75(pattern(0 0 0 0 0 1) fmt(3))") noobs  ///
nonumbers replace booktabs collabels(none) mtitles("N" "Mean" "Std. Dev." "Bottom 25\%" "Median" "Top 25\%") ///
prehead("\begin{table}\begin{center}\caption{Summary Statistics of Firm Characteristics (one year before actual end date)}\label{tab: summstats111283}\tabcolsep=0.1cm\scalebox{0.67}{\begin{tabular}{lcccccc}\toprule")  ///
postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table reports the descriptive statistics of firm-level characteristics for 11,283 firm-year observations from 2003 to 2017. Firm characteristics are obtained from Compustat and I/B/E/S databases. We restrict the sample to be within a year before the actual period end date of each firm's financial report. Refer to Appendices A to C for detailed variable definitions and measurements. Descriptions of each variable can be found in Table \ref{tab: variabledescriptions}.}\end{table}") 

* 5) Table OA6: Weather characteristics using actual period end date and one-year exposure
label var temp "Temp."
label var dewp "Dew" 
label var slp  "Sea-level Pressure"
label var visib "Visibility"
label var wdsp  "Wind"
label var mxspd  "Max Wind"
label var min  "Min Temp."
label var fog  "Fog"
label var rain  "Rain"
label var thunder  "Thunder"
label var gust  "Gust"
label var max  "Max Temp"
label var prcp  "Total Precip."
label var sndp  "Snow Depth"
label var snow  "Snow"
label var hail  "Hail"
label var tornado "Tornado"

replace prcp = . if prcp >90
global summ_vars_weather temp dewp slp visib wdsp ///
				 gust mxspd prcp sndp max min fog rain snow   ///
				  hail thunder tornado
* Summary statistics continued
	eststo clear
eststo summ_stats: estpost sum $summ_vars_weather

eststo obs: estpost summarize $summ_vars_weather

ereturn list 

eststo Mean: estpost summarize $summ_vars_weather

ereturn list 

eststo p25: estpost summarize $summ_vars_weather, detail

ereturn list 

eststo p50: estpost summarize $summ_vars_weather, detail

ereturn list 

eststo p75: estpost summarize $summ_vars_weather, detail

ereturn list 

eststo std: estpost summarize $summ_vars_weather

ereturn list 

eststo Median: estpost summarize $summ_vars_weather

ereturn list 

* .tex
esttab obs Mean std p25 p50 p75 using "$output\summ_stats_weather_11283.tex", fragment  ///
label cells("count(pattern(1 0 0 0 0 0)) mean(pattern(0 1 0 0 0 0) fmt(3)) sd(pattern(0 0 1 0 0 0) fmt(3)) p25(pattern(0 0 0 1 0 0) fmt(3)) p50(pattern(0 0 0 0 1 0) fmt(3)) p75(pattern(0 0 0 0 0 1) fmt(3))") noobs  ///
nonumbers replace booktabs collabels(none) mtitles("N" "Mean" "Std. Dev." "Bottom 25\%" "Median" "Top 25\%") ///
prehead("\begin{table}\begin{center}\caption{Summary Statistics of Weather-Related Characteristics (one year before actual end date)}\label{tab: summstats211283}\tabcolsep=0.1cm\scalebox{0.67}{\begin{tabular}{lcccccc}\toprule")  ///
postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table reports the descriptive statistics of weather-related characteristics for 11,283 firm-year observations from 2003 to 2017. Details of each weather-related variable, including the definition, unit, can be found in Table \ref{tab: variabledescriptions2}.}\end{table}") 

* 6) Table OA7: The Effect of Visibility on Earnings Management (actual period end date and one-year exposure)
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

esttab regression1 regression2 regression3 regression4 regression5 using "$output\table4_11283.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
mtitles("\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jones')}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") collabels(none) booktabs label scalar(ymean) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management (one year before actual end date)}\label{tab: table411283}\tabcolsep=0.1cm\scalebox{0.57}{\begin{tabular}{lccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: The dependent variables are indicated at the top of each column. Visibility refers to the visibility that is recorded by the firm's closest NOAA weather station during the year prior to each firm's actual period end date. The dependent variables in columns 1-3 are: a firm's accrual earnings management calculated using the performance-adjusted model, a firm's accrual earnings management calculated using the modified Jones model, and the rank of the firm's accrual earnings management (modified Jones), respectively. The dependent variables in columns 4-5 are: a firm's real earnings management and the rank of the firm's real earnings management, respectively. A description of all variables can be found in Table \ref{tab: variabledescriptions}. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm-year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

**# Table OA8-OA10
* Three months prior to each firm's fiscal year end
use "$output\convk.dta", replace
keep fyear lpermno dacck
tempfile convk
save `convk', replace

use "$output\OLD DOCUMENTS\final_data_10883.dta", replace

duplicates drop tic fyear, force
duplicates drop cusip8 fyear, force
	capture drop _merge
merge 1:1 lpermno fyear using "$maindir\sale_sd.dta"
keep if _merge == 1 | _merge == 3

	capture drop _merge
merge 1:1 tic fyear using "$output\board_characteristics", force
	keep if _merge == 1 | _merge == 3
	capture drop _merge
merge 1:1 cusip8 fyear using "$output\institutional_ownership_x.dta", force
	keep if _merge == 1 | _merge == 3

label var loss "Loss"
label var salesgrowth "Sales Growth"
label var InstOwn_Perc "INST\%"
label var stockreturn "RET"
label var sale_sd "StdSales"
label var sale "Sales"
label var cover "ANAL"
label var rank "Big N"

destring sic, replace
gen lit = 1 if (sic >= 2833 & sic <= 2836) | (sic >= 3570 & sic <= 3577) | (sic >= 3600 & sic <=3674) | (sic >= 5200 & sic <= 5961) | (sic >= 7370 & sic <= 7379) | (sic >= 8731 & sic <= 8734)
replace lit = 0 if mi(lit) & !mi(sic)

label var lit "Litigious"
replace InstOwn_Perc = 0 if mi(InstOwn_Perc)

capture drop _merge
merge m:1 state city fyear using "$maindir\US_PM25_weightedannualmean.dta"
keep if _m==1 | _m == 3 //3583 observations, or 762 state-city-fyears
label var pollutant_value "PM 2.5 (Weighted Annual Mean)"

xtset lpermno fyear

/*Cleaning*/

/* Drop observations with duplicate lpermco-fyear
	capture drop dup
	capture drop dup2
bysort lpermco fyear: gen dup = _n
bysort lpermco fyear: egen dup2 = max(dup)
drop if dup2 > 1 //87
*/
hhi5 sale, by(ff_48 fyear) //hhi_sale
label var hhi_sale "HHI index"		

	capture drop _merge
merge 1:1 lpermno fyear using `convk'	

label var dacck "AEM (performance-adjusted)"

keep if _merge == 1 | _merge == 3
drop _merge

* 1) Table OA8: Firm characteristics using actual period end date and three-month exposure

eststo summ_stats: estpost sum $summ_vars

eststo obs: estpost summarize $summ_vars

ereturn list 

eststo Mean: estpost summarize $summ_vars

ereturn list 

eststo p25: estpost summarize $summ_vars, detail

ereturn list 

eststo p50: estpost summarize $summ_vars, detail

ereturn list 

eststo p75: estpost summarize $summ_vars, detail

ereturn list 

eststo std: estpost summarize $summ_vars

ereturn list 

eststo Median: estpost summarize $summ_vars

ereturn list 

* .tex
esttab obs Mean std p25 p50 p75 using "$output\summ_stats_firm_10883.tex", fragment  ///
label cells("count(pattern(1 0 0 0 0 0)) mean(pattern(0 1 0 0 0 0) fmt(3)) sd(pattern(0 0 1 0 0 0) fmt(3)) p25(pattern(0 0 0 1 0 0) fmt(3)) p50(pattern(0 0 0 0 1 0) fmt(3)) p75(pattern(0 0 0 0 0 1) fmt(3))") noobs  ///
nonumbers replace booktabs collabels(none) mtitles("N" "Mean" "Std. Dev." "Bottom 25\%" "Median" "Top 25\%") ///
prehead("\begin{table}\begin{center}\caption{Summary Statistics of Firm Characteristics (three months before actual period end date)}\label{tab: summstats110883}\tabcolsep=0.1cm\scalebox{0.67}{\begin{tabular}{lcccccc}\toprule")  ///
postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table reports the descriptive statistics of firm-level characteristics for 10,883 firm-year observations from 2003 to 2017. Firm characteristics are obtained from Compustat and I/B/E/S data. We restrict the sample to be within three months before the actual period end date of each firm's financial report. Refer to Appendices A to C for detailed variable definitions and measurements. Descriptions of each variable can be found in Table \ref{tab: variabledescriptions}. }\end{table}")  

* 2) Table OA9: Weather characteristics using actual period end date and three-month exposure
label var temp "Temp."
label var dewp "Dew" 
label var slp  "Sea-level Pressure"
label var visib "Visibility"
label var wdsp  "Wind"
label var mxspd  "Max Wind"
label var min  "Min Temp."
label var fog  "Fog"
label var rain  "Rain"
label var thunder  "Thunder"
label var gust  "Gust"
label var max  "Max Temp"
label var prcp  "Total Precip."
label var sndp  "Snow Depth"
label var snow  "Snow"
label var hail  "Hail"
label var tornado "Tornado"

replace prcp = . if prcp > 99
global summ_vars_weather temp dewp slp visib wdsp ///
				 gust mxspd prcp sndp max min fog rain snow   ///
				  hail thunder tornado
* Summary statistics continued
	eststo clear
eststo summ_stats: estpost sum $summ_vars_weather

eststo obs: estpost summarize $summ_vars_weather

ereturn list 

eststo Mean: estpost summarize $summ_vars_weather

ereturn list 

eststo p25: estpost summarize $summ_vars_weather, detail

ereturn list 

eststo p50: estpost summarize $summ_vars_weather, detail

ereturn list 

eststo p75: estpost summarize $summ_vars_weather, detail

ereturn list 

eststo std: estpost summarize $summ_vars_weather

ereturn list 

eststo Median: estpost summarize $summ_vars_weather

ereturn list 

* .tex
esttab obs Mean std p25 p50 p75 using "$output\summ_stats_weather_10883.tex", fragment  ///
label cells("count(pattern(1 0 0 0 0 0)) mean(pattern(0 1 0 0 0 0) fmt(3)) sd(pattern(0 0 1 0 0 0) fmt(3)) p25(pattern(0 0 0 1 0 0) fmt(3)) p50(pattern(0 0 0 0 1 0) fmt(3)) p75(pattern(0 0 0 0 0 1) fmt(3))") noobs  ///
nonumbers replace booktabs collabels(none) mtitles("N" "Mean" "Std. Dev." "Bottom 25\%" "Median" "Top 25\%") ///
prehead("\begin{table}\begin{center}\caption{Summary Statistics of Weather-Related Characteristics (three months before actual period end date)}\label{tab: summstats210883}\tabcolsep=0.1cm\scalebox{0.67}{\begin{tabular}{lcccccc}\toprule")  ///
postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table reports the descriptive statistics of weather-related characteristics for 10,883 firm-year observations in the three months prior to each firm's actual period end date ranging from 2003 to 2017. Details of each weather-related variable, including the definition, unit, can be found in Table \ref{tab: variabledescriptions2}.}\end{table}") 

* 3) Table OA10: The Effect of Visibility on Earnings Management (actual period end date and three-month exposure)
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

esttab regression1 regression2 regression3 regression4 regression5 using "$output\table4_10883.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
mtitles("\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jones')}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") collabels(none) booktabs label scalar(ymean) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management (three months before actual period end date)}\label{tab: table410883}\tabcolsep=0.1cm\scalebox{0.57}{\begin{tabular}{lccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: The dependent variables are indicated at the top of each column. Visibility refers to the visibility that is recorded by the firm's closest NOAA weather station during the three months prior to each firm's actual period end date. The dependent variables in columns 1-3 are: a firm's accrual earnings management calculated using the performance-adjusted model, a firm's accrual earnings management calculated using the modified Jones model, and the rank of the firm's accrual earnings management (modified Jones), respectively. The dependent variables in columns (4)-(5) are: a firm's real earnings management and the rank of the firm's real earnings management, respectively. A description of all variables can be found in Table \ref{tab: variabledescriptions}. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm-year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 
