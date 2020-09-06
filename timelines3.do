
/* Master Thesis WS 2019/20

TIMELINES

* averaged vacancy rates over all districts

*/


preserve

$region
$othercond

local varofint = "$varofint"

foreach v in "old" "new" "all" "1919to1944" "1945to1960" "before1919" "1961to1980" "1981to1990" "after1991"{
foreach x in `varofint' {

gen pc`x'`v' = .

foreach w in 1971 1981 1991 2001 {

sum pc`varofint' if syear == `w' & built == "`v'" & owner == "$owner"

local y = round(`w'/10) - 196
* so scalars are named 1 2 3 4 (better for later)

quiet sca avg`x'`v'`y' = r(mean)

replace pc`x'`v' = avg`x'`v'`y' in `y'

}
}
}

label variable pcvacold old
label variable pcvacnew new
label variable pcvacall all
label variable pcvac1919to1944 "1919 to 1944"
label variable pcvac1945to1960 "1945 to 1960"
label variable pcvac1961to1980 "1961 to 1980"
label variable pcvac1981to1990 "1981 to 1990"
label variable pcvacafter1991 "after 1991"


gen year = _n

lab def time 1 "1971" 2 "1981" 3 "1991" 4 "2001", replace
lab values year time

* plot all construction year-groups
* twoway (line pc`varofint'old-pc`varofint'1961to1980 year, mcolor(navy) lcolor(navy) xlab(,val)) if year<=4, xline(2) graphregion(fcolor(white)) name(avg`varofint'all$owner$region1$filter, replace) title("average vacancy rates by construction period $region1")
* graph export avg`varofint'ratesall$owner$region1$filter.pdf, replace

* plot old vs new
twoway (line pc`varofint'old pc`varofint'new year, mcolor(navy) lcolor(navy) xlab(,val)) if year<=4, xline(2) graphregion(fcolor(white)) name(avg`varofint'oldnew$owner$region1$filter, replace) title("avgerage vacancy rates by construction period $region1")
graph export avg`varofint'ratesoldnew$owner$region1$filter.pdf, replace

* plot just around threshold
twoway (line pc`varofint'1919to1944 pc`varofint'1945to1960 year, mcolor(navy) lcolor(navy) xlab(,val)) if year<=4, xline(2) graphregion(fcolor(white)) name(avg`varofint'justaround$owner$region1$filter, replace) title("avgerage vacancy rates by construction period $region1")
graph export avg`varofint'justaround$owner$region1$filter.pdf, replace

restore






























