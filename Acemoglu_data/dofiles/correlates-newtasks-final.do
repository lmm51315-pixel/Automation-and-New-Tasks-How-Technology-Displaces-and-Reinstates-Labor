/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

"Automation and New Tasks: How Technology Changes Labor Demand" 
by D. Acemoglu and P. Restrepo, JEP 2019

7.31.208
Pascual Restrepo

This do file:
- computes the last four sets of coefficients of Table 1:
	Relationship between change in task content of production and proxies for new tasks
- generates Figure A5: 
	New Tasks and Change in Task Content of Production

(revised by G. Marcolongo 3.1.2019)
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

use "${project}/clean_data/census_occdiversity_BEA.dta", clear // dataset created in cleaners/clean_census_industry_xs.do 
merge 1:1 industry_bea using "${project}/clean_data/census_characteristics_BEA.dta", assert(2 3) nogenerate // dataset created in cleaners/clean_census_industry_xs.do 
merge 1:1 industry_bea using "${project}/clean_data/industry_contribution_sigma_${sigma}.dta", assert(2 3) nogenerate // created in decomposition 1987 - 2017 (includes task_content, displacement and reinstatement effect and respective weights)
replace manufacturing=0 if manufacturing==.
gen indname=industry_bea

*Industry names*
replace indname=ltrim(rtrim(indname))
replace indname="Forestry and fishing" if indname=="Forestry, fishing, and related activities"
replace indname="Automotive" if indname=="Motor vehicles, bodies and trailers, and parts"
replace indname="Electronics and components" if indname=="Electrical equipment, appliances, and components"
replace indname="Computers" if indname=="Computer and electronic products"
replace indname="Food and beveradges" if indname=="Food and beverage and tobacco products"
replace indname="Furniture" if indname=="Furniture and related products"
replace indname="Miscellaneous manufacturing" if indname=="Miscellaneous manufacturing"
replace indname="Primary metals" if indname=="Primary metals"
replace indname="Mineral products" if indname=="Nonmetallic mineral products"
replace indname="Printing and support activities" if indname=="Printing and related support activities"
replace indname="Pictures and Records" if indname=="Motion picture and sound recording industries"
replace indname="Live entertainment" if indname=="Performing arts, spectator sports, museums, and related activities"
replace indname="Real estate" if indname=="Real estate"
replace indname="Educational services" if indname=="Educational services"
replace indname="Waste management" if indname=="Waste management and remediation services"
replace indname="Professional services" if indname=="Miscellaneous professional, scientific, and technical services"
replace indname="Banks and credit institutions" if indname=="Federal Reserve banks, credit intermediation, and related activities"
replace indname="Data services and internet" if indname=="Data processing, internet publishing, and other information services"
replace indname="Security brokers" if indname=="Securities, commodity contracts, and investments"
replace indname="Rental and leasing" if indname=="Rental and leasing services and lessors of intangible assets"
replace indname="Publishing" if indname=="Publishing industries, except internet (includes software)"
replace indname="Amusement and recreation" if indname=="Amusements, gambling, and recreation industries"
replace indname="Hospitals" if indname=="Hospitals and nursing and residential care facilities"
replace indname="Textiles" if indname=="Textile mills and textile product mills"
replace indname="Computer systems design" if indname=="Computer systems design and related services"
replace indname="Management of companies" if indname=="Management of companies and enterprises"
replace indname=ustrregexrf(indname,"products","",.)

*Write down task content in log points*
replace task_content_i=100*task_content_i

*************************
*Other Shocks and trends*
*************************
*Robots*
merge m:1 industry_ifr19 using  "${project}/clean_data/apr_measure.dta", keep(3) nogenerate

*Trade with china*
merge 1:1 industry_bea using "${project}/clean_data/china-sag_bea.dta", assert(1 3) nogenerate
gen china_exposure=0
replace china_exposure=d_import_otch_1991_2011 if manuf==1

*Offshoring*
merge 1:1 industry_bea using "${project}/clean_data/FH_offshoring_bea", assert(1 3) nogenerate // created from cleaners/clean_offshoring.do
gen fh_offshoring=0
replace fh_offshoring=increase_offs if manuf==1
gen proxy_offshoring=fh_offshoring


****************************************************************
*Model 1: New job titles appear in occupations in that industry 
****************************************************************
* Figure A5, panel 1 and Fourth set of coefficients in Table 1
replace sh_newtitles_narrow_1990=100*sh_newtitles_narrow_1990
analyze_var_jep task_content sh_newtitles_narrow_1990 [w=indwts], xname("Share of new job titles, based on 1991 DOT and 1990 employment by occupation") yname("Change in task content of production, 1987-2017")

*******************************************************************
*Model 2: Occupations in that industry getting more emerging tasks 
*******************************************************************
* Figure A5, panel 2 and Fifth set of coefficients in Table 1
analyze_var_jep task_content emerging_tasks_2018 [w=indwts], xname("Number of emerging tasks, based on 1990 employment by occupation") yname("Change in task content of production, 1987-2017")

**************************************************
*Model 3: Employment growth in "new" occuppations*
**************************************************
* Figure A5, panel 3 and Sixth set of coefficients in Table 1
replace growth_first_wt=100*growth_first_wt
analyze_var_jep task_content growth_first_wt [w=indwts], xname("Share of growth between 1990-2016 in occupations not in industry in 1990") yname("Change in task content of production, 1987-2017")

*******************************************
*Model 4: Increase in occupational variety*
*******************************************
* Figure A5, panel 4 and Last Set of coefficients in Table 1
replace arrivals_variety=100*arrivals_variety
analyze_var_jep task_content arrivals_variety [w=indwts], xname("Percent increase in number of occupations represented in industry") yname("Change in task content of production, 1987-2017")

