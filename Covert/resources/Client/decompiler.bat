@echo off
setlocal enabledelayedexpansion
cls

SET appRepo=..\app_repo\%1
cd resources/AndroidDecompiler


for /f %%f in ('dir /b /s ..\..\..\%appRepo%\*.apk') do (
	SET folder=..\..\..\%appRepo%\source\%%~nf
	if exist !folder! rmdir /Q /S !folder!
	mkdir !folder!
	CALL ./dex2jar/d2j-dex2jar.bat -o !folder!/output.jar %%f
	CALL java -Djava.library.path=.\jd-intellij\src\main\native\nativelib\win32\x86_64 -jar .\jd-core-java\jd-core-java-1.2.jar !folder!\output.jar !folder!\src
	del !folder!\output.jar
)
