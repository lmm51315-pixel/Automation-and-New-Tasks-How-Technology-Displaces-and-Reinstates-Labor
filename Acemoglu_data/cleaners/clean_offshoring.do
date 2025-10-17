/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
"Automation and New Tasks: How Technology Changes Labor Demand" 
by D. Acemoglu and P. Restrepo, JEP 2019

Cleans offshoring data (supplied by Wright) and create
measures available at BEA level and sic87dd level.

2.24.2019
Pascual Restrepo

revised by G. Marcolongo on 3.4.2019
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

****Offshoring data from Gregory Wright*****
use "${project}/raw_data/industry/FH_offshoring_naics.dta", clear
merge 1:1 naics year using "${project}/raw_data/industry/naics5811.dta", assert(2 3)  nogenerate
keep if year>=1993 & year<=2007
*Missing implies no intermediate imports*
replace offsh=0 if offsh==.

tempfile naics
save `naics', replace

*Weighted average using materials*
gen naics4=floor(naics/100)
merge m:1 naics4 using "${project}/xwalks/naics4_xwalk.dta", assert(2 3) keep(3) 
collapse (mean) offsh [w=matcost], by(industry_bea year)
reshape wide offsh, i(industry_bea) j(year)
gen increase_offshoring=100*(offsh2007-offsh1993)
keep industry_bea increase
save "${project}/clean_data/FH_offshoring_bea", replace

*Match to SIC87DD industries (follows Joonas code)*
use `naics', clear
keep naics offsh year
* Keep only 1993 and 2007
keep if year==1993 | year==2000 | year==2007
assert naics!=.

/* Convert 1990-2007 data from NAICS to SIC codes using David Dorn's crosswalk */
rename naics naics6
joinby naics6 using "${project}/xwalks/cw_n97_s87.dta", unmatched(both) _merge(naics_merge)
*naics97_sic87.dta", unmatched(both) _merge(naics_merge)
assert naics_merge == 2 | naics_merge == 3
keep if naics_merge == 3
drop naics_merge 


* The variable weight indicates the share of a NAICS industry's 1997 employment that maps to a given SIC code.
* Use employment weights from Solow paper in naics industries in 1997
rename naics6 naics
rename sic4 sic
merge m:1 naics using "${project}/raw_data/industry/nber-ces-naics-emp.dta", assert(2 3) keep(3) nogenerate
* Generate final weights
sort sic
gen weight_final = weight * emp 

* Collapse to the SIC87 level
collapse (mean) offsh [w=weight_final], by(year sic)

* Drop instances in which industries are partly/fully mapped into non-manufacturing SIC codes
drop if sic==2411 | sic==2711 | sic==2721 | sic==2731 | sic==2741 | sic==2771
keep if sic >= 2000 & sic <= 3999
bys sic: gen count_sic=_N
assert count_sic==3

/*  Map into sic87dd codes using David Dorn's concordance as in Solow paradox paper */
gen sic87=sic
merge m:1 sic87 using "${project}/xwalks/sic87_sic87dd.dta", assert(2 3) keep(3)

*Merge material costs to be used as weights*
merge 1:1 sic year using "${project}/raw_data/industry/sic5811.dta", assert(2 3) keep(3) nogenerate

* Verify that we only have manufacturing industries (after excluding the fishing industry)
keep if sic87dd >= 2000 & sic87dd <= 3999
* Recollapse to the sic87dd level using material costs
collapse (mean) offsh [w=matcost], by(year sic87dd)
/* Reshape */
reshape wide offsh, i(sic87dd) j(year)
gen increase_offshoring=100*(offsh2007-offsh1993)
keep sic87dd increase
/* Save */
save "${project}/clean_data/FH_offshoring_sic87dd", replace
