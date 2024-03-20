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


use "$output\convk.dta", replace
keep fyear lpermno dacck
tempfile convk
save `convk', replace

global summ_vars dacck dac rank_dac rem rank_rem stdz_rem d_cfo_neg rank_d_cfo_neg d_prod rank_d_prod ///
d_discexp_neg rank_d_discexp_neg size bm roa lev firm_age rank au_years /*<--tenure*/ oa_scale hhi_sale cover sale /*<--noa*/ /*xrd_int */ /*cycle*/
global control_variables_aem size bm roa lev firm_age rank au_years oa_scale /*xrd_int*/
global control_variables_rem size bm roa lev firm_age rank au_years hhi_sale /*xrd_int*/

use "$output\OLD DOCUMENTS\final_data_10883.dta", replace

hhi5 sale, by(ff_48 fyear) //hhi_sale
label var hhi_sale "HHI index"		

	capture drop _merge
merge 1:1 lpermno fyear using `convk'	

label var dacck "AEM (performance-adjusted)"

keep if _merge == 1 | _merge == 3
drop _merge

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
esttab obs Mean std p25 p50 p75 using "$output\summ_stats_firm_10883.tex", fragment  ///
label cells("count(pattern(1 0 0 0 0 0)) mean(pattern(0 1 0 0 0 0) fmt(3)) sd(pattern(0 0 1 0 0 0) fmt(3)) p25(pattern(0 0 0 1 0 0) fmt(3)) p50(pattern(0 0 0 0 1 0) fmt(3)) p75(pattern(0 0 0 0 0 1) fmt(3))") noobs  ///
nonumbers replace booktabs collabels(none) mtitles("N" "Mean" "Std. Dev." "Bottom 25\%" "Median" "Top 25\%") ///
prehead("\begin{table}\begin{center}\caption{Summary Statistics of Firm Characteristics(Three-month Exposure)}\label{tab: summstats1}\tabcolsep=0.1cm\scalebox{0.67}{\begin{tabular}{lcccccc}\toprule")  ///
postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table reports the descriptive statistics of firm-level characteristics for 10,883 firm-year-station observations from 2003 to 2017. Firm characteristics are obtained from Compustat and I/B/E/S data. We restrict the sample to be within a year before the actual period end date of each firm's financial report. The characteristics include the following: $AEM$ (performance-adjusted) is computed using the cross-sectional performance-adjusted modified Jones model as in Kothari et al.(2005); $AEM$ (modified Jone's) is calculated following Dechow (1995); $AEM \ Rank$ denotes the rank of $AEM (modified Jone's)$ for the year and industry;  REM, the aggregate measure of real earnings management, is the sum of $REM_{CFO}$, $REM_{PROD}$, and $REM_{DISX}$, where $REM_{CFO}$ and $REM_{DISX}$ are the negative values of discretionary cash flows and discretionary expenses, respectively; $REM \ Rank$ represents the rank of $REM$ for the year and industry;  $REM \ Variability$ indicates the standard deviation of $REM$ across the five consecutive years prior to the firm's actual period end date; $REM_{CFO}$ denotes abnormal cash flows from operations, which are measured as the deviation of the firm's actual cash flows from the normal level of discretionary cash flows as are predicted using the corresponding industry-year regression; $REM_{PROD}$ denotes abnormal production costs, and is measured as the deviation of the firm's actual production costs from the normal level of production costs as are predicted using the corresponding industry-year regression; $REM_{DISX}$, discretionary expenses, are measured as the deviation of the firm's actual expenses from the normal level of discretionary expenses as are predicted using the corresponding industry-year regression. $Size$, the firm's size, is calculated as the logged value of the firm's total assets in the current fiscal year; $BM$, the book-to-market ratio in the current fiscal year, is calculated as the ratio of the firm's book value of equity and the market value of equity; $ROA$ is the ratio of the firm's income before extraordinary items and total assets; $Leverage$, the leverage ratio in the current fiscal year, is defined as the ratio between the firm's total liabilities and total assets;  $Firm \ Age$, the age of the firm, is defined as the number of years starting from the first time when the firm's stock returns are reported in the monthly stock files of the Center for Research in Security Prices (CRSP); $Big \ N$ is an indicator that takes 1 if the firm was audited by a Big N CPA firm, and 0 otherwise;  $Auditor \ Tenure$ denotes the number of years that the firm was audited by a same auditor; $NOA$ is the ratio between the firm's net operating assets at the beginning of the year and lagged sales during the corresponding industry-year (net operating assets are calculated using shareholders' equity less cash and marketable securities, plus total debt); $HHI$ refers to Herfindahl–Hirschman Index; $Number \ of \ Analysts \ Following$, the number of analysts following the firm in the current fiscal year, is obtained from I/B/E/S; $Sales$ refers to the sales of the firm in the current fiscal year. Standard deviations are in parentheses. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}")  

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
prehead("\begin{table}\begin{center}\caption{Summary Statistics of Weather-related Characteristics(Three-month Exposure)}\label{tab: summstats2}\tabcolsep=0.1cm\scalebox{0.67}{\begin{tabular}{lcccccc}\toprule")  ///
postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table reports the descriptive statistics of weather-related characteristics for 10,883 firm-year-station observations in the three months prior to each firm's actual period end date ranging from 2003 to 2017. Weather-related characterstics are: temp, mean temperature for the day in degrees Fahrenheit; dewp, mean dew point for the day in degrees Fahrenheit to tenths; slp, mean sea level pressure for the day in millibars to tenths; visib, mean visibility for the day in millibars to tenths; wdsp, mean wind speed for the day in knots to tenths; gust, maximum wind gust reported for the day in knots to tenths; mxspd, maximum sustained wind speed reported for the day in knots to tenths; prcp, total precipitation (rain and/or melted snow) reported during the day in inches and hundredths; sndp, snow depth in inches to tenths, and will be the last report for the day if reported more than once; max, maximum temperature reported during the day in Fahrenheit; min, minimum temperature reported during the day in Fahrenheit; rain, an indicator that takes 1 during the day of rain or drizzle; fog, an indicator that takes 1 during the day of fog; snow, an indicator that takes 1 during the day of snow or ice pellets; thunder, an indicator that takes 1 during the day of thunder; hail, an indicator during the day of hail; tornado, an indicator that takes 1 during the day of tornado or funnel cloud. Standard deviations are in parentheses. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

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
mtitles("\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jone's')}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") collabels(none) booktabs label scalar(ymean) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management(Three-month Exposure)}\label{tab: table4}\tabcolsep=0.1cm\scalebox{0.9}{\begin{tabular}{lccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: The dependent variables are indicated at the top of each column. Visibility refers to the visibility that is recorded by the firm's closest NOAA weather station during the three months prior to each firm's actual period end date. The dependent variables in columns (1)-(3) are: a firm's accrual earnings management calculated using the performance-adjusted model, a firm's accrual earnings management calculated using the modified Jone's model, and the rank of the firm's accrual earnings management (modified Jone's), respectively. The dependent variables in columns (4)-(5) are: a firm's real earnings management and the rank of the firm's real earnings management, respectively. A description of all variables can be found in Table \ref{tab: variabledescriptions}. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm-year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

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
prehead("\begin{table}\begin{center}\caption{Summary Statistics of Firm Characteristics(One-year Exposure)}\label{tab: summstatsOneYear}\tabcolsep=0.1cm\scalebox{0.67}{\begin{tabular}{lcccccc}\toprule")  ///
postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table reports the descriptive statistics of firm-level characteristics for 11,283 firm-year-station observations from 2003 to 2017. Firm characteristics are obtained from Compustat and I/B/E/S data. We restrict the sample to be within a year before the actual period end date of each firm's financial report. The characteristics include the following: $AEM$ (performance-adjusted) is computed using the cross-sectional performance-adjusted modified Jones model as in Kothari et al.(2005); $AEM$ (modified Jone's) is calculated following Dechow (1995); $AEM \ Rank$ denotes the rank of $AEM (modified Jone's)$ for the year and industry;  REM, the aggregate measure of real earnings management, is the sum of $REM_{CFO}$, $REM_{PROD}$, and $REM_{DISX}$, where $REM_{CFO}$ and $REM_{DISX}$ are the negative values of discretionary cash flows and discretionary expenses, respectively; $REM \ Rank$ represents the rank of $REM$ for the year and industry; $REM \ Variability$ indicates the standard deviation of $REM$ across the five consecutive years prior to the firm's actual period end date; $REM_{CFO}$ denotes abnormal cash flows from operations, which are measured as the deviation of the firm's actual cash flows from the normal level of discretionary cash flows as are predicted using the corresponding industry-year regression; $REM_{PROD}$ denotes abnormal production costs, and is measured as the deviation of the firm's actual production costs from the normal level of production costs as are predicted using the corresponding industry-year regression; $REM_{DISX}$, discretionary expenses, are measured as the deviation of the firm's actual expenses from the normal level of discretionary expenses as are predicted using the corresponding industry-year regression. $Size$, the firm's size, is calculated as the logged value of the firm's total assets in the current fiscal year; $BM$, the book-to-market ratio in the current fiscal year, is calculated as the ratio of the firm's book value of equity and the market value of equity; $ROA$ is the ratio of the firm's income before extraordinary items and total assets; $Leverage$, the leverage ratio in the current fiscal year, is defined as the ratio between the firm's total liabilities and total assets; $Firm \ Age$, the age of the firm, is defined as the number of years starting from the first time when the firm's stock returns are reported in the monthly stock files of the Center for Research in Security Prices (CRSP); $Big \ N$ is an indicator that takes 1 if the firm was audited by a Big N CPA firm, and 0 otherwise;  $Auditor \ Tenure$ denotes the number of years that the firm was audited by a same auditor; $NOA$ is the ratio between the firm's net operating assets at the beginning of the year and lagged sales during the corresponding industry-year (net operating assets are calculated using shareholders' equity less cash and marketable securities, plus total debt); $HHI$ refers to Herfindahl–Hirschman Index; $Number \ of \ Analysts \ Following$, the number of analysts following the firm in the current fiscal year, is obtained from I/B/E/S; $Sales$ refers to the sales of the firm in the current fiscal year. Standard deviations are in parentheses. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

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
prehead("\begin{table}\begin{center}\caption{Summary Statistics of Weather-related Characteristics(One-year Exposure)}\label{tab: summstatsSecond11283}\tabcolsep=0.1cm\scalebox{0.67}{\begin{tabular}{lcccccc}\toprule")  ///
postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table reports the descriptive statistics of weather-related characteristics for 11,283 firm-year-station observations in the year prior to each firm's actual period end date ranging from 2003 to 2017. Weather-related characterstics are: temp, mean temperature for the day in degrees Fahrenheit; dewp, mean dew point for the day in degrees Fahrenheit to tenths; slp, mean sea level pressure for the day in millibars to tenths; visib, mean visibility for the day in millibars to tenths; wdsp, mean wind speed for the day in knots to tenths; gust, maximum wind gust reported for the day in knots to tenths; mxspd, maximum sustained wind speed reported for the day in knots to tenths; prcp, total precipitation (rain and/or melted snow) reported during the day in inches and hundredths; sndp, snow depth in inches to tenths, and will be the last report for the day if reported more than once; max, maximum temperature reported during the day in Fahrenheit; min, minimum temperature reported during the day in Fahrenheit; rain, an indicator that takes 1 during the day of rain or drizzle; fog, an indicator that takes 1 during the day of fog; snow, an indicator that takes 1 during the day of snow or ice pellets; thunder, an indicator that takes 1 during the day of thunder; hail, an indicator during the day of hail; tornado, an indicator that takes 1 during the day of tornado or funnel cloud. Standard deviations are in parentheses. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

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
mtitles("\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jone's')}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") collabels(none) booktabs label scalar(ymean) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management(One-year Exposure)}\label{tab: table4}\tabcolsep=0.1cm\scalebox{0.9}{\begin{tabular}{lccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: The dependent variables are indicated at the top of each column. Visibility refers to the visibility that is recorded by the firm's closest NOAA weather station during the year prior to each firm's actual period end date. The dependent variables in columns (1)-(3) are: a firm's accrual earnings management calculated using the performance-adjusted model, a firm's accrual earnings management calculated using the modified Jone's model, and the rank of the firm's accrual earnings management (modified Jone's), respectively. The dependent variables in columns (4)-(5) are: a firm's real earnings management and the rank of the firm's real earnings management, respectively. A description of all variables can be found in Table \ref{tab: variabledescriptions}. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm-year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 


