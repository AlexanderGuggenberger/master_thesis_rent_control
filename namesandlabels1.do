
* Master Thesis WS 2019/20

* NAMESANDLABELS1

* First part of renaming and labelling. (Extra file the make code clearer)

********************************************************************************

rename mit_Hauptwohnsitzangabe mainres
rename nur_mit_Neben__bzw__ohne_Wohnsit vac

rename mit_Bad_einschl__Duschnische_u__ A
rename mit_Bad_einschl__Duschnische B
rename mit_WC_u__Wasserentnahme_innerha C
rename mit_Wasserentnahme_innerhalb_der D
rename ohne_WC_u__Wasserentnahme_innerh E

rename *tzung_Hauseigent* flatowner
rename *tzung_Wohnungseigent* houseowner
rename Hauptmiete__MRG_WGG_ rented
rename Dienst___Naturalwohnung service
rename sonstiges_Rechts* other

* note: accessing the variable via *tzung_Hauseigent* was necessary, Stata did not take the name with the special symbols

* make "built" numeric with labels

gen built2 = 1 if built == "vor 1919"
replace built2 = 2 if built == "1919 bis 1944"
replace built2 = 3 if built == "1945 bis 1960"
replace built2 = 4 if built == "1961 bis 1980"
replace built2 = 5 if built == "1981 bis 1990"
replace built2 = 6 if built2 == .

label define built 1 "before1919" 2 "1919to1944" 3 "1945to1960" 4 "1961to1980" 5 "1981to1990" 6 "after1991"
label values built2 built

decode built2, gen(built3)

* generate district identifier from string variable

gen distrid = regexs(0) if(regexm(distr, "[0-9][0-9][0-9]"))

* simplify entries of variable "owner"

gen n = _n
gen mod = mod(n,9)

replace owner = "fed" if mod == 1
replace owner = "muni" if mod == 2
replace owner = "state" if mod == 3
replace owner = "oth" if mod == 4
replace owner = "othpub" if mod == 5
replace owner = "onepriv" if mod == 6
replace owner = "char" if mod == 7
replace owner = "manypriv" if mod == 8
replace owner = "othleg" if mod == 0

drop n mod

* change to correct character for missings

global vars "mainres vac A B C D E flatowner houseowner rented service other"

foreach v in $vars {

replace `v' = "." if `v' == "-"

}

* encode districts, st I obtain value labels

encode distr, gen(distrlabel)

* declaring variables as numeric

destring mainres-built2, replace

* generate the rowsum of dwellings used by their owners

egen selfused = rowtotal(flatowner houseowner)
global vars "mainres vac A B C D E flatowner houseowner rented service other selfused"




















