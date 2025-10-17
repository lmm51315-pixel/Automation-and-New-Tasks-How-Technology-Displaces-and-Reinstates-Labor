/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
"Automation and New Tasks: How Technology Changes Labor Demand" 
by D. Acemoglu and P. Restrepo, JEP 2019


Cleans BEA data for 1947-1987  and merges BEA data required to generate prices and quantities
Resulting panel of 43 industries based on SIC72

7.23.2018 (revised 2.21.2019)
Pascual Restrepo

revised by G. Marcolongo on 4.3.2019
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

**Import the value added data 1947-1987, SIC72**
import excel "${project}/raw_data/industry/GDPbyInd_VA_SIC.xls", sheet("72SIC_VA, GO, II") cellrange(A1:AQ91) firstrow clear

rename IndustryTitle industry_bea72

rename (C D E F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC AD AE AF AG AH AI AJ AK AL AM AN AO AP AQ) ///
       (bea72_vadded1947	bea72_vadded1948	bea72_vadded1949	bea72_vadded1950	bea72_vadded1951	bea72_vadded1952	bea72_vadded1953	bea72_vadded1954	bea72_vadded1955	bea72_vadded1956	bea72_vadded1957	bea72_vadded1958	bea72_vadded1959	bea72_vadded1960	bea72_vadded1961	bea72_vadded1962	bea72_vadded1963	bea72_vadded1964	bea72_vadded1965	bea72_vadded1966	bea72_vadded1967	bea72_vadded1968	bea72_vadded1969	bea72_vadded1970	bea72_vadded1971	bea72_vadded1972	bea72_vadded1973	bea72_vadded1974	bea72_vadded1975	bea72_vadded1976	bea72_vadded1977	bea72_vadded1978	bea72_vadded1979	bea72_vadded1980	bea72_vadded1981	bea72_vadded1982	bea72_vadded1983	bea72_vadded1984	bea72_vadded1985	bea72_vadded1986	bea72_vadded1987)

keep industry_bea bea72_* 

**Merge industry names, descriptions and crosswalks to match other classifications. Note: only keeps 59 industries used in analysis**
merge m:1 industry_bea72 using "${project}/xwalks/sic72_xwalk.dta", keep(3) nogenerate keepusing(industry_bea72)

assert _N==59

destring bea72_*, force replace	   

save "${project}/temp_data/broad_bea72.dta", replace

**Import the worker compensation data**
import excel "${project}/raw_data/industry/GDPbyInd_VA_SIC.xls", sheet("72SIC_Components of VA") cellrange(A1:AQ89) firstrow clear

rename IndustryTitle industry_bea72

rename (C D E F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC AD AE AF AG AH AI AJ AK AL AM AN AO AP AQ) ///
       (bea72_comp1947	bea72_comp1948	bea72_comp1949	bea72_comp1950	bea72_comp1951	bea72_comp1952	bea72_comp1953	bea72_comp1954	bea72_comp1955	bea72_comp1956	bea72_comp1957	bea72_comp1958	bea72_comp1959	bea72_comp1960	bea72_comp1961	bea72_comp1962	bea72_comp1963	bea72_comp1964	bea72_comp1965	bea72_comp1966	bea72_comp1967	bea72_comp1968	bea72_comp1969	bea72_comp1970	bea72_comp1971	bea72_comp1972	bea72_comp1973	bea72_comp1974	bea72_comp1975	bea72_comp1976	bea72_comp1977	bea72_comp1978	bea72_comp1979	bea72_comp1980	bea72_comp1981	bea72_comp1982	bea72_comp1983	bea72_comp1984	bea72_comp1985	bea72_comp1986	bea72_comp1987)

keep industry_bea bea72_* 

**Merge industry names, descriptions and crosswalks to match other classifications. Note: only keeps 59 industries used in analysis**
merge m:1 industry_bea72 using "${project}/xwalks/sic72_xwalk.dta", keep(3) nogenerate keepusing(industry_bea72)

assert _N==59

destring bea72_*, force replace	   

*Merge value added*
merge 1:1 industry_bea72 using "${project}/temp_data/broad_bea72.dta", assert(3) nogenerate

save "${project}/temp_data/broad_bea72.dta", replace

**Import employment**
import excel "${project}/raw_data/industry/GDPbyInd_VA_SIC.xls", sheet("72SIC_Employment") cellrange(A1:AQ180) firstrow clear

keep if Code=="FTE"

rename IndustryTitle industry_bea72

rename (C D E F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC AD AE AF AG AH AI AJ AK AL AM AN AO AP AQ) ///
       (bea72_employment1947	bea72_employment1948	bea72_employment1949	bea72_employment1950	bea72_employment1951	bea72_employment1952	bea72_employment1953	bea72_employment1954	bea72_employment1955	bea72_employment1956	bea72_employment1957	bea72_employment1958	bea72_employment1959	bea72_employment1960	bea72_employment1961	bea72_employment1962	bea72_employment1963	bea72_employment1964	bea72_employment1965	bea72_employment1966	bea72_employment1967	bea72_employment1968	bea72_employment1969	bea72_employment1970	bea72_employment1971	bea72_employment1972	bea72_employment1973	bea72_employment1974	bea72_employment1975	bea72_employment1976	bea72_employment1977	bea72_employment1978	bea72_employment1979	bea72_employment1980	bea72_employment1981	bea72_employment1982	bea72_employment1983	bea72_employment1984	bea72_employment1985	bea72_employment1986	bea72_employment1987)

keep industry_bea bea72_* 

destring bea72_*, force replace

*Fix social services and membership organizations by imputing them back in time using the 645 to 1335 proportion*
forvalues year=1948(1)1974{
egen total_`year'=total(bea72_employment`year'*(industry_bea72=="            Social services and membership organizations"))
replace bea72_employment`year'=(645/(645+1335))*total_`year' if industry_bea72=="               Social services"
replace bea72_employment`year'=(1335/(645+1335))*total_`year' if industry_bea72=="               Membership organizations"
drop total_`year'
}
replace industry_bea72="            Social services" if industry_bea72=="               Social services" 
replace industry_bea72="            Membership organizations" if industry_bea72=="               Membership organizations" 

*Impute 1947*
replace bea72_employment1947=bea72_employment1948*144.1/146.6

**Merge industry names, descriptions and crosswalks to match other classifications. Note: only keeps 61 industries used in analysis**
merge m:1 industry_bea72 using "${project}/xwalks/sic72_xwalk.dta", keep(3) nogenerate 

assert _N==59	   

*Merge value added and compensation*
merge 1:1 industry_bea72 using "${project}/temp_data/broad_bea72.dta", assert(3) nogenerate

save "${project}/temp_data/broad_bea72.dta", replace

**Reshape**
reshape long bea72_comp bea72_vadded bea72_employment, i(industry_bea72) j(year)

**Aggregate to 43 consolidated industries that we can match to NIPA**
replace industry_bea72=ltrim(rtrim(industry_bea72))
preserve
use "${project}/xwalks/consolidate_nipa.dta", clear
duplicates drop industry_bea72, force
keep if industry_bea72!=""
keep industry_bea72 industry_cons
tempfile xwalk_72
save `xwalk_72', replace
restore
merge m:1 industry_bea72 using `xwalk_72', assert(3) keep(3) nogenerate
collapse (sum) bea72_* (firstnm) manufacturing sector, by(industry_consolidated year)

**Declare panel and save**
encode industry_consolidated, gen(indcode)
sort industry_consolidated year
xtset indcode year

*Convert data to billion dollars at current prices*
replace bea72_comp=bea72_comp/1000
replace bea72_vadded=bea72_vadded/1000

*Bring aggregates for employment, price level, population, and tfp (from FRED)*
merge m:1 year using "${project}/raw_data/aggregates/employment.dta", keep(1 3) nogenerate
*Impute employment for 1947 based on population growth*
sort indcode year
bys indcode: replace employment_us=employment_us[2]*144.1/146.6 if year==1947
merge m:1 year using "${project}/raw_data/aggregates/population.dta", assert(2 3) keep(3) nogenerate
merge m:1 year using "${project}/raw_data/aggregates/consumer_price_pce.dta", assert(2 3) keep(3) nogenerate
merge m:1 year using "${project}/raw_data/aggregates/tfp.dta", assert(2 3) keep(3) nogenerate
merge m:1 year using "${project}/raw_data/aggregates/quantities_manuf.dta", keep(3) nogenerate

*Bring prices and quantities from NIPA fixed-assets tables*
*Note: need to run "clean_nipa_R" first*
preserve
use "${project}/xwalks/consolidate_nipa.dta", clear
duplicates drop industry_bea, force
keep if industry_bea!=""
keep industry_bea industry_cons
tempfile xwalk_bea
save `xwalk_bea', replace
use "${project}/temp_data/nipa_capital", clear
replace industry_bea=ltrim(rtrim(industry_bea))
merge m:1 industry_bea using `xwalk_bea', assert(3) keep(3) nogenerate
collapse (rawsum) nipa_capvalue (mean) nipa_PK_nom nipa_PK_real nipa_delta nipa_capqty nipa_R_jorg* [w=nipa_capvalue], by(industry_consolidated year)
tempfile nipa
save `nipa'
restore

*Merge NIPA data*
merge 1:1 industry_consolidated year using `nipa', assert(2 3) keep(3) nogenerate

**Baseline measure for R: extension of BLS measure based on NIPA quantity indices---assumes R such that there are no rents left**
gen capinc=max(bea72_vadded-bea72_comp,0)
sort indcode year
bys indcode: replace capinc=0.5*(f.capinc+l.capinc) if capinc==0 & f.capinc!=. & l.capinc!=.
bys indcode: gen bea72_R_full=100*(capinc/nipa_capqty)/(capinc[1]/nipa_capqty[1])
bys indcode: gen bea72_K_full=100*(nipa_capqty)/(nipa_capqty[1])

**Baseline measure for W: unadjusted wages**
bys indcode: gen bea72_W_unadj=100*(bea72_comp/bea72_employment)/(bea72_comp[1]/bea72_employment[1])
bys indcode: gen bea72_L_unadj=100*(bea72_employment)/(bea72_employment[1])

**Order variables**
keep indcode year  industry_consolidated sector manufacturing  bea72_vadded bea72_comp bea72_R_full bea72_K_full bea72_W_unadj bea72_L_unadj nipa_*  employment_us population_us price_us tfp_us qty_manuf
order indcode year industry_consolidated sector manufacturing  bea72_vadded bea72_comp bea72_R_full bea72_K_full bea72_W_unadj bea72_L_unadj nipa_*  employment_us population_us price_us tfp_us qty_manuf

*sort and save*
sort indcode year
save "${project}/clean_data/panel_bea72.dta", replace
