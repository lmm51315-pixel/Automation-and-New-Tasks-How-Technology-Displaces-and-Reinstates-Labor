/*******************************************************************************
"Automation and New Tasks: How Technology Changes Labor Demand" 
by D. Acemoglu and P. Restrepo, JEP 2019

2.22.2019
Pascual Restrepo


This do file implements decomposition of the sources of the changes in labor demand
for the years 1987-2017 and produces:
 - Figure 5 in the Main Text
 - Figure A1  - panel B
 - Figure A8  - panel B
 - Figure A2  - panel B
 - Figure A12 
 - Figure A13 
 
 creates the industry_contribution_sigma0.8.dta 
 
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
use "${project}/clean_data/panel_beaNAICS.dta", clear
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
gen vadded_i=bea_vadded
gen wages_i=bea_comp
gen priceR_i=bls_R_full
gen priceW_i=bls_W_adj

* * * * Generate macroeconomic aggregates:                          * * * * * *
* * * * GDP, Wage Bill, Labor Share, Real GDP pc, Real Wage Bill pc * * * * * *

sort indcode year

bys year: egen gdp_us=total(vadded_i) 					/*GDP in nominal terms */

bys year: egen wbill_us=total(wages_i)					/*Wage bill in nominal terms*/

gen labsh_us=wbill_us/gdp_us							/*Labor share. Note this is smaller than headline BLS measure because it misses the self employed.
                                                           Self-employment declined from 14 percent in 1948 to 8.5 in 2012.
														   These changes in self-employment generate a larger decline in labor share. (s_L)*/

gen log_gdp_us=ln(gdp_us*price_us/population_us) 		/*GDP per capita in real terms using PCE index*/

gen log_wbill_us=ln(wbill_us*price_us/population_us)	/*Wage bill per capita in real terms using PCE index*/


* * * Generate measures for the observed change in wage bill and output * * * *
sort indcode year

bys indcode: gen cum_delta_wbill_us=100*(log_wbill_us-log_wbill_us[1])  /* Cumulative change in WAGE BILL */
assert cum_delta_wbill_us==0 if year==1987

bys indcode: gen cum_prod_effect_wbill=100*(log_gdp_us-log_gdp_us[1])   /* PRODUCTIVITY effect */
assert cum_prod_effect_wbill==0 if year==1987


* * * Sectoral shares and statistics                                    * * * * 
* * * Share of GDP, Labor share at time t and at intitial point (1987)  * * * *
sort indcode year

gen gdpsh_i=vadded_i/gdp_us  				/*Share GDP i: Contribution of sector i to GDP (chi_ i)*/

gen labsh_i=wages_i/vadded_i 				/*Labor share i: Contribution of labor to value added in sector i (s_i)*/

bys indcode: gen base_gdpsh=gdpsh_i[1] 		/*Initial share GDP in industry i (chi_i in 1987)*/
assert base_gdpsh==gdpsh_i if year==1987

bys indcode: gen base_labsh=labsh_i[1]		/*Initial labor share in industry i (s_i in 1987) */
assert base_labsh==labsh_i if year==1987

* * * Measure the contribution of the COMPOSITION EFFECT                 * * * *
* * * (see the appendix for the derivations, pagg. A6 - A7)				 * * * *

sort indcode year

bys year: egen  comp_actual_1=total(gdpsh_i*labsh_i)    		/*Actual contribution from observed sectoral contribution given the labor intensity of sectors*/

bys year: egen comp_counter_1=total(base_gdpsh*labsh_i)			/*Counterfactual leaving sectoral contribution unchanged at its baseline level*/

gen cum_composition=100*(ln(comp_actual_1)-ln(comp_counter_1))	/*Contribution of compositional shifts*/

* * * Measure the contribution of changes in TASK CONTENT of production  		* * * *
* * *  and SUBSTITUTION effects (see the appendix for derivations, pagg. A8-A10) * * * *
sort indcode year

gen logW_i=ln(priceW_i)		/*Observed wages adjusted from composition, BLS (ln_W_i)*/ 

gen logR_i=ln(priceR_i)		/*Observed rental rates of capital, BLS (ln_R_i)*/

gen ln_labsh_i=ln(labsh_i)  /*Observed decline in labor share, BEA */

gen substitution_i=(1-${sigma})*(1-base_labsh)*(d.logW_i-d.logR_i-${growth_rate_1987_2017}) /*Formula for the substitution effect (see appendix - pag. A9)*/

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

* * * COUNTERFACTUAL changes  in TFP required to explain DISPLACEMENT and * * * 
* * * REINSTATEMENT via factor-augmenting technologies					  * * *
**Counterfactual changes in TFP required to explain displacement and reinstatement via factor-augmenting technologies**

if ${sigma}<1{

 
*Formulas provided in the appendix pag. A11*
	gen counter_AL_tfp=(-task_negative_5yr_zero*base_labsh/((1-${sigma})*(1-base_labsh)))*base_gdpsh
	gen counter_AK_tfp=(task_positive_5yr_zero/(1-${sigma}))*base_gdpsh
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


*** Export dataset on contribution by industry for this period    ***
*** (note: this is only saved for the entire economy in 1987-2017)***
if $appendix==0{
preserve
gen indwts=wages_i/wbill_us /*Use share of wage bill as weights for industry analysis (l_i)*/
collapse (firstnm) industry_ifr (sum) task_negative_5yr task_positive_5yr task_content_i (mean) manuf indwts, by(industry_bea)
save "${project}/clean_data/industry_contribution_sigma_${sigma}.dta", replace
restore
}

***Collapse by period to implement decomposition and calculate industry weights ***
sort indcode year
bys indcode: gen base_share=wages_i[1]/wbill_us[1] 			/*Weights used in published version: Weighting leaves composition of economy unchanged at its 1987 level. Exact decomposition except for approximations of log changes*/
bys indcode: gen lagged_share=wages_i[_n-1]/wbill_us[_n-1] 	/*Weights used in working-paper version: Use this weights to implement decomposition using rolling basis. Decomposition not exact in this case*/
collapse (mean) cum_* (sum) substitution_i task_content_* task_negative* task_positive* (rawsum) counter_*_tfp  [iw=base_share], by(year)
 

*Declare time series*
tsset year 

*Cumulate variables since 1987 (substitution effect, task content of production, 
*displacement and reinstatement effect and counterfactual TFP changes) * * * * *
foreach var of varlist substitution_i task_content_* task_negative* task_positive* counter_*_tfp{
gen cum_`var'=100*sum(`var')
replace cum_`var'=0 if year==1987
}


* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* * * * * * * * * * * * * *      GRAPHS      * * * * * * * * * * * * * * * * * *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

* * * * * * Sources of changes in Labor Demand, 1987 - 2017 * * * * * * * * * *
*** Decomposition of the wage bill: 
*** productivity, composition, substitution and change in task content effect 
* * * FIGURE 5 - Panel A: Sigma = 0.8 * * * * * * * * * * * * * * * * * * * * * 
* * * FIGURE A12 - Panel A: Sigma = 0.6 * * * * * * * * * * * * * * * * * * * * 
* * * FIGURE A12 - Panel B: Sigma = 0.8 * * * * * * * * * * * * * * * * * * * * 
* * * FIGURE A12 - Panel C: Sigma = 1   * * * * * * * * * * * * * * * * * * * * 
* * * FIGURE A12 - Panel D: Sigma = 1.2  * * * * * * * * * * * * * * * * * * * *

*manual labels to the right of the graphed line*
gen label_prod="Productivity effect" if year==2016
gen label_comp="Composition effect" if year==2016
gen label_subs="Substitution effect" if year==2016
gen label_task="Change in task content" if year==2016
gen label_task1 = "Change in task content" if year == 2014
gen label_wbill="Observed wage bill" if year==2016

*manual labels on task content depending on the value of sigma (so they don't overlap the graph)
if $sigma <1{
	global label_task mlabel(label_task) mlabposition(12)
}

else if $sigma >=1{
	global label_task mlabel(label_task1) mlabposition(1)
}


*Plot decomposition: labor demand*
twoway (connected  cum_prod_effect_wbill year, $style_prod_effect mlabel(label_prod)) ///
	   (connected  cum_comp year, $style_comp_effect mlabel(label_comp)) ///
	   (connected  cum_substitution_i year, $style_price_subs mlabel(label_subs)) ///
       (connected  cum_task_content_i year, $style_task_content $label_task) ///
	   (connected  cum_delta_wbill_us year, $style_observed mlabel(label_wbill)), ///
       title("Wage bill, 1987-2017 `title' ", size(medium) position(11)) ytitle("")  xtitle("")  yscale(noline) ///
	   ylabel(-10(10)40, noticks angle(horizontal)) legend(off) xlabel(1987(5)2017) xscale(r(1987 2020)) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white)) ysize(4) xsize(8)
graph export "${project}\figs\decomposition_wbill_1987_2017_sigma_${sigma}`stub'.eps", as(eps) preview(on) replace


* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
* * Estimates of the reinstatement and displacement effects, 
* * yearly and five-year changes * * * * * * * * * * * * * * * * * * * * * * * *
* * * FIGURE A8 - Panel B: Sigma = 0.8 * * * * * * * * * * * * * * * * * * * * * 

*manual labels to the right*
gen label_pos="Reinstatement, yearly" if year==2016
gen label_pos5="Reinstatement" if year==2016
gen label_neg="Displacement, yearly" if year==2016
gen label_neg5="Displacement" if year==2016

*** Plot bounds on task content, bound version including yearly changes *
twoway (connected  cum_task_positive year, $style_reinstatement2 mlabel(label_pos)) ///
	   (connected  cum_task_positive_5yr year, $style_reinstatement mlabel(label_pos5)) ///
	   (connected  cum_task_negative year, $style_displacement2 mlabel(label_neg)) ///
	   (connected  cum_task_negative_5yr year, $style_displacement mlabel(label_neg5)) ///
	   (connected  cum_task_content_i year, $style_task_content $label_task), ///
	   title("Change in task content of production, 1987-2017 `title' ", size(medium) position(11)) ytitle("")  xtitle("")  yscale(noline) ///
	   ylabel(#8, noticks angle(horizontal)) legend(off) xlabel(1987(5)2017) xscale(r(1987 2020)) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white)) ysize(4) xsize(8)
graph export "${project}\figs\taskcontent_1987_2017_sigma_${sigma}`stub'.eps", as(eps) preview(on) replace


* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
* * Displacement and Reinstatement effect for the entire economy 1987 - 2017. *
* * FIGURE 5 - Panel B: Sigma = 0.8  * * * * * * * * * * * * * * * * * * * * * *
* * FIGURE A13 - Panel A: Sigma = 0.6 * * * * * * * * * * * * * * * * * * * * * 
* * FIGURE A13 - Panel B: Sigma = 0.8 * * * * * * * * * * * * * * * * * * * * * 
* * FIGURE A13 - Panel C: Sigma = 1   * * * * * * * * * * * * * * * * * * * * * 
* * FIGURE A13 - Panel D: Sigma = 1.2 * * * * * * * * * * * * * * * * * * * * * 

*manual labels to the right*
gen label_reinstatement="Reinstatement" if year==2016
gen label_displacement="Displacement" if year==2016
gen label_task2 = "Change in task content" if year == 2013


if $sigma <1{
	global malbpos mlabposition(5)
}

else if $sigma >=1{
	global malbpos mlabposition(1)
}


*Plot bounds on task content of production, version*
twoway (connected  cum_task_positive_5yr year, $style_reinstatement mlabel(label_reinstatement)) ///
	   (connected  cum_task_negative_5yr year, $style_displacement  mlabel(label_displacement)) ///
	   (connected  cum_task_content_i year, $style_task_content mlabel(label_task2) mlabpos(4)), ///
	   title("Change in task content of production, 1987-2017 `title' ", size(medium) position(11)) ytitle("")  xtitle("")  yscale(noline) ///
	   ylabel(-20(5)10, noticks angle(horizontal)) legend(off) xlabel(1987(5)2017) xscale(r(1987 2020)) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white)) ysize(4) xsize(8)
graph export "${project}\figs\taskcontent_1987_2017_sigma_${sigma}_estimates`stub'.eps", as(eps) preview(on) replace


* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
* * Estimates of the displacement and reinstatement * * * * * * * * * * * * * * 
* * effect for different assumed growth rates for A_L/A_K  * * * * * * * * * * *
* * FIGURE A1 - Panel B: sigma = 0.8 * * * * * * * * * * * * * * * * * * * * * *

*Manual labels*
*gen scenario_p2="A{superscript:L}/A{superscript:K} grows at  a rate of 2%" if year==2016
gen scenario_zero="A{superscript:L}/A{superscript:K} constant" if year==2016
gen label_task3 = "Change in task content" if year == 2012

* Manual label position
if $sigma <1{
	gen scenario_p2="A{superscript:L}/A{superscript:K} grows at a rate of 2%" if year==2016
	global mlabpos_1 mlabpos(2)
	global mlabpos_2 mlabpos(2)
	global mlabpos_3 mlabpos(3)
	global mlabpos_4 mlabpos(2)
	global mlabpos_5 mlabpos(4)
	global label_task mlabel(label_task)
	
}

else if $sigma ==1{
	gen scenario_p2="A{superscript:L}/A{superscript:K} grows at a rate of 2%" if year==2013
	global mlabpos_1 mlabpos(6)
	global mlabpos_2 mlabpos(8)
	global mlabpos_3 mlabpos(2)
	global mlabpos_4 mlabpos(4)
	global mlabpos_5 mlabpos(1)
	global label_task mlabel(label_task3) mlabpos(1)
	}


else if $sigma ==1.2{
	gen scenario_p2="A{superscript:L}/A{superscript:K} grows at a rate of 2%" if year==2012
	global mlabpos_1 mlabpos(5)
	global mlabpos_2 mlabpos(8)
	global mlabpos_3 mlabpos(2)
	global mlabpos_4 mlabpos(4)
	global mlabpos_5 mlabpos(3)
	global label_task mlabel(label_task3) mlabpos(2)
	}

*Change in task content of production for different values of growth rate of A_L/A_K*
twoway (connected  cum_task_content_p2 year, $style_task_content msymbol(none) lpattern(dash_dot) lwidth(thin) msize(vsmall) connect(direct) mlabel(scenario_p2) $mlabpos_1 ) ///
	   (connected  cum_task_content_i  year,  $style_task_content msymbol(diamond) lpattern(tight_dot) lwidth(thin) msize(vsmall) connect(direct) $label_task) ///
	   (connected  cum_task_content_zero year, $style_task_content msymbol(none) lpattern(dash_dot) lwidth(thin) msize(vsmall) connect(direct) mlabel(scenario_zero)) ///
	   (connected  cum_task_negative_5yr_p2 year, $style_displacement msymbol(none) lpattern(tight_dot) lwidth(thin) msize(vsmall) connect(direct) mlabel(scenario_p2)  $mlabpos_2 ) ///
	   (connected  cum_task_negative_5yr    year, $style_displacement msymbol(triangle) lpattern(tight_dot) lwidth(thin) msize(vsmall) connect(direct) mlabel(label_neg5)) ///
	   (connected  cum_task_negative_5yr_zero year, $style_displacement msymbol(none) lpattern(tight_dot) lwidth(thin) msize(vsmall) connect(direct) mlabel(scenario_zero) $mlabpos_3) ///
	   (connected  cum_task_positive_5yr_p2 year, $style_reinstatement msymbol(none) lpattern(tight_dot) lwidth(thin) msize(vsmall) connect(direct) mlabel(scenario_p2)  $mlabpos_4) ///
	   (connected  cum_task_positive_5yr    year, $style_reinstatement msymbol(circle) lpattern(tight_dot) lwidth(thin) msize(vsmall) connect(direct) mlabel(label_pos5)) ///   
	   (connected  cum_task_positive_5yr_zero year, $style_reinstatement msymbol(none) lpattern(tight_dot) lwidth(thin) msize(vsmall) connect(direct) mlabel(scenario_zero)  $mlabpos_5), ///
	   title("Change in task content of production, 1987-2017 `title' ", size(medium) position(11)) ytitle("")  xtitle("")  yscale(noline) ///
	   ylabel(-20(5)15, noticks angle(horizontal)) legend(off) xlabel(1987(5)2017) xscale(r(1987 2020)) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white)) ysize(4) xsize(8)
graph export "${project}\figs\scenarios_factaugm_1987_2017_sigma_${sigma}`stub'.eps", as(eps) preview(on) replace

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
* * FIGURE A2 - Panel B: Counterfactual TFP changes, 1987 - 2017
* * Counterfactual TFP changes that would be implied if the estimates of 
* * the displacement and reinstatement effect wer accounted for by 
* * industry-level changes in labor-augmenting technological changes alone.

if ${sigma}<1{

merge 1:1 year using "${project}/raw_data/aggregates/tfp.dta", keep(3) nogenerate
sort year
gen cum_tfp=100*(ln(tfp_us)-ln(tfp_us[1]))

*Labels*
gen label_AL="Contribution of AL" if year==2016
gen label_AK="Contribution of AK" if year==2016
gen label_tfp="Observed TFP" if year==2016


twoway (connected cum_counter_AL_tfp year, $style_displacement mlabel(label_AL)) ///
       (connected cum_counter_AK_tfp year, $style_reinstatement mlabel(label_AK)) ///
	   (connected cum_tfp year, $style_observed mlabel(label_tfp) mlabpos(4)), ///
	   title("Implied TFP growth, 1987-2017 `title' ", size(medium) position(11)) ytitle("")  xtitle("")  yscale(noline) ///
	   ylabel(, noticks angle(horizontal)) legend(off) xlabel(1987(5)2017) xscale(r(1987 2020)) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white)) ysize(4) xsize(8)
graph export "${project}\figs\counter_tfp_1987_2017_sigma_${sigma}`stub'.eps", as(eps) preview(on) replace

}

else if ${sigma}>1{	 

merge 1:1 year using "${project}/raw_data/aggregates/tfp.dta", keep(3) nogenerate
sort year
gen cum_tfp=100*(ln(tfp_us)-ln(tfp_us[1]))

*Labels*
gen label_AL="Contribution of AL" if year==2016
gen label_AK="Contribution of AK" if year==2016
gen label_tfp="Observed TFP" if year==2016

*Plot implied TFP behavior*
twoway (connected cum_counter_AL_tfp year, $style_reinstatement mlabel(label_AL)) ///
       (connected cum_counter_AK_tfp year, $style_displacement mlabel(label_AK)) ///
	   (connected cum_tfp year, $style_observed mlabel(label_tfp)), ///
	   title("Implied TFP growth, 1987-2017 `title' ", size(medium) position(11)) ytitle("")  xtitle("")  yscale(noline) ///
	   ylabel(, noticks angle(horizontal)) legend(off) xlabel(1987(5)2017) xscale(r(1987 2020)) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white)) ysize(4) xsize(8)
graph export "${project}\figs\counter_tfp_1987_2017_sigma_${sigma}`stub'.eps", as(eps) preview(on) replace

}

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
* GRADUAL DECOMPOSITION 1987- 2017 *
* shows decomposition of labor demand on separate graph gradually adding different
* effects: Wage Bill --> Productivity Effect --> Composition Effect -- > 
* Substition Effect --> Change in Task content of productoin

if $appendix==0{
***Present basic decompositions for employment, wages and wage bill***

******************** WAGE BILL ***************************
gen lw="Observed wage bill" if year==2016
*Plot decomposition: labor demand*
twoway (connected  cum_delta_wbill_us year, color(gs4) mlabcolor(gs4) msymbol(triangle) lpattern(solid) lwidth(thin) msize(vsmall) connect(direct) mlabel(lw)), ///
       title("Wage bill, 1987-2017 `title' ", size(medium) position(11)) ytitle("")  xtitle("")  yscale(noline) ///
	   ylabel(0(10)50, noticks angle(horizontal)) legend(off) xlabel(1987(5)2017) xscale(r(1987 2020)) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white)) ysize(4) xsize(8)
graph export "${project}\figs\decA_full1987_2017_sigma_${sigma}_estimates`stub'.eps", as(eps) preview(on) replace


******************** PRODUCTIVITY EFFECT ***************************   
gen l1="Productivity effect" if year==2016	
gen y1=cum_prod_effect_wbill
twoway (connected  y1 year, color(edkblue) mlabcolor(edkblue) msymbol(diamond_hollow) lpattern(tight_dot) lwidth(thin) msize(small) connect(direct) mlabel(l1)) ///
	   (connected  cum_delta_wbill_us year, color(gs4) mlabcolor(gs4) msymbol(triangle) lpattern(solid) lwidth(thin) msize(vsmall) connect(direct) mlabel(label_wbill)), ///
       title("Wage bill, 1987-2017 `title' ", size(medium) position(11)) ytitle("")  xtitle("")  yscale(noline) ///
	   ylabel(0(10)50, noticks angle(horizontal)) legend(off) xlabel(1987(5)2017) xscale(r(1987 2020)) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white)) ysize(4) xsize(8)
graph export "${project}\figs\decB_full1987_2017_sigma_${sigma}_estimates`stub'.eps", as(eps) preview(on) replace


******************** COMPOSITION EFFECT ***************************   	   
gen l2="+Composition effect" if year==2016	   
gen y2=y1+cum_comp
twoway (connected  y1 year, color(gs12) msymbol(circle) lpattern(tight_dot) lwidth(thin) msize(vsmall) connect(direct) mlabel(l1) mlabcolor(gs12)) ///
	   (connected  y2 year, color(edkblue) mlabcolor(edkblue) msymbol(diamond_hollow) lpattern(tight_dot) lwidth(thin) msize(small) connect(direct) mlabel(l2) mlabcolor(edkblue)) ///
	   (connected  cum_delta_wbill_us year, color(gs4) mlabcolor(gs4) msymbol(triangle) lpattern(solid) lwidth(thin) msize(vsmall) connect(direct) mlabel(label_wbill)), ///
       title("Wage bill, 1987-2017 `title' ", size(medium) position(11)) ytitle("")  xtitle("")  yscale(noline) ///
	   ylabel(0(10)50, noticks angle(horizontal)) legend(off) xlabel(1987(5)2017) xscale(r(1987 2020)) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white)) ysize(4) xsize(8)
graph export "${project}\figs\decC_full1987_2017_sigma_${sigma}_estimates`stub'.eps", as(eps) preview(on) replace


******************** SUBSTITUTION EFFECT ***************************   	     
gen l3="+Price substitution" if year==2016	   
gen y3=y2+cum_substitution_i
twoway (connected  y1 year, color(gs12) msymbol(circle) lpattern(tight_dot) lwidth(thin) msize(vsmall) connect(direct)) ///
	   (connected  y2 year, color(gs12) msymbol(circle) lpattern(tight_dot) lwidth(thin) msize(vsmall) connect(direct)) ///
	   (connected  y3 year, color(edkblue) mlabcolor(edkblue) msymbol(diamond_hollow) lpattern(tight_dot) lwidth(thin) msize(small) connect(direct) mlabel(l3)) ///
	   (connected  cum_delta_wbill_us year, color(gs4) mlabcolor(gs4) msymbol(triangle) lpattern(solid) lwidth(thin) msize(vsmall) connect(direct) mlabel(label_wbill)), ///
       title("Wage bill, 1987-2017 `title' ", size(medium) position(11)) ytitle("")  xtitle("")  yscale(noline) ///
	   ylabel(0(10)50, noticks angle(horizontal)) legend(off) xlabel(1987(5)2017) xscale(r(1987 2020)) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white)) ysize(4) xsize(8)
graph export "${project}\figs\decD_full1987_2017_sigma_${sigma}_estimates`stub'.eps", as(eps) preview(on) replace


******************** CHANGE TASK CONTENT OF PRODUCTION ***************************   	     
gen l4="+Change in task content of production" if year==2012	   
gen y4=y3+cum_task_content_i
twoway (connected  y1 year, color(gs12) msymbol(circle) lpattern(tight_dot) lwidth(thin) msize(vsmall) connect(direct)) ///
	   (connected  y2 year, color(gs12) msymbol(circle) lpattern(tight_dot) lwidth(thin) msize(vsmall) connect(direct) ) ///
	   (connected  y3 year, color(edkblue) mlabcolor(edkblue) msymbol(diamond_hollow) lpattern(tight_dot) lwidth(thin) msize(vsmall) connect(direct)) ///
	   (connected  y4 year, color(cranberry) mlabcolor(cranberry) msymbol(diamond) lpattern(tight_dot) lwidth(thin) msize(small) connect(direct) mlabel(l4) mlabpos(5)) ///
	   (connected  cum_delta_wbill_us year, color(gs4) mlabcolor(gs4) msymbol(triangle) lpattern(solid) lwidth(thin) msize(vsmall) connect(direct) mlabel(label_wbill)), ///
       title("Wage bill, 1987-2017 `title' ", size(medium) position(11)) ytitle("")  xtitle("")  yscale(noline) ///
	   ylabel(0(10)50, noticks angle(horizontal)) legend(off) xlabel(1987(5)2017) xscale(r(1987 2020)) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white)) ysize(4) xsize(8)
graph export "${project}\figs\decE_full1987_2017_sigma_${sigma}_estimates`stub'.eps", as(eps) preview(on) replace
}	   	   	   
	


