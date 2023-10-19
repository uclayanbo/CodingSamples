
*Merge in unweighted mean and sd
import excel "$path/Analysis Data/unweighted means.xlsx", sheet("Sheet1") firstrow clear
tempfile unweighted
save `unweighted'


use "$path/Analysis Data/data_vioplot.dta", clear
gsort provid staff_type2

label define stftype2 1 "CNAs{superscript:a}" 2 "RNs and LPNs{sup:b}" 3 "Therapists{sup:c}" 4 "Physicians/Practitioners{sup:d}" ///
	5 "All Healthcare Staff{sup:e}" 6 "Residents{sup:f}", replace 
label values staff_type2 stftype2


rename staff_type2 staff
decode staff, gen(staff_type2)

merge m:1 staff_type2 using `unweighted', keep(match) nogen
drop mean_percent_comp_vax wt_se staff_type2
rename staff staff_type2

*95% CI
bysort staff_type2: gen upper = mean_unw + 1.96 * se_unw if _n == 1
bysort staff_type2: gen lower = mean_unw - 1.96 * se_unw if _n == 1
gen zero = 0 if !missing(upper)
replace mean_unw = . if missing(upper)


local counter = 1
foreach group in "CNAs{superscript:a}" "RNs and LPNs{sup:b}" "Therapists{sup:c}" "Physicians/Practitioners{sup:d}" "All Healthcare Staff{sup:e}" {
	
	twoway histogram percent_comp_vax if staff_type2 == "`group'":stftype2, ///
		bin(60) color(edkblue%40) lcolor(edkblue) ///
		graphregion(color(white) margin(l=20)) bgcolor(white) ///
		xtitle("") xlab(, labsize(medsmall)) ///
		ylab(minmax, nogrid labsize(medsmall)) ///
		ytitle("`group'", orientation(horizontal) width(20) xoffset(-8) size(medium)) || ///
		///
		rspike lower upper zero if staff_type2 == "`group'":stftype2, lwidth(medthick) horizontal || ///
		///
		scatter zero mean_unw if staff_type2 == "`group'":stftype2, ///
		msize(vlarge) msymbol(|) mfcolor(white) mlcolor(maroon) mlwidth(medthick) ///
		legend(off) name(g`counter', replace)
	
	local counter = `counter' + 1
}

*Last group should have a legend at the bottom
twoway histogram percent_comp_vax if staff_type2 == "Residents{sup:f}":stftype2, ///
		bin(60) color(edkblue%40) lcolor(edkblue) ///
		graphregion(color(white) margin(l=20)) bgcolor(white) ///
		xtitle("") xlab(, labsize(medsmall)) ///
		ylab(minmax, nogrid labsize(medsmall)) ///
		ytitle("Residents{sup:f}", orientation(horizontal) width(20) xoffset(-8) size(medium)) || ///
		///
		rspike lower upper zero if staff_type2 == "Residents{sup:f}":stftype2, lwidth(medthick) horizontal || ///
		///
		scatter zero mean_unw if staff_type2 == "Residents{sup:f}":stftype2, ///
		msize(vlarge) msymbol(|) mfcolor(white) mlcolor(maroon) mlwidth(medthick) ///
		legend(order(1 "Share" 3 "Mean" 2 "95% CI") row(1) pos(6) region(color(white))) ///
		name(g6, replace)


*Combine vertically
grc1leg2 g1 g2 g3 g4 g5 g6, col(1) legendfrom(g6) position(6) ring(2) labsize(small) xtob1title ///
	graphregion(color(white)) ///
	b2title("Completed Vaccination Rate (%)", size(small) xoffset(14.5) yoffset(2))

graph display, xsize(5) ysize(8)


*Save
graph export "$path/Results/vax_bytype.pdf", as(pdf) replace
