/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
"Automation and New Tasks: How Technology Changes Labor Demand" 
by D. Acemoglu and P. Restrepo, JEP 2019

before running set the path to this working directory at line 16
For example:
global project "C:\Users\Pippo\Documents\replication_acemoglu_restrepo_jep"

(revised by G. Marcolongo on 03.27.2019)
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
clear
set more off

*******************************************************************************/
*Set Working Directory:
global project "...\replication_acemoglu_restrepo_jep\"
*******************************************************************************/


***Executer***
global appendix=0
global sigma 0.8
global growth_rate_1987_2017 0.0146
global growth_rate_1947_1987 0.02

***Figures***
global style_prod_effect 	color(eltgreen) mlabcolor(eltgreen) msymbol(circle) lpattern(tight_dot) lwidth(thin) msize(small) connect(direct)
global style_comp_effect 	lcolor(edkblue) mcolor(edkblue) mlabcolor(edkblue) msymbol(square) lpattern(solid) lwidth(thin) msize(vsmall) connect(direct)
global style_price_subs 	color(lavender) mlabcolor(lavender) msymbol(none) lpattern(dash_dot) lwidth(thin) msize(vsmall) connect(direct)
global style_task_content   color(dkorange) mlabcolor(dkorange) msymbol(diamond_hollow) lpattern(dash_dot) lwidth(thin) msize(small) connect(direct)
global style_observed       lcolor(gs8) mcolor(gs8) mlabcolor(gs8) msymbol(triangle_hollow) lpattern(solid) lwidth(thin) msize(small) connect(direct)
global style_displacement   color(orange_red) mlabcolor(orange_red) msymbol(circle) lpattern(solid) lwidth(thin) msize(small) connect(direct)
global style_reinstatement  color(blue)    mlabcolor(blue)     msymbol(triangle) lpattern(solid) lwidth(thin) msize(small) connect(direct)
global style_displacement2  color(orange_red) mlabcolor(orange_red) msymbol(none) lpattern(dash_dot) lwidth(thin) msize(small) connect(direct)
global style_reinstatement2 color(blue)    mlabcolor(blue)     msymbol(none) lpattern(dash_dot) lwidth(thin) msize(small) connect(direct)
global style_price_effect 	color(maroon) mlabcolor(maroon) msymbol(circle) lpattern(tight_dot) lwidth(thin) msize(small) connect(direct)
global style_obs_manuf      mcolor(edkblue) msize(medium) msymbol(diamond) mlcolor(black) mlwidth(vthin)
global style_obs_nmanuf 	mcolor(eltgreen) msize(medium) msymbol(circle) mlcolor(black) mlwidth(vthin)

*****************
*** Main text ***
*****************
*Raw data *
do "${project}/dofiles/sectoral trends" /// Figures A15, 2, 4

*Decomposition 1987-2017*
do "${project}/dofiles/decomposition 1987-2017.do" 					// Figure 5: Panel A + B, Figure A8: Panel B, Figure A1: Panel B, Figure A2: Panel B, Alternative scenario for A_L/ A_K, Gradual Decomposition
do "${project}/dofiles/decomposition 1987-2017, manufacturing.do" 	// Figure A3 : Panel B, Figure 5: Panel C, Gradual Decomposition

*Decomposition 1947-1987*
do "${project}/dofiles/decomposition 1947-1987.do" 					// Figure 3: Panel A + B, Figure A8: Panel A, Figure A1: Panel A, Figure A2: Panel A, Alternative scenario for A_L/ A_K, Gradual Decomposition
do "${project}/dofiles/decomposition 1947-1987, manufacturing.do"  	// Figure A3 : Panel A, Figure 3: Panel C, Gradual Decomposition

*Correlates*
do "${project}/dofiles/analyze_var_jep.do" 					// Creates function that will be recalled in the following do files to run regressions and plot graphs
do "${project}/dofiles/correlates automation final.do" 		// Creates first set of Coefficients of Table 1 for Proxies of automation technologies and Figure A4
do "${project}/dofiles/correlates newtasks final.do"		// Creates second set of Coefficients of Table 1 for Proxies of new tasks and Figure A5
do "${project}/dofiles/correlates prices and quantities.do" // Creates Table A1: Relationship between gross change in task content of production, quantities produced, TFP, and skill intensity of industries.

*****************
***  Appendix ***
*****************
global appendix=1

*Order of decomposition*
do "${project}/dofiles/decomposition 1947-1987, alt order.do" // Figure A6: Panel A, Alternative order for the Wage Bill Decomposition 1947-1987
do "${project}/dofiles/decomposition 1987-2017, alt order.do" // Figure A6: Panel B, Alternative order for the Wage Bill Decomposition 1987-2017

*BLS data*
do "${project}/dofiles/decomposition 1987-2017, BLS.do"		// Figure A7: Panels A + B + C, Sources of Changes in Labor Demand 1987 - 2017, BLS data

*Different values of sigma*
global sigma 0.6
do "${project}/dofiles/decomposition 1987-2017.do"		 			// Creates Figure A 12 - Panel A and Figure A 13 - Panel A (Sources of changes in Labor Demand and estimates of Reinstatement and Displacement effect with sigma = 0.6)
do "${project}/dofiles/decomposition 1987-2017, manufacturing.do"  	// Creates Figure A 14 - Panel A (Estimates of Reinstatement and Displacement effects - sigma = 0.6)
do "${project}/dofiles/decomposition 1947-1987.do"					// Creates Figure A 9  - Panel A and Figure A 10 - Panel A (Sources of changes in Labor Demand and estimates of Reinstatement and Displacement effect with sigma = 0.6)
do "${project}/dofiles/decomposition 1947-1987, manufacturing.do"	// Creates Figure A 11 - Panel A (Estimates of Reinstatement and Displacement effects - sigma = 0.6)

global sigma 0.8
do "${project}/dofiles/decomposition 1987-2017.do"					// Creates Figure A 12 - Panel B and Figure A 13 - Panel B (Sources of changes in Labor Demand and estimates of Reinstatement and Displacement effect with sigma = 0.8)
do "${project}/dofiles/decomposition 1987-2017, manufacturing.do"	// Creates Figure A 14 - Panel B (Estimates of Reinstatement and Displacement effects - sigma = 0.8)
do "${project}/dofiles/decomposition 1947-1987.do"					// Creates Figure A 9  - Panel B and Figure A 10 - Panel B (Sources of changes in Labor Demand and estimates of Reinstatement and Displacement effect with sigma = 0.8)
do "${project}/dofiles/decomposition 1947-1987, manufacturing.do"	// Creates Figure A 11 - Panel B (Estimates of Reinstatement and Displacement effects - sigma = 0.8)

global sigma 1
do "${project}/dofiles/decomposition 1987-2017.do"					// Creates Figure A 12 - Panel C and Figure A 13 - Panel A (Sources of changes in Labor Demand and estimates of Reinstatement and Displacement effect with sigma = 1)
do "${project}/dofiles/decomposition 1987-2017, manufacturing.do" 	// Creates Figure A 14 - Panel C (Estimates of Reinstatement and Displacement effects - sigma = 1)
do "${project}/dofiles/decomposition 1947-1987.do"					// Creates Figure A 9  - Panel C and Figure A 10 - Panel C (Sources of changes in Labor Demand and estimates of Reinstatement and Displacement effect with sigma = 1)
do "${project}/dofiles/decomposition 1947-1987, manufacturing.do"	// Creates Figure A 11 - Panel C (Estimates of Reinstatement and Displacement effects - sigma = 1)

global sigma 1.2
do "${project}/dofiles/decomposition 1987-2017.do"					// Creates Figure A 12 - Panel D and Figure A 13 - Panel D (Sources of changes in Labor Demand and estimates of Reinstatement and Displacement effect with sigma = 1.2)
do "${project}/dofiles/decomposition 1987-2017, manufacturing.do"	// Creates Figure A 14 - Panel D (Estimates of Reinstatement and Displacement effects - sigma = 1.2)
do "${project}/dofiles/decomposition 1947-1987.do"					// Creates Figure A 9  - Panel D and Figure A 10 - Panel D (Sources of changes in Labor Demand and estimates of Reinstatement and Displacement effect with sigma = 1.2)
do "${project}/dofiles/decomposition 1947-1987, manufacturing.do"	// Creates Figure A 11 - Panel D (Estimates of Reinstatement and Displacement effects - sigma = 1.2)




