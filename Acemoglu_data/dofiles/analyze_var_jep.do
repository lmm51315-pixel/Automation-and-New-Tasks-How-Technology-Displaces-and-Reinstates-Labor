/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

"Automation and New Tasks: How Technology Changes Labor Demand" 
by D. Acemoglu and P. Restrepo, JEP 2019

This do file creates the program "analyze_var_jep" that will be recalled in 
the subsequent do files to produce Tables 1, A1 and Figures A4 and A5

(revised by G. Marcolongo 2.25.2019)
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */


* Define the function "analyze_var_jep"  that will be recalled in the following do files to estimate the models
cap program drop analyze_var_jep
program define analyze_var_jep, eclass 

/*
Structure of the function:
- (min = 2 numeric) specify at least two variables
- [if] specify the subset of obs on which to run the regression 
- [in] range of the observations
- [aweight fweight]: which weights to use for the observations 
- cluster(varname numeric string)]: which variable (numerical or string) to use to cluster
- xname(string): the name of the covariate and
- yname(string): the name of the dependent variable, will be used as a title in the graphs*/

syntax varlist(min=2 numeric) [if] [in] [aweight fweight], ///
	   [cluster(varname numeric string) xname(string) yname(string)]
		
		* Create convenient weight local
	    if ("`weight'"!="") local wt [`weight'`exp']
	
	* Parse varlist into y-vars and x-var
	* Identify the covariates as the list of words excluding the first (which is the dep variable) in the arguments of the analyze_var_jep function 
	local x_var=word("`varlist'",-1)
	* Identify the dependent variable as the list of words argument of the function, excluding the covariates identified above
	local y_vars=regexr("`varlist'"," `x_var'$","")

* If no variable for clustering is specified, run these three regressions (std errors robust for heteroschedasticity):
	if "`cluster'"==""{
	* I) Baseline regression (Raw data)
	quietly: reg `y_vars' `x_var'  `wt'  `if', r
	local best: display %6.2f round(_b[`x_var'], .01)
	local serror: display %6.2f round(_se[`x_var'], .01)
	estimates store e1
	
	* II) Controlling for manufacturing
	quietly: reg `y_vars' `x_var' manuf `wt'  `if', r
	local best_manuf: display %6.2f round(_b[`x_var'], .01)
	local serror_manuf: display %6.2f round(_se[`x_var'], .01)
	estimates store e2
	
	* III) Controlling for Chinese import and offshoring
	quietly: reg `y_vars' `x_var' manuf china_exposure proxy_offshoring  `wt'  `if', r
	local best_trade: display %6.2f round(_b[`x_var'], .01)
	local serror_trade: display %6.2f round(_se[`x_var'], .01)
	estimates store e3
	}
	
	* When the variable for clustering is specified, use the available variable to cluster std errors
	else if "`cluster'"!="" {
	
	* I) Baseline regression (Raw data)
	quietly: reg `y_vars' `x_var'  `wt'  `if', r cluster(`cluster')
	local best: display %6.2f round(_b[`x_var'], .01)
	local serror: display %6.2f round(_se[`x_var'], .01)
	estimates store e1
	
	* II) Controlling for manufacturing
	quietly: reg `y_vars' `x_var' manuf `wt'  `if', r  cluster(`cluster')
	local best_manuf: display %6.2f round(_b[`x_var'], .01)
	local serror_manuf: display %6.2f round(_se[`x_var'], .01)
	estimates store e2
	
	* III) Controlling for Chinese import and offshoring
	quietly: reg `y_vars' `x_var' manuf china_exposure proxy_offshoring  `wt'  `if', r cluster(`cluster')
	local best_trade: display %6.2f round(_b[`x_var'], .01)
	local serror_trade: display %6.2f round(_se[`x_var'], .01)
	estimates store e3
	}
	
	
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
* * * * * * * * * * * * * *      TABLES     * * * * * * * * * * * * * * * * * *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *  	
	
	
	* Create separate Tables for whole sample and only manufacturing
	sum manuf 
	
	*** WHOLE SAMPLE ***
	local mantag=r(min)
	if `mantag'==0{
	*Table*
	estout e1 e2 e3 using "${project}/tables/table_`y_vars'_`x_var'.tex", style(tex) ///
	varlabels(`x_var' "\multirow{2}{=}{`xname'}") ///
		  cells(b(nostar fmt(%9.3f)) se(par)) stats(N r2, fmt(%7.0f %7.2f) labels("Observations" "R-squared")) nolabel replace mlabels(none) collabels(none)  ///
	keep(`x_var') ///
	order(`x_var') 
    }
	
	*** ONLY MANUFACTURING ***
	else if `mantag'==1{
	*Table*
	estout e1 e3 using "${project}/tables/table_`y_vars'_`x_var'.tex", style(tex) extracols(2) ///
	varlabels(`x_var' "\multirow{2}{=}{`xname'}") ///
		  cells(b(nostar fmt(%9.3f)) se(par)) stats(N r2, fmt(%7.0f %7.2f) labels("Observations" "R-squared")) nolabel replace mlabels(none) collabels(none)  ///
	keep(`x_var') ///
	order(`x_var') 
    }
	

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
* * * * * * * * * * * * * *      GRAPHS     * * * * * * * * * * * * * * * * * *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *  	
	
	*Define set of markers to label*
	tempvar tag_label
	tempvar tag_rank
	quietly: gen `tag_label'=0

	*Yvar*
	quietly: egen `tag_rank'=rank(`y_vars') if `y_vars'!=.
	quietly: sum `y_vars' if `tag_rank'==3 
	quietly: replace `tag_label'=1 if `y_vars'<r(mean) & `y_vars'!=. // identify the obs that will be labelled as those whose value is below the mean of the third in rank (increasing order)
	quietly: drop `tag_rank'
	
	quietly: egen `tag_rank'=rank(-`y_vars') if `y_vars'!=. 
	quietly: sum `y_vars' if `tag_rank'==3
	quietly: replace `tag_label'=1 if `y_vars'>r(mean) & `y_vars'!=. // identify the obs that will be labelled as those whose value is above the mean of the third in rank (descending order)
	quietly: drop `tag_rank'

	*Xvar*
	quietly: egen `tag_rank'=rank(-`x_var') if `x_var'!=.
	quietly: sum `x_var' if `tag_rank'<=8 & `tag_rank'>=3
	quietly: replace `tag_label'=1 if `x_var'>r(mean) & `x_var'!=. // identify the obs that will be labelled as those whose value is above the mean of the obs that are rankied below 8 or above 3 when x is ranked in descending order
	quietly: drop `tag_rank'
	
	sum `x_var'
	local min=r(min)
	local max=r(max)
	
* CREATE separate GRAPHS for WHOLE sample and ONLY manufacturing	
* Graphs for ALL sample
	if `mantag'==0{
	twoway (scatter `y_vars' `x_var' `wt' if `y_vars'!=. & manuf==0, $style_obs_nmanuf) ///
		   (scatter `y_vars' `x_var' `wt' if `y_vars'!=. & manuf==1, $style_obs_manuf) ///
		   (lfit    `y_vars' `x_var' `wt' if `y_vars'!=., range(`min' `max') lcolor(gs4) lwidth(thin)) ///
		   (scatter `y_vars' `x_var' if `tag_label'==1, mcolor("233 119 120%70") msize(zero) mlabel(indname) mlabsize(vsmall) mlabcolor(gs8) mlabposition(12) mlabgap(small)), ///
		   title("`yname'", color(navy) position(11) size(medium)) ///
		   subtitle("Estimate: `best' (se=`serror')" ///
		            "Controls for manufacturing: `best_manuf' (se=`serror_manuf')" ///
		            "Controls for trade: `best_trade' (se=`serror_trade')" ///
		           " ", size(small) position(11) ) legend(off) xtitle("`xname'", size(medium)) ytitle("", size(medium)) ///
		   ysize(5) xsize(8) ylabel(, angle(horizontal) grid glwidth(thin) glcolor(white)) xlabel(,  grid glwidth(thin) glcolor(white))  graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white))
    graph export "${project}\figs\corr_`y_vars'_`x_var'_info.eps", as(eps) preview(on) replace
	
	twoway (scatter `y_vars' `x_var' `wt' if `y_vars'!=. & manuf==0, $style_obs_nmanuf) ///
		   (scatter `y_vars' `x_var' `wt' if `y_vars'!=. & manuf==1, $style_obs_manuf) ///
		   (lfit    `y_vars' `x_var' `wt' if `y_vars'!=., range(`min' `max') lcolor(gs4) lwidth(thin)) ///
		   (scatter `y_vars' `x_var' if `tag_label'==1, mcolor("233 119 120%70") msize(zero) mlabel(indname) mlabsize(vsmall) mlabcolor(gs8) mlabposition(12) mlabgap(small)), ///
		   title("`yname'", color(navy) position(11) size(medium)) ///
		   legend(off) xtitle("`xname'", size(medium)) ytitle("", size(medium)) ///
		   ysize(5) xsize(8) ylabel(, angle(horizontal) grid glwidth(thin) glcolor(white)) xlabel(,  grid glwidth(thin) glcolor(white))  graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white))
    graph export "${project}\figs\corr_`y_vars'_`x_var'.eps", as(eps) preview(on) replace
	}
	
* Graphs for MANUFACTURING
	else if `mantag'==1{
	twoway (scatter `y_vars' `x_var' `wt' if `y_vars'!=., $style_obs_manuf) ///
		   (lfit    `y_vars' `x_var' `wt' if `y_vars'!=., range(`min' `max') lcolor(gs4) lwidth(thin)) ///
		   (scatter `y_vars' `x_var' if `tag_label'==1, mcolor("233 119 120%70") msize(zero) mlabel(indname) mlabsize(vsmall) mlabcolor(gs8) mlabposition(3) mlabgap(small)), ///
		   title("`yname'", color(navy) position(11) size(medium)) ///
		   subtitle("Estimate:`best' (se=`serror')" ///
		            "Controls for trade: `best_trade' (se=`serror_trade')" ///
		            " ", size(small) position(11) ) legend(off) xtitle("`xname'", size(medium)) ytitle("", size(medium)) ///
		   ysize(5) xsize(8) ylabel(,  angle(horizontal) grid glwidth(thin) glcolor(white)) xlabel(,  grid glwidth(thin) glcolor(white))  graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white))
    graph export "${project}\figs\corr_`y_vars'_`x_var'_info.eps", as(eps) preview(on) replace
	
	twoway (scatter `y_vars' `x_var' `wt' if `y_vars'!=., $style_obs_manuf) ///
		   (lfit    `y_vars' `x_var' `wt' if `y_vars'!=., range(`min' `max') lcolor(gs4) lwidth(thin)) ///
		   (scatter `y_vars' `x_var' if `tag_label'==1, mcolor("233 119 120%70") msize(zero) mlabel(indname) mlabsize(vsmall) mlabcolor(gs8) mlabposition(3) mlabgap(small)), ///
		   title("`yname'", color(navy) position(11) size(medium)) ///
		   legend(off) xtitle("`xname'", size(medium)) ytitle("", size(medium)) ///
		   ysize(5) xsize(8) ylabel(,  angle(horizontal) grid glwidth(thin) glcolor(white)) xlabel(,  grid glwidth(thin) glcolor(white))  graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white))
    graph export "${project}\figs\corr_`y_vars'_`x_var'.eps", as(eps) preview(on) replace
	}
	
	
end
