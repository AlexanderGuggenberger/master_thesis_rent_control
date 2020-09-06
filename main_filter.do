
/* Master Thesis WS 2019/20

Main_filter

Preparation of dataset with only dwellings in buildings with one or two flats.
I do the same as in "main" for the entire data set, in the end, I only sum up the lines for one and for two flats
Finally, I substract this whole dataset from the actual main dataset and thus obtain a filtered dataset with all dwellings in buildings with more than two buildings.
 
*/
 
cd "\\fs.univie.ac.at\homedirs\alexanderg15\Documents\WS_201920\Masterarbeit\Daten"

clear
graph drop _all

********************************************************************************

* DATA PREPARATION

********************************************************************************
* basic data: from Gebäude- und Wohnungszählung (GWZ)
* bringing data sets in proper form and save as .dta files before merging them

foreach x in BuKaeNoe OoeSaSt TiVoWi {

foreach w in Wohnsitzangabe Ausstattung Rechtsgrund {

insheet using "`x'`w'Filter.csv", clear delimiter(";")

drop if _n < 10
drop if _n == 2

rename v1 syear
rename v2 built
rename v3 owner
rename v4 distr
rename v5 nflats

gen n = _n

foreach v in syear built owner distr nflats {

replace `v' = `v'[n-1] if `v' == "" & n[n-1] == n-1

}

drop n

local j = 6
mat def c = c(k)
sca c = c[1,1]

while `j' > 5 & `j' <= c {

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

save `x'`w'Filter.dta, replace
clear

}
}


* and merge them to one big data set

foreach x in BuKaeNoe OoeSaSt TiVoWi {

use `x'WohnsitzangabeFilter

joinby syear built owner distr nflats using `x'AusstattungFilter
joinby syear built owner distr nflats using `x'RechtsgrundFilter

save `x'Filter, replace
clear

}

append using BuKaeNoeFilter OoeSaStFilter TiVoWiFilter

********************************************************************************

order syear distr built nflats owner 
sort syear distr built nflats owner 

do namesandlabels1

* generate total rowsum first - needed in columnsum programm already
egen rowtot = rowtotal(mainres vac)


********************************************************************************

* sum the rows for one and two flats (like I do it in column sums)

rename flatowner flato
rename houseowner houseo
rename selfused selfu

global vars "mainres vac A B C D E flato houseo rented service other selfu rowtot"

replace nflats = "1" if nflats == "1 Wohnung"
replace nflats = "2" if nflats == "2 Wohnungen"


gen syeardistrid = syear+"qy"+distrid
gen builtownernflats = built3+"qy"+owner+"qy"+nflats

drop syear built built2 built3 owner distrid distr nflats

reshape wide $vars, i(syeardistrid) j(builtownernflats) string

foreach v in $vars {
foreach w in before1919 1919to1944 1945to1960 1961to1980 1981to1990 after1991 {
foreach x in char fed manypriv muni onepriv oth othleg othpub state {

egen `v'`w'qy`x'qy12 = rowtotal(`v'`w'qy`x'qy1 `v'`w'qy`x'qy2)

}
}
}

reshape long

********************************************************************************

rename flato flatowner
rename houseo houseowner
rename selfu selfused


split syeardistrid, p("qy") gen(a)
rename a1 syear
rename a2 distrid

split builtownernflats, p("qy") gen(b)
rename b1 built
rename b2 owner
rename b3 nflats


drop syeardistrid builtownernflats

order syear distrid built owner nflats
sort syear distrid built owner nflats

* keep only if number of flats is 12, i.e. keep the rows that aare the sum

keep if nflats == "12"
drop nflats distrlabel

* rename the variables such that later I can subtract them from the main data set variables

foreach v in $vars {

rename `v' twoflats`v'

}

* finished: data set counting only apartments in buildings with maximum 2 flats

********************************************************************************

* now join it with and subtract it from the main data set, st. all the numbers only count dwellings with more than 2 appartments

rename built built3

joinby syear distrid built3 owner using prepdata1

rename twoflatsflato twoflatsflatowner
rename twoflatshouseo twoflatshouseowner
rename twoflatsselfu twoflatsselfused

foreach v in mainres vac A B C D E flatowner houseowner rented service other selfused rowtot {

replace `v' = `v' - twoflats`v' if twoflats`v' != 0 & twoflats`v' != .
drop twoflats`v'

}

save prepdatafilter1, replace

********************************************************************************

* no I can continue like with the normal data set before, i.e. do some further cleansing and join with Census data, scripted in vz

do vz

********************************************************************************

* DEAL WITH MISSINGS: 

* some of them are actually zeros. Assume a missing is actually zero if other percentages for same variable type are non zero and sum up to one

* categories

egen rowtotcat = rowtotal(pcA pcB pcC pcD pcE)

foreach v in pcA pcB pcC pcD pcE {
replace `v' = 0 if `v' == . & rowtotcat > 0.99
}

* user

egen rowtotuser = rowtotal(pcflatowner pchouseowner pcrented pcservice pcother pcselfused)

foreach v in pcflatowner pchouseowner pcrented pcservice pcother pcselfused {
replace `v' = 0 if `v' == . & rowtotcat > 0.99
}

* citizenship

* Yugoslawia was not asked again in 2001, and I cannot reconstruct it --> drop it

drop Jugoslawia 



* rest should be fine, no systematic missings, or missings that could be dealt with easily

save prepdatafilter2, replace

* then continue to analysis or analysis_weighted_logit


















