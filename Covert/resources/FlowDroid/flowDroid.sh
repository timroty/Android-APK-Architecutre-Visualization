#!/bin/bash
clear
repo_class="$1"
appRepo="../app_repo/$repo_class"
output="../$appRepo/analysis/flow"
performanceResult="$output/performance.csv"
adt=$(pwd)/../AndroidPlatforms
params="--nopaths --aplength 3  --nostatic --aliasflowins --layoutmode none"
#default_params="--nopaths --nostatic --aplength 1 --aliasflowins --nocallbacks --layoutmode none"

rm -rf "$output"/* 
mkdir -p "$output"
cd resources
for file in ../../"$appRepo"/*.apk
do
	reverseDir="${file%.*}"
	IFS='/ ' read -a fileName <<< "$reverseDir"	
	START=$(date +%s)
	java -Xmx8G -cp soot.jar:soot-infoflow.jar:soot-infoflow-android.jar:slf4j-api-1.7.5.jar:slf4j-simple-1.7.5.jar:axml-1.0.jar soot.jimple.infoflow.android.TestApps.Test "$file" "$adt"  $params> "../$output/${fileName[5]}.txt"
	END=$(date +%s)
	DIFF=$(( $END - $START ))
	printf "%s,%s\n" "${fileName[4]}" "$DIFF" >> ../$performanceResult
done
