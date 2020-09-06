
/* Master Thesis WS 2019/20

* COLUMNSUMS

Accessed by vz
Sums variables by owner and year of construction, thus generating new rows, eg. for all privately owned dwellings. This is done by bringing the data to wide format, pretending owner and built combinations to be the time variable.
I reshape the data again once I am done, because it is more handy, ending up with the extra rows I needed.

*/

global vars "mainres vac A B C D E flatowner houseowner rented service other selfused rowtot"

********************************************************************************

* bring to wide format, pretending owner and built to be the time variable (makes summing up easier)


gen syeardistrid = syear+"qy"+distrid
gen builtowner = built3+"qy"+owner

drop syear built built2 built3 owner distrid distr

reshape wide $vars, i(syeardistrid) j(builtowner) string

* sums by old vs new buildings (and percentage shares of all dwellings in this district)

foreach w in $vars {
foreach v in char fed manypriv muni onepriv oth othleg othpub state {

egen `w'oldqy`v' = rowtotal(`w'before1919qy`v' `w'1919to1944qy`v')
egen `w'newqy`v' = rowtotal(`w'1945to1960qy`v' `w'1961to1980qy`v' `w'1981to1990qy`v' `w'after1991qy`v')
egen `w'allqy`v' = rowtotal(`w'before1919qy`v' `w'1919to1944qy`v' `w'1945to1960qy`v' `w'1961to1980qy`v' `w'1981to1990qy`v' `w'after1991qy`v')

}
}

* sums by ownership (and percentage shares of all dwellings in this district)

foreach w in $vars {
foreach v in before1919 1919to1944 1945to1960 1961to1980 1981to1990 after1991 old new all {

egen `w'`v'qytotal = rowtotal(`w'`v'qychar `w'`v'qyfed `w'`v'qymanypriv `w'`v'qymuni `w'`v'qyonepriv `w'`v'qyoth `w'`v'qyothleg `w'`v'qyothpub `w'`v'qystate)
egen `w'`v'qypriv = rowtotal(`w'`v'qymanypriv `w'`v'qyonepriv `w'`v'qyothleg)
egen `w'`v'qypub = rowtotal(`w'`v'qyfed `w'`v'qymuni `w'`v'qyothpub `w'`v'qystate)

}
}


* generate percentages

foreach w in $vars {
foreach v in total {

foreach u in old new before1919 1919to1944 1961to1980 {
gen `w'pc`u'qy`v' = `w'`u'qy`v'/`w'allqy`v'

}
}
}

foreach w in $vars {
foreach v in before1919 1919to1944 1945to1960 1961to1980 1981to1990 after1991 old new all {

foreach u in char fed manypriv muni onepriv oth othleg othpub state priv pub {
gen `w'`v'qypc`u' =  `w'`v'qy`u'/`w'`v'qytotal

}
}
}


********************************************************************************

reshape long

split syeardistrid, p("qy") gen(a)
rename a1 syear
rename a2 distrid

split builtowner, p("qy") gen(b)
rename b1 built
rename b2 owner


drop syeardistrid builtowner

order syear distrid built owner
sort syear distrid built owner





















