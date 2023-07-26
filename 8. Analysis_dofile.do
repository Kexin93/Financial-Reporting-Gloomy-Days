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
global maindir "E:\Research材料\21. Air Pollution and Accounting\DATA"
global output "E:\Research材料\21. Air Pollution and Accounting\RESULTS"
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

*br tic cusip ncusip ibes_cusip cusip8
use "$maindir\Firm_Year_Weather", replace
* 23139 firm-year-weather observations

global control_variables size bm roa lev firm_age rank au_years oa_scale /*xrd_int*/

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
global summ_vars dac rank_dac rem rank_rem stdz_rem rank_d_cfo d_cfo d_prod rank_d_prod ///
d_discexp rank_d_discexp size bm roa lev firm_age rank au_years /*<--tenure*/ oa_scale /*<--noa*/ /*xrd_int */ /*cycle*/


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

	/*
	preserve
	* generate a unique firm data set
	bysort lpermno: gen num = _n
		keep if num == 1
		summarize num_years, d
		local median = r(p50)
	restore
	*/

	*gen tenure = (au_years > `median') if !mi(au_years)

* oa
gen oa = ceq- che -dlc- dltt // shareholders' equity - cash and marketale securities + total debt
xtset lpermno fyear
gen lsale = l1.sale
gen loa = l1.oa
gen oa_scale = loa/lsale

		/*
		gen oa_median_year =.
		forvalues x = 2003/2017{
			summarize oa_scale if fyear == `x' & !mi(oa_scale),d
			replace oa_median_year = r(p50) if fyear == `x'
		}

		gen noa = (oa_scale > oa_median_year) if !mi(oa_scale)
		*/

hhi5 sale, by(ff_48 fyear) //hhi_sale
		
/*generate KZ score*/
*xtset lpermno fyear 
gen cashflow=dp+ib
gen CF_lscaled=cashflow/l1.at
	label variable CF_lscaled "cashflow/l1.at"

/*Cash Reserve Ratio*/
/*label variable Cash_scaled "che/at Cash Reserve Ratio"*/

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

* ============ Labeling =================
label var firm_ID "firm-year ID"
label var firm_FID "firm FID = firm_ID - 1"
label var dac "AEM"
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
label var hhi_sale "HHI"
label var au_years "Auditor Tenure"
label var firm_age "Firm Age"
label var rank "Big N" //binary
label var visib "Visibility"
label var cover "Analysts Following"
label var KZ "Financial Constraint"

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

save "$output\final_data_10883", replace

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
prehead("\begin{table}\begin{center}\caption{Summary Statistics of Firm Characteristics}\label{tab: summstats1}\tabcolsep=0.1cm\scalebox{0.67}{\begin{tabular}{lcccccc}\toprule")  ///
postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table reports the descriptive statistics of firm-level characteristics for 10,883 firm-year-station observations from 2004 to 2017. Firm characteristics are obtained from Compustat and I/B/E/S data. We restrict the sample to be within 90 days before the actual period end date of each firm's financial report. The characteristics include the following: AEM, signed discretionary accruals (DA), which are computed using the cross-sectional modified Jones model as in Kothari et al.(2005); REM, the aggregate measure of real earnings management, is the sum of $REM_{CFO}$, $REM_{PROD}$, and $REM_{DISX}$, where $REM_{CFO}$ and $REM_{DISX}$ are the negative value of discretionary cash flows and discretionary expenses, respectively; $AEM \ Rank$ denotes the rank of $AEM$ for the year and industry; $REM \ Rank$ represents the rank of $REM$ for the year and industry; $REM \ Variability$ indicates the standard deviation of $REM$ across the five consecutive years prior to the firm's actual period end date; $REM_{CFO}$ denotes abnormal cash flows from operations, which are measured as the deviation of the firm's actual cash flows from the normal level of discretionary cash flows as are predicted using the corresponding industry-year regression; $REM_{PROD}$ denotes abnormal production costs, and is measured as the deviation of the firm's actual production costs from the normal level of production costs as are predicted using the corresponding industry-year regression; $REM_{DISX}$, discretionary expenses, are measured as the deviation of the firm's actual expenses from the normal level of discretionary expenses as are predicted using the corresponding industry-year regression. $Size$, the firm's size, is calculated as the logged value of the firm's total assets in the current fiscal year; $BM$, the book-to-market ratio in the current fiscal year, is calculated as the ratio of the firm's book value of equity and the market value of equity; $ROA$ is the ratio of the firm's income before extraordinary items and total assets; $Leverage$, the leverage ratio in the current fiscal year, is defined as the ratio between the firm's total liabilities and total assets; $Firm \ Age$, the age of the firm, is defined as the number of years starting from the first time when the firm’s stock returns are reported in the monthly stock files of the Center for Research in Security Prices (CRSP); $Big \ 8$ is an indicator that takes 1 if the firm was audited by a Big N CPA firm, and 0 otherwise; $Auditor \ Tenure$ denotes the number of years that the firm was audited by a same auditor; $NOA$ is the ratio between the firm's net operating assets at the beginning of the year and lagged sales during the corresponding industry-year (net operating assets are calculated using shareholders’ equity less cash and marketable securities, plus total debt); Tobin's Q denotes the market value of the firm; $Number \ of \ Analysts \ Following$, the number of analysts following the firm in the current fiscal year, is obtained from I/B/E/S; $Sales$ refers to the sales of the firm in the current fiscal year. Standard deviations are in parentheses. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 


* .rtf
esttab obs Mean std p25 p50 p75 using "$output\Word_results.rtf", ///
label cells("count(pattern(1 0 0 0 0 0)) mean(pattern(0 1 0 0 0 0) fmt(3)) sd(pattern(0 0 1 0 0 0) fmt(3)) p25(pattern(0 0 0 1 0 0) fmt(3)) p50(pattern(0 0 0 0 1 0) fmt(3)) p75(pattern(0 0 0 0 0 1) fmt(3))") noobs  ///
nonumbers replace collabels(none) mtitles("N" "Mean" "Std. Dev." "Bottom 25%" "Median" "Top 25%") ///
title("Summary Statistics")

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

global summ_vars_weather temp dewp slp visib wdsp mxspd ///
				 gust prcp sndp max min fog rain snow   ///
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
postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table reports the descriptive statistics of weather-related characteristics for 10,883 firm-year-station observations from 2004 to 2017. Weather-related characterstics are: temp, mean temperature for the day in degrees Fahrenheit to tenths; dewp, mean dew point for the day in degrees Fahrenheit to tenths; slp, mean sea level pressure for the day in millibars to tenths; visib, mean visibility for the day in millibars to tenths; wdsp, mean wind speed for the day in knots to tenths; mxspd, maximum sustained wind speed reported for the day in knots to tenths; min, minimum temperature reported during the day in Fahrenheit to tenths; fog, an indicator that takes 1 during the day of fog; rain, an indicator that takes 1 during the day of rain or drizzle; thunder, an indicator that takes 1 during the day of thunder; gust, maximum wind gust reported for the day in knots to tenths; max, maximum temperature reported during the day in Fahrenheit to tenths; prcp, total precipitation (rain and/or melted snow) reported during the day in inches and hundredths; sndp, snow depth in inches to tenths, and will be the last report for the day if reported more than once; snow, an indicator that takes 1 during the day of snow or ice pellets; hail, an indicator during the day of hail; tornado, an indicator that takes 1 during the day of tornado or funnel cloud. Standard deviations are in parentheses. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

* .rtf
esttab obs Mean std p25 p50 p75 using "$output\Word_results.rtf", ///
label cells("count(pattern(1 0 0 0 0 0)) mean(pattern(0 1 0 0 0 0) fmt(3)) sd(pattern(0 0 1 0 0 0) fmt(3)) p25(pattern(0 0 0 1 0 0) fmt(3)) p50(pattern(0 0 0 0 1 0) fmt(3)) p75(pattern(0 0 0 0 0 1) fmt(3))") noobs  ///
nonumbers append collabels(none)  nomtitles ///
title("Summary Statistics")

*========= Table 2: t-test table ========================
global summ_vars dac rank_dac rem rank_rem stdz_rem d_cfo rank_d_cfo d_prod rank_d_prod ///
d_discexp rank_d_discexp size bm roa lev firm_age rank au_years /*<--tenure*/ oa_scale /*<--noa*/ /*xrd_int */ /*cycle*/

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
posthead("\midrule") postfoot("\bottomrule\end{tabular}\end{center}\footnotesize{Notes: This table shows the univarite test of the difference between firms exposed to higher air quality and those exposed to lower air quality (defined as being lower than the median of visibility over years: 2003-2017). A description of all variables can be found in Table \ref{tab: variabledescriptions}. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

esttab allsample polluted_sample unpolluted_sample difference using "$output\Word_results.rtf", ///
append cells("mean(pattern(1 1 1 0)  fmt(3)) b(star pattern(0 0 0 1) fmt(3)) ") ///
label mtitles("All" "Polluted" "Unpolluted" "Polluted-Unpolluted") collabels(none) nonumbers ///
title("Uni-variate Test") ///
note("Notes: The independent variable polluted takes the value of 1 if visibility is below the median of visibility over years (2003-2017).")

global control_variables size bm roa lev firm_age rank au_years oa_scale /*xrd_int*/

*======== Table 3: Correlation Table ==============================
*ssc install corrtex
*asdoc correlate $summ_vars, label
corrtex $summ_vars, file(CorrTable) replace land sig /*dig(4) star(0.05)*/
* Notes: This table reports pooled Pearson correlations for the entire sample of 10,883 firm-year observations over the period 2004-2017. *Significant at the 10% level. **Significant at the 5% level. Please see Table \ref{tab: variabledescriptions} for variable descriptions.
 
*======== Summary Stats CSR =====================================
	capture drop CSR_Str
	capture drop CSR_Con
	capture drop CSR_Overall
egen CSR_Str= rowtotal(ENV_str_num COM_str_num EMP_str_num DIV_str_num PRO_str_num HUM_str_num)
	label var CSR_Str "Overall CSR Strength"
	replace CSR_Str = . if mi(ENV_str_num)
egen CSR_Con = rowtotal(ENV_con_num COM_con_num HUM_con_num EMP_con_num DIV_con_num PRO_con_num)
	label var CSR_Con "Overall CSR Concern"
	replace CSR_Con = . if mi(ENV_con_num)
gen CSR_Overall = CSR_Str - CSR_Con
	label var CSR_Overall "Overall CSR"
	replace CSR_Overall=. if mi(ENV_con_num)
	
gen CGOV_overall =  CGOV_str_num - CGOV_con_num
	label var CGOV_overall "Overall CGOV"
	label var CGOV_str_num "Overall CGOV Strength"
	label var CGOV_con_num "Overall CGOV Concern"

global summ_vars_CSR CGOV_overall CGOV_str_num CGOV_con_num
eststo summ_stats: estpost sum $summ_vars_CSR

eststo obs: estpost summarize $summ_vars_CSR

ereturn list 

eststo Mean: estpost summarize $summ_vars_CSR

ereturn list 

eststo p25: estpost summarize $summ_vars_CSR, detail

ereturn list 

eststo p50: estpost summarize $summ_vars_CSR, detail

ereturn list 

eststo p75: estpost summarize $summ_vars_CSR, detail

ereturn list 

eststo std: estpost summarize $summ_vars_CSR

ereturn list 

eststo Median: estpost summarize $summ_vars_CSR

ereturn list 

* .tex
esttab obs Mean std p25 p50 p75 using "$output\summ_stats_CSR.tex", fragment  ///
label cells("count(pattern(1 0 0 0 0 0)) mean(pattern(0 1 0 0 0 0) fmt(3)) sd(pattern(0 0 1 0 0 0) fmt(3)) p25(pattern(0 0 0 1 0 0) fmt(3)) p50(pattern(0 0 0 0 1 0) fmt(3)) p75(pattern(0 0 0 0 0 1) fmt(3))") noobs  ///
nonumbers replace booktabs collabels(none) mtitles("N" "Mean" "Std. Dev." "Bottom 25\%" "Median" "Top 25\%") ///
prehead("\begin{table}\begin{center}\caption{Summary Statistics of CSR Measures}\label{tab: summstats1}\tabcolsep=0.1cm\scalebox{0.67}{\begin{tabular}{lcccccc}\toprule")  ///
postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table reports the descriptive statistics of CSR measures for 6,234 firm-year observations from 2004 to 2013. CSR measures are obtained from MSCI ESG KLD STATS (previously named KLD). The CSR measures we focus on include the following: $Overall \ CGOV$, $\Overall \ CGOV \ Strength$, and $Overall \ CGOV \ Concern$. A description of all variables can be found in Table \ref{tab: variabledescriptions}. Standard deviations are in parentheses. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

*======== Table 13: CSR =============================
	eststo clear
eststo regression1: reghdfe CSR_Overall visib $control_variables, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize CSR_Overall
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression2: reghdfe CSR_Str visib $control_variables, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize CSR_Str
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression3: reghdfe CSR_Con visib $control_variables, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize CSR_Con
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression4: reghdfe CGOV_overall visib $control_variables, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize CGOV_overall
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression5: reghdfe CGOV_str_num visib $control_variables, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize CGOV_str_num
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression6: reghdfe CGOV_con_num visib $control_variables, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize CGOV_con_num
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 regression6 using "$output\table13.tex", replace ///
mtitles("Overall CSR" "Overall CSR Strength" "Overall CSR Concern" "Overall CGOV" "Overall CGOV Strength" "Overall CGOV Concern") collabels(none) booktabs label scalar(ymean) nonumbers ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Corporate Social Responsibility}\label{tab: table13}\tabcolsep=0.1cm\begin{tabular}{lcccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}\end{center}\\\footnotesize{Notes: The dependent variables are indicated at the top of each column. A description of all variables can be found in Table \ref{tab: variabledescriptions}. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are heteroskedastic-robust. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

*========== Table 14: visibility interacts with CSR to REM ======================== 
	eststo clear
eststo regression1: reghdfe dac visib CSR_Str c.visib#c.CSR_Str $control_variables, absorb(fyear ff_48) vce(robust) //c.?
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression2: reghdfe dac visib CSR_Con c.visib#c.CSR_Con $control_variables, absorb(fyear ff_48) vce(robust) //c.?
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression3: reghdfe rem visib CSR_Str c.visib#c.CSR_Str $control_variables, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression4: reghdfe rem visib CSR_Con c.visib#c.CSR_Con $control_variables, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

esttab regression1 regression2 regression3 regression4 using "$output\table14.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) drop($control_variables) ///
mtitles("CSR Strength" "CSR Concern" "CSR Strength" "CSR Concern") collabels(none) booktabs label scalar(ymean) order(visib CSR_Str c.visib#c.CSR_Str CSR_Con c.visib#c.CSR_Con) ///
stats(yearfe indfe firmcont N ymean ar2, fmt(0 0 0 0 2 2) labels("Year FE" "Industry FE" "Firm Controls" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management by the Degree of CSR Behaviors}\label{tab: table14}\tabcolsep=0.1cm\begin{tabular}{lcccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}\\\end{center}\footnotesize{Notes: This table reports how the effects of visibility on AEM and REMdiffer by the degree of the corporate social responsibility (CSR). A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variable in columns (1) and (2) is AEM, and the dependent variable in columns (3) and (4) is REM. Firm controls are the same as in Table \ref{tab: table4}. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are heteroskedastic-robust. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 
exit
*========== Table 15: visibility interacts with internal monitoring to REM ======================== 
	eststo clear
eststo regression1: reghdfe dac visib CGOV_str_num c.visib#c.CGOV_str_num $control_variables, absorb(fyear ff_48) vce(robust) //c.?
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression2: reghdfe dac visib CGOV_con_num c.visib#c.CGOV_con_num $control_variables, absorb(fyear ff_48) vce(robust) //c.?
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression3: reghdfe rem visib CGOV_str_num c.visib#c.CGOV_str_num $control_variables, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression4: reghdfe rem visib CGOV_con_num c.visib#c.CGOV_con_num $control_variables, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

esttab regression1 regression2 regression3 regression4 using "$output\table15.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) drop($control_variables) ///
mtitles("Good CG" "Poor CG" "Good CG" "Poor CG") collabels(none) booktabs label scalar(ymean) order(visib CGOV_str_num c.visib#c.CGOV_str_num CGOV_con_num c.visib#c.CGOV_con_num) ///
stats(yearfe indfe firmcont N ymean ar2, fmt(0 0 0 0 2 2) labels("Year FE" "Industry FE" "Firm Controls" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management by the Degree of Corporate Governance}\label{tab: table15}\tabcolsep=0.1cm\scalebox{0.9}{\begin{tabular}{lcccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table reports how the effects of visibility on AEM and REMdiffer by the degree of the internal corporate governance. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variable in columns (1) and (2) is AEM, and the dependent variable in columns (3) and (4) is REM. Firm controls are the same as in Table \ref{tab: table4}. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are heteroskedastic-robust. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

*======== Table 4: Regression (Signed) Subsample where Overall CGOV indicators are not missing =============================
	eststo clear
eststo regression1: reghdfe dac visib $control_variables if !mi(CGOV_str_num), absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression2: reghdfe rank_dac visib $control_variables if !mi(CGOV_str_num), absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rank_dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression3: reghdfe rem visib $control_variables if !mi(CGOV_str_num), absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression4: reghdfe rank_rem visib $control_variables if !mi(CGOV_str_num), absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rank_rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

esttab regression1 regression2 regression3 regression4 using "$output\table4_CGOVSubsample.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
mtitles("AEM" "AEM Rank" "REM" "REM Rank") collabels(none) booktabs label scalar(ymean) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management}\label{tab: table4cgovsubsample}\tabcolsep=0.1cm\begin{tabular}{lcccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}\end{center}\footnotesize{Notes: The dependent variables are indicated at the top of each column. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variables in columns (1)-(2) are: a firm's accrual earnings management, and the rank of the firm's accrual earnings management, respectively. The dependent variables in columns (3)-(4) are: a firm's real earnings management, and the rank of the firm's real earnings management, respectively. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are heteroskedastic-robust. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

esttab regression1 regression2 regression3 regression4 using "$output\Word_results.rtf", append ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 1 0)) ///
mtitles("AEM" "AEM Rank" "REM" "REM Rank") nonumbers collabels(none) label scalar(ymean`') ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
title("Table 4: The Effect of Visibility on Earnings Management") ///
note("Notes: The dependent variable in columns (1)-(2) is a firm's accrual earnings management; the dependent variable in columns (3)-(4) is a firm's real earnings management.")

*======== Table 16: CSR ENV is affected by Visibility =============================
gen ENV_overall =  ENV_str_num - ENV_con_num
	label var ENV_overall "Overall ENV"
	label var ENV_str_num "Overall ENV Strength"
	label var ENV_con_num "Overall ENV Concern"
	
	eststo clear
eststo regression1: reghdfe ENV_overall visib $control_variables, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize ENV_overall
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression2: reghdfe ENV_str_num visib $control_variables, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize ENV_str_num
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression3: reghdfe ENV_con_num visib $control_variables, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize ENV_con_num
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

esttab regression1 regression2 regression3 using "$output\table16.tex", replace ///
mtitles("ENV Overall" "Overall ENV Strength" "Overall ENV Concern") collabels(none) booktabs label scalar(ymean) nonumbers ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Corporate Social Responsibility}\label{tab: table16}\tabcolsep=0.1cm\begin{tabular}{lccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}\end{center}\\\footnotesize{Notes: The dependent variables are indicated at the top of each column. A description of all variables can be found in Table \ref{tab: variabledescriptions}. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are heteroskedastic-robust. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

*========== Table 17: visibility interacts with ENV CSR to REM ======================== 
	eststo clear
	xtset lpermno fyear 
	bysort lpermno: gen ENV_str_num_L = l.ENV_str_num
	bysort lpermno: gen ENV_con_num_L = l.ENV_con_num
eststo regression1: reghdfe rank_dac visib ENV_str_num_L c.visib#c.ENV_str_num_L $control_variables, absorb(fyear ff_48) vce(robust) //c.?
estadd scalar ar2 = e(r2_a)
summarize rank_dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression2: reghdfe rank_dac visib ENV_con_num_L c.visib#c.ENV_con_num_L $control_variables, absorb(fyear ff_48) vce(robust) //c.?
estadd scalar ar2 = e(r2_a)
summarize rank_dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression3: reghdfe rank_rem visib ENV_str_num_L c.visib#c.ENV_str_num_L $control_variables, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rank_rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression4: reghdfe rank_rem visib ENV_con_num_L c.visib#c.ENV_con_num_L $control_variables, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rank_rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

esttab regression1 regression2 regression3 regression4 using "$output\table17.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) drop($control_variables) ///
mtitles("Good ENV" "Poor ENV" "Good ENV" "Poor ENV") collabels(none) booktabs label scalar(ymean) order(visib ENV_str_num_L c.visib#c.ENV_str_num_L ENV_con_num_L c.visib#c.ENV_con_num_L) ///
stats(yearfe indfe firmcont N ymean ar2, fmt(0 0 0 0 2 2) labels("Year FE" "Industry FE" "Firm Controls" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management by the Degree of Environmental Performance}\label{tab: table17}\tabcolsep=0.1cm\begin{tabular}{lcccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}\\\end{center}\footnotesize{Notes: This table reports how the effects of visibility on AEM and REMdiffer by the degree of environmental performance. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variable in columns (1) and (2) is AEM, and the dependent variable in columns (3) and (4) is REM. Firm controls are the same as in Table \ref{tab: table4}. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are heteroskedastic-robust. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

*======== Table 4: Regression (Signed) =============================
	eststo clear
eststo regression1: reghdfe dac visib $control_variables, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression2: reghdfe rank_dac visib $control_variables, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression3: reghdfe rem visib $control_variables, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression4: reghdfe rank_rem visib $control_variables, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

esttab regression1 regression2 regression3 regression4 using "$output\table4.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
mtitles("AEM" "AEM Rank" "REM" "REM Rank") collabels(none) booktabs label scalar(ymean) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management}\label{tab: table4}\tabcolsep=0.1cm\scalebox{0.9}{\begin{tabular}{lcccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\\\footnotesize{Notes: The dependent variables are indicated at the top of each column. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variables in columns (1)-(2) are: a firm's accrual earnings management, and the rank of the firm's accrual earnings management, respectively. The dependent variables in columns (3)-(4) are: a firm's real earnings management, and the rank of the firm's real earnings management, respectively. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are heteroskedastic-robust. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

esttab regression1 regression2 regression3 regression4 using "$output\Word_results.rtf", append ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 1 0)) ///
mtitles("AEM" "AEM Rank" "REM" "REM Rank") nonumbers collabels(none) label scalar(ymean`') ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
title("Table 4: The Effect of Visibility on Earnings Management") ///
note("Notes: The dependent variable in columns (1)-(2) is a firm's accrual earnings management; the dependent variable in columns (3)-(4) is a firm's real earnings management.")


*======== Table 4: Regression (Absolute) =============================
sum dac rem absdac absrem rank_absdac rank_absrem 
br dac rem absdac absrem rank_absdac rank_absrem 
count if dac > 0
count if rem > 0
count if dac >= 0 & rem >= 0

preserve
keep if rem <= 0
capture drop absrem
capture drop rank_absrem
*gen absdac = abs(dac)
gen absrem = abs(rem)
*assert rem >= absrem - 0.0001 & rem <= absrem + 0.0001
*assert dac >= absdac - 0.0001 & dac <= absdac + 0.0001
*xtile rank_absdac = absdac, nq(10)
xtile rank_absrem = absrem, nq(10)
*replace rank_absdac = rank_absdac - 1
replace rank_absrem = rank_absrem - 1
	sort absdac
	br absdac rank_absdac
	sort absrem
	br absrem rank_absrem
	eststo clear
eststo regression1: reghdfe absdac  visib $control_variables, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize absdac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression2: reghdfe rank_absdac visib $control_variables, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rank_absdac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression3: reghdfe absrem visib $control_variables, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize absrem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression4: reghdfe rank_absrem visib $control_variables, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rank_absrem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

esttab regression1 regression2 regression3 regression4 using "$output\table4_abs.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
mtitles("abs. AEM" "abs. AEM Rank" "abs. REM" "abs. REM Rank") collabels(none) booktabs label scalar(ymean) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management}\label{tab: table4}\tabcolsep=0.1cm\begin{tabular}{lcccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}\end{center}\\\footnotesize{Notes: The dependent variables are indicated at the top of each column. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variables in columns (1)-(2) are: the absolute value of a firm's accrual earnings management, and the rank of the firm's absolute accrual earnings management, respectively. The dependent variables in columns (3)-(4) are: the absolute value of a firm's real earnings management, and the rank of the firm's absolute real earnings management, respectively. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are heteroskedastic-robust. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

esttab regression1 regression2 regression3 regression4 using "$output\Word_results.rtf", append ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 1 0)) ///
mtitles("abs. AEM" "abs. AEM Rank" "abs. REM" "abs. REM Rank") nonumbers collabels(none) label scalar(ymean`') ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
title("Table 4: The Effect of Visibility on Earnings Management") ///
note("Notes: The dependent variable in columns (1)-(2) is a firm's accrual earnings management; the dependent variable in columns (3)-(4) is a firm's real earnings management.")
restore
exit
*========== Table 5: Decomposition of REM ========================
eststo sales1: reghdfe d_cfo_neg visib $control_variables, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize d_cfo_neg
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo sales2: reghdfe rank_d_cfo_neg visib $control_variables, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear) 
estadd scalar ar2 = e(r2_a)
summarize rank_d_cfo_neg
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo overprod1: reghdfe d_prod visib $control_variables, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize d_prod
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo overprod2: reghdfe rank_d_prod visib $control_variables, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_d_prod
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo expenditure1: reghdfe d_discexp_neg visib $control_variables, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize d_discexp_neg
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo expenditure2: reghdfe rank_d_discexp_neg visib $control_variables, absorb(fyear ff_48) vce(cluster i.lpermno#i.fyear)
estadd scalar ar2 = e(r2_a)
summarize rank_d_discexp_neg
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

esttab sales1 sales2 overprod1 overprod2 expenditure1 expenditure2 using "$output\table5.tex", replace ///
depvars collabels(none) booktabs label scalar(ymean) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effects of Visibility on Individual REM Measures}\label{tab: table5}\tabcolsep=0.1cm\scalebox{0.78}{\begin{tabular}{lcccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: The table reports the effects of visibility on each component of the aggregate measure of real earnings management (REM). A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variables are indicated at the top of each column. The dependent variables in columns (1)-(2) are: the discretionary cash flow component of a firm's REM, and the rank of this component. To be consistent with the sign of the aggregate measure of REM, we take the negative value of discretionary cash flows. The dependent variables in columns (3)-(4) are: the production cost component of a firm's REM, and the rank of this component. The dependent variables in columns (5)-(6) are: the discretionary expense component of a firm's REM, and the rank of this component. To be consistent with the sign of the aggregate measure of REM, we take the negative value of discretionary expenses. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are heteroskedastic-robust.  *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

esttab sales1 sales2 overprod1 overprod2 expenditure1 expenditure2 using "$output\Word_results.rtf", replace ///
depvars nonumbers collabels(none) label scalar(ymean)  ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
title("Table 5: The Effects of Visibility on Individual REM Measures") 

*========= Table 6: Regression (Rank) ======================
egen city_num = group(city)

	eststo clear
eststo regression1: reghdfe rank_dac visib $control_variables, absorb(fyear city ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local cityfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression2: reghdfe rank_rem visib $control_variables, absorb(fyear city ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local cityfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression3: reghdfe rank_d_cfo_neg visib $control_variables, absorb(fyear city ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local cityfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression4: reghdfe rank_d_prod visib $control_variables, absorb(fyear city ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local cityfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression5: reghdfe rank_d_discexp_neg visib $control_variables, absorb(fyear city ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local cityfe "Yes", replace
estadd local indfe "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 using "$output\table6.tex", replace ///
mtitles("AEM Rank" "REM Rank" "Rank(Neg. Disc. CF)" "Rank(Disc. Prod.)" "Rank(Neg. Disc. Exp.)") collabels(none) booktabs label ///
scalar(ymean) stats(yearfe cityfe indfe N ymean ar2, fmt(0 0 0 0 2 2) labels("Year FE" "City FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effects of Visibility on the Rank of Earnings Management}\label{tab: table6}\tabcolsep=0.1cm\scalebox{0.8}{\begin{tabular}{lccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\\\end{center}\footnotesize{Notes: The table reports the effects of visibility on the rank of AEM, REM, and each component of the aggregate measure of real earnings management (REM), respectively. In addition to year fixed effects and industry fixed effects, city fixed effects are also included in all regressions in this table. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variables are indicated at the top of each column. The dependent variables in columns (1)-(2) are: the rank of a firm's AEM and REM, respectively. The dependent variables in columns (3)-(5) are: the rank of each component of the aggregate measure of real earnings management (REM), namely, $REM_{CFO}$, $REM_{PROD}$, and $REM_{DISX}$. Standard errors are heteroskedastic-robust. *** p < 1\%, ** p < 5\%, * p < 10\% }\end{table}") 

esttab regression1 regression2 regression3 regression4 regression5 using "$output\Word_results.rtf", append ///
mtitles("AEM Rank" "REM Rank" "Rank(Neg. Disc. CF)" "Rank(Disc. Prod.)" "Rank(Neg. Disc. Exp.)") nonumbers collabels(none) label scalar(ymean) ///
stats(yearfe cityfe indfe N ymean ar2, fmt(0 0 0 0 2 2) labels("Year FE" "City FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
title("Table 6: The Effect of Visibility on the Rank of Earnings Management") ///
note("Notes: The dependent variable in columns (1)-(2) is the rank of a firm's accrual earnings management; the dependent variable in columns (3)-(4) is the rank of a firm's real earnings management.")

* Table 7: Weather controls
* ==============================================================================
* ============================ Other weather controls ==========================
* ==============================================================================
	eststo clear
eststo regression1: reghdfe rem visib $control_variables, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression2: reghdfe rem visib $control_variables  temp, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression3: reghdfe rem visib $control_variables  dewp, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression4: reghdfe rem visib $control_variables slp, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression5: reghdfe rem visib $control_variables wdsp, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression6: reghdfe rem visib $control_variables mxspd , absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression7: reghdfe rem visib $control_variables min, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression8: reghdfe rem visib $control_variables fog, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression9: reghdfe rem visib $control_variables rain, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression10: reghdfe rem visib $control_variables temp dewp slp wdsp mxspd min fog rain, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

esttab regression1 regression2 regression3 regression4  regression5 regression6 regression7 regression8 regression9 regression10 using "$output\table7.tex", replace  drop($control_variables) ///
nomtitles collabels(none) booktabs label scalar(ymean) stats(yearfe indfe firmcont N ymean ar2, fmt(0 0 0 0 2 2) labels("Year FE" "Industry FE" "Firm Controls" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effects of Alternative Measures of Unpleasant Weather on Earnings Management}\label{tab: table7}\tabcolsep=0.1cm\scalebox{0.8}{\begin{tabular}{lcccccccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\\\end{center}\\\footnotesize{Notes: This table reports the effects of visibility on the aggregate measure of real earnings management (REM) with a series of additional weather control variables from NOAA. A description of all variables can be found in Table \ref{tab: variabledescriptions}. Column (1) is the baseline regression with no other weather controls. Column (2) includes the mean temperature reported by the firm's nearest station over the three-month period. Column (3) includes the mean dew point reported by the firm's nearest station over the three-month period. Column (4) includes the mean sea level pressure reported by the firm's nearest station over the three-month period. Column (5) includes the mean wind speed reported by the firm's nearest station over the three-month period. Column (6) includes the maximum wind speed reported by the firm's nearest station over the three-month period. Column (7) includes the minimum temprature reported by the firm's nearest station over the three-month period. Column (8) includes the mean probability of fog occurrence reported by the firm's nearest station over the three-month period. Column (9) includes the mean rain occurrence reported by the firm's nearest station over the three-month period. Column (10) includes all the above-mentioned weather controls. Firm controls are the same as in Table \ref{tab: table13}. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are heteroskedastic-robust. *** p < 1\%, ** p < 5\%, * p < 10\% }\end{table}")

esttab regression1 regression2 regression3 regression4  regression5 regression6 regression7 regression8 regression9 using "$output\Word_results.rtf", append ///
nomtitles collabels(none) label scalar(ymean)  ///
stats(yearfe indfe firmcont N ymean ar2, fmt(0 0 0 0 2 2) labels("Year FE" "Industry FE" "Firm Controls" "N" "Dep mean" "Adjusted R-sq")) ///
title("Table 7: The Effect of Visibility on Earnings Management") drop($control_variables _cons) noconstant

*========== Table 8: External Monitoring? Analyst ======================== Yes, add cover (#of analysts following) as a mechanism
	eststo clear
eststo regression1: reghdfe dac visib cover c.visib#c.cover $control_variables, absorb(fyear ff_48) vce(robust) //c.?
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression2: reghdfe rank_dac visib cover c.visib#c.cover $control_variables, absorb(fyear ff_48) vce(robust) //c.?
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression3: reghdfe rem visib cover c.visib#c.cover $control_variables, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression4: reghdfe rank_rem visib cover c.visib#c.cover $control_variables, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

esttab regression1 regression2 regression3 regression4 using "$output\table8.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) drop($control_variables) ///
mtitles("AEM" "AEM Rank" "REM" "REM Rank") collabels(none) booktabs label scalar(ymean) order(visib cover c.visib#c.cover) ///
stats(yearfe indfe firmcont N ymean ar2, fmt(0 0 0 0 2 2) labels("Year FE" "Industry FE" "Firm Controls" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management by the Degree of External Control}\label{tab: table8}\tabcolsep=0.1cm\scalebox{0.9}{\begin{tabular}{lcccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table reports how the effects of visibility on AEM, the rank of AEM, REM, and the rank of REM differ by the degree of external monitoring. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variable in column (1) is AEM, the dependent variable in column (2) is the rank of AEM, the dependent variable in column (3) is REM, and the dependent variable in column (4) is the rank of REM. Firm controls are the same as in Table \ref{tab: table4}.  Year fixed effects and industry fixed effects are included in all regressions. Standard errors are heteroskedastic-robust. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

esttab regression1 regression2 regression3 regression4 using "$output\Word_results.rtf", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 1 0)) ///
mtitles("AEM" "AEM Rank" "REM" "REM Rank") nonumbers collabels(none) label scalar(ymean) order(visib cover c.visib#c.cover)  ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
title("Table 8: The Effect of Visibility on Earnings Management by the Degree of External Control") ///
note("Notes: The dependent variable in columns (1)-(2) is a firm's accrual earnings management; the dependent variable in columns (3)-(4) is a firm's real earnings management. The variable cover refers to the number of analysts that follow the firm.")

*========== Table 21: Financial Constraint & Interaction ======================================
	eststo clear
eststo regression1: reghdfe rem visib $control_variables, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace

eststo regression2: reghdfe rem visib $control_variables KZ, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace

eststo regression3: reghdfe rem visib $control_variables KZ c.visib#c.KZ, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace

eststo regression4: reghdfe rank_rem visib $control_variables, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace

eststo regression5: reghdfe rank_rem visib $control_variables KZ, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace

eststo regression6: reghdfe rank_rem visib $control_variables KZ c.visib#c.KZ, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 regression6 using "$output\table21.tex", replace ///
mgroups("Real Earnings Management" "Rank of Real Earnings Management", pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
nomtitles collabels(none) booktabs label scalar(ymean) drop($control_variables) ///
stats(blcontrols yearfe indfe N ymean ar2, fmt(0 0 0 0 2 2) labels("Baseline Controls" "Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visiblity on Real Earnings Management with Financial Constraints}\label{tab: table21}\tabcolsep=0.1cm\scalebox{0.8}{\begin{tabular}{lcccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table reports the effects of visibility on the aggregate measure of real earnings management (REM) and the rank of REM. A description of all variables can be found in Table \ref{tab: variabledescriptions}. Columns (1)-(3) report the effects of visibility on REM, and columns (4)-(6) report the effects of visibility on the rank of REM. Columns (1) and (4) are the baseline specifications. Columns (2) and (5) include financial constraints as an additional control. Columns (3) and (6) further include the interaction terms of the firm's financial constraint and visibility. Firm controls are the same as in Table \ref{tab: table4}. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are heteroskedastic-robust. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

esttab regression1 regression2 regression3 regression4  regression5 regression6 using "$output\Word_results.rtf", append ///
mgroups("Real Earnings Management" "Rank of Real Earnings Management", pattern(1 0 0 1 0 0)) ///
nomtitles collabels(none) label scalar(ymean) drop($control_variables) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
title("Table 9: The Effect of Visibility on Earnings Management (with Additional Controls)") ///
note("Notes: The dependent variable in columns (1)-(3) is a firm's real earnings management; the dependent variable in columns (4)-(6) is the rank of a firm's real earnings management.")

*========== Table 24: Auditor's Unqualified Opinion ======================== 
destring auop, replace
	capture drop good_opinion
gen good_opinion = (auop == 1) if (auop == 1 | auop == 4) 
	label var good_opinion "Auditor's Unqualifed Opinion"

	eststo clear
eststo regression1: reghdfe rem visib $control_variables, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace

eststo regression2: reghdfe rem visib $control_variables good_opinion, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace

eststo regression3: reghdfe rem visib $control_variables good_opinion c.visib#i.good_opinion, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace

eststo regression4: reghdfe rank_rem visib $control_variables, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace

eststo regression5: reghdfe rank_rem visib $control_variables good_opinion, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace
		
eststo regression6: reghdfe rank_rem visib $control_variables good_opinion c.visib#i.good_opinion, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 regression6 using "$output\table24.tex", replace ///
mgroups("Real Earnings Management" "Rank of Real Earnings Management", pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
nomtitles collabels(none) booktabs label scalar(ymean) drop($control_variables) ///
stats(blcontrols yearfe indfe N ymean ar2, fmt(0 0 0 0 2 2) labels("Baseline Controls" "Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Real Earnings Management with Auditor's Unqualified Opinion}\label{tab: table24}\tabcolsep=0.1cm\scalebox{0.85}{\begin{tabular}{lcccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table reports the effects of visibility on the aggregate measure of real earnings management (REM) and the rank of REM. A description of all variables can be found in Table \ref{tab: variabledescriptions}. Columns (1)-(3) report the effects of visibility on REM, and columns (4)-(6) report the effects of visibility on the rank of REM. Columns (1) and (4) are the baseline specifications. Columns (2) and (5) include auditor's unqualified opinion toward the firm as an additional control. Columns (3) and (6) further include the interaction term of the variable auditor's unqualified opinion and average visibility the firm is exposed to during the three months prior to its actual period end date as an additional control. Firm controls are the same as in Table \ref{tab: table4}. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are heteroskedastic-robust. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

esttab regression1 regression2 regression3 regression4  regression5 regression6 using "$output\Word_results.rtf", append ///
mgroups("Real Earnings Management" "Rank of Real Earnings Management", pattern(1 0 0 1 0 0)) ///
nomtitles collabels(none) label scalar(ymean) drop($control_variables) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
title("Table 9: The Effect of Visibility on Earnings Management (with Additional Controls)") ///
note("Notes: The dependent variable in columns (1)-(3) is a firm's real earnings management; the dependent variable in columns (4)-(6) is the rank of a firm's real earnings management.")

*========== Table 25: Big N Auditors to proxy for External monitoring ======================== 
global control_variables size bm roa lev firm_age /*rank*/ au_years oa_scale /*xrd_int*/
xtset lpermno fyear

	eststo clear
eststo regression1: reghdfe rem visib $control_variables, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace

eststo regression2: reghdfe rem visib $control_variables rank, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace

eststo regression3: reghdfe rem visib $control_variables rank c.visib#c.rank, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace

eststo regression4: reghdfe rank_rem visib $control_variables, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace

eststo regression5: reghdfe rank_rem visib $control_variables rank, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace
		
eststo regression6: reghdfe rank_rem visib $control_variables rank c.visib#c.rank, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 regression6 using "$output\table25.tex", replace ///
mgroups("Real Earnings Management" "Rank of Real Earnings Management", pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
nomtitles collabels(none) booktabs label scalar(ymean) drop($control_variables) ///
stats(blcontrols yearfe indfe N ymean ar2, fmt(0 0 0 0 2 2) labels("Baseline Controls" "Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Real Earnings Management with Big N Auditors}\label{tab: table25}\tabcolsep=0.1cm\scalebox{0.85}{\begin{tabular}{lcccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table reports the effects of visibility on the aggregate measure of real earnings management (REM) and the rank of REM. A description of all variables can be found in Table \ref{tab: variabledescriptions}. Columns (1)-(3) report the effects of visibility on REM, and columns (4)-(6) report the effects of visibility on the rank of REM. Columns (1) and (4) are the baseline specifications. Columns (2) and (5) include an indicator for Big N Auditors as an additional control. Columns (3) and (6) further include the interaction term of the Big N Auditor indicator and average visibility the firm is exposed to during the three months prior to its actual period end date as an additional control. Firm controls are the same as in Table \ref{tab: table4}. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are heteroskedastic-robust. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

esttab regression1 regression2 regression3 regression4  regression5 regression6 using "$output\Word_results.rtf", append ///
mgroups("Real Earnings Management" "Rank of Real Earnings Management", pattern(1 0 0 1 0 0)) ///
nomtitles collabels(none) label scalar(ymean) drop($control_variables) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
title("Table 25: The Effect of Visibility on Earnings Management (with Additional Controls)") ///
note("Notes: The dependent variable in columns (1)-(3) is a firm's real earnings management; the dependent variable in columns (4)-(6) is the rank of a firm's real earnings management.")


*========== Table 9: Financial Constraint? KZ ======================== NO: add KZ as an additional control
	eststo clear
eststo regression1: reghdfe rem visib $control_variables, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace

eststo regression2: reghdfe rem visib $control_variables KZ, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace

eststo regression4: reghdfe rank_rem visib $control_variables, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace

eststo regression5: reghdfe rank_rem visib $control_variables KZ, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace
		
destring auop, replace
	capture drop good_opinion
gen good_opinion = (auop == 1) if (auop == 1 | auop == 4) 
	label var good_opinion "Auditor's Unqualifed Opinion"

eststo regression3: reghdfe rem visib $control_variables KZ good_opinion, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace

eststo regression6: reghdfe rank_rem visib $control_variables KZ good_opinion, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace

esttab regression1 regression2 regression3 regression4 regression5 regression6 using "$output\table9.tex", replace ///
mgroups("Real Earnings Management" "Rank of Real Earnings Management", pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
nomtitles collabels(none) booktabs label scalar(ymean) drop($control_variables) ///
stats(blcontrols yearfe indfe N ymean ar2, fmt(0 0 0 0 2 2) labels("Baseline Controls" "Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{Robustness Test: Financial Constraint and Auditor's Unqualified Opinion}\label{tab: table9}\tabcolsep=0.1cm\begin{tabular}{lcccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}\end{center}\\\footnotesize{Notes: This table reports the effects of visibility on the aggregate measure of real earnings management (REM) and the rank of REM. A description of all variables can be found in Table \ref{tab: variabledescriptions}. Columns (1)-(3) report the effects of visibility on REM, and columns (4)-(6) report the effects of visibility on the rank of REM. Columns (1) and (4) are the baseline specifications. Columns (2) and (5) include financial constraints as an additional control. Columns (3) and (6) further include auditor's unqualified opinion as an additional control. Firm controls are the same as in Table \ref{tab: table4}. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are heteroskedastic-robust. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

esttab regression1 regression2 regression3 regression4  regression5 regression6 using "$output\Word_results.rtf", append ///
mgroups("Real Earnings Management" "Rank of Real Earnings Management", pattern(1 0 0 1 0 0)) ///
nomtitles collabels(none) label scalar(ymean) drop($control_variables) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
title("Table 9: The Effect of Visibility on Earnings Management (with Additional Controls)") ///
note("Notes: The dependent variable in columns (1)-(3) is a firm's real earnings management; the dependent variable in columns (4)-(6) is the rank of a firm's real earnings management.")

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

*============== Table 22: External Scrutiny: Auditor's Unqualified Opinion & Coastal ============
	eststo clear
eststo regression1: reghdfe rem visib $control_variables, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace

eststo regression2: reghdfe rem visib $control_variables coastal, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace

eststo regression3: reghdfe rem visib $control_variables coastal c.visib#i.coastal, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace

eststo regression4: reghdfe rank_rem visib $control_variables, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace

eststo regression5: reghdfe rank_rem visib $control_variables coastal, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace

eststo regression6: reghdfe rank_rem visib $control_variables coastal c.visib#i.coastal, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace
		
esttab regression1 regression2 regression3 regression4 regression5 regression6 using "$output\table22.tex", replace ///
mgroups("Real Earnings Management" "Rank of Real Earnings Management", pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
nomtitles collabels(none) booktabs label scalar(ymean) drop($control_variables) ///
stats(blcontrols yearfe indfe N ymean ar2, fmt(0 0 0 0 2 2) labels("Baseline Controls" "Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Real Earnings Management in Coastal Regions}\label{tab: table22}\tabcolsep=0.1cm\scalebox{0.8}{\begin{tabular}{lcccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: This table reports the effects of visibility on the aggregate measure of real earnings management (REM) and the rank of REM. A description of all variables can be found in Table \ref{tab: variabledescriptions}. Columns (1)-(3) report the effects of visibility on REM, and columns (4)-(6) report the effects of visibility on the rank of REM. Columns (1) and (4) are the baseline specifications. Columns (2) and (5) include an indicator for whether the state the firm is located in is coastal as an additional control. Columns (3) and (6) further include the interaction term between the coastal indicator variable and visiblity as an additional control. Firm controls are the same as in Table \ref{tab: table4}. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are heteroskedastic-robust. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

esttab regression1 regression2 regression3 regression4  regression5 regression6 using "$output\Word_results.rtf", append ///
mgroups("Real Earnings Management" "Rank of Real Earnings Management", pattern(1 0 0 1 0 0)) ///
nomtitles collabels(none) label scalar(ymean) drop($control_variables) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
title("Table 9: The Effect of Visibility on Earnings Management (with Additional Controls)") ///
note("Notes: The dependent variable in columns (1)-(3) is a firm's real earnings management; the dependent variable in columns (4)-(6) is the rank of a firm's real earnings management.")

*================================= Table 23: Environmental Expenses ===============================
xtset lpermno fyear
gen xsga_scale = xsga/l1.at

label var xsga_scale "Admin. Expenses"

	eststo clear
eststo regression1: reghdfe dac visib $control_variables xsga_scale /*c.visib#c.xsga_scale*/, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local controls "Yes", replace

eststo regression2: reghdfe rank_dac visib $control_variables xsga_scale /*c.visib#c.xsga_scale*/, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rank_dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local controls "Yes", replace

eststo regression3: reghdfe rem visib $control_variables xsga_scale /*c.visib#c.xsga_scale*/, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local controls "Yes", replace

eststo regression4: reghdfe rank_rem visib $control_variables xsga_scale /*c.visib#c.xsga_scale*/, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rank_rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local controls "Yes", replace

esttab regression1 regression2 regression3 regression4 using "$output\table23.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
mtitles("AEM" "AEM Rank" "REM" "REM Rank") collabels(none) booktabs label scalar(ymean) drop($control_variables) ///
stats(controls yearfe indfe N ymean ar2, fmt(0 0 0 0 2 2) labels("Baseline Controls" "Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management with Selling, General, and Administrative Expenses}\label{tab: table23}\tabcolsep=0.1cm\begin{tabular}{lcccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}\end{center}\\\footnotesize{Notes: The dependent variables are indicated at the top of each column. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variables in columns (1)-(2) are: a firm's accrual earnings management, and the rank of the firm's accrual earnings management, respectively. The dependent variables in columns (3)-(4) are: a firm's real earnings management, and the rank of the firm's real earnings management, respectively. Year fixed effects and industry fixed effects are included in all regressions. Columns (2) and (4) further include the firm's Selling, General, and Administrative Expenses (xsga) as an additional control variable. All baseline control variables are included in the model, including firm size, book-to-market ratio, returns on assets (ROA), firm's leverage ratio, firm age, Big N indicator, auditor tenure, and net operating assets. Standard errors are heteroskedastic-robust. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

esttab regression1 regression2 regression3 regression4 using "$output\Word_results.rtf", append ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 1 0)) ///
mtitles("AEM" "AEM Rank" "REM" "REM Rank") nonumbers collabels(none) label scalar(ymean`') drop($control_variables) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
title("Table 4: The Effect of Visibility on Earnings Management") ///
note("Notes: The dependent variable in columns (1)-(2) is a firm's accrual earnings management; the dependent variable in columns (3)-(4) is a firm's real earnings management.")


/* ============================================================================
* ====================== Consequences ========================================
* ============================================================================
* Second-order outcomes: CEO Compensation

bysort ff_48: egen ff48_median = median(Tobinq)
gen adjq =  Tobinq / ff48_median
	label var adjq "Adjusted TobinQ"
	
gen logat = log(at)
	label var logat "Log(total assets)"
	
gen debtr = dltt/at
	label var debtr "Long-term debt/Total assets"
	
gen rndr = xrd/sale
	label var rndr "R&D expense/Sales"
	
gen capxr = capx/sale
	label var capxr "Capital expenditure expense/Sales"

gen advr = xad/sale
	label var advr "Advertising expense/Sales"
	
	xtset lpermno fyear
gen sgr = (sale - l1.sale)/l1.sale
	label var sgr "Sales growth"
	
* gen lambda
global control_variables_TQ logat debtr /*rndr*/ /*capxr*/ /*advr*/ sgr

	eststo clear
eststo regression1: reghdfe adjq rem $control_variables_TQ, absorb(fyear ff_48)
estadd scalar ar2 = e(r2_a)
summarize Tobinq
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression2: ivreghdfe adjq (rem = visib) $control_variables_TQ, absorb(fyear ff_48) first savefirst savefprefix(st1)
estadd scalar ar2 = e(r2_a)
summarize Tobinq
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd scalar cdf1 = e(cdf)

eststo regression3: reghdfe adjq rank_rem $control_variables_TQ, absorb(fyear ff_48)
estadd scalar ar2 = e(r2_a)
summarize Tobinq
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression4: ivreghdfe adjq (rank_rem=visib) $control_variables_TQ, absorb(fyear ff_48) first savefirst savefprefix(st1)
estadd scalar ar2 = e(r2_a)
summarize Tobinq
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd scalar cdf1 = e(cdf)

esttab regression1 regression2 regression3 regression4 using "$output\table10.tex", replace ///
mgroups("with REM" "with REM Rank", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
mtitles("OLS" "IV" "OLS" "IV") nonumbers collabels(none) booktabs label scalar(ymean) ///
order(rem rank_rem $control_variables_TQ) ///
stats(yearfe indfe N ymean ar2 cdf1, fmt(0 0 0 2 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq" "CD Wald F")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of REM on Tobin's Q}\label{tab: table10}\tabcolsep=0.1cm\begin{tabular}{lcccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}\end{center}\\\footnotesize{Notes: This table reports the market consequences of weather-induced real earnings management behaviors. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variable in all columns is the adjusted Tobin's Q. The main regressor in columns (1) and (2) is REM. The main regressor in columns (3)-(4) is the rank of the firm's REM. Columns (1) and (3) report the OLS estimates. Columns (2) and (4) report the IV estimates where REM and REM rank are instrumented by visibility. The first stage C-D Wald F-statistic for IV regressions are displayed in the last row of the table. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are heteroskedastic-robust. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

esttab regression1 regression2 regression3 regression4 using "$output\Word_results.rtf", append ///
mtitles("OLS" "IV" "OLS" "IV") nonumbers collabels(none) label scalar(ymean)  ///
order(rem rank_rem $control_variables_TQ) ///
stats(yearfe indfe N ymean ar2 cdf1, fmt(0 0 0 2 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq" "CD Wald F")) ///
title("Table 10: The Effect of REM on Tobin's Q") ///
note("Notes: The dependent variable in all columns is adjusted Tobin's Q.")


* ==================== IV: Exclusion Restriction ======================
	eststo clear
eststo regression1: reghdfe adjq visib $control_variables_TQ, absorb(fyear ff_48)
estadd scalar ar2 = e(r2_a)
summarize Tobinq
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression2: reghdfe adjq visib rem $control_variables_TQ, absorb(fyear ff_48)
estadd scalar ar2 = e(r2_a)
summarize Tobinq
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression3: reghdfe adjq visib rank_rem $control_variables_TQ, absorb(fyear ff_48)
estadd scalar ar2 = e(r2_a)
summarize Tobinq
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

esttab regression1 regression2 regression3 using "$output\table12.tex", replace ///
collabels(none) booktabs label scalar(ymean) ///
order(visib rem rank_rem $control_variables_TQ) ///
stats(yearfe indfe N ymean ar2 cdf1, fmt(0 0 0 2 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq" "CD Wald F")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of REM on Tobin's Q}\label{tab: table12}\tabcolsep=0.1cm\begin{tabular}{lccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}\end{center}\\\footnotesize{Notes: This table reports the effect of visibility on a firm's Tobin's Q. Columns (2) further includes REM as a control variable, and column (3) replaces the REM with the rank of REM as the control variable. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are heteroskedastic-robust. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

esttab regression1 regression2 regression3 using "$output\Word_results.rtf", append ///
collabels(none) label scalar(ymean)  ///
order(visib rem rank_rem $control_variables_TQ) ///
stats(yearfe indfe N ymean ar2 cdf1, fmt(0 0 0 2 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq" "CD Wald F")) ///
title("Table 12: The Effect of REM on Tobin's Q") ///
note("Notes: The dependent variable in all columns is adjusted Tobin's Q.")

/*
			* Second-order outcomes: Tobin Q
			xtset lpermco fyear
				eststo clear
			eststo regression1: reghdfe Tobinq rem $control_variables sale if polluted == 1, absorb(fyear ff_48)
			estadd scalar ar2 = e(r2_a)
			summarize Tobinq
			estadd scalar ymean = r(mean)
			estadd local yearfe "Yes", replace
			estadd local indfe "Yes", replace

			eststo regression2: reghdfe Tobinq rem $control_variables sale if polluted == 0, absorb(fyear ff_48)
			estadd scalar ar2 = e(r2_a)
			summarize Tobinq
			estadd scalar ymean = r(mean)
			estadd local yearfe "Yes", replace
			estadd local indfe "Yes", replace

			gen visib_T10 =.
			gen visib_B10 =.

				foreach year of numlist 2003/2017{
				summarize visib if fyear == `year' & !mi(visib), d
				local t10 = r(p90)
				local b10 = r(p10)
				replace visib_T10 = `t10' if fyear == `year'
				replace visib_B10 = `b10' if fyear == `year'
				}
				
				gen polluted1 = 0 if (visib >= visib_T10) & !mi(visib)
				replace polluted1 = 1 if (visib <= visib_B10) & !mi(visib)
					br polluted1 visib

				eststo regression3: reghdfe f.Tobinq rem $control_variables sale, absorb(fyear ff_48)
				estadd scalar ar2 = e(r2_a)
				summarize Tobinq
				estadd scalar ymean = r(mean)
				estadd local yearfe "Yes", replace
				estadd local indfe "Yes", replace

				eststo regression4: reghdfe f.Tobinq visib $control_variables sale, absorb(fyear ff_48)
				estadd scalar ar2 = e(r2_a)
				summarize Tobinq
				estadd scalar ymean = r(mean)
				estadd local yearfe "Yes", replace
				estadd local indfe "Yes", replace
					
				eststo regression5: reghdfe Tobinq rem polluted c.rem#c.polluted $control_variables sale, absorb(fyear ff_48)
				estadd scalar ar2 = e(r2_a)
				summarize Tobinq
				estadd scalar ymean = r(mean)
				estadd local yearfe "Yes", replace
				estadd local indfe "Yes", replace

			esttab regression1 regression2 using "$output\table11.tex", replace ///
			mtitles("(1)Accrual Earnings Management" "(2)Real Earnings Management") ///
			nonumbers collabels(none) booktabs label scalar(ymean) ///
			stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
			prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management}\tabcolsep=0.1cm\begin{tabular}{lcccc}\toprule")  ///
			posthead("\midrule") postfoot("\bottomrule\end{tabular}\\\footnotesize{Notes: The dependent variable in column (1) is a firm's accrual earnings management; the dependent variable in column (2) is a firm's real earnings management.}\end{center}\end{table}") 

			esttab regression1 regression2 using "$output\Word_results.rtf", append ///
			mtitles("(1)Accrual Earnings Management" "(2)Real Earnings Management") ///
			nonumbers collabels(none) label scalar(ymean)  ///
			stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
			title("Table 11: The Effect of Visibility on Earnings Management") ///
			note("Notes: The dependent variable in column (1) is a firm's accrual earnings management; the dependent variable in column (2) is a firm's real earnings management.")
			*/
* classification

* ================================= Compensation ====================================
* Second-order outcomes: CEO Compensation
preserve
	clear
	use "$maindir\compensation and turnover", replace
	rename PERMCO lpermco
	rename year fyear
		capture drop _merge
	tempfile compensation_turnover
	save `compensation_turnover', replace
restore

	capture drop _merge
merge 1:m lpermco fyear using `compensation_turnover'
	keep if _m == 3
	drop _merge

drop if mi(cfoann) & mi(ceoan) //20235
keep if !mi(ceoan)

xtset lpermco fyear 
*------------------------ Compensation ---------------------------------
/*
				eststo clear
			xtset lpermco fyear
			eststo regression1: reghdfe f.total_curr rem $control_variables, absorb(fyear ff_48)
			estadd scalar ar2 = e(r2_a)
			summarize Tobinq
			estadd scalar ymean = r(mean)
			estadd local yearfe "Yes", replace
			estadd local indfe "Yes", replace

			eststo regression2: reghdfe f.total_curr visib $control_variables, absorb(fyear ff_48)

			eststo regression3: reghdfe f.total_curr rem visib c.rem#c.visib $control_variables, absorb(fyear ff_48)
*/

	eststo clear
eststo regression1: reghdfe f.total_curr rem $control_variables_TQ, absorb(fyear ff_48)
estadd scalar ar2 = e(r2_a)
summarize total_curr
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression2: ivreghdfe f.total_curr (rem = visib) $control_variables_TQ, absorb(fyear ff_48) first savefirst savefprefix(st1)
estadd scalar ar2 = e(r2_a)
summarize total_curr
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd scalar cdf1 = e(cdf)

*------------------------ Turnover ---------------------------------
/*
				gen turnover_f3 = (turnover == 1 | f.turnover == 1 | f2.turnover == 1 | f3.turnover == 1) if !mi(turnover)
					eststo clear
				eststo regression1: logit turnover_f3 rem /*visib*/ $control_variables i.fyear i.ff_48 if ceoann == "CEO", vce(robust)
				estadd scalar ar2 = e(r2_a)
				summarize turnover
				estadd scalar ymean = r(mean)
				estadd local yearfe "Yes", replace
				estadd local indfe "Yes", replace

				eststo regression2: logit turnover_f3 visib $control_variables i.fyear i.ff_48 if ceoann == "CEO", vce(robust)

				eststo regression3: logit turnover_f3 rem $control_variables i.fyear i.ff_48 if ceoann == "CEO", vce(robust)

				eststo regression4: logit turnover_f3 rem visib c.rem#c.visib $control_variables i.fyear i.ff_48 if ceoann == "CEO", vce(robust)
*/


eststo regression3: reghdfe f.turnover rem $control_variables_TQ, absorb(fyear ff_48) 
estadd scalar ar2 = e(r2_a)
summarize turnover
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression4: ivreghdfe f.turnover (rem = visib) $control_variables_TQ, absorb(fyear ff_48) first savefirst savefprefix(st1)
estadd scalar ar2 = e(r2_a)
summarize turnover
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd scalar cdf1 = e(cdf)

esttab regression1 regression2 regression3 regression4 using "$output\table11.tex", replace ///
mgroups("CEO Compensation" "CEO Turnovers", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
mtitles("OLS" "IV" "OLS" "IV") nonumbers collabels(none) booktabs label scalar(ymean) ///
order(rem $control_variables_TQ) ///
stats(yearfe indfe N ymean ar2 cdf1, fmt(0 0 0 2 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq" "CD Wald F")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of REM on Labor Market Outcomes}\tabcolsep=0.1cm\label{tab: table11}\begin{tabular}{lcccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}\end{center}\\\footnotesize{Notes: This table reports the labor market consequences of weather-induced real earnings management behavior. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variable in columns (1)-(2) is the total compensation of a firm's CEO within a fiscal year. The dependent variable in columns (3)-(4) is an indicator for there being at least one occurrance of CEO turnover during the fiscal year. Columns (1) and (3) report the OLS estimates, and columns (2) and (4) report the IV estimates where REM is instrumented by visibility. The first stage C-D Wald F-statistic for IV regressions are displayed in the last row of the table. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are heteroskedastic-robust. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

esttab regression1 regression2 regression3 regression4 using "$output\Word_results.rtf", append ///
mtitles("OLS" "IV" "OLS" "IV") nonumbers collabels(none) label scalar(ymean)  ///
order(rem $control_variables_TQ) ///
stats(yearfe indfe N ymean ar2 cdf1, fmt(0 0 0 2 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq" "CD Wald F")) ///
title("Table 11: The Effect of REM on Labor Market Outcomes") ///
note("Notes: The dependent variable in the first two columns is CEO's compensation, and is the turnover of CEOs in the last two columns.")
*/
