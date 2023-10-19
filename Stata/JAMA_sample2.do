
set scheme s1color

use "$path/Analysis Data/data for forrest plot_update.dta", clear
//county vax rate in wrong scale, fix here
//replace county_vax_rate_10=county_vax_rate_10/100
sum county_vax_rate_10, det


*Regressions
********************************************************************************
**Staff Rates 
areg percent_comp_vax i.profit_stat numberofcertifiedbeds_10 i.chain fivestar employee_count_10 staff_death100 res_death100 ///
	share_lpn_10 share_rn_10 share_nurse_ctr_10 dc_exp_10 share_nonwhite_10 share_u29_10 share_female_10 ///
	paymcaid_10 pct_nonwhite_10 ///
	trump_biden_diff_10 county_vax_rate_10 ///
	medicaid_miss nonwhite_miss staff_size_miss rn_share_miss lpn_share_miss share_ctr_miss share_nonwhite_miss countyvax_miss trump_biden_miss fivestar_miss ///
	bedsize_miss exp_dc_miss share_u29_miss share_female_miss ///
	if type == "anyhc" [fweight=num_], absorb(providerstate) vce(cluster federalprovidernumber)

//outreg2 using "$results/lpm_cont_8_2_21_anyhc", ctitle(Any Health Care Staff Vaccination Rate) ///
	//	stats(coef ci) dec(3) addtext(Linear Probability Model, Yes, Weights, Staff Size, Clustered SEs, No) ///
		//excel replace


estimates store staff_cont
gen staff_sample = 1 if e(sample) == 1


**Resident Rates
areg percent_comp_vax i.profit_stat numberofcertifiedbeds_10 i.chain fivestar employee_count_10 staff_death100 res_death100 ///
	share_lpn_10 share_rn_10 share_nurse_ctr_10 dc_exp_10 share_nonwhite_10 share_u29_10 share_female_10 ///
	paymcaid_10 pct_nonwhite_10 ///
	trump_biden_diff_10 county_vax_rate_10 ///
	medicaid_miss nonwhite_miss staff_size_miss rn_share_miss lpn_share_miss share_ctr_miss share_nonwhite_miss countyvax_miss trump_biden_miss fivestar_miss ///
	bedsize_miss exp_dc_miss share_u29_miss share_female_miss ///
	if type == "res" [fweight=num_], absorb(providerstate) vce(cluster federalprovidernumber)

//outreg2 using "$results/lpm_cont_8_2_21_res", ctitle(Resident Vaccination Rate) stats(coef ci) dec(3) /// 
	//	addtext(Linear Probability Model, Yes, Weights, Res Count, Clustered SEs, No) excel replace


estimates store res_cont

gen res_sample = 1 if e(sample) == 1

prop profit_stat if res_sample == 1
prop chain if res_sample == 1


*Forest Plot
********************************************************************************
*Label Variables for use in Graph - Unused

*Facility Characteristics
label var profit_stat "Profit Status"
label define profit 1 "Non-Profit" 2 "Government Owned" 3 "For Profit" 4 "Missing", replace
label values profit_stat profit
label var numberofcertifiedbeds_10 "Facility Size (per 10 beds)"
label define new_chain 0 "No" 1 "Part of Chain" 2 "Missing", replace
label value chain new_chain
label var fivestar "Overall Quality Score"
label var employee_count_10 "Total Staff Size{sup:a} (per 10 employees)"
label var staff_death100 "Staff COVID-19 Deaths{sup:b} per 100 beds"
label var res_death100 "Resident COVID-19 Deaths{sup:c} per 100 beds"

*Staff Characteristics
label var share_lpn_10 "Percent LPN{sup:d} (per 10pp)"
label var share_rn_10 "Percent RN{sup:e} (per 10pp)"
label var share_nurse_ctr_10 "Percent Contract Staff{sup:f} (per 10pp)"
label var dc_exp_10 "Percent with >XX Hours Experience{sup:g} (per 10pp)"
label var share_nonwhite_10 "Percent non-White{sup:h} (per 10pp)"
label var share_u29_10 "Percent Age <29{sup:i} (per 10pp)"
label var share_female_10 "Percent Female{sup:j} (per 10pp)"


*Resident Characteristics
label var paymcaid_10 "Percent with Medicaid (per 10pp)" 
label var pct_nonwhite_10 "Percent non-White (per 10pp)"


*County Characteristics
label var trump_biden_diff_10 "Republican Vote Margin (per 10pp)"
label var county_vax_rate_10 "Adult Vaccination Rate (per 10pp)"


*Combine two sets of estimates into a single graph
********************************************************************************
foreach x in employee_count share_lpn share_rn share_nurse_ctr ///
	dc_exp share_nonwhite share_u29 share_female paymcaid pct_nonwhite ///
	trump_biden_diff county_vax_rate numberofcertifiedbeds {
		gen `x'_real=(`x'_10)*10 if `x'_miss!=1
	}
	
foreach x in fivestar res_death100 staff_death100{
	gen `x'_real=`x' if `x'_miss!=1
	}

*Sample Means
foreach x of var fivestar_real employee_count_real share_lpn_real share_rn_real share_nurse_ctr_real ///
	dc_exp_real share_nonwhite_real share_u29_real share_female_real paymcaid_real pct_nonwhite_real ///
	res_death100_real staff_death100_real trump_biden_diff_real county_vax_rate_real numberofcertifiedbeds_real {
		
		summ `x' if res_sample == 1, d
		
		local `x'_mean: di %9.1f `r(mean)'
		local `x'_sd: di %9.1f `r(sd)'
		
		local `x'_mean = trim("``x'_mean'")
		local `x'_sd = trim("``x'_sd'")
}

prop profit_stat chain

//Percentage for categories
local chain_percent "54.5%"
local govt_own_percent "6.3%"
local for_profit_percent "70.3%"


********************************************************************************
*A function that creates the coefficients and p-values column
capt program drop coefplot_mlbl2
program coefplot_mlbl2, sclass
	_parse comma plots 0 : 0
	syntax [, MLabel(passthru) * ]
	if `"`mlabel'"'=="" local mlabel mlabel(string(@b))
	preserve
	qui coefplot `plots', `options' `mlabel' generate replace nodraw
	tempvar touse
	qui gen byte `touse' = 0
	local nplots = r(n_plots)
	forv i = 1/`nplots' {
		qui replace `touse' = __plot==`i' & __at<.
		mata: st_global("s(mlbl`i')", ///
			invtokens((strofreal(st_data(.,"__at","`touse'")) :+ " " :+ ///
			"`" :+ `"""' :+ st_sdata(.,"__mlbl","`touse'") :+ `"""' :+ "'")'))
	}
	sreturn local plots `"`plots'"'
	sreturn local options `"`options'"'
end


********************************************************************************
*Create the coefficients and p-values column - `s(mlbl1)' and `s(mlbl2)' get returned
coefplot_mlbl2 (staff_cont, drop(2.profit_stat 2.chain nonwhite_miss staff_size_miss rn_share_miss lpn_share_miss share_ctr_miss share_nonwhite_miss countyvax_miss fivestar_miss _cons exp_dc_miss) label(Staff) offset(0.22)) ///
	(res_cont, drop(2.profit_stat 2.chain nonwhite_miss staff_size_miss rn_share_miss lpn_share_miss share_ctr_miss share_nonwhite_miss countyvax_miss fivestar_miss _cons exp_dc_miss) label(Residents) offset(-0.22)), ///
	drop(_cons) ciopt(lwidth(thin)) ///
	msize(vsmall) mcolor(%50) msymbol(Dh) ///
	graphregion(fcolor(white) margin(l=60)) bgcolor(white) ///
	legend(pos(6) region(color(none)) xoffset(-7) yoffset(-3) size(vsmall) ) ///
	xlab(, labsize(tiny)) xtitle("Estimated Marginal Change in Vaccination Coverage (pp)", size(tiny)) xscale(titlegap(2)) ///
	xline(0, lcolor(gray%70) lpattern(dash)) ///
	ylab(, nogrid labsize(tiny)) yscale(noline alt) ///
	///
	headings(3.profit_stat = `""{bf:Facility Characteristics}" """' ///
		share_lpn_10 = `""{bf:Staff Characteristics (for 10pp increase){sup:c}}" """' ///
		paymcaid_10 = `""{bf:Resident Characteristics (for 10pp increase){sup:c}}"" ""' ///
		trump_biden_diff_10 = `""{bf:County Characteristics (for 10pp increase){sup:c}}" """', labsize(tiny) labgap(-73)) ///
	///
	coeflabels( ///
		///Facility Characteristics
		*2.profit_stat = `""Government Owned" "Percentage = `govt_own_percent'""' ///
		3.profit_stat = `""For Profit" "Percentage = `for_profit_percent'""' ///
		numberofcertifiedbeds_10 = `""Facility Size (for 10 bed increase)" "Mean = `numberofcertifiedbeds_real_mean', SD = `numberofcertifiedbeds_real_sd'""' ///
		1.chain = `""Part of Chain" "Percentage = `chain_percent'""' ///
		fivestar = `""Overall Quality Score" "Mean = `fivestar_real_mean', SD = `fivestar_real_sd'""' ///
		employee_count_10 = `""Staff Size{bf:{sup:a}} (for 10 employee increase)" "Mean = `employee_count_real_mean', SD = `employee_count_real_sd'""' ///
		staff_death100 = `""Staff COVID-19 Deaths per 100 beds{bf:{sup:b}}" "Mean = `staff_death100_real_mean', SD = `staff_death100_real_sd'""' ///
		res_death100 = `""Resident COVID-19 Deaths per 100 beds{bf:{sup:b}}" "Mean = `res_death100_real_mean', SD = `res_death100_real_sd'""' ///
		///Staff Characteristics
		share_lpn_10 = `""Percent LPN{bf:{sup:d}}" "Mean = `share_lpn_real_mean', SD = `share_lpn_real_sd'""' ///
		share_rn_10 = `""Percent RN{bf:{sup:e}}" "Mean = `share_rn_real_mean', SD = `share_rn_real_sd'""' ///
		share_nurse_ctr_10 = `""Percent Contract Staff{bf:{sup:f}}" "Mean = `share_nurse_ctr_real_mean', SD = `share_nurse_ctr_real_sd'""' ///
		dc_exp_10 = `""Percent with >33 Weeks Tenure{bf:{sup:g}}" "Mean = `dc_exp_real_mean', SD = `dc_exp_real_sd'""' ///
		share_nonwhite_10 = `""Percent non-White{bf:{sup:h}}" "Mean = `share_nonwhite_real_mean', SD = `share_nonwhite_real_sd'""' ///
		share_u29_10 = `""Percent Age <29{bf:{sup:h}}" "Mean = `share_u29_real_mean', SD = `share_u29_real_sd'""' ///
		share_female_10 = `""Percent Female{bf:{sup:h}}" "Mean = `share_female_real_mean', SD = `share_female_real_sd'""' ///
		///Resident Characteristics
		paymcaid_10 = `""Percent with Medicaid" "Mean = `paymcaid_real_mean', SD = `paymcaid_real_sd'""' ///
		pct_nonwhite_10 = `""Percent non-White" "Mean = `pct_nonwhite_real_mean', SD = `pct_nonwhite_real_sd'""' ///
		///County Characteristics
		trump_biden_diff_10 = `""Republican Vote Margin" "Mean = `trump_biden_diff_real_mean', SD = `trump_biden_diff_real_sd'""' ///
		county_vax_rate_10 = `""Adult Vaccination Coverage" "Mean = `county_vax_rate_real_mean', SD = `county_vax_rate_real_sd'""', notick labgap(-70)) ///
	r1title("{bf:Estimate         P-Value}", size(1.4) pos(1) xoffset(30) yoffset(-2.7)) ///
	mlabel(cond(@b < 0, string(@b, "%9.2f") + "             " + cond(@pval < 0.001, "< 0.001", "   " + string(@pval, "%9.3f")), ///
		" " + string(@b, "%9.2f") + "             " + cond(@pval < 0.001, "< 0.001", "   " + string(@pval, "%9.3f"))))


********************************************************************************
*The actual single line version of the forest plot
coefplot (staff_cont, drop(2.profit_stat 2.chain nonwhite_miss staff_size_miss rn_share_miss lpn_share_miss share_ctr_miss share_nonwhite_miss countyvax_miss fivestar_miss _cons exp_dc_miss) label(Staff) offset(0.22)) ///
	(res_cont, drop(2.profit_stat 2.chain nonwhite_miss staff_size_miss rn_share_miss lpn_share_miss share_ctr_miss share_nonwhite_miss countyvax_miss fivestar_miss _cons exp_dc_miss) label(Residents) offset(-0.22)), ///
	drop(_cons) ciopt(lwidth(thin)) ///
	msize(vsmall) mcolor(%50) msymbol(Dh) ///
	graphregion(fcolor(white) margin(l=60)) bgcolor(white) ///
	legend(pos(6) region(color(none)) xoffset(-7) yoffset(-3) size(vsmall) ) ///
	xlab(, labsize(tiny)) xtitle("Estimated Marginal Change in Vaccination Coverage (pp)", size(tiny)) xscale(titlegap(2)) ///
	xline(0, lcolor(gray%70) lpattern(dash)) ///
	ylab(, nogrid labsize(tiny)) yscale(noline alt) ///
	///
	headings(3.profit_stat = `""{bf:Facility Characteristics}" """' ///
		share_lpn_10 = `""{bf:Staff Characteristics (for 10pp increase){sup:c}}" """' ///
		paymcaid_10 = `""{bf:Resident Characteristics (for 10pp increase){sup:c}}"" ""' ///
		trump_biden_diff_10 = `""{bf:County Characteristics (for 10pp increase){sup:c}}" """', labsize(tiny) labgap(-73)) ///
	///
	coeflabels( ///
		///Facility Characteristics
		*2.profit_stat = `""Government Owned" "Percentage = `govt_own_percent'""' ///
		3.profit_stat = `""For Profit" "Percentage = `for_profit_percent'""' ///
		numberofcertifiedbeds_10 = `""Facility Size (for 10 bed increase)" "Mean = `numberofcertifiedbeds_real_mean', SD = `numberofcertifiedbeds_real_sd'""' ///
		1.chain = `""Part of Chain" "Percentage = `chain_percent'""' ///
		fivestar = `""Overall Quality Score" "Mean = `fivestar_real_mean', SD = `fivestar_real_sd'""' ///
		employee_count_10 = `""Staff Size{bf:{sup:a}} (for 10 employee increase)" "Mean = `employee_count_real_mean', SD = `employee_count_real_sd'""' ///
		staff_death100 = `""Staff COVID-19 Deaths per 100 beds{bf:{sup:b}}" "Mean = `staff_death100_real_mean', SD = `staff_death100_real_sd'""' ///
		res_death100 = `""Resident COVID-19 Deaths per 100 beds{bf:{sup:b}}" "Mean = `res_death100_real_mean', SD = `res_death100_real_sd'""' ///
		///Staff Characteristics
		share_lpn_10 = `""Percent LPN{bf:{sup:d}}" "Mean = `share_lpn_real_mean', SD = `share_lpn_real_sd'""' ///
		share_rn_10 = `""Percent RN{bf:{sup:e}}" "Mean = `share_rn_real_mean', SD = `share_rn_real_sd'""' ///
		share_nurse_ctr_10 = `""Percent Contract Staff{bf:{sup:f}}" "Mean = `share_nurse_ctr_real_mean', SD = `share_nurse_ctr_real_sd'""' ///
		dc_exp_10 = `""Percent with >33 Weeks Tenure{bf:{sup:g}}" "Mean = `dc_exp_real_mean', SD = `dc_exp_real_sd'""' ///
		share_nonwhite_10 = `""Percent non-White{bf:{sup:h}}" "Mean = `share_nonwhite_real_mean', SD = `share_nonwhite_real_sd'""' ///
		share_u29_10 = `""Percent Age <29{bf:{sup:h}}" "Mean = `share_u29_real_mean', SD = `share_u29_real_sd'""' ///
		share_female_10 = `""Percent Female{bf:{sup:h}}" "Mean = `share_female_real_mean', SD = `share_female_real_sd'""' ///
		///Resident Characteristics
		paymcaid_10 = `""Percent with Medicaid" "Mean = `paymcaid_real_mean', SD = `paymcaid_real_sd'""' ///
		pct_nonwhite_10 = `""Percent non-White" "Mean = `pct_nonwhite_real_mean', SD = `pct_nonwhite_real_sd'""' ///
		///County Characteristics
		trump_biden_diff_10 = `""Republican Vote Margin" "Mean = `trump_biden_diff_real_mean', SD = `trump_biden_diff_real_sd'""' ///
		county_vax_rate_10 = `""Adult Vaccination Coverage" "Mean = `county_vax_rate_real_mean', SD = `county_vax_rate_real_sd'""', notick labgap(-70)) ///
	r1title("{bf:Estimate         P-Value}", size(1.4) pos(1) xoffset(30) yoffset(-2.7)) ///
	ymlabel(`s(mlbl1)', angle(0) notick axis(1) add custom labcolor(green) labgap(4) labsize(tiny)) ///
	ymlabel(`s(mlbl2)', angle(0) notick axis(1) add custom labcolor(orange) labgap(4) labsize(tiny))

graph display, ysize(10) xsize(9.5) margin(l-22)
graph export "$path/Results/forest_8_12_21_singleline_update.png", as(png) replace
graph export "$path/Results/forest_8_12_21_singleline_update.pdf", as(pdf) replace

*End of do-file
