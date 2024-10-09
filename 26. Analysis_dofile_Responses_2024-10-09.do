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

use "$maindir\Analysis_102148 observations\firm_year_stations_48332.dta", replace
bysort lpermno fyear (station): gen dup = _n

drop if dup > 1

count // 47662, unique lpermno fyear

tempfile firm_year47662
save `firm_year47662', replace

use "$maindir\Accounting Variables\conv.dta", replace
destring sic, replace
keep lpermno fyear sic
tempfile conv
save `conv', replace

use `firm_year47662', replace
merge 1:1 lpermno fyear using `conv', gen(m)
keep if m == 1 | m == 3

gen finance_industry = (inrange(sic, 6011, 6099) | inrange(sic, 6111, 6163) | sic == 6211 | sic == 6712) if !mi(sic)

ta finance_industry

* There are 5156 observations in finance industry among the 47662 firm-year observations

gen utilities_industry = (inrange(sic, 4900, 4999)) if !mi(sic)

ta utilities_industry

count if utilities_industry == 1 | finance_industry == 1

drop if utilities_industry == 1 | finance_industry == 1

count // 40368
