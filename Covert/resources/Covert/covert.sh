#!/bin/bash
clear
mode="$1" # model | flow | dsl | dsl2 | cfg | solver | policy
repo_class="$2"
opt="$3"
filter_type="NO_FILTER" 
appRepo="../app_repo/$repo_class"
output="../$appRepo/analysis/"
extractionOutput=$output/model
mergedOutput=$output/merged
alloyResult=$output/dsl
cfgResult=$output/graph
solverResult=$output/alloy_solutions
performanceResult=$output/performance.csv
flowOutput=$output/flow
map="prmMapping/jellybean_allmappings.txt,prmMapping/jellybean_intentpermissions.txt"
domainMap="resources/prmMapping/prmDomains.txt"
apiMap="resources/prmMapping/jellybean_allmappings.txt"
sensitivefilter="resources/filters"
tmpl="resources/templates"
adt=$(pwd)/../AndroidPlatforms

if [ "$#" -lt 2 ]; then
    echo "Illegal number of parameters: 1:mode (model|flow|dsl|dsl2) 2:repository name"
    exit;
fi

#Generating Model from APK Files
if [ "$mode" = "model" ];then
	export ANDROID_HOME=$adt
	mkdir -p "$extractionOutput"
	rm -rf "$extractionOutput"/*
	rm -f "$performanceResult"
	cd resources
	for file in ../../"$appRepo"/*.apk
	do
		reverseDir="${file%.*}"
		reverseDir="${reverseDir//./_}"
		reverseDir="${reverseDir/_/.}"
		IFS='/ ' read -a fileName <<< "$reverseDir"	
		#apktool/apktool -q d "$file" ../../"$appRepo/reverse/${fileName[5]}" 
		START=$(date +%s)
		java -Xmx10G -jar covert.jar -mode analyzer2 -in "$file" -out ../"$extractionOutput" -map ../"$domainMap" -map_api ../"$apiMap"
		END=$(date +%s)
		DIFF=$(( $END - $START ))
		if [ "$opt" = "performance" ];then
			SMALI_FILES=$(find ../../"$appRepo/reverse/${fileName[4]}"/smali -type f -name *.smali)
			declare -i TOTAL_LOC=0
			for SMALI in $SMALI_FILES
			do
				NUMOFLINES=$(wc -l < "$SMALI")
				TOTAL_LOC=$TOTAL_LOC+$NUMOFLINES
			done
			printf "%s,%s,%s\n" "${fileName[4]}" "$TOTAL_LOC" "$DIFF" >> ../$performanceResult
		fi
	done

#Merging models with flow analysis results
elif [ "$mode" = "flow" ];then
	mkdir -p "$mergedOutput"
	rm -rf "$mergedOutput"/* 
	java -Xmx8G -jar resources/covert.jar -mode flow -in "$extractionOutput" -out "$mergedOutput" -flow "$flowOutput" -filter "$sensitivefilter" -map "$domainMap"


#Generating DSL from the models
elif [ "$mode" = "dsl" ] || [ "$mode" = "dsl2" ];then
	mkdir -p "$alloyResult"
	rm -rf "$alloyResult"/* 
	cp ./resources/alloy/androidDeclaration.als ./"$alloyResult"/androidDeclaration.als
	if [ "$mode" = "dsl" ];then
		java -Xmx8G -jar resources/covert.jar -mode composer -in "$extractionOutput" -out "$alloyResult" -filter n
	else
		java -Xmx8G -jar resources/covert.jar -mode t_composer2 -in "$mergedOutput" -out "$alloyResult" -templates "$tmpl" -filter "$filter_type"
	fi

#Merging models with flow analysis results
elif [ "$mode" = "cfg" ];then
	mkdir -p "$cfgResult"
	rm -rf "$cfgResult"/*
	cd resources
	java -Xmx8G -jar covert.jar -mode cgg -in ../"$extractionOutput" -out ../"$cfgResult" -map "$map"

#Generating alloy results
elif [ "$mode" = "solver" ];then
	mkdir -p "$solverResult"
	rm -rf "$solverResult"/*
	cd resources
	java -Xmx8G -jar covert.jar -mode solver -in ../"$alloyResult"/ICC.als -out ../"$solverResult"

#Generating policies
elif [ "$mode" = "policy" ];then
	rm -rf "$solverResult"/Policy.xml
	cd resources
	java -Xmx8G -jar covert.jar -mode policy -in ../"$solverResult" -out ../../$appRepo

else
	echo "Invalid args"
fi

