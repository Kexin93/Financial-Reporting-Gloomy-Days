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
use "$maindir\One-year Analysis\Firm_Year_Weather_1Yr", replace
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

save "$output\final_data_11283", replace

*10883 observations

sort lpermno fyear
br lpermno fyear	
	
bysort lpermno (fyear): gen x = _N

* Drop observations with only one year
drop if x == 1

xtset lpermno fyear
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

	capture drop visib_change
bysort lpermno: gen visib_change = visib - visib[_n-1]	

* replace missings for post
replace post = 1 if mi(post)
	
gen obs = _n
replace post = 0 if post == 1 & mod(obs, 2) == 1
	drop obs

* replace visib_change values with missing if post == 0 (pre)
replace visib_change =. if visib_change == 0 & post == 0

	capture drop drastic polluted clean

summarize visib if !mi(visib_change), d
egen visib_std1 = sd(visib) if !mi(visib_change)
gen visib_std1_2times = 2*visib_std1
gen drastic = (abs(visib_change) >= visib_std1_2times) if !mi(visib_change)
gen polluted = (visib_change < 0 & drastic == 1) if !mi(visib_change)
gen clean = (visib_change >= 0 & drastic == 1) if !mi(visib_change)
	
* compare pairs that experience drastic changes and those that did not experience that big changes in visibility
gen pair = _n/2 if post == 1
replace pair = (_n+1)/2 if post == 0

* fill values for visib_change, drastic, polluted, clean for each pair
foreach var of varlist visib_change drastic polluted clean{
	bysort pair: replace `var' = `var'[_n+1] if mi(`var')
}


global control_variables size bm roa lev /*firm_age rank au_years oa_scale /*xrd_int*/ */

reghdfe rem polluted clean post i.polluted#i.post i.clean#i.post $control_variables, absorb(fyear ff_48) vce(robust)
reg rem polluted clean post i.polluted#i.post i.clean#i.post $control_variables i.fyear i.ff_48, vce(robust)
reg rank_rem polluted clean post i.polluted#i.post i.clean#i.post $control_variables i.fyear i.ff_48, vce(robust)

preserve
drop if clean == 1
reghdfe rem polluted post i.polluted#i.post $control_variables, absorb(fyear ff_48) vce(robust)
restore

* tornado
sort lpermno fyear
bysort lpermno: gen tornado_shock = tornado - tornado[_n-1]
replace tornado_shock =. if  post == 0
br lpermno fyear visib visib_change drastic polluted clean post rem tornado tornado_shock pair

bysort pair: replace tornado_shock = tornado_shock[_n+1] if tornado_shock ==.
reghdfe rem tornado post c.tornado#i.post $control_variables, absorb(fyear ff_48) vce(robust)

* mxspd - max wind speed
sort lpermno fyear
bysort lpermno: gen mxspd_shock = mxspd - mxspd[_n-1]

br lpermno fyear post pair mxspd mxspd_shock

	ta mxspd_shock if post == 0
replace mxspd_shock =. if post == 0
egen mxspd_std1 = sd(mxspd) if !mi(mxspd_shock)
gen drastic_mxspd = (abs(mxspd_shock) >= mxspd_std1) if !mi(mxspd_shock)
gen mxspd_in = (mxspd_shock > 0 & drastic_mxspd == 1) if !mi(mxspd_shock)
gen mxspd_de = (mxspd_shock <= 0 & drastic_mxspd == 1) if !mi(mxspd_shock)

* fill values for each pair
foreach var of varlist mxspd_shock drastic_mxspd mxspd_in mxspd_de{
	bysort pair: replace `var' = `var'[_n+1] if mi(`var')
}

reghdfe rem mxspd_in mxspd_de post i.mxspd_in#i.post i.mxspd_de#i.post $control_variables, absorb(fyear ff_48) vce(robust)

*wdsp
sort lpermno fyear
bysort lpermno: gen wdsp_shock = wdsp - wdsp[_n-1]

br lpermno fyear post pair wdsp wdsp_shock

	ta wdsp_shock if post == 0
replace wdsp_shock =. if post == 0
egen wdsp_std1 = sd(wdsp) if !mi(wdsp_shock)
gen drastic_wdsp = (abs(wdsp_shock) >= wdsp_std1) if !mi(wdsp_shock)
gen wdsp_in = (wdsp_shock > 0 & drastic_wdsp == 1) if !mi(wdsp_shock)
gen wdsp_de = (wdsp_shock <= 0 & drastic_wdsp == 1) if !mi(wdsp_shock)

* fill values for each pair
foreach var of varlist wdsp_shock drastic_wdsp wdsp_in wdsp_de{
	bysort pair: replace `var' = `var'[_n+1] if mi(`var')
}

reghdfe rem wdsp_in wdsp_de post i.wdsp_in#i.post i.wdsp_de#i.post $control_variables, absorb(fyear ff_48) vce(robust)
