/*
Start of Do File to Create Graphs
*/

clear all
set more off 


*********************************************************************************
**Resident Cases
use "$root/Outdata/res_margin", clear

gen keep = 0
forvalues i = 22444(7)22514 {
	display "`i'"
	replace keep = 1 if inlist(var, "`i'bn.week#1bn.county_covid_quart#1bn.staff_vax_base_quart", ///
		"`i'bn.week#4.county_covid_quart#1bn.staff_vax_base_quart", ///
		"`i'bn.week#1bn.county_covid_quart#4.staff_vax_base_quart", ///
		"`i'bn.week#4.county_covid_quart#4.staff_vax_base_quart")
}

forvalues i = 22444(7)22514 {
	replace keep =1 if inlist(var, "`i'.week#1bn.county_covid_quart#1bn.staff_vax_base_quart", ///
		"`i'.week#1bn.county_covid_quart#4.staff_vax_base_quart", ///
		"`i'.week#4.county_covid_quart#1bn.staff_vax_base_quart", ///
		"`i'.week#4.county_covid_quart#4.staff_vax_base_quart")
}

keep if keep == 1
drop keep

split var, parse("#")
tab1 var1 var2 var3

gen week = substr(var1, 1, 5)
destring week, replace
format week %td


/*
*Create a variable containing the outcome sample mean for the start and end of the study period (for scaling estimates).
local start_mean = 0.0268993
local end_mean = 1.254821

*Scale the second yaxis using end_mean.
forvalues x = 0(40)160 {
	local pos_`x' = `x' * `end_mean' / 100
	display "pos_`x' is `pos_`x''"
}
*/

gen county_covid = 1 if var2 == "1bn.county_covid_quart"
replace county_covid = 4 if var2 == "4.county_covid_quart"
label var county_covid "County COVID-19 Rate"
label define c_cov 1 "Facilities in Counties with Bottom Quartile COVID Prevalence" 4 "Facilities in Counties with Top Quartile COVID Prevalence", replace
label values county_covid c_cov

gen staff_vax = 1 if var3 == "1bn.staff_vax_base_quart"
replace staff_vax = 4 if var3 == "4.staff_vax_base_quart"
label var staff_vax "Staff Vaccination Rates"
label define s_vax 1 "Low Staff Vaccination" 4 "High Staff Vaccination", replace
label values staff_vax s_vax

gsort county_covid staff_vax week


twoway scatter coef week if county_covid == 4 & staff_vax==4, connect(direct) lcolor(navy) msymbol(point) lpattern(dash) lwidth(medium) || rarea ci_lower ci_upper week if county_covid == 4 & staff_vax==4, fcolor(navy%20) lcolor(white%0) || ///
scatter coef week if county_covid == 4 & staff_vax==1, connect(direct) lcolor(maroon) msymbol(point) lpattern(dash) lwidth(medium) || rarea ci_lower ci_upper week if county_covid == 4 & staff_vax==1, fcolor(maroon%20) lcolor(white%0) ///
|| , title("") plotregion(color(none)) graphregion(color(none)) bgcolor(white) ylab(, nogrid) ///
legend(order(1 "Low Staff Vaccination Facilities" 3 "High Staff Vaccination Facilities") size(small) cols(1) region(color(none))) ///
ytitle("Cases per 100 Beds", size(vsmall)) ylabel(0(.5)3, labsize(vsmall)) yscale(range(-.2 3.2)) ///
xtitle("") xlabel(22444 " " 22458 " " 22472 " " 22486 " " 22500 " " 22514 " ", labsize(vsmall)) ///
text(1.955 22516.2 "`=ustrunescape("\u23AB")'" /// RCB UPPER HOOK
	"`=ustrunescape("\u23AA")'" ///
	"`=ustrunescape("\u23AC")'" /// RCB MIDDLE PIECE
	"`=ustrunescape("\u23AA")'" ///
	"`=ustrunescape("\u23AD")'", size(*.8) color(black)) ///
text(1.945 22525.7 " 1.64" "(1.13 2.14)", size(*.55) color(black) justification(left)) ///
name(g1, replace)


twoway scatter coef week if county_covid == 1 & staff_vax==4, connect(direct) lcolor(navy) msymbol(point) lpattern(dash) lwidth(medium) || rarea ci_lower ci_upper week if county_covid == 1 & staff_vax==4, fcolor(navy%20) lcolor(white%0) || ///
scatter coef week if county_covid == 1 & staff_vax==1, connect(direct) lcolor(maroon) msymbol(point) lpattern(dash) lwidth(medium) || rarea ci_lower ci_upper week if county_covid == 1 & staff_vax==1, fcolor(maroon%20) lcolor(white%0) ///
|| , title("") plotregion(color(none)) graphregion(color(none)) bgcolor(white) ylab(, nogrid) ///
legend(order(1 "Low Staff Vaccination Facilities" 3 "High Staff Vaccination Facilities") size(small) cols(1) region(color(none))) ///
ytitle(" ", size(vsmall)) ylabel(0(.5)3, labsize(vsmall)) yscale(range(-.2 3.2)) ///
xtitle("") xlabel(22444 " " 22458 " " 22472 " " 22486 " " 22500 " " 22514 " ", labsize(vsmall)) ///
text(.71 22515.5 "}", size(*.7) color(black)) ///
text(.67 22523.5 " -.025" "(-.24 .19)", size(*.55) color(black) justification(left)) ///
name(g2, replace)


*********************************************************************************
**Staff Cases
use "$root/Outdata/staff_margin", clear

gen keep = 0
forvalues i = 22444(7)22514 {
	display "`i'"
	replace keep = 1 if inlist(var, "`i'bn.week#1bn.county_covid_quart#1bn.staff_vax_base_quart", ///
		"`i'bn.week#4.county_covid_quart#1bn.staff_vax_base_quart", ///
		"`i'bn.week#1bn.county_covid_quart#4.staff_vax_base_quart", ///
		"`i'bn.week#4.county_covid_quart#4.staff_vax_base_quart")
}

forvalues i = 22444(7)22514 {
	replace keep =1 if inlist(var, "`i'.week#1bn.county_covid_quart#1bn.staff_vax_base_quart", ///
		"`i'.week#1bn.county_covid_quart#4.staff_vax_base_quart", ///
		"`i'.week#4.county_covid_quart#1bn.staff_vax_base_quart", ///
		"`i'.week#4.county_covid_quart#4.staff_vax_base_quart")
}

keep if keep == 1
drop keep

split var, parse("#")
tab1 var1 var2 var3

gen week = substr(var1, 1, 5)
destring week, replace
format week %td


/*
*Create a variable containing the outcome sample mean for the start and end of the study period (for scaling estimates).
local start_mean = 0.0268993
local end_mean = 1.254821

*Scale the second yaxis using end_mean.
forvalues x = 0(40)160 {
	local pos_`x' = `x' * `end_mean' / 100
	display "pos_`x' is `pos_`x''"
}
*/

gen county_covid = 1 if var2 == "1bn.county_covid_quart"
replace county_covid = 4 if var2 == "4.county_covid_quart"
label var county_covid "County COVID-19 Rate"
label define c_cov 1 "Facilities in Counties with Bottom Quartile COVID Prevalence" 4 "Facilities in Counties with Top Quartile COVID Prevalence", replace
label values county_covid c_cov

gen staff_vax = 1 if var3 == "1bn.staff_vax_base_quart"
replace staff_vax = 4 if var3 == "4.staff_vax_base_quart"
label var staff_vax "Staff Vaccination Rates"
label define s_vax 1 "Low Staff Vaccination" 4 "High Staff Vaccination", replace
label values staff_vax s_vax

gsort county_covid staff_vax week


twoway scatter coef week if county_covid == 4 & staff_vax==4, connect(direct) lcolor(navy) msymbol(point) lpattern(dash) lwidth(medium) || rarea ci_lower ci_upper week if county_covid == 4 & staff_vax==4, fcolor(navy%20) lcolor(white%0) || ///
scatter coef week if county_covid == 4 & staff_vax==1, connect(direct) lcolor(maroon) msymbol(point) lpattern(dash) lwidth(medium) || rarea ci_lower ci_upper week if county_covid == 4 & staff_vax==1, fcolor(maroon%20) lcolor(white%0) ///
|| , title("") plotregion(color(none)) graphregion(color(none)) bgcolor(white) ylab(, nogrid) ///
legend(order(1 "Low Staff Vaccination Facilities" 3 "High Staff Vaccination Facilities") size(small) cols(1) region(color(none))) ///
ytitle("Cases per 100 Beds", size(vsmall)) ylabel(0(1)4.5, labsize(vsmall)) yscale(range(-.2 4.2)) ///
xtitle("") xlabel(22444 " " 22458 " " 22472 " " 22486 " " 22500 " " 22514 " ", labsize(vsmall)) ///
text(3.3 22516.2 "`=ustrunescape("\u23AB")'" /// RCB UPPER HOOK
	"`=ustrunescape("\u23AC")'" /// RCB MIDDLE PIECE
	"`=ustrunescape("\u23AD")'", size(*.9) color(black)) ///
text(3.3 22525.7 " 1.59" "(1.18 2.01)", size(*.55) color(black) justification(left)) ///
name(g3, replace)


twoway scatter coef week if county_covid == 1 & staff_vax==4, connect(direct) lcolor(navy) msymbol(point) lpattern(dash) lwidth(medium) || rarea ci_lower ci_upper week if county_covid == 1 & staff_vax==4, fcolor(navy%20) lcolor(white%0) || ///
scatter coef week if county_covid == 1 & staff_vax==1, connect(direct) lcolor(maroon) msymbol(point) lpattern(dash) lwidth(medium) || rarea ci_lower ci_upper week if county_covid == 1 & staff_vax==1, fcolor(maroon%20) lcolor(white%0) ///
|| , title("") plotregion(color(none)) graphregion(color(none)) bgcolor(white) ylab(, nogrid) ///
legend(order(1 "Low Staff Vaccination Facilities" 3 "High Staff Vaccination Facilities") size(small) cols(1) region(color(none))) ///
ytitle(" ", size(vsmall)) ylabel(0(1)4.5, labsize(vsmall)) yscale(range(-.2 4.2)) ///
xtitle("") xlabel(22444 " " 22458 " " 22472 " " 22486 " " 22500 " " 22514 " ", labsize(vsmall)) ///
text(1.23 22515.5 "}", size(*.9) color(black)) ///
text(1.18 22523 " .34" "(.15 .53)", size(*.55) color(black) justification(left)) ///
name(g4, replace)


*********************************************************************************
**Resident Deaths
use "$root/Outdata/death_margin", clear

gen keep = 0
forvalues i = 22444(7)22514 {
	display "`i'"
	replace keep = 1 if inlist(var, "`i'bn.week#1bn.county_covid_quart#1bn.staff_vax_base_quart", ///
		"`i'bn.week#4.county_covid_quart#1bn.staff_vax_base_quart", ///
		"`i'bn.week#1bn.county_covid_quart#4.staff_vax_base_quart", ///
		"`i'bn.week#4.county_covid_quart#4.staff_vax_base_quart")
}

forvalues i = 22444(7)22514 {
	replace keep =1 if inlist(var, "`i'.week#1bn.county_covid_quart#1bn.staff_vax_base_quart", ///
		"`i'.week#1bn.county_covid_quart#4.staff_vax_base_quart", ///
		"`i'.week#4.county_covid_quart#1bn.staff_vax_base_quart", ///
		"`i'.week#4.county_covid_quart#4.staff_vax_base_quart")
}

keep if keep == 1
drop keep

split var, parse("#")
tab1 var1 var2 var3

gen week = substr(var1, 1, 5)
destring week, replace
format week %td


/*
*Create a variable containing the outcome sample mean for the start and end of the study period (for scaling estimates).
local start_mean = 0.0268993
local end_mean = 1.254821

*Scale the second yaxis using end_mean.
forvalues x = 0(40)160 {
	local pos_`x' = `x' * `end_mean' / 100
	display "pos_`x' is `pos_`x''"
}
*/

gen county_covid = 1 if var2 == "1bn.county_covid_quart"
replace county_covid = 4 if var2 == "4.county_covid_quart"
label var county_covid "County COVID-19 Rate"
label define c_cov 1 "Facilities in Counties with Bottom Quartile COVID Prevalence" 4 "Facilities in Counties with Top Quartile COVID Prevalence", replace
label values county_covid c_cov

gen staff_vax = 1 if var3 == "1bn.staff_vax_base_quart"
replace staff_vax = 4 if var3 == "4.staff_vax_base_quart"
label var staff_vax "Staff Vaccination Rates"
label define s_vax 1 "Low Staff Vaccination" 4 "High Staff Vaccination", replace
label values staff_vax s_vax

gsort county_covid staff_vax week

twoway scatter coef week if county_covid == 4 & staff_vax==4, connect(direct) lcolor(navy) msymbol(point) lpattern(dash) lwidth(medium) || rarea ci_lower ci_upper week if county_covid == 4 & staff_vax==4, fcolor(navy%20) lcolor(white%0) || ///
scatter coef week if county_covid == 4 & staff_vax==1, connect(direct) lcolor(maroon) msymbol(point) lpattern(dash) lwidth(medium) || rarea ci_lower ci_upper week if county_covid == 4 & staff_vax==1, fcolor(maroon%20) lcolor(white%0) ///
|| , title("") plotregion(color(none)) graphregion(color(none)) bgcolor(white) ylab(, nogrid) ///
legend(order(1 "Low Staff Vaccination Facilities" 3 "High Staff Vaccination Facilities") size(small) cols(1) region(color(none))) ///
ytitle("Deaths per 100 Beds", size(vsmall)) ylabel(0(.1).5, labsize(vsmall)) yscale(range(-.05 .55)) ///
xtitle("") xlabel(22444(14)22514, format(%tdMon_dd) labsize(vsmall)) ///
text(.193 22516.2 "`=ustrunescape("\u23AB")'" /// RCB UPPER HOOK
	"`=ustrunescape("\u23AC")'" /// RCB MIDDLE PIECE
	"`=ustrunescape("\u23AD")'", size(*.9) color(black)) ///
text(.19 22525.5 " .19" "(.081 .30)", size(*.55) color(black) justification(left)) ///
name(g5, replace)


twoway scatter coef week if county_covid == 1 & staff_vax==4, connect(direct) lcolor(navy) msymbol(point) lpattern(dash) lwidth(medium) || rarea ci_lower ci_upper week if county_covid == 1 & staff_vax==4, fcolor(navy%20) lcolor(white%0) || ///
scatter coef week if county_covid == 1 & staff_vax==1, connect(direct) lcolor(maroon) msymbol(point) lpattern(dash) lwidth(medium) || rarea ci_lower ci_upper week if county_covid == 1 & staff_vax==1, fcolor(maroon%20) lcolor(white%0) ///
|| , title("") plotregion(color(none)) graphregion(color(none)) bgcolor(white) ylab(, nogrid) ///
legend(order(1 "Low Staff Vaccination Facilities" 3 "High Staff Vaccination Facilities") size(small) cols(1) region(color(none))) ///
ytitle(" ", size(vsmall)) ylabel(0(.1).5, labsize(vsmall)) yscale(range(-.05 .55)) ///
xtitle("") xlabel(22444(14)22514, format(%tdMon_dd) labsize(vsmall)) ///
text(.068 22515.5 "}", size(*.8) color(black)) ///
text(.061 22525.5 " .022" "(-.018 .061)", size(*.55) color(black) justification(left)) ///
name(g6, replace)


*********************************************************************************
*Combine vertically.
grc1leg2 g1 g2 g3 g4 g5 g6, cols(2) legendfrom(g3) position(6) ring(2) labsize(vsmall) ltsize(vsmall) ///
	plotregion(color(white)) graphregion(color(white) margin(r+2.5)) ysize(15) xsize(14) ///
	b1title("Week Ending (all 2021)", size(tiny) yoffset(2.5) xoffset(2.5)) ///
	title("       High COVID Prevalence Counties                       Low COVID Prevalence Counties", size(vsmall)) ///
	l1title("Resident" "Cases" " " " " " " " " " " " " " " " " " " " " " " " " ///
		"Staff" "Cases" " " " " " " " " " " " " " " " " " " " " " " ///
		"Resident" "Deaths", size(vsmall) orientation(horizontal) yoffset(3.2))


graph export "$root/Outdata/line_graph_cumulative.pdf", replace
