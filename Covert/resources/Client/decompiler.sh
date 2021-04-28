#!/bin/bash
clear
repo_class="$1"
appRepo="../../app_repo/$repo_class"
cd resources/AndroidDecompiler
for file in ../../"$appRepo"/*.apk
do
  	reverseDir="${file%.*}"
	IFS='/ ' read -a array <<< "$reverseDir"	
	./decompileAPK.sh --output ../../$appRepo/source/${array[6]} $file
	#./decompileAPK.sh --skipResources --output ../../$appRepo/source/${array[6]} $file
done
