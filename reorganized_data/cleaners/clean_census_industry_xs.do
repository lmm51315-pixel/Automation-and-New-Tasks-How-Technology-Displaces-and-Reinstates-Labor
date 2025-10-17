/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
Automation and New Tasks: How Technology Changes Labor Demand" 
by D. Acemoglu and P. Restrepo, JEP 2019

Industry characteristics from Census 1990 and Pooled 2012-2016 ACS
4.10.2018 (revised 2.22.2019)
Pascual Restrepo

revised by G. Marcolongo on 03/04/2019

Note: 	The underlying census data (ipums_census_jep) can be obtained from IPUMS. 
		It is not included in this package due to its size.
		To obtain the exact extract used, please email pascual@bu.edu
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

************************************************************************
***Step 1: Generate measures of occupations subject to more new tasks***
************************************************************************

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
Jeffrey Lin's data for 1980 with Census 1980 codes
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
use "${project}/raw_data/occs/new1980-wk.dta", clear
merge m:1 occ using "${project}/raw_data/occs/occ1980_occ1990dd.dta", keep(2 3) nogenerate
quietly: do "${project}/raw_data/occs/create_occ1990dd_acs.do" /*new occupational system that is consistent despite changes in the ACS*/ 
gen new1980=newmaster
gen newbroad1980=new
gen titles1980=dot77_titles
collapse (sum) newbroad1980 new1980 titles1980, by(occ1990dd_acs)
drop if occ1990dd_acs>=900 
save "${project}/temp_data/newtasks1980.dta", replace

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
Jeffrey Lin's data for 1990 with Census 1980 codes 
(note: the version published in his site has the 1990 codes, but due to updates in codes cannot be matched)
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
use "${project}/raw_data/occs/new91-wk.dta", clear
merge m:1 occ using"${project}/raw_data/occs/occ1980_occ1990dd.dta", keep(2 3) nogenerate
quietly: do "${project}/raw_data/occs/create_occ1990dd_acs.do" /*new occupational system that is consistent despite changes in the ACS*/ 
gen new1990=new_convt
gen newbroad1990=new_dlu78
gen titles1990=dot91_titles
collapse (sum) newbroad1990 new1990 titles1990, by(occ1990dd_acs)
drop if occ1990dd_acs>=900 
save "${project}/temp_data/newtasks1990.dta", replace

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
Jeffrey Lin's data for 2000 with Census 2000 codes
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
use "${project}/raw_data/occs/new2000-wk.dta", clear
merge m:1 occ using "${project}/raw_data/occs/occ2000_occ1990dd.dta", keep(2 3) nogenerate 
quietly: do "${project}/raw_data/occs/create_occ1990dd_acs.do" /*new occupational system that is consistent despite changes in the ACS*/
gen new2000=rec*new_lin
gen newbroad2000=rec*new_cen
gen titles2000=rec
collapse (sum) newbroad2000 new2000 titles2000, by(occ1990dd_acs)
drop if occ1990dd_acs>=900 
save "${project}/temp_data/newtasks2000.dta", replace

*Merge all data for 304 occupations*
use "${project}/raw_data/occs/occ1990dd_acs_names", clear
merge 1:1 occ1990dd_acs using "${project}/temp_data/newtasks1980.dta", assert(1 3) nogenerate
merge 1:1 occ1990dd_acs using "${project}/temp_data/newtasks1990.dta", assert(1 3) nogenerate
merge 1:1 occ1990dd_acs using "${project}/temp_data/newtasks2000.dta", assert(1 3) nogenerate

foreach year in 1980 1990 2000{
gen sh_newtitles_narrow_`year'=new`year'/titles`year'
gen sh_newtitles_broad_`year'=newbroad`year'/titles`year'
}

*Merge data from ONET (compiled by Martina Uccioli)
merge 1:1 occ1990dd_acs using "${project}/raw_data/occs/task_changes_occ1990dd_acs_allyrs.dta", keep(1 3) nogenerate /*Note: 20 occupations not matched to ONET*/
save "${project}/temp_data/newtasks.dta", replace


*********************************************************************
***Step 2: Compile census data on industry characteristics in 1990***
*********************************************************************
use if year==1990 using "${project}/raw_data/ipums/ipums_census_jep.dta" , clear
*Drop institutional group quarters* 
drop if gqtyped>=100 & gqtyped<=499
*Drop alaska and hawaii*
drop if statefip==2 | statefip==15

*Restrict to people above 16 who are working*
keep if age>=16 & empstat==1 

***Create consistent occupational groups***
merge m:1 occ using "${project}/raw_data/occs/occ1990_occ1990dd.dta", assert(2 3) keep(3) nogenerate /*Use David Dorn's crosspath to merge occ1990dd occupational codes*/
*aggregate occupations to the occ1990dd_acs system, which can be consistently tracked over time*
run "${project}/raw_data/occs/create_occ1990dd_acs.do"
drop if occ1990dd_acs>=900
*merge occupational characteristics*
merge m:1 occ1990dd_acs using "${project}/temp_data/newtasks.dta", assert(3) nogenerate
***Create consistent industry groups ind1990dd ***
run "${project}/raw_data/occs/subfile_ind1990dd.do"

*Checks*
assert occ1990dd_acs!=. & ind1990dd!=.

***Measure of routine jobs used in Handbook Chapter***
gen task_middle=0
replace task_middle=1 if (occ1990dd>=303 & occ1990dd<=389)
replace task_middle=1 if (occ1990dd>=628 & occ1990dd<=699)
replace task_middle=1 if (occ1990dd>=703 & occ1990dd<=799)
replace task_middle=1 if (occ1990dd>=274 & occ1990dd<=283)

***Counts***
gen emppriv=(empstat==1 & (classwkrd==22 | classwkrd==23 ))

**Tabulation of basic features**
collapse  (mean) task_middle sh_new* emerging_tasks_2018 pct_emerging_tasks_2008_2018 pct_increase_tot_2008_2018 pct_change_tot_2008_2018 pct_abs_change_tot_2008_2018 ///
				 pct_increase_core_2008_2018 pct_change_core_2008_2018 pct_abs_change_core_2008_2018 ///
				 (sum) emppriv [iw=perwt], by(ind1990)			 
save "${project}/temp_data/census_characteristics_ind1990.dta", replace

**Aggregate**
use  "${project}/xwalks/master_xwalk.dta", clear
split ind1990, p(",")
rename ind1990 ind1990list
gen ind1990=""
expand 35
bys industry_bea: gen id=_n
forvalues j=1(1)35{
replace ind1990=ind1990`j' if id==`j'
drop ind1990`j' 
}
drop if ind1990==""
destring ind1990, force replace
bys ind1990: gen inv_count_ind1990=1/_N /*Assumes each industry contributes in equal proportions to each BEA industry that contains it*/

***Merge characteristics based on 1990 employment distribution***
/*List of industries with no match: 412->Postal service.  873->Labor unions.  900,901,910,921,922,930,931,932->Public officials 940,941,942,950,951,952,960->Military*/
merge m:1 ind1990 using "${project}/temp_data/census_characteristics_ind1990.dta", keep(1 3) nogenerate

*Allocate employment proportionally*
collapse (mean) task_middle sh_new* emerging_tasks_2018 pct_emerging_tasks_2008_2018 pct_increase_tot_2008_2018 pct_change_tot_2008_2018 pct_abs_change_tot_2008_2018 ///
				pct_increase_core_2008_2018 pct_change_core_2008_2018 pct_abs_change_core_2008_2018  [w=emppriv*inv_count_ind1990], by(industry_bea)
save "${project}/clean_data/census_characteristics_BEA.dta", replace

*************************************************************
***Step 3: Compile census data on employment by occupation***
*************************************************************
foreach year in 1990 2014{
if `year'!=2014{
use if year==`year' using "${project}/raw_data/ipums/ipums_census_jep.dta", clear
}
else if `year'==2014{
use if year==2016 & multyear!=. using "${project}/raw_data/ipums/ipums_census_jep.dta", clear
}
*Drop institutional group quarters* 
drop if gqtyped>=100 & gqtyped<=499
*Drop alaska and hawai*
drop if statefip==2 | statefip==15
*Restrict to people above 16 who are working*
keep if age>=16 & empstat==1
***Create consistent occupational groups***
if `year'<=2000{
merge m:1 occ using "${project}/raw_data/occs/occ`year'_occ1990dd.dta", assert(2 3) keep(3) nogenerate /*Use David Dorn's crosspath to merge occ1990dd occupational codes*/
}
else if `year'==2008{
merge m:1 occ using "${project}/raw_data/occs/occACS_occ1990dd.dta", assert(2 3) keep(3) nogenerate /*Use David Dorn's crosspath to merge occ1990dd occupational codes*/
}
else if `year'>2008{
*recode acs occupational codes*
run "${project}/raw_data/occs/recode_acs.do" 				/*Recode the ACS occupational codes to their 2005-09 vintage */
merge m:1 occ using "${project}/raw_data/occs/occACS_occ1990dd.dta", assert(2 3) keep(3) nogenerate /*David Dorn's crosspath to merge occ1990dd occupational codes*/
}
*aggregate occupations to the occ1990dd_acs system, which can be consistently tracked over time*
run "${project}/raw_data/occs/create_occ1990dd_acs.do"
drop if occ1990dd_acs>=900
***Create consistent industry groups occ1990dd ***
run "${project}/raw_data/occs/subfile_ind1990dd.do"

*Checks*
assert occ1990dd_acs!=. & ind1990dd!=.

***Counts***
gen emppriv=(empstat==1 & (classwkrd==22 | classwkrd==23 ))

*Pool Shoe repair and miscellaneous personal services, so that it can be tracked in the ACS too*
replace ind1990dd=791 if ind1990dd==782

***Average years of education and share with college***
gen college=(educd>=100 & educd<=116)  if age>=16 
gen edyears=0     		if age>=16 
replace edyears=0 		if educd==0 & age>=16 
replace edyears=0 		if educd==1 & age>=16 
replace edyears=0 		if educd==2 & age>=16 
replace edyears=2.5 	if educd>=10 & educd<=17 & age>=16 
replace edyears=6.5 	if educd>=20 & educd<=26 & age>=16 
replace edyears=9 		if educd==30 & age>=16 
replace edyears=10 		if educd==40 & age>=16 
replace edyears=11 		if educd==50 & age>=16 
replace edyears=12 		if educd>=60 & educd<=65 & age>=16 
replace edyears=13 		if (educd==70 | educd==71) & age>=16 
replace edyears=14 		if educd>=80 & educd<=90 & age>=16 
replace edyears=16 		if (educd==100 | educd==101) & age>=16 
replace edyears=18 		if educd>=110 & age>=16 

*Average gears of education*
gen comp_edyears=edyears
*College workers*
gen comp_highed=college

*Education*
preserve
collapse (sum) emppriv (mean) comp_* [iw=perwt],by(ind1990dd)
rename comp_edyears comp_edyears_`year'
rename comp_highed comp_highed_`year'
rename emppriv emppriv_`year'
save "${project}/temp_data/census_education`year'_ind1990dd.dta", replace
restore

**Tabulation of basic features**
collapse (sum) emppriv [iw=perwt], by(occ1990dd_acs ind1990dd)

rename emppriv emppriv_`year'

save "${project}/temp_data/census_occind_`year'.dta", replace

*Occupation totals*
collapse (sum) emppriv_`year', by(occ1990dd_acs)
egen total_emppriv=total(emppriv_`year')
gen sh_national_occ_emppriv_`year'=emppriv_`year'/total_emppriv
keep occ1990dd_acs sh_*
save "${project}/temp_data/census_occ_counts_`year'.dta", replace
}

*******************************************************
***Step 4: Create measures of occupational diversity***
*******************************************************
*This generates a dataset with all potential occ*industru combinations*
use "${project}/temp_data/census_occind_1990.dta", clear
duplicates drop ind1990dd, force
keep ind1990dd
expand 304
bys ind1990dd: gen num=_n
tempfile indlist
save `indlist', replace

use "${project}/temp_data/census_occind_1990.dta", clear
duplicates drop occ1990dd_acs, force
keep occ1990dd_acs
gen num=_n
merge 1:m num using `indlist', assert(3) nogenerate
keep occ1990dd_acs ind1990dd

merge 1:1 occ1990dd_acs ind1990dd using "${project}/temp_data/census_occind_1990.dta", nogenerate
merge 1:1 occ1990dd_acs ind1990dd using "${project}/temp_data/census_occind_2014.dta", nogenerate
merge m:1 occ1990dd_acs using "${project}/temp_data/census_occ_counts_1990.dta", nogenerate
merge m:1 occ1990dd_acs using "${project}/temp_data/census_occ_counts_2014.dta", nogenerate
sort ind1990dd occ1990dd_acs

replace emppriv_1990=0 if emppriv_1990==.
replace emppriv_2014=0 if emppriv_2014==.
bys ind1990dd: egen total_emppriv_1990=total(emppriv_1990)
bys ind1990dd: egen total_emppriv_2014=total(emppriv_2014)
gen share_industry_occ_emppriv=emppriv_1990/total_emppriv_1990

*Share of employment growth explained by occs that were uncommon in that industry (did not exist bfore)
*Amount of growth taking place in new/uncommon occs (take sums))*
gen growth_first_wt=(emppriv_2014!=0  & emppriv_1990==0)*(emppriv_2014/total_emppriv_1990) if sh_national_occ_emppriv_1990>0
gen growth_uncommon_wt=(emppriv_2014!=0  & emppriv_1990<0.2*total_emppriv_1990*sh_national_occ_emppriv_1990)*(emppriv_2014/total_emppriv_1990) if sh_national_occ_emppriv_1990>0

*Share of current employment in uncommon or new occupations (take sums)
gen share_new=(emppriv_2014!=0  & emppriv_1990==0)*(emppriv_2014/total_emppriv_2014) if sh_national_occ_emppriv_1990>0
gen share_uncommon_wt=(emppriv_2014!=0  & emppriv_1990<0.2*total_emppriv_1990*sh_national_occ_emppriv_1990)*(emppriv_2014/total_emppriv_2014) if sh_national_occ_emppriv_1990>0

*"Arrival" rate of new occupations (take means)
gen arrivals_unc=(emppriv_2014!=0 & emppriv_1990==0) if sh_national_occ_emppriv_1990>0
gen arrivals_cond=(emppriv_2014!=0 & emppriv_1990==0) if sh_national_occ_emppriv_1990>0 & emppriv_1990==0
bys ind1990dd: egen count1990=total((emppriv_1990>0))
bys ind1990dd: egen count2014=total((emppriv_2014>0))
bys ind1990dd: egen appear2014=total((emppriv_2014>0 & emppriv_1990==0))
gen arrivals_variety=ln(count2014)-ln(count1990)
gen arrivals_pctg=appear2014/count1990

collapse (rawsum) emppriv_1990 growth_* share_* (mean) arrivals_*, by(ind1990dd)
save "${project}/temp_data/measures_dispersion.dta", replace

**Aggregate the data on occupational structure**
use  "${project}/xwalks/master_xwalk.dta", clear
split ind1990, p(",")
rename ind1990 ind1990list
gen ind1990=""
expand 35
bys industry_bea: gen id=_n
forvalues j=1(1)35{
replace ind1990=ind1990`j' if id==`j'
drop ind1990`j' 
}
drop if ind1990==""
destring ind1990, force replace

**Match measures of occupational dispersion using ind1990dd categories (need consistent definition of industries)**
do "${project}/raw_data/occs/subfile_ind1990dd"
duplicates drop industry_bea ind1990dd, force
bys ind1990dd: gen inv_count_ind1990dd=1/_N
drop if ind1990dd==782 /*Note that 782 mapped to 791---both map to "Other services, except government"*/

***Merge characteristics based on 1990 employment distribution.***
/*List of industries with no match: 412->Postal service.  873->Labor unions.  900,901,910,921,922,930,931,932->Public officials 940,941,942,950,951,952,960->Military*/
merge m:1 ind1990dd using "${project}/temp_data/measures_dispersion.dta", keep(1 3) nogenerate

*Allocate employment proportionally*
collapse (mean) growth_* share_* arrivals_*  [w=emppriv*inv_count_ind1990], by(industry_bea)
save "${project}/clean_data/census_occdiversity_BEA.dta", replace

**Aggregate the data on education**
foreach year in 1990 2014{
use  "${project}/xwalks/master_xwalk.dta", clear
split ind1990, p(",")
rename ind1990 ind1990list
gen ind1990=""
expand 35
bys industry_bea: gen id=_n
forvalues j=1(1)35{
replace ind1990=ind1990`j' if id==`j'
drop ind1990`j' 
}
drop if ind1990==""
destring ind1990, force replace

**Match measures of occupational dispersion using ind1990dd categories (need consistent definition of industries)**
do "${project}/raw_data/occs/subfile_ind1990dd"
duplicates drop industry_bea ind1990dd, force
bys ind1990dd: gen inv_count_ind1990dd=1/_N
drop if ind1990dd==782 /*Note that 782 mapped to 791---both map to "Other services, except government"*/

***Merge characteristics based on 1990 employment distribution.***
/*List of industries with no match: 412->Postal service.  873->Labor unions.  900,901,910,921,922,930,931,932->Public officials 940,941,942,950,951,952,960->Military*/
merge m:1 ind1990dd using "${project}/temp_data/census_education`year'_ind1990dd.dta", keep(1 3) nogenerate
*Allocate employment proportionally*
collapse (mean) comp_* [w=emppriv_`year'*inv_count_ind1990], by(industry_bea)
save "${project}/clean_data/census_education`year'_BEA.dta", replace
}
