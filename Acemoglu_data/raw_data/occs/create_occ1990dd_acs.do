/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
"The Race Between Man and Machine", by Daron Acemoglu and Pascual Restrepo
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

This do file aggregates the occ1990dd codes to the occ1990dd_acs groups.
This aggregation corrects for the fact that ACS codes for the 2010-2011 and 2012-2015 vintages
cannot be matched perfectly to the occ1990dd system---even after running recode_acs. 
 
Notes:
-works once you have the variable occ1990dd created. 
-Before running this, make sure that you have occupations that are:
	a. census codes (or acs 2005-2009) codes perfectly matched to occ1990dd
	b. acs codes (2010-2011 and 2012-2015 vintages) imperfectly matched to occ1990dd. 
-Based on the changes described in https://usa.ipums.org/usa/volii/occ_acs.shtml
 and David Dorn's crosspath occ2005_occ1990dd.
-The code produces 304 occupational groups indicated by the code occ1990dd_acs. 

Version 10.20.2017
Pascual Restrepo
pascual@bu.edu
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

gen occ1990dd_acs=occ1990dd

*Change 1 in ACS*
/*Grouped: Farm managers (occ 200---occ1990dd 475) and owners (occ 210---occ1990dd 473) grouped into 205*/
/*Further action in create_occ1990dd_acs (Change 1 in ACS): the codes occ1990dd 473 and 475 merged in occ1990dd_acs 475*/
replace occ1990dd_acs=475 if occ1990dd==473

*Change 2 in ACS*
/*Reshuffle: Morticians and funeral directors (occ 320---occ1990dd 19) and miscellaneous managers (occ 430---occ1990dd 22) got reshuffled into 4465 and 430*/
/*Further action in create_occ1990dd_acs (Change 2 in ACS): the codes occ1990dd 19 and 22 merged in occ1990dd_acs 22*/
replace occ1990dd_acs=22 if occ1990dd==19

*Change 3 in ACS*
/*Reshuffle: Compliance officers (occ 560---occ1990dd 36), security guards (occ 3920---occ1990dd 426), lifeguards (occ 3950---occ1990dd 427) reshuffled into 565, 3945, 3930, 3955*/
/*Further action in create_occ1990dd_acs (Change 3 in ACS): the codes occ1990dd 36, 427 and 426 merged in occ1990dd_acs 427*/
replace occ1990dd_acs=427 if occ1990dd==426
replace occ1990dd_acs=427 if  occ1990dd==36

*Change 4 in ACS*
/*Reshuffle: Public relations (occ 2820---occ1990dd 13), meeting planners (occ 720---occ1990dd 22), and market analyst (occ 730---occ1990dd 37) were reshuffled into 2825, 725, 735, 740, 425*/
/*Further action in create_occ1990dd_acs (Change 4 in ACS): the codes occ1990dd 13, 22, 37 merged in occ1990dd_acs 22*/
replace occ1990dd_acs=22 if occ1990dd==13
replace occ1990dd_acs=22 if occ1990dd==37

*Cnage 5 in ACS*
/*Reshuffle: survey researchers (occ 1810---occ1990dd 166) and miscellaneous social scientists (occ 1860---occ1990dd 169) were reshuffled into 1815 and 1860.*/
/*Further action in create_occ1990dd_acs (Change 5 in ACS): the codes occ1990dd 166, 169 merged in occ1990dd_acs 166*/
replace occ1990dd_acs=166 if occ1990dd==169							

*Change 6 in ACS*
/*Reshuffle: Lawyers (occ 2100---occ1990dd 178), clerks (occ 2150---occ1990dd 234), and paralegals (occ 2140---occ1990dd 234) were reshuffled into 2100, 2105, 2160, 2145*/
/*Further action in create_occ1990dd_acs (Change 6 in ACS): the codes occ1990dd 178 and 234 merged in occ1990dd_acs 178*/
replace occ1990dd_acs=178 if occ1990dd==234

*Change 7 in ACS*
/*Reshuffle: Health practitioners (3410---occ1990dd 678) and technicians (occ 3530---occ1990dd 208) were reshuffled into 3420, 3535*/
/*Further action in create_occ1990dd_acs (Change 7 in ACS): the codes occ1990dd 678 and 208 merged in occ1990dd_acs 208*/
replace occ1990dd_acs=208 if occ1990dd==678

*Change 8 in ACS*
/*Reshuffle: Brickmasons (occ 6220---occ1990dd 563) and metal workers (occ 6500---occ1990dd 597) were pooled into 6220*/
/*Further action in create_occ1990dd_acs (Change 8 in ACS): the codes occ1990dd 563 and 597 merged in occ1990dd_acs 563*/
replace occ1990dd_acs=563 if occ1990dd==597

*Change 9 in ACS*
/*Reshuffle: Electricians (occ 6350---occ1990dd 575), roofers (occ 6510---occ1990dd 595), and heating installers (occ 7310---occ1990dd 534) reshuffled into 6355, 6540, 6515, 7315*/
/*Further action in create_occ1990dd_acs (Change 9 in ACS): the codes occ1990dd 534, 575 and 595 merged in occ1990dd_acs 575 */
replace occ1990dd_acs=575 if occ1990dd==595
replace occ1990dd_acs=575 if occ1990dd==534

*Change 10 in ACS*
/*Pooled: miscellaneous production workers (occ 8960---occ1990dd 779) and other production workers (occ 8860---occ1990dd 764) pooled into 8965*/
/*Note: I also add workers in the newly created 7855 category (food processing workers), created out of parts of occ 8960.*/
/*Further action in create_occ1990dd_acs (Change 10 in ACS): the codes occ1990dd 779, 764 merged in occ1990dd_acs 779*/
replace occ1990dd_acs=779 if occ1990dd==764

*Change 11 in ACS* 
/*Reshuffle: Miscellaneous metal-working jobs (7950, 7960, 8000, 8010, 8220, 8150, 8200, 8210) grouped into 7950, 8220*/
/*Further action in create_occ1990dd_acs (Change 11 in ACS): the codes occ1990dd 706, 708, 709, 703, 684, 724, 723, 644 merged in occ1990dd_acs 684 */
replace occ1990dd_acs=684 if occ1990dd==706
replace occ1990dd_acs=684 if occ1990dd==708
replace occ1990dd_acs=684 if occ1990dd==709
replace occ1990dd_acs=684 if occ1990dd==703
replace occ1990dd_acs=684 if occ1990dd==724
replace occ1990dd_acs=684 if occ1990dd==723
replace occ1990dd_acs=684 if occ1990dd==644

*Change 12 in ACS*
/*Pooled: model makers (occ 8060---occ1990dd 645) and molder jobs (occ 8100---occ1990dd 719) were pooled into 8100*/
/*Further action in create_occ1990dd_acs (Change 12 in ACS): the codes occ1990dd 645, 719 merged in occ1990dd_acs 719*/
replace occ1990dd_acs=719 if occ1990dd==645

*Change 13 in ACS*
/*Reshuffle: bookbinders (occ 8230---occ1990dd 679) printer (occ 8240---occ1990dd 734) and related jobs (occ 8260---occ1990dd 736) were reshuffled into 8255, 8256*/
/*Further action in create_occ1990dd_acs (Change 13 in ACS): the codes occ1990dd 679, 734, 736 merged in occ1990dd_acs 679*/
replace occ1990dd_acs=679 if occ1990dd==734
replace occ1990dd_acs=679 if occ1990dd==736

*Change 14 in ACS*
/*Pooled: shoemakers(occ 8330---occ1990dd 669) and leather workers (occ 8340---occ1990dd 745) were pooled into 8330*/
/*Further action in create_occ1990dd_acs (Change 14 in ACS): the codes occ1990dd 669, 745 merged in occ1990dd_acs 669*/
replace occ1990dd_acs=669 if occ1990dd==745

*Change 15 in ACS*
/*Pooled:railway workers (occ 9230---occ1990dd 825) and other rail transportation workers (occ 9260---occ1990dd 824) pooled into 9260*/
/*Further action in create_occ1990dd_acs (Change 15 in ACS): the codes occ1990dd 824, 825 merged in occ1990dd_acs 824*/
replace occ1990dd_acs=824 if occ1990dd==825

*Change 16 in ACS*
/*Pooled: paper hangers (occ 6420---occ1990dd 579) and painters (occ 6430---occ1990dd 583) were pooled into 6420*/
/*Further action in create_occ1990dd_acs (Change 16 in ACS): the codes occ1990dd 579, 583 merged in occ1990dd_acs 579*/
replace occ1990dd_acs=579 if occ1990dd==583


