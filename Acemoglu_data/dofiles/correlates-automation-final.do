/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

"Automation and New Tasks: How Technology Changes Labor Demand" 
by D. Acemoglu and P. Restrepo, JEP 2019

7.31.208
Pascual Restrepo

This do file:
- computes the first three sets of coefficients of Table 1:
	Relationship between change in task content of production and proxies of automation technologies
- generates Figure A4: 
	Automation Technologies, Offshoring, and Changes in the Task Content of production

(revised by G. Marcolongo 3.1.2019)
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

use "${project}/clean_data/census_characteristics_BEA.dta", clear // dataset created in clean_census_industry_xs.do (inside "cleaners" folder)
merge 1:1 industry_bea using "${project}/clean_data/industry_contribution_sigma_${sigma}.dta", assert(2 3) nogenerate // created in decomposition 1987 - 2017 (includes task_content, displacement and reinstatement effect and respective weights)
replace manufacturing=0 if manufacturing==.
gen indname=industry_bea

*Write down task content in log points*
replace task_content_i=100*task_content_i

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
merge 1:1 industry_bea using "${project}/clean_data/FH_offshoring_bea", assert(1 3) nogenerate // created from cleaners/clean_offshoring.do
gen fh_offshoring=0
replace fh_offshoring=increase_offs if manuf==1
gen proxy_offshoring=fh_offshoring

***********************************************************************************
*Model 1: Adjusted penetration of robots and Change in task content of production *
**********************************************************************************

* Figure A4, panel 1 and First set of coefficients in Table 1
analyze_var_jep task_content apr_93_14 [w=indwts], cluster(industry_ifr) xname("Adjusted penetration of robots, 1993-2014") yname("Change in task content of production, 1987-2017")

******************************************************************************************************
*Model 2: Share of routine occupations in an industry in 1990 and Change in task content of production **
******************************************************************************************************

* Figure A4, panel 2 and Second set of coefficients in Table 1
replace task_middle=100*task_middle
analyze_var_jep task_content task_middle [w=indwts], xname("Share of routine jobs in industry, 1990") yname("Change in task content of production, 1987-2017")

*Test together (not reported in the paper)*
reg  task_content apr_93_14 task_middle  manuf china_exposure fh_offshoring [w=indwts], r
reg  task_content apr_93_14 task_middle  manuf china_exposure fh_offshoring [w=indwts] if manuf==0, r
reg  task_content apr_93_14 task_middle  manuf china_exposure fh_offshoring [w=indwts] if manuf==1, r

********************************************************************************************************************
*Model 3: Role of offshoring and Change in task content of production and Change in task content of production *****
********************************************************************************************************************
* Figure A4, panel 4 
analyze_var_jep task_content fh_offshoring [w=indwts], cluster(industry_ifr) xname("Exposure to intermediate imports (% of total intermediates), 1993-2007") yname("Change in task content of production, 1987-2017")

********************************************************************************************************
*Model 4: Share of firms with automation technologies from SMT and Change in task content of production ***
********************************************************************************************************
**Detailed manufacturing sample and SMT**
use "${project}/clean_data/beaio_smt.dta", clear // created in cleaners/clean_smt.do
gen indname=sic87dd
gen manuf=1

*Control for China*
merge 1:1 sic87dd using "${project}/clean_data/china-sag_sic87dd", assert(2 3) keep(3) nogenerate
merge 1:1 sic87dd using "${project}/clean_data/FH_offshoring_sic87dd", keep(1 3) nogenerate // created from cleaners/clean_offshoring.do
gen china_exposure=d_import_otch_1991_2011
gen proxy_offshoring=increase_offshoring

**Define narrow measures of automation**
foreach yr in 1988 1993{
egen automsh_`yr'=rowmean(share_agv_`yr' share_as1_`yr' share_asr_`yr' share_cad2_`yr' share_cc4_`yr' share_cnc_`yr' share_fmc_`yr' share_otr_`yr' share_ppr_`yr')
egen automnarrow_`yr'=rowmean(share_as1_`yr' share_asr_`yr'  share_cnc_`yr' share_otr_`yr' share_ppr_`yr')
egen robotsh_`yr'=rowmean(share_otr_`yr' share_ppr_`yr')
}

*average over surveys (paper reports results for automsh)*
egen smtshare_mean=rowmean(smtshare_*)
egen automnarrow_mean=rowmean(automnarrow_*)
egen automsh_mean=rowmean(automsh_*)
egen robotsh_mean=rowmean(robotsh_*)

**Generate task content**
forvalues year=1977(5)2007{
gen nber_K_`year'=(cap`year')
gen nber_L_unadj_`year'=(emp`year')
gen share_prod`year'=prodw`year'/pay`year'
gen nber_L_adj_`year'=(emp`year'^(1-share_prod`year')*prode`year'^(share_prod`year'))
}

**********************************************************************************************************************************
***Estimates for shift in task content (uses alternative formula A20 in terms of quantities provided in the appendix - p. A16) ***
**********************************************************************************************************************************
*Shift from 1987 to 2007*
gen task_content_1987=100*${sigma}*(ln(beaCP_labsh2007)-ln(beaCP_labsh1987)) ///
                     +100*(1-beaCP_labsh1987)*(1-${sigma})*(ln(nber_L_adj_2007/nber_L_adj_1987)-ln(nber_K_2007/nber_K_1987)) ///
					 +100*(1-beaCP_labsh1987)*(1-${sigma})*20*${growth_rate_1987_2017}

					 
reg task_content_1987 increase_offshoring china [w=beaCP_comp1987]					 

keep if smt_sample==1 // industries included in the Survey of Manufacturing Technologies

* Figure A4, panel 3 and Third set of coefficients in Table 1:
analyze_var_jep task_content_1987 automsh_mean [w=beaCP_comp1987], xname("Share of firms using automation technologies, 1988-1993") yname("Change in task content of production, 1987-2007")

* Using alternative measures for Share of firms using advanced technoglogies:
analyze_var_jep task_content_1987 smtshare_mean [w=beaCP_comp1987], xname("Share firms using advanced technologies, 1988-1993") yname("Change in task content of production, 1987-2007")
analyze_var_jep task_content_1987 automnarrow_mean [w=beaCP_comp1987], xname("Share firms using narrow set of automation technologies, 1988-1993") yname("Change in task content of production, 1987-2007")
analyze_var_jep task_content_1987 robotsh_mean [w=beaCP_comp1987], xname("Share firms using robotic technologies, 1988-1993") yname("Change in task content of production, 1987-2007")





