@ECHO OFF
::: For each configuration in the input file use a different line
::: use configuration name the , "comma" and then value
::: In the case of tablesisreadcheck seperate each table name with a space
::: In the case of emailrecepient seperate each email address with ;
FOR /F "tokens=1,2 delims=," %%G IN (%1) DO (
SET _%%G=%%H
)
:::Replace ; with ,
set _emailrecepient=%_emailrecepient:;=,%

goto:eof
