
* Master Thesis WS 2019/20

* NAMESANDLABELS2

* Second part of renaming

********************************************************************************

label variable mainres "main residences"
label variable vac "without main residence"

label variable A "bathroom and central heating"
label variable B "bathroom"
label variable C "WC and water"
label variable D "water"
label variable E "no WC or water"

label variable flatowner "used by owner of flat"
label variable houseowner "used by owner of house"
label variable rented "rented out"
label variable service "service or official accomodation"
label variable other "other legal title"


* generate state identifier

gen stateid = regexs(0) if(regexm(distrid, "[0-9]"))

destring, replace

label define stateid 1 "Burgenland" 2 "Kaernten" 3 "Niederoesterreich" 4 "Oberoesterreich" 5 "Salzburg" 6 "Steiermark" 7 "Tirol" 8 "Vorarlberg" 9 "Wien"
label values stateid stateid

































