
/* Master Thesis WS 2019/20

ANALYSIS_LINEAR_PERCENTAGES

Fits OLS regressions. Outputs are percentages of vacancies
All outputs begin with lp to abreviate linear_percentages

*/

cd "\\fs.univie.ac.at\homedirs\alexanderg15\Documents\WS_201920\Masterarbeit\Daten"

clear
graph drop _all

use prepdatafilter2
* use prepdata2

global filter f
* f ... only those with more than two apartments, n ... no filter

********************************************************************************

* MODELS

********************************************************************************

* generate a treatment indicator

gen treat = 1 if built == "1919to1944"
replace treat = 0 if built == "1945to1960"
drop if treat == .

gen time = syear > 1981

global version justaround
* justaround ... just around threshold, oldvnew ... all before vs all after 1945

* $version and $filter automatically name the graphs according to what I specified as the treatment and control group and whether I use the dataset with dwellings containing less than 3 apartments filtered out or not

********************************************************************************

* baseline diff in diff with all observations

xtreg pcvac treat##time if owner == "total", fe vce(cluster distrid)

* by owner

est drop _all

quiet eststo: xtreg pcvac i.treat##i.time if owner == "total", fe vce(cluster distrid)
quiet eststo: xtreg pcvac i.treat##i.time if owner == "char", fe vce(cluster distrid)
quiet eststo: xtreg pcvac i.treat##i.time if owner == "fed", fe vce(cluster distrid)
quiet eststo: xtreg pcvac i.treat##i.time if owner == "manypriv", fe vce(cluster distrid)
quiet eststo: xtreg pcvac i.treat##i.time if owner == "muni", fe vce(cluster distrid)
quiet eststo: xtreg pcvac i.treat##i.time if owner == "onepriv", fe vce(cluster distrid)
quiet eststo: xtreg pcvac i.treat##i.time if owner == "oth", fe vce(cluster distrid)
quiet eststo: xtreg pcvac i.treat##i.time if owner == "othleg", fe vce(cluster distrid)
quiet eststo: xtreg pcvac i.treat##i.time if owner == "othpub", fe vce(cluster distrid)
quiet eststo: xtreg pcvac i.treat##i.time if owner == "state", fe vce(cluster distrid)

esttab est*, compress p mtitles("total" "char" "fed" "manypriv" "muni" "onepriv" "oth" "othleg" "othpub" "state") title(by owner, no controls, version $version, data $filter) noomitted nobaselevels order(1.treat#1.time)
esttab est* using lpbyowner_nocontrols$verion$filter.tex, replace compress p mtitles("total" "char" "fed" "manypriv" "muni" "onepriv" "oth" "othleg" "othpub" "state") title(by owner, no controls, version $version, data $filter) noomitted nobaselevels  order(1.treat#1.time)

* Note that with filtered data, nothing is significant anymore except for those owned by other legal persons

* models split up only by privately vs publicly owned

est drop _all

quiet eststo: xtreg pcvac i.treat##i.time if owner == "priv", fe vce(cluster distrid)
quiet eststo: xtreg pcvac i.treat##i.time if owner == "pub", fe vce(cluster distrid)
quiet eststo: xtreg pcvac i.treat##i.time i.syear treat pcA pcB pcC pcD pcE if owner == "priv", fe vce(cluster distrid)
quiet eststo: xtreg pcvac i.treat##i.time i.syear treat pcA pcB pcC pcD pcE if owner == "pub", fe vce(cluster distrid)

esttab est*, p mtitles("priv baseline" "pub baseline" "priv controls" "pub controls") title(priv vs pub, with GWZ controls, $version $filter) noomitted nobaselevels order(1.treat#1.time)
esttab est* using lppubvspriv_GWZcontrols$verion$filter.tex, replace p mtitles("priv baseline" "pub baseline" "priv controls" "pub controls") title(priv vs pub, with GWZ controls, $version $filter) noomitted nobaselevels order(1.treat#1.time)

********************************************************************************
* GWZ and VZ controls

* BACKWARD SELECTION, and using information criteria for selection of best fitting specification (done by hand with "just around" and unfiltered data)

est drop _all
quiet eststo: xtreg pcvac treat##time i.syear treat pcA pcB pcC pcD pcE inhabitants d.inhabitants pcAustria pcTurkey pcnonEu pcuni pcprimary pcsecundary pctertiary pcselfemp pcnotworking pcclark pcchildren pcyoungadults pcadults pcseniors if owner == "total", fe vce(cluster distrid) 
quiet eststo: xtreg pcvac treat##time i.syear treat pcA pcB pcC pcD pcE inhabitants d.inhabitants pcAustria pcnonEu pcuni pcprimary pcsecundary pctertiary pcselfemp pcnotworking pcclark pcchildren pcyoungadults pcadults pcseniors if owner == "total", fe vce(cluster distrid) 
quiet eststo: xtreg pcvac treat##time i.syear treat pcA pcB pcC pcD pcE inhabitants d.inhabitants pcAustria pcnonEu pcuni pcprimary pcsecundary pctertiary pcselfemp pcnotworking pcchildren pcyoungadults pcadults pcseniors if owner == "total", fe vce(cluster distrid) 
quiet eststo: xtreg pcvac treat##time i.syear treat pcA pcB pcC pcD pcE inhabitants d.inhabitants pcAustria pcnonEu pcuni pcprimary pcsecundary pcselfemp pcnotworking pcchildren pcyoungadults pcadults pcseniors if owner == "total", fe vce(cluster distrid) 
quiet eststo: xtreg pcvac treat##time i.syear treat pcA pcB pcC pcD pcE inhabitants d.inhabitants pcAustria pcnonEu pcuni pcprimary pcsecundary pcselfemp pcchildren pcyoungadults pcadults pcseniors if owner == "total", fe vce(cluster distrid) 
quiet eststo: xtreg pcvac treat##time i.syear treat pcA pcB pcC pcD pcE inhabitants d.inhabitants pcAustria pcnonEu pcuni pcprimary pcsecundary pcselfemp pcchildren pcyoungadults pcadults pcseniors if owner == "total", fe vce(cluster distrid) 
quiet eststo: xtreg pcvac treat##time i.syear treat pcB pcC pcD pcE inhabitants d.inhabitants pcAustria pcnonEu pcuni pcprimary pcsecundary pcselfemp pcchildren pcyoungadults pcadults pcseniors if owner == "total", fe vce(cluster distrid) 
quiet eststo: xtreg pcvac treat##time i.syear treat pcB pcC pcE inhabitants d.inhabitants pcAustria pcnonEu pcuni pcprimary pcsecundary pcselfemp pcchildren pcyoungadults pcadults pcseniors if owner == "total", fe vce(cluster distrid) 
quiet eststo: xtreg pcvac treat##time i.syear treat pcB pcC pcE inhabitants d.inhabitants pcAustria pcnonEu pcuni pcprimary pcsecundary pcselfemp pcchildren pcadults pcseniors if owner == "total", fe vce(cluster distrid) 
quiet eststo: xtreg pcvac treat##time i.syear treat pcB pcC pcE inhabitants d.inhabitants pcAustria pcnonEu pcuni pcprimary pcsecundary pcselfemp pcadults pcseniors if owner == "total", fe vce(cluster distrid) 
quiet eststo: xtreg pcvac treat##time i.syear treat pcB pcC pcE inhabitants d.inhabitants pcAustria pcuni pcprimary pcsecundary pcselfemp pcadults pcseniors if owner == "total", fe vce(cluster distrid) 
quiet eststo: xtreg pcvac treat##time i.syear treat pcB pcC pcE inhabitants d.inhabitants pcAustria pcuni pcprimary pcsecundary pcselfemp pcseniors if owner == "total", fe vce(cluster distrid) 
quiet eststo: xtreg pcvac treat##time i.syear treat pcB pcC pcE inhabitants pcAustria pcuni pcprimary pcsecundary pcselfemp pcseniors if owner == "total", fe vce(cluster distrid) 
quiet eststo: xtreg pcvac treat##time i.syear treat pcB pcC pcE inhabitants pcAustria pcprimary pcsecundary pcselfemp pcseniors if owner == "total", fe vce(cluster distrid) 
quiet eststo: xtreg pcvac treat##time i.syear treat pcB pcC pcE inhabitants pcAustria pcprimary pcsecundary pcselfemp if owner == "total", fe vce(cluster distrid) 
quiet eststo: xtreg pcvac treat##time i.syear treat pcB pcC pcE inhabitants pcprimary pcsecundary pcselfemp if owner == "total", fe vce(cluster distrid) 
quiet eststo: xtreg pcvac treat##time i.syear treat pcB pcC inhabitants pcprimary pcsecundary pcselfemp if owner == "total", fe vce(cluster distrid) 
quiet eststo: xtreg pcvac treat##time i.syear treat pcB pcC inhabitants pcprimary pcsecundary if owner == "total", fe vce(cluster distrid) 

esttab est1 est2 est3 est4 est5 est6 est7 est8 est9 est10, aic bic p title(linear model: backward selection with GWZ and VZ controls, $filter $version) noomitted nobaselevels order(1.treat#1.time) interaction() b(%9.3f )
esttab est11 est12 est13 est14 est15 est16 est17 est18, aic bic p title(linear model: backward selection with GWZ and VZ controls, $filter $version 2) noomitted nobaselevels order(1.treat#1.time) interaction() b(%9.3f )
 
* not filtered: --> AIC chooses 15, BIC 16, coefficient of treat#time alwayse highly significant! 
* filtered: --> IC prefer always more parsimonious models
 
 
esttab est* using lpbuildup$version$filter.tex, replace p title(linear model: backward selection with GWZ and VZ controls, $filter $version) noomitted nobaselevels interaction() order(1.treat#1.time) compress long b(%9.3f )

* by owner, with controls (those controls chosen for unfiltered dataset)

est drop _all

quiet eststo: xtreg pcvac i.treat##i.time i.syear treat pcB pcC pcE inhabitants pcprimary pcsecundary pcselfemp if owner == "total", fe vce(cluster distrid)
quiet eststo: xtreg pcvac i.treat##i.time i.syear treat pcB pcC pcE inhabitants pcprimary pcsecundary pcselfemp if owner == "char", fe vce(cluster distrid)
quiet eststo: xtreg pcvac i.treat##i.time i.syear treat pcB pcC pcE inhabitants pcprimary pcsecundary pcselfemp if owner == "fed", fe vce(cluster distrid)
quiet eststo: xtreg pcvac i.treat##i.time i.syear treat pcB pcC pcE inhabitants pcprimary pcsecundary pcselfemp if owner == "manypriv", fe vce(cluster distrid)
quiet eststo: xtreg pcvac i.treat##i.time i.syear treat pcB pcC pcE inhabitants pcprimary pcsecundary pcselfemp if owner == "muni", fe vce(cluster distrid)
quiet eststo: xtreg pcvac i.treat##i.time i.syear treat pcB pcC pcE inhabitants pcprimary pcsecundary pcselfemp if owner == "onepriv", fe vce(cluster distrid)
quiet eststo: xtreg pcvac i.treat##i.time i.syear treat pcB pcC pcE inhabitants pcprimary pcsecundary pcselfemp if owner == "othleg", fe vce(cluster distrid)
quiet eststo: xtreg pcvac i.treat##i.time i.syear treat pcB pcC pcE inhabitants pcprimary pcsecundary pcselfemp if owner == "state", fe vce(cluster distrid)

esttab est*, compress p mtitles("total" "char" "fed" "manypriv" "muni" "onepriv" "othleg" "state") title(by owner, backw sel controls, version $version, data $filter) noomitted nobaselevels order(1.treat#1.time)
esttab est* using lpbyowner_backselcontrols$verion$filter.tex, replace compress p mtitles("total" "char" "fed" "manypriv" "muni" "onepriv" "othleg" "state") title(by owner, backw sel controls, version $version, data $filter) noomitted nobaselevels  order(1.treat#1.time)


********************************************************************************

* use LASSO for model selection (Chosen controls are used from now on. Possibly differs depending on whether filtered or unfiltered data is used and which constructions periods are compared!)

* rlasso: Ahrens, A., Hansen, C.B., Schaffer, M.E. 2019.  lassopack: Model selection and prediction with regularized regression in Stata https://arxiv.org/abs/1901.05397

gen inter = treat*time
rlasso pcvac inter treat time i.syear pcA pcB pcC pcD pcE inhabitants pcAustria pcTurkey pcnonEu pcuni pcprimary pcsecundary pctertiary pcselfemp pcnotworking pcclark pcchildren pcyoungadults pcadults pcseniors if owner == "total", pnotpen(inter) fe cluster(distrid)

* for the further analysis, the selected variables are chosen:

local indepvars=e(selected)
global indepvars "`indepvars'"

* note that these may differ depending on the specification/ filtered not filtered etc. sparser than backward selev´ction using information criteria

********************************************************************************

* again by owner

est drop _all
quiet eststo: xtreg pcvac treat##time i.syear $indepvars if owner == "priv", fe vce(cluster distrid)
quiet eststo: xtreg pcvac treat##time i.syear $indepvars if owner == "pub", fe vce(cluster distrid)

esttab est*, p mtitles("privately owned" "publicly owned") title(with GWZ and VZ lasso controls) noomitted nobaselevels interaction(x) order(1.treat#1.time)
esttab est* using lppubvspriv$version$filter.tex, replace p compress title(publicly vs privately owner - with GWZ and VZ controls) noomitted nobaselevels interaction(x) order(1.treat#1.time) b(%9.3f )


est drop _all
quiet eststo: xtreg pcvac i.treat##i.time i.syear $indepvars if owner == "char", fe vce(cluster distrid)
quiet eststo: xtreg pcvac i.treat##i.time i.syear $indepvars if owner == "fed", fe vce(cluster distrid)
quiet eststo: xtreg pcvac i.treat##i.time i.syear $indepvars if owner == "manypriv", fe vce(cluster distrid)
quiet eststo: xtreg pcvac i.treat##i.time i.syear $indepvars if owner == "muni", fe vce(cluster distrid)
quiet eststo: xtreg pcvac i.treat##i.time i.syear $indepvars if owner == "onepriv", fe vce(cluster distrid)
quiet eststo: xtreg pcvac i.treat##i.time i.syear $indepvars if owner == "othleg", fe vce(cluster distrid)

esttab est*, p mtitles("char" "fed" "manypriv" "muni" "onepriv" "othleg") title(with GWZ and VZ lasso controls, $filter $version) noomitted nobaselevels interaction(x) order(1.treat#1.time)
esttab using lpbyowner$version$filter.tex, replace p compress mtitles("char" "fed" "manypriv" "muni" "onepriv" "othleg") title(effect by owner - with GWZ and VZ lasso controls, $filter $version) noomitted nobaselevels interaction(x) order(1.treat#1.time) b(%9.3f )

********************************************************************************
* placebo breaks
* do it without controls, some collinearity issues otherwise

est drop _all

replace time = syear > 1981
quiet eststo: xtreg pcvac i.treat##i.time if owner == "priv" & syear != 1971 & syear != 2001, fe vce(cluster distrid)
quiet eststo: xtreg pcvac i.treat##i.time if owner == "pub" & syear != 1971 & syear != 2001, fe vce(cluster distrid)

replace time = syear > 1971
quiet eststo: xtreg pcvac i.treat##i.time if owner == "priv" & syear != 1991 & syear != 2001, fe vce(cluster distrid)
quiet eststo: xtreg pcvac i.treat##i.time if owner == "pub" & syear != 1991 & syear != 2001, fe vce(cluster distrid)

replace time = syear > 1991
quiet eststo: xtreg pcvac i.treat##i.time if owner == "priv" & syear != 1971 & syear != 1981, fe vce(cluster distrid)
quiet eststo: xtreg pcvac i.treat##i.time if owner == "pub" & syear != 1971 & syear != 1981, fe vce(cluster distrid)

esttab est*, p mtitles("private 1981" "public 1981" "private 1971" "public 1971" "private 1991" "public 1991") title(placebo breaks, no controls, $version $filter) noomitted nobaselevels order(1.treat#1.time)
esttab est* using lpplacebobreaks_nocontrols_$version$filter.tex, b(%9.3f ) replace p compress mtitles("private 1981" "public 1981" "private 1971" "public 1971" "private 1991" "public 1991") title(placebo breaks, no controls, $version $filter) noomitted nobaselevels interaction(x) order(1.treat#1.time)

* --> only significant at the 1971 pseudo break for unfiltered data (everything insignificant for filtered data)

********************************************************************************
* placebo breaks with lasso controls

est drop _all

replace time = syear > 1981
quiet eststo: xtreg pcvac treat##time i.syear $indepvars if owner == "priv" & syear != 1971 & syear != 2001, fe vce(cluster distrid)
quiet eststo: xtreg pcvac treat##time i.syear $indepvars if owner == "pub" & syear != 1971 & syear != 2001, fe vce(cluster distrid)

replace time = syear > 1971
quiet eststo: xtreg pcvac treat##time i.syear $indepvars if owner == "priv" & syear != 1991 & syear != 2001, fe vce(cluster distrid)
quiet eststo: xtreg pcvac treat##time i.syear $indepvars if owner == "pub" & syear != 1991 & syear != 2001, fe vce(cluster distrid)

replace time = syear > 1991
quiet eststo: xtreg pcvac treat##time i.syear $indepvars if owner == "priv" & syear != 1971 & syear != 1981, fe vce(cluster distrid)
quiet eststo: xtreg pcvac treat##time i.syear $indepvars if owner == "pub" & syear != 1971 & syear != 1981, fe vce(cluster distrid)

esttab est*, p mtitles("private 1981" "public 1981" "private 1971" "public 1971" "private 1991" "public 1991") title(placebo breaks, lasso controls, $version $filter) noomitted nobaselevels order(1.treat#1.time)
esttab est* using lpplacebobreaks_lassocontrols_$version$filter.tex, b(%9.3f ) replace p compress mtitles("private 1981" "public 1981" "private 1971" "public 1971" "private 1991" "public 1991") title(placebo breaks, lasso controls, $version $filter) noomitted nobaselevels interaction(x) order(1.treat#1.time)

* --> same ...

********************************************************************************
* placebo breaks with full controls

est drop _all

replace time = syear > 1981
quiet eststo: xtreg pcvac treat##time i.syear pcA-pcrowtot pcAustria-pccommuter if owner == "priv" & syear != 1971 & syear != 2001, fe vce(cluster distrid)
quiet eststo: xtreg pcvac treat##time i.syear pcA-pcrowtot pcAustria-pccommuter if owner == "pub" & syear != 1971 & syear != 2001, fe vce(cluster distrid)

replace time = syear > 1971
quiet eststo: xtreg pcvac treat##time i.syear pcA-pcrowtot pcAustria-pccommuter if owner == "priv" & syear != 1991 & syear != 2001, fe vce(cluster distrid)
quiet eststo: xtreg pcvac treat##time i.syear pcA-pcrowtot pcAustria-pccommuter if owner == "pub" & syear != 1991 & syear != 2001, fe vce(cluster distrid)

esttab est*, p mtitles("private 1981" "public 1981" "private 1971" "public 1971") title(placebo breaks, full controls, $version $filter) noomitted nobaselevels order(1.treat#1.time)
esttab est* using lpplacebobreaks_fullcontrols_$version$filter.tex, b(%9.3f ) replace p compress mtitles("private 1981" "public 1981" "private 1971" "public 1971") title(placebo breaks, full controls, $version $filter) noomitted nobaselevels interaction(x) order(1.treat#1.time)

* note: insufficient obeservations to do the 1991 pseudo break
* --> unfiltered: interestingly, with full controls, 1981 break is strongest

* set time indicator back to actual policy break
replace time = syear > 1981

********************************************************************************
* SUBGROUPS

* only statutary cities

est drop _all
quiet eststo: xtreg pcvac treat##time i.syear $indepvars if owner == "total" & city == 1, fe vce(cluster distrid)
quiet eststo: xtreg pcvac treat##time i.syear $indepvars if owner == "priv" & city == 1, fe vce(cluster distrid)
quiet eststo: xtreg pcvac treat##time i.syear $indepvars if owner == "pub" & city == 1, fe vce(cluster distrid)

esttab est*, p mtitles("total" "privately owned" "publicly owned") title(with GWZ and VZ controls - only cities) noomitted nobaselevels interaction(x) order(1.treat#1.time)
esttab est* using lpcities$version$filter.tex, b(%9.3f ) p mtitles("total" "privately owned" "publicly owned") title(with GWZ and VZ controls - only cities, $filter $version) replace noomitted nobaselevels interaction(x) order(1.treat#1.time)

* east vs west Austria
* east

est drop _all
quiet eststo: xtreg pcvac treat##time i.syear $indepvars if owner == "total" & region == "east", fe vce(cluster distrid)
quiet eststo: xtreg pcvac treat##time i.syear $indepvars if owner == "priv" & region == "east", fe vce(cluster distrid)
quiet eststo: xtreg pcvac treat##time i.syear $indepvars if owner == "pub" & region == "east", fe vce(cluster distrid)

esttab est*, p mtitles("total" "privately owned" "publicly owned") title(with GWZ and VZ controls - eastern Asutria) noomitted nobaselevels interaction(x) order(1.treat#1.time)
esttab est* using lpeast$version$filter.tex, b(%9.3f ) p mtitles("total" "privately owned" "publicly owned") title(with GWZ and VZ controls - only cities, $filter $version) replace noomitted nobaselevels interaction(x) order(1.treat#1.time)

* west

est drop _all
quiet eststo: xtreg pcvac treat##time i.syear $indepvars if owner == "total" & region == "west", fe vce(cluster distrid)
quiet eststo: xtreg pcvac treat##time i.syear $indepvars if owner == "priv" & region == "west", fe vce(cluster distrid)
quiet eststo: xtreg pcvac treat##time i.syear $indepvars if owner == "pub" & region == "west", fe vce(cluster distrid)

esttab est*, p mtitles("total" "privately owned" "publicly owned") title(with GWZ and VZ controls - western Austria ) noomitted nobaselevels interaction(x) order(1.treat#1.time)
esttab est* using lpwest$version$filter.tex, b(%9.3f ) p mtitles("total" "privately owned" "publicly owned") title(with GWZ and VZ controls - only cities, $filter $version) replace noomitted nobaselevels interaction(x) order(1.treat#1.time)

********************************************************************************
* for comparison with weighted logit models:
* by owner with GWZ and with GWZ and VZ controls

* GWZ

global indepvarsGWZ "pcA pcB pcC pcD pcE pcflatowner pchouseowner pcrented pcservice pcother pcselfused"
global indepvarsVZ "pcAustria pcaliens pcEu pcTurkey pcnonEu pcuni pcprimary pcmarried pcselfemp pcnotworking pcclark inhabitants pcchildren pcyoungadults pcadults pcseniors pctertiary pcsecundary pccommuter"

est drop _all
quiet eststo: xtreg pcvac treat##time i.syear $indepvarsGWZ if owner == "priv", fe vce(cluster distrid)
quiet eststo: xtreg pcvac treat##time i.syear $indepvarsGWZ if owner == "pub", fe vce(cluster distrid)

esttab est*, p mtitles("privately owned" "publicly owned") title(with GWZ and VZ lasso controls) noomitted nobaselevels interaction(x) order(1.treat#1.time)
esttab est* using lppubvspriv_gwzcontrols_$version$filter.tex, replace p compress title(publicly vs privately owner - with GWZ controls) noomitted nobaselevels interaction(x) order(1.treat#1.time) b(%9.3f )


* GWZ and VZ

est drop _all
quiet eststo: xtreg pcvac treat##time i.syear $indepvarsGWZ $indepvarsVZ if owner == "priv", fe vce(cluster distrid)
quiet eststo: xtreg pcvac treat##time i.syear $indepvarsGWZ $indepvarsVZ if owner == "pub", fe vce(cluster distrid)

esttab est*, p mtitles("privately owned" "publicly owned") title(with GWZ and VZ lasso controls) noomitted nobaselevels interaction(x) order(1.treat#1.time)
esttab est* using lppubvspriv_fullcontrols_$version$filter.tex, replace p compress title(publicly vs privately owner - with full controls) noomitted nobaselevels interaction(x) order(1.treat#1.time) b(%9.3f )

********************************************************************************

* COLLECTION OF OUTPUTS FOR THE PAPER

global indepvarsGWZ "pcA pcB pcC pcD pcE pcrented pcservice pcother pcselfused"
global indepvarsVZ "pcAustria pcaliens pcEu pcTurkey pcnonEu pcuni pcprimary pcmarried pcselfemp pcnotworking pcclark inhabitants pcchildren pcyoungadults pcadults pcseniors pctertiary pcsecundary pccommuter"

* 1) results by owner

est drop _all
quiet eststo: xtreg pcvac treat##time i.syear $indepvarsVZ $indepvarsGWZ if owner == "total", fe vce(cluster distrid)
quiet eststo: xtreg pcvac treat##time i.syear $indepvarsVZ $indepvarsGWZ if owner == "priv", fe vce(cluster distrid)
quiet eststo: xtreg pcvac treat##time i.syear $indepvarsVZ $indepvarsGWZ if owner == "pub", fe vce(cluster distrid)

esttab est*, p mtitles("total" "privately owned" "publicly owned") title(with GWZ and VZ lasso controls) noomitted nobaselevels interaction("x") order(1.treat#1.time)
esttab est* using lppubvspriv$version$filter.tex, replace compress title(publicly vs privately owner - with GWZ and VZ controls) noomitted nobaselevels interaction(x) order(1.treat#1.time) b(%9.3f) se


est drop _all
quiet eststo: xtreg pcvac i.treat##i.time i.syear $indepvarsVZ $indepvarsGWZ if owner == "onepriv", fe vce(cluster distrid)
quiet eststo: xtreg pcvac i.treat##i.time i.syear $indepvarsVZ $indepvarsGWZ if owner == "manypriv", fe vce(cluster distrid)
quiet eststo: xtreg pcvac i.treat##i.time i.syear $indepvarsVZ $indepvarsGWZ if owner == "char", fe vce(cluster distrid)
quiet eststo: xtreg pcvac i.treat##i.time i.syear $indepvarsVZ $indepvarsGWZ if owner == "othleg", fe vce(cluster distrid)
quiet eststo: xtreg pcvac i.treat##i.time i.syear $indepvarsVZ $indepvarsGWZ if owner == "fed", fe vce(cluster distrid)
quiet eststo: xtreg pcvac i.treat##i.time i.syear $indepvarsVZ $indepvarsGWZ if owner == "state", fe vce(cluster distrid)
quiet eststo: xtreg pcvac i.treat##i.time i.syear $indepvarsVZ $indepvarsGWZ if owner == "muni", fe vce(cluster distrid)

esttab est*, mtitles("onepriv" "manypriv" "char" "othleg" "fed" "state" "muni") title(with GWZ and VZ lasso controls, $filter $version) noomitted nobaselevels interaction(\times) order(1.treat#1.time) se b(%9.3f )
esttab using lpbyowner$version$filter.tex, replace compress mtitles("onepriv" "manypriv" "char" "othleg" "fed" "state" "muni") title(effect by owner - with GWZ and VZ lasso controls, $filter $version) noomitted nobaselevels interaction(\times) order(1.treat#1.time) se b(%9.3f )








































