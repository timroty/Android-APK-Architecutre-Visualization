@echo off
cls

IF NOT [%2] == [] cd %2

cd resources\FlowDroid
echo "Flow analysis ..."
CALL flowDroid.bat %1 >nul 2>&1

cd ..\Client
echo "Decompiling apk files ..."
CALL decompiler.bat %1 >nul 2>&1

IF NOT [%2] == [] exit

cd ..\Covert
echo "Extracting apk models ..."
CALL covert.bat model %1 >nul 2>&1
echo "Merging apk models ..."
CALL covert.bat flow %1 >nul 2>&1
echo "Generating formal models ..."
CALL covert.bat dsl2 %1 >nul 2>&1
echo "Solving formal models ..."
CALL covert.bat solver %1 >nul 2>&1
echo "Generating vulnerability models ..."
CALL covert.bat policy %1 >nul 2>&1

cd ..\..\
SET result=%CD%\app_repo\%1\%1.xml
echo Analysis Finished. & echo.Detected vulnerabilities are listed in %result%
