strtoday = Now - WScript.Arguments(0)
yr = Year(strtoday)
mth = Month(strtoday)
dy = Day(strtoday)
If Len(mth) <2 Then 
	mth="0"&mth
End If
If Len(dy) <2 Then 
	dy="0"&dy
End If
thedate = dy&"/"&mth&"/"&yr
WScript.Echo thedate