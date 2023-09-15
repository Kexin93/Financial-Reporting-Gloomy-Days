clear
else if "`c(username)'" == "kexin"{
global maindir "E:\21. Air Pollution and Accounting\DATA"
}

else if "`c(username)'" == "Huaxi"{
global maindir "E:\Dropbox\Air Pollution and Accounting\Data"
}


* firm data
use "$maindir\Accounting Variables\conv.dta"
	count if loc == "USA" & mi(addzip) //all USA firms have zip codes! 114,365
		keep if fyear >= 2003
		count //52593
	drop if loc != "USA" // only keep USA firms: 102,193, 7287
	gen addzip2 = substr(addzip, 1, 5)
	
	
	* backward: change some zipcodes that cannot be matched to any zipcode
	replace addzip2 = "02203" if add1 == "28 State Street"
	replace addzip2 = "02125" if add1 == "135 MORRISSEY BOULEVARD"
	replace addzip2 = "02451" if add1 == "266 Second Avenue"
	replace addzip2 = "02130" if add1 == "400 Centre St"
	replace addzip2 = "02472" if add1 == "500 Arsenal St"
	replace addzip2 = "02420" if add1 == "1776 Massachusetts Avenue"
	replace addzip2 = "02481" if add1 == "Sun Life Executive Park"
	replace addzip2 = "02494" if add1 == "197 First Avenue"
	replace addzip2 = "02451" if add1 == "275 WYMAN STREET"
	replace addzip2 = "06824" if add1 == "55 WALLS DRIVE"
	replace addzip2 = "10604" if add1 == "2000 Westchester Avenue"
	replace addzip2 = "02451" if add1 == "69 Hickory Drive"
	replace addzip2 = "02421" if add1 == "20 Maguire Road"
	replace addzip2 = "02494" if add1 == "115 Fourth Avenue"
	replace addzip2 = "02451" if add1 == "101 First Avenue"
	replace addzip2 = "20166" if add1 == "Washington Dulles International Airport, 300 West Service Ro"
	replace addzip2 = "20170" if add1 == "575 Herndon Parkway"
	replace addzip2 = "20176" if add1 == "44084 Riverside Parkway, Landsdowne Business Center"
	replace addzip2 = "20191" if add1 == "1800 Alexander Bell Drive"
	replace addzip2 = "24540" if add1 == "103 Tower Drive, P.O. Box 1001"
	replace addzip2 = "28262" if add1 == "201 McCullough Drive, Suite 200"
	replace addzip2 = "30099" if add1 == "3120 Breckinridge Boulevard"
	replace addzip2 = "30004" if add1 == "1105 Sanctuary Parkway, Suite 100"
	replace addzip2 = "30005" if add1 == "1121 Alderman Drive"
	replace addzip2 = "30046" if add1 == "750 Perry Street Sw, P.O. Box 2000"
	replace addzip2 = "32202" if add1 == "One Independent Drive"
	replace addzip2 = "33324" if add1 == "1333 S. University Drive, Suite 202"
	replace addzip2 = "34108" if add1 == "5801 Pelican Bay Boulevard"
	replace addzip2 = "34236" if add1 == "22 South Links Avenue"
	replace addzip2 = "33760" if add1 == "15950 Bay Vista Dr Ste 240"
	replace addzip2 = "45402" if add1 == "907 West Fifth Street"
	replace addzip2 = "48304" if add1 == "505 North Woodward"
	replace addzip2 = "48341" if add1 == "761 W. Huron Street"
	replace addzip2 = "53158" if add1 == "One Terra Way, 8601 95th Street"
	replace addzip2 = "61350" if add1 == "122 West Madison Street"
	replace addzip2 = "75081" if add1 == "1212 East Arapaho Rd"
	replace addzip2 = "92868" if add1 == "1100 Town & Country Rd, Ste 900"
	replace addzip2 = "92618" if add1 == "7700 Irvine Center Drive, Suite 870"
	replace addzip2 = "92821" if add1 == "330 E Lambert Rd"
	replace addzip2 = "92841" if add1 == "7441 Lincoln Way Ste 100"
	replace addzip2 = "92780" if add1 == "2742 Dow Avenue"
	replace addzip2 = "92614" if add1 == "17862 Fitch"
	replace addzip2 = "92612" if add1 == "2201 DUPONT DRIVE"
	replace addzip2 = "92618" if add1 == "50 TECHNOLOGY DRIVE"
	replace addzip2 = "95054" if add1 == "3200 Patrick Henry Drive"
	replace addzip2 = "30005" if add1 == "100 Alderman Drive, PO Box 2470"
	replace addzip2 = "02494" if add1 == "119 Fourth Avenue"
	replace addzip2 = "92780" if add1 == "1382 Bell Avenue"
	replace addzip2 = "92780" if add1 == "14351 MYFORD ROAD"
	replace addzip2 = "92618" if add1 == "15091 Bake Parkway"
	replace addzip2 = "92618" if add1 == "15370 Barranca Parkway"
	replace addzip2 = "92618" if add1 == "16215 Alton Pkwy"
	replace addzip2 = "92780" if add1 == "17752 E 17th St"
	replace addzip2 = "02494" if add1 == "197 First Avenue, Suite 300 Heights"
	replace addzip2 = "02451" if add1 == "245 WINTER STREET"
	replace addzip2 = "92614" if add1 == "2652 MCGAW AVENUE"
	replace addzip2 = "30005" if add1 == "3015 Windward Plaza, Windward Fairways Ii"
	replace addzip2 = "02451" if add1 == "400-2 Totten Pond Rd"
	replace addzip2 = "02452" if add1 == "411 Waverley Oaks Road"
	replace addzip2 = "02452" if add1 == "411 Waverley Oaks Road, Suite 227"
	replace addzip2 = "20170" if add1 == "460 HERNDON PARKWAY"
	replace addzip2 = "48226" if add1 == "500 North Woodward Avenue"
	replace addzip2 = "02451" if add1 == "610 Lincoln Street, Suite 300"
	replace addzip2 = "02451" if add1 == "716 Main St"
	replace addzip2 = "02453" if add1 == "800 South Street"
	
	
* zipcode information
	preserve
		clear
		use "$maindir\Zipcode Information\ZipCode"
		unique ZipCode
		rename ZipCode addzip2
		tempfile Zipcode_info
		save `Zipcode_info'
	restore
	
	merge m:1 addzip2 using `Zipcode_info'
	
		sort add1 addzip2
	edit addzip2 add1 city county incorp if _merge == 1 //45 firms do not match to any zipcodes
	
	drop if _merge == 1 //45 dropped, 13
	
	drop if _merge == 2 // 38,308 dropped, unused zipcodes in the USA

	* Generate Firm identifier (firm_year_ID)
	gen firm_ID = _n

	* Drop all firms with no apdedate
	keep if !mi(fyr)
	*keep if !mi(apdedate)
	
	* 45065 observations
	tempfile firm_zipcode
	save `firm_zipcode'
	save "$maindir\firm_zipcode", replace
	
	
	preserve
		keep firm_ID addzip2 ZipCodeLatitude ZipCodeLongitude ZipCodeCity ZipCodeState ZipCodeCounty
		export excel "$maindir\firm_zipcode.xlsx", firstrow(variables) replace
	restore
	
