
/* Master Thesis WS 2019/20

* MAIN

Does the first steps of the data preparation. csv files with data counting all observations (unlike in "main_filter") from the Buildings and Dwellings Census are imported, cleaned, attached etc. 
Uses csv files downloaded from Statistics Austria's Database.
Main links to namesandlabels1.
The output of main is either used directly by vz, which joines the variables from the census, or by main_filter which substracts the number of dwellings with less then three apartments from every cell. 

*/

cd "\\fs.univie.ac.at\homedirs\alexanderg15\Documents\WS_201920\Masterarbeit\Daten"

clear
graph drop _all

********************************************************************************

* DATA PREPARATION

********************************************************************************
* basic data: from Gebäude- und Wohnungszählung (GWZ)
* bringing data sets in proper form and save as .dta files before merging them

foreach x in Bukae NoeOoeSa SteVoTiWien {

foreach w in Wohnsitzangabe Ausstattung Rechtsgrund {

insheet using "`x'`w'.csv", clear delimiter(";")

drop if _n < 10
drop if _n == 2

rename v1 syear
rename v2 built
rename v3 owner
rename v4 distr

local j = 5
mat def c = c(k)
sca c = c[1,1]

while `j' > 4 & `j' <= c {

    local name = strtoname(strtrim(v`j'[1]))
    capture rename v`j'  `name'
	
local j = `j' + 1
}

foreach v of varlist _all {

if `v'[2] == "" {
drop `v'
}

}

drop if _n == 1

gen n = _n

foreach v in syear built owner {

replace `v' = `v'[n-1] if `v' == "" & n[n-1] == n-1

}

drop n
save `x'`w'.dta, replace
clear

}
}


* and merge them to one big data set

foreach x in Bukae NoeOoeSa SteVoTiWien {

use `x'Wohnsitzangabe

joinby syear built owner distr using `x'Ausstattung
joinby syear built owner distr using `x'Rechtsgrund

save `x', replace
clear

}

append using Bukae NoeOoeSa SteVoTiWien

********************************************************************************

order syear distr built owner 
sort syear distr built owner 

do namesandlabels1

egen rowtot = rowtotal(mainres vac)

* save

save prepdata1, replace

********************************************************************************

* Next steps: go directly to vz, which does further cleansing and joins census data variables, or do main_filter, which does the same as main for those dwellings with less than 3 appartments, substracts it from the main dataset and then links to vz



clear
use prepdata1
do vz
save prepdata2, replace

*/



































