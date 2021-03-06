/*==================================================
project:       Create text file and other povcalnet files
Author:        R.Andres Castaneda Aguilar
E-email:       acastanedaa@worldbank.org
url:
Dependencies:  The World Bank
----------------------------------------------------
Creation Date:     9 Aug 2019 - 08:51:26
Modification Date:
Do-file version:    01
References:
Output:
==================================================*/

/*==================================================
0: Program set up
==================================================*/
program define pcn_create, rclass
syntax [anything(name=subcmd id="subcommand")],  ///
[                                                ///
countries(string)                                ///
Years(numlist)                                   ///
maindir(string)                                  ///
type(string)                                     ///
survey(string)                                   ///
replace                                          ///
vermast(string)                                  ///
veralt(string)                                   ///
MODule(string)                                   ///
server(string)                                   ///
newsynth					                               ///
clear                                            ///
pause                                            ///
*                                                ///
]

version 16

*---------- conditions
if ("`pause'" == "pause") pause on
else                      pause off


* ---- Initial parameters

local date = date("`c(current_date)'", "DMY")  // %tdDDmonCCYY
local time = clock("`c(current_time)'", "hms") // %tcHH:MM:SS
local date_time = `date'*24*60*60*1000 + `time'  // %tcDDmonCCYY_HH:MM:SS
local datetimeHRF: disp %tcDDmonCCYY_HH:MM:SS `date_time'
local datetimeHRF = trim("`datetimeHRF'")
local user=c(username)



/*==================================================
1: primus query
==================================================*/
qui {
	
	/*
	pcn_primus_query, countries(`countries') years(`years') ///
	`pause' gpwg
	pause after primus query
	*/
	
	pcn load price, clear `pause'
	rename countrycode country
	tostring _all, replace
	
	pause create - after loading price framework data
	
	/*==================================================
	2: Condition to filter data
	==================================================*/
	
	
	* Countries
	if (lower("`countries'") != "all" ) {
		local countrylist ""
		local countries = upper("`countries'")
		local countrylist: subinstr local countries " " "|", all
		keep if regexm(country, "`countrylist'")
	}
	
	** years
	if ("`years'" != "") {
		numlist "`years'"
		local years  `r(numlist)'
		local yearlist: subinstr local years " " "|", all
		keep if regexm(year, "`yearlist'")
	}
	
	if ("`vermast'" != "") {
		local vmlist: subinstr local vermast " " "|", all
		keep if regexm(vermast, "`vmlist'")
	}
	
	if ("`veralt'" != "") {
		local valist: subinstr local veralt " " "|", all
		keep if regexm(veralt, "`valist'")
	}
	
	qui ds
	local varlist = "`r(varlist)'"
	
	mata: R = st_sdata(.,tokens(st_local("varlist")))
	local n = _N
	
	* mata: S = st_sdata(.,tokens("survname"))
	mata: CV = st_sdata(.,tokens("survey_coverage"))
	
	/*==================================================
	2:  Loop over surveys
	==================================================*/
	noi disp as txt ". " in y "= saved successfully"
	noi disp as txt "s " in y "= skipped - already exists"
	noi disp as err "e " in y "= error reading"
	noi disp as err "x " in y "= error in process"
	
	
	mata: P  = J(0,0, .z)   // matrix with information about each survey
	local i = 0
	local previous ""
	noi _dots 0, title(Creating PCN files) reps(`n')
	while (`i' < `n') {
		local ++i
		local status   ""
		local dlwnote  ""
		local iscover  ""
		local iscoverpr  ""
		
		mata: pcn_ind(R)
		
		/* if ("`previous'" == "`country'-`year'") continue
		else local previous "`country'-`year'" */
		
		//------------ get metadata
		
		pause create - before searching for data 
		
		local dlwnote `"pcn inventory, count(`country') year(`year') type(GMD) survey("`survey'") `pause' `clear' `options'"'
		
		cap `dlwnote'
		
		if (_rc) {
			local status "error. loading inventory"
			mata: P = pcn_info(P)
			noi _dots `i' 2
			continue
		}
		if (_N == 0) {
			local status "error. No survey available"
			mata: P = pcn_info(P)
			noi _dots `i' 2
			continue
		}
		
		
		// Get the right hierarchical module
		levelsof module, local(mods) clean
		local modules = "GPWG BIN HIST"  // the order matters
		
		local available_modules: list modules & mods
		if ("`available_modules'" != "") {
			local selected_module = 0
			foreach mod of local modules {
				local selected_module: list mod in mods
				local module = "`mod'"
				
				if `selected_module' == 0    continue
				keep if module == "`module'" 
				continue, break 
			}
			
			pause: after inventory is loaded and filtered 
			
			local id  = id[1]
			* local survin    = "`r(survin)'"
			if regexm("`id'", "(.+)(_[a-zA-Z\-]+)$") local survid = regexs(1)
			local survey_id = "`survid'"
			local surdir    =  "`maindir'/" + countrycode + "/" + dir1 
			
		}
		
		// If not modules is available, then use synth data
		else {
			local module "isynth"
			// NOTE: We have to figure out a way to execute the code for synthetic data
			// only for the countries that require it. 
			
			
			/* 
			
			cap pcn_create_isynth, country(`country') year(`year') maindir("`maindir'") /* 
			*/ survey(`survey') server(`server') `newsynth' `replace' `clear' `pause' 
			
			if (_rc) {
				local status "error. synthetic data"
				local dlwnote `"pcn_create_isynth, country(`country') year(`year') maindir("`maindir'") survey(`survey') server(`server') `newsynth' `replace' `clear' `pause'"'
				mata: P = pcn_info(P)
				noi _dots `i' 2
				continue
			} // end of isynth error
			
			 */
			 
			 continue
		} // end of synth data
		
		pause create - after having searched for data 
		
		cap confirm new file "`surdir'/`survid'/Data/`survid'_PCN.dta"
		if (_rc & "`replace'" == "") {  //  File exists
			
			local status "skipped"
			local dlwnote "File exists. Not replaced"
			mata: P = pcn_info(P)
			
			noi _dots `i' -1
			continue // there is not need to load data or check datasignature
		}
		*--------------------2.2: Load data
		
		cap pcn load, count(`country') year(`year') type(GMD) /*
		*/ module(`module') survey("`survey'")  /*
		*/ `pause' clear `options'
		
		if (_rc) {
			
			local status "error. loading"
			local dlwnote "pcn load, count(`country') year(`year') type(`type') survey("`survey'")  module(`module') `pause' `clear' `options'"
			mata: P = pcn_info(P)
			noi _dots `i' 2
			continue
			
		}
		
		pause after loading data 
		/*==================================================
		3:  Clear and save data
		==================================================*/
		*----------1.1: clean weight variable
		
		cap confirm var weight, exact
		if (_rc) {
			cap confirm var weight_p, exact
			if (_rc == 0) rename weight_p weight
			else {
				cap confirm var weight_h, exact
				if (_rc == 0) rename weight_h weight
				else {
					local dlwnote "no weight variable found for count(`country') year(`year') type(GMD) survey("`survey'")  module(`module')"
					local status "error. cleaning"
					mata: P = pcn_info(P)
					noi _dots `i' 1
					continue
				}
			}
		}
		
		
		* make sure no information is lost
		svyset, clear
		recast double welfare
		recast double weight
		
		* monthly data
		// Already monthly data for IDN 1993, 1996, 1998 and 1999
		*if ("`country'"!="IDN") | !inlist(`year',1993,1996,1998,1999)	{
		
		replace welfare=welfare/12
		
		
		* special treatment for IDN and IND
		if inlist("`country'", "IND", "IDN") {
			keep weight welfare urban
			preserve
			keep if urban==0
			tempfile rfile
			char _dta[cov]  "R"
			save `rfile'
			
			restore, preserve
			
			keep if urban==1
			char _dta[cov]  "U"
			tempfile ufile
			save `ufile'
			
			restore			
			
			keep welfare weight urban
			compress
			
			local urban "urban"
			char _dta[cov]  "A"
			tempfile wfile
			save `wfile'
			
			
			local cfiles "`rfile' `ufile' `wfile'"
		} // end of special cases
		else {
			// if urban is available
			cap confirm variable urban 
			if (_rc) {
				local urban ""
			}
			else{
				local urban "urban"
			}
			
			//  Include alternative welfare variable if available
			if ("`oth_welfare1_var'" != "") {
				cap gen alt_welfare = `oth_welfare1_var'/12
				if (_rc) {
					local dlwnote "alternative variable `oth_welfare1_var' is not available in  count(`country') year(`year') type(GMD) survey("`survey'")  module(`module')"
					local status "error. cleaning"
					mata: P = pcn_info(P)
					noi _dots `i' 1
					continue
				}
			} 
			else {
				gen alt_welfare = .
			}
			
			pause create - after generating alternative welfare
			
			* keep weight and welfare
			keep weight welfare `urban' alt_welfare
			missings dropvars, force
			
			
			tempfile wfile
			char _dta[cov]  ""
			save `wfile'
			local cfiles "`wfile'"
		}
		
		foreach file of local cfiles {
			
			use `file', clear
			sort welfare
			
			local cc: char _dta[cov]  // country coverage
			if ("`cc'" != "") {
				local cov "-`cc'"
			}
			else {
				local cc "N"
				local cov ""
			}
			
			* drop missing values
			drop if welfare < 0 | welfare == .
			drop if weight <= 0 | weight == .
			
			order weight welfare
			
			//========================================================
			// Check if data is the same as the previous one and save.
			//========================================================
			
			
			cap datasignature confirm using  "`surdir'/`survid'/Data/`survid'_PCN`cov'"
			local dsrc = _rc
			if (`dsrc' == 9) {  // if signature does not exist
				cap mkdir "`surdir'/`survid'/Data/_vintage"
				preserve   // I cannot use  copy because I need the pcn_datetime char
				
				use "`surdir'/`survid'/Data/`survid'_PCN`cov'.dta", clear
				cap save "`surdir'/`survid'/Data/_vintage/`survid'_PCN`cov'_`:char _dta[creationdate]'", replace
				if (_rc) {
					save "`surdir'/`survid'/Data/_vintage/`survid'_PCN`cov'_`date_time'", replace
				}
				
				restore
			}
			if (`dsrc' != 0 | "`replace'" != "") { // if different signature or replace
				cap datasignature set, reset /*
				*/ saving("`surdir'/`survid'/Data/`survid'_PCN`cov'", replace)
				
				char _dta[filename]         "`id'"
				* char _dta[survin]           "`survin'"
				char _dta[survid]           "`survid'"
				char _dta[surdir]           "`surdir'"
				char _dta[creationdate]     "`date_time'"
				char _dta[survey_coverage]  "`cc'"
				
				// Special case for IDN 2018 (should be deleted later)
				if ("`country'" == "IDN") {
					char _dta[welfaretype]  "CONS"
					char _dta[weighttype]   "aw"
				}
				
				
				//------------Uncollapsed data
				save "`surdir'/`survid'/Data/`survid'_PCN`cov'.dta", `replace'
				local status "saved"
				local dlwnote "OK. country(`country') year(`year') veralt(`veralt') cov `cc'"
				noi _dots `i' 0
				
			}
			else { // Skipped data has not change. 
				local status "skipped. data has not changed"
				local dlwnote "skipped. country(`country') year(`year') veralt(`veralt') cov `cc'"
				noi _dots `i' -1
				continue
			}
			
			mata: P = pcn_info(P)
		} // end of files loop
		
	} // end of while
	
	
	/*==================================================
	3: import results file
	==================================================*/
	
	*----------3.1:
	drop _all
	getmata (surveyid status dlwnote) = P
	
	* Add chars
	char _dta[pcn_datetimeHRF]    "`datetimeHRF'"
	char _dta[pcn_datetime]       "`date_time'"
	char _dta[pcn_user]           "`user'"
	
	
	*----------3.2:
	noi disp _n ""
	cap noi datasignature confirm using "`maindir'/_aux/pcn_create/pcn_create"
	if (_rc) {
		
		datasignature set, reset saving("`maindir'/_aux/pcn_create/pcn_create", replace)
		save "`maindir'/_aux/pcn_create/_vintage/pcn_create_`date_time'.dta"
		save "`maindir'/_aux/pcn_create/pcn_create.dta", replace
		
	}
	noi disp as result "Click {stata br:here} to see results"
	
} // end of qui
noi disp _n(2) ""

end


/*====================================================================
Mata functions
====================================================================*/

findfile "pcn_functions.mata"
include "`r(fn)'"


exit
/* End of do-file */

><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><

Notes:
1.
2.
3.


Version Control:


