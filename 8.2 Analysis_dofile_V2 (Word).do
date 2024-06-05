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
drop if mi(ENV_str_num) | mi(ENV_con_num) | mi(COM_str_num) | mi(COM_con_num) | ///
mi(HUM_con_num) | mi(EMP_str_num) | mi(EMP_con_num) | mi(DIV_str_num) | mi(DIV_con_num) ///
| mi(PRO_str_num) | mi(PRO_con_num) | mi(CGOV_str_num) | mi(CGOV_con_num) | mi(HUM_str_num)
	rename Ticker tic
	rename year fyear
	rename CUSIP cusip8
	unique tic fyear cusip8
	duplicates drop tic fyear, force 
tempfile KLD_MSCI_tic
save `KLD_MSCI_tic', replace

use "$maindir\KLD MSCI", replace
drop if mi(ENV_str_num) | mi(ENV_con_num) | mi(COM_str_num) | mi(COM_con_num) | ///
mi(HUM_con_num) | mi(EMP_str_num) | mi(EMP_con_num) | mi(DIV_str_num) | mi(DIV_con_num) ///
| mi(PRO_str_num) | mi(PRO_con_num) | mi(CGOV_str_num) | mi(CGOV_con_num) | mi(HUM_str_num)
	rename Ticker tic
	rename year fyear
	rename CUSIP cusip8
	unique tic fyear cusip8
	duplicates drop cusip8 fyear, force 
tempfile KLD_MSCI_cusip8
save `KLD_MSCI_cusip8', replace

use "$output\convk.dta", replace
keep fyear lpermno dacck
tempfile convk
save `convk', replace

*br tic cusip ncusip ibes_cusip cusip8
use "$maindir\Analysis_102148 observations\Firm_Year_Weather", replace

global control_variables_aem size bm roa lev firm_age rank au_years oa_scale /*xrd_int*/
global control_variables_rem size bm roa lev firm_age rank au_years hhi_sale /*xrd_int*/

sort firm_FID fyear

/*Cleaning*/

* Drop observations with duplicate lpermco-fyear
bysort lpermco fyear: gen dup = _n
bysort lpermco fyear: egen dup2 = max(dup)
drop if dup2 > 1 //128

///controls: firm size (Waddock and Graves, 1997), 

/*growth opportunities (McWilliams and Siegel, 2000; Prior et al., 2008), R&D expenses  ///
(Roychowdhury, 2006), advertisement intensity (Cohen and Zarowin, 2010; Kim and Sohn, 2013), ///
firm age (Roychowdhury, 2006; Cohen et al., 2008), profitability (Musteen et al., 2009), ///
leverage (Teoh et al., 1998; Kim and Park, 2005), and the presence of BIG 4 auditors (Becker et al., ///
1998; Francis et al., 2005) are controlled and expressed as controled */

/*Table 1: Summary Statistics*/
global summ_vars dacck dac rank_dac rem rank_rem stdz_rem d_cfo_neg rank_d_cfo_neg d_prod rank_d_prod ///
d_discexp_neg rank_d_discexp_neg size bm roa lev firm_age rank au_years /*<--tenure*/ oa_scale hhi_sale cover sale /*<--noa*/ /*xrd_int */ /*cycle*/ loss salesgrowth /*Boardindependence*/ lit InstOwn_Perc stockreturn sale_sd pollutant_value

*============= Constructing Variables ===================
gen xrd_int= xrd/ sale
label var xrd_int "RD Intensity"

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

gen d_cfo_neg = - d_cfo
gen rank_d_cfo_neg = 9- rank_d_cfo

gen d_discexp_neg = -d_discexp
gen rank_d_discexp_neg = 9-rank_d_discexp

/*generate KZ score*/
*xtset lpermno fyear 
gen cashflow=dp+ib
gen CF_lscaled=cashflow/l1.at
	label variable CF_lscaled "cashflow/l1.at"

gen cash_dividends=dvc+dvp
gen Dividends_scaled=cash_dividends/at
	label variable Dividends_scaled "cash_dividends/at"

gen Debt_scaled=(dltt+dlc)/at

gen DIV_lscaled=cash_dividends/l1.at
	label variable DIV_lscaled "Cash_dividends/l1.at"

gen C_lscaled=che/l1.at
	label variable C_lscaled "che/l1.at"

gen BLEV=( dltt + dlc )/(dltt+dlc+seq)
	label variable BLEV "( dltt + dlc )/(dltt+dlc+seq)"

gen Tobinq=(at +(csho* prcc_f)-ceq)/at
	label variable Tobinq "(at +(csho* prcc_f)-ceq)/at"

*gen Tobinq_2=(at +(csho* prcc_f)-(ceq+txdb))/at
*label variable Tobinq_2 "(at +(csho* prcc_f)-(ceq+txdb))/at"
gen KZ=-1.002*CF_lscaled- 39.368*DIV_lscaled- 1.315*C_lscaled+ 3.319*BLEV+ 0.283*Tobinq
 
 capture ssc install sicff
* generate 48 industries based on the 4-digit sic code: sic
destring sic, replace
sicff sic, ind(48)

	* ==================================================================
	* ==================== Choose Sample ===============================
	* ==================================================================
	keep if !mi(dac) & !mi(rem) & !mi(visib) & !mi(size) & !mi(bm) & !mi(roa)  ///
	& !mi(lev) & !mi(firm_age) & !mi(rank) & !mi(au_years) & !mi(oa_scale) ///
	&  !mi(d_cfo) &  !mi( rank_d_cfo) &  !mi( d_prod ) &  !mi(rank_d_prod ) ///
	&  !mi(d_discexp ) &  !mi(rank_d_discexp) & !mi(ff_48) & !mi(fyear)
	
hhi5 sale, by(ff_48 fyear) //hhi_sale
label var hhi_sale "HHI index"		

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

	capture drop _merge
merge 1:1 lpermno fyear using `convk'	

drop if _merge == 2

*save "$output\final_data_47662", replace

**# Start of Analyses
use "$output\final_data_47662", replace

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

**# Table 2
global summ_vars dacck dac rank_dac rem rank_rem stdz_rem d_cfo_neg rank_d_cfo_neg d_prod rank_d_prod ///
d_discexp_neg rank_d_discexp_neg size bm roa lev firm_age rank au_years /*<--tenure*/ oa_scale hhi_sale cover sale /*<--noa*/ /*xrd_int */ /*cycle*/ loss salesgrowth /*Boardindependence*/ lit InstOwn_Perc stockreturn sale_sd pollutant_value

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

* .rtf
estout obs Mean std p25 p50 p75 using "$output\Word_results.rtf",  ///
label nonumbers replace mlabels("N" "Mean" "Std. Dev." "Bottom 25%" "Median" "Top 25%") collabels(none) ///
cells("count(pattern(1 0 0 0 0 0)) mean(pattern(0 1 0 0 0 0) fmt(3)) sd(pattern(0 0 1 0 0 0) fmt(2)) p25(pattern(0 0 0 1 0 0) fmt(2)) p50(pattern(0 0 0 0 1 0) fmt(3)) p75(pattern(0 0 0 0 0 1) fmt(2))") ///
title("Summary Statistics of Firm Characteristics") ///
note("Notes: This table reports the descriptive statistics of firm-level characteristics for 12,191 firm-year-station observations from 2003 to 2017. Firm characteristics are obtained from Compustat and I/B/E/S data. We restrict the sample to be within a year before the actual period end date of each firm's financial report. The characteristics include the following: AEM (performance-adjusted) is computed using the cross-sectional performance-adjusted modified Jones model as in Kothari et al.(2005); AEM (modified Jone's) is calculated following Dechow (1995); AEM Rank denotes the rank of AEM (modified Jone's) for the year and industry; REM, the aggregate measure of real earnings management, is the sum of REM_{CFO}, REM_{PROD}, and REM_{DISX}, where REM_{CFO} and REM_{DISX} are the negative values of discretionary cash flows and discretionary expenses, respectively; REM Rank represents the rank of REM for the year and industry; REM Variability indicates the standard deviation of REM across the five consecutive years prior to the firm's actual period end date; REM_{CFO} denotes abnormal cash flows from operations, which are measured as the deviation of the firm's actual cash flows from the normal level of discretionary cash flows as are predicted using the corresponding industry-year regression; REM_{PROD} denotes abnormal production costs, and is measured as the deviation of the firm's actual production costs from the normal level of production costs as are predicted using the corresponding industry-year regression; REM_{DISX}, discretionary expenses, are measured as the deviation of the firm's actual expenses from the normal level of discretionary expenses as are predicted using the corresponding industry-year regression. Size, the firm's size, is calculated as the logged value of the firm's total assets in the current fiscal year; BM, the book-to-market ratio in the current fiscal year, is calculated as the ratio of the firm's book value of equity and the market value of equity; ROA is the ratio of the firm's income before extraordinary items and total assets; Leverage, the leverage ratio in the current fiscal year, is defined as the ratio between the firm's total liabilities and total assets; Firm Age, the age of the firm, is defined as the number of years starting from the first time when the firm's stock returns are reported in the monthly stock files of the Center for Research in Security Prices (CRSP); Big N is an indicator that takes 1 if the firm was audited by a Big N CPA firm, and 0 otherwise; Auditor Tenure denotes the number of years that the firm was audited by a same auditor; NOA is the ratio between the firm's net operating assets at the beginning of the year and lagged sales during the corresponding industry-year (net operating assets are calculated using shareholders' equity less cash and marketable securities, plus total debt); HHI refers to Herfindahl–Hirschman Index; ANAL, the number of analysts following the firm in the current fiscal year, is obtained from I/B/E/S; Sales refers to the sales of the firm in the current fiscal year; Loss refers to the firm's loss; Sales growhth refers to the firm's sales growth; Litigious is an indicator for litigious industry; Institutional ownership refers to the percent of shares outstanding that is owned by institutional owners; Stock return refers to the return to the firm's stocks; and Sales rolling std. refers to the 3-year rolling standard deviation of the firm's sales. PM 2.5 refers to the weighted annual mean of PM 2.5 for each city and year. Standard deviations are in parentheses. *** p < 1%, ** p < 5%, * p < 10%.") 

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
label var max  "Max Temp"
label var prcp  "Total Precip."
label var sndp  "Snow Depth"
label var snow  "Snow"
label var hail  "Hail"
label var tornado "Tornado"

global summ_vars_weather temp dewp slp visib wdsp ///
				 gust mxspd prcp sndp max min fog rain snow   ///
				  hail thunder tornado
				  
* Summary statistics continued
	eststo clear
eststo summ_stats: estpost sum $summ_vars_weather

eststo obs: estpost summarize $summ_vars_weather, detail

ereturn list 

eststo Mean: estpost summarize $summ_vars_weather, detail

ereturn list 

eststo p25: estpost summarize $summ_vars_weather, detail

ereturn list 

eststo p50: estpost summarize $summ_vars_weather, detail

ereturn list 

eststo p75: estpost summarize $summ_vars_weather, detail

ereturn list 

eststo std: estpost summarize $summ_vars_weather, detail

ereturn list 

eststo Median: estpost summarize $summ_vars_weather

ereturn list 

* .tex
estout obs Mean std p25 p50 p75 using "$output\summ_stats_weather.rtf", ///
 label cells("count(pattern(1 0 0 0 0 0)) mean(pattern(0 1 0 0 0 0) fmt(2)) sd(pattern(0 0 1 0 0 0) fmt(2)) p25(pattern(0 0 0 1 0 0) fmt(2)) p50(pattern(0 0 0 0 1 0) fmt(2)) p75(pattern(0 0 0 0 0 1) fmt(2))")  ///
nonumbers replace collabels(none) mlabels("N" "Mean" "Std. Dev." "Bottom 25%" "Median" "Top 25%") ///
title("Summary Statistics of Weather-related Characteristics")  ///
note("Notes: This table reports the descriptive statistics of weather-related characteristics for 12,191 firm-year-station observations from 2003 to 2017. Weather-related characterstics are: temp, mean temperature for the day in degrees Fahrenheit; dewp, mean dew point for the day in degrees Fahrenheit to tenths; slp, mean sea level pressure for the day in millibars to tenths; visib, mean visibility for the day in millibars to tenths; wdsp, mean wind speed for the day in knots to tenths; gust, maximum wind gust reported for the day in knots to tenths; mxspd, maximum sustained wind speed reported for the day in knots to tenths; prcp, total precipitation (rain and/or melted snow) reported during the day in inches and hundredths; sndp, snow depth in inches to tenths, and will be the last report for the day if reported more than once; max, maximum temperature reported during the day in Fahrenheit; min, minimum temperature reported during the day in Fahrenheit; rain, an indicator that takes 1 during the day of rain or drizzle; fog, an indicator that takes 1 during the day of fog; snow, an indicator that takes 1 during the day of snow or ice pellets; thunder, an indicator that takes 1 during the day of thunder; hail, an indicator during the day of hail; tornado, an indicator that takes 1 during the day of tornado or funnel cloud. Details of each weather-related variable, including the definition, unit, can be found in Table \ref{tab: variabledescriptions2}. Standard deviations are in parentheses. *** p < 1\%, ** p < 5\%, * p < 10\%.") 

**# Table 4
*========= t-test table ========================
global summ_vars dacck dac rank_dac rem rank_rem stdz_rem d_cfo_neg rank_d_cfo_neg d_prod rank_d_prod ///
d_discexp_neg rank_d_discexp_neg size bm roa lev firm_age rank au_years /*<--tenure*/ oa_scale hhi_sale cover sale /*<--noa*/ /*xrd_int */ /*cycle*/ loss salesgrowth /*Boardindependence*/ lit InstOwn_Perc stockreturn sale_sd pollutant_value

global control_variables_rem size bm roa lev firm_age rank au_years hhi_sale /*xrd_int*/ loss salesgrowth /*Boardindependence*/ lit InstOwn_Perc stockreturn sale_sd dac

summarize visib if !mi(visib), d
local visib_median = r(p50) 
gen polluted = (visib < `visib_median') if !mi(visib)

eststo allsample: estpost summarize $summ_vars

eststo polluted_sample: estpost summarize $summ_vars if polluted == 1

eststo unpolluted_sample: estpost summarize $summ_vars if polluted == 0

gen unpolluted = -polluted
eststo difference:  estpost ttest $summ_vars, by(unpolluted)

esttab allsample polluted_sample unpolluted_sample difference using "$output\ttest.rtf", ///
replace cells("mean(pattern(1 1 1 0)  fmt(3)) b(star pattern(0 0 0 1) fmt(3)) ") collabels(none) ///
label mtitles("All" "Polluted" "Unpolluted" "Polluted-Unpolluted") nonumbers title("Uni-variate Test")  ///
note("Notes: This table shows the univarite test of the difference between firms exposed to higher air quality and those exposed to lower air quality (defined as being lower than the median of visibility over years: 2003-2017). A description of all variables can be found in Table. *** p < 1\%, ** p < 5\%, * p < 10\%.") 
exit
**# Table 5
global control_variables_aem size bm roa lev firm_age rank au_years oa_scale /*xrd_int*/
global control_variables_rem size bm roa lev firm_age rank au_years hhi_sale /*xrd_int*/

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

esttab regression1 regression2 regression3 regression4 regression5 using "$output\table4.rtf", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0)) ///
mtitles("AEM (performance-adj.)" "AEM (modified Jone's')" "AEM Rank" "REM" "REM Rank") collabels(none) label scalar(ymean) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
title("The Effect of Visibility on Earnings Management")  ///
note("Notes: The dependent variables are indicated at the top of each column. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variables in columns (1)-(3) are: a firms' accrual earnings management calculated using the performance-adjusted method, a firm's accrual earnings management calculated using the modified Jone's method, and the rank of the firm's accrual earnings management (modified Jone's), respectively. The dependent variables in columns (4)-(5) are: a firm's real earnings management, and the rank of the firm's real earnings management, respectively. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm-year. *** p < 1\%, ** p < 5\%, * p < 10\%.") 

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

esttab sales1 sales2 overprod1 overprod2 expenditure1 expenditure2 using "$output\table5.rtf", replace ///
depvars collabels(none) label scalar(ymean) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
title("The Effects of Visibility on Individual REM Measures")  ///
note("Notes: The table reports the effects of visibility on each component of the aggregate measure of real earnings management (REM). A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variables are indicated at the top of each column. The dependent variables in columns (1)-(2) are: the discretionary cash flow component of a firm's REM, and the rank of this component. To be consistent with the sign of the aggregate measure of REM, we take the negative value of discretionary cash flows. The dependent variables in columns (3)-(4) are: the production cost component of a firm's REM, and the rank of this component. The dependent variables in columns (5)-(6) are: the discretionary expense component of a firm's REM, and the rank of this component. To be consistent with the sign of the aggregate measure of REM, we take the negative value of discretionary expenses. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm and year.  *** p < 1\%, ** p < 5\%, * p < 10\%.") 

**# Table 7
*================================== External Monitoring? Analyst ================================
	eststo clear
eststo regression1: reghdfe dacck visib cover c.visib#c.cover $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace	

eststo regression2: reghdfe dac visib cover c.visib#c.cover $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression3: reghdfe rank_dac visib cover c.visib#c.cover $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression4: reghdfe rem visib cover c.visib#c.cover $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression5: reghdfe rank_rem visib cover c.visib#c.cover $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 using "$output\table8.rtf", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0)) drop($control_variables_rem $control_variables_aem) ///
mtitles("AEM (performance-adj.)" "AEM (modified Jone's)" "AEM Rank" "REM" "REM Rank") collabels(none) label scalar(ymean) order(visib cover c.visib#c.cover) ///
stats(yearfe indfe firmcont N ymean ar2, fmt(0 0 0 0 2 2) labels("Year FE" "Industry FE" "Firm Controls" "N" "Dep mean" "Adjusted R-sq")) ///
title("The Effect of Visibility on Earnings Management by the Degree of External Control")  ///
note("Notes: This table reports how the effects of visibility on AEM, the rank of AEM, REM, and the rank of REM differ by the degree of external monitoring. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variable in column (1) is the performance-adjusted measure of AEM, the dependent variable in column (2) is AEM calculated using the modified Jone's model, the dependent variable in column (3) is the rank of AEM (modified Jone's), the dependent variable in column (4) is REM, and the dependent variable in column (5) is the rank of REM. Firm controls are the same as in Table \ref{tab: table4}.  Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm and year. *** p < 1\%, ** p < 5\%, * p < 10\%.") 

**# Table 8
*========== Table 15: visibility interacts with internal monitoring to REM ======================== 
label var CGOV_str_num "CG Strengths"
label var CGOV_con_num "CG Concerns"
	eststo clear
eststo regression1: reghdfe dacck visib CGOV_str_num c.visib#c.CGOV_str_num $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression2: reghdfe dacck visib CGOV_con_num c.visib#c.CGOV_con_num $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace
	
eststo regression3: reghdfe dac visib CGOV_str_num c.visib#c.CGOV_str_num $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression4: reghdfe dac visib CGOV_con_num c.visib#c.CGOV_con_num $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) //c.?
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression5: reghdfe rem visib CGOV_str_num c.visib#c.CGOV_str_num $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression6: reghdfe rem visib CGOV_con_num c.visib#c.CGOV_con_num $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 regression6 using "$output\table15.rtf", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 0 1 0)) drop($control_variables_rem $control_variables_aem) ///
mtitles("Good CG" "Poor CG" "Good CG" "Poor CG" "Good CG" "Poor CG") collabels(none) label scalar(ymean) order(visib CGOV_str_num c.visib#c.CGOV_str_num CGOV_con_num c.visib#c.CGOV_con_num) ///
stats(yearfe indfe firmcont N ymean ar2, fmt(0 0 0 0 2 2) labels("Year FE" "Industry FE" "Firm Controls" "N" "Dep mean" "Adjusted R-sq")) ///
title("The Effect of Visibility on Earnings Management by the Degree of Corporate Governance")  ///
note("Notes: This table reports how the effects of visibility on AEM and REM differ by the degree of the internal corporate governance. CG Strengths refer to the number of strengths of a firm's internal governance. CG Concerns refer to the number of concerns of a firm's internal governance. The dependent variable in columns (1)-(4) is AEM, and the dependent variable in columns (5) and (6) is REM. The AEM measure in columns (1) and (2) is calculated using the performance-adjusted model, and the AEM measure in columns (3) and (4) is calculated using the modified Jone's model. Firm controls are the same as in Table \ref{tab: table4}. A description of all variables can be found in Table \ref{tab: variabledescriptions}. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm and year. *** p < 1\%, ** p < 5\%, * p < 10\%.") 

**# Table 9 PSM separate do-files
run "$dofile\12. Analysis_dofile_PSM.do"

**# Table 10
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

label var coastal "Coastal Region"

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

eststo regression3: reghdfe rem visib $control_variables_rem coastal c.visib#i.coastal, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
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

eststo regression6: reghdfe rank_rem visib $control_variables_rem coastal c.visib#i.coastal, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace
		
esttab regression1 regression2 regression3 regression4 regression5 regression6 using "$output\table22.rtf", replace ///
mgroups("Real Earnings Management" "Rank of Real Earnings Management", pattern(1 0 0 1 0 0)) ///
nomtitles collabels(none) label scalar(ymean) drop($control_variables_rem) ///
stats(blcontrols yearfe indfe N ymean ar2, fmt(0 0 0 0 2 2) labels("Baseline Controls" "Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
title("The Effect of Visibility on Real Earnings Management in Coastal Regions")  ///
note("Notes: This table reports the effects of visibility on the aggregate measure of real earnings management (REM) and the rank of REM. A description of all variables can be found in Table \ref{tab: variabledescriptions}. Columns (1)-(3) report the effects of visibility on REM, and columns (4)-(6) report the effects of visibility on the rank of REM. Columns (1) and (4) are the baseline specifications. Columns (2) and (5) include an indicator for whether the state the firm is located in is coastal. Columns (3) and (6) further include the interaction term between the coastal indicator variable and visiblity as an additional control. Firm controls are the same as in Table \ref{tab: table4}. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm and year. *** p < 1\%, ** p < 5\%, * p < 10\%.") 

**# Table 11 PM 2.5 in another do-file
run "$dofile\13. Analysis_dofile_pollutants.do"

**# Table D1 - Cross-correlation Table
*======== Correlation Table ==============================
*ssc install corrtex
*corrtex $summ_vars, file(CorrTable) replace land sig /*dig(4) star(0.05)*/
asdoc pwcorr $summ_vars, label replace sig format(%9.1f) save(corr2.rtf)
* Notes: This table reports pooled Pearson correlations for the entire sample of 10,883 firm-year observations over the period 2004-2017. *Significant at the 10% level. **Significant at the 5% level. Please see Table \ref{tab: variabledescriptions} for variable descriptions.

**# Table E1
*========== Table 25: Big N Auditors to proxy for External monitoring ======================== 
global control_variables_rem_bign size bm roa lev firm_age /*rank*/ au_years hhi_sale /*xrd_int*/
xtset lpermno fyear

	eststo clear
eststo regression1: reghdfe rem visib $control_variables_rem_bign, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace

eststo regression2: reghdfe rem visib $control_variables_rem_bign rank, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace

eststo regression3: reghdfe rem visib $control_variables_rem_bign rank c.visib#c.rank, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace

eststo regression4: reghdfe rank_rem visib $control_variables_rem_bign, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace

eststo regression5: reghdfe rank_rem visib $control_variables_rem_bign rank, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace
		
eststo regression6: reghdfe rank_rem visib $control_variables_rem_bign rank c.visib#c.rank, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 regression6 using "$output\table25.rtf", replace ///
mgroups("Real Earnings Management" "Rank of Real Earnings Management", pattern(1 0 0 1 0 0)) ///
nomtitles collabels(none) label scalar(ymean) drop($control_variables_rem_bign) ///
stats(blcontrols yearfe indfe N ymean ar2, fmt(0 0 0 0 2 2) labels("Baseline Controls" "Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
title("The Effect of Visibility on Real Earnings Management with Big N Auditors")  note(Notes: This table reports the effects of visibility on the aggregate measure of real earnings management (REM) and the rank of REM. A description of all variables can be found in Table \ref{tab: variabledescriptions}. Columns (1)-(3) report the effects of visibility on REM, and columns (4)-(6) report the effects of visibility on the rank of REM. Columns (1) and (4) are the baseline specifications. Columns (2) and (5) include an indicator for Big N Auditors as an additional control. Columns (3) and (6) further include the interaction term of the Big N Auditor indicator and average visibility the firm is exposed to during the fiscal year prior to its fiscal year end date as an additional control. Firm controls are the same as in Table \ref{tab: table4}. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm and year. *** p < 1\%, ** p < 5\%, * p < 10\%.) 



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

eststo regression8: reghdfe rem visib $control_variables_rem fog, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression9: reghdfe rem visib $control_variables_rem rain, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression10: reghdfe rem visib $control_variables_rem temp dewp slp wdsp mxspd min fog rain, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

esttab regression1 regression2 regression3 regression4  regression5 regression6 regression7 regression8 regression9 regression10 using "$output\table7.rtf", replace  drop($control_variables_rem) ///
nomtitles collabels(none) label scalar(ymean) stats(yearfe indfe firmcont N ymean ar2, fmt(0 0 0 0 2 2) labels("Year FE" "Industry FE" "Firm Controls" "N" "Dep mean" "Adjusted R-sq")) ///
title("Controlling for Additional Measures of Unpleasant Weather")  ///
note("Notes: This table reports the effects of visibility on the aggregate measure of real earnings management (REM) with a series of additional weather control variables from NOAA. Column (1) is the baseline regression with no other weather controls. Column (2) includes the mean temperature reported by the firm's nearest station over the one-year period. Column (3) includes the mean dew point reported by the firm's nearest station over the one-year period. Column (4) includes the mean sea level pressure reported by the firm's nearest station over the one-year period. Column (5) includes the mean wind speed reported by the firm's nearest station over the one-year period. Column (6) includes the maximum wind speed reported by the firm's nearest station over the one-year period. Column (7) includes the minimum temprature reported by the firm's nearest station over the one-year period. Column (8) includes the mean probability of fog occurrence reported by the firm's nearest station over the one-year period. Column (9) includes the mean rain occurrence reported by the firm's nearest station over the one-year period. Column (10) includes all the above-mentioned weather controls. Firm controls are the same as in Table \ref{tab: table4}. A description of all variables can be found in Table \ref{tab: variabledescriptions}. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm-year. *** p < 1\%, ** p < 5\%, * p < 10\%.")

**# Table OA2-Table OA7 in a separate do-file
do "$dofile\14. apde_3month_analysis_file_10883 obs.do"

* Table OA2
* Table OA3
* Table OA4
* Table OA5
* Table OA6
* Table OA7

**# Knowledge-intensive v.s Labor-intensive
global control_variables_aem size bm roa lev firm_age rank au_years oa_scale /*xrd_int*/
global control_variables_rem size bm roa lev firm_age rank au_years hhi_sale /*xrd_int*/
global control_variables size bm roa lev firm_age hhi_sale 

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

esttab regression1 regression2 regression3 regression4 regression5 using "$output\table9.rtf", replace nonumbers keep(visib) ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0)) ///
mtitles("AEM (performance-adj.)" "AEM (modified Jone's')" "AEM Rank" "REM" "REM Rank") collabels(none) label ///
title("The Effect of Visibility on Earnings Management: Knowledge-Intensive vs. Labor-Intensive Industries Panel A: Knowledge-Intensive Industries Subsample")
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

esttab regression1 regression2 regression3 regression4 regression5 using "$output\table9.rtf", append nonumbers nomtitles keep(visib) collabels(none) label ///
title("Panel B: Non-Knowledge-Intensive Industries Subsample")
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

esttab regression1 regression2 regression3 regression4 regression5 using "$output\table9.rtf", append nonumbers nomtitles keep(visib) collabels(none) label ///
title("Panel C: Labor-Intensive Industries Subsample")

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

esttab regression1 regression2 regression3 regression4 regression5 using "$output\table9.rtf", append nonumbers nomtitles keep(visib) collabels(none) label ///
title("Panel D: Non-Labor-Intensive Industries Subsample")
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

label var log_tfp "log(TFP)"
label var visib "Visibility"
label var size "Firm Size"
label var bm "Book-to-Market Ratio"
label var roa "ROA"
label var lev "Leverage"
label var firm_age "Firm Age"
label var hhi_sale "HHI"
 	eststo clear
eststo regression1: reghdfe log_tfp visib $control_variables, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

esttab regression1 using "$output\table9.rtf", append label nonumbers title("Panel E: The Effect of Visibility on Managers' Productivity") note("Notes: The dependent variables are indicated at the top of each column. The dependent variables in columns 1-3 are: a firms' accrual earnings management calculated using the performance-adjusted method, a firm's accrual earnings management calculated using the modified Jone's method, and the rank of the firm's accrual earnings management (modified Jone's), respectively. The dependent variables in columns 4-5 are: a firm's real earnings management, and the rank of the firm's real earnings management, respectively. Control variables include: firm size, book-to-market ratio, return on assets, leverage ratio, firm age, Big N auditor, number of years that a firm was audited by the same auditor, net operating assets (with dependent variable being AEM, and Herfindahl–Hirschman index (with dependent variable being REM. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm-year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

**# Table 12
global control_variables_aem size bm roa lev firm_age rank au_years oa_scale /*xrd_int*/
global control_variables_rem size bm roa lev firm_age rank au_years hhi_sale /*xrd_int*/
use "$output\final_data_47662", replace
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

esttab regression1 regression2 regression3 regression4 regression5 using "$output\table12.rtf", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0)) ///
mtitles("AEM (performance-adj.)" "AEM (modified Jone's)" "AEM Rank" "REM" "REM Rank") nonumbers collabels(none) label keep(visib_PM2_5) ///
title("The Effect of Visibility on Earnings Management: Using Actual Air Pollution Measures Panel A: Using Visibility Explained by PM 2.5 and Residual")  

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

esttab regression1 regression2 regression3 regression4 regression5 using "$output\table12.rtf", append  ///
label nomtitles nonumbers keep(visib_res) 

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

esttab regression1 regression2 regression3 regression4 regression5 using "$output\table12.rtf", append ///
nomtitles collabels(none) label ///
title("Using PM 2.5 Instead of Visibility")  