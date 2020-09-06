
/* Master Thesis WS 2019/20

ANALYSIS_WEIGHTED_LOGIT

second approach: run a weighted logit model instead of OLS with share outputs
all outputs begin with wl to abreviate weighted logit

*/

cd "\\fs.univie.ac.at\homedirs\alexanderg15\Documents\WS_201920\Masterarbeit\Daten"

clear
graph drop _all

use prepdatafilter2
* use prepdata2

global filter f
* f ... only those with more than two apartments, n ... no filter
* appears in file names of outputs


********************************************************************************
* prepare the data accordingly: binary vacant indicator (binvac) and variables telling how many dwellings are vacant / not vacant (counter)

gen weight0 = rowtot - vac
gen weight1 = vac
gen id = _n

reshape long weight, i(id) j(binvac)
drop id

* xtset such that I can create a variable with the lags of inhabitants

gen binvac2 = "0" if binvac == 0
replace binvac2 = "1" if binvac == 1
gen group = distr+" "+built+" "+owner+" "+binvac2

encode group, gen(groupid2)
drop group

xtset groupid2 syear, delta(10)

* gen dinhabitants = d.inhabitants
* decided not to use it, as this means dropping a fourth of the observations for which d.inhabitants cannot be computed

********************************************************************************

* generate a treatment indicator

gen treat = 1 if built == "1919to1944"
replace treat = 0 if built == "1945to1960"
drop if treat == .

gen time = syear > 1981

global version justaround
* justaround ... just around threshold, oldvnew ... all before vs all after 1945
* $version and $filter automatically name the graphs according to what I specified as the treatment and control group and whether I use the dataset with dwellings containing less than 3 apartments filtered out or not

save prepdata3$filter, replace

********************************************************************************
* SOME SPECIFICATIONS

est drop _all

* baseline OLS (linear probability model using frequency weights)

eststo: reg binvac i.treat##i.time [fw = weight] if owner == "total"
eststo: reg binvac i.treat##i.time [fw = weight] if owner == "total", vce(cluster distrid)

* OLS with all controls

eststo: reg binvac i.treat##i.time i.syear treat pcA pcB pcC pcD pcE inhabitants pcAustria-pccommuter i.groupid [fw = weight] if owner == "total"
eststo: reg binvac i.treat##i.time i.syear treat pcA pcB pcC pcD pcE inhabitants pcAustria-pccommuter i.groupid [fw = weight] if owner == "total", vce(cluster distrid)

* logit

eststo: logit binvac i.treat##i.time [fw = weight] if owner == "total", vce(cluster distrid)
eststo: logit binvac i.treat##i.time i.syear treat pcA pcB pcC pcD pcE inhabitants pcAustria-pccommuter i.groupid [fw = weight] if owner == "total", vce(cluster distrid)

* linear fixed effects model - does not work with weights! Weights would need to be constant, which makes no sense, as they are basically the output variable

* xtreg binvac treat##time i.syear treat pcA pcB pcC pcD pcE inhabitants d.inhabitants pcAustria-pccommuter [fw = weight] if owner == "total", fe vce(cluster distrid)

* logistic fixed effects

* xtlogit binvac treat##time i.syear treat pcA pcB pcC pcD pcE inhabitants d.inhabitants pcAustria-pccommuter [fw = weight] if owner == "total", fe vce(cluster distrid)

esttab est*, compress mtitles("OLS" "OLS clustered" "OLS controls" "OLS controls clustered" "logit clustered" "logit clustered controls") title(some specifications using frequency weights, version $version, data $filter) noomitted nobaselevels drop(*.groupid) order(1.treat#1.time) se  b(%9.3f )
esttab est* using wlsomespecifications$verion$filter.tex, replace compress mtitles("OLS" "OLS clustered" "OLS controls" "OLS controls clustered" "logit clustered" "logit clustered controls") title(some specifications using frequency weights, version $version, data $filter) noomitted nobaselevels drop(*.groupid) order(1.treat#1.time) se  b(%9.3f )
 
* unfiltered: --> significant positive effect with OLS, controls, clustered se and significant negativ effect with logit, clustered se and no controls

********************************************************************************
* GO ON WITH LOGIT (seems to be most suitable)

* baseline, no controls

est drop _all

quiet eststo: logit binvac i.treat##i.time [fw = weight] if owner == "total", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time [fw = weight] if owner == "char", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time [fw = weight] if owner == "fed", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time [fw = weight] if owner == "manypriv", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time [fw = weight] if owner == "muni", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time [fw = weight] if owner == "onepriv", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time [fw = weight] if owner == "oth", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time [fw = weight] if owner == "othleg", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time [fw = weight] if owner == "othpub", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time [fw = weight] if owner == "state", vce(cluster distrid)

esttab est*, compress mtitles("total" "char" "fed" "manypriv" "muni" "onepriv" "oth" "othleg" "othpub" "state") title(weighhted logit, by owner, no controls, version $version, data $filter) noomitted nobaselevels order(1.treat#1.time) se  b(%9.3f )
esttab est* using wlbyowner_nocontrols$verion$filter.tex, replace compress mtitles("total" "char" "fed" "manypriv" "muni" "onepriv" "oth" "othleg" "othpub" "state") title(wl, by owner, no controls, version $version, data $filter) noomitted nobaselevels order(1.treat#1.time) se  b(%9.3f )

* unfiltered: --> significant negative effect overall and for privately owned dwellings, positive for "others"

* models split up only by privately vs publicly owned

est drop _all

quiet eststo: logit binvac i.treat##i.time [fw = weight] if owner == "priv", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time [fw = weight] if owner == "pub", vce(cluster distrid)

esttab est*, mtitles("privately owned" "publicly owned") title(priv vs pub, no controls, $version $filter) noomitted nobaselevels order(1.treat#1.time) se
esttab est* using wlpubvspriv_GWZcontrols$verion$filter.tex, replace mtitles("privately owned" "publicly owned") title(wl, priv vs pub, no controls, $version $filter) noomitted nobaselevels order(1.treat#1.time) se

* unfiltered: --> significant negative effects for both

********************************************************************************

* backward selecion of control variables in the logit model (in each step delete least significant estimator, except interaction term and categorical variables for fixed effects)

eststo clear

quiet eststo: logit binvac treat##time i.syear treat pcA pcB pcC pcD inhabitants pcAustria pcaliens pcEu pcJugoslawia pcTurkey pcnonEu pcuni pcprimary pcmarried pcselfemp pcnotworking pcclark pcinhabitants pcchildren pcyoungadults pcadults pcseniors pctertiary pcsecundary pccommuter i. groupid [fw = weight] if owner == "total", vce(cluster distrid)
quiet eststo: logit binvac treat##time i.syear treat pcA pcB pcC pcD inhabitants pcAustria pcaliens pcEu pcJugoslawia pcTurkey pcnonEu pcuni pcprimary pcmarried pcselfemp pcclark pcinhabitants pcchildren pcyoungadults pcadults pcseniors pctertiary pcsecundary pccommuter i. groupid [fw = weight] if owner == "total", vce(cluster distrid)
quiet eststo: logit binvac treat##time i.syear treat pcA pcB pcC pcD inhabitants pcAustria pcaliens pcEu pcJugoslawia pcTurkey pcnonEu pcuni pcprimary pcmarried pcselfemp pcinhabitants pcchildren pcyoungadults pcadults pcseniors pctertiary pcsecundary pccommuter i. groupid [fw = weight] if owner == "total", vce(cluster distrid)
quiet eststo: logit binvac treat##time i.syear treat pcA pcB pcC pcD inhabitants pcAustria pcaliens pcEu pcJugoslawia pcTurkey pcnonEu pcuni pcprimary pcmarried pcselfemp pcinhabitants pcchildren pcyoungadults pcseniors pctertiary pcsecundary pccommuter i. groupid [fw = weight] if owner == "total", vce(cluster distrid)
quiet eststo: logit binvac treat##time i.syear treat pcA pcB pcC pcD inhabitants pcAustria pcaliens pcEu pcJugoslawia pcTurkey pcnonEu pcuni pcprimary pcmarried pcselfemp pcinhabitants pcchildren pcyoungadults pctertiary pcsecundary pccommuter i. groupid [fw = weight] if owner == "total", vce(cluster distrid)
quiet eststo: logit binvac treat##time i.syear treat pcA pcB pcC pcD inhabitants pcAustria pcaliens pcEu pcJugoslawia pcTurkey pcnonEu pcuni pcprimary pcmarried pcselfemp pcinhabitants pcchildren pcyoungadults pctertiary pcsecundary pccommuter i. groupid [fw = weight] if owner == "total", vce(cluster distrid)
quiet eststo: logit binvac treat##time i.syear treat pcA pcB pcC pcD inhabitants pcAustria pcaliens pcEu pcJugoslawia pcTurkey pcnonEu pcuni pcmarried pcselfemp pcinhabitants pcchildren pcyoungadults pctertiary pcsecundary pccommuter i. groupid [fw = weight] if owner == "total", vce(cluster distrid)
quiet eststo: logit binvac treat##time i.syear treat pcA pcB pcC pcD inhabitants pcAustria pcaliens pcEu pcJugoslawia pcTurkey pcnonEu pcuni pcmarried pcselfemp pcinhabitants pcchildren pcyoungadults pctertiary pcsecundary i. groupid [fw = weight] if owner == "total", vce(cluster distrid)
quiet eststo: logit binvac treat##time i.syear treat pcA pcB pcC inhabitants pcAustria pcaliens pcEu pcJugoslawia pcTurkey pcnonEu pcuni pcmarried pcselfemp pcinhabitants pcchildren pcyoungadults pctertiary pcsecundary i. groupid [fw = weight] if owner == "total", vce(cluster distrid)
quiet eststo: logit binvac treat##time i.syear treat pcA pcB pcC inhabitants pcAustria pcaliens pcEu pcJugoslawia pcTurkey pcnonEu pcuni pcmarried pcinhabitants pcchildren pcyoungadults pctertiary pcsecundary i. groupid [fw = weight] if owner == "total", vce(cluster distrid)

esttab est*, aic bic title(weighted logit: backward selection with GWZ and VZ controls, $filter $version 1) noomitted nobaselevels order(1.treat#1.time) se interaction() b(%9.3f ) drop(*.groupid) 

* --> AIC and BIC suggest the full model. Possibly due to use of frequency weights, which makes n seem much larger.
* IC might not be reliably here as they depend on n, and n varies between the modles due to automatic reduction Stata does until there are no missings
* Coefficient of interest is not significant (at 5% or lower) at any model with a few covariates

* make varlists for Gebäude- und Wohnungszählungs- und Volkszählungs-control variables
* note: I do not include share used by houseowner and rentowner respectively, as this is directly linked to the ownership groups. e.g. dwellings owned by legal persons are never inhabitated by them.

global indepvarsGWZ "pcA pcB pcC pcD pcE pcrented pcservice pcother pcselfused"
global indepvarsVZ "pcAustria pcaliens pcEu pcTurkey pcnonEu pcuni pcprimary pcmarried pcselfemp pcnotworking pcclark inhabitants pcchildren pcyoungadults pcadults pcseniors pctertiary pcsecundary pccommuter"

********************************************************************************
* again by owner, now controls (albeit some of them are bad controls, i.e. they might be driven by the prevalence of main vs secpndary residences)

* GWZ, VZ and group fixed effects

est drop _all
quiet eststo: logit binvac i.treat##i.time i.syear i.groupid $indepvarsGWZ $indepvarsVZ [fw = weight] if owner == "priv", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear i.groupid $indepvarsGWZ $indepvarsVZ [fw = weight] if owner == "pub", vce(cluster distrid)

esttab est*, mtitles("privately owned" "publicly owned") title(with GWZ and VZ controls and fixed effects) noomitted nobaselevels interaction(x) order(1.treat#1.time) se  b(%9.3f ) drop(*.groupid)
esttab est* using wlpubvspriv_gwz_vz_fe_$version$filter.tex, replace compress title(with GWZ and VZ controls and fixed effects) noomitted nobaselevels interaction(x) order(1.treat#1.time) se b(%9.3f ) drop(*.groupid) 

est drop _all

quiet eststo: logit binvac i.treat##i.time i.syear i.groupid $indepvarsVZ $indepvarsGWZ [fw = weight] if owner == "total", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear i.groupid $indepvarsVZ $indepvarsGWZ [fw = weight] if owner == "char", vce(cluster distrid) iterate(50)
quiet eststo: logit binvac i.treat##i.time i.syear i.groupid $indepvarsVZ $indepvarsGWZ [fw = weight] if owner == "fed", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear i.groupid $indepvarsVZ $indepvarsGWZ [fw = weight] if owner == "manypriv", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear i.groupid $indepvarsVZ $indepvarsGWZ [fw = weight] if owner == "muni", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear i.groupid $indepvarsVZ $indepvarsGWZ [fw = weight] if owner == "onepriv", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear i.groupid $indepvarsVZ $indepvarsGWZ [fw = weight] if owner == "othleg", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear i.groupid $indepvarsVZ $indepvarsGWZ [fw = weight] if owner == "othpub", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear i.groupid $indepvarsVZ $indepvarsGWZ [fw = weight] if owner == "state", vce(cluster distrid)

esttab est*, mtitles("total" "char" "fed" "manypriv" "muni" "onepriv" "othleg" "othpub" "state") title(with GWZ and VZ controls and group-fixed effetcs, $filter $version) noomitted nobaselevels interaction(x) order(1.treat#1.time) se drop(*.groupid) 
esttab est* using wlbyowner_gwz_vz_fe_$version$filter.tex, replace compress mtitles("total" "char" "fed" "manypriv" "muni" "onepriv" "othleg" "othpub" "state") title(with GWZ and VZ controls and group-fixed effetcs, $filter $version) noomitted nobaselevels interaction(x) order(1.treat#1.time) se b(%9.3f ) drop(*.groupid) 

* seems to be significant for publicly owned buildings rather than for privately owned ones

* GWZ and group fixed effects, no VZ

est drop _all
quiet eststo: logit binvac i.treat##i.time i.syear i.groupid $indepvarsGWZ [fw = weight] if owner == "priv", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear i.groupid $indepvarsGWZ [fw = weight] if owner == "pub", vce(cluster distrid)

esttab est*, mtitles("privately owned" "publicly owned") title(with GWZ controls and fixed effects) noomitted nobaselevels interaction(x) order(1.treat#1.time) se  b(%9.3f ) drop(*.groupid)
esttab est* using wlpubvspriv__gwz_fe_$version$filter.tex, replace compress title(with GWZ controls and fixed effects) noomitted nobaselevels interaction(x) order(1.treat#1.time) se b(%9.3f ) drop(*.groupid) 

est drop _all

quiet eststo: logit binvac i.treat##i.time i.syear i.groupid $indepvarsGWZ [fw = weight] if owner == "total", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear i.groupid $indepvarsGWZ [fw = weight] if owner == "char", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear i.groupid $indepvarsGWZ [fw = weight] if owner == "fed", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear i.groupid $indepvarsGWZ [fw = weight] if owner == "manypriv", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear i.groupid $indepvarsGWZ [fw = weight] if owner == "muni", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear i.groupid $indepvarsGWZ [fw = weight] if owner == "onepriv", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear i.groupid $indepvarsGWZ [fw = weight] if owner == "othleg", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear i.groupid $indepvarsGWZ [fw = weight] if owner == "othpub", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear i.groupid $indepvarsGWZ [fw = weight] if owner == "state", vce(cluster distrid)

esttab est*, mtitles("total" "char" "fed" "manypriv" "muni" "onepriv" "othleg" "othpub" "state") title(with GWZ controls and fixed effects, $filter $version) noomitted nobaselevels interaction(x) order(1.treat#1.time) se drop(*.groupid) 
esttab est* using wlbyowner_gwz_fe_$version$filter.tex, replace compress mtitles("total" "char" "fed" "manypriv" "muni" "onepriv" "othleg" "othpub" "state") title(with GWZ controls and fixed effects, $filter $version) noomitted nobaselevels interaction(x) order(1.treat#1.time) se b(%9.3f ) drop(*.groupid) 


* GWZ and VZ, no fixed effects

est drop _all
quiet eststo: logit binvac i.treat##i.time i.syear $indepvarsGWZ $indepvarsVZ [fw = weight] if owner == "priv", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear $indepvarsGWZ $indepvarsVZ [fw = weight] if owner == "pub", vce(cluster distrid)

esttab est*, mtitles("privately owned" "publicly owned") title(with GWZ and VZ controls) noomitted nobaselevels interaction(x) order(1.treat#1.time) se  b(%9.3f )
esttab est* using wlpubvspriv_gwz_vz_$version$filter.tex, replace compress title(with GWZ and VZ controls) noomitted nobaselevels interaction(x) order(1.treat#1.time) se b(%9.3f )

est drop _all

quiet eststo: logit binvac i.treat##i.time i.syear $indepvarsGWZ $indepvarsVZ [fw = weight] if owner == "total", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear $indepvarsGWZ $indepvarsVZ [fw = weight] if owner == "char", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear $indepvarsGWZ $indepvarsVZ [fw = weight] if owner == "fed", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear $indepvarsGWZ $indepvarsVZ [fw = weight] if owner == "manypriv", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear $indepvarsGWZ $indepvarsVZ [fw = weight] if owner == "muni", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear $indepvarsGWZ $indepvarsVZ [fw = weight] if owner == "onepriv", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear $indepvarsGWZ $indepvarsVZ [fw = weight] if owner == "othleg", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear $indepvarsGWZ $indepvarsVZ [fw = weight] if owner == "othpub", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear $indepvarsGWZ $indepvarsVZ [fw = weight] if owner == "state", vce(cluster distrid)

esttab est*, mtitles("total" "char" "fed" "manypriv" "muni" "onepriv" "othleg" "othpub" "state") title(with GWZ and VZ controls, $filter $version) noomitted nobaselevels interaction(x) order(1.treat#1.time) se 
esttab est* using wlbyowner_gwz_vz_$version$filter.tex, replace compress mtitles("total" "char" "fed" "manypriv" "muni" "onepriv" "othleg" "othpub" "state") title(with GWZ and VZ controls, $filter $version) noomitted nobaselevels interaction(x) order(1.treat#1.time) se b(%9.3f ) 


* only GWZ

est drop _all
quiet eststo: logit binvac i.treat##i.time i.syear $indepvarsGWZ [fw = weight] if owner == "priv", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear $indepvarsGWZ [fw = weight] if owner == "pub", vce(cluster distrid)

esttab est*, mtitles("privately owned" "publicly owned") title(with GWZ controls) noomitted nobaselevels interaction(x) order(1.treat#1.time) se  b(%9.3f )
esttab est* using wlpubvspriv_gwz_$version$filter.tex, replace compress title(with GWZ controls) noomitted nobaselevels interaction(x) order(1.treat#1.time) se b(%9.3f )

est drop _all

quiet eststo: logit binvac i.treat##i.time i.syear $indepvarsGWZ [fw = weight] if owner == "total", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear $indepvarsGWZ [fw = weight] if owner == "char", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear $indepvarsGWZ [fw = weight] if owner == "fed", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear $indepvarsGWZ [fw = weight] if owner == "manypriv", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear $indepvarsGWZ [fw = weight] if owner == "muni", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear $indepvarsGWZ [fw = weight] if owner == "onepriv", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear $indepvarsGWZ [fw = weight] if owner == "othleg", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear $indepvarsGWZ [fw = weight] if owner == "othpub", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear $indepvarsGWZ [fw = weight] if owner == "state", vce(cluster distrid)

esttab est*, mtitles("total" "char" "fed" "manypriv" "muni" "onepriv" "othleg" "othpub" "state") title(with GWZ controls, $filter $version) noomitted nobaselevels interaction(x) order(1.treat#1.time) se
esttab est* using wlbyowner_gwz_$version$filter.tex, replace compress mtitles("total" "char" "fed" "manypriv" "muni" "onepriv" "othleg" "othpub" "state") title(with GWZ controls, $filter $version) noomitted nobaselevels interaction(x) order(1.treat#1.time) se b(%9.3f )


********************************************************************************
* placebo breaks
* do it without controls

est drop _all

replace time = syear > 1981
quiet eststo: logit binvac i.treat##i.time [fw = weight] if owner == "priv" & syear != 1971 & syear != 2001, vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time [fw = weight] if owner == "pub" & syear != 1971 & syear != 2001, vce(cluster distrid)

replace time = syear > 1971
quiet eststo: logit binvac i.treat##i.time [fw = weight] if owner == "priv" & syear != 1991 & syear != 2001, vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time [fw = weight] if owner == "pub" & syear != 1991 & syear != 2001, vce(cluster distrid)

replace time = syear > 1991
quiet eststo: logit binvac i.treat##i.time [fw = weight] if owner == "priv" & syear != 1971 & syear != 1981, vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time [fw = weight] if owner == "pub" & syear != 1971 & syear != 1981, vce(cluster distrid)

esttab est*, mtitles("private 1981" "public 1981" "private 1971" "public 1971" "private 1991" "public 1991") title(placebo breaks, $version $filter) noomitted nobaselevels order(1.treat#1.time) se
esttab est* using wlplacebobreaks_nocontrols$version$filter.tex, b(%9.3f ) replace compress mtitles("private 1981" "public 1981" "private 1971" "public 1971" "private 1991" "public 1991") title(placebo breaks $version $filter) noomitted nobaselevels interaction(x) order(1.treat#1.time) se

* nothing significant except negativ public 1991

********************************************************************************
* placebo breaks with controls

* does not work with VZ controls

est drop _all

replace time = syear > 1981
quiet eststo: logit binvac treat##time i.syear i.groupid $indepvarsGWZ [fw = weight] if owner == "priv" & syear != 1971 & syear != 2001, vce(cluster distrid)
quiet eststo: logit binvac treat##time i.syear i.groupid $indepvarsGWZ [fw = weight] if owner == "pub" & syear != 1971 & syear != 2001, vce(cluster distrid)

replace time = syear > 1971
quiet eststo: logit binvac treat##time i.syear i.groupid $indepvarsGWZ [fw = weight] if owner == "priv" & syear != 1991 & syear != 2001, vce(cluster distrid)
quiet eststo: logit binvac treat##time i.syear i.groupid $indepvarsGWZ [fw = weight] if owner == "pub" & syear != 1991 & syear != 2001, vce(cluster distrid)

replace time = syear > 1991
quiet eststo: logit binvac treat##time i.syear i.groupid $indepvarsGWZ [fw = weight] if owner == "priv" & syear != 1971 & syear != 1981, vce(cluster distrid)
quiet eststo: logit binvac treat##time i.syear i.groupid $indepvarsGWZ [fw = weight] if owner == "pub" & syear != 1971 & syear != 1981, vce(cluster distrid)

esttab est*, mtitles("private 1981" "public 1981" "private 1971" "public 1971" "private 1991" "public 1991") title(placebo breaks with controls, $version $filter) noomitted nobaselevels order(1.treat#1.time) se drop(*.groupid)
esttab est* using wlplacebobreaks_fullcontrols$version$filter.tex, b(%9.3f ) replace compress mtitles("private 1981" "public 1981" "private 1971" "public 1971" "private 1991" "public 1991") title(placebo breaks with controls, $version $filter) noomitted nobaselevels interaction(x) order(1.treat#1.time) se drop(*.groupid)

* reset time indicator to actual policy break
replace time = syear > 1981

********************************************************************************
* the effect on subgroups
* only statutary cities

est drop _all
quiet eststo: logit binvac treat##time i.syear i.groupid $indepvarsGWZ $indepvarsVZ [fw = weight] if owner == "total" & city == 1, vce(cluster distrid)
quiet eststo: logit binvac treat##time i.syear i.groupid $indepvarsGWZ $indepvarsVZ [fw = weight] if owner == "priv" & city == 1, vce(cluster distrid)
quiet eststo: logit binvac treat##time i.syear i.groupid $indepvarsGWZ $indepvarsVZ [fw = weight] if owner == "pub" & city == 1, vce(cluster distrid)

esttab est*, mtitles("total" "privately owned" "publicly owned") title(with GWZ and VZ controls - only cities) noomitted nobaselevels interaction(x) order(1.treat#1.time) se drop(*.groupid) 
esttab est* using wlcities$version$filter.tex, b(%9.3f ) mtitles("total" "privately owned" "publicly owned") title(with GWZ and VZ controls - only cities, $filter $version) replace noomitted nobaselevels interaction(x) order(1.treat#1.time) se drop(*.groupid) 

* east vs west Austria
* east

est drop _all
quiet eststo: logit binvac treat##time i.syear i.groupid $indepvarsGWZ $indepvarsVZ [fw = weight] if owner == "total" & region == "east", vce(cluster distrid)
quiet eststo: logit binvac treat##time i.syear i.groupid $indepvarsGWZ $indepvarsVZ [fw = weight] if owner == "priv" & region == "east", vce(cluster distrid)
quiet eststo: logit binvac treat##time i.syear i.groupid $indepvarsGWZ $indepvarsVZ [fw = weight] if owner == "pub" & region == "east", vce(cluster distrid)

esttab est*, mtitles("total" "privately owned" "publicly owned") title(with GWZ and VZ controls - eastern Asutria) noomitted nobaselevels interaction(x) order(1.treat#1.time) se drop(*.groupid) 
esttab est* using wleast$version$filter.tex, b(%9.3f ) mtitles("total" "privately owned" "publicly owned") title(with GWZ and VZ controls - only cities, $filter $version) replace noomitted nobaselevels interaction(x) order(1.treat#1.time) se drop(*.groupid) 

* west

* again, must exclude VZ vars

est drop _all
quiet eststo: logit binvac treat##time i.syear i.groupid $indepvarsGWZ [fw = weight] if owner == "total" & region == "west", vce(cluster distrid)
quiet eststo: logit binvac treat##time i.syear i.groupid $indepvarsGWZ [fw = weight] if owner == "priv" & region == "west", vce(cluster distrid)
quiet eststo: logit binvac treat##time i.syear i.groupid $indepvarsGWZ [fw = weight] if owner == "pub" & region == "west", vce(cluster distrid) technique(nr bhhh dfp bfgs) difficult

esttab est*, mtitles("total" "privately owned" "publicly owned") title(with GWZ and VZ controls - western Austria ) noomitted nobaselevels interaction(x) order(1.treat#1.time) se drop(*.groupid) 
esttab est* using wlwest$version$filter.tex, b(%9.3f ) mtitles("total" "privately owned" "publicly owned") title(with GWZ and VZ controls - only cities, $filter $version) replace noomitted nobaselevels interaction(x) order(1.treat#1.time) se drop(*.groupid) 


********************************************************************************

* collection of regression outputs with differenct specifications for presentation

est drop _all

quiet eststo: logit binvac i.treat##i.time [fw = weight] if owner == "total", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear $indepvarsGWZ [fw = weight] if owner == "total", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear $indepvarsGWZ $indepvarsVZ [fw = weight] if owner == "total", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear i.groupid $indepvarsGWZ $indepvarsVZ [fw = weight] if owner == "total", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear i.groupid $indepvarsGWZ $indepvarsVZ [fw = weight] if owner == "pub", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear i.groupid $indepvarsGWZ $indepvarsVZ [fw = weight] if owner == "priv", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear i.groupid $indepvarsGWZ $indepvarsVZ [fw = weight] if owner == "onepriv", vce(cluster distrid)

esttab est*, mtitles("total" "total" "total" "total" "publicly owned" "privately owned" "one privat perseon") title(Different specifications and subgroups, $filter $version) noomitted nobaselevels interaction(x) order(1.treat#1.time) se drop(*.groupid) 
esttab est* using specifications_and_subgroups_$version$filter.tex, replace compress mtitles("total" "total" "total" "total" "publicly owned" "privately owned" "one privat perseon") title(Different specifications and subgroups, $filter $version) noomitted nobaselevels interaction(x) order(1.treat#1.time) se drop(*.groupid)

* don't forget to transform to odds ratios for interpretation!

********************************************************************************







********************************************************************************
* COLLECTION OF OUTPUTS FOR THE PAPER
********************************************************************************

* 1) different specifications, building up the model 

est drop _all

quiet eststo: logit binvac i.treat##i.time [fw = weight] if owner == "total", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear [fw = weight] if owner == "total", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear $indepvarsGWZ [fw = weight] if owner == "total", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear $indepvarsGWZ $indepvarsVZ [fw = weight] if owner == "total", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear i.groupid $indepvarsGWZ $indepvarsVZ [fw = weight] if owner == "total", vce(cluster distrid)


esttab est*, mtitles("total" "total" "total" "total" "total") title(Different Specifications, $filter $version) noomitted nobaselevels interaction(\times) order(1.treat#1.time) se drop(*.groupid) 
esttab est* using specifications_$version$filter.tex, replace compress mtitles("total" "total" "total" "total" "total") title(Different Specifications, $filter $version) noomitted nobaselevels interaction(\times) order(1.treat#1.time) se drop(*.groupid)

* 2) full specification, by owner

est drop _all
quiet eststo: logit binvac i.treat##i.time i.syear i.groupid $indepvarsVZ $indepvarsGWZ [fw = weight] if owner == "total", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear i.groupid $indepvarsGWZ $indepvarsVZ [fw = weight] if owner == "priv", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear i.groupid $indepvarsGWZ $indepvarsVZ [fw = weight] if owner == "pub", vce(cluster distrid)

esttab est*, mtitles("total" "privately owned" "publicly owned") title(with GWZ and VZ controls and fixed effects) noomitted nobaselevels interaction(\times) order(1.treat#1.time) se  b(%9.3f ) drop(*.groupid)
esttab est* using wlpubvspriv_gwz_vz_fe_$version$filter.tex, mtitles("total" "privately owned" "publicly owned") replace compress title(with GWZ and VZ controls and fixed effects) noomitted nobaselevels interaction(\times) order(1.treat#1.time) se b(%9.3f ) drop(*.groupid) 

est drop _all

quiet eststo: logit binvac i.treat##i.time i.syear i.groupid $indepvarsVZ $indepvarsGWZ [fw = weight] if owner == "onepriv", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear i.groupid $indepvarsVZ $indepvarsGWZ [fw = weight] if owner == "manypriv", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear i.groupid $indepvarsVZ $indepvarsGWZ [fw = weight] if owner == "char", vce(cluster distrid) iterate(50)
quiet eststo: logit binvac i.treat##i.time i.syear i.groupid $indepvarsVZ $indepvarsGWZ [fw = weight] if owner == "othleg", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear i.groupid $indepvarsVZ $indepvarsGWZ [fw = weight] if owner == "fed", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear i.groupid $indepvarsVZ $indepvarsGWZ [fw = weight] if owner == "state", vce(cluster distrid)
quiet eststo: logit binvac i.treat##i.time i.syear i.groupid $indepvarsVZ $indepvarsGWZ [fw = weight] if owner == "muni", vce(cluster distrid)

esttab est*, mtitles("onepriv" "manypriv" "char" "othleg" "fed" "state" "muni") title(with GWZ and VZ controls and group-fixed effetcs, $filter $version) noomitted nobaselevels interaction(\times) order(1.treat#1.time) se drop(*.groupid) 
esttab est* using wlbyowner_gwz_vz_fe_$version$filter.tex, replace compress mtitles("onepriv" "manypriv" "char" "othleg" "fed" "state" "muni") title(with GWZ and VZ controls and group-fixed effetcs, $filter $version) noomitted nobaselevels interaction(\times) order(1.treat#1.time) se b(%9.3f ) drop(*.groupid) 

* 3) placebobreaks/restricting time around policy break

est drop _all

replace time = syear > 1971
quiet eststo: logit binvac treat##time i.syear i.groupid $indepvarsVZ $indepvarsGWZ [fw = weight] if owner == "total" & syear != 1991 & syear != 2001, vce(cluster distrid)
quiet eststo: logit binvac treat##time i.syear i.groupid $indepvarsVZ $indepvarsGWZ [fw = weight] if owner == "priv" & syear != 1991 & syear != 2001, vce(cluster distrid)
quiet eststo: logit binvac treat##time i.syear i.groupid $indepvarsVZ $indepvarsGWZ [fw = weight] if owner == "pub" & syear != 1991 & syear != 2001, vce(cluster distrid)

replace time = syear > 1981
quiet eststo: logit binvac treat##time i.syear i.groupid $indepvarsVZ $indepvarsGWZ [fw = weight] if owner == "total" & syear != 1971 & syear != 2001, vce(cluster distrid)
quiet eststo: logit binvac treat##time i.syear i.groupid $indepvarsVZ $indepvarsGWZ [fw = weight] if owner == "priv" & syear != 1971 & syear != 2001, vce(cluster distrid)
quiet eststo: logit binvac treat##time i.syear i.groupid $indepvarsVZ $indepvarsGWZ [fw = weight] if owner == "pub" & syear != 1971 & syear != 2001, vce(cluster distrid)

replace time = syear > 1991
quiet eststo: logit binvac treat##time i.syear i.groupid $indepvarsVZ $indepvarsGWZ [fw = weight] if owner == "total" & syear != 1971 & syear != 1981, vce(cluster distrid)
quiet eststo: logit binvac treat##time i.syear i.groupid $indepvarsVZ $indepvarsGWZ [fw = weight] if owner == "priv" & syear != 1971 & syear != 1981, vce(cluster distrid)
quiet eststo: logit binvac treat##time i.syear i.groupid $indepvarsVZ $indepvarsGWZ [fw = weight] if owner == "pub" & syear != 1971 & syear != 1981, vce(cluster distrid)

esttab est*, mtitles("total 1971" "private 1971" "public 1971" "total 1981" "private 1981" "public 1981" "total 1991" "private 1991" "public 1991") title(placebo breaks with controls, $version $filter) noomitted nobaselevels order(1.treat#1.time) se drop(*.groupid)
esttab est* using wlplacebobreaks_fullcontrols$version$filter.tex, b(%9.3f ) replace compress mtitles("total 1971" "private 1971" "public 1971" "total 1981" "private 1981" "public 1981" "total 1991" "private 1991" "public 1991") title(placebo breaks with controls, $version $filter) noomitted nobaselevels interaction(x) order(1.treat#1.time) se drop(*.groupid)

* reset time indicator to actual policy break
replace time = syear > 1981




















