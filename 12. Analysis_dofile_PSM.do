*=========================== Difference-in-Difference Analysis ===============================
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
global maindir "F:\21. Air Pollution and Accounting\DATA"
global output "F:\21. Air Pollution and Accounting\RESULTS"
}

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
label var au_years "Auditor Tenure"
label var firm_age "Firm Age"
label var rank "Big 8" //binary
label var visib "Visibility"
label var cover "Analysts Following"
label var KZ "Financial Constraint"

* sales  
label var rank_d_cfo "Disc. CF Rank"
label var d_cfo "Change in Disc. CF"

gen d_cfo_neg = - d_cfo
gen rank_d_cfo_neg = 9- rank_d_cfo

label var d_cfo_neg "$REM_{CFO}$"
label var rank_d_cfo_neg " Rank($REM_{CFO}$)"

* over-production
 label var d_prod "$REM_{PROD}$"
 label var rank_d_prod "Rank($REM_{PROD}$)"

* expenditure
 label var d_discexp "Disc. Exp."
 label var rank_d_discexp " Rank(Disc. Exp.)"

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

*use "$output\final_data_10883.dta", replace	

global control_variables size bm roa lev firm_age rank au_years oa_scale /*xrd_int*/

label var size "Size"
label var bm "BM"
label var roa "ROA"
label var lev "Leverage"
label var oa_scale "NOA"
label var au_years "Auditor Tenure"
label var firm_age "Firm Age"
label var rank "Big N" //binary

	capture drop visib_median
	capture drop visib_binary
egen visib_median = median(visib)
gen visib_binary = (visib < visib_median) if !mi(visib)
gen visib_binary_neg = -visib_binary

psmatch2 visib_binary $control_variables, outcome(rem) noreplacement ties radius caliper(0.00001)
psmatch2 visib_binary $control_variables, outcome(rem) ai(3) ///
                     caliper(0.001) noreplacement descending common odds index logit ties ///
                     warnings quietly ate


psgraph
pstest $control_variables

eststo treatall: estpost sum $control_variables if visib < visib_median
eststo controlall: estpost sum $control_variables if visib >= visib_median
eststo diffall: estpost ttest $control_variables, by(visib_binary_neg) 
eststo treatpsm: estpost sum $control_variables if visib < visib_median & _support == 1
eststo controlpsm: estpost sum $control_variables if visib >= visib_median  & _support == 1
eststo diffpsm: estpost ttest $control_variables if _support == 1, by(visib_binary_neg) 

esttab treatall controlall diffall treatpsm controlpsm diffpsm using "$output\ttest_psm.tex", ///
replace cells("mean(pattern(1 1 0 1 1 0)  fmt(3)) b(star pattern(0 0 1 0 0 1) fmt(3)) ") ///
mgroups("Pooled Sample" "PSM Sample", pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
label mtitles("More Polluted" "Less Polluted" "Difference" "More Polluted" "Less Polluted" "Difference") collabels(none) nonumbers booktabs ///
prehead("\begin{table}\begin{center}\caption{Propensity Score Matching Sample}\label{tab: ttestpsm}\tabcolsep=0.1cm\scalebox{0.7}{\begin{tabular}{lcccccc}\toprule")  ///
posthead("\midrule \multicolumn{7}{c}{\textbf{Panel A: Descriptive Statistics for the Sample before and after PSM}}\\") ///
postfoot("\end{tabular}}") 

esttab treatall controlall diffall treatpsm controlpsm diffpsm using "$output\ttest_psm.rtf", ///
replace cells("mean(pattern(1 1 0 1 1 0)  fmt(3)) b(star pattern(0 0 1 0 0 1) fmt(3)) ") ///
mgroups("Pooled Sample" "PSM Sample", pattern(1 0 0 1 0 0)) ///
label mtitles("Polluted" "Unpolluted" "Polluted-Unpolluted" "Polluted" "Unpolluted" "Polluted-Unpolluted") collabels(none) nonumbers booktabs ///
postfoot("\end{tabular}}\end{center}\footnotesize{Notes: This table shows the univarite test of the difference between firms exposed to higher air quality and those exposed to lower air quality (defined as being lower than the median of visibility over years: 2003-2017). The first three columns show the t-test among the pooled sample, and the last three columns show the t-test among the PSM sample. A description of all variables can be found in Table \ref{tab: variabledescriptions}. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

sum _support
keep if _support == 1 //10846

*======== Table 4: Regression (Signed) =============================
	eststo clear
eststo regression1: reghdfe dac visib $control_variables, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression2: reghdfe rank_dac visib $control_variables, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rank_dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression3: reghdfe rem visib $control_variables, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression4: reghdfe rank_rem visib $control_variables, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rank_rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

esttab regression1 regression2 regression3 regression4 using "$output\ttest_psm.tex", append ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
mtitles("AEM" "AEM Rank" "REM" "REM Rank") collabels(none) booktabs label scalar(ymean) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\scalebox{0.8}{\begin{tabular}{lcccc}\toprule")  ///
posthead("\midrule\multicolumn{5}{c}{\textbf{Panel B: PSM Sample Regression}}\\") ///
postfoot("\bottomrule\end{tabular}}\end{center}\footnotesize{Notes: The dependent variables are indicated at the top of each column. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variables in columns (1)-(2) are: a firm's accrual earnings management, and the rank of the firm's accrual earnings management, respectively. The dependent variables in columns (3)-(4) are: a firm's real earnings management, and the rank of the firm's real earnings management, respectively. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are heteroskedastic-robust. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

esttab regression1 regression2 regression3 regression4 using "$output\Word_results.rtf", append ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 1 0)) ///
mtitles("AEM" "AEM Rank" "REM" "REM Rank") nonumbers collabels(none) label scalar(ymean`') ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
title("Table 4: The Effect of Visibility on Earnings Management") ///
note("Notes: The dependent variable in columns (1)-(2) is a firm's accrual earnings management; the dependent variable in columns (3)-(4) is a firm's real earnings management.")

