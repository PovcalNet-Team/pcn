/*==================================================
project:       create comparability database
Author:        David L. Vargas
E-email:       dvargasm@worldbank.org
url:
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:     2020-05-14  
Do-file version:    01
References:
Output:
==================================================*/

/*========================================================
0: Program set up
========================================================*/

program define pcn_compare, rclass
syntax [anything(name=subcmd id="subcommand")], ///
[                                             ///
IDvar(string)                                  ///
MAINv(string)                                  ///
server(string)                                 ///
DISvar(string)                                 ///
check(string)                                  ///
POVline(string)                                ///
TOLerance(integer 3)                           /// decimal places
listc(string)								 ///
SDLevel(string)								 ///
COUNtry(string)								 ///
REGion(string)								 ///
year(string)									 ///
FILLgaps                     				 ///
]

version 14

*---------- pause
if ("`pause'" == "pause") pause on
else                      pause off

//========================================================
// Start
//========================================================

qui { 
	
	/*================================================
	1: Check options definition and declare macros
	==================================================*/
	
	// relevant macros 
	if ("`idvar'" == "") loc idvar "regioncode countrycode year povertyline coveragetype datatype"
	else 				 loc idvar = lower("`idvar'")
	
	if ("`mainv'" == "")  loc mainv "headcount"
	else                  loc mainvar = lower("`mainv'")
	
	if ("`server'" == "") loc server "AR"
	else                  loc server = lower("`server'")
	
	if ("`check'" == "") loc check "main"
	else                 loc check = lower("`check'")
	
	if ("`disvar'" == "") loc disvar "main"
	else                 loc disvar = lower("`disvar'")
	
	if ("`sdlevel'" == "") loc sdlevel = 2 				
	
	if !inlist("`check'","main","all") {
    noi di as err "Check varibables must be set to: main or all"
		noi di as text "Check option forced to default"
		loc check "main"
	}
	
	if !inlist("`disvar'","diff","main","all") {
    noi di as err "Check varibables must be set to: main, diff or all"
		noi di as text "Check option forced to default"
		loc check "all"
	}
	
	/*================================================
	2: Get data
	==================================================*/
	
	// get testing data
	povcalnet, server(`server') povline(`povline') ///
				country(`country') region(`region') ///
				year(`year') `fillgaps' clear
	
	cap isid `idvar'
	if _rc {
		duplicates tag `idvar', gen(duplicate)
		keep if duplicate > 0
		lab var duplicate "Number of duplicities in case"
		noi di as err "The testing server has unnexpected duplicates" char(10)  as text "The process has stop, no duplicities should exist, check" char(10) as result "The data on memory contains the cases with duplicates"	
		noi tab duplicate
		qui err 459
		exit
	}
	
	if ("`check'" == "main"){
    keep `idvar' `mainv'
	}
	
	* apply tolerance
	local tl: disp _dup(`=`tolerance'-1') 0
	local tl = ".`tl'1"
	foreach mv of local mainv {
		replace `mv' = round(`mv', `tl')
	}
	
	tempfile serverd
	save `serverd'
	
	// Get current data
	povcalnet, povline(`povline') ///
				country(`country') region(`region') ///
				year(`year') `fillgaps' clear 
	
	if ("`check'" == "main"){
    keep `idvar' `mainv'
	}
	
	foreach mv of local mainv {
		replace `mv' = round(`mv', `tl')
	}
	
	tempfile PCN
	save `PCN'
	
	// Determine point status
	merge 1:1 `idvar' using `serverd', update gen(status)
	
	keep `idvar' status
	lab define statusl 1 "Dropped" 2 "New point" 3 "Unchanged" 4 "Udpade from missing" 5 "Changed (conflict)"
	lab values status statusl
	
	preserve 
	
	/*================================================
	3: Trace back changes                             
	==================================================*/
	
	keep if inlist(status,3,4,5)
	
	merge 1:1 `idvar' using `serverd', keep(match) nogen
	
	loc vlist 
	loc vlistt
	foreach var of varlist _all {
		if (!regexm("`idvar'","`var'") & "`var'" != "status"){
			cap confirm string var `var'
			if _rc {
				loc vlab: var label `var'
				rename `var' test_`var'
				lab var test_`var' "Testing: `vlab'"
				loc vlist "`vlist' `var'"
				loc vlistt "`vlistt' test_`var'"
				loc tvlist "`tvlist' `var' test_`var'"
			}
			else{
				drop `var'
			}
		}
	}
	
	merge 1:1 `idvar' using `PCN', keep(match) nogen
	
	keep `idvar' status `vlist' `vlistt'
	
	// difference in main values
	
	if ("`mainv'" == "all")  loc mainv "`vlist'"
	
	loc dvars
	foreach var of local mainv{
		cap confirm var `var'
		if (_rc == 0){
			gen d_`var' = `var' - test_`var'
			lab var d_`var' "difference in `var'"
			loc dvars "`dvars' d_`var'"
			loc mcall "`mcall' `var' test_`var'"
		}
	}
	
	tempfile changes
	save `changes'
	
	restore 
	
	
	// join to get the final dataset 
	merge 1:1 `idvar' using `changes', nogen
	
	order `idvar' status `dvars' `tvlist'
	
	if ("`disvar'" != "all") {
    if ("`disvar'" == "diff") {
	    keep `idvar' status `dvars'
		}
		if ("`disvar'" == "main"){
	    keep `idvar' status `dvars' `mcall'
		}
	}
	

	/*================================================
	4: Report results and return values
	==================================================*/
	
	// report back to user
	noi di as text "The status of observations is as follows:"
	noi tab status
	
	// list of problematic obs
	
	if (lower("`listc'")=="yes"){
		
		tempvar obsid
		egen `obsid' = concat(countrycode year), p(-)
		lab var `obsid' "Country-year"
		
		foreach var of local mainv{
			foreach v in mn_d_`var' sd_d_`var'{
				cap drop `v'
			}

			bysort regioncode: egen mn_d_`var' = mean(d_`var')
			bysort regioncode: egen sd_d_`var' = sd(d_`var')
						
			forv x = 1/`sdlevel' {
			// higher than variables
				cap drop ht_`x'sd_`var'
				gen ht_`x'sd_`var' = abs(d_`var') > (mn_d_`var' +   `x'*sd_d_`var') if d_`var' != .
				tab ht_`x'sd_`var'
				lab var  ht_`x'sd_`var' "Higher than `x' SD from mean" 
			}
		}
		
		levelsof regioncode, local(regions)
		
		forv x = 1/`sdlevel' {		
				loc vars "`vars' ht_`x'sd_`var'"
			}
			
		foreach vh of local vars{
			local lab: variable label `vh'
			foreach rg of local regions {
					noi di "List of problems `rg'"
					noi di "`lab'"
					noi tab `obsid' if regioncode == "`rg'" & `vh' == 1
			}
		}
		
		
		noi di as result "Comparison data load into memory"
	}
	
	
} // end qui

end
exit

/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:


