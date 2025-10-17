/*******************************************************************************
"Automation and New Tasks: How Technology Changes Labor Demand" 
by D. Acemoglu and P. Restrepo, JEP 2019

2.22.2019
Pascual Restrepo

This do file implements decomposition of the sources of the changes in labor demand
for the years 1947-1987 - manufacturing
sector and produces:
- Figure 3  - panel C
- Figure A3 - panel A
- Figure A11

(revised by G. Marcolongo on 3.27.2019)
*******************************************************************************/

if $appendix==1{
local title ", sigma=${sigma}"
local stub "_appendix"
}
else if $appendix==0{
local title
local stub
}

**Open dataset and merge TFP data**
use "${project}/clean_data/panel_bea72.dta", clear
* keep only manufacturing sector
keep if manuf==1
sort indcode year

********************************************
*Provide measures of value added and prices*
********************************************
*Baseline choice:                          *
*gen vadded_i=bea_vadded                   *
*gen wages_i=bea_comp                      *  
*gen priceR_i=bls_R_full                   *
*gen priceW_i=bls_W_adj                    *
********************************************
gen vadded_i=bea72_vadded
gen wages_i=bea72_comp
gen priceR_i=bea72_R_full
gen priceW_i=bea72_W_unadj

**Generate macroeconomic aggregates**
sort indcode year

bys year: egen gdp_manuf=total(vadded_i) 		/*GDP in nominal terms*/

bys year: egen wbill_manuf=total(wages_i)		/*Wage bill in nominal terms*/

gen labsh_us=wbill_manuf/gdp_manuf				/*Labor share. Note this is smaller than headline BLS measure because it misses the self employed.
                                                           Self-employment declined from 14 percent in 1948 to 8.5 in 2012.
														   These changes in self-employment generate a larger decline in labor share. */

gen log_gdp_manuf=ln(gdp_manuf*price_us/population_us) 		/*GDP per capita in real terms using PCE index*/

gen log_wbill_manuf=ln(wbill_manuf*price_us/population_us)	/*Wage bill per capita in real terms using PCE index*/

gen log_qty_manuf=ln(qty_manuf/population_us)				/*Index of quantities produced in manufacturing*/
 
gen log_price_manuf=ln(gdp_manuf*price_us/qty_manuf)    	/*Price index for manufacturing sector relative to consumption good*/


* * * Generate measures for the observed change in wage bill and output * * * *
sort indcode year

bys indcode: gen cum_delta_wbill_manuf=100*(log_wbill_manuf-log_wbill_manuf[1]) /* Cumulative change in WAGE BILL */
assert cum_delta_wbill_manuf==0 if year==1947

bys indcode: gen cum_prod_effect=100*(log_gdp_manuf-log_gdp_manuf[1])			/* PRODUCTIVITY effect */
assert cum_prod_effect==0 if year==1947

bys indcode: gen cum_qty_effect=100*(log_qty_manuf-log_qty_manuf[1])			/* Cumulative change in QUANTITY manufactured */
assert cum_qty_effect==0 if year==1947

bys indcode: gen cum_price_effect=100*(log_price_manuf-log_price_manuf[1])		/* Cumulative change in relative PRICE index for manufacturing sector relative to consumption good */
assert cum_price_effect==0 if year==1947

* * * Sectoral shares and statistics                                    * * * * 
* * * Share of GDP, Labor share at time t and at intitial point (1947)  * * * *
sort indcode year

gen gdpsh_i=vadded_i/gdp_manuf  			/*Share GDP i: Contribution of sector i to GDP (chi_ i)*/

gen labsh_i=wages_i/vadded_i 				/*Labor share i: Contribution of labor to value added in sector i (s_i)*/

bys indcode: gen base_gdpsh=gdpsh_i[1] 		/*Initial share GDP in industry i (chi_i in 1947)*/
assert base_gdpsh==gdpsh_i if year==1947

bys indcode: gen base_labsh=labsh_i[1]		/*Initial labor share in industry i (s_i in 1947) */
assert base_labsh==labsh_i if year==1947

* * * Measure the contribution of the COMPOSITION EFFECT                 * * * *
* * * (see the appendix for the derivations, pagg. A6 - A7)				 * * * *
sort indcode year

bys year: egen  comp_actual_1=total(gdpsh_i*labsh_i)    		/*Actual contribution from observed sectoral contribution given the labor intensity of sectors*/

bys year: egen comp_counter_1=total(base_gdpsh*labsh_i)			/*Counterfactual leaving sectoral contribution unchanged at its baseline level*/

gen cum_composition=100*(ln(comp_actual_1)-ln(comp_counter_1))	/*Contribution of compositional shifts*/

* * * Measure the contribution of changes in TASK CONTENT of production  		* * * *
* * *  and SUBSTITUTION effects (see the appendix for derivations, pagg. A8-A10) * * * *
sort indcode year

gen logW_i=ln(priceW_i)			/*Observed wages adjusted from composition, BEA*/

gen logR_i=ln(priceR_i)			/*Observed rental rates of capital, BEA */

gen ln_labsh_i=ln(labsh_i)  	/*Observed decline in labor share, BEA  */

gen substitution_i=(1-${sigma})*(1-base_labsh)*(d.logW_i-d.logR_i-${growth_rate_1947_1987}) /*Formula for the substitution effect (see appendix - pag. A9)*/

gen task_content_i=d.ln_labsh_i-substitution_i                                             	/*Formula for changes in the task content (see appendix - pag. A9)*/
*Note: the last three measures need to be cummulated*

* * * Disentangle the DISPLACEMENT and REINSTATEMENT effect using 5 year moving averages * * *
sort indcode year

* Calculate mean of task content for each industry at 5 years MA centered at current year
* (Baseline: 5-year moving averages) 
rangestat (mean) task_content_*, interval(year -2 2) by(indcode)

*Industry element of the Displacement effect:
gen task_negative_5yr=min(task_content_i_mean,0)

*Industry element of the Reinstatement effect: 
gen task_positive_5yr=max(task_content_i_mean,0)

***Collapse by period to implement decomposition and calculate industry weights ***
sort indcode year
bys indcode: gen base_share=wages_i[1]/wbill_manuf[1] 			/*Weights used in published version: Weighting leaves composition of economy unchanged at its 1947 level. Exact decomposition except for approximations of log changes*/
bys indcode: gen lagged_share=wages_i[_n-1]/wbill_manuf[_n-1] 	/*Weights used in working-paper version: Use this weights to implement decomposition using rolling basis. Decomposition not exact in this case*/
collapse (mean) cum_* (sum) substitution_i task_content_* task_negative* task_positive*  [iw=base_share], by(year)

*Declare time series*
tsset year

*Cumulate variables since 1947 (substitution effect, task content of production, 
*displacement and reinstatement effect)  * * * * *
foreach var of varlist substitution_i task_content_* task_negative* task_positive*{
gen cum_`var'=100*sum(`var')
replace cum_`var'=0 if year==1947
}

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* * * * * * * * * * * * * *      GRAPHS      * * * * * * * * * * * * * * * * * *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

* * * Decomposition of manufacturing wage bill in : Productivity, Substition * *
* * * Composition, Change in Task Content and Price Effect                 * * *
* * * FIGURE A3 - Panel A: Manufacturing Wage Bill, 1947 - 1947            * * *

*manual labels to the right*
gen label_prod="Productivity effect" if year==1987
gen label_comp="Composition effect" if year==1987
gen label_subs="Substitution effect" if year==1986
gen label_task="Change in task content" if year==1987
gen label_wbill="Observed wage bill" if year==1987
gen label_price="Price effect" if year==1987

if $sigma < 1{

 global mlabpos_1 mlabpos(1)
 global mlabpos_2 mlabpos(1)
 global mlabpos_3 mlabpos(3)
 
 }
 else if $sigma ==1{
  
 global mlabpos_1 mlabpos(1)
 global mlabpos_2 mlabpos(7)
 global mlabpos_3 mlabpos(4)
 }
else if $sigma ==1.2{
  
 global mlabpos_1 mlabpos(3)
 global mlabpos_2 mlabpos(4)
 global mlabpos_3 mlabpos(1)
 }
 
*Plot decomposition: labor demand*
twoway (connected  cum_qty_effect year, $style_prod_effect mlabel(label_prod)) ///
	   (connected  cum_price_effect year, $style_price_effect mlabel(label_price)) ///
	   (connected  cum_comp year, $style_comp_effect mlabel(label_comp) $mlabpos_1) ///
	   (connected  cum_substitution_i year, $style_price_subs mlabel(label_subs) $mlabpos_2) ///
       (connected  cum_task_content_i year, $style_task_content mlabel(label_task) $mlabpos_3) ///
	   (connected  cum_delta_wbill_manuf year, $style_observed mlabel(label_wbill)), ///
       title("Manufacturing wage bill, 1947-1987 `title' ", size(medium) position(11)) ytitle("")  xtitle("")  yscale(noline) ///
	   ylabel(#8, noticks angle(horizontal)) legend(off) xlabel(1947(5)1987) xscale(r(1947 1990)) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white)) ysize(4) xsize(8)
graph export "${project}\figs\decomposition_wbill_1947_1987_sigma_${sigma}_manuf`stub'.eps", as(eps) preview(on) replace

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* * Displacement and Reinstatement effect for the manufacturing sector 1947 - 1987  * * *
* * * FIGURE 3 - Panel C  sigma= 0.8 					* * * * * * * * * * * * * * * * *
* * * FIGURE A11 - Panel A  sigma= 0.6 					* * * * * * * * * * * * * * * * *
* * * FIGURE A11 - Panel B  sigma= 0.8 					* * * * * * * * * * * * * * * * *
* * * FIGURE A11 - Panel C  sigma= 1.0 					* * * * * * * * * * * * * * * * *
* * * FIGURE A11 - Panel D  sigma= 1.0 					* * * * * * * * * * * * * * * * *

*manual labels to the right*
gen label_reinstatement="Reinstatement" if year==1987
gen label_displacement="Displacement" if year==1987
gen label_task1="Change in task content" if year==1985

*Plot bounds on task content, version*
twoway (connected  cum_task_positive_5yr year, $style_reinstatement mlabel(label_reinstatement)) ///
	   (connected  cum_task_negative_5yr year, $style_displacement mlabel(label_displacement)) ///
	   (connected  cum_task_content_i year, $style_task_content mlabel(label_task1) mlabpos(1)), ///
	   title("Manufacturing task content of production, 1947-1987 `title'  ", size(medium) position(11)) ytitle("")  xtitle("")  yscale(noline) ///
	   ylabel(-20(10)20, noticks angle(horizontal)) legend(off) xlabel(1947(5)1987) xscale(r(1947 1990)) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white)) ysize(4) xsize(8)
graph export "${project}\figs\taskcontent_1947_1987_sigma_${sigma}_estimates_manuf`stub'.eps", as(eps) preview(on) replace


* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*  Gradual decompositions*
* shows decomposition of labor demand on separate graph gradually adding different
* effects: Wage Bill --> Productivity Effect --> Relative Price Effect -->
* Composition Effect -- > Substition Effect --> Change in Task content of productoin

if $appendix==0{

******************** WAGE BILL ***************************
***Present basic decompositions for employment, wages and wage bill***
gen lw="Observed wage bill" if year==1987
*Plot decomposition: labor demand*
twoway (connected  cum_delta_wbill_manuf year, color(gs4) mlabcolor(gs4) msymbol(triangle) lpattern(solid) lwidth(thin) msize(vsmall) connect(direct) mlabel(lw)), ///
       title("Manufacturing wage bill, 1947-1987 `title' ", size(medium) position(11)) ytitle("")  xtitle("")  yscale(noline) ///
	   ylabel(#8, noticks angle(horizontal)) legend(off) xlabel(1947(5)1987) xscale(r(1947 1990)) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white)) ysize(4) xsize(8)
graph export "${project}\figs\decA_manuf1947_1987_sigma_${sigma}_estimates`stub'.eps", as(eps) preview(on) replace
   
******************** PRODUCTIVITY EFFECT ***************************      
gen l1="Productivity effect" if year==1987	
gen y1=cum_qty_effect
twoway (connected  y1 year, color(edkblue) mlabcolor(edkblue) msymbol(diamond_hollow) lpattern(tight_dot) lwidth(thin) msize(small) connect(direct) mlabel(l1)) ///
	   (connected  cum_delta_wbill_manuf year, color(gs4) mlabcolor(gs4) msymbol(triangle) lpattern(solid) lwidth(thin) msize(vsmall) connect(direct) mlabel(label_wbill)), ///
       title("Manufacturing wage bill, 1947-1987 `title' ", size(medium) position(11)) ytitle("")  xtitle("")  yscale(noline) ///
	   ylabel(#8, noticks angle(horizontal)) legend(off) xlabel(1947(5)1987) xscale(r(1947 1990)) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white)) ysize(4) xsize(8)
graph export "${project}\figs\decB_manuf1947_1987_sigma_${sigma}_estimates`stub'.eps", as(eps) preview(on) replace
	
******************* RELATIVE PRICE EFFECT **************************   
gen l1b="+Relative price effect" if year==1986	
gen y1b=cum_prod_effect
twoway (connected  y1 year, color(gs12) msymbol(circle) lpattern(tight_dot) lwidth(thin) msize(vsmall) connect(direct)) ///
	   (connected  y1b year, color(edkblue) mlabcolor(edkblue) msymbol(diamond_hollow) lpattern(tight_dot) lwidth(thin) msize(small) connect(direct) mlabel(l1b) mlabpos(4)) ///
	   (connected  cum_delta_wbill_manuf year, color(gs4) mlabcolor(gs4) msymbol(triangle) lpattern(solid) lwidth(thin) msize(vsmall) connect(direct) mlabel(label_wbill)), ///
       title("Manufacturing wage bill, 1947-1987 `title' ", size(medium) position(11)) ytitle("")  xtitle("")  yscale(noline) ///
	   ylabel(#8, noticks angle(horizontal)) legend(off) xlabel(1947(5)1987) xscale(r(1947 1990)) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white)) ysize(4) xsize(8)
graph export "${project}\figs\decB2_manuf1947_1987_sigma_${sigma}_estimates`stub'.eps", as(eps) preview(on) replace

******************** COMPOSITION EFFECT ***************************  	
gen l2="+Composition effect" if year==1987	   
gen y2=y1b+cum_comp
twoway (connected  y1 year, color(gs12) msymbol(circle) lpattern(tight_dot) lwidth(thin) msize(vsmall) connect(direct)) ///
	   (connected  y1b year, color(gs12) msymbol(circle) lpattern(tight_dot) lwidth(thin) msize(vsmall) connect(direct)) ///
	   (connected  y2 year, color(edkblue) mlabcolor(edkblue) msymbol(diamond_hollow) lpattern(tight_dot) lwidth(thin) msize(small) connect(direct) mlabel(l2)) ///
	   (connected  cum_delta_wbill_manuf year, color(gs4) mlabcolor(gs4) msymbol(triangle) lpattern(solid) lwidth(thin) msize(vsmall) connect(direct) mlabel(label_wbill) mlabpos(1)), ///
       title("Manufacturing wage bill, 1947-1987 `title' ", size(medium) position(11)) ytitle("")  xtitle("")  yscale(noline) ///
	   ylabel(#8, noticks angle(horizontal)) legend(off) xlabel(1947(5)1987) xscale(r(1947 1990)) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white)) ysize(4) xsize(8)
graph export "${project}\figs\decC_manuf1947_1987_sigma_${sigma}_estimates`stub'.eps", as(eps) preview(on) replace
	   
******************** SUBSTITUTION EFFECT *************************** 	   	   
gen l3="+Price substitution" if year==1987	   
gen y3=y2+cum_substitution_i
twoway (connected  y1b year, color(gs12) msymbol(circle) lpattern(tight_dot) lwidth(thin) msize(vsmall) connect(direct)) ///
	   (connected  y1 year, color(gs12) msymbol(circle) lpattern(tight_dot) lwidth(thin) msize(vsmall) connect(direct)) ///
	   (connected  y2 year, color(gs12) msymbol(circle) lpattern(tight_dot) lwidth(thin) msize(vsmall) connect(direct) ) ///
	   (connected  y3 year, color(edkblue) mlabcolor(edkblue) msymbol(diamond_hollow) lpattern(tight_dot) lwidth(thin) msize(small) connect(direct) mlabel(l3) mlabpos(2)) ///
	   (connected  cum_delta_wbill_manuf year, color(gs4) mlabcolor(gs4) msymbol(triangle) lpattern(solid) lwidth(thin) msize(vsmall) connect(direct) mlabel(label_wbill)), ///
       title("Manufacturing wage bill, 1947-1987 `title' ", size(medium) position(11)) ytitle("")  xtitle("")  yscale(noline) ///
	   ylabel(#8, noticks angle(horizontal)) legend(off) xlabel(1947(5)1987) xscale(r(1947 1990)) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white)) ysize(4) xsize(8)
graph export "${project}\figs\decD_manuf1947_1987_sigma_${sigma}_estimates`stub'.eps", as(eps) preview(on) replace

******************** CHANGE TASK CONTENT OF PRODUCTION ***************************   	     
gen l4="+Change task content of production" if year==1985	   
gen y4=y3+cum_task_content_i
twoway (connected  y1b year, color(gs12) msymbol(circle) lpattern(tight_dot) lwidth(thin) msize(vsmall) connect(direct)) ///
	   (connected  y1 year, color(gs12) msymbol(circle) lpattern(tight_dot) lwidth(thin) msize(vsmall) connect(direct)) ///
	   (connected  y2 year, color(gs12) msymbol(circle) lpattern(tight_dot) lwidth(thin) msize(vsmall) connect(direct) ) ///
	   (connected  y3 year, color(edkblue) mlabcolor(edkblue) msymbol(diamond_hollow) lpattern(tight_dot) lwidth(thin) msize(vsmall) connect(direct)) ///
	   (connected  y4 year, color(cranberry) mlabcolor(cranberry) msymbol(diamond) lpattern(tight_dot) lwidth(thin) msize(small) connect(direct) mlabel(l4) mlabpos(1)) ///
	   (connected  cum_delta_wbill_manuf year, color(gs4) mlabcolor(gs4) msymbol(triangle) lpattern(solid) lwidth(thin) msize(vsmall) connect(direct) mlabel(label_wbill) mlabpos(4)), ///
       title("Manufacturing wage bill, 1947-1987 `title' ", size(medium) position(11)) ytitle("")  xtitle("")  yscale(noline) ///
	   ylabel(#8, noticks angle(horizontal)) legend(off) xlabel(1947(5)1987) xscale(r(1947 1990)) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white)) ysize(4) xsize(8)
graph export "${project}\figs\decE_manuf1947_1987_sigma_${sigma}_estimates`stub'.eps", as(eps) preview(on) replace
}  


