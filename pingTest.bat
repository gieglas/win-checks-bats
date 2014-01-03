@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

:::-- Performs ping on the IPs given and returns a JSON array 
:::
:::-- Prerequisites, Dependencies:  
::: -	parameter (config file)
::: -	getDateMinusArg.vbs (to get the CORRECT date)
:::
:::-- Accepts the following parameters
::: -%0 = IPs for ping test
:::
:::-- format for values in config values
::: ----------------------------------------------------
::: -  _cscript=C:\Windows\System32\cscript
::: -  _ping=C:\Windows\System32\ping
::: -  _getdate=getDateMinusArg.vbs (get date vbscript)
::: -  _notation=^<notation^> (after this notation is the JSON array)
:::
:::-- How to call
::: ----------------------------------------------------
::: - pingTest.bat 10.10.10.10 10.10.10.11
:::
:::-- Output 
::: ----------------------------------------------------
::: - JSON file with array of ^<notation^>[{"name":"DISPLAYNAME", "value":"YES/NO"}]

set _ping=C:\Windows\System32\ping
set _cscript=C:\Windows\System32\cscript
set _getdate=getDateMinusArg.vbs
set _notation=^<notation^>

::: change directory ***************************CHANGE
::: cd C:\code\win-checks-bats


set _hasRecords=0
set _dateTime=%date% %time%
FOR /F %%i IN ('%_cscript% "%_getdate%" 0 //nologo') do set MYDATE=%%i


::: Initialize output file 
SET _outJSON=[

::: For each server 
FOR %%A IN (%*) DO (
	IF !_hasRecords! EQU 1 (SET _outJSON=!_outJSON! ^,)
	set /a _hasRecords=1

	%_ping% -n 1 %%A 		
	:::check for error on ping
	if errorlevel 1 (
		set _checkNetworkIndicator=1
		SET _outJSON=!_outJSON! {"name":"%%A at %MYDATE% %TIME:~0,5%","value":"NO"}
		
	) else 	(
		SET _outJSON=!_outJSON! {"name":"%%A at %MYDATE% %TIME:~0,5%","value":"YES"}
	)
	
)

SET _outJSON=!_outJSON!]

@echo !_notation!
@echo !_outJSON!