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

**# Reviewer 2 Comment 7 Event
/*
1. **July 5, 2011 - Phoenix, Arizona**
   - A massive dust storm known as a haboob struck Phoenix, Arizona, resulting from strong outflow boundaries from storms initiated southeast of Tucson [(Raman, Arellano, & Brost, 2014)]
https://www.sciencedirect.com/science/article/abs/pii/S1352231014001228?via%3Dihub


2. **April 12, 2000** year too early
   - A severe dust storm driven mainly by a passing cold front was analyzed in detail [(Wang Bao-jian, 2001)]
Bao-jian, W. (2001). A Meso-micro scale synoptic analysis of strong dust storm on 12 April 2000. Gansu Meteorology.
The strong dust storm on 12 April 2000 was mainly a passing cold front, with mesoscale system turbulence strengthening and stimulating it.

3. **December 15, 2003 - Texas and New Mexico** year too early
   - A major dust event occurred in the Chihuahuan Desert region, covering Texas and New Mexico, characterized by multiple small-scale sources merging to form a regional-scale dust storm [(Lee et al., 2009)]
https://www.sciencedirect.com/science/article/abs/pii/S0169555X08002717?via%3Dihub

The 2003 dust storm in southwestern North America was mainly caused by cropland and rangeland, with microscale variations in erodibility or meteorological factors potentially determining actual dust emission points.

4. **April 2008 and March 2009 - Salt Lake City, Utah**
   - Significant dust event days occurred, driven by approaching mid-level troughs which caused dust outbreaks and storms. Strengthening cyclonic systems in the region were primary producers of these dust events [(Hahnenberger & Nicoll, 2012)]
https://www.sciencedirect.com/science/article/abs/pii/S1352231012005808?via%3Dihub
*/
	
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

*Event 1
	capture drop postTreat dust
gen postTreat = 1 if fyear >= 2011
replace postTreat = 0 if mi(postTreat) & fyear < 2011
gen dust = 1 if state == "AZ" /*& city == "Phoenix"*/
replace dust = 0 if mi(dust)

egen city_id = group(city)

reghdfe visib postTreat dust c.postTreat#c.dust fog if fyear >= 2009 & fyear <= 2014, absorb(fyear city_id) vce(cluster i.city_id#i.fyear)

replace state = "PA" if city == "Canonsburg" & mi(state)
replace state = "OH" if city == "Columbus" & mi(state)
replace state = "TX" if city == "Houston" & mi(state)
replace state = "CA" if city == "Los Angeles" & mi(state)
replace state = "VA" if city == "McLean" & mi(state)
replace state = "NY" if city == "New York" & mi(state)
replace state = "NJ" if city == "Secaucus" & mi(state)
replace state = "CA" if city == "Sunnyvale" & mi(state)
replace state = "GA" if city == "Suwanee" & mi(state)
replace state = "FL" if city == "West Palm Beach" & mi(state)
replace state = "NY" if city == "White Plains" & mi(state)
count if mi(state)

*Event 2
	capture drop postTreat dust
gen postTreat = 1 if fyear >= 2000
replace postTreat = 0 if mi(postTreat) & fyear < 2000
gen dust = 1 if state == "TX" | state == "NM" //Texas & New Mexico
replace dust = 0 if mi(dust)

reghdfe visib postTreat dust c.postTreat#c.dust fog if fyear >= 2009 & fyear <= 2014, absorb(fyear city_id) vce(cluster i.city_id#i.fyear)

*==================== Regression (Signed) =============================
use "$output\final_data_47662", replace

global control_variables_aem size bm roa lev firm_age rank au_years oa_scale /*xrd_int*/
global control_variables_rem size bm roa lev firm_age rank au_years hhi_sale /*xrd_int*/

* Event 4
	capture drop postTreat dust
gen postTreat = 1 if fyear >= 2008
replace postTreat = 0 if mi(postTreat) & fyear < 2008
gen dust = 1 if state == "UT" //UT
replace dust = 0 if mi(dust)

egen city_id = group(city)

reghdfe visib postTreat dust c.postTreat#c.dust fog if fyear <= 2014, absorb(fyear city_id) vce(cluster i.city_id#i.fyear)

reg visib postTreat dust c.postTreat#c.dust fog i.fyear i.city_id if fyear <= 2014, vce(robust)

predict visib_hat, xb

	eststo clear
eststo regression1: ivregress 2sls dacck (visib = c.postTreat#c.dust) postTreat dust fog $control_variables_aem i.fyear i.ff_48 if fyear <= 2014, vce(robust)
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
		estat firststage
		matrix FS = r(singleresults)
		estadd scalar fs = FS[1, 4]

estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
	
eststo regression2: reghdfe dac visib_hat $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression3: reghdfe rank_dac visib_hat $control_variables_aem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression4: ivregress 2sls rem (visib = c.postTreat#c.dust)postTreat dust fog $control_variables_rem i.fyear i.ff_48, vce(robust)
summarize rem
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
		estat firststage
		matrix FS = r(singleresults)
		estadd scalar fs = FS[1, 4]

estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression5: reghdfe rank_rem visib_hat $control_variables_rem, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 using "$output\table4_dust_hat.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
mtitles("\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jone's')}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") collabels(none) booktabs label scalar(ymean) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management}\label{tab: table4}\tabcolsep=0.1cm\scalebox{0.9}{\begin{tabular}{lccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: The dependent variables are indicated at the top of each column. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variables in columns (1)-(3) are: a firms' accrual earnings management calculated using the performance-adjusted method, a firm's accrual earnings management calculated using the modified Jone's method, and the rank of the firm's accrual earnings management (modified Jone's), respectively. The dependent variables in columns (4)-(5) are: a firm's real earnings management, and the rank of the firm's real earnings management, respectively. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm-year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

**# Table 5 main table
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

esttab regression1 regression2 regression3 regression4 regression5 using "$output\results_wind_speed.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
mtitles("\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jone's')}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") collabels(none) booktabs label scalar(ymean) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management, among Knowledge-intensive Industries}\label{tab: table4}\tabcolsep=0.1cm\scalebox{0.9}{\begin{tabular}{lccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: The dependent variables are indicated at the top of each column. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variables in columns (1)-(3) are: a firms' accrual earnings management calculated using the performance-adjusted method, a firm's accrual earnings management calculated using the modified Jone's method, and the rank of the firm's accrual earnings management (modified Jone's), respectively. The dependent variables in columns (4)-(5) are: a firm's real earnings management, and the rank of the firm's real earnings management, respectively. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm-year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

**# Reviewer 2 Comment 7: Wind speed with OLD CONTROLS
global control_variables_aem size bm roa lev firm_age rank au_years oa_scale /*xrd_int*/
global control_variables_rem size bm roa lev firm_age rank au_years hhi_sale /*xrd_int*/

use "$output\final_data_47662", replace
	eststo clear
eststo regression1: ivregress 2sls dacck (visib = gust) $control_variables_aem i.fyear ff_48, vce(robust)
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
		estat firststage
		matrix FS = r(singleresults)
		estadd scalar fs = FS[1, 4]
*boottest visib, weight(webb)
*estadd scalar wild = r(p)

estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression2:  ivregress 2sls dac (visib = gust) $control_variables_aem i.fyear ff_48, vce(robust)
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
		estat firststage
		matrix FS = r(singleresults)
		estadd scalar fs = FS[1, 4]
*boottest visib, weight(webb)
*estadd scalar wild = r(p)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression3:  ivregress 2sls rank_dac (visib = gust) $control_variables_aem i.fyear ff_48, vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rank_dac
estadd scalar ymean = r(mean)
		estat firststage
		matrix FS = r(singleresults)
		estadd scalar fs = FS[1, 4]
*boottest visib, weight(webb)
*estadd scalar wild = r(p)

estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression4: ivregress 2sls rem (visib = gust) $control_variables_rem i.fyear ff_48, vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
		estat firststage
		matrix FS = r(singleresults)
		estadd scalar fs = FS[1, 4]
*boottest visib, weight(webb)
*estadd scalar wild = r(p)

estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression5: ivregress 2sls rank_rem (visib = gust) $control_variables_rem i.fyear ff_48, vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rank_rem
estadd scalar ymean = r(mean)
		estat firststage
		matrix FS = r(singleresults)
		estadd scalar fs = FS[1, 4]
*boottest visib, weight(webb)
*estadd scalar wild = r(p)

estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 using "$output\results_wind_speed.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
mtitles("\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jone's')}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") collabels(none) booktabs label scalar(ymean) ///
stats(yearfe indfe N fs ymean /*wild*/ ar2, fmt(0 2 2) labels("Year FE" "Industry FE" "N" "First Stage F" "Control mean" /*"Wild cluster p-value"*/ "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{TheInstrumental Variable (IV-2SLS) Results of Visibility on Earnings Management}\label{tab: table4}\tabcolsep=0.1cm\scalebox{0.9}{\begin{tabular}{lccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table presents the IV-2SLS results of visibility on earnings management, where visibility is instrumented by average wind speed. The dependent variables are indicated at the top of each column. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variables in columns (1)-(3) are: a firms' accrual earnings management calculated using the performance-adjusted method, a firm's accrual earnings management calculated using the modified Jone's method, and the rank of the firm's accrual earnings management (modified Jone's), respectively. The dependent variables in columns (4)-(5) are: a firm's real earnings management, and the rank of the firm's real earnings management, respectively. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm-year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

**# Reviewer 2 Comment 7: Wind speed with NEW CONTROLS
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

label var grow "Sales growth"
label var loss "Loss"

gen lit = 1 if (sic >= 2833 & sic <= 2836) | (sic >= 3570 & sic <= 3577) | (sic >= 3600 & sic <=3674) | (sic >= 5200 & sic <= 5961) | (sic >= 7370 & sic <= 7379) | (sic >= 8731 & sic <= 8734)
replace lit = 0 if mi(lit) & !mi(sic)

label var lit "Litigious"
replace InstOwn_Perc = 0 if mi(InstOwn_Perc)

**# instruments: wdsp gust mxspd
	eststo clear
eststo regression1: ivregress 2sls dacck (visib = wdsp gust mxspd) $control_variables_aem i.fyear i.ff_48, vce(robust)
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
		estat firststage
		matrix FS = r(singleresults)
		estadd scalar fs = FS[1, 4]
*boottest visib, weight(webb)
*estadd scalar wild = r(p)

estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression2:  ivregress 2sls dac (visib = wdsp gust mxspd) $control_variables_aem i.fyear ff_48, vce(robust)
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
		estat firststage
		matrix FS = r(singleresults)
		estadd scalar fs = FS[1, 4]
*boottest visib, weight(webb)
*estadd scalar wild = r(p)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression3:  ivregress 2sls rank_dac (visib = wdsp gust mxspd) $control_variables_aem i.fyear i.ff_48, vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rank_dac
estadd scalar ymean = r(mean)
		estat firststage
		matrix FS = r(singleresults)
		estadd scalar fs = FS[1, 4]
*boottest visib, weight(webb)
*estadd scalar wild = r(p)

estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression4: ivregress 2sls rem (visib = wdsp gust mxspd) $control_variables_rem i.fyear i.ff_48, vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
		estat firststage
		matrix FS = r(singleresults)
		estadd scalar fs = FS[1, 4]
*boottest visib, weight(webb)
*estadd scalar wild = r(p)

estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression5: ivregress 2sls rank_rem (visib = wdsp gust mxspd) $control_variables_rem i.fyear i.ff_48, vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rank_rem
estadd scalar ymean = r(mean)
		estat firststage
		matrix FS = r(singleresults)
		estadd scalar fs = FS[1, 4]
*boottest visib, weight(webb)
*estadd scalar wild = r(p)

estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 using "$output\results_wind_speed_NEWCONTROLS.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) keep(visib size bm roa lev firm_age rank au_years oa_scale loss salesgrowth lit InstOwn_Perc stockreturn sale_sd _cons) ///
mtitles("\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jone's')}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") collabels(none) booktabs label scalar(ymean) ///
stats(yearfe indfe N fs ymean /*wild*/ ar2, fmt(0 2 2) labels("Year FE" "Industry FE" "N" "First Stage F" "Control mean" /*"Wild cluster p-value"*/ "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{TheInstrumental Variable (IV-2SLS) Results of Visibility on Earnings Management}\label{tab: table4}\tabcolsep=0.1cm\scalebox{0.9}{\begin{tabular}{lccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table presents the IV-2SLS results of visibility on earnings management, where visibility is instrumented by average wind speed (wdsp), max wind speed (mxspd), and gust (gust). The dependent variables are indicated at the top of each column. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variables in columns (1)-(3) are: a firms' accrual earnings management calculated using the performance-adjusted method, a firm's accrual earnings management calculated using the modified Jone's method, and the rank of the firm's accrual earnings management (modified Jone's), respectively. The dependent variables in columns (4)-(5) are: a firm's real earnings management, and the rank of the firm's real earnings management, respectively. The control variables include: firm size, book-to-market ratio, return on assets, leverage ratio, firm age, Big N auditor, number of years that a firm was audited by the same auditor, sale loss, sale growth, board independence, litigious industry, institutional ownership, stock return, 3-year rolling standard deviation of sales, REM (for AEM), AEM (for REM), net operating assets (with dependent variable being AEM, and Herfindahl–Hirschman index (with dependent variable being REM. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm-year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

**# instruments: wdsp 
eststo clear
eststo regression1: ivregress 2sls dacck (visib = wdsp) $control_variables_aem i.fyear i.ff_48, vce(robust)
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
		estat firststage
		matrix FS = r(singleresults)
		estadd scalar fs = FS[1, 4]
*boottest visib, weight(webb)
*estadd scalar wild = r(p)

estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression2:  ivregress 2sls dac (visib = wdsp) $control_variables_aem i.fyear ff_48, vce(robust)
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
		estat firststage
		matrix FS = r(singleresults)
		estadd scalar fs = FS[1, 4]
*boottest visib, weight(webb)
*estadd scalar wild = r(p)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression3:  ivregress 2sls rank_dac (visib = wdsp) $control_variables_aem i.fyear i.ff_48, vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rank_dac
estadd scalar ymean = r(mean)
		estat firststage
		matrix FS = r(singleresults)
		estadd scalar fs = FS[1, 4]
*boottest visib, weight(webb)
*estadd scalar wild = r(p)

estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression4: ivregress 2sls rem (visib = wdsp) $control_variables_rem i.fyear i.ff_48, vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
		estat firststage
		matrix FS = r(singleresults)
		estadd scalar fs = FS[1, 4]
*boottest visib, weight(webb)
*estadd scalar wild = r(p)

estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression5: ivregress 2sls rank_rem (visib = wdsp) $control_variables_rem i.fyear i.ff_48, vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rank_rem
estadd scalar ymean = r(mean)
		estat firststage
		matrix FS = r(singleresults)
		estadd scalar fs = FS[1, 4]
*boottest visib, weight(webb)
*estadd scalar wild = r(p)

estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 using "$output\results_wind_speed_wdsp_NEWCONTROLS.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) keep(visib size bm roa lev firm_age rank au_years oa_scale loss salesgrowth lit InstOwn_Perc stockreturn sale_sd _cons) ///
mtitles("\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jone's')}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") collabels(none) booktabs label scalar(ymean) ///
stats(yearfe indfe N fs ymean /*wild*/ ar2, fmt(0 2 2) labels("Year FE" "Industry FE" "N" "First Stage F" "Control mean" /*"Wild cluster p-value"*/ "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{TheInstrumental Variable (IV-2SLS) Results of Visibility on Earnings Management}\label{tab: table4}\tabcolsep=0.1cm\scalebox{0.9}{\begin{tabular}{lccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table presents the IV-2SLS results of visibility on earnings management, where visibility is instrumented by average wind speed (wdsp). The dependent variables are indicated at the top of each column. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variables in columns (1)-(3) are: a firms' accrual earnings management calculated using the performance-adjusted method, a firm's accrual earnings management calculated using the modified Jone's method, and the rank of the firm's accrual earnings management (modified Jone's), respectively. The dependent variables in columns (4)-(5) are: a firm's real earnings management, and the rank of the firm's real earnings management, respectively. The control variables include: firm size, book-to-market ratio, return on assets, leverage ratio, firm age, Big N auditor, number of years that a firm was audited by the same auditor, sale loss, sale growth, board independence, litigious industry, institutional ownership, stock return, 3-year rolling standard deviation of sales, REM (for AEM), AEM (for REM), net operating assets (with dependent variable being AEM, and Herfindahl–Hirschman index (with dependent variable being REM. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm-year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

**# instruments: mxspd
eststo clear
eststo regression1: ivregress 2sls dacck (visib = mxspd) $control_variables_aem i.fyear i.ff_48, vce(robust)
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
		estat firststage
		matrix FS = r(singleresults)
		estadd scalar fs = FS[1, 4]
*boottest visib, weight(webb)
*estadd scalar wild = r(p)

estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression2:  ivregress 2sls dac (visib = mxspd) $control_variables_aem i.fyear ff_48, vce(robust)
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
		estat firststage
		matrix FS = r(singleresults)
		estadd scalar fs = FS[1, 4]
*boottest visib, weight(webb)
*estadd scalar wild = r(p)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression3:  ivregress 2sls rank_dac (visib = mxspd) $control_variables_aem i.fyear i.ff_48, vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rank_dac
estadd scalar ymean = r(mean)
		estat firststage
		matrix FS = r(singleresults)
		estadd scalar fs = FS[1, 4]
*boottest visib, weight(webb)
*estadd scalar wild = r(p)

estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression4: ivregress 2sls rem (visib = mxspd) $control_variables_rem i.fyear i.ff_48, vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
		estat firststage
		matrix FS = r(singleresults)
		estadd scalar fs = FS[1, 4]
*boottest visib, weight(webb)
*estadd scalar wild = r(p)

estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression5: ivregress 2sls rank_rem (visib = mxspd) $control_variables_rem i.fyear i.ff_48, vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rank_rem
estadd scalar ymean = r(mean)
		estat firststage
		matrix FS = r(singleresults)
		estadd scalar fs = FS[1, 4]
*boottest visib, weight(webb)
*estadd scalar wild = r(p)

estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 using "$output\results_wind_speed_mxspd_NEWCONTROLS.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) keep(visib size bm roa lev firm_age rank au_years oa_scale loss salesgrowth lit InstOwn_Perc stockreturn sale_sd _cons) ///
mtitles("\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jone's')}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") collabels(none) booktabs label scalar(ymean) ///
stats(yearfe indfe N fs ymean /*wild*/ ar2, fmt(0 2 2) labels("Year FE" "Industry FE" "N" "First Stage F" "Control mean" /*"Wild cluster p-value"*/ "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{TheInstrumental Variable (IV-2SLS) Results of Visibility on Earnings Management}\label{tab: table4}\tabcolsep=0.1cm\scalebox{0.9}{\begin{tabular}{lccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table presents the IV-2SLS results of visibility on earnings management, where visibility is instrumented by max wind speed (mxspd). The dependent variables are indicated at the top of each column. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variables in columns (1)-(3) are: a firms' accrual earnings management calculated using the performance-adjusted method, a firm's accrual earnings management calculated using the modified Jone's method, and the rank of the firm's accrual earnings management (modified Jone's), respectively. The dependent variables in columns (4)-(5) are: a firm's real earnings management, and the rank of the firm's real earnings management, respectively. The control variables include: firm size, book-to-market ratio, return on assets, leverage ratio, firm age, Big N auditor, number of years that a firm was audited by the same auditor, sale loss, sale growth, board independence, litigious industry, institutional ownership, stock return, 3-year rolling standard deviation of sales, REM (for AEM), AEM (for REM), net operating assets (with dependent variable being AEM, and Herfindahl–Hirschman index (with dependent variable being REM. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm-year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

**# instruments: gust
eststo clear
eststo regression1: ivregress 2sls dacck (visib = gust) $control_variables_aem i.fyear i.ff_48, vce(robust)
estadd scalar ar2 = e(r2_a)
summarize dacck
estadd scalar ymean = r(mean)
		estat firststage
		matrix FS = r(singleresults)
		estadd scalar fs = FS[1, 4]
*boottest visib, weight(webb)
*estadd scalar wild = r(p)

estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression2:  ivregress 2sls dac (visib = gust) $control_variables_aem i.fyear ff_48, vce(robust)
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
		estat firststage
		matrix FS = r(singleresults)
		estadd scalar fs = FS[1, 4]
*boottest visib, weight(webb)
*estadd scalar wild = r(p)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression3:  ivregress 2sls rank_dac (visib = gust) $control_variables_aem i.fyear i.ff_48, vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rank_dac
estadd scalar ymean = r(mean)
		estat firststage
		matrix FS = r(singleresults)
		estadd scalar fs = FS[1, 4]
*boottest visib, weight(webb)
*estadd scalar wild = r(p)

estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression4: ivregress 2sls rem (visib = gust) $control_variables_rem i.fyear i.ff_48, vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
		estat firststage
		matrix FS = r(singleresults)
		estadd scalar fs = FS[1, 4]
*boottest visib, weight(webb)
*estadd scalar wild = r(p)

estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression5: ivregress 2sls rank_rem (visib = gust) $control_variables_rem i.fyear i.ff_48, vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rank_rem
estadd scalar ymean = r(mean)
		estat firststage
		matrix FS = r(singleresults)
		estadd scalar fs = FS[1, 4]
*boottest visib, weight(webb)
*estadd scalar wild = r(p)

estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 using "$output\results_wind_speed_gust_NEWCONTROLS.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) keep(visib size bm roa lev firm_age rank au_years oa_scale loss salesgrowth lit InstOwn_Perc stockreturn sale_sd _cons) ///
mtitles("\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jone's')}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") collabels(none) booktabs label scalar(ymean) ///
stats(yearfe indfe N fs ymean /*wild*/ ar2, fmt(0 2 2) labels("Year FE" "Industry FE" "N" "First Stage F" "Control mean" /*"Wild cluster p-value"*/ "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{TheInstrumental Variable (IV-2SLS) Results of Visibility on Earnings Management}\label{tab: table4}\tabcolsep=0.1cm\scalebox{0.9}{\begin{tabular}{lccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table presents the IV-2SLS results of visibility on earnings management, where visibility is instrumented by gust (gust). The dependent variables are indicated at the top of each column. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variables in columns (1)-(3) are: a firms' accrual earnings management calculated using the performance-adjusted method, a firm's accrual earnings management calculated using the modified Jone's method, and the rank of the firm's accrual earnings management (modified Jone's), respectively. The dependent variables in columns (4)-(5) are: a firm's real earnings management, and the rank of the firm's real earnings management, respectively. The control variables include: firm size, book-to-market ratio, return on assets, leverage ratio, firm age, Big N auditor, number of years that a firm was audited by the same auditor, sale loss, sale growth, board independence, litigious industry, institutional ownership, stock return, 3-year rolling standard deviation of sales, REM (for AEM), AEM (for REM), net operating assets (with dependent variable being AEM, and Herfindahl–Hirschman index (with dependent variable being REM. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm-year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

**# Reviewer 2 Comment 7: Event
global control_variables_aem fog size bm roa lev firm_age rank au_years oa_scale /*xrd_int*/ loss salesgrowth /*Boardindependence*/ /*lit*/ InstOwn_Perc_D stockreturn sale_sd rem

global control_variables_rem fog size bm roa lev firm_age rank au_years hhi_sale /*xrd_int*/ loss salesgrowth /*Boardindependence*/ /*lit*/ InstOwn_Perc_D stockreturn sale_sd dac

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

label var salesgrowth "Sales growth"
label var loss "Loss"

gen lit = 1 if (sic >= 2833 & sic <= 2836) | (sic >= 3570 & sic <= 3577) | (sic >= 3600 & sic <=3674) | (sic >= 5200 & sic <= 5961) | (sic >= 7370 & sic <= 7379) | (sic >= 8731 & sic <= 8734)
replace lit = 0 if mi(lit) & !mi(sic)

label var lit "Litigious"
replace InstOwn_Perc = 0 if mi(InstOwn_Perc)

drop if fyear >= 2007 & fyear <= 2011

gen post = (fyear >= 2012) if !mi(fyear)

sum InstOwn_Perc, d
local median = r(p50)
gen InstOwn_Perc_D = (InstOwn_Perc >= `median') if !mi(InstOwn_Perc)

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
mtitles("Visibility" "\makecell{AEM \\ (performance-adj.)}" "\makecell{AEM \\ (modified Jone's')}" "\makecell{AEM \\ Rank}" "REM" "\makecell{REM \\ Rank}") collabels(none) booktabs label scalar(ymean) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Clean Air Effect on AEM and REM}\label{tab: table4}\tabcolsep=0.1cm\scalebox{0.9}{\begin{tabular}{lcccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: The dependent variables are indicated at the top of each column. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variable in column (1) is visibility. The dependent variables in columns (2)-(4) are: a firms' accrual earnings management calculated using the performance-adjusted method, a firm's accrual earnings management calculated using the modified Jone's method, and the rank of the firm's accrual earnings management (modified Jone's), respectively. The dependent variables in columns (5)-(6) are: a firm's real earnings management, and the rank of the firm's real earnings management, respectively. Control variables include: firm size, book-to-market ratio, return on assets, leverage ratio, firm age, Big N auditor, number of years that a firm was audited by the same auditor, sale loss, sale growth, institutional ownership, stock return, 3-year rolling standard deviation of sales, REM (for AEM), AEM (for REM), net operating assets (with dependent variable being AEM, and Herfindahl–Hirschman index (with dependent variable being REM. Industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm-year. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

**# Reviewer 1 Comment 2: Cloud cover

