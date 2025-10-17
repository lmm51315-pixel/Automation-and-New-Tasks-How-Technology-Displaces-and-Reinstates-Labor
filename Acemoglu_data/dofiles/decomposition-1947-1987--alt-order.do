/*******************************************************************************
"Automation and New Tasks: How Technology Changes Labor Demand" 
by D. Acemoglu and P. Restrepo, JEP 2019

This do file implements decomposition of the sources of the changes in labor demand
for the years 1947-1987 using an alternative ordering of decomposition:

 - Figure A6 - Panel A
*******************************************************************************/

**Open dataset and merge TFP data**
use "${project}/clean_data/panel_bea72.dta", clear
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

bys year: egen gdp_us=total(vadded_i) 		/*GDP in nominal terms*/

bys year: egen wbill_us=total(wages_i)		/*Wage bill in nominal terms*/

gen labsh_us=wbill_us/gdp_us				/*Labor share. Note this is smaller than headline BLS measure because it misses the self employed.
                                                           Self-employment declined from 14 percent in 1948 to 8.5 in 2012.
														   These changes in self-employment generate a larger decline in labor share. */

gen log_gdp_us=ln(gdp_us*price_us/population_us) 		/*GDP per capita in real terms using PCE index*/

gen log_wbill_us=ln(wbill_us*price_us/population_us)	/*Wage bill per capita in real terms using PCE index*/


**Generate measures for the observed change in wage bill and output**
sort indcode year

bys indcode: gen cum_delta_wbill_us=100*(log_wbill_us-log_wbill_us[1])
assert cum_delta_wbill_us==0 if year==1947

bys indcode: gen cum_prod_effect_wbill=100*(log_gdp_us-log_gdp_us[1])
assert cum_prod_effect_wbill==0 if year==1947

**Sectoral shares and statistics**
sort indcode year

gen gdpsh_i=vadded_i/gdp_us  	/*Share GDP i: Contribution of sector i to GDP*/

gen labsh_i=wages_i/vadded_i /*Labor share i: Contribution of labor to value added in sector i*/

bys indcode: gen base_gdpsh=gdpsh_i[1] 		/*Initial share GDP in i*/
assert base_gdpsh==gdpsh_i if year==1947

bys indcode: gen base_labsh=labsh_i[1]		/*Initial labor share in i*/
assert base_labsh==labsh_i if year==1947

**Measure the contribution of the composition effect (see the appendix for the derivations)**
sort indcode year

bys year: egen  comp_actual_1=total(gdpsh_i*base_labsh)    		/*Actual contribution from observed sectoral contribution given the labor intensity of sectors*/

bys year: egen comp_counter_1=total(base_gdpsh*base_labsh)		/*Counterfactual leaving sectoral contribution unchanged at its baseline level*/

gen cum_composition=100*(ln(comp_actual_1)-ln(comp_counter_1))	/*Contribution of compositional shifts*/

**Measure the contribution of changes in task content and substitution effects (see the appendix for derivations)**
sort indcode year

gen logW_i=ln(priceW_i)	/*Observed wages adjusted from composition, BLS*/

gen logR_i=ln(priceR_i)	/*Observed rental rates of capital, BLS*/

gen ln_labsh_i=ln(labsh_i)  /*Observed decline in labor share, BEA*/

bys indcode: gen cum_substitution_i=100*(1-${sigma})*(1-base_labsh)*(logW_i-logW_i[1]-logR_i+logR_i[1]-(year-1947)*${growth_rate_1947_1987}) /*Formula for the substitution effect (see appendix)*/

bys indcode: gen cum_task_content_i=100*(ln_labsh_i-ln_labsh_i[1])-cum_substitution_i                                            	/*Formula for changes in the task content (see appendix)*/

***Collapse by period to implement decomposition***
sort indcode year
gen alt_wts=gdpsh_i*base_labsh
collapse (mean) cum_* [iw=alt_wts], by(year)

*Declare time series*
tsset year


***Present basic decompositions for employment, wages and wage bill***
*manual labels to the right*
gen label_prod="Productivity effect" if year==1987
gen label_comp="Composition effect" if year==1987
gen label_subs="Substitution effect" if year==1987
gen label_task="Change in task content" if year==1987
gen label_wbill="Observed wage bill" if year==1987

*Plot decomposition: labor demand*
twoway (connected  cum_prod_effect_wbill year, $style_prod_effect mlabel(label_prod)) ///
	   (connected  cum_comp year, $style_comp_effect mlabel(label_comp)) ///
	   (connected  cum_substitution_i year, $style_price_subs mlabel(label_subs) mlabpos(1)) ///
       (connected  cum_task_content_i year, $style_task_content mlabel(label_task) mlabpos(5)) ///
	   (connected  cum_delta_wbill_us year, $style_observed mlabel(label_wbill)), ///
       title("Wage bill, 1947-1987 (alternative ordering) ", size(medium) position(11)) ytitle("")  xtitle("")  yscale(noline) ///
	   ylabel(#8, noticks angle(horizontal)) legend(off) xlabel(1947(5)1987) xscale(r(1947 1990)) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white)) ysize(4) xsize(8)
graph export "${project}\figs\decomposition_wbill_1947_1987_sigma_${sigma}_order.eps", as(eps) preview(on) replace



