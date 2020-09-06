
/* Master Thesis WS 2019/20

* DESCRIPTIVE STATISTICS

Produces graphs with timelines and distributions

*/

cd "\\fs.univie.ac.at\homedirs\alexanderg15\Documents\WS_201920\Masterarbeit\Daten"

clear
use prepdatafilter2
* use prepdata2

global filter f
* f ... only those with more than two apartments, n ... no filter. Appears in file names and titles

********************************************************************************

* TIMELINE

********************************************************************************

* timeline of the variables of interest - can one see the treatment effect in the shape of the graphs?

global varofint vac
* the rate of which variable should be plotted: vac / selfused

global owner total
* for which owner: total / priv / pub

global region ""
global region1 ""
* leave empty for all, otherwise state a keep-condition. region1 will be attached to title and name

global othercond ""
* leave empty for no conditions

do timelines
do timelines2
do timelines3

* timelines plots the vacancy rates, timelines2 plots the actual numbers (no rates), timelines3 plots average vacancy rate, not the vacancy rate after summing for the whole country, which corresponds more closely to what the linear percentages model does.

* conclusio: one cannot clearly see the effect with certainty in the aggregated vacancy rate over all districts. But this is possibly also due to only four years

* combine some graphs

graph combine vacoldnewtotaln vacjustaroundtotaln avgvacoldnewtotaln avgvacjustaroundtotaln vacoldnewtotalf vacjustaroundtotalf avgvacoldnewtotalf avgvacjustaroundtotalf, iscale(.3) rows(4) cols(2) name(vacratescombined, replace) title() graphregion(fcolor(white))
graph export vacratescombined.pdf, replace

********************************************************************************

* overview over distribution of vacancy rate over districts

hist pcvac if owner == "total" & built == "all" & syear == 2001, name(histpcvac2001, replace) graphregion(fcolor(white))
graph export histpcvac2001$filter.pdf, replace

hist pcvac if owner == "total" & built == "old" & syear == 2001, name(histpcvacold2001, replace) graphregion(fcolor(white))
graph export histpcvacold2001$filter.pdf, replace
hist pcvac if owner == "total" & built == "1961to1980" & syear == 2001, name(histpcvacafter19612001, replace) graphregion(fcolor(white))
graph export histpcvacafter19612001$filter.pdf, replace


********************************************************************************

* DISTRIBUTION BY OWNER AND CONSTRUCTION YEAR OVER ALL DISTRICTS

* distribution of share of privately owner buildings by old vs new over all districts for all years

foreach syear in 1971 1981 1991 2001 {
foreach owner in pcpriv {
foreach built in old new 1919to1944 1945to1960{

quiet hist rowtot if owner == "`owner'" & built == "`built'" & syear == `syear', percent graphregion(fcolor(white)) xsc(r(0.2 1)) xlabel(0.2(0.1)1) ysc(r(0 40)) ylabel(0(10)40) width(0.05) title("`owner' of `built' (`syear')") name(hist`owner'`built'`syear', replace)
quiet graph export hist`owner'`built'`syear'$filter.pdf, replace

}
}
}


* combine graphs regarding old vs new

graph combine histpcprivold1971 histpcprivold1981 histpcprivold1991 histpcprivold2001 histpcprivnew1971 histpcprivnew1981 histpcprivnew1991 histpcprivnew2001, iscale(.5) rows(2) cols(4) name(pcprioldvsnew, replace) title(pc privately owned: old vs new) graphregion(fcolor(white))
quiet graph export allyearspcprivoldvsnew$filter.pdf, replace


* --> old buildings are always more likely to be privately owned, even gets a bit more clear over the years

* combine graphs regarding 1919to1944 vs 1945to1960

graph combine histpcpriv1919to19441971 histpcpriv1919to19441981 histpcpriv1919to19441991 histpcpriv1919to19442001 histpcpriv1945to19601971 histpcpriv1945to19601981 histpcpriv1945to19601991 histpcpriv1945to19602001, rows(2) cols(4) iscale(.5) name(pcprivjustaroundthreshold, replace) title(pc privately owned: 1919to1944 vs 1945to1960) graphregion(fcolor(white))
quiet graph export allyearspcprivjustaroundthreshold$filter.pdf, replace


* --> no substantial change in ownership structures can be seen!

********************************************************************************

* for balance table see balance_table.do












































































