
*Check for uninstalled packages.
local required_ados calipmatch carryforward gtools ftools winsor2 psmatch2 binscatter ///
	statastates unique estout frameappend fs strkeep distinct rangejoin rangestat ///
	geonear isvar cibar /*egenmore*/ grc1leg2 colrspace palettes heatplot rcspline cdfplot ///
	mylabels binscatter2 texresults spineplot coefplot nearmrg geodist missings

foreach x in `required_ados' {
	capture findfile `x'.ado
	
	if _rc == 601 {
		
		if "`x'" == "gtools" {
			gtools, upgrade
		}
		
		else if "`x'" == "grc1leg2" {
			net install grc1leg2, from("http://digital.cgdev.org/doc/stata/MO/Misc") replace
		}
		
		else if "`x'" == "binscatter2" {
			net install binscatter2, from("https://raw.githubusercontent.com/mdroste/stata-binscatter2/master") replace
		}
		
		else if "`x'" == "nprobust" {
			net install nprobust, from("https://raw.githubusercontent.com/nppackages/nprobust/master/stata") replace
		}

		else {
			ssc install `x'
		}
	}
	
	else {
		display "`x' already installed."
	}
}
