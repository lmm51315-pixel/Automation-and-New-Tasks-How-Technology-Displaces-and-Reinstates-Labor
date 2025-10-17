/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
"Automation and New Tasks: How Technology Changes Labor Demand" 
by D. Acemoglu and P. Restrepo, JEP 2019

Cleans BEA data for 1987-2017 for prices and quantities
7.23.2018 (revised 2.21.2019)
Pascual Restrepo

revised by G. Marcolongo on 3.4.2019
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

**Import the price data**
import excel "${project}/raw_data/industry/GDPbyInd_VA_1947-2017.xlsx", sheet("ChainPriceIndexes") cellrange(A6:BU108) firstrow clear
rename B industry_bea
rename (AQ AR AS AT AU AV AW AX AY AZ BA BB BC BD BE BF BG BH BI BJ BK BL BM BN BO BP BQ BR BS BT BU) ///
       (bea_price1987 bea_price1988 bea_price1989 bea_price1990 bea_price1991 bea_price1992 bea_price1993 bea_price1994 bea_price1995 bea_price1996 bea_price1997 bea_price1998 bea_price1999 bea_price2000 bea_price2001  bea_price2002  bea_price2003  bea_price2004  bea_price2005 bea_price2006  bea_price2007  bea_price2008  bea_price2009  bea_price2010  bea_price2011  bea_price2012  bea_price2013  bea_price2014  bea_price2015  bea_price2016 bea_price2017)
destring bea_price*, force replace
gen price_change=100*(ln(bea_price2016)-ln(bea_price1987))
keep Line industry_bea price_change
replace industry_bea=ltrim(rtrim(industry_bea))
merge m:1 industry_bea using "${project}/xwalks/master_xwalk.dta", assert(1 3) keep(3) nogenerate
save "${project}/clean_data/price_bea.dta", replace

**Import the quantity data**
import excel "${project}/raw_data/industry/GDPbyInd_VA_1947-2017.xlsx", sheet("ChainQtyIndexes") cellrange(A6:BU108) firstrow clear
rename B industry_bea
rename (AQ AR AS AT AU AV AW AX AY AZ BA BB BC BD BE BF BG BH BI BJ BK BL BM BN BO BP BQ BR BS BT BU) ///
       (bea_qty1987 bea_qty1988 bea_qty1989 bea_qty1990 bea_qty1991 bea_qty1992 bea_qty1993 bea_qty1994 bea_qty1995 bea_qty1996 bea_qty1997 bea_qty1998 bea_qty1999 bea_qty2000 bea_qty2001  bea_qty2002  bea_qty2003  bea_qty2004  bea_qty2005 bea_qty2006  bea_qty2007  bea_qty2008  bea_qty2009  bea_qty2010  bea_qty2011  bea_qty2012  bea_qty2013  bea_qty2014  bea_qty2015  bea_qty2016 bea_qty2017)
destring bea_qty*, force replace
gen qty_change=100*(ln(bea_qty2016)-ln(bea_qty1987))
keep Line industry_bea qty_change
replace industry_bea=ltrim(rtrim(industry_bea))
merge m:1 industry_bea using "${project}/xwalks/master_xwalk.dta", assert(1 3) keep(3) nogenerate
save "${project}/clean_data/qty_bea.dta", replace

*Value added QI*
import excel "$project/raw_data/bea_klems/BEA-BLS-industry-level-production-account-1987-1998.xlsx", sheet("Integrated MFP Index") cellrange(A2:M65) firstrow clear
rename (B C D E F G H I J K L M) (var1987 var1988 var1989 var1990 var1991 var1992 var1993 var1994 var1995 var1996 var1997 var1998)
reshape long var, i(Industry) j(year)
rename var bea_klems_tfp
replace year=1997.5 if year==1998
tempfile klems87
save `klems87', replace

*Value added QI*
import excel "$project/raw_data/bea_klems/BEA-BLS-industry-level-production-account-1998-2016.xlsx", sheet("Integrated MFP Index") cellrange(A2:T65) firstrow clear
rename (B C D E F G H I J K L M N O P Q R S T) (var1998 var1999 var2000 var2001 var2002 var2003 var2004 var2005 var2006 var2007 var2008 var2009 var2010 var2011 var2012 var2013 var2014 var2015 var2016)
reshape long var, i(Industry) j(year)
rename var bea_klems_tfp
tempfile klems98
save `klems98', replace

*Append*
append using `klems87'
*Cleaning*
rename Industry industry_bea
replace industry_bea=ltrim(rtrim(industry_bea))

*Check series match*
sort industry_bea year
foreach var of varlist bea_klems_*{
bys industry_bea: assert `var'[12]==`var'[13]
}
drop if year==1997.5

*Remove Industries not in analysis*
drop if industry_bea=="Federal"
drop if industry_bea=="State and local"

reshape wide bea_klems_tfp, i(industry_bea) j(year)
gen tfp_change=100*(ln(bea_klems_tfp2016)-ln(bea_klems_tfp1987))
keep industry_bea tfp_change
save "${project}/clean_data/tfp_bea.dta", replace
