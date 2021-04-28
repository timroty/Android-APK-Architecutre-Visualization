#!/bin/bash
clear
if [ ! -z "$2" ];then
	cd $2
fi
cd resources
cd FlowDroid
echo "Flow analysis ..."
./flowDroid.sh $1 &> /dev/null
cd ..
cd Client
echo "Decompiling apk files ..."
./decompiler.sh $1 &> /dev/null
if [ ! -z "$2" ];then
	exit;
fi
cd ..
cd Covert
echo "Extracting apk models ..."
./covert.sh model $1 &> /dev/null
echo "Merging apk models ..."
./covert.sh flow $1 &> /dev/null
echo "Generating formal models ..."
./covert.sh dsl2 $1 &> /dev/null
echo "Solving formal models ..."
./covert.sh solver $1 &> /dev/null
echo "Generating vulnerability models ..."
./covert.sh policy $1 &> /dev/null
cd ../../
result=$(pwd)/app_repo/$1/$1.xml
echo -e 'Analysis Finished.\nDetected vulnerabilities are listed in' $result
