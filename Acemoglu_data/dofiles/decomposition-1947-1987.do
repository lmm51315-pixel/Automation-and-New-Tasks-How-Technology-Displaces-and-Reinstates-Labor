/*******************************************************************************
"Automation and New Tasks: How Technology Changes Labor Demand" 
by D. Acemoglu and P. Restrepo, JEP 2019

2.22.2019
Pascual Restrepo

This do file implements decomposition of the sources of the changes in labor demand
for the years 1947-1987 and produces:
 - Figure 3   - panel A and B
 - Figure A1  - panel A
 - Figure A2  - panel A
 - Figure A8  - panel A
 - Figure A9
 - Figure A10 

(revised by G. Marcolongo on 2.28.2019)
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


* * * * Generate macroeconomic aggregates:                          * * * * * *
* * * * GDP, Wage Bill, Labor Share, Real GDP pc, Real Wage Bill pc * * * * * *
sort indcode year

bys year: egen gdp_us=total(vadded_i) 		/*GDP in nominal terms*/

bys year: egen wbill_us=total(wages_i)		/*Wage bill in nominal terms*/

gen labsh_us=wbill_us/gdp_us				/*Labor share. Note this is smaller than headline BLS measure because it misses the self employed.
                                                           Self-employment declined from 14 percent in 1948 to 8.5 in 2012.
														   These changes in self-employment generate a larger decline in labor share. */

gen log_gdp_us=ln(gdp_us*price_us/population_us) 		/*GDP per capita in real terms using PCE index*/

gen log_wbill_us=ln(wbill_us*price_us/population_us)	/*Wage bill per capita in real terms using PCE index*/

* * * Generate measures for the observed change in wage bill and output * * * *
sort indcode year

bys indcode: gen cum_delta_wbill_us=100*(log_wbill_us-log_wbill_us[1]) 	/* Cumulative change in WAGE BILL */
assert cum_delta_wbill_us==0 if year==1947

bys indcode: gen cum_prod_effect_wbill=100*(log_gdp_us-log_gdp_us[1]) 	/* PRODUCTIVITY effect */
assert cum_prod_effect_wbill==0 if year==1947

* * * Sectoral shares and statistics                                    * * * * 
* * * Share of GDP, Labor share at time t and at intitial point (1987)  * * * *
sort indcode year

gen gdpsh_i=vadded_i/gdp_us  				/*Share GDP i: Contribution of sector i to GDP (chi_ i)*/

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

gen logW_i=ln(priceW_i)		/*Observed wages adjusted from composition, BEA*/

gen logR_i=ln(priceR_i)		/*Observed rental rates of capital, BEA */

gen ln_labsh_i=ln(labsh_i)  /*Observed decline in labor share, BEA  */

gen substitution_i=(1-${sigma})*(1-base_labsh)*(d.logW_i-d.logR_i-${growth_rate_1947_1987}) /*Formula for the substitution effect (see appendix - pag. A9)*/

gen task_content_i=d.ln_labsh_i-substitution_i                                             	/*Formula for changes in the task content (see appendix - pag. A9)*/

*Note: the last three measures need to be cummulated*

* * Different scenarios for A_L/A_K * *
gen task_content_p2=f.d.ln_labsh_i-(1-${sigma})*(1-base_labsh)*(f.d.logW_i-f.d.logR_i-0.02)

gen task_content_p1=f.d.ln_labsh_i-(1-${sigma})*(1-base_labsh)*(f.d.logW_i-f.d.logR_i-0.01)

gen task_content_zero=f.d.ln_labsh_i-(1-${sigma})*(1-base_labsh)*(f.d.logW_i-f.d.logR_i)

gen task_content_m1=f.d.ln_labsh_i-(1-${sigma})*(1-base_labsh)*(f.d.logW_i-f.d.logR_i+0.01)

gen task_content_m2=f.d.ln_labsh_i-(1-${sigma})*(1-base_labsh)*(f.d.logW_i-f.d.logR_i+0.02)

gen task_content_m3=f.d.ln_labsh_i-(1-${sigma})*(1-base_labsh)*(f.d.logW_i-f.d.logR_i+0.03)

gen task_content_m4=f.d.ln_labsh_i-(1-${sigma})*(1-base_labsh)*(f.d.logW_i-f.d.logR_i+0.04)

* * * Disentangle the DISPLACEMENT and REINSTATEMENT effect using 5 year moving averages * * *
sort indcode year

* Calculate mean of task content for each industry at 5 years MA centered at current year
* (Baseline: 5-year moving averages) 
rangestat (mean) task_content_*, interval(year -2 2) by(indcode)

*Industry element of the Displacement effect:
gen task_negative_5yr=min(task_content_i_mean,0)

*Industry element of the Reinstatement effect: 
gen task_positive_5yr=max(task_content_i_mean,0)

* Do the same for each possible scenario for A_L/A_K
foreach var in p2 p1 zero m1 m2 m3 m4{
gen task_negative_5yr_`var'=min(task_content_`var'_mean,0)
gen task_positive_5yr_`var'=max(task_content_`var'_mean,0)
}

*Appendix: Yearly changes*
gen task_negative=min(task_content_i,0)

gen task_positive=max(task_content_i,0)


* * * FACTUAL changes  in TFP required to explain DISPLACEMENT and * * * 
* * * REINSTATEMENT via factor-augmenting technologies					  * * *
if ${sigma}<1{

*Formulas provided in the appendix pag. A11*
gen counter_AL_tfp=(-task_negative_5yr_zero*base_labsh/((1-${sigma})*(1-base_labsh)))*base_gdpsh
gen counter_AK_tfp=(task_positive_5yr_zero/((1-${sigma})))*base_gdpsh

}
else if ${sigma}>1{

*Formulas provided in the appendix pag. A11*
gen counter_AK_tfp=(-task_negative_5yr_zero/(${sigma}-1))*base_gdpsh
gen counter_AL_tfp=(task_positive_5yr_zero*base_labsh/((${sigma}-1)*(1-base_labsh)))*base_gdpsh

}
else{

*When sigma=1, factor augmenting technologies cannot affect labor shares*
gen counter_AL_tfp=0
gen counter_AK_tfp=0
}

***Collapse by period to implement decomposition and calculate industry weights ***
sort indcode year
bys indcode: gen base_share=wages_i[1]/wbill_us[1] 			/*Weights used in published version: Weighting leaves composition of economy unchanged at its 1947 level. Exact decomposition except for approximations of log changes*/
bys indcode: gen lagged_share=wages_i[_n-1]/wbill_us[_n-1] 	/*Weights used in working-paper version: Use this weights to implement decomposition using rolling basis. Decomposition not exact in this case*/
collapse (mean) cum_* (sum) substitution_i task_content_* task_negative* task_positive* (rawsum) counter_*_tfp  [iw=base_share], by(year)

*Declare time series*
tsset year

*Cumulate variables since 1947 (substitution effect, task content of production, 
*displacement and reinstatement effect and counterfactual TFP changes)  * * * * *
foreach var of varlist substitution_i task_content_* task_negative* task_positive* counter_*_tfp{
gen cum_`var'=100*sum(`var')
replace cum_`var'=0 if year==1947
}


* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* * * * * * * * * * * * * *      GRAPHS      * * * * * * * * * * * * * * * * * *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

* * * Decomposition of the wage bill: productivity, composition, substitution *
* * * and change in task content effect for different values of Sigma * * * * *
* * * FIGURE 3 - Panel A: Sigma = 0.8 * * * * * * * * * * * * * * * * * * * * *
* * * FIGURE A9 - Panel A: Sigma = 0.6 * * * * * * * * * * * * * * * * * * * * *
* * * FIGURE A9 - Panel B: Sigma = 0.8 * * * * * * * * * * * * * * * * * * * * *
* * * FIGURE A9 - Panel C: Sigma = 1.0 * * * * * * * * * * * * * * * * * * * * *
* * * FIGURE A9 - Panel D: Sigma = 1.2 * * * * * * * * * * * * * * * * * * * * *

*manual labels to the right*
gen label_prod="Productivity effect" if year==1987
gen label_comp="Composition effect" if year==1987
gen label_subs="Substitution effect" if year==1987
gen label_task="Change in task content" if year==1987
gen label_task1="Change in task content" if year==1985
gen label_wbill="Observed wage bill" if year==1987

di $sigma
if $sigma == .8 {
	global mlabpos_1 mlabpos(3)
	global mlabpos_2 mlabpos(2)
	global label_task mlabel(label_task) mlabpos(4)
}

else if $sigma ==0.6 {
	global mlabpos_1 mlabposition(2)
	global mlabpos_2 mlabposition(1)
	global label_task mlabel(label_task) mlabposition(1)
}

else if $sigma == 1{
	global mlabpos_1 mlabposition(3)
	global mlabpos_2 mlabposition(5)
    global label_task mlabel(label_task1) mlabpos(1)
}

else if $sigma == 1.2{
	global mlabpos_1 mlabposition(3)
	global mlabpos_2 mlabposition(3)
    global label_task mlabel(label_task1) mlabpos(1)
}


*Plot decomposition: labor demand*
twoway (connected  cum_prod_effect_wbill year, $style_prod_effect mlabel(label_prod)) ///
	   (connected  cum_comp year, $style_comp_effect mlabel(label_comp) $mlabpos_1 ) ///
	   (connected  cum_substitution_i year, $style_price_subs mlabel(label_subs) $mlabpos_2 ) ///
       (connected  cum_task_content_i year, $style_task_content $label_task ) ///
	   (connected  cum_delta_wbill_us year, $style_observed mlabel(label_wbill)), ///
       title("Wage bill, 1947-1987 `title'  ", size(medium) position(11)) ytitle("")  xtitle("")  yscale(noline) ///
	   ylabel(, noticks angle(horizontal)) legend(off) xlabel(1947(5)1987) xscale(r(1947 1990)) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white)) ysize(4) xsize(8)
	   graph export "${project}\figs\decomposition_wbill_1947_1987_sigma_${sigma}`stub'.eps", as(eps) preview(on) replace


* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
* * Estimates of the reinstatement and displacement effects, * * * * * * * * * * 
* * yearly and five-year changes * * * * * * * * * * * * * * * * * * * * * * * 
* * * FIGURE A8 - Panel A  * * * * * * * * * * * * * * * * * * * * * * * * * * * 

*manual labels to the right*
gen label_pos="Reinstatement, yearly" if year==1987
gen label_pos5="Reinstatement" if year==1987
gen label_neg="Displacement, yearly" if year==1987
gen label_neg5="Displacement" if year==1987
gen label_manuf="Task content of production, manufacturing" if year==1987
gen label_task2="Change in task content" if year==1985

*Plot bounds on task content, bound version*
twoway (connected  cum_task_positive year, $style_reinstatement2 mlabel(label_pos)) ///
	   (connected  cum_task_positive_5yr year, $style_reinstatement mlabel(label_pos5)) ///
	   (connected  cum_task_negative year, $style_displacement2 mlabel(label_neg)) ///
	   (connected  cum_task_negative_5yr year, $style_displacement mlabel(label_neg5)) ///
	   (connected  cum_task_content_i year, $style_task_content mlabel(label_task2) mlabposition(1)), ///
	   title("Change in task content of production, 1947-1987 `title'  ", size(medium) position(11)) ytitle("")  xtitle("")  yscale(noline) ///
	   ylabel(-40(20)40, noticks angle(horizontal)) legend(off) xlabel(1947(5)1987) xscale(r(1947 1990)) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white)) ysize(4) xsize(8)
graph export "${project}\figs\taskcontent_1947_1987_sigma_${sigma}`stub'.eps", as(eps) preview(on) replace


* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
* * Displacement and Reinstatement effect for the entire economy 1947 - 1987. *
* * FIGURE 3 - Panel B: Sigma = 0.8 * * * * * * * * * * * * * * * * * * * * * * 
* * FIGURE A10 - Panel A: Sigma = 0.6 * * * * * * * * * * * * * * * * * * * * * * 
* * FIGURE A10 - Panel B: Sigma = 0.8 * * * * * * * * * * * * * * * * * * * * * * 
* * FIGURE A10 - Panel C: Sigma = 1.0 * * * * * * * * * * * * * * * * * * * * * * 
* * FIGURE A10 - Panel D: Sigma = 1.2 * * * * * * * * * * * * * * * * * * * * * * 

*manual labels to the right*
gen label_reinstatement="Reinstatement" if year==1987
gen label_displacement="Displacement" if year==1987

*Plot bounds on task content, version*
twoway (connected  cum_task_positive_5yr year, $style_reinstatement mlabel(label_reinstatement)) ///
	   (connected  cum_task_negative_5yr year, $style_displacement mlabel(label_displacement)) ///
	   (connected  cum_task_content_i year, $style_task_content mlabel(label_task2) mlabpos(1)), ///
	   title("Change in task content of production, 1947-1987 `title'  ", size(medium) position(11)) ytitle("")  xtitle("")  yscale(noline) ///
	   ylabel(-20(10)20, noticks angle(horizontal)) legend(off) xlabel(1947(5)1987) xscale(r(1947 1990)) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white)) ysize(4) xsize(8)
graph export "${project}\figs\taskcontent_1947_1987_sigma_${sigma}_estimates`stub'.eps", as(eps) preview(on) replace

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
* * Counterfactual TFP changes that would be implied if the estimates of  * * * 
* * the displacement and reinstatement effect wer accounted for by        * * *
* * industry-level changes in labor-augmenting technological changes alone. * * 
* * FIGURE A1 - Panel A: Counterfactual TFP changes, 1947 - 1987          * * *

*Manual labels*
gen scenario_p2="A{superscript:L}/A{superscript:K} grows at a rate of 3%" if year==1987
gen scenario_p3="A{superscript:L}/A{superscript:K} grows at a rate of 3%" if year==1986
gen scenario_zero="A{superscript:L}/A{superscript:K} grows at a rate of 1%" if year==1987

if $sigma == 0.8 {
	global mlabpos_1 mlabpos(5) 
	global mlabpos_2 mlabpos(1)
	global mlabpos_3 mlabpos(3)
	
	global mlabpos_4 mlabpos(1)
	global mlabpos_5 mlabpos(2)
	global mlabpos_6 mlabpos(3)
		
	global mlabpos_7 mlabpos(1)
	global mlabpos_8 mlabpos(3)
	global mlabpos_9 mlabpos(4)
}
else if $sigma == 0.6 {
	global mlabpos_1 mlabpos(5)
	global mlabpos_2 mlabpos(2)
	global mlabpos_3 mlabpos(3)
	
	global mlabpos_4 mlabpos(2)
	global mlabpos_5 mlabpos(3)
	global mlabpos_6 mlabpos(3)
	
	global mlabpos_7 mlabpos(1)
	global mlabpos_8 mlabpos(4)
	global mlabpos_9 mlabpos(4)
}
else if $sigma == 1.0 {
	global mlabpos_1 mlabpos(1)
	global mlabpos_2 mlabpos(3)
	global mlabpos_3 mlabpos(6) 
	
	global mlabpos_4 mlabpos(1)
	global mlabpos_5 mlabpos(2)
	global mlabpos_6 mlabpos(4)
	
	global mlabpos_7 mlabpos(1)
	global mlabpos_8 mlabpos(3)
	global mlabpos_9 mlabpos(5)
		
}


*Change in task content for different values of growth rate of A_L/A_K*
twoway (connected  cum_task_content_p2 year, $style_task_content msymbol(none) lpattern(dash_dot) lwidth(thin) msize(vsmall) connect(direct) mlabel(scenario_p2) $mlabpos_1) ///
	   (connected  cum_task_content_i  year,  $style_task_content msymbol(diamond) lpattern(tight_dot) lwidth(thin) msize(vsmall) connect(direct) mlabel(label_task) $mlabpos_2) ///
	   (connected  cum_task_content_p1 year, $style_task_content msymbol(none) lpattern(dash_dot) lwidth(thin) msize(vsmall) connect(direct) mlabel(scenario_zero) $mlabpos_3) ///
	   (connected  cum_task_negative_5yr_p2 year, $style_displacement msymbol(none) lpattern(tight_dot) lwidth(thin) msize(vsmall) connect(direct) mlabel(scenario_p3) $mlabpos_4) ///
	   (connected  cum_task_negative_5yr    year, $style_displacement msymbol(triangle) lpattern(tight_dot) lwidth(thin) msize(vsmall) connect(direct) mlabel(label_neg5) $mlabpos_5) ///
	   (connected  cum_task_negative_5yr_p1 year, $style_displacement msymbol(none) lpattern(tight_dot) lwidth(thin) msize(vsmall) connect(direct) mlabel(scenario_zero) $mlabpos_6) ///
	   (connected  cum_task_positive_5yr_p2 year, $style_reinstatement msymbol(none) lpattern(tight_dot) lwidth(thin) msize(vsmall) connect(direct) mlabel(scenario_p2) $mlabpos_7) ///
	   (connected  cum_task_positive_5yr    year, $style_reinstatement msymbol(circle) lpattern(tight_dot) lwidth(thin) msize(vsmall) connect(direct) mlabel(label_pos5) $mlabpos_8) ///   
	   (connected  cum_task_positive_5yr_p1 year, $style_reinstatement msymbol(none) lpattern(tight_dot) lwidth(thin) msize(vsmall) connect(direct) mlabel(scenario_zero) $mlabpos_9), ///
	   title("Change in task content of production, 1947-1987 `title'  ", size(medium) position(11)) ytitle("")  xtitle("")  yscale(noline) ///
	   ylabel(, noticks angle(horizontal)) legend(off) xlabel(1947(5)1987) xscale(r(1947 1990)) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white)) ysize(4) xsize(8)
graph export "${project}\figs\scenarios_factaugm_1947_1987_sigma_${sigma}`stub'.eps", as(eps) preview(on) replace

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
* * Counterfactual TFP changes that would be implied if the estimates of  * * * 
* * the displacement and reinstatement effect were accounted for by        * * * 
* * industry-level changes in labor-augmenting technological changes alone. * * 
* * FIGURE A2 - Panel A: Counterfactual TFP changes, 1947 - 1987		  * * * 

if ${sigma}<1{	   

merge 1:1 year using "${project}/raw_data/aggregates/tfp.dta", keep(3) nogenerate
sort year
gen cum_tfp=100*(ln(tfp_us)-ln(tfp_us[1]))

*Labels*
gen label_AL="Contribution of AL" if year==1987
gen label_AK="Contribution of AK" if year==1987
gen label_tfp="Observed TFP" if year==1987

*Plot implied TFP behavior*
twoway (connected cum_counter_AL_tfp year, $style_displacement mlabel(label_AL)) ///
       (connected cum_counter_AK_tfp year, $style_reinstatement mlabel(label_AK)) ///
	   (connected cum_tfp year, $style_observed mlabel(label_tfp)), ///
	   title("Implied TFP growth, 1947-1987 `title'  ", size(medium) position(11)) ytitle("")  xtitle("")  yscale(noline) ///
	   ylabel(, noticks angle(horizontal)) legend(off) xlabel(1947(5)1987) xscale(r(1947 1990)) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white)) ysize(4) xsize(8)
graph export "${project}\figs\counter_tfp_1947_1987_sigma_${sigma}`stub'.eps", as(eps) preview(on) replace

}
else if ${sigma}>1{

merge 1:1 year using "${project}/raw_data/aggregates/tfp.dta", keep(3) nogenerate
sort year
gen cum_tfp=100*(ln(tfp_us)-ln(tfp_us[1]))	   

*Labels*
gen label_AL="Contribution of AL" if year==1987
gen label_AK="Contribution of AK" if year==1987
gen label_tfp="Observed TFP" if year==1987

*Plot implied TFP behavior*
twoway (connected cum_counter_AL_tfp year, $style_reinstatement mlabel(label_AL)) ///
       (connected cum_counter_AK_tfp year, $style_displacement mlabel(label_AK)) ///
	   (connected cum_tfp year, $style_observed mlabel(label_tfp)), ///
	   title("Implied TFP growth, 1947-1987 `title'  ", size(medium) position(11)) ytitle("")  xtitle("")  yscale(noline) ///
	   ylabel(, noticks angle(horizontal)) legend(off) xlabel(1947(5)1987) xscale(r(1947 1990)) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white)) ysize(4) xsize(8)
graph export "${project}\figs\counter_tfp_1947_1987_sigma_${sigma}`stub'.eps", as(eps) preview(on) replace

}



* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
* GRADUAL DECOMPOSITION 1947 - 1987 *
* shows decomposition of labor demand on separate graph gradually adding different
* effects: Wage Bill --> Productivity Effect --> Composition Effect -- > 
* Substition Effect --> Change in Task content of productoin

if $appendix==0{

***Present basic decompositions for employment, wages and wage bill***

******************** WAGE BILL ***************************
gen lw="Observed wage bill" if year==1987
*Plot decomposition: labor demand*
twoway (connected  cum_delta_wbill_us year, color(gs4) mlabcolor(gs4) msymbol(triangle) lpattern(solid) lwidth(thin) msize(vsmall) connect(direct) mlabel(lw)), ///
       title("Wage bill, 1947-1987 `title' ", size(medium) position(11)) ytitle("")  xtitle("")  yscale(noline) ///
	   ylabel(0(10)100, noticks angle(horizontal)) legend(off) xlabel(1947(5)1987) xscale(r(1947 1990)) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white)) ysize(4) xsize(8)
graph export "${project}\figs\decA_full1947_1987_sigma_${sigma}_estimates`stub'.eps", as(eps) preview(on) replace
   
   
******************** PRODUCTIVITY EFFECT ***************************      
gen l1="Productivity effect" if year==1987	
gen y1=cum_prod_effect_wbill
twoway (connected  y1 year, color(edkblue) mlabcolor(edkblue) msymbol(diamond_hollow) lpattern(tight_dot) lwidth(thin) msize(small) connect(direct) mlabel(l1)) ///
	   (connected  cum_delta_wbill_us year, color(gs4) mlabcolor(gs4) msymbol(triangle) lpattern(solid) lwidth(thin) msize(vsmall) connect(direct) mlabel(label_wbill)), ///
       title("Wage bill, 1947-1987 `title' ", size(medium) position(11)) ytitle("")  xtitle("")  yscale(noline) ///
	   ylabel(0(10)100, noticks angle(horizontal)) legend(off) xlabel(1947(5)1987) xscale(r(1947 1990)) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white)) ysize(4) xsize(8)
graph export "${project}\figs\decB_full1947_1987_sigma_${sigma}_estimates`stub'.eps", as(eps) preview(on) replace
	   
	   
******************** COMPOSITION EFFECT ***************************   	   	   
gen l2="+Composition effect" if year==1987	   
gen y2=y1+cum_comp
twoway (connected  y1 year, color(gs12) msymbol(circle) lpattern(tight_dot) lwidth(thin) msize(vsmall) connect(direct)) ///
	   (connected  y2 year, color(edkblue) mlabcolor(edkblue) msymbol(diamond_hollow) lpattern(tight_dot) lwidth(thin) msize(small) connect(direct) mlabel(l2)) ///
	   (connected  cum_delta_wbill_us year, color(gs4) mlabcolor(gs4) msymbol(triangle) lpattern(solid) lwidth(thin) msize(vsmall) connect(direct) mlabel(label_wbill)), ///
       title("Wage bill, 1947-1987 `title' ", size(medium) position(11)) ytitle("")  xtitle("")  yscale(noline) ///
	   ylabel(0(10)100, noticks angle(horizontal)) legend(off) xlabel(1947(5)1987) xscale(r(1947 1990)) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white)) ysize(4) xsize(8)
graph export "${project}\figs\decC_full1947_1987_sigma_${sigma}_estimates`stub'.eps", as(eps) preview(on) replace


******************** SUBSTITUTION EFFECT ***************************   	     	   
gen l3="+Price substitution" if year==1987	   
gen y3=y2+cum_substitution_i
twoway (connected  y1 year, color(gs12) msymbol(circle) lpattern(tight_dot) lwidth(thin) msize(vsmall) connect(direct)) ///
	   (connected  y2 year, color(gs12) msymbol(circle) lpattern(tight_dot) lwidth(thin) msize(vsmall) connect(direct) ) ///
	   (connected  y3 year, color(edkblue) mlabcolor(edkblue) msymbol(diamond_hollow) lpattern(tight_dot) lwidth(thin) msize(small) connect(direct) mlabel(l3) mlabpos(3)) ///
	   (connected  cum_delta_wbill_us year, color(gs4) mlabcolor(gs4) msymbol(triangle) lpattern(solid) lwidth(thin) msize(vsmall) connect(direct) mlabel(label_wbill) mlabpos(1)), ///
       title("Wage bill, 1947-1987 `title' ", size(medium) position(11)) ytitle("")  xtitle("")  yscale(noline) ///
	   ylabel(0(10)100, noticks angle(horizontal)) legend(off) xlabel(1947(5)1987) xscale(r(1947 1990)) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white)) ysize(4) xsize(8)
graph export "${project}\figs\decD_full1947_1987_sigma_${sigma}_estimates`stub'.eps", as(eps) preview(on) replace


******************** CHANGE TASK CONTENT OF PRODUCTION ***************************   	     
gen l4="+Change task content of production" if year==1987	   
gen y4=y3+cum_task_content_i
twoway (connected  y1 year, color(gs12) msymbol(circle) lpattern(tight_dot) lwidth(thin) msize(vsmall) connect(direct)) ///
	   (connected  y2 year, color(gs12) msymbol(circle) lpattern(tight_dot) lwidth(thin) msize(vsmall) connect(direct) ) ///
	   (connected  y3 year, color(edkblue) mlabcolor(edkblue) msymbol(diamond_hollow) lpattern(tight_dot) lwidth(thin) msize(vsmall) connect(direct)) ///
	   (connected  y4 year, color(cranberry) mlabcolor(cranberry) msymbol(diamond) lpattern(tight_dot) lwidth(thin) msize(small) connect(direct) mlabel(l4)) ///
	   (connected  cum_delta_wbill_us year, color(gs4) mlabcolor(gs4) msymbol(triangle) lpattern(solid) lwidth(thin) msize(vsmall) connect(direct) mlabel(label_wbill) mlabpos(1)), ///
       title("Wage bill, 1947-1987 `title' ", size(medium) position(11)) ytitle("")  xtitle("")  yscale(noline) ///
	   ylabel(0(10)100, noticks angle(horizontal)) legend(off) xlabel(1947(5)1987) xscale(r(1947 1990)) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white)) ysize(4) xsize(8)
graph export "${project}\figs\decE_full1947_1987_sigma_${sigma}_estimates`stub'.eps", as(eps) preview(on) replace
}	   	   	   
	
	


