@echo off
setlocal enabledelayedexpansion
cls

SET appRepo=..\app_repo\%2
SET output=..\%appRepo%\analysis
SET flowOutput=%output%\flow
SET extractionOutput=%output%\model
SET mergedOutput=%output%\merged
SET alloyResult=%output%\dsl
SET solverResult=%output%\alloy_solutions

SET argC=0
for %%x in (%*) do Set /A argC+=1
IF %argC% LSS 2 (
    echo "Illegal number of parameters: 1:mode (model|flow|dsl|dsl2) 2:repository name"
    exit;
)

SET ANDROID_HOME=%CD%\..\AndroidPlatforms

rem Generating Model from APK Files
IF "%1"=="model" (
	if exist %extractionOutput% rmdir /Q /S %extractionOutput%
	mkdir %extractionOutput%
	cd resources
	for /f %%f in ('dir /b /s ..\..\%appRepo%\*.apk') do (
		SET tmp=%%~nf
		SET filename=!tmp:.=_!
		echo !filename!
		CALL apktool_win\apktool.bat d --no-src -q -f -o ..\..\%appRepo%\reverse\!filename! %%f 
		java -Xmx8G -jar covert.jar -mode analyzer2 -in %%f -out ..\%extractionOutput% -map .\prmMapping\prmDomains.txt
	)
)

rem Merging models with flow analysis results
IF "%1"=="flow" (
	if exist %mergedOutput% rmdir /Q /S %mergedOutput%
	mkdir %mergedOutput%
	java -Xmx8G -jar resources\covert.jar -mode flow -in %extractionOutput% -out %mergedOutput% -flow %flowOutput%  -filter .\resources\filters -map .\resources\prmMapping\prmDomains.txt
)


rem Generating DSL from the models
IF "%1"=="dsl2" (
	if exist %alloyResult% rmdir /Q /S %alloyResult%
	mkdir %alloyResult%
	copy .\resources\alloy\androidDeclaration.als %alloyResult%\androidDeclaration.als
	java -Xmx8G -jar resources\covert.jar -mode t_composer2 -in %mergedOutput% -out %alloyResult% -templates .\resources\templates -filter NO_FILTER
)

rem Generating alloy results
IF "%1"=="solver" (
	if exist %solverResult% rmdir /Q /S %solverResult%
	mkdir %solverResult%
	java -Xmx8G -jar resources\covert.jar -mode solver -in %alloyResult%\ICC.als -out %solverResult%
)

rem Generating policies
IF "%1"=="policy" (
	IF EXIST ..\%appRepo%\%2.xml DEL /F ..\%appRepo%\%2.xml
	java -Xmx8G -jar resources\covert.jar -mode policy -in %solverResult% -out ../%appRepo%
)