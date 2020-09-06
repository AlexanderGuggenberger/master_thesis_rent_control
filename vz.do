
/* Master Thesis WS 2019/20

* VZ

Continue data preparation, mainly by adding the variables from the census
Vz links to namesandlabels2 and to columnsums and is itself accessed by main or main_filter
The output is ready for the models

*/

cd "\\fs.univie.ac.at\homedirs\alexanderg15\Documents\WS_201920\Masterarbeit\Daten"

* clear
* graph drop _all

* use prepdatafilter1
* use prepdata1

* note: if vz is accessed via main or main_filter, file need not be loaded and workspace need not be cleared

********************************************************************************

* generate column sums by group

do columnsums

* renaming and labelling

do namesandlabels2


********************************************************************************
* generate percentages of GWZ variables (used by the do file "analysis" for model with percentage outcome)

foreach v in $vars {

gen pc`v' = `v'/rowtot

}

********************************************************************************
* declare as panel data

decode distrlabel, gen(distr)
drop distrlabel

gen group = distr+" "+built+" "+owner

encode group, gen(groupid) label(group)
drop group

xtset groupid syear, delta(10)

save prepdata12, replace

* as this is only temporary, I do not differ between filter and no filter in the filename

********************************************************************************

* FURTHER VARIABLES FROM VOLKSZÄHLUNG (VZ)

********************************************************************************



* import additional data on district level and add it to data set

foreach w in Staatsangehoerigkeit Alter Bildungsstand Lebensgemeinschaftsform Beruf Pendelzeitperwohnbezirk Pendelzeitperarbeitsbezirk {

insheet using "`w'.csv", clear delimiter(";")

gen aux1 = 1 if v1 == "Zeit"
gen ones = 1
gen aux2 = sum(ones)
gen aux3 = sum(aux2) if aux1 == 1
gen n = _n
replace aux3 = aux3[n-1] if aux3 == . & n[n-1] == n-1

sca p = aux3[20] - 2

drop aux* ones n

drop if _n <= p
drop if _n == 2

rename v1 syear
rename v2 distr

local j = 3
mat def c = c(k)
sca c = c[1,1]

local c = c
drop v`c'

while `j' > 2 & `j' <= c - 1 {

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

foreach v in syear distr {

replace `v' = `v'[n-1] if `v' == "" & n[n-1] == n-1

}

drop n

drop if syear != "1971" & syear != "1981" & syear != "1991" & syear != "2001"

foreach v of varlist _all {

replace `v' = "." if `v' == "-"

}

destring _all, replace

save `w'.dta, replace
clear

use prepdata12
joinby syear distr using `w', unmatched(master)
drop _merge

save prepdata12, replace
clear

}



********************************************************************************

* cleansing, summing and renaming of demographic district level variables

use prepdata12

order syear distr built owner
rename v3 Oesterreich
format distr %40s

* citizenship

rename Oesterreich Austria
rename Nicht_*rg aliens
rename EU_Staat Eu
rename Jugo* Jugoslawia
rename T*rkei Turkey
rename sonstiges_Ausland nonEu

gen inhabitants = Austria + aliens

* age groups

egen children = rowtotal(bis_4_Jahre _5_bis_9_Jahre _10_bis_14_Jahre _15_bis_19_Jahre)
egen youngadults = rowtotal(_20_bis_24_Jahre _25_bis_29_Jahre)
egen adults = rowtotal(_30_bis_34_Jahre _35_bis_39_Jahre _40_bis_44_Jahre _45_bis_49_Jahre _50_bis_54_Jahre _55_bis_59_Jahre)
egen seniors = rowtotal(_60_bis_64_Jahre _65_bis_69_Jahre _70_bis_74_Jahre _75_bis_79_Jahre _80_bis_84_Jahre _85_bis_89_Jahre _90_bis_94_Jahre _95_Jahre*)

drop bis_4_Jahre-_90_bis_94_Jahre _95_Jahre*

* education 

rename Universi* uni
egen tertiary = rowtotal(uni Berufs__und* Kolleg*)
egen secundary = rowtotal(Berufsbil* Allgemeinbildende_h* Lehrling*)
rename Allgemeinbildende_Pflicht* primary

drop Berufs__und_lehrerbildende_Akade-Lehrlingsausbildung__8_

* civil status

rename verheiratet__mit* married

drop verheiratet__Ehepart__nicht_im_s-Nicht_klassifizierbar__0_

* job status

rename selbst* selfemp
rename nicht_Erwerbsperson notworking
rename unselbst* clark

* commuting - note that this refers to those who work in this district, not those who live there!
* as commuters count those with more than 45 minutes distance - I assume that some of these might want to move to this districts, putting pressure on the housing market

egen commuter = rowtotal(Tagespendler__Wegzeit_46_bis_60_ Tagespendler__Wegzeit_61_und_meh)
drop Tagespendler* Nicht*

* compute shares

global demvars "Austria aliens Eu Jugoslawia Turkey nonEu uni primary married selfemp notworking clark inhabitants children youngadults adults seniors tertiary secundary commuter"

foreach v in $demvars {

gen pc`v' = `v'/inhabitants

}

********************************************************************************

* classify districts:
* only Statutarstädte

gen city = (distrid == 304 | distrid == 102 | distrid == 601 | distrid == 701 | distrid == 201 | distrid == 301 | distrid == 401 | distrid == 501 | distrid == 302 | distrid == 402 | distrid == 202 | distrid == 303 | distrid == 403 | distrid == 101 | stateid == 9)

gen region = "west" if distrid == 5 | stateid == 7 | stateid == 8
replace region = "east" if region != "west"


gen syear2 = syear^2

/* main and main_filter save the file, if vz was accessed via them

save prepdata2, replace
save prepdatafilter2, replace






