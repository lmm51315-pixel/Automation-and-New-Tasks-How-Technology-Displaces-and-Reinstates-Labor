/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
"Automation and New Tasks: How Technology Changes Labor Demand" 
by D. Acemoglu and P. Restrepo, JEP 2019
 
Detailed manufacturing sample from BEA-IO tables for 1987-2007
-Measures of technology adoption from SMT (subset of 148 industries)
Resulting panel of 387 industries based on SIC87 for 1977, 1982, 1987, 1992, 1997, 2002, 2007

7.23.2018 (revised 2.24.2019)
Pascual Restrepo

revised by G. Marcolongo on 3.4.2019
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

****Step 1: Code from Brendan Price (Solow Paradox paper)***
/* Prepare 1988 and 1993 SMT data (used in Doms, Dunne, and Troske 1997) */
foreach y of numlist 88 93{
	* Load data on technology use within industries 3400-3800
	use "${project}/raw_data/industry/smt`y'.dta", clear
	
	assert sic >= 3400 & sic <= 3899 /*Industries included in SMT*/
	
	* Retain employment-weighted technology measures (i.e., number of employees working in plants that use each technology)
	*keep sic totemp *02
	
	* Verify that the share of employees using a technology never exceeds unity (up to rounding error)
	foreach v of varlist *02 {
		assert `v' < totemp + 1
		replace `v' = totemp if `v' > totemp
	}
	* Same for number of firms (though here, data seems to have more mistakes that are not due to rounding) *
	foreach v of varlist *01 {
		replace `v' = freq if `v' > freq
	}

	if `y' == 88 {
		* 1988 data are coded in 1977 SIC codes; I use the 1972-1987 SIC crosswalk with some modification
		* (see http://www.census.gov/epcd/www/SIC1987%20to%20SIC1977%20correspondence%20tables.pdf)
		rename sic sic72
		joinby sic72 using "${project}/xwalks/sic72_sic87.dta", unmatched(master) _merge(check)
		assert sic72 == 3673 | sic72 == 3716 | sic72 == 3790 if check == 1

		replace sic87 = 3671 if sic72 == 3673
		replace sic87 = 3716 if sic72 == 3716
		replace sic87 = 3799 if sic72 == 3790
		replace sh7287 = 1 if sic72 == 3673 | sic72 == 3716 | sic72 == 3790
		
		* 1987 shares should sum to unity within each 1972 SIC
		bysort sic72: egen tot_sh7287 = total(sh7287)
		assert abs(1 - tot_sh7287) < .0001
		drop tot_sh7287

		* Rescale variables
		foreach v of varlist totemp *02 {
			replace `v' = `v' * sh7287
		}
	
		
		collapse (sum) totemp freq *01 *02, by(sic87)
	}
	else if `y' == 93 {
		* 1993 data are reported in 1987 SIC codes
		rename sic sic87
	}
	
	*Save intermediate step*
	save "${project}/temp_data/smt`y'_sic87.dta", replace

	* Clean adn generate shares *
	keep sic87 totemp *02
	
	
	* Map into sic87dd codes
	merge 1:1 sic87 using "${project}/xwalks/sic87_sic87dd.dta", assert(2 3)
	keep if _merge == 3
	collapse (sum) totemp *02, by(sic87dd)

	* Compute the share of employees working in plants that use each technology
	foreach v of varlist *02 {
		gen share_`v' = 100* `v'/totemp
		drop `v'
	}
	
	* Verify that there are 17 technologies
	quietly lookfor share
	local num_techs : word count `r(varlist)'
	assert `num_techs' == 17
	
	* Compute the fraction of these 17 technologies to which the average worker is exposed in each industry
	gen smtshare_19`y' = 0
	foreach v of varlist share* {
		replace smtshare_19`y' = smtshare_19`y' + (`v'/17)
	}
	
	
	* Restrict the technology variable to industries in SIC 34-38
	keep if sic87dd >= 3400 & sic87dd <= 3899
	assert smtshare_19`y' >= 0 & smtshare_19`y' <= 100
	
	rename *02 *_19`y'
	
	keep sic87dd *_19`y'
	tempfile smt`y'
	gen smt_sample=1
	save "${project}/temp_data/smt`y'_sic87dd.dta", replace
}


****Step 2: Bring data on value added and compensation for detailed manufacturing industries, from Christina Patterson****
foreach year in 1977 1982 1987 1992 1997 2002 2007{

use "${project}/raw_data/industry/`year'_table_sic87_codes.dta", clear
destring sic, gen(sic87) force
keep if sic87!=.

*Drop industries that leave manufacturing in subsequent years (consistent with treatment in NBER-CES data)*
drop if sic=="2411" | sic=="2711" | sic=="2721" | sic=="2731" | sic=="2741" | sic=="2771"

*Aggregate to sic87dd classification*
merge 1:1 sic87 using "${project}/xwalks/sic87_sic87dd.dta", assert(2 3) keep(3)
collapse (sum) value_added compensation, by(sic87dd)

keep if sic87dd>=2000 & sic87dd<=3999 /*Keep only manufacturing (drop lodging)*/

rename value_added  beaCP_vadded`year'
rename compensation beaCP_comp`year'
gen beaCP_labsh`year'=beaCP_comp`year'/beaCP_vadded`year'

if `year'==1977{
save "${project}/temp_data/beacp_aggregates.dta", replace
}
else{
merge 1:1 sic87dd using "${project}/temp_data/beacp_aggregates.dta", assert(3)  nogenerate
save "${project}/temp_data/beacp_aggregates.dta", replace
}
}


****Step 3: Bring capital and employment**********
use "${project}/raw_data/industry/sic5811.dta", clear
keep if year==1977 | year==1982 | year==1987 | year==1992 | year==1997 | year==2002 | year==2007

*Drop industries that leave manufacturing in subsequent years (consistent with treatment in NBER-CES data)*
drop if sic==2411 | sic==2711 | sic==2721 | sic==2731 | sic==2741 | sic==2771

*Quantity of capital and labor needed to compute changes in task content*
keep sic year emp prode pay prodw  cap 
reshape wide emp prode pay prodw cap , i(sic) j(year)
rename sic sic87
merge 1:1 sic87 using "${project}/xwalks/sic87_sic87dd.dta", assert(2 3) keep(3)

collapse (sum) emp* prode* pay* prodw* cap*, by(sic87dd)

keep if sic87dd>=2000 & sic87dd<=3999 /*Keep only manufacturing (drop lodging)*/

save "${project}/temp_data/nber_ces.dta", replace



**Merge data**
use "${project}/temp_data/beacp_aggregates.dta", clear
merge 1:1 sic87dd using "${project}/temp_data/nber_ces.dta", assert(3) nogenerate
merge 1:1 sic87dd using "${project}/temp_data/smt88_sic87dd.dta", assert(1 3) nogenerate
merge 1:1 sic87dd using "${project}/temp_data/smt93_sic87dd.dta", assert(1 3) nogenerate
save  "${project}/clean_data/beaio_smt.dta", replace



