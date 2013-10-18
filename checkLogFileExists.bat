@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

:::-- Checks if log files with specific date format exists and returns JSON Array
:::
:::-- Prerequisites, Dependencies: 
::: -	parameter (config file)
::: -	getDateMinusArg.vbs (to get the CORRECT date)
::: -	getDateFormatVars.bat (to get the Date Variables)
:::
:::-- Accepts the following parameters
::: -%1 = path of config file
:::
:::-- format for values in config values
::: ----------------------------------------------------
::: -  cscript,C:\Windows\System32\cscript
::: -  servicesfolder,log files folder must be shared folder eg \\10.10.10.10\Services
::: -  net,C:\Windows\System32\net.exe
::: -  getdate,getDateMinusArg.vbs (get date vbscript)
::: -  login,log files server login eg administrator pass
::: -  errorfilesin,PATHOFFILE#"DISPLAYNAME" e.g. \ServiceSubfolder\logs\#yyyy#-#mm#-#dd#\error.log:"Something Generator Service on #yyyy#-#mm#-#dd#" 
::: - 				NOTE: PATHOFFILE can also have #STAR#
::: -  notation,^<notation^> (after this notation is the JSON array)
:::
:::-- How to call
::: ----------------------------------------------------
::: - checkLogFileExists.bat configfile.config
:::
:::-- Output 
::: ----------------------------------------------------
::: - JSON file with array of [{"name":"DISPLAYNAME", "value":"ERRORS/OK"}]

::: change directory ***************************CHANGE
::: cd C:\code\win-checks-bats

::: get config values
call getConfigValues.bat %1

:::Get date
call getDateFormatVars.bat

%_net% use "%_servicesfolder%" /user:%_login%

::: replace date formats
SET _errorfilesin=%_errorfilesin:#dd#=!dd!%
SET _errorfilesin=%_errorfilesin:#mm#=!mm!%
SET _errorfilesin=%_errorfilesin:#yyyy#=!yyyy!%
SET _errorfilesin=%_errorfilesin:#yy#=!yy!%
SET _errorfilesin=%_errorfilesin:#dd1#=!dd1!%
SET _errorfilesin=%_errorfilesin:#mm1#=!mm1!%
SET _errorfilesin=%_errorfilesin:#yyyy1#=!yyyy1!%
SET _errorfilesin=%_errorfilesin:#yy1#=!yy1!%
SET _errorfilesin=%_errorfilesin:#_d#=!_d!%
SET _errorfilesin=%_errorfilesin:#_m#=!_m!%
SET _errorfilesin=%_errorfilesin:#_d1#=!_d1!%
SET _errorfilesin=%_errorfilesin:#_m1#=!_m1!%

set _errorfiles=%_errorfilesin% 

::: Initialize output file 
SET _outJSON=[

::: For all the error files
FOR %%A IN (%_errorfiles%) DO (	
	IF !_hasRecords! EQU 1 (SET _outJSON=!_outJSON! ^,)	
	set _hasRecords=1
	::: get name and errorfile
	for /F "tokens=1,2 delims=:" %%K IN ("%%A") DO (
		SET _errorfile=%%K
		SET _name=%%L
		::: handle star #STAR# in find
		SET _errorfile=!_errorfile:#STAR#=*!
		::: remove double quotes
		set _name=!_name:"=!
		::: remove tabs
		set _name=!_name:	=!
	)	
	set _jsonfriendlyfilepath=%_servicesfolder%!_errorfile!
	set _jsonfriendlyfilepath=!_jsonfriendlyfilepath:\=\\!
	IF EXIST "%_servicesfolder%!_errorfile!" (
		SET _outJSON=!_outJSON! {"name":"!_name!","value":"ERRORS"}
	) ELSE (
		SET _outJSON=!_outJSON! {"name":"!_name!","value":"OK"}
	)
)
SET _outJSON=!_outJSON!]
@echo !_notation!
@echo !_outJSON!
ENDLOCAL
:::exit