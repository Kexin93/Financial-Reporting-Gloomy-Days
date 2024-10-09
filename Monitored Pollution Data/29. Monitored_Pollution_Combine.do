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

		cd "E:\21. Air Pollution and Accounting\DATA\PMdata\PM2_5_output_files"
		clear 
		forvalues var = 1/11590{
			use `var'.dta, replace
			gen Num = `var'
			save `var'.dta, replace
		}
		fs "*.dta"
		append using `r(files)',force
		sort Num
			
			capture drop dup
		bysort Num: gen dup=_n
			drop if dup == 2
			drop dup
			unique Num
			label var Num "ID"
			order Num
		save "$maindir\PMdata\PM2_5_combined.dta", replace
		
use "$output\final_data_47662_utilitiesDelete.dta", replace
merge 1:1 Num using "$maindir\PMdata\PM2_5_combined.dta", gen(m)
keep if m == 1 | m == 3

	label var arithmeticmean "Monitored PM 2.5"
	label var aqi "AQI"
save "$maindir\PMdata\final_data_47662_withMonitored.dta", replace



