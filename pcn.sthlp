{smcl}
{* *! version 1.0.0 8jan2020}{...}
{cmd:help pcn}{right: ({browse "some link":SJ: ???})}
{hline}

{vieweralsosee "" "--"}{...}
{vieweralsosee "Install wbopendata" "ssc install wbopendata"}{...}
{vieweralsosee "Help wbopendata (if installed)" "help wbopendata"}{...}
{viewerjumpto   "Command description"   "pcn##desc"}{...}
{viewerjumpto "Parameters description"   "pcn##param"}{...}
{viewerjumpto "Options description"   "pcn##options"}{...}
{viewerjumpto "Subcommands"   "pcn##subcommands"}{...}
{viewerjumpto "Stored results"   "pcn##return"}{...}
{viewerjumpto "Examples"   "pcn##Examples"}{...}
{viewerjumpto "Disclaimer"   "pcn##disclaimer"}{...}
{viewerjumpto "How to cite"   "pcn##howtocite"}{...}
{viewerjumpto "References"   "pcn##references"}{...}
{viewerjumpto "Acknowledgements"   "pcn##acknowled"}{...}
{viewerjumpto "Authors"   "pcn##authors"}{...}
{viewerjumpto "Regions" "pcn_countries##regions"}{...}
{viewerjumpto "Countries" "pcn_countries##countries"}{...}
{title:Title}

{* Title}
{p2colset 10 17 16 2}{...}
{p2col:{cmd:pcn} {hline 2}}Stata package to manage {ul:{it:PovcalNet}} files and folders.{p_end}
{* short description}
{p 4 4 2}{bf:{ul:Description (short)}}{p_end}
{pstd}
The {cmd:pcn} command, throughout a series of subcommands, allows Stata users to manage the PovcalNet files and folders in a comprensive way. Using the command the user will be able to load data into stata, get the main aggregates, keep up with the latest updates in the datesets and more.{p_end}
{pstd}
A more comprensive {it:{help pcn##description:description}} is avialable {help pcn##description:below}.{p_end}

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:pcn:} [{it:{help pcn##subcommands:subcommand}}] [{cmd:,} {it:{help pcn##subcommands:Parameters}} {it:{help pcn##options:Options}}]

{p 4 4 2} Where parameters identify the characteristics of the file to be used. {p_end}

{p 4 4 2} {ul:{title:Subcommands}}
The available subcommnds are the following:

{col 5}Subcommand{col 30}Description
{space 4}{hline}
{p2colset 5 30 29 2}{...}
{p2col:{opt load}}Loads into memory the file corresponding the parameters given by the user.{p_end}
{p2col:{opt create}}Create weights and index (why?){p_end}
{p2col:{ul:{opt group}}{opt data}}Tricky thing, (Somthing is not working w/ this command CHECK).{p_end}
{p2col:{opt download}}(Rarely used). Downloads the latest file(s) availible. Should be only used when mayor updates are released.{p_end}
{space 4}{hline}
{p 4 4 2}
Further explanation on the {help pcn##subcommands:subcommands} is found {help pcn##subcommands:below}.{p_end}


{p 4 4 2} {ul:{title:Parameters}}
The {bf:pcn} command requires the following parameters:

{col 5}Parameter{col 30}Description
{space 4}{hline}
{p2col:{opt country:}(3-letter code)}List of country code (accepts multiples) [{it:all} is not accepted]{p_end}
{p2col:{opt years:}(numlist|string)}List of years (accepts multiples) [all is not accepted] {p_end}
{p2col:{opt type:}(string)}Type ?{p_end}
{space 4}{hline}
{p 4 4 2}
Further explanation on the {help pcn##param:parameters} is found {help pcn##param:below}.{p_end}

{p 4 4 2} {ul:{title:Options}}
The {bf:pcn} command has the following options available:

{col 5}Option{col 30}Description
{space 4}{hline}
{p2col:{opt clear:}}Replaces data in memory{p_end}
{space 4}{hline}
{p 4 4 2}
Further explanation on the {help pcn##options:Options} is found {help pcn##options:below}. {p_end}

{p 4 4 2}
{bf: Note: pcn} requires {help datalibweb:datalibweb} access.

{marker sections}{...}
{title:Sections}

{pstd}
Sections are presented under the following headings:

                {it:{help pcn##description:Command description}}
                {it:{help pcn##subcommands:Parameters description}}
                {it:{help pcn##param:Parameters description}}
                {it:{help pcn##options:Options description}}
                {it:{help pcn##:Examples}}
                {it:{help pcn##disclaimer:Disclaimer}}
                {it:{help pcn##termsofuse:Terms of use}}
                {it:{help pcn##howtocite:How to cite}}

{marker description}{...}
{title:Description}
{pstd}
the {cmd:pcn} command(s) allows Stata users with access to the World Bank's {help datalibweb:datalibweb} platform to {p_end}



{marker subcommands}{...}
{title:Subcommands}

{dlgtab:load}
{dlgtab:create}
{dlgtab:groupdata}
{dlgtab:download}

{marker param}{...}
{title:Parameters}

{p 4 4 2}
The parameters are the main input to define the data source to work with. Beyond the choosen sucommand the parameters work in a similar fashion:{p_end}

{p 8 17 2}
{cmdab:pcn:} [{it:{help pcn##subcommands:subcommand}}] [{cmd:,} {opt countr:ies(3-letter code)} {opt year(####)} {opt type(string)} {it:{help pcn##options:Options}}]{p_end}

{p 4 4 2}
The {opt countr:ies} and {opt year} are (in general) mandatory, nonetheless in some cases the omision will not result in an error, but insted it will deploy a list of the availible data given the parameters input. The {opt type} parameter determines the {p_end}

{marker options}{...}
{title:Options}

{dlgtab:Main}

{p2col:{opt clear:}}Replaces data in memory{p_end}

{dlgtab:Versions}

{p2col:{opt verm:aster(#)}}Specifies the master version to be used. By default, the latest version is selected if it is omitted.{p_end}

{p2col:{opt vera:lt(#)}}Specifies the harmonization version to be used. By default, the latest harmonization version is selected for the latest master version if it is omitted. {p_end}

{marker examples}{...}
{title:Examples}


{marker disclaimer}{...}
{title:Disclaimer}


{marker termsofuse}{...}
{title:Terms of use}

{marker howtocite}{...}
{title:How to cite}
