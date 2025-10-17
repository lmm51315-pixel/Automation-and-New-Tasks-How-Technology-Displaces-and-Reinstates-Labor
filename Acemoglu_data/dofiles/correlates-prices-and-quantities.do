/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
"Automation and New Tasks: How Technology Changes Labor Demand" 
by D. Acemoglu and P. Restrepo, JEP 2019

7.31.208
Pascual Restrepo

This do file generates Table A1: "Relationship between gross change in task content of production,
quantities produced, TFP, and skill intensity of industries."

(revised by G. Marcolongo on 3.1.2019)
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

use "${project}/clean_data/industry_contribution_sigma_${sigma}.dta", clear // created in decomposition 1987 - 2017 (includes task_content, displacement and reinstatement effect and respective weights)
merge 1:1 industry_bea using "${project}/clean_data/census_education1990_BEA.dta", assert(1 3) nogenerate 	// created in cleaners/clean_census_industry_xs.do
merge 1:1 industry_bea using "${project}/clean_data/census_education2014_BEA.dta", assert(1 3) nogenerate 	// created in cleaners/clean_census_industry_xs.do
merge 1:1 industry_bea using "${project}/clean_data/price_bea.dta", assert(3) nogenerate					// created in cleaners/clean_bea_productivity.do
merge 1:1 industry_bea using "${project}/clean_data/qty_bea.dta", assert(3) nogenerate						// created in cleaners/clean_bea_productivity.do
merge 1:1 industry_bea using "${project}/clean_data/tfp_bea.dta", assert(3) nogenerate 						// created in cleaners/clean_bea_productivity.do
replace manufacturing=0 if manufacturing==.
gen indname=industry_bea

*Write down task content in log points*
replace task_content_i=100*task_content_i
replace task_negative_5yr=100*task_negative_5yr
replace task_positive_5yr=100*task_positive_5yr

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
merge 1:1 industry_bea using "${project}/clean_data/FH_offshoring_bea", assert(1 3) nogenerate
gen fh_offshoring=0
replace fh_offshoring=increase_offs if manuf==1
gen proxy_offshoring=fh_offshoring

***********************************
*Prices, Quantities and Skill Bias*
***********************************
gen electronics=(industry_bea=="Computer and electronic products")
gen gross_change=task_positive_5yr-task_negative_5yr
gen change_ed=100*(comp_highed_2014-comp_highed_1990)
replace manufacturing=100*manuf

******************************************************
* Log change in quantities of industries, 1987 - 2016 
******************************************************
* Gross change in task content and manufacturing
reg qty_change   gross_change  manuf [w=indwts], r
estimates store e1

* Gross change in task content, manufacturing and Chinese import, Offshoring of intermediates
reg qty_change   gross_change  manuf china_exposure proxy_offshoring [w=indwts], r
estimates store e2

*********************************
* Log change in TFP, 1987 - 2016 
*********************************
* Gross change in task content and manufacturing
reg tfp_change gross_change  manuf  [w=indwts], r
estimates store e3

* Gross change in task content, manufacturing and Chinese import, Offshoring of intermediates
reg tfp_change gross_change  manuf china_exposure proxy_offshoring [w=indwts], r
estimates store e4

*********************************************
* Log change in Skill Intensity, 1990 - 2016 
*********************************************
* Gross change in task content and manufacturing
reg change_ed    gross_change  manuf  [w=indwts], r
estimates store e5

* Gross change in task content, manufacturing and Chinese import, Offshoring of intermediates
reg change_ed    gross_change  manuf china_exposure proxy_offshoring [w=indwts], r
estimates store e6

**************************************************
* Log change in prices of industries, 1987 - 2016 
**************************************************
/*Not reported to save space*/
reg price_change gross_change  manuf  [w=indwts], r

reg price_change gross_change  manuf china_exposure proxy_offshoring [w=indwts], r

* export to Table A1
estout e1 e2 e3 e4 e5 e6 using "${project}/tables/table_productivity.tex", style(tex) ///
	varlabels(gross_change "Gross change in task content of production" compindustry "Computer industry" manufacturing "Manufacturing" china_exposure "Chinese import competititon" proxy_offshoring "Offshoring of intermediates") ///
		  cells(b(nostar fmt(%9.3f)) se(par)) stats(N r2, fmt(%7.0f %7.2f) labels("Observations" "R-squared")) nolabel replace mlabels(none) collabels(none)  ///
	keep(gross_change  china_exposure proxy_offshoring manufacturing compindustry) ///
	order(gross_change  china_exposure proxy_offshoring manufacturing compindustry) 



