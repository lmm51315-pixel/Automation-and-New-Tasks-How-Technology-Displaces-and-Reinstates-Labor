/*******************************************************************************
"Automation and New Tasks: How Technology Changes Labor Demand" 
by D. Acemoglu and P. Restrepo, JEP 2019

2.22.2019
Pascual Restrepo

This do file generates:

- Figure A15 in the Appendix: 
	Labor share and sectoral evolutions during the mechanization of agriculture:
	1850 -1910
	
- Figure 2 in the paper:
	Labor share and sectoral evolutions during 1947 - 1987
	
- Figure 4 in the paper:
	Labor share and sectoral evolutions during 1987 - 2017

(revised by G. Marcolongo on 3.27.2019	)
*******************************************************************************/


* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
* * FIGURE A15 - Appendix 
* * LABOR SHARE AND SECTORAL EVOLUTIONS DURING THE MECHANIZATION OF AGRICULTURE
* * It plots raw data between 1850 - 1910 
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

use "${project}/clean_data/panel_budd.dta", clear

bys year: egen wbill_us=total(budd_comp)
bys year: egen gdp_us=total(budd_vadded)
gen share_gdp=100*budd_vadded/gdp_us
gen labsh_us=100*wbill_us/gdp_us
replace budd_labsh=100*budd_labsh

*labels*
gen lab_agriculture="Agriculture" if year==1910
gen lab_manufacturing="Industry" if year==1910
gen lab_aggre="Overall" if year==1910


**** A) TOP PANEL ****
** Labor share in value added in industry and agriculture between 1850-1910

* as in the appendix:
twoway (connected budd_labsh year if industry=="manufacturing and services", m(none) mlab(lab_manuf)  lpattern(dash)) ///
       (connected budd_labsh year if industry=="agriculture",  m(none) mlab(lab_agriculture)) ///
       (connected  labsh_us year if industry=="manufacturing and services", lpattern(dot) m(triangle) mlab(lab_aggr) mlabsize(small)), ///
	   ylabel(20(10)60, noticks angle(horizontal)) title("Labor share, 1850-1910", size(medium) position(11)) ytitle("")  xtitle("")  yscale(noline) ///
	   legend(off) xlabel(1850(10)1910) xscale(r(1850 1915)) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white)) xsize(7.5) ysize(4.5)
graph export "${project}\figs\sector_labsh_1850_1910.eps", as(eps) preview(on) replace	

* rescaled to fit slides:
twoway (connected budd_labsh year if industry=="manufacturing and services", m(none) mlab(lab_manuf)  lpattern(dash)) ///
       (connected budd_labsh year if industry=="agriculture",  m(none) mlab(lab_agriculture)) ///
       (connected  labsh_us year if industry=="manufacturing and services", lpattern(dot) m(triangle) mlab(lab_aggr) mlabsize(small)), ///
	   ylabel(20(10)60, noticks angle(horizontal)) title("Labor share, 1850-1910", size(medium) position(11)) ytitle("")  xtitle("")  yscale(noline) ///
	   legend(off) xlabel(1850(10)1910) xscale(r(1850 1915)) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white)) xsize(5) ysize(5)
graph export "${project}\figs\sector_labsh_1850_1910_slides.eps", as(eps) preview(on) replace	


**** B) BOTTOM PANEL ****
** Share of value added in industry and agriculture relative to GDP between 1850-1910
twoway (connected share_gdp year if industry=="manufacturing and services", m(none) mlab(lab_manuf) lpattern(dash)) ///
       (connected share_gdp year if industry=="agriculture",  m(none) mlab(lab_agriculture)), ///
	   ylabel(20(10)80, noticks angle(horizontal)) title("Share GDP, 1850-1910", size(medium) position(11)) ytitle("")  xtitle("")  yscale(noline) ///
	   legend(off) xlabel(1850(10)1910) xscale(r(1850 1915)) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white))  xsize(7.5) ysize(4.5)
graph export "${project}\figs\sector_gdpsh_1850_1910.eps", as(eps) preview(on) replace	
	   	   
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
* * FIGURE 2 
* * THE LABOR SHARE AND SECTORAL EVOLUTIONS, 1947 - 1987	
* * It plots raw data between 1947 and 1987
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

use "${project}/clean_data/panel_bea72.dta", clear
collapse (sum) *_comp *_vadded, by(sector year)

bys year: egen wbill_us=total(bea72_comp)
bys year: egen gdp_us=total(bea72_vadded)
gen share_gdp=100*bea72_vadded/gdp_us
gen labsh_us=100*wbill_us/gdp_us
gen labsh_sector=100*bea72_comp/bea72_vadded


*labels*
gen lab_agriculture="Agriculture" if year==1987
gen lab_manufacturing="Manufacturing" if year==1987
gen lab_mining="Mining" if year==1987
gen lab_transp="Transportation" if year==1987
gen lab_construction="Construction" if year==1987
gen lab_services="Services" if year==1987

**** A) TOP PANEL ****
** Labor share in value added in services, manufacturing, construction, 
** transportation, mining and agriculture between 1947 and 1987

* as in the paper:
twoway (connected labsh_sector year if sector=="manufacturing", m(none) mlab(lab_manuf)) ///
       (connected labsh_sector year if sector=="agriculture", m(none)  mlab(lab_agriculture)) ///
       (connected labsh_sector year if sector=="mining", m(none) lpattern(dash_dot) mlab(lab_mining)) ///
	   (connected labsh_sector year if sector=="transportation", m(none) lpattern(dash_dot) mlab(lab_transp)) ///
	   (connected labsh_sector year if sector=="construction", m(none) lpattern(dash_dot)  mlab(lab_const)) ///
       (connected labsh_sector year if sector=="services", m(none) mlab(lab_serv)), ///
	   ylabel(20(10)80, noticks angle(horizontal)) title("Labor share, 1947-1987", size(medium) position(11)) ytitle("")  xtitle("")  yscale(noline) ///
	   legend(off) xlabel(1947(5)1987) xscale(r(1947 1990)) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white))  xsize(7.5) ysize(4.5)
graph export "${project}\figs\sector_labsh_1947_1987.eps", as(eps) preview(on) replace	

* rescaled to fit slides:
twoway (connected labsh_sector year if sector=="manufacturing", m(none) mlab(lab_manuf)) ///
       (connected labsh_sector year if sector=="agriculture", m(none)  mlab(lab_agriculture)) ///
       (connected labsh_sector year if sector=="mining", m(none) lpattern(dash_dot) mlab(lab_mining)) ///
	   (connected labsh_sector year if sector=="transportation", m(none) lpattern(dash_dot) mlab(lab_transp)) ///
	   (connected labsh_sector year if sector=="construction", m(none) lpattern(dash_dot)  mlab(lab_const)) ///
       (connected labsh_sector year if sector=="services", m(none) mlab(lab_serv)), ///
	   ylabel(20(10)80, noticks angle(horizontal)) title("Labor share, 1947-1987", size(medium) position(11)) ytitle("")  xtitle("")  yscale(noline) ///
	   legend(off) xlabel(1947(5)1987) xscale(r(1947 1990)) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white))  xsize(5) ysize(5)
graph export "${project}\figs\sector_labsh_1947_1987_slides.eps", as(eps) preview(on) replace	

**** B) BOTTOM PANEL ****
** Share of value added in the services, manufacturing, construction, 
** transportation, mining and agriculture relative to GDP, 1947-1987.

gen lab_agriculture2="Agriculture" if year==1983

* as in the paper:
twoway (connected share_gdp year if sector=="manufacturing", m(none) mlab(lab_manuf)) ///
       (connected share_gdp year if sector=="agriculture", m(none)  mlab(lab_agriculture2) mlabposition(4)) ///
       (connected share_gdp year if sector=="mining", m(none) lpattern(dash_dot) mlab(lab_mining)) ///
	   (connected share_gdp year if sector=="transportation", m(none) lpattern(dash_dot) mlab(lab_transp)) ///
	   (connected share_gdp year if sector=="construction", m(none) lpattern(dash_dot)  mlab(lab_const)) ///
       (connected share_gdp year if sector=="services", m(none) mlab(lab_serv)), ///
	   ylabel(0(10)60, noticks angle(horizontal)) title("Share GDP, 1947-1987", size(medium) position(11)) ytitle("")  xtitle("")  yscale(noline) ///
	   legend(off) xlabel(1947(5)1987) xscale(r(1947 1990)) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white))  xsize(7.5) ysize(4.5)
graph export "${project}\figs\sector_gdpsh_1947_1987.eps", as(eps) preview(on) replace	

* rescaled to fit slides:
twoway (connected share_gdp year if sector=="manufacturing", m(none) mlab(lab_manuf)) ///
       (connected share_gdp year if sector=="agriculture", m(none)  mlab(lab_agriculture2) mlabposition(4)) ///
       (connected share_gdp year if sector=="mining", m(none) lpattern(dash_dot) mlab(lab_mining)) ///
	   (connected share_gdp year if sector=="transportation", m(none) lpattern(dash_dot) mlab(lab_transp)) ///
	   (connected share_gdp year if sector=="construction", m(none) lpattern(dash_dot)  mlab(lab_const)) ///
       (connected share_gdp year if sector=="services", m(none) mlab(lab_serv)), ///
	   ylabel(0(10)60, noticks angle(horizontal)) title("Share GDP, 1947-1987", size(medium) position(11)) ytitle("")  xtitle("")  yscale(noline) ///
	   legend(off) xlabel(1947(5)1987) xscale(r(1947 1990)) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white))  xsize(5) ysize(5)
graph export "${project}\figs\sector_gdpsh_1947_1987_slides.eps", as(eps) preview(on) replace	


* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
* * FIGURE 4 
* * THE LABOR SHARE AND SECTORAL EVOLUTIONS, 1987 - 2017	
* * It plots raw data between 1987 and 2017
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
use "${project}/clean_data/panel_beaNAICS.dta", clear
collapse (sum) *_comp *_vadded, by(sector year)

bys year: egen wbill_us=total(bea_comp)
bys year: egen gdp_us=total(bea_vadded)
gen share_gdp=100*bea_vadded/gdp_us
gen labsh_us=100*wbill_us/gdp_us
gen labsh_sector=100*bea_comp/bea_vadded

*labels*
gen lab_agriculture="Agriculture" if year==2016
gen lab_manufacturing="Manufacturing" if year==2016
gen lab_mining="Mining" if year==2016
gen lab_transp="Transportation" if year==2016
gen lab_construction="Construction" if year==2016
gen lab_services="Services" if year==2016

**** A) TOP PANEL ****
** Labor share in value added in services, manufacturing, construction, 
** transportation, mining and agriculture between 1987 and 2017

* as in the paper:
twoway (connected labsh_sector year if sector=="manufacturing", m(none) mlab(lab_manuf)) ///
       (connected labsh_sector year if sector=="agriculture", m(none)  mlab(lab_agriculture)) ///
       (connected labsh_sector year if sector=="mining", m(none) lpattern(dash_dot) mlab(lab_mining)) ///
	   (connected labsh_sector year if sector=="transportation", m(none) lpattern(dash_dot) mlab(lab_transp)) ///
	   (connected labsh_sector year if sector=="construction", m(none) lpattern(dash_dot)  mlab(lab_const)) ///
       (connected labsh_sector year if sector=="services", m(none) mlab(lab_serv)), ///
	   title("Labor share, 1987-2017", size(medium) position(11)) ytitle("")  xtitle("")  yscale(noline)  xsize(7.5) ysize(4.5) ///
	   ylabel(20(10)70, noticks angle(horizontal)) legend(off) xlabel(1987(5)2017) xscale(r(1987 2020)) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white))
graph export "${project}\figs\sector_labsh_1987_2017.eps", as(eps) preview(on) replace	

* rescaled to fit slides:
twoway (connected labsh_sector year if sector=="manufacturing", m(none) mlab(lab_manuf)) ///
       (connected labsh_sector year if sector=="agriculture", m(none)  mlab(lab_agriculture)) ///
       (connected labsh_sector year if sector=="mining", m(none) lpattern(dash_dot) mlab(lab_mining)) ///
	   (connected labsh_sector year if sector=="transportation", m(none) lpattern(dash_dot) mlab(lab_transp)) ///
	   (connected labsh_sector year if sector=="construction", m(none) lpattern(dash_dot)  mlab(lab_const)) ///
       (connected labsh_sector year if sector=="services", m(none) mlab(lab_serv)), ///
	   title("Labor share, 1987-2017", size(medium) position(11)) ytitle("")  xtitle("")  yscale(noline)  xsize(5) ysize(5) ///
	   ylabel(20(10)70, noticks angle(horizontal)) legend(off) xlabel(1987(5)2017) xscale(r(1987 2020)) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white))
graph export "${project}\figs\sector_labsh_1987_2017_slides.eps", as(eps) preview(on) replace	

**** B) BOTTOM PANEL ****
** Share of value added in the services, manufacturing, construction, 
** transportation, mining and agriculture relative to GDP, 1987-2017.

gen lab_agriculture2="Agriculture" if year==2013

* as in the paper:
twoway (connected share_gdp year if sector=="manufacturing", m(none) mlab(lab_manuf)) ///
       (connected share_gdp year if sector=="agriculture", m(none)  mlab(lab_agriculture2) mlabposition(4)) ///
       (connected share_gdp year if sector=="mining", m(none) lpattern(dash_dot) mlab(lab_mining)) ///
	   (connected share_gdp year if sector=="transportation", m(none) lpattern(dash_dot) mlab(lab_transp) mlabpos(2)) ///
	   (connected share_gdp year if sector=="construction", m(none) lpattern(dash_dot)  mlab(lab_const)) ///
       (connected share_gdp year if sector=="services", m(none) mlab(lab_serv)), ///
	   ylabel(0(10)70, noticks angle(horizontal)) title("Share GDP, 1987-2017", size(medium) position(11)) ytitle("")  xtitle("")  yscale(noline)  xsize(7.5) ysize(4.5) ///
	   legend(off) xlabel(1987(5)2017) xscale(r(1987 2020)) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white))
graph export "${project}\figs\sector_gdpsh_1987_2017.eps", as(eps) preview(on) replace	

* rescaled to fit slides:
twoway (connected share_gdp year if sector=="manufacturing", m(none) mlab(lab_manuf)) ///
       (connected share_gdp year if sector=="agriculture", m(none)  mlab(lab_agriculture2) mlabposition(4)) ///
       (connected share_gdp year if sector=="mining", m(none) lpattern(dash_dot) mlab(lab_mining)) ///
	   (connected share_gdp year if sector=="transportation", m(none) lpattern(dash_dot) mlab(lab_transp) mlabpos(2)) ///
	   (connected share_gdp year if sector=="construction", m(none) lpattern(dash_dot)  mlab(lab_const)) ///
       (connected share_gdp year if sector=="services", m(none) mlab(lab_serv)), ///
	   ylabel(0(10)70, noticks angle(horizontal)) title("Share GDP, 1987-2017", size(medium) position(11)) ytitle("")  xtitle("")  yscale(noline)  xsize(5) ysize(5) ///
	   legend(off) xlabel(1987(5)2017) xscale(r(1987 2020)) graphregion(fcolor(white) ifcolor(white)  lcolor(white) ilcolor(white)) plotregion(fcolor(white))
graph export "${project}\figs\sector_gdpsh_1987_2017_slides.eps", as(eps) preview(on) replace	
