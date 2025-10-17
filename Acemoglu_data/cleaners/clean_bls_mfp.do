/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
Automation and New Tasks: How Technology Changes Labor Demand" 
by D. Acemoglu and P. Restrepo, JEP 2019

Cleans BLS multifactor productivity data for 1987-2016

Saves series for:
	Capital and labor prices (indices in current dollars)
	Capital and labor quantities (indices)
	Capital and labor values (current dollars)
	Labor quantities (not adjusted for composition)
	
7.23.2018 (revised 2.22.2019)
Pascual Restrepo

revised by G. Marcolongo 3.4.2019
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

****************************
******Data for capital******
****************************

**1a. Capital R in manufacturing**
import excel "${project}/raw_data/industry/klemsmfpbymeasure.xlsx", sheet("2-12.2") cellrange(A7:AF28) firstrow clear
rename (C D E F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC AD AE AF) ///
       (bls_R1987 bls_R1988 bls_R1989 bls_R1990 bls_R1991 bls_R1992 bls_R1993 bls_R1994 bls_R1995 bls_R1996 bls_R1997 bls_R1998 bls_R1999 bls_R2000 bls_R2001  bls_R2002  bls_R2003  bls_R2004  bls_R2005 bls_R2006  bls_R2007  bls_R2008  bls_R2009  bls_R2010  bls_R2011  bls_R2012  bls_R2013  bls_R2014  bls_R2015  bls_R2016)
drop if SectororIndustryTitle=="Manufacturing Sector"
drop if SectororIndustryTitle==" Non-Durable Manufacturing Sector"
drop if SectororIndustryTitle==" Durable Manufactoring Sector"
rename  SectororIndustryTitle industry_bls
tempfile capital_price_manuf
save `capital_price_manuf'

**1b. Capital R in non-manufacturing**
import excel "${project}/raw_data/industry/klemsmfpxgbymeasure.xlsx", sheet("2-12.2") cellrange(A7:AF56) firstrow clear
rename (C D E F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC AD AE AF) ///
       (bls_R1987 bls_R1988 bls_R1989 bls_R1990 bls_R1991 bls_R1992 bls_R1993 bls_R1994 bls_R1995 bls_R1996 bls_R1997 bls_R1998 bls_R1999 bls_R2000 bls_R2001  bls_R2002  bls_R2003  bls_R2004  bls_R2005 bls_R2006  bls_R2007  bls_R2008  bls_R2009  bls_R2010  bls_R2011  bls_R2012  bls_R2013  bls_R2014  bls_R2015  bls_R2016)
drop if SectororIndustryTitle=="Agriculture, Forestry, and Fishery"
drop if SectororIndustryTitle=="Mining"
drop if SectororIndustryTitle=="Trade"
drop if SectororIndustryTitle=="Transportation and Warehousing"
drop if SectororIndustryTitle=="Information"
drop if SectororIndustryTitle=="Finance, Insurance, and Real Estate"
drop if SectororIndustryTitle=="Services"
rename  SectororIndustryTitle industry_bls
append using `capital_price_manuf'

reshape long bls_R, i(industry_bls) j(year)
drop NAICS
replace industry_bls=ltrim(industry_bls)
save "${project}/temp_data/bls_capital_prices.dta", replace

**2a. Capital qty in manufacturing**
import excel "${project}/raw_data/industry/klemsmfpbymeasure.xlsx", sheet("1-2.2") cellrange(A7:AF28) firstrow clear
rename (C D E F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC AD AE AF) ///
       (bls_K_qty1987 bls_K_qty1988 bls_K_qty1989 bls_K_qty1990 bls_K_qty1991 bls_K_qty1992 bls_K_qty1993 bls_K_qty1994 bls_K_qty1995 bls_K_qty1996 bls_K_qty1997 bls_K_qty1998 bls_K_qty1999 bls_K_qty2000 bls_K_qty2001  bls_K_qty2002  bls_K_qty2003  bls_K_qty2004  bls_K_qty2005 bls_K_qty2006  bls_K_qty2007  bls_K_qty2008  bls_K_qty2009  bls_K_qty2010  bls_K_qty2011  bls_K_qty2012  bls_K_qty2013  bls_K_qty2014  bls_K_qty2015  bls_K_qty2016)
drop if SectororIndustryTitle=="Manufacturing Sector"
drop if SectororIndustryTitle==" Non-Durable Manufacturing Sector"
drop if SectororIndustryTitle==" Durable Manufactoring Sector"
rename  SectororIndustryTitle industry_bls
tempfile capital_qty_manuf
save `capital_qty_manuf'

**2b. Capital qty in non-manufacturing**
import excel "${project}/raw_data/industry/klemsmfpxgbymeasure.xlsx", sheet("1-2.2") cellrange(A7:AF56) firstrow clear
rename (C D E F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC AD AE AF) ///
       (bls_K_qty1987 bls_K_qty1988 bls_K_qty1989 bls_K_qty1990 bls_K_qty1991 bls_K_qty1992 bls_K_qty1993 bls_K_qty1994 bls_K_qty1995 bls_K_qty1996 bls_K_qty1997 bls_K_qty1998 bls_K_qty1999 bls_K_qty2000 bls_K_qty2001  bls_K_qty2002  bls_K_qty2003  bls_K_qty2004  bls_K_qty2005 bls_K_qty2006  bls_K_qty2007  bls_K_qty2008  bls_K_qty2009  bls_K_qty2010  bls_K_qty2011  bls_K_qty2012  bls_K_qty2013  bls_K_qty2014  bls_K_qty2015  bls_K_qty2016)
drop if SectororIndustryTitle=="Agriculture, Forestry, and Fishery"
drop if SectororIndustryTitle=="Mining"
drop if SectororIndustryTitle=="Trade"
drop if SectororIndustryTitle=="Transportation and Warehousing"
drop if SectororIndustryTitle=="Information"
drop if SectororIndustryTitle=="Finance, Insurance, and Real Estate"
drop if SectororIndustryTitle=="Services"
rename  SectororIndustryTitle industry_bls
append using `capital_qty_manuf'

reshape long bls_K_qty, i(industry_bls) j(year)
drop NAICS
replace industry_bls=ltrim(industry_bls)
save "${project}/temp_data/bls_capital_qty.dta", replace

**3a. Capital income in manufacturing**
import excel "${project}/raw_data/industry/klemsmfpbymeasure.xlsx", sheet("4-26.1") cellrange(A6:AF27) firstrow clear
rename (C D E F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC AD AE AF) ///
       (bls_K_inc1987 bls_K_inc1988 bls_K_inc1989 bls_K_inc1990 bls_K_inc1991 bls_K_inc1992 bls_K_inc1993 bls_K_inc1994 bls_K_inc1995 bls_K_inc1996 bls_K_inc1997 bls_K_inc1998 bls_K_inc1999 bls_K_inc2000 bls_K_inc2001  bls_K_inc2002  bls_K_inc2003  bls_K_inc2004  bls_K_inc2005 bls_K_inc2006  bls_K_inc2007  bls_K_inc2008  bls_K_inc2009  bls_K_inc2010  bls_K_inc2011  bls_K_inc2012  bls_K_inc2013  bls_K_inc2014  bls_K_inc2015  bls_K_inc2016)
drop if SectororIndustryTitle=="Manufacturing Sector"
drop if SectororIndustryTitle==" Non-Durable Manufacturing Sector"
drop if SectororIndustryTitle==" Durable Manufactoring Sector"
rename  SectororIndustryTitle industry_bls
tempfile capital_inc_manuf
save `capital_inc_manuf'

**3b. Capital income in non-manufacturing**
import excel "${project}/raw_data/industry/klemsmfpxgbymeasure.xlsx", sheet("4-26.1") cellrange(A6:AF55) firstrow clear
rename (C D E F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC AD AE AF) ///
       (bls_K_inc1987 bls_K_inc1988 bls_K_inc1989 bls_K_inc1990 bls_K_inc1991 bls_K_inc1992 bls_K_inc1993 bls_K_inc1994 bls_K_inc1995 bls_K_inc1996 bls_K_inc1997 bls_K_inc1998 bls_K_inc1999 bls_K_inc2000 bls_K_inc2001  bls_K_inc2002  bls_K_inc2003  bls_K_inc2004  bls_K_inc2005 bls_K_inc2006  bls_K_inc2007  bls_K_inc2008  bls_K_inc2009  bls_K_inc2010  bls_K_inc2011  bls_K_inc2012  bls_K_inc2013  bls_K_inc2014  bls_K_inc2015  bls_K_inc2016)
drop if SectororIndustryTitle=="Agriculture, Forestry, and Fishery"
drop if SectororIndustryTitle=="Mining"
drop if SectororIndustryTitle=="Trade"
drop if SectororIndustryTitle=="Transportation and Warehousing"
drop if SectororIndustryTitle=="Information"
drop if SectororIndustryTitle=="Finance, Insurance, and Real Estate"
drop if SectororIndustryTitle=="Services"
rename  SectororIndustryTitle industry_bls
append using `capital_inc_manuf'

reshape long bls_K_inc, i(industry_bls) j(year)
drop NAICS
replace industry_bls=ltrim(industry_bls)
save "${project}/temp_data/bls_capital_inc.dta", replace

****************************
*******Data for labor*******
****************************

**1a. Labor W in manufacturing**
import excel "${project}/raw_data/industry/klemsmfpbymeasure.xlsx", sheet("2-13.2") cellrange(A7:AF28) firstrow clear
rename (C D E F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC AD AE AF) ///
       (bls_W1987 bls_W1988 bls_W1989 bls_W1990 bls_W1991 bls_W1992 bls_W1993 bls_W1994 bls_W1995 bls_W1996 bls_W1997 bls_W1998 bls_W1999 bls_W2000 bls_W2001  bls_W2002  bls_W2003  bls_W2004  bls_W2005 bls_W2006  bls_W2007  bls_W2008  bls_W2009  bls_W2010  bls_W2011  bls_W2012  bls_W2013  bls_W2014  bls_W2015  bls_W2016)
drop if SectororIndustryTitle=="Manufacturing Sector"
drop if SectororIndustryTitle==" Non-Durable Manufacturing Sector"
drop if SectororIndustryTitle==" Durable Manufactoring Sector"
rename  SectororIndustryTitle industry_bls
tempfile labor_price_manuf
save `labor_price_manuf'

**1b. Labor W in non-manufacturing**
import excel "${project}/raw_data/industry/klemsmfpxgbymeasure.xlsx", sheet("2-13.2") cellrange(A7:AF56) firstrow clear
rename (C D E F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC AD AE AF) ///
       (bls_W1987 bls_W1988 bls_W1989 bls_W1990 bls_W1991 bls_W1992 bls_W1993 bls_W1994 bls_W1995 bls_W1996 bls_W1997 bls_W1998 bls_W1999 bls_W2000 bls_W2001  bls_W2002  bls_W2003  bls_W2004  bls_W2005 bls_W2006  bls_W2007  bls_W2008  bls_W2009  bls_W2010  bls_W2011  bls_W2012  bls_W2013  bls_W2014  bls_W2015  bls_W2016)
drop if SectororIndustryTitle=="Agriculture, Forestry, and Fishery"
drop if SectororIndustryTitle=="Mining"
drop if SectororIndustryTitle=="Trade"
drop if SectororIndustryTitle=="Transportation and Warehousing"
drop if SectororIndustryTitle=="Information"
drop if SectororIndustryTitle=="Finance, Insurance, and Real Estate"
drop if SectororIndustryTitle=="Services"
rename  SectororIndustryTitle industry_bls
append using `labor_price_manuf'

reshape long bls_W, i(industry_bls) j(year)
drop NAICS
replace industry_bls=ltrim(industry_bls)
save "${project}/temp_data/bls_labor_prices.dta", replace

**2a. Labor qty in manufacturing**
import excel "${project}/raw_data/industry/klemsmfpbymeasure.xlsx", sheet("1-3.2") cellrange(A7:AF28) firstrow clear
rename (C D E F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC AD AE AF) ///
       (bls_L_qty1987 bls_L_qty1988 bls_L_qty1989 bls_L_qty1990 bls_L_qty1991 bls_L_qty1992 bls_L_qty1993 bls_L_qty1994 bls_L_qty1995 bls_L_qty1996 bls_L_qty1997 bls_L_qty1998 bls_L_qty1999 bls_L_qty2000 bls_L_qty2001  bls_L_qty2002  bls_L_qty2003  bls_L_qty2004  bls_L_qty2005 bls_L_qty2006  bls_L_qty2007  bls_L_qty2008  bls_L_qty2009  bls_L_qty2010  bls_L_qty2011  bls_L_qty2012  bls_L_qty2013  bls_L_qty2014  bls_L_qty2015  bls_L_qty2016)
drop if SectororIndustryTitle=="Manufacturing Sector"
drop if SectororIndustryTitle==" Non-Durable Manufacturing Sector"
drop if SectororIndustryTitle==" Durable Manufactoring Sector"
rename  SectororIndustryTitle industry_bls
tempfile labor_qty_manuf
save `labor_qty_manuf'

**2b. Labor qty in non-manufacturing**
import excel "${project}/raw_data/industry/klemsmfpxgbymeasure.xlsx", sheet("1-3.2") cellrange(A7:AF56) firstrow clear
rename (C D E F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC AD AE AF) ///
       (bls_L_qty1987 bls_L_qty1988 bls_L_qty1989 bls_L_qty1990 bls_L_qty1991 bls_L_qty1992 bls_L_qty1993 bls_L_qty1994 bls_L_qty1995 bls_L_qty1996 bls_L_qty1997 bls_L_qty1998 bls_L_qty1999 bls_L_qty2000 bls_L_qty2001  bls_L_qty2002  bls_L_qty2003  bls_L_qty2004  bls_L_qty2005 bls_L_qty2006  bls_L_qty2007  bls_L_qty2008  bls_L_qty2009  bls_L_qty2010  bls_L_qty2011  bls_L_qty2012  bls_L_qty2013  bls_L_qty2014  bls_L_qty2015  bls_L_qty2016)
drop if SectororIndustryTitle=="Agriculture, Forestry, and Fishery"
drop if SectororIndustryTitle=="Mining"
drop if SectororIndustryTitle=="Trade"
drop if SectororIndustryTitle=="Transportation and Warehousing"
drop if SectororIndustryTitle=="Information"
drop if SectororIndustryTitle=="Finance, Insurance, and Real Estate"
drop if SectororIndustryTitle=="Services"
rename  SectororIndustryTitle industry_bls
append using `labor_qty_manuf'

reshape long bls_L_qty, i(industry_bls) j(year)
drop NAICS
replace industry_bls=ltrim(industry_bls)
save "${project}/temp_data/bls_labor_qty.dta", replace

**3a. Labor income in manufacturing**
import excel "${project}/raw_data/industry/klemsmfpbymeasure.xlsx", sheet("4-27.1") cellrange(A6:AF27) firstrow clear
rename (C D E F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC AD AE AF) ///
       (bls_L_inc1987 bls_L_inc1988 bls_L_inc1989 bls_L_inc1990 bls_L_inc1991 bls_L_inc1992 bls_L_inc1993 bls_L_inc1994 bls_L_inc1995 bls_L_inc1996 bls_L_inc1997 bls_L_inc1998 bls_L_inc1999 bls_L_inc2000 bls_L_inc2001  bls_L_inc2002  bls_L_inc2003  bls_L_inc2004  bls_L_inc2005 bls_L_inc2006  bls_L_inc2007  bls_L_inc2008  bls_L_inc2009  bls_L_inc2010  bls_L_inc2011  bls_L_inc2012  bls_L_inc2013  bls_L_inc2014  bls_L_inc2015  bls_L_inc2016)
drop if SectororIndustryTitle=="Manufacturing Sector"
drop if SectororIndustryTitle==" Non-Durable Manufacturing Sector"
drop if SectororIndustryTitle==" Durable Manufactoring Sector"
rename  SectororIndustryTitle industry_bls
tempfile labor_inc_manuf
save `labor_inc_manuf'

**3b. Labor income in non-manufacturing**
import excel "${project}/raw_data/industry/klemsmfpxgbymeasure.xlsx", sheet("4-27.1") cellrange(A6:AF55) firstrow clear
rename (C D E F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC AD AE AF) ///
       (bls_L_inc1987 bls_L_inc1988 bls_L_inc1989 bls_L_inc1990 bls_L_inc1991 bls_L_inc1992 bls_L_inc1993 bls_L_inc1994 bls_L_inc1995 bls_L_inc1996 bls_L_inc1997 bls_L_inc1998 bls_L_inc1999 bls_L_inc2000 bls_L_inc2001  bls_L_inc2002  bls_L_inc2003  bls_L_inc2004  bls_L_inc2005 bls_L_inc2006  bls_L_inc2007  bls_L_inc2008  bls_L_inc2009  bls_L_inc2010  bls_L_inc2011  bls_L_inc2012  bls_L_inc2013  bls_L_inc2014  bls_L_inc2015  bls_L_inc2016)
drop if SectororIndustryTitle=="Agriculture, Forestry, and Fishery"
drop if SectororIndustryTitle=="Mining"
drop if SectororIndustryTitle=="Trade"
drop if SectororIndustryTitle=="Transportation and Warehousing"
drop if SectororIndustryTitle=="Information"
drop if SectororIndustryTitle=="Finance, Insurance, and Real Estate"
drop if SectororIndustryTitle=="Services"
rename  SectororIndustryTitle industry_bls
append using `labor_inc_manuf'

reshape long bls_L_inc, i(industry_bls) j(year)
drop NAICS
replace industry_bls=ltrim(industry_bls)
save "${project}/temp_data/bls_labor_inc.dta", replace

*****************************************
*******Data for labor (unadjusted)*******
*****************************************

**Labor qty (unadjusted)**
import excel "${project}/raw_data/industry/hrs.xlsx", sheet("INDEX") cellrange(A2:AE62) firstrow clear
rename (B C D E F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC AD AE) ///
       (bls_L_hours1987 bls_L_hours1988 bls_L_hours1989 bls_L_hours1990 bls_L_hours1991 bls_L_hours1992 bls_L_hours1993 bls_L_hours1994 bls_L_hours1995 bls_L_hours1996 bls_L_hours1997 bls_L_hours1998 bls_L_hours1999 bls_L_hours2000 bls_L_hours2001  bls_L_hours2002  bls_L_hours2003  bls_L_hours2004  bls_L_hours2005 bls_L_hours2006  bls_L_hours2007  bls_L_hours2008  bls_L_hours2009  bls_L_hours2010  bls_L_hours2011  bls_L_hours2012  bls_L_hours2013  bls_L_hours2014  bls_L_hours2015  bls_L_hours2016)
split A, p("(")
gen industry_bls=ltrim(rtrim(A1))
*fix some industry names manually*
replace industry_bls="Crop & Animal Production (Farms)" if industry_bls=="Farm Sector"
replace industry_bls="Publishing industries, except internet (includes software)" if industry_bls=="Publishing industries, except internet [includes software]"
keep industry_bls bls_*
reshape long bls_L_hours, i(industry_bls) j(year)
save "${project}/temp_data/bls_labor_hours.dta", replace
