/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
"Automation and New Tasks: How Technology Changes Labor Demand" 
by D. Acemoglu and P. Restrepo, JEP 2019

Cleans BEA data for 1987-2017 and merges BLS and BEA data required to generate prices and quantities
Resulting panel of 61 industries based on NAICS

7.23.2018 (revised 2.21.2019)
Pascual Restrepo

revised by G. Marcolongo on 3.4.2019
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

**Import the BEA value added data**
import excel "${project}/raw_data/industry/GDPbyInd_VA_1947-2017.xlsx", sheet("VA") cellrange(A6:BU108) firstrow clear

rename B industry_bea

rename (AQ AR AS AT AU AV AW AX AY AZ BA BB BC BD BE BF BG BH BI BJ BK BL BM BN BO BP BQ BR BS BT BU) ///
       (bea_vadded1987 bea_vadded1988 bea_vadded1989 bea_vadded1990 bea_vadded1991 bea_vadded1992 bea_vadded1993 bea_vadded1994 bea_vadded1995 bea_vadded1996 bea_vadded1997 bea_vadded1998 bea_vadded1999 bea_vadded2000 bea_vadded2001  bea_vadded2002  bea_vadded2003  bea_vadded2004  bea_vadded2005 bea_vadded2006  bea_vadded2007  bea_vadded2008  bea_vadded2009  bea_vadded2010  bea_vadded2011  bea_vadded2012  bea_vadded2013  bea_vadded2014  bea_vadded2015  bea_vadded2016 bea_vadded2017)

keep Line industry_bea bea_*

**Merge industry names, descriptions and crosswalks to match other classifications. Note: only keeps 61 industries used in analysis**
replace industry_bea=ltrim(rtrim(industry_bea))
merge m:1 industry_bea using "${project}/xwalks/master_xwalk.dta", assert(1 3) keep(3) nogenerate

destring bea_*, force replace	   

save "${project}/temp_data/broad_bea.dta", replace

**Import the BEA worker compensation data**
import excel "${project}/raw_data/industry/GDPbyInd_VA_1947-2017.xlsx", sheet("Components") cellrange(A6:AF411) firstrow clear

gen industry_bea=B[_n-1] if strpos(B,"Compensation")!=0 /*keep only the line that refers to industry compensation*/

keep if industry_bea!=""

rename (C D E F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC AD AE AF) ///
       (bea_comp1987 bea_comp1988 bea_comp1989 bea_comp1990 bea_comp1991 bea_comp1992 bea_comp1993 bea_comp1994 bea_comp1995 bea_comp1996 bea_comp1997 bea_comp1998 bea_comp1999 bea_comp2000 bea_comp2001  bea_comp2002  bea_comp2003  bea_comp2004  bea_comp2005 bea_comp2006  bea_comp2007  bea_comp2008  bea_comp2009  bea_comp2010  bea_comp2011  bea_comp2012  bea_comp2013  bea_comp2014  bea_comp2015  bea_comp2016)

keep Line industry_bea bea_*

**Merge industry names, descriptions and crosswalks to match other classifications. Note: only keeps 61 industries used in analysis**
replace industry_bea=ltrim(rtrim(industry_bea))
merge m:1 industry_bea using "${project}/xwalks/master_xwalk.dta", assert(1 3) keep(3) nogenerate

destring bea_*, force replace	   

*Merge value added*
merge 1:1 industry_bea using "${project}/temp_data/broad_bea.dta", assert(3) nogenerate

save "${project}/temp_data/broad_bea.dta", replace

**Reshape**
reshape long bea_comp bea_vadded, i(industry_bea) j(year)

drop if year==2017 /*Compensation data not available for this year*/

**Declare panel**
encode industry_bea, gen(indcode)
xtset indcode year, delta(1)
sort indcode year

*Convert data to billion dollars at current prices (same as stock of capital and all variables)*
replace bea_comp=bea_comp/1000
replace bea_vadded=bea_vadded/1000

*Bring aggregates for employment, price level, population, and tfp (from FRED)*
merge m:1 year using "${project}/raw_data/aggregates/employment.dta", assert(2 3) keep(3) nogenerate
merge m:1 year using "${project}/raw_data/aggregates/population.dta", assert(2 3) keep(3) nogenerate
merge m:1 year using "${project}/raw_data/aggregates/consumer_price_pce.dta", assert(2 3) keep(3) nogenerate
merge m:1 year using "${project}/raw_data/aggregates/tfp.dta", assert(2 3) keep(3) nogenerate
merge m:1 year using "${project}/raw_data/aggregates/quantities_manuf.dta", keep(3) nogenerate

*Bring prices from BEA-KLEMS (todo)*

*Bring prices and quantities from BLS multifactor productivity dataset (used in main analysis)*
*Note: need to run "clean_bls_mfp" first*
replace industry_bls=ltrim(industry_bls)
merge m:1 industry_bls year using "${project}/temp_data/bls_capital_prices.dta", assert(3) nogenerate
merge m:1 industry_bls year using "${project}/temp_data/bls_capital_qty.dta", assert(3) nogenerate
merge m:1 industry_bls year using "${project}/temp_data/bls_labor_prices.dta", assert(3) nogenerate
merge m:1 industry_bls year using "${project}/temp_data/bls_labor_qty.dta", assert(3) nogenerate
merge m:1 industry_bls year using "${project}/temp_data/bls_labor_hours.dta", assert(3) nogenerate

**Baseline measure for R: original BLS measure---assumes R such that there are no rents left**
bys indcode: gen bls_R_full=100*(bls_R/bls_R[1])
bys indcode: gen bls_K_full=100*(bls_K_qty/bls_K_qty[1])

**Baseline measure for W: original BLS measure**
bys indcode: gen bls_W_adj=100*(bls_W/bls_W[1])
bys indcode: gen bls_L_adj=100*(bls_L_qty/bls_L_qty[1])
bys indcode: gen bls_L_unadj=100*(bls_L_hours/bls_L_hours[1])

**Robustness measure for W: wages adjusted (and unadjusted) by composition but using BEA compensation data**
bys industry_bls year: egen bea_comp_pooled=total(bea_comp) /*accounts for the fact that some industries are pooled in BLS*/
sort indcode year
bys indcode: gen bea_W_adj=100*(bea_comp_pooled/bls_L_qty)/(bea_comp_pooled[1]/bls_L_qty[1])
bys indcode: gen bea_W_unadj=100*(bea_comp_pooled/bls_L_hours)/(bea_comp_pooled[1]/bls_L_hours[1])
drop bea_comp_pooled

**Robustness measures of R using user cost formulas (prices per unit)**
*Note: need to run "clean_nipa_R" first*
merge 1:1 industry_bea year using "${project}/temp_data/nipa_capital", assert(2 3) keep(3) nogenerate 

**Robustness measures of R using quantity indices from NIPA**
gen capinc=max(bea_vadded-bea_comp,0)
sort indcode year
bys indcode: replace capinc=0.5*(f.capinc+l.capinc) if capinc==0 & f.capinc!=. & l.capinc!=.
bys indcode: gen bea_R_full=100*(capinc/nipa_capqty)/(capinc[1]/nipa_capqty[1])
bys indcode: gen bea_K_full=100*(nipa_capqty)/(nipa_capqty[1])

**Robustness measures of value added and compensation from BLS**
*Note: need to run "clean_bls_mfp.do" first*
merge m:1 industry_bls year using "${project}/temp_data/bls_labor_inc.dta", assert(3) nogenerate
merge m:1 industry_bls year using "${project}/temp_data/bls_capital_inc.dta", assert(3) nogenerate
*Apportionate BLS values as to avoid double counting*
bys industry_bls year: replace bls_L_inc=bls_L_inc/_N
bys industry_bls year: replace bls_K_inc=bls_K_inc/_N

**Order variables**
keep indcode year  industry_bea industry_bls industry_ifr sector sector_01 manufacturing  bea_vadded bea_comp bls_R_full bls_K_full bls_W_adj bls_L_adj bls_L_unadj bea_W_adj bea_W_unadj nipa_* bea_R_full bea_K_full bls_L_inc bls_K_inc employment_us population_us price_us tfp_us qty_manuf
order indcode year industry_bea industry_bls industry_ifr sector sector_01 manufacturing  bea_vadded bea_comp bls_R_full bls_K_full bls_W_adj bls_L_adj bls_L_unadj bea_W_adj bea_W_unadj nipa_* bea_R_full bea_K_full bls_L_inc bls_K_inc employment_us population_us price_us tfp_us qty_manuf

*sort and save*
sort indcode year
save "${project}/clean_data/panel_beaNAICS.dta", replace





