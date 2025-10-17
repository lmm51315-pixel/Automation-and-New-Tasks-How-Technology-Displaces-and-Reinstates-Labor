/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
"The Race Between Man and Machine", by Daron Acemoglu and Pascual Restrepo
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

This do file recodes the ACS occupational codes to their 2005-09 vintage so that they can be matched to 
the crosspath occ2005_occ1990dd.

Notes:
-works for the 2010-2011 and 2012-2015 vintages.
-uses the correspondence: https://usa.ipums.org/usa/volii/occ_acs.shtml
-the match is not perfect. In some cases, the Census grouped or reshuffled occupational categories.
-the resulting codes can be matched with the crosspath occ2005_occ1990dd.
-But to account for grouped and reshuffled categories, one needs to run the dofile 
create_occ1990dd_acs right after. 

Version 10.20.2017
Pascual Restrepo
pascual@bu.edu
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */


replace occ=130 if (occ==135 | occ==136 | occ==137)  /*Division: Human resources (occ 130) was divided in 135, 136, 137*/

replace occ=200 if occ==205 & year>= 2010 	/*Grouped: Farm managers (occ 200---occ1990dd 475) and owners (occ 210---occ1990dd 473) grouped into 205*/
											/*Further action in create_occ1990dd_acs (Change 1 in ACS): the codes occ1990dd 473 and 475 merged in occ1990dd_acs 475*/
										
replace occ=320 if (occ==4465| occ==430)  	/*Reshuffle: Morticians and funeral directors (occ 320---occ1990dd 19) and miscellaneous managers (occ 430---occ1990dd 22) got reshuffled into 4465 and 430*/
											/*Further action in create_occ1990dd_acs (Change 2 in ACS): the codes occ1990dd 19 and 22 merged in occ1990dd_acs 22*/

replace occ=560 if (occ==565 | occ==3930| occ==3945 | occ==3955)  /*Reshuffle: Compliance officers (occ 560---occ1990dd 36), security guards (occ 3920---occ1990dd 426), lifeguards (occ 3950---occ1990dd 427) reshuffled into 565, 3945, 3930, 3955*/
																  /*Further action in create_occ1990dd_acs (Change 3 in ACS): the codes occ1990dd 36, 427 and 426 merged in occ1990dd_acs 427*/

replace occ=620 if (occ==630 | occ==640| occ==650)  /*Division: Human resources jobs (occ 620) divided in 630, 640, 650*/
replace occ=6000 if occ==6005 						/*Reshuffling: some farm supervisors were moved to human resources (occ 630). 
													  These are a few, so I do not pool the codes occ1990dd 27 and 496; these are quite different*/

replace occ=4960 if (occ==726| occ==4965)  /*Division: Fundraisers (occ 4960) was divided in 726 and 4965*/

replace occ=720 if (occ==2825| occ==725 | occ==735 | occ==740 | occ==425)  /*Reshuffle: Public relations (occ 2820---occ1990dd 13), meeting planners (occ 720---occ1990dd 22), and market analyst (occ 730---occ1990dd 37) were reshuffled into 2825, 725, 735, 740, 425*/
																		   /*Further action in create_occ1990dd_acs (Change 4 in ACS): the codes occ1990dd 13, 22, 37 merged in occ1990dd_acs 22*/

replace occ=1000 if (occ==1005 | occ==1006 | occ==1107 | occ==1106 | occ==1007 | occ==1030 | occ==1050 | occ==1105)  /*Reshuffle: Computer jobs (occ 1000---occ1990dd 64), Network architects (occ 1110---occ1990dd), and network support specialists (occ 1040---occ1990dd ) were reshuffled into 1005, 1006, 1107, 1106, 1007, 1030, 1050, 1105 */
																													 /*Further action in create_occ1990dd_acs: No action required. All these jobs map to occ1990dd 64*/

replace occ=1860 if occ==1815 	/*Reshuffle: survey researchers (occ 1810---occ1990dd 166) and miscellaneous social scientists (occ 1860---occ1990dd 169) were reshuffled into 1815 and 1860.*/
								/*Further action in create_occ1990dd_acs (Change 5 in ACS): the codes occ1990dd 166, 169 merged in occ1990dd_acs 166*/																									
																																																																
replace occ=1960 if (occ==1950 | occ==1965 )  /*Division: Scientists (occ 1960) divided in 1950 1965*/

replace occ=2020 if (occ==2015 | occ==2016| occ==2025)  /*Division:  Social workers (occ 2020) divided in 2015, 2016, 2025*/

replace occ=2100 if (occ==2105 | occ==2160 | occ==2145) 	/*Reshuffle: Lawyers (occ 2100---occ1990dd 178), clerks (occ 2150---occ1990dd 234), and paralegals (occ 2140---occ1990dd 234) were reshuffled into 2100, 2105, 2160, 2145*/
															/*Further action in create_occ1990dd_acs (Change 6 in ACS): the codes occ1990dd 178 and 234 merged in occ1990dd_acs 178*/

replace occ=3130 if (occ==3255 | occ==3256| occ==3258)  /*Division: Nurses (occ 3130) divided in 3255, 3256, 3258*/

replace occ=3240 if occ==3245  /*Code Change: Change in the code of other therapists*/

replace occ=3410 if (occ==3420 | occ==3535)  	/*Reshuffle: Health practitioners (3410---occ1990dd 678) and technicians (occ 3530---occ1990dd 208) were reshuffled into 3420, 3535*/
												/*Further action in create_occ1990dd_acs (Change 7 in ACS): the codes occ1990dd 678 and 208 merged in occ1990dd_acs 208*/

replace occ=3650 if (occ==3645 | occ==3646| occ==3647| occ==3648| occ==3649| occ==3655)  /*Division: Medical assistants (occ 3650) divided in 3645, 3646, 3647, 3648, 3649, 3655*/


replace occ=4550  if (occ==9415| occ==9050)  /*Division: Flight. attendants (occ 4550) divided in 9050 and 9415*/

replace occ=5930 if (occ==5940| occ==5165)   /*Division: Clerks (5930) divided in 5165 and 5940*/

														/*Reshuffle: Brickmasons (occ 6220---occ1990dd 563) and metal workers (occ 6500---occ1990dd 597) were pooled into 6220*/
														/*Further action in create_occ1990dd_acs (Change 8 in ACS): the codes occ1990dd 563 and 597 merged in occ1990dd_acs 563*/
														/*Note that this change does not require a recoding of occ*/

replace occ=6350 if (occ==6355| occ==6540 | occ==6515 | occ==7315)  /*Reshuffle: Electricians (occ 6350---occ1990dd 575), roofers (occ 6510---occ1990dd 595), and heating installers (occ 7310---occ1990dd 534) reshuffled into 6355, 6540, 6515, 7315*/
																	/*Further action in create_occ1990dd_acs (Change 9 in ACS): the codes occ1990dd 534, 575 and 595 merged in occ1990dd_acs 575 */

replace occ=6760 if occ==6765  /*Code change: Misc construction*/


replace occ=7620 if (occ==7630|occ==7550)  /*Pooled: Repair workers (occ 7620---occ1990dd 549) and installation workers (occ 7550---occ1990dd 549) consolidated in 7630*/
										   /*Further action in create_occ1990dd_acs: No action required. All these occupations map to 549 */

										   
replace occ=8960 if (occ==8965 |occ==8860 | occ==7855)  	/*Pooled: miscellaneous production workers (occ 8960---occ1990dd 779) and other production workers (occ 8860---occ1990dd 764) pooled into 8965*/
															/*Note: I also add workers in the newly created 7855 category (food processing workers), created out of parts of occ 8960.*/
															/*Further action in create_occ1990dd_acs (Change 10 in ACS): the codes occ1990dd 779, 764 merged in occ1990dd_acs 779*/
										   
														/*Reshuffle: Miscellaneous metal-working jobs (7950, 7960, 8000, 8010, 8220, 8150, 8200, 8210) grouped into 7950, 8220*/
														/*Further action in create_occ1990dd_acs (Change 11 in ACS): the codes occ1990dd 706, 708, 709, 703, 684, 724, 723, 644 merged in occ1990dd_acs 684 */
														/*Note that this change does not require a recoding of occ*/
														
														/*Pooled: model makers (occ 8060---occ1990dd 645) and molder jobs (occ 8100---occ1990dd 719) were pooled into 8100*/
														/*Further action in create_occ1990dd_acs (Change 12 in ACS): the codes occ1990dd 645, 719 merged in occ1990dd_acs 719*/
														/*Note that this change does not require a recoding of occ*/
														
replace occ=8230 if (occ==8255 | occ==8256)  	/*Reshuffle: bookbinders (occ 8230---occ1990dd 679) printer (occ 8240---occ1990dd 734) and related jobs (occ 8260---occ1990dd 736) were reshuffled into 8255, 8256*/
												/*Further action in create_occ1990dd_acs (Change 13 in ACS): the codes occ1990dd 679, 734, 736 merged in occ1990dd_acs 679*/
														
														/*Pooled: shoemakers(occ 8330---occ1990dd 669) and leather workers (occ 8340---occ1990dd 745) were pooled into 8330*/
														/*Further action in create_occ1990dd_acs (Change 14 in ACS): the codes occ1990dd 669, 745 merged in occ1990dd_acs 669*/
														/*Note that this change does not require a recoding of occ*/
														
														/*Pooled:railway workers (occ 9230---occ1990dd 825) and other rail transportation workers (occ 9260---occ1990dd 824) pooled into 9260*/
														/*Further action in create_occ1990dd_acs (Change 15 in ACS): the codes occ1990dd 824, 825 merged in occ1990dd_acs 824*/
														/*Note that this change does not require a recoding of occ*/
														
														/*Pooled: paper hangers (occ 6420---occ1990dd 579) and painters (occ 6430---occ1990dd 583) were pooled into 6420*/
														/*Further action in create_occ1990dd_acs (Change 16 in ACS): the codes occ1990dd 579, 583 merged in occ1990dd_acs 579*/
														/*Note that this change does not require a recoding of occ*/
														

																																								

															


