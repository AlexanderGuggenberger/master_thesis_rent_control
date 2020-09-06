
/* Master Thesis WS 2019/20

TIMELINES

* numbers (not rates)

*/

preserve

$region
$othercond

local varofint = "$varofint"

foreach v in "old" "new" "all" "1919to1944" "1945to1960" "before1919" "1961to1980" "1981to1990" "after1991"{
foreach x in `varofint' rowtot {

gen `x'`v' = .

foreach w in 1971 1981 1991 2001 {

quiet total `x' if built == "`v'" & syear == `w' & owner == "$owner"
quiet mat def a = e(b)

local y = round(`w'/10) - 196
* so scalars are named 1 2 3 4 (better for later)

quiet sca tot`x'`v'`y' = a[1,1]

replace `x'`v' = tot`x'`v'`y' in `y'

}
}
}


label variable vacold old
label variable vacnew new
label variable vacall all
label variable vac1919to1944 "1919 to 1944"
label variable vac1945to1960 "1945 to 1960"
label variable vac1961to1980 "1961 to 1980"
label variable vac1981to1990 "1981 to 1990"
label variable vacafter1991 "after 1991"


gen year = _n

lab def time 1 "1971" 2 "1981" 3 "1991" 4 "2001", replace
lab values year time

* plot all construction year-groups
twoway (line `varofint'old-`varofint'1961to1980 year, mcolor(navy) lcolor(navy) xlab(,val)) if year<=4, xline(2) graphregion(fcolor(white)) name(abs`varofint'all$owner$region1$filter, replace) title("vacancies (abs. num.) by construction period $region1")
graph export abs`varofint'all$owner$region1$filter.pdf, replace

* plot old vs new
twoway (line `varofint'old `varofint'new year, mcolor(navy) lcolor(navy) xlab(,val)) if year<=4, xline(2) graphregion(fcolor(white)) name(abs`varofint'oldnew$owner$region1$filter, replace) title("vacanies (abs. num.) by construction period $region1")
graph export abs`varofint'oldnew$owner$region1$filter.pdf, replace

* plot just before vs just after
twoway (line `varofint'1919to1944 `varofint'1945to1960 year, mcolor(navy) lcolor(navy) xlab(,val)) if year<=4, xline(2) graphregion(fcolor(white)) name(abs`varofint'justaround$owner$region1$filter, replace) title("vacancies (abs. num.) by construction period $region1")
graph export abs`varofint'justaround$owner$region1$filter.pdf, replace

restore






























