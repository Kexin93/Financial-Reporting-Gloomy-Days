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

set matsize 5000

*======== Table 4: Regression (Absolute) =============================
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

*============== External Scrutiny: Auditor's Unqualified Opinion & Coastal ============
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
		
destring auop, replace
	capture drop good_opinion
gen good_opinion = (auop == 1) if (auop == 1 | auop == 4) 
	label var good_opinion "Auditor's Unqualifed Opinion"

eststo regression3: reghdfe rem visib $control_variables coastal i.coastal#c.visib, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local blcontrols "Yes", replace

eststo regression6: reghdfe rank_rem visib $control_variables coastal i.coastal#c.visib, absorb(fyear ff_48) vce(robust)
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
prehead("\begin{table}\begin{center}\caption{Coastal Region and Auditor's Unqualified Opinion}\label{tab: table9}\tabcolsep=0.1cm\begin{tabular}{lcccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}\end{center}\\\footnotesize{Notes: This table reports the effects of visibility on the aggregate measure of real earnings management (REM) and the rank of REM. A description of all variables can be found in Table \ref{tab: variabledescriptions}. Columns (1)-(3) report the effects of visibility on REM, and columns (4)-(6) report the effects of visibility on the rank of REM. Columns (1) and (4) are the baseline specifications. Columns (2) and (5) include financial constraints as an additional control. Columns (3) and (6) further include auditor's unqualified opinion as an additional control. Firm controls are the same as in Table \ref{tab: table4}. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are heteroskedastic-robust. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

esttab regression1 regression2 regression3 regression4  regression5 regression6 using "$output\Word_results.rtf", append ///
mgroups("Real Earnings Management" "Rank of Real Earnings Management", pattern(1 0 0 1 0 0)) ///
nomtitles collabels(none) label scalar(ymean) drop($control_variables) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
title("Table 9: The Effect of Visibility on Earnings Management (with Additional Controls)") ///
note("Notes: The dependent variable in columns (1)-(3) is a firm's real earnings management; the dependent variable in columns (4)-(6) is the rank of a firm's real earnings management.")


* Environmental Expenses
xtset lpermno fyear
gen xsga_scale = xsga/l1.at

label var xsga_scale "Admin. Expenses"

	eststo clear
eststo regression1: reghdfe dac visib $control_variables xsga_scale c.xsga_scale#c.visib, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression2: reghdfe rank_dac visib $control_variables xsga_scale c.xsga_scale#c.visib, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rank_dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression3: reghdfe rem visib $control_variables xsga_scale c.xsga_scale#c.visib, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression4: reghdfe rank_rem visib $control_variables xsga_scale c.xsga_scale#c.visib, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rank_rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

esttab regression1 regression2 regression3 regression4 using "$output\table20.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
mtitles("AEM" "AEM Rank" "REM" "REM Rank") collabels(none) booktabs label scalar(ymean) drop($control_variables) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management}\label{tab: table4}\tabcolsep=0.1cm\begin{tabular}{lcccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}\end{center}\\\footnotesize{Notes: The dependent variables are indicated at the top of each column. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variables in columns (1)-(2) are: a firm's accrual earnings management, and the rank of the firm's accrual earnings management, respectively. The dependent variables in columns (3)-(4) are: a firm's real earnings management, and the rank of the firm's real earnings management, respectively. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are heteroskedastic-robust. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

esttab regression1 regression2 regression3 regression4 using "$output\Word_results.rtf", append ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 1 0)) ///
mtitles("AEM" "AEM Rank" "REM" "REM Rank") nonumbers collabels(none) label scalar(ymean`') drop($control_variables) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
title("Table 4: The Effect of Visibility on Earnings Management") ///
note("Notes: The dependent variable in columns (1)-(2) is a firm's accrual earnings management; the dependent variable in columns (3)-(4) is a firm's real earnings management.")

*======== Table 4: Regression (Signed) Subsample where ENV indicators are not missing =============================
	eststo clear
eststo regression1: reghdfe dac visib $control_variables if !mi(ENV_str_num_L), absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression2: reghdfe rank_dac visib $control_variables if !mi(ENV_str_num_L), absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rank_dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression3: reghdfe rem visib $control_variables if !mi(ENV_str_num_L), absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression4: reghdfe rank_rem visib $control_variables if !mi(ENV_str_num_L), absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rank_rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

esttab regression1 regression2 regression3 regression4 using "$output\table4_EnvSubsample.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
mtitles("AEM" "AEM Rank" "REM" "REM Rank") collabels(none) booktabs label scalar(ymean) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management}\label{tab: table4}\tabcolsep=0.1cm\begin{tabular}{lcccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}\end{center}\\\footnotesize{Notes: The dependent variables are indicated at the top of each column. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variables in columns (1)-(2) are: a firm's accrual earnings management, and the rank of the firm's accrual earnings management, respectively. The dependent variables in columns (3)-(4) are: a firm's real earnings management, and the rank of the firm's real earnings management, respectively. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are heteroskedastic-robust. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

esttab regression1 regression2 regression3 regression4 using "$output\Word_results.rtf", append ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 1 0)) ///
mtitles("AEM" "AEM Rank" "REM" "REM Rank") nonumbers collabels(none) label scalar(ymean`') ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
title("Table 4: The Effect of Visibility on Earnings Management") ///
note("Notes: The dependent variable in columns (1)-(2) is a firm's accrual earnings management; the dependent variable in columns (3)-(4) is a firm's real earnings management.")


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

*======== Table 4: Regression (Signed) Subsample where Overall CSR indicators are not missing =============================
	eststo clear
eststo regression1: reghdfe dac visib $control_variables /*if !mi(CSR_Str)*/, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression2: reghdfe rank_dac visib $control_variables /*if !mi(CSR_Str)*/, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rank_dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression3: reghdfe rem visib $control_variables /*if !mi(CSR_Str)*/, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

eststo regression4: reghdfe rank_rem visib $control_variables /*if !mi(CSR_Str)*/, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rank_rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace

esttab regression1 regression2 regression3 regression4 using "$output\table4_CSRSubsample.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
mtitles("AEM" "AEM Rank" "REM" "REM Rank") collabels(none) booktabs label scalar(ymean) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management}\label{tab: table4}\tabcolsep=0.1cm\begin{tabular}{lcccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}\end{center}\\\footnotesize{Notes: The dependent variables are indicated at the top of each column. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variables in columns (1)-(2) are: a firm's accrual earnings management, and the rank of the firm's accrual earnings management, respectively. The dependent variables in columns (3)-(4) are: a firm's real earnings management, and the rank of the firm's real earnings management, respectively. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are heteroskedastic-robust. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

esttab regression1 regression2 regression3 regression4 using "$output\Word_results.rtf", append ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 1 0)) ///
mtitles("AEM" "AEM Rank" "REM" "REM Rank") nonumbers collabels(none) label scalar(ymean`') ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
title("Table 4: The Effect of Visibility on Earnings Management") ///
note("Notes: The dependent variable in columns (1)-(2) is a firm's accrual earnings management; the dependent variable in columns (3)-(4) is a firm's real earnings management.")

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
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management}\label{tab: table4}\tabcolsep=0.1cm\begin{tabular}{lcccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}\end{center}\\\footnotesize{Notes: The dependent variables are indicated at the top of each column. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variables in columns (1)-(2) are: a firm's accrual earnings management, and the rank of the firm's accrual earnings management, respectively. The dependent variables in columns (3)-(4) are: a firm's real earnings management, and the rank of the firm's real earnings management, respectively. Year fixed effects and industry fixed effects are included in all regressions. Standard errors are heteroskedastic-robust. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

esttab regression1 regression2 regression3 regression4 using "$output\Word_results.rtf", append ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 1 0)) ///
mtitles("AEM" "AEM Rank" "REM" "REM Rank") nonumbers collabels(none) label scalar(ymean`') ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
title("Table 4: The Effect of Visibility on Earnings Management") ///
note("Notes: The dependent variable in columns (1)-(2) is a firm's accrual earnings management; the dependent variable in columns (3)-(4) is a firm's real earnings management.")


*========== Table 8: External Monitoring? Analyst ======================== Yes, add cover (#of analysts following) as a mechanism
	eststo clear
eststo regression1: reghdfe cover visib $control_variables, absorb(fyear ff_48) vce(robust) //c.?
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression2: reghdfe cover visib $control_variables, absorb(fyear ff_48) vce(robust) //c.?
estadd scalar ar2 = e(r2_a)
summarize dac
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression3: reghdfe cover visib $control_variables, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

eststo regression4: reghdfe cover visib $control_variables, absorb(fyear ff_48) vce(robust)
estadd scalar ar2 = e(r2_a)
summarize rem
estadd scalar ymean = r(mean)
estadd local yearfe "Yes", replace
estadd local indfe "Yes", replace
estadd local firmcont "Yes", replace

esttab regression1 regression2 regression3 regression4 using "$output\table8.tex", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) drop($control_variables) ///
mtitles("AEM" "AEM Rank" "REM" "REM Rank") collabels(none) booktabs label scalar(ymean) ///
stats(yearfe indfe firmcont N ymean ar2, fmt(0 0 0 0 2 2) labels("Year FE" "Industry FE" "Firm Controls" "N" "Dep mean" "Adjusted R-sq")) ///
prehead("\begin{table}\begin{center}\caption{The Effect of Visibility on Earnings Management by the Degree of External Control}\label{tab: table8}\tabcolsep=0.1cm\begin{tabular}{lcccccc}\toprule")  ///
posthead("\midrule") postfoot("\bottomrule\end{tabular}\\\end{center}\footnotesize{Notes: This table reports how the effects of visibility on AEM, the rank of AEM, REM, and the rank of REM differ by the degree of external monitoring. A description of all variables can be found in Table \ref{tab: variabledescriptions}. The dependent variable in column (1) is AEM, the dependent variable in column (2) is the rank of AEM, the dependent variable in column (3) is REM, and the dependent variable in column (4) is the rank of REM. Firm controls are the same as in Table \ref{tab: table4}.  Year fixed effects and industry fixed effects are included in all regressions. Standard errors are heteroskedastic-robust. *** p < 1\%, ** p < 5\%, * p < 10\%.}\end{table}") 

esttab regression1 regression2 regression3 regression4 using "$output\Word_results.rtf", replace ///
mgroups("Accrual Earnings Management" "Real Earnings Management", pattern(1 0 1 0)) ///
mtitles("AEM" "AEM Rank" "REM" "REM Rank") nonumbers collabels(none) label scalar(ymean) ///
stats(yearfe indfe N ymean ar2, fmt(0 0 0 2 2) labels("Year FE" "Industry FE" "N" "Dep mean" "Adjusted R-sq")) ///
title("Table 8: The Effect of Visibility on Earnings Management by the Degree of External Control") ///
note("Notes: The dependent variable in columns (1)-(2) is a firm's accrual earnings management; the dependent variable in columns (3)-(4) is a firm's real earnings management. The variable cover refers to the number of analysts that follow the firm.")

