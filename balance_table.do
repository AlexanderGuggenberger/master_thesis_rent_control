
/* Master Thesis WS 2019/20

* BALANCE TABLE

Produces balance table

*/

cd "\\fs.univie.ac.at\homedirs\alexanderg15\Documents\WS_201920\Masterarbeit\Daten"

clear
use prepdatafilter2
* use prepdata2

global filter f
* f ... only those with more than two apartments, n ... no filter. Appears in file names and titles

global owner "total"
global year "all_years"
* determines for which owners and years balance table will be generated

********************************************************************************

* BALANCE TABLE
* total, just before vs just after 1945

global btvars "mean_all mean_1919to1944 mean_1945to1960 difference p_value"

* I can only do a comparison of weighted means of GWZ variables, as I have the VZ variables only on district-, not group level

gen varname=""
quietly foreach v in $btvars {
gen double `v' = .
}

* generate a treatment indicator

gen treat = 1 if built == "1919to1944"
replace treat = 0 if built == "1945to1960"
drop if treat == . & built != "all"
drop if owner != "$owner"
* drop if syear != $year



local i=1
quietly foreach v in vac A B C D E flatowner houseowner rented service other selfused {

* fill in values for total and by group

foreach w in "all" "1919to1944" "1945to1960" {
replace varname="`v'" in `i'

quiet total rowtot if built == "`w'"
quiet mat def a = e(b)
quiet total `v' if built == "`w'"
quiet mat def b = e(b)

replace mean_`w' = round(b[1,1]/a[1,1], .001) in `i'

* number of observations by group:
scalar obs_`w'=a[1,1]

}

* comparison of means
replace difference = round(abs(mean_1919to1944[`i'] - mean_1945to1960[`i']), .001) in `i'

* ttest: do it as a regression, otherwise hard to do the frequency weights
reg `v' i.treat [fw = rowtot], vce(cluster distr)
quiet mat def c = r(table)
replace p_value = round(c[4,2], .001) in `i'

local i = `i' + 1

}

* add number of observations in an extra row
replace varname="n" in 13
replace mean_all = obs_all in 13
replace mean_1919to1944 = obs_1919to1944 in 13
replace mean_1945to1960 = obs_1945to1960 in 13
replace difference = 0 in 13
replace p_value = 0 in 13

* convert to matrix and export as table
format mean_all mean_1919to1944 mean_1945to1960 difference p_value %9.3f
mkmat $btvars, matrix(bt$year$filter) nomissing rownames(varname)

outtable using bt$year$filter$owner, mat(bt$year$filter) replace center caption("Balance Table of GWZ Variables - $year, $filter")




























