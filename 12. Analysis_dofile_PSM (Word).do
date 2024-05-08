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
global maindir "E:\21. Air Pollution and Accounting\DATA"
global output "E:\21. Air Pollution and Accounting\RESULTS"
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
global summ_vars dacck dac rank_dac rem rank_rem stdz_rem d_cfo_neg rank_d_cfo_neg d_prod rank_d_prod ///
d_discexp_neg rank_d_discexp_neg size bm roa lev firm_age rank au_years /*<--tenure*/ oa_scale cover sale /*<--noa*/ /*xrd_int */ /*cycle*/

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

*hhi5 sale, by(ff_48 fyear) //hhi_sale
		
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
label var cover "Analysts Following"
label var KZ "Financial Constraint"

* sales  
label var rank_d_cfo "Rank(REM_CFO)"
label var d_cfo "REM_CFO"

gen d_cfo_neg = - d_cfo
gen rank_d_cfo_neg = 9- rank_d_cfo

label var d_cfo_neg "REM_CFO"
label var rank_d_cfo_neg " Rank(REM_CFO)"

* over-production
 label var d_prod "REM_PROD$"
 label var rank_d_prod "Rank(REM_PROD)"

* expenditure
 label var d_discexp "REM_DISX"
 label var rank_d_discexp " Rank(REM_DISX)"

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

	capture drop _merge
merge 1:1 lpermno fyear using `convk'	

drop if _merge == 2
label var dacck "AEM (performance-adjusted)"

hhi5 sale, by(ff_48 fyear) //hhi_sale
label var hhi_sale "HHI index"		
	
use "$output\final_data_47662", replace

label var size "Size"
label var bm "BM"
label var roa "ROA"
label var lev "Leverage"
label var oa_scale "NOA"
label var au_years "Auditor Tenure"
label var firm_age "Firm Age"
label var rank "Big N" //binary

global control_variables_aem size bm roa lev firm_age rank au_years oa_scale /*xrd_int*/
global control_variables_rem size bm roa lev firm_age rank au_years hhi_sale /*xrd_int*/

use "$output\final_data_47662", replace

	capture drop visib_median
	capture drop visib_binary
	capture drop visib_binary_neg
egen visib_median = median(visib)
gen visib_binary = (visib < visib_median) if !mi(visib)
gen visib_binary_neg = -visib_binary

set seed 12345678
*psmatch2 visib_binary $control_variables, outcome(rem) noreplacement ties radius caliper(0.00001)
psmatch2 visib_binary $control_variables_rem, outcome(rem) ai(3) ///
                     caliper(0.03) noreplacement descending common odds index logit ties ///
                     warnings quietly ate


psgraph
pstest $control_variables_rem

eststo treatall: estpost sum $control_variables_rem if visib < visib_median
eststo controlall: estpost sum $control_variables_rem if visib >= visib_median
eststo diffall: estpost ttest $control_variables_rem, by(visib_binary_neg) 
eststo treatpsm: estpost sum $control_variables_rem if visib < visib_median & _support == 1
eststo controlpsm: estpost sum $control_variables_rem if visib >= visib_median  & _support == 1
eststo diffpsm: estpost ttest $control_variables_rem if _support == 1, by(visib_binary_neg) 

estout treatall controlall diffall treatpsm controlpsm diffpsm using "$output\ttest_psm.rtf", ///
replace cells("mean(pattern(1 1 0 1 1 0)  fmt(3)) b(star pattern(0 0 1 0 0 1) fmt(3)) ") ///
mgroups("Pooled Sample" "PSM Sample", pattern(1 0 0 1 0 0)) ///
label mlabels("More Polluted" "Less Polluted" "Difference" "More Polluted" "Less Polluted" "Difference") collabels(none) nonumbers  ///
stats(N , fmt(0) labels("N")) title("Propensity Score Matching Sample")  ///
posthead("Panel A: Descriptive Statistics for the Sample before and after PSM") 

sum _support
keep if _support == 1 //10846

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

estout regression1 regression2 regression3 regression4 regression5 using "$output\ttest_psm.rtf", append ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 0 1 0)) ///
cells(b(star) se(par)) mlabels("AEM (performance-adj.)" "AEM (modified Jone's')" "AEM Rank" "REM" "REM Rank") collabels(none) label  ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) /// 
posthead("Panel B: PSM Sample Regression") ///
note("Notes: The analysis is conducted among the obtained sample after PSM. The dependent variables are indicated at the top of each column. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variables in columns 1-3 are: a firm's accrual earnings management (AEM) calculated using the performance-adjusted model, a firm's AEM calculated using the modified Jone's model, and the rank of the firm's AEM (modified Jone's), respectively. The dependent variables in columns 4-5 are: a firm's real earnings management (REM), and the rank of the firm's REM, respectively. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are clustered at the level of firm and year. *** p < 1%, ** p < 5%, * p < 10%.}\end{table}") 
exit
esttab regression1 regression2 regression3 regression4 using "$output\Word_results.rtf", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 1 0)) ///
mtitles("AEM" "AEM Rank" "REM" "REM Rank") nonumbers collabels(none) label scalar(ymean`') ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
title("Table 4: The Effect of Visibility on Earnings Management") ///
note("Notes: The dependent variable in columns 1-2 is a firm's accrual earnings management; the dependent variable in columns 3-4 is a firm's real earnings management.") 

* ========== DID ==========
*2466 observations

sort lpermno fyear
br lpermno fyear	
	
bysort lpermno (fyear): gen x = _N

* Drop observations with only one year
drop if x == 1

/*
br lpermno fyear visib
	capture drop visib_change
bysort lpermno (fyear): gen visib_change = visib - l.visib
		
bysort lpermno: gen post = _n-1 if x == 2

expand 2 if x > 2
sort lpermno fyear

bysort lpermno (fyear): gen N_max = _N
bysort lpermno (fyear): gen N = _n
drop if (N == 1 | N == N_max) & x > 2
	drop N_max N
*/

	capture drop visib_change
bysort lpermno: gen visib_change = visib - visib[_n-1]	

/* replace missings for post
replace post = 1 if mi(post)
	
gen obs = _n
replace post = 0 if post == 1 & mod(obs, 2) == 1
	drop obs

* replace visib_change values with missing if post == 0 (pre)
replace visib_change =. if visib_change == 0 & post == 0
*/
	capture drop drastic polluted clean

summarize visib if !mi(visib_change), d
	capture drop visib_std1
egen visib_std1 = sd(visib) if !mi(visib_change)
gen drastic = (abs(visib_change) >= visib_std1) if !mi(visib_change)
gen polluted = (visib_change < 0 & drastic == 1) if !mi(visib_change)
gen clean = (visib_change >= 0 & drastic == 1) if !mi(visib_change)
	
/* compare pairs that experience drastic changes and those that did not experience that big changes in visibility
gen pair = _n/2 if post == 1
replace pair = (_n+1)/2 if post == 0
*/

/* fill values for visib_change, drastic, polluted, clean for each pair
foreach var of varlist visib_change drastic polluted clean{
	bysort pair: replace `var' = `var'[_n+1] if mi(`var')
}
*/
br lpermno fyear visib visib_change drastic polluted clean

exit
global control_variables size bm roa lev firm_age rank au_years oa_scale /*xrd_int*/ 

/*
reghdfe rem polluted clean post i.polluted#i.post i.clean#i.post $control_variables, absorb(fyear ff_48) vce(robust)
reg rem polluted clean post i.polluted#i.post i.clean#i.post $control_variables i.fyear i.ff_48, vce(robust)
reg rank_rem polluted clean post i.polluted#i.post i.clean#i.post $control_variables i.fyear i.ff_48, vce(robust)
*/
forvalues i = 2004/2017{
unique lpermno if fyear == `i'
}
bysort lpermno: gen numyrs = _N
ta numyrs
 
* ========== SDID ============
*! version 2.01
*! 2008.08.23
*! Author: Lian Yu-jun, Sun Yat-Sen University
*! E-mail: arlionn@163.com
*! 2009.08.09 
*  新增 gen() 选项，用于标示平行面板的样本，受 -panelthin- 启发

cap program drop xtbalance
program define xtbalance
version 8.0

   syntax , Range(numlist min=2 max=2 int ascending) [Miss(varlist)]
   
   qui capture tsset
   capture confirm e `r(panelvar)'
   if ( _rc != 0 ) {
     dis as error "You must {help tsset} your data before using {cmd:xtbalance},see help {help xtbalance}."
     exit
   }
   
   qui tsset
   local id   "`r(panelvar)'"
   local t    "`r(timevar)'" 
   
   gettoken byear oyear : range
   
   qui count if (`t'<`byear') | (`t'>`oyear')
   if `r(N)' != 0 {
      dis _n in g "(" in y `r(N)' in g " observations deleted due to out of range) "
   }
   cap drop if (`t'<`byear') | (`t'>`oyear')  /*减少搜索量*/
   
   tempvar  missv                     /*删除 varlist 中的缺漏值*/
   egen `missv' = rmiss(`miss')
   qui count if `missv' !=0
   qui drop if `missv' != 0
   if "`miss'" != "" & `r(N)'!=0{
      dis _n in g "(" in y `r(N)' in g " observations deleted due to missing) "
   }
    
   qui sum `t', meanonly  /*判断用户输入的区间是否超出了样本的时间区间*/ 
   local rmin = r(min)
   local rmax = r(max)
   if `byear'<r(min){
     dis in g "#1" in r " in option "   ///
         in g "range(#1,#2)", in r "i.e., "       ///
         in g `byear', in r "must be greater than "  ///
         in g "`rmin'," in r " the smallest year in sample."
     exit
   }
   else if `oyear'>r(max){
     dis in g "#2" in r " in option "   ///
         in g "range(#1,#2)", in r "i.e., "       ///
         in g `oyear', in r "must be less than "  ///
         in g "`rmax'," in r " the largest year in sample."
     exit
   }
   
   tempvar pt
   qui xtpattern, gen(`pt')  /*调用外部命令xtpattern*/
   
   * 样本区间
   local r2 = `oyear' - `byear' + 1             
   
   local dot  ""            /*产生xtpattern对应的模式，"11111"*/
   forvalues i = 1/`r2'{
     local dot "`dot'1"
   }
   
   qui count if `pt' ! = "`dot'"
   if `r(N)' != 0 {
      dis _n in g "(" in y `r(N)' in g " observations deleted due to discontinues) "
   }
   cap drop if `pt' ! = "`dot'"
   
   qui tsset
   
end

     
program def xtpattern, sortpreserve   
* NJC 1.0.1 29 January 2002 
	version 7 
	syntax [if], Generate(string) 
	marksample touse
	local g "`generate'" 

	qui tsset 
	
	if "`r(panelvar)'" == "" { 
		di as err "no panel variable set"
		exit 198 
	} 
	else local panel "`r(panelvar)'"
	
	local time "`r(timevar)'" 

	capture confirm new variable `g' 
	if _rc { 
		di as err "`g' should be new variable"
		exit 198 
	} 	

	tempvar T occ
	
	qui egen `T' = group(`time') if `touse' 
	
	* update for Stata/SE 11 February 2002 
	local smax = cond("$S_StataSE" == "SE", 244, 80) 

	su `T', meanonly 
	if `r(max)' > `smax' { 
		di as err "number of times > `smax': no variable created"
		exit 198 
	} 
	else local max = `r(max)'
	
	qui gen str1 `g' = "" 
	gen byte `occ' = 0 

	sort `touse' `panel' 
	
	qui forval t = 1/`max' { 
		by `touse' `panel': replace `occ' = sum(`T' == `t') 
		by `touse' `panel': replace `occ' = `occ'[_N] 
		by `touse' `panel': /* 
	*/ replace `g' = `g' + cond(`occ', "1", ".") if `touse'
	}
end           
               


xtset lpermno fyear
xtbalance, range(2004 2017)
sdid rem lpermno fyear polluted, vce(placebo) seed(1213)

