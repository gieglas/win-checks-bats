@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

:::-- Checks the size of network space JSON array 
:::
:::-- Prerequisites, Dependencies: 
::: -	parameter (config file)
::: -	getDateMinusArg.vbs (to get the CORRECT date)
:::
:::-- Accepts the following parameters
::: -%1 = path of config file
:::
:::-- format for values in config file 
::: ----------------------------------------------------
::: - cscript,C:\Windows\System32\cscript
::: - net,C:\Windows\System32\net.exe
::: - getdate,..\scripts\getDateMinusArg.vbs (get date vbscript)
::: - checkdisksizepaths,PATHOFSHAREDFOLDER:USERNAME:PASSWORD:TEMPDRIVE#DISPLAYNAME eg\\10.10.10.10\temp:10.10.10.10\administrator:pass:o#10.10.10.10
::: - notation,^<notation^> (after this notation is the JSON array)
:::
:::-- How to call
::: ----------------------------------------------------
::: - checkNetworkDiskSpace.bat configfile.config
:::
:::-- Output 
::: ----------------------------------------------------
::: - JSON file with array of [{"name":"DISPLAYNAME", "value":"SIZEinBytes"},...] after the notation ^<notation^>

::: change directory ***************************CHANGE
::: cd C:\code\win-checks-bats

::: get config values
call getConfigValues.bat %1

:::Get date
FOR /F %%i IN ('%_cscript% "%_getdate%" 0 //nologo') do set MYDATE=%%i

::: json file
set _outJSON=s[

FOR %%A IN (%_checkdisksizepaths%) DO (
	::: Initialize vars
	set _checkDiskSizeIndicator=0
	set _checkDiskSizeValue=0
	set _pname=''
	set _ppath=''
	::: get values
	call:checkDiscSpace %%A %_checkdisksizelimit%	
	::: json file	
	set _outJSON=!_outJSON! {"name":"!_pname! at %MYDATE% %TIME:~0,5%","value":!_checkDiskSizeValue!},
)
::: json file
SET _outJSON=%_outJSON:~1,-1%
set _outJSON=%_outJSON%]

@echo !_notation!
@echo %_outJSON%
goto:eof

:checkDiscSpace  
:::--------------------------------------------------------
:::-- Function get the free disk space in bytes
:::
:::-- Prerequisite: parameter
:::
:::-- Accepts the following parameters
::: -%1 = path
:::
:::-- returns variable _checkDiskSizeValue the value size
:::--
:::--------------------------------------------------------
set _p=%~1
set _puser=0
set _ppass=0
set _pletter=0
set /a _plimit=%~2
FOR /F "tokens=1,2 delims=#" %%G IN ("!_p!") DO (	
	SET _pname=%%H
	SET _ppath=%%G	
	for /F "tokens=1-4 delims=:" %%K IN ("!_ppath!") DO (
		set _ppath=%%K
		set _puser=%%L
		set _ppass=%%M		
		set _pletter=%%N
	)
)
IF !_puser! NEQ 0 (
	%_net% use "!_ppath!" /user:!_puser! !_ppass!
)
for /f "tokens=3" %%x in ('dir %_ppath%') do (		
	:::get size
	set size=%%x
	::: clear comma
	set size=!size:.=!
	::: clear period
	set size=!size:,=!
	set _checkDiskSizeValue=!size!
)

goto:eof
ENDLOCAL
:::exit

