@echo off
setlocal enabledelayedexpansion
cls

SET appRepo=..\app_repo\%1
SET output=..\%appRepo%\analysis\flow
SET argC=0
for %%x in (%*) do Set /A argC+=1
IF %argC% NEQ 1 (
    echo "Illegal number of parameters"
    exit;
)
if exist %output% rmdir /Q /S %output%
mkdir %output%
cd resources

set CLASSPATH=.
set CLASSPATH=%CLASSPATH%;soot.jar;soot-infoflow.jar;soot-infoflow-android.jar;slf4j-api-1.7.5.jar;slf4j-simple-1.7.5.jar;axml-1.0.jar

for /f %%f in ('dir /b /s ..\..\%appRepo%\*.apk') do (
	java -Xmx8G soot.jimple.infoflow.android.TestApps.Test %%f ..\..\AndroidPlatforms --nopaths --aplength 3  --nostatic --aliasflowins --layoutmode none > ..\%output%\%%~nf.txt
)
