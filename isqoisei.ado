
*
*!!! REFERENCE(S):
*!!!
*!!! Ganzeboom, Harry B.G.; Treiman, Donald J. (2019): 
*!!!	International Stratification and Mobility File: Conversion Tools. Amsterdam: 
*!!! 	Department of Social Research Methodology, 
*!!!	http://www.harryganzeboom.nl/ismf/index.htm. <last revised: 2019-10-05>.
*

*******************************************************************************************
*  Version 0.2: 2020-07-01
*******************************************************************************************
*  Dennis Föste-Eggers	
*
*  German Centre for Higher Education Research and Science Studies (DZHW)
*  Lange Laube 12, 30159 Hannover         
*  Phone: +49-(0)511 450 670-114		
*  E-Mail (1): foeste-eggers@dzhw.eu  	
*  E-Mail (2): dennis.foeste@gmx.de
*
*******************************************************************************************
*  Program name: isqoisei.ado     
*  Program purpose: Assignment of ISEI-08 scores to ISCO-08 codes, as
*					provided by Ganzeboom & Treiman (2019).			
*******************************************************************************************
*  Changes made:
*  Version 0.1: added GPL 
*  Version 0.2: added checks   
*******************************************************************************************
*  License: GPL (>= 3)
*     
*	isqoisei.ado for Stata
*   Copyright (C) 2020 Foeste-Eggers, Dennis 
*
*   This program is free software: you can redistribute it and/or modify
*   it under the terms of the GNU General Public License as published by
*   the Free Software Foundation, either version 3 of the License, or
*   (at your option) any later version.
*
*   This program is distributed in the hope that it will be useful,
*   but WITHOUT ANY WARRANTY; without even the implied warranty of
*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*   GNU General Public License for more details.
*
*   You should have received a copy of the GNU General Public License
*   along with this program.  If not, see <https://www.gnu.org/licenses/>.
*
*******************************************************************************************
*  Citation: This code is © D. Foeste-Eggers, 2020, and it is made 
*				 available under the GPL license enclosed with the software.
*
*!			Over and above the legal restrictions imposed by this license, if you use this 	!
*! 			program for any (academic) publication then you are obliged to provide proper 	!
*!			attribution. 																	!
*
*   D. Foeste-Eggers isqoisei.ado for Stata, v0.2 (2020). 
*			[weblink].
*
*******************************************************************************************
*
*!!! REFERENCE(S):
*!!!
*!!! Ganzeboom, Harry B.G.; Treiman, Donald J. (2019): 
*!!!	International Stratification and Mobility File: Conversion Tools. Amsterdam: 
*!!! 	Department of Social Research Methodology. 
*!!!	http://www.harryganzeboom.nl/ismf/index.htm. <last revised: 2019-10-05>.

*tempname temp_global

cap program drop syntaxtest
program define syntaxtest  , nclass

	syntax  newvarlist(min=1 numeric)  // , anything(everything)
	
	*foreach var of varlist `newvarlist' {
	*	local nvl = `"`nvl' `var'"' 
	*}
	**tempname temp_global
	*global temp_global = `"`nvl'"'
	
end



cap program drop isqoisei
program define isqoisei  , nclass
	version 15
	
	if ("`c(excelsupport)'" != "1") {
		dis as err `"import excel is not supported on this platform."'
		exit 198
	}
	
	syntax varlist [if] [in] , 						///
								XLSfile(passthru)		///
								GENerate(namelist)		///
								[sheet(passthru)		///
								cellrange(passthru)		///  undocumented	
								assignment(passthru)	///  undocumented
								duplicates(namelist max=4)    ///  undocumented
								/// ideas:	TAG(namelist), FORCE(Priority),	
								]	//  	PRE- & SUFFIX, use more columns, 
									// 		use of string functions


			qui {
			*if `"`xlsfile'"' ~= `""' { // ggf. später nutzen und Standarddatei mitliefern
				local xlsfile = trim(`"`xlsfile'"')
				local xlsfile = subinstr(`"`xlsfile'"',`"xlsfile("',`""',1)
				local xlsfile = subinstr(`"`xlsfile'"',`"xlsfil("',`""',1)
				local xlsfile = subinstr(`"`xlsfile'"',`"xlsfi("',`""',1)
				local xlsfile = subinstr(`"`xlsfile'"',`"xlsf("',`""',1)
				local xlsfile = subinstr(`"`xlsfile'"',`"xls("',`""',1)
				di `"`xlsfile'"'
				di `"`=usubstr(`"`xlsfile'"',1,1)'"'
				di `"`=ustrlen(`"`xlsfile'"')-3'"'
				local pos = `=ustrlen(`"`xlsfile'"')'
				di `"`=usubstr(`"`xlsfile'"',`pos',1)'"'
				*di `"`=usubstr(`"`xlsfile'"',`=ustrlen(`xlsfile')-3',1)'"'
				if substr(`"`xlsfile'"',`pos',1)==`")"' {
					local xlsfile =  substr(`"`xlsfile'"',1,`=`pos'-1')
				}
				confirm file `xlsfile'
			*}
				if `"`assignment'"' ~= `""' {
					local assignment = trim(`"`assignment'"')
					local assignment = subinstr(`"`assignment'"',`"assignment("',`""',1)
					local pos = `=ustrlen(`"`assignment'"')'
					if substr(`"`assignment'"',`pos',1)==`")"' {
						local assignment =  substr(`"`assignment'"',1,`=`pos'-1')
					}
				}
				local dlist = 0
				local ddrop = 0
				local dtag  = 0
				if `"`duplicates'"' ~= `""' {
					local duplicates = trim(`"`duplicates'"')
					local duplicates = subinstr(`"`duplicates'"',`"duplicates("',`""',1)
					local pos = `=ustrlen(`"`duplicates'"')'
					if substr(`"`duplicates'"',`pos',1)==`")"' {
						local duplicates =  substr(`"`duplicates'"',1,`=`pos'-1')
					}
					local duplicates = `" "' + `"`duplicates'"' + `" "'
					if strpos(`"`duplicates'"', " list ")>0 {
						local dlist = 1
						local duplicates = subinstr(`"`duplicates'"',`" list "',`" "',.)
					} 
					if strpos(`"`duplicates'"', " drop ")>0 {
						local ddrop = 1
						local duplicates = subinstr(`"`duplicates'"',`" drop "',`" "',.)
					} 
					if strpos(`"`duplicates'"', " tag ")>0 {
						local dtag = 1
						local duplicates = subinstr(`"`duplicates'"',`" tag "',`" "',1)
						local duplicates = subinstr(`"`duplicates'"',`"  "',`" "',.)
						local duplicates = subinstr(`"`duplicates'"',`"  "',`" "',.)
						local duplicates = trim(`"`duplicates'"')
						
						local dindi : word 1 of `duplicates'
						local di_wc : word count `duplicates'
						*di `""`di_wc'""'
						if `di_wc'==0 {
								local dtag = 0
								di as txt in red "tag option set to 0, because of missing variable name"
						}
							else if `di_wc' > 1 {
								di as txt in red "more than one potential variable name specified:" 
								di as txt in red `"`duplicates'"'
								di as txt in red `"`dindi' assumed to be intended"'
							}
								else{
								*if `"`dindi'"'==`""' {
								*		local dtag = 0
								*		di as txt in red "tag option set to 0, because of missing variable name"
								*}
								*else {
									cap syntaxtest `dindi'
									if _rc {
										local dtag = 0
										di as txt in red `"tag option set to 0, because a variable with the name `dindi' exists already"'
									}
								}
					}
				}
			
			}
			* di `"syntaxtest `generate' , `xlsfile'"'
			qui syntaxtest `generate'   // ,  `xlsfile'
			
			if `"`assignment'"' != `""' local asterisk = `"*"'
			if `"`assignment'"' == `""' local ast3r1sk = `"*"' 
			
			
			`ast3r1sk' di as result  ""
			`ast3r1sk' di `"Assignment `assignment'"'
			`ast3r1sk' di "      via isqoisei.ado by Foeste-Eggers (2020, Version 0.2)"	
			
			
			
			`asterisk' di as result  ""
			`asterisk' di "Assignment of ISEI-08 scores to ISCO-08 codes, as provided by Ganzeboom & Treiman (2019)." 
			`asterisk' di "      via isqoisei.ado by Foeste-Eggers (2020, Version 0.2)"
			`asterisk' di ""			
			`asterisk' di "Reference(s): Ganzeboom, Harry B.G.; Treiman, Donald J. (2019):"
			`asterisk' di "                International Stratification and Mobility File: Conversion Tools. " 
			`asterisk' di "                Amsterdam: Department of Social Research Methodology."
			`asterisk' di "                http://www.harryganzeboom.nl/ismf/index.htm. <last revised: 2019-10-05>."
			`asterisk' di ""
			
			noi {
				preserve 
					* Importieren der Daten
					* --> relativen statt fixen Dateibezug einbauen
					noi di `""'
					noi di `"xls info:"'
					if `"`sheet'"' == "" {
							import excel `xlsfile', sheet("Tabelle1")  firstrow clear 
						}
						else if `"`sheet'"' == "" {
								import excel `xlsfile', `sheet'  firstrow clear 
							}
							else import excel `xlsfile', `sheet' `cellrange' firstrow clear 
			* qui {
			* 	preserve 
			* 		* Importieren der Daten
			* 		* --> relativen statt fixen Dateibezug einbauen
			* 		import excel "P:\panel\Ados\Diss_Dennis\isei08.xlsx", sheet("Tabelle1") firstrow clear
					
					local countvar = 0
					foreach var of varlist _all {
						local ++countvar
						tempvar `countvar'
						clonevar `"``countvar''"' = `var'
						drop `var'
						if `countvar' == 2 {
							if `dtag' == 1 {
								noi duplicates tag `1', gen(`dindi')
							}
							if `dlist' == 1 {
								noi di "duplicates in xls file:"
								if `dtag' == 1 {
									tempfile xlsduplos
									qui save `"`xlsduplos'"', replace
										qui duplicates drop `1' `2' , force
										rename `dindi' freq
										keep `1' `2' freq
										clonevar var1 = `1'
										clonevar var2 = `2'
										drop `1' `2'
										sort var1
										noi list var1 var2 freq if freq>0
									qui use `"`xlsduplos'"', clear
								}
								else noi duplicates list `1' 
							}
							if `ddrop' ==1 duplicates drop `1', force
						}
					}
					if `countvar'==1 {
						di `"too few variables in xls file"'
						exit 102
					}
					
					tempfile isei08temp
					qui save `"`isei08temp'"'
					
				restore
			}
			
	*mark sample		
	tempvar touse 
	mark `touse' `if' `in'
	
	
	local n = 0
	noi foreach var of varlist `varlist' {
	    local ++n 
		* noi sum _all
		*cap drop isco08_tempvar 
	    gen `1' = `var' if `touse'
		tempvar rslt_mrg
		* tempname rslt_mrg
		noi cap merge m:1 `1'  using ///
		`"`isei08temp'"' , ///  
		generate(`rslt_mrg')
		if _rc {
			local rc = _rc
			cap drop `rslt_mrg'
			if `rc'==459 noi di in red "check xls file for duplicates"
			forvalues v = 1(1)`countvar' {
				cap drop `"``v''"'
			}
			exit `rc'
		}
		qui drop if (`rslt_mrg'==2)
		noi di `""'
		noi di as result "no score could be assigned to:"
		noi tab `1' if (`rslt_mrg'==1), mi nolab
		local name : word `n' of `generate'
		noi clonevar  `name' = `2'
		* hier tag-Option einsetzen
		drop  `rslt_mrg'
		forvalues v = 1(1)`countvar' {
				cap drop `"``v''"'
		}
	}
	
	
end

	
					