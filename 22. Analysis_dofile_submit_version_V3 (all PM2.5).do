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
	label var gparachute "Golden Parachute"
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

global control_variables_aem size bm roa lev firm_age rank au_years loss salesgrowth lit InstOwn_Perc stockreturn sale_sd oa_scale rem

global control_variables_rem size bm roa lev firm_age rank au_years loss salesgrowth lit InstOwn_Perc stockreturn sale_sd hhi_sale dac

global control_variables size bm roa lev firm_age /*rank au_years oa_scale*/ hhi_sale loss salesgrowth /*lit*/ InstOwn_Perc /*sale_sd*/ 

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
esttab obs Mean std p25 p50 p75 using "$output\summ_stats_firm_PM25.tex", fragment  ///
label cells("count(pattern(1 0 0 0 0 0)) mean(pattern(0 1 0 0 0 0) fmt(3)) sd(pattern(0 0 1 0 0 0) fmt(3)) p25(pattern(0 0 0 1 0 0) fmt(3)) p50(pattern(0 0 0 0 1 0) fmt(3)) p75(pattern(0 0 0 0 0 1) fmt(3))") noobs  ///
nonumbers replace booktabs collabels(none) mtitles("N" "Mean" "Std. Dev." "Bottom 25\%" "Median" "Top 25\%") ///
prehead("\begin{table}\begin{center}\caption{Summary Statistics of Firm Characteristics}\label{tab: summstats1}\tabcolsep=0.1cm\scalebox{0.8}{\begin{tabular}{lcccccc}\toprule")  ///
postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table presents the descriptive statistics for the firm-level variables used in our main analyses. See Appendix A for detailed variable definitions and measurement.}\end{table}")

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
				  
* Summary statistics of weather variables at the station-year level (Panel A)
	capture drop _merge
merge 1:m lpermno fyear using "E:\21. Air Pollution and Accounting\DATA\Analysis_102148 observations\firm_year_stations_48332"
	keep if _merge == 3
	drop _merge
	capture drop dup
bysort lpermno fyear (station): gen dup = _n
	drop if dup == 2

bysort station fyear (lpermno): gen number = _n
preserve
	keep if number == 1 //4089
	eststo clear
eststo summ_stats: estpost sum $summ_vars_weather pollutant_value

eststo obs: estpost summarize $summ_vars_weather pollutant_value

ereturn list 

eststo Mean: estpost summarize $summ_vars_weather pollutant_value

ereturn list 

eststo p25: estpost summarize $summ_vars_weather pollutant_value, detail

ereturn list 

eststo p50: estpost summarize $summ_vars_weather pollutant_value, detail

ereturn list 

eststo p75: estpost summarize $summ_vars_weather pollutant_value, detail

ereturn list 

eststo std: estpost summarize $summ_vars_weather pollutant_value 

ereturn list 

eststo Median: estpost summarize $summ_vars_weather pollutant_value

ereturn list 

* .tex
esttab obs Mean std p25 p50 p75 using "$output\summ_stats_weather_PM25.tex", fragment  ///
label cells("count(pattern(1 0 0 0 0 0)) mean(pattern(0 1 0 0 0 0) fmt(3)) sd(pattern(0 0 1 0 0 0) fmt(3)) p25(pattern(0 0 0 1 0 0) fmt(3)) p50(pattern(0 0 0 0 1 0) fmt(3)) p75(pattern(0 0 0 0 0 1) fmt(3))") noobs  ///
prehead("\begin{table}\begin{center}\caption{Summary Statistics of Weather-Related Characteristics}\label{tab: summ_stats_weather}\tabcolsep=0.1cm\scalebox{0.65}{\begin{tabular}{lcccccc}\toprule")  ///
nonumbers replace booktabs collabels(none) mtitles("N" "Mean" "Std. Dev." "Bottom 25\%" "Median" "Top 25\%") ///
posthead("\midrule \textbf{Panel A: Weather Station-Year Level}\\") ///
postfoot("\midrule")
restore

* Summary statistics of weather variables at the firm-year level (Panel B)
	eststo clear
eststo summ_stats: estpost sum $summ_vars_weather pollutant_value

eststo obs: estpost summarize $summ_vars_weather pollutant_value

ereturn list 

eststo Mean: estpost summarize $summ_vars_weather pollutant_value

ereturn list 

eststo p25: estpost summarize $summ_vars_weather pollutant_value, detail

ereturn list 

eststo p50: estpost summarize $summ_vars_weather pollutant_value, detail

ereturn list 

eststo p75: estpost summarize $summ_vars_weather pollutant_value, detail

ereturn list 

eststo std: estpost summarize $summ_vars_weather pollutant_value

ereturn list 

eststo Median: estpost summarize $summ_vars_weather pollutant_value

ereturn list 

* .tex
esttab obs Mean std p25 p50 p75 using "$output\summ_stats_weather_PM25.tex", fragment  ///
label cells("count(pattern(1 0 0 0 0 0)) mean(pattern(0 1 0 0 0 0) fmt(3)) sd(pattern(0 0 1 0 0 0) fmt(3)) p25(pattern(0 0 0 1 0 0) fmt(3)) p50(pattern(0 0 0 0 1 0) fmt(3)) p75(pattern(0 0 0 0 0 1) fmt(3))") noobs  ///
nonumbers append booktabs collabels(none) mtitles("N" "Mean" "Std. Dev." "Bottom 25\%" "Median" "Top 25\%") ///
posthead("\midrule \textbf{Panel B: Firm-Year Level} \\") ///
postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table presents the descriptive statistics for the various weather variables used in our analyses. See Appendix B for detailed variable descriptions.}\end{table}") 

**# Table 4
global summ_vars dacck dac rank_dac rem rank_rem d_cfo_neg rank_d_cfo_neg d_prod rank_d_prod ///
d_discexp_neg rank_d_discexp_neg size bm roa lev firm_age rank au_years loss sale salesgrowth lit InstOwn_Perc   stockreturn sale_sd oa_scale hhi_sale cover pollutant_value

*========= t-test table ========================
summarize pollutant_value if !mi(pollutant_value), d
local pollutant_value_median = r(p50) 
gen polluted = (pollutant_value > `pollutant_value_median') if !mi(pollutant_value)

eststo allsample: estpost summarize $summ_vars if !mi(pollutant_value)

eststo polluted_sample: estpost summarize $summ_vars if polluted == 1

eststo unpolluted_sample: estpost summarize $summ_vars if polluted == 0

gen unpolluted = -polluted
eststo difference:  estpost ttest $summ_vars, by(unpolluted)

esttab allsample polluted_sample unpolluted_sample difference using "$output\ttest_PM25.tex", ///
replace cells("mean(pattern(1 1 1 0)  fmt(3)) b(star pattern(0 0 0 1) fmt(3)) ") ///
label mtitles("All" "Polluted" "Unpolluted" "Polluted-Unpolluted") collabels(none) nonumbers booktabs ///
prehead("\begin{table}\begin{center}\caption{Univariate Test}\label{tab: ttest}\tabcolsep=0.1cm\begin{tabular}{lcccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}\end{center}\footnotesize{Notes: This table presents the univariate test results about the difference of various firm characteristics between the firms located in high vs. low air pollution areas. We test the significance of the difference using the t-test. See Appendix A for detailed variable definitions. ***, **, and * indicate statistical significance at the 1\%, 5\%, and 10\% levels, respectively.}\end{table}") 

**# Table 5
label var dac "AEM"
label var pollutant_value "PM 2.5 (Weighted Annual Mean)"
*==================== Regression (Signed) =============================
	eststo clear
eststo regression1: reghdfe dacck pollutant_value $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
	
eststo regression2: reghdfe dac pollutant_value $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression3: reghdfe rank_dac pollutant_value $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression4: reghdfe rem pollutant_value $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression5: reghdfe rank_rem pollutant_value $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 using "$output\table4_PM25.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
mtitles("\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jones)}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") collabels(none) booktabs label scalar(ymean) ///
stats(yearfe indfe N ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Air Pollution on Earnings Management}\label{tab: table4}\tabcolsep=0.1cm\scalebox{0.6}{\begin{tabular}{lccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table presents the main regression results to test our hypotheses on the effect of the level of PM 2.5 on AEM and REM. See Appendix A for detailed variable definitions. Numbers in parentheses represent t-statistics calculated based on standard errors clustered at the industry-year level. ***, **, and * indicate statistical significance at the 1\%, 5\%, and 10\% levels, respectively.}\end{table}") 

**# Table 6
*======================= Decomposition of REM ========================
eststo sales1: reghdfe d_cfo_neg pollutant_value $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize d_cfo_neg
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo sales2: reghdfe rank_d_cfo_neg pollutant_value $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) 
estadd scalar ar2 = e(r2_a)
summarize rank_d_cfo_neg
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo overprod1: reghdfe d_prod pollutant_value $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize d_prod
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo overprod2: reghdfe rank_d_prod pollutant_value $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_d_prod
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo expenditure1: reghdfe d_discexp_neg pollutant_value $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize d_discexp_neg
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo expenditure2: reghdfe rank_d_discexp_neg pollutant_value $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_d_discexp_neg
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

esttab sales1 sales2 overprod1 overprod2 expenditure1 expenditure2 using "$output\table5_PM25.tex", replace ///
depvars collabels(none) booktabs label scalar(ymean) ///
stats(yearfe indfe N ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Air Pollution on Individual REM Measures}\label{tab: table5}\tabcolsep=0.1cm\scalebox{0.62}{\begin{tabular}{lcccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table presents the regression results to test the effect of the level of PM 2.5 on REM using three individual REM measures and their ranks. See Appendix A for detailed variable definitions. Numbers in parentheses represent t-statistics calculated based on standard errors clustered at the industry-year level. ***, **, and * indicate statistical significance at the 1\%, 5\%, and 10\% levels, respectively.}\end{table}") 

global control_variables_aem_t78 size bm roa lev firm_age rank au_years oa_scale /*xrd_int*/
global control_variables_rem_t78 size bm roa lev firm_age rank au_years hhi_sale /*xrd_int*/
**# Table 7
*================================== External Monitoring? Analyst ================================
	eststo clear
eststo regression1: reghdfe dacck pollutant_value cover c.pollutant_value#c.cover $control_variables_aem_t78, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace	

eststo regression2: reghdfe dac pollutant_value cover c.pollutant_value#c.cover $control_variables_aem_t78, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression3: reghdfe rank_dac pollutant_value cover c.pollutant_value#c.cover $control_variables_aem_t78, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression4: reghdfe rem pollutant_value cover c.pollutant_value#c.cover $control_variables_rem_t78, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression5: reghdfe rank_rem pollutant_value cover c.pollutant_value#c.cover $control_variables_rem_t78, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 using "$output\table8_PM25.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) drop($control_variables_rem_t78 $control_variables_aem_t78) ///
mtitles("\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jones)}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") collabels(none) booktabs label scalar(ymean) order(pollutant_value cover c.pollutant_value#c.cover) starlevels(* 0.2 ** 0.1 *** 0.02) ///
stats(firmcont yearfe indfe N ar2, fmt(0 0 0 0 2 2) labels("Baseline Controls" "Year FE" "Industry FE" "N" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Moderating Effect of Analyst Coverage on the Relation between Air Pollution and Earnings Management}\label{tab: table8}\tabcolsep=0.1cm\scalebox{0.82}{\begin{tabular}{lccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table presents the regression results to test the moderating effect of analyst following on the relation between the level of PM 2.5 and AEM/REM. See Appendix A for detailed variable definitions. Numbers in parentheses represent t-statistics calculated based on standard errors clustered at the industry-year level. ***, **, and * indicate statistical significance at the 1\%, 5\%, and 10\% levels, respectively.}\end{table}") 

**# Table 8
global control_variables_aem size bm roa lev firm_age rank au_years loss salesgrowth lit InstOwn_Perc stockreturn sale_sd oa_scale rem

global control_variables_rem size bm roa lev firm_age rank au_years loss salesgrowth lit InstOwn_Perc stockreturn sale_sd hhi_sale dac

global control_variables_aem_t78 size bm roa lev firm_age rank au_years oa_scale /*xrd_int*/
global control_variables_rem_t78 size bm roa lev firm_age rank au_years hhi_sale /*xrd_int*/

*========== Table 15: visibility interacts with internal monitoring to REM ======================== 
* Panel A
label var CGOV_str_num "CG Strengths"
label var CGOV_con_num "CG Concerns"
	eststo clear
eststo regression1: reghdfe dacck pollutant_value CGOV_str_num c.pollutant_value#c.CGOV_str_num $control_variables_aem_t78, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression2: reghdfe dacck pollutant_value CGOV_con_num c.pollutant_value#c.CGOV_con_num $control_variables_aem_t78, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace
	
eststo regression3: reghdfe dac pollutant_value CGOV_str_num c.pollutant_value#c.CGOV_str_num $control_variables_aem_t78, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression4: reghdfe dac pollutant_value CGOV_con_num c.pollutant_value#c.CGOV_con_num $control_variables_aem_t78, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression5: reghdfe rem pollutant_value CGOV_str_num c.pollutant_value#c.CGOV_str_num $control_variables_rem_t78, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression6: reghdfe rem pollutant_value CGOV_con_num c.pollutant_value#c.CGOV_con_num $control_variables_rem_t78, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 regression6 using "$output\table15_panelAB_PM25.tex", replace fragment ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) drop($control_variables_rem_t78 $control_variables_aem_t78) mtitles("\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jones)}" "\makecell{AEM \\ (modified Jones)}" "REM" "REM") collabels(none) booktabs label scalar(ymean) order(pollutant_value CGOV_str_num c.pollutant_value#c.CGOV_str_num CGOV_con_num c.pollutant_value#c.CGOV_con_num) starlevels(* 0.2 ** 0.1 *** 0.02) ///
stats(firmcont yearfe indfe N ar2, fmt(0 0 0 0 2 2) labels("Baseline Controls" "Year FE" "Industry FE" "N" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Mediating Effect of Corporate Governance on the Relation between Air Pollution and Earnings Management}\label{tab: table15}\tabcolsep=0.1cm\scalebox{0.65}{\begin{tabular}{lcccccc}\toprule") posthead("\midrule&\multicolumn{6}{c}{\textbf{Panel A: CG =  CG Strengths and Concerns}}\\")

* Panel B
label var boarddiversity "Female Board\%"
label var Boardindependence "Board Ind."
	eststo clear
eststo regression1: reghdfe dacck pollutant_value Boardindependence c.pollutant_value#c.Boardindependence $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) 
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace
	
eststo regression2: reghdfe dacck pollutant_value boarddiversity c.pollutant_value#c.boarddiversity $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression3: reghdfe dac pollutant_value Boardindependence c.pollutant_value#c.Boardindependence $control_variables_aem_t78, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) 
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression4: reghdfe dac pollutant_value boarddiversity c.pollutant_value#c.boarddiversity $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression5: reghdfe rem pollutant_value Boardindependence c.pollutant_value#c.Boardindependence $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression6: reghdfe rem pollutant_value boarddiversity c.pollutant_value#c.boarddiversity $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 regression6 using "$output\table15_panelAB_PM25.tex", append fragment ///
drop($control_variables_rem $control_variables_aem) ///
nomtitles nonumbers collabels(none) booktabs label order(pollutant_value Boardindependence c.pollutant_value#c.Boardindependence boarddiversity c.pollutant_value#c.boarddiversity) starlevels(* 0.2 ** 0.1 *** 0.02) ///
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
	
eststo regression1: reghdfe dacck pollutant_value gparachute c.pollutant_value#c.gparachute $control_variables_aem_t78, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression2: reghdfe dacck pollutant_value ppill c.pollutant_value#c.ppill $control_variables_aem_t78, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace
	
eststo regression3: reghdfe dac pollutant_value gparachute c.pollutant_value#c.gparachute $control_variables_aem_t78, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression4: reghdfe dac pollutant_value ppill c.pollutant_value#c.ppill $control_variables_aem_t78, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression5: reghdfe rem pollutant_value gparachute c.pollutant_value#c.gparachute $control_variables_rem_t78, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression6: reghdfe rem pollutant_value ppill c.pollutant_value#c.ppill $control_variables_rem_t78, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 regression6 using "$output\table15_panelCD_PM25.tex", replace fragment ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) drop($control_variables_rem_t78 $control_variables_aem_t78) mtitles("\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jones)}" "\makecell{AEM \\ (modified Jones)}" "REM" "REM")  collabels(none) booktabs label stats(firmcont yearfe indfe N ar2, fmt(0 0 0 0 2 2) labels("Baseline Controls" "Year FE" "Industry FE" "N" "Adjusted R-sq")) order(pollutant_value gparachute c.pollutant_value#c.gparachute ppill c.pollutant_value#c.ppill) prehead("\begin{table}\begin{center}\scalebox{0.6}{\begin{tabular}{lcccccc}\toprule") posthead("\midrule&\multicolumn{6}{c}{\textbf{Panel C: CG = Golden Parachute or Poison Pill}}\\") /*starlevels(* 0.2 ** 0.1 *** 0.02)*/

* Panel D
	capture drop _merge
merge 1:1 lpermco fyear using "$output\CEO_duality_x.dta"
	keep if _merge == 1 | _merge == 3

	capture drop _merge
merge 1:1 tic fyear using "$output\board_characteristics", force
	keep if _merge == 1 | _merge == 3
	
label var dual_max "CEO-Chairman Duality"
	eststo clear
eststo regression1: reghdfe dacck  pollutant_value CEOduality c.pollutant_value#c.CEOduality $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression2: reghdfe dacck pollutant_value dual_max c.pollutant_value#c.dual_max $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace
	
eststo regression3: reghdfe dac pollutant_value CEOduality c.pollutant_value#c.CEOduality $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression4: reghdfe dac pollutant_value dual_max c.pollutant_value#c.dual_max $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression5: reghdfe rem pollutant_value CEOduality c.pollutant_value#c.CEOduality $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression6: reghdfe rem pollutant_value dual_max c.pollutant_value#c.dual_max $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 regression6 using "$output\table15_panelCD_PM25.tex", append fragment ///
drop($control_variables_rem $control_variables_aem) ///
mtitles("Duality 1" "Duality 2" "Duality 1" "Duality 2" "Duality 1" "Duality 2") nonumbers collabels(none) booktabs label order(pollutant_value CEOduality c.pollutant_value#c.CEOduality dual_max c.pollutant_value#c.dual_max) ///
stats(firmcont yearfe indfe N ar2, fmt(0 0 0 0 2 2) labels("Baseline Controls" "Year FE" "Industry FE" "N" "Adjusted R-sq")) starlevels(* 0.2 ** 0.1 *** 0.02) ///
posthead("\midrule&\multicolumn{6}{c}{\textbf{Panel D: CG = CEO-Chairman Duality}}\\") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table presents the regression results to test the mediating effect of corporate governance on the relation between air pollution and AEM/REM. We use CG Strengths and CG Concerns in Panel A, Board Independence and Female Ratio on Boards in Panel B, Golden Parachute and Poison Pill in Panel C, and CEO-Chairman Duality in Panel D, respectively, as the proxy for corporate governance. See Appendix A for detailed variable definitions. Numbers in parentheses represent t-statistics calculated based on standard errors clustered at the industry-year level. ***, **, and * indicate statistical significance at the 1\%, 5\%, and 10\% levels, respectively.}\end{table}") 

**# Table 9
	capture drop _merge
	capture drop knowledge_intense labor_intensive
merge m:1 sic using "$output\knowledge_intensive_industry.dta"
	keep if _merge == 1 | _merge == 3
	gen knowledge_intense = (_merge == 3)
	drop _merge

*==================== Regression (Signed) =============================
preserve
keep if knowledge_intense == 1
	eststo clear
eststo regression1: reghdfe dacck pollutant_value $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression2: reghdfe dac pollutant_value $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression3: reghdfe rank_dac pollutant_value $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression4: reghdfe rem pollutant_value $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression5: reghdfe rank_rem pollutant_value $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 using "$output\table9_panelAB_PM25.tex", replace fragment keep(pollutant_value) ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
mtitles("\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jones)}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") collabels(none) booktabs label ///
stats(firmcon yearfe indfe N ar2, fmt(0 0 0 0 2 2) labels("Baseline Controls" "Year FE" "Industry FE" "N" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Air Pollution on Earnings Management: Knowledge-Intensive vs. Labor-Intensive Industries}\label{tab: table9}\tabcolsep=0.1cm\scalebox{0.9}{\begin{tabular}{lccccc}\toprule") posthead("\midrule & \multicolumn{5}{c}{\textbf{Panel A: Knowledge-Intensive Industries Subsample}}\\") 
restore

preserve
keep if knowledge_intense == 0
	eststo clear
eststo regression1: reghdfe dacck pollutant_value $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace
	
eststo regression2: reghdfe dac pollutant_value $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression3: reghdfe rank_dac pollutant_value $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression4: reghdfe rem pollutant_value $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression5: reghdfe rank_rem pollutant_value $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 using "$output\table9_panelAB_PM25.tex", append fragment keep(pollutant_value) ///
nomtitles nonumbers collabels(none) booktabs label ///
stats(firmcon yearfe indfe N ar2, fmt(0 0 0 0 2 2) labels("Baseline Controls" "Year FE" "Industry FE" "N" "Adjusted R-sq")) posthead("\midrule& \multicolumn{5}{c}{\textbf{Panel B: Non-Knowledge-Intensive Industries Subsample}}\\") ///
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
eststo regression1: reghdfe dacck pollutant_value $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression2: reghdfe dac pollutant_value $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression3: reghdfe rank_dac pollutant_value $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression4: reghdfe rem pollutant_value $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace 
estadd local firmcont "Yes", replace

eststo regression5: reghdfe rank_rem pollutant_value $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 using "$output\table9_panelCD_PM25.tex", replace fragment keep(pollutant_value) /// 
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
mtitles("\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jones)}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") collabels(none) booktabs label ///
stats(firmcon yearfe indfe N ar2, fmt(0 0 0 0 2 2) labels("Baseline Controls" "Year FE" "Industry FE" "N" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\tabcolsep=0.1cm\scalebox{0.9}{\begin{tabular}{lccccc}\toprule") posthead("\midrule& \multicolumn{5}{c}{\textbf{Panel C: Labor-Intensive Industries Subsample}}\\") 
restore

preserve
keep if labor_intensive == 0
	eststo clear
eststo regression1: reghdfe dacck pollutant_value $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression2: reghdfe dac pollutant_value $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression3: reghdfe rank_dac pollutant_value $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression4: reghdfe rem pollutant_value $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression5: reghdfe rank_rem pollutant_value $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 using "$output\table9_panelCD_PM25.tex", append fragment keep(pollutant_value) ///
nomtitles nonumbers collabels(none) booktabs label ///
stats(firmcon yearfe indfe N ar2, fmt(0 0 0 0 2 2) labels("Baseline Controls" "Year FE" "Industry FE" "N" "Adjusted R-sq")) posthead("\midrule& \multicolumn{5}{c}{\textbf{Panel D: Non-Labor-Intensive Industries Subsample}}\\") ///
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
eststo regression1: reghdfe log_tfp pollutant_value $control_variables, absorb(fyear) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "No", replace
estadd local firmcont "Yes", replace

eststo regression2: reghdfe log_tfp pollutant_value $control_variables, absorb(ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "No", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression3: reghdfe log_tfp pollutant_value $control_variables, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

esttab regression3 using "$output\table9_panelE_PM25.tex", replace fragment ///
nomtitles collabels(none) booktabs label ///
stats(yearfe indfe N ar2, fmt(0 0 0 0 2) labels("Year FE" "Industry FE" "N" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\tabcolsep=0.1cm\scalebox{0.9}{\begin{tabular}{lccc}\toprule") /*starlevels(* 0.2 ** 0.1 *** 0.02)*/ compress style(tab) posthead("\midrule &\multicolumn{1}{c}{\textbf{Panel E: The Effect of Air Pollution on Managers' Productivity}}\\") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: Panels A to D of this table present the regression results to test the effect of the level of PM 2.5 on AEM and REM using subsamples. Our sample is divided into two subsamples based on knowledge-intensive vs. non-knowledge-intensive industries in Panels A and B, and based on labor-intensive vs. non-labor-intensive industries in Panels C and D. Panel E presents the regression results to test the effect of the level of PM 2.5 on Total Factor Productivity. See Appendix A for detailed variable definitions. Numbers in parentheses represent t-statistics calculated based on standard errors clustered at the industry-year level. ***, **, and * indicate statistical significance at the 1\%, 5\%, and 10\% levels, respectively.}\end{table}") 

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
eststo regression1: reghdfe rem pollutant_value $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace

eststo regression2: reghdfe rem pollutant_value $control_variables_rem coastal, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace

eststo regression3: reghdfe rem pollutant_value $control_variables_rem coastal c.pollutant_value#c.coastal, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace

eststo regression4: reghdfe rank_rem pollutant_value $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace

eststo regression5: reghdfe rank_rem pollutant_value $control_variables_rem coastal, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace

eststo regression6: reghdfe rank_rem pollutant_value $control_variables_rem coastal c.pollutant_value#c.coastal, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace
		
esttab regression1 regression2 regression3 regression4 regression5 regression6 using "$output\table22_PM25.tex", replace ///
mgroups("Real Earnings Management" "Rank of Real Earnings Management", pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
nomtitles collabels(none) booktabs label scalar(ymean) drop($control_variables_rem) ///
stats(blcontrols yearfe indfe N ar2, fmt(0 0 0 0 2 2) labels("Baseline Controls" "Year FE" "Industry FE" "N" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Air Pollution on Earnings Management: Coastal vs. Inland Regions}\label{tab: table22}\tabcolsep=0.1cm\scalebox{0.8}{\begin{tabular}{lcccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table presents the regression results to test the difference between coastal and inland areas in the effect of the level of PM 2.5 on REM. See Appendix A for detailed variable definitions. Numbers in parentheses represent t-statistics calculated based on standard errors clustered at the industry-year level. ***, **, and * indicate statistical significance at the 1\%, 5\%, and 10\% levels, respectively.}\end{table}") 

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

esttab regression1 regression2 regression3 regression4 regression5 using "$output\table12_PM25.tex", replace fragment ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
mtitles("\makecell{AEM \\ (performance \\ -adj.)}" "\makecell{AEM \\ (modified \\ Jones)}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") nonumbers collabels(none) nolines booktabs label keep(visib_PM2_5) postfoot("\midrule") ///
stats(firmcont yearfe indfe N ar2, fmt(0 0 0 0 2 2) labels("Baseline Controls" "Year FE" "Industry FE" "N" "Adjusted R-sq")) ///
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

esttab regression1 regression2 regression3 regression4 regression5 using "$output\table12_PM25.tex", append  ///
booktabs label scalar(ymean) nomtitles nonumbers fragment nolines keep(visib_res) posthead("\midrule") postfoot("\midrule") ///
stats(firmcon yearfe indfe N ar2, fmt(0 0 0 0 2 2) labels("Baseline Controls" "Year FE" "Industry FE" "N" "Adjusted R-sq")) 

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

esttab regression1 regression2 regression3 regression4 regression5 using "$output\table12_PM25.tex", append fragment ///
nomtitles nonumbers collabels(none) booktabs label ///
stats(firmcon yearfe indfe N ar2, fmt(0 0 0 0 2 2) labels("Baseline Controls" "Year FE" "Industry FE" "N" "Adjusted R-sq")) keep(pollutant_value) ///
posthead("&\multicolumn{5}{c}{\textbf{Panel B: Using PM 2.5 Instead of Visibility}} \\") ///
postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table presents the regression results to test the effect of unpleasant air quality on AEM and REM using actual air pollution measures. We use the fitted value of $Visibility$ and the residual from the regression of $Visibility$ on PM 2.5 in Panel A, and use PM 2.5 in Panel B, respectively, as the main test variable. See Appendix A for detailed variable definitions. Numbers in parentheses represent t-statistics calculated based on standard errors clustered at the industry-year level. ***, **, and * indicate statistical significance at the 1\%, 5\%, and 10\% levels, respectively.}\end{table}") 
exit

**# Table D1
*======== Correlation Table ==============================

global summ_vars dacck dac rem size bm roa lev firm_age rank au_years loss salesgrowth lit InstOwn_Perc stockreturn sale_sd oa_scale hhi_sale cover 

*ssc install corrtex
corrtex $summ_vars, file(CorrTable) replace land sig /*dig(4) star(0.05)*/


**# Table OA1
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

esttab regression1 regression2 regression3 regression4  regression5 regression6 regression7 regression8 regression9 using "$output\table7_PM25.tex", replace  drop($control_variables_rem) ///
nomtitles collabels(none) booktabs label scalar(ymean) stats(firmcont yearfe indfe N ar2, fmt(0 0 0 0 2 2) labels("Baseline Controls"  "Year FE" "Industry FE" "N" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{Controlling for Additional Measures of Unpleasant Weather}\label{tab: table7}\tabcolsep=0.1cm\scalebox{0.65}{\begin{tabular}{lcccccccccc}\toprule") starlevels(* 0.2 ** 0.1 *** 0.02)  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table presents the regression results to test the effect of $Visibility$ on REM after controlling for various weather variables. See Appendices A and B for detailed variable definitions and descriptions. Numbers in parentheses represent t-statistics calculated based on standard errors clustered at the industry-year level. ***, **, and * indicate statistical significance at the 1\%, 5\%, and 10\% levels, respectively.}\end{table}")

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

	capture drop pollutant_value_median
	capture drop pollutant_value_binary
	capture drop pollutant_value_binary_neg
egen pollutant_value_median = median(pollutant_value)
gen pollutant_value_binary = (pollutant_value > pollutant_value_median) if !mi(pollutant_value)
gen pollutant_value_binary_neg = -pollutant_value_binary

global control_variables_psm size bm roa lev firm_age rank au_years hhi_sale oa_scale

*set seed 12345678
*psmatch2 visib_binary $control_variables, outcome(rem) noreplacement ties radius caliper(0.00001)
psmatch2 pollutant_value_binary $control_variables_psm, outcome(rem) ai(3) ///
                     caliper(0.03) noreplacement descending common odds index logit ties ///
                     warnings quietly ate


psgraph
pstest $control_variables_psm

eststo treatall: estpost sum $control_variables_psm if pollutant_value > pollutant_value_median
eststo controlall: estpost sum $control_variables_psm if pollutant_value <= pollutant_value_median
eststo diffall: estpost ttest $control_variables_psm, by(pollutant_value_binary_neg) 
eststo treatpsm: estpost sum $control_variables_psm if pollutant_value > pollutant_value_median & _support == 1
eststo controlpsm: estpost sum $control_variables_psm if pollutant_value <= pollutant_value_median  & _support == 1
eststo diffpsm: estpost ttest $control_variables_psm if _support == 1, by(pollutant_value_binary_neg) 

esttab treatall controlall diffall treatpsm controlpsm diffpsm using "$output\ttest_psm1_PM25.tex", ///
replace cells("mean(pattern(1 1 0 1 1 0)  fmt(3)) b(star pattern(0 0 1 0 0 1) fmt(3)) ") ///
mgroups("Pooled Sample" "PSM Sample", pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
label mtitles("More Polluted" "Less Polluted" "Difference" "More Polluted" "Less Polluted" "Difference") collabels(none) nonumbers booktabs ///
prehead("\begin{table}\begin{center}\caption{Using Propensity Score Matched Sample}\label{tab: ttestpsm}\tabcolsep=0.1cm\scalebox{0.47}{\begin{tabular}{lcccccc}\toprule") starlevels(* 0.2 ** 0.1 *** 0.02) ///
posthead("\midrule \multicolumn{7}{c}{\textbf{Panel A: Descriptive Statistics for the Sample before and after PSM}}\\") ///
postfoot("\end{tabular}}") 

sum _support
keep if _support == 1 //10846

label var fog "Fog"
*======== Table 4: Regression (Signed) =============================
	eststo clear
eststo regression1: reghdfe dacck pollutant_value $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) 
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
	
eststo regression2: reghdfe dac pollutant_value $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) 
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression3: reghdfe rank_dac pollutant_value $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) 
estadd scalar ar2 = e(r2_a)
summarize rank_dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression4: reghdfe rem pollutant_value $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) 
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression5: reghdfe rank_rem pollutant_value $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) 
estadd scalar ar2 = e(r2_a)
summarize rank_rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 using "$output\ttest_psm2_PM25.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
mtitles("\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jones)}" "AEM Rank" "REM" "REM Rank") collabels(none) booktabs label scalar(ymean) starlevels(* 0.2 ** 0.1 *** 0.02) ///
stats(yearfe indfe N ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{Propensity Score Matching Sample}\label{tab: ttestpsm}\tabcolsep=0.1cm\scalebox{0.6}{\begin{tabular}{lcccccc}\toprule") posthead("\midrule") ///
postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table presents the main regression results to test our hypotheses on the effect of air pollution on AEM and REM using the Propensity Score Matched sample. See Appendix A for detailed variable definitions. Numbers in parentheses represent t-statistics calculated based on standard errors clustered at the industry-year level. ***, **, and * indicate statistical significance at the 1\%, 5\%, and 10\% levels, respectively.}\end{table}") 

**# Table OA2-OA4
global summ_vars dacck dac rank_dac rem rank_rem d_cfo_neg rank_d_cfo_neg d_prod rank_d_prod ///
d_discexp_neg rank_d_discexp_neg size bm roa lev firm_age rank au_years loss sale salesgrowth lit InstOwn_Perc   stockreturn sale_sd oa_scale hhi_sale cover pollutant_value

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
esttab obs Mean std p25 p50 p75 using "$output\summ_stats_firm_8294_PM25.tex", fragment  ///
label cells("count(pattern(1 0 0 0 0 0)) mean(pattern(0 1 0 0 0 0) fmt(3)) sd(pattern(0 0 1 0 0 0) fmt(3)) p25(pattern(0 0 0 1 0 0) fmt(3)) p50(pattern(0 0 0 0 1 0) fmt(3)) p75(pattern(0 0 0 0 0 1) fmt(3))") noobs  ///
nonumbers replace booktabs collabels(none) mtitles("N" "Mean" "Std. Dev." "Bottom 25\%" "Median" "Top 25\%") ///
prehead("\begin{table}\begin{center}\caption{Summary Statistics of Firm Characteristics (three months after fiscal year-end)}\label{tab: summstats18294}\tabcolsep=0.1cm\scalebox{0.67}{\begin{tabular}{lcccccc}\toprule")  ///
postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table presents the descriptive statistics for the firm-level variables used in the analyses where Visibility is measured for three months after the fiscal year-end. See Appendix A for detailed variable definitions and measurement.}\end{table}")  

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

* _PM25.tex
esttab obs Mean std p25 p50 p75 using "$output\summ_stats_weather_8294_PM25.tex", fragment  ///
label cells("count(pattern(1 0 0 0 0 0)) mean(pattern(0 1 0 0 0 0) fmt(3)) sd(pattern(0 0 1 0 0 0) fmt(3)) p25(pattern(0 0 0 1 0 0) fmt(3)) p50(pattern(0 0 0 0 1 0) fmt(3)) p75(pattern(0 0 0 0 0 1) fmt(3))") noobs  ///
nonumbers replace booktabs collabels(none) mtitles("N" "Mean" "Std. Dev." "Bottom 25\%" "Median" "Top 25\%") ///
prehead("\begin{table}\begin{center}\caption{Summary Statistics of Weather-Related Characteristics (three months after fiscal year-end)}\label{tab: summstats28294}\tabcolsep=0.1cm\scalebox{0.67}{\begin{tabular}{lcccccc}\toprule")  ///
postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table presents the descriptive statistics for the various weather variables used in the analyses where Visibility is measured for three months after the fiscal year-end. See Appendix B for detailed variable descriptions.}\end{table}") 

* 3) Table OA4: The Effect of Visibility on Earnings Management (actual period end date and three-month exposure)
label var visib "Visibility_{AfterFY3}"
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

esttab regression1 regression2 regression3 using "$output\table4_8294_PM25.tex", replace ///
mtitles("\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jones)}" "\makecell{AEM \\ Rank}") collabels(none) booktabs label scalar(ymean) ///
stats(yearfe indfe N ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on AEM (three months after fiscal year-end)}\label{tab: table48294}\tabcolsep=0.1cm\scalebox{0.6}{\begin{tabular}{lccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table presents the regression results to test the effect of $Visibility$ on AEM when $Visibility$ is measured for three months after the fiscal year-end. See Appendix A for detailed variable definitions. Numbers in parentheses represent t-statistics calculated based on standard errors clustered at the industry-year level. ***, **, and * indicate statistical significance at the 1\%, 5\%, and 10\% levels, respectively.}\end{table}") 

**# Table OA5-OA7
label var visib "Visibility"

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
esttab obs Mean std p25 p50 p75 using "$output\summ_stats_firm_11283_PM25.tex", fragment  ///
label cells("count(pattern(1 0 0 0 0 0)) mean(pattern(0 1 0 0 0 0) fmt(3)) sd(pattern(0 0 1 0 0 0) fmt(3)) p25(pattern(0 0 0 1 0 0) fmt(3)) p50(pattern(0 0 0 0 1 0) fmt(3)) p75(pattern(0 0 0 0 0 1) fmt(3))") noobs  ///
nonumbers replace booktabs collabels(none) mtitles("N" "Mean" "Std. Dev." "Bottom 25\%" "Median" "Top 25\%") ///
prehead("\begin{table}\begin{center}\caption{Summary Statistics of Firm Characteristics (one year before actual end date)}\label{tab: summstats111283}\tabcolsep=0.1cm\scalebox{0.67}{\begin{tabular}{lcccccc}\toprule")  ///
postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table presents the descriptive statistics for the firm-level variables used in the analyses where $Visibility$ is measured for one year before the actual fiscal year end date. See Appendix A for detailed variable definitions and measurement.}\end{table}") 

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
esttab obs Mean std p25 p50 p75 using "$output\summ_stats_weather_11283_PM25.tex", fragment  ///
label cells("count(pattern(1 0 0 0 0 0)) mean(pattern(0 1 0 0 0 0) fmt(3)) sd(pattern(0 0 1 0 0 0) fmt(3)) p25(pattern(0 0 0 1 0 0) fmt(3)) p50(pattern(0 0 0 0 1 0) fmt(3)) p75(pattern(0 0 0 0 0 1) fmt(3))") noobs  ///
nonumbers replace booktabs collabels(none) mtitles("N" "Mean" "Std. Dev." "Bottom 25\%" "Median" "Top 25\%") ///
prehead("\begin{table}\begin{center}\caption{Summary Statistics of Weather-Related Characteristics (one year before actual end date)}\label{tab: summstats211283}\tabcolsep=0.1cm\scalebox{0.67}{\begin{tabular}{lcccccc}\toprule")  ///
postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table presents the descriptive statistics for the various weather variables used in the analyses where Visibility is measured for one year before the actual fiscal year end date. See Appendix B for detailed variable descriptions.}\end{table}") 

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

esttab regression1 regression2 regression3 regression4 regression5 using "$output\table4_11283_PM25.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
mtitles("\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jones)}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") collabels(none) booktabs label ///
stats(yearfe indfe N ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management (one year before actual end date)}\label{tab: table411283}\tabcolsep=0.1cm\scalebox{0.57}{\begin{tabular}{lccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table presents the regression results to test the effect of $Visibility$ on AEM and REM when $Visibility$ is measured for one year before the actual fiscal year end date. See Appendix A for detailed variable definitions. Numbers in parentheses represent t-statistics calculated based on standard errors clustered at the industry-year level. ***, **, and * indicate statistical significance at the 1\%, 5\%, and 10\% levels, respectively.}\end{table}") 

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
esttab obs Mean std p25 p50 p75 using "$output\summ_stats_firm_10883_PM25.tex", fragment  ///
label cells("count(pattern(1 0 0 0 0 0)) mean(pattern(0 1 0 0 0 0) fmt(3)) sd(pattern(0 0 1 0 0 0) fmt(3)) p25(pattern(0 0 0 1 0 0) fmt(3)) p50(pattern(0 0 0 0 1 0) fmt(3)) p75(pattern(0 0 0 0 0 1) fmt(3))") noobs  ///
nonumbers replace booktabs collabels(none) mtitles("N" "Mean" "Std. Dev." "Bottom 25\%" "Median" "Top 25\%") ///
prehead("\begin{table}\begin{center}\caption{Summary Statistics of Firm Characteristics (three months before actual period end date)}\label{tab: summstats110883}\tabcolsep=0.1cm\scalebox{0.67}{\begin{tabular}{lcccccc}\toprule")  ///
postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table presents the descriptive statistics for the firm-level variables used in the analyses where Visibility is measured for three months before the actual period year end date. See Appendix A for detailed variable definitions and measurement.}\end{table}")  

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
esttab obs Mean std p25 p50 p75 using "$output\summ_stats_weather_10883_PM25.tex", fragment  ///
label cells("count(pattern(1 0 0 0 0 0)) mean(pattern(0 1 0 0 0 0) fmt(3)) sd(pattern(0 0 1 0 0 0) fmt(3)) p25(pattern(0 0 0 1 0 0) fmt(3)) p50(pattern(0 0 0 0 1 0) fmt(3)) p75(pattern(0 0 0 0 0 1) fmt(3))") noobs  ///
nonumbers replace booktabs collabels(none) mtitles("N" "Mean" "Std. Dev." "Bottom 25\%" "Median" "Top 25\%") ///
prehead("\begin{table}\begin{center}\caption{Summary Statistics of Weather-Related Characteristics (three months before actual period end date)}\label{tab: summstats210883}\tabcolsep=0.1cm\scalebox{0.67}{\begin{tabular}{lcccccc}\toprule")  ///
postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table presents the descriptive statistics for the various weather variables used in the analyses where Visibility is measured for three months before the actual fiscal year end date. See Appendix B for detailed variable descriptions.}\end{table}") 

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

esttab regression1 regression2 regression3 regression4 regression5 using "$output\table4_10883_PM25.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
mtitles("\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jones)}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") collabels(none) booktabs label  ///
stats(yearfe indfe N ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management (three months before actual period end date)}\label{tab: table410883}\tabcolsep=0.1cm\scalebox{0.57}{\begin{tabular}{lccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{This table presents the regression results to test the effect of $Visibility$ on AEM and REM when $Visibility$ is measured for three months before the actual fiscal year end date. See Appendix A for detailed variable definitions. Numbers in parentheses represent t-statistics calculated based on standard errors clustered at the industry-year level. ***, **, and * indicate statistical significance at the 1\%, 5\%, and 10\% levels, respectively.}\end{table}") 
