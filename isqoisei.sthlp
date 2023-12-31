{smcl}
**!ado file version 0.2: 2020-07-01
help for {hi:isqoisei}{right: {browse "mailto:dennis.foeste@outlook.de":Dennis Foeste-Eggers}}
{hline}

{title:Title}

{phang}
{bf:isqoisei} {hline 1} Assignment of ISEI-08 scores to ISCO-08 codes


{title:Syntax}

{p 8 17 2}
{cmd:isqoisei} {varlist} {ifin} {cmd:,} {opth gen:erate(newvarlist)}  {opth xls:file(filename)} 
{p_end}


{title:Description}

{p 4}
{cmd:isqoisei} Assignment of ISEI-08 scores to ISCO-08 codes, as provided by Ganzeboom & Treiman (2019).
{p_end}


{title:Options}

{p 4}{opth gen:erate(newvarlist)} generates a new variable for each variable of {it:varlist} as specified in {it:newvarlist}.
{p_end}

{p 4}{cmd:xlsfile} allows users to use any xls(x) file with a mapping of scores (in column B) to codes (in column A).


{title:References}

{p 4}
Ganzeboom, Harry B.G.; Treiman, Donald J. (2019):
{p_end}
{p 8 17 2}
International Stratification and Mobility File: Conversion Tools. 
{p_end}
{p 8 17 2}
Amsterdam: Department of Social Research Methodology.
{p_end}
{p 8 17 2}
http://www.harryganzeboom.nl/ismf/index.htm. <last revised: 2019-10-05>.
{p_end}


{title:Examples}

{hline}

local var_list = "var1 var2 var3"

local praefix_isei "g_"
local  suffix_isei "_isei"

foreach var in `var_list' {
    
    di `"************** `var' **************"'
    
    local label : variable label `var' 
	
    cap drop `praefix_isei'`var'`suffix_isei'
    isqoisei `var' , gen(`praefix_isei'`var'`suffix_isei') xlsfile(`"C:\re_sources\isei08_exzerptSPS_df.xlsx"') // change the location of the file 
    label variable `praefix_isei'`var'`suffix_isei' `"`label' (ISEI-08)"'
}

{hline}

isqoisei isco_1 isco_2 isco_3 , gen(isei_1 isei_2 isei_3) xlsfile(`"C:\re_sources\isei08_exzerptSPS_df.xlsx"') // change the location of the file

{hline}