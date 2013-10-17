:::--------------------------------------------------------
:::-- Function to get the date format vars
:::
:::-- Prerequisite: call getConfigValues
:::--------------------------------------------------------
@ECHO OFF

:::Get date
FOR /F %%i IN ('%_cscript% "%_getdate%" 0 //nologo') do set MYDATE=%%i
FOR /F %%i IN ('%_cscript% "%_getdate%" 1 //nologo') do set MYYESTDATE=%%i

::Perform date manipulations and set values
SET dd=%MYDATE:~0,2%
SET mm=%MYDATE:~3,2%
SET yyyy=%MYDATE:~6,4%
SET yy=%MYDATE:~8,2%
SET dd1=%MYYESTDATE:~0,2%%
SET mm1=%MYYESTDATE:~3,2%
SET yyyy1=%MYYESTDATE:~6,4%
SET yy1=%MYYESTDATE:~8,2%
::: Arithmetic values used a trick since leading 0 means octal 
SET /a _d=10%dd%-1000
SET /a _m=10%mm%-1000
SET /a _d1=10%dd1%-1000
SET /a _m1=10%mm1%-1000