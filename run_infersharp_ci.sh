#!/bin/bash

# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

set -e

# Check if we have enough arguments.
if [ "$#" -lt 2 ]; then
    echo "run_infersharp.sh <dll_folder_path> <github_sarif> <options - see https://fbinfer.com/docs/man-infer-run#OPTIONS>"
	exit
fi

infer_args=""
github_sarif=$2

if [ "$#" -gt 2 ]; then
    i=3
    while [ $i -le $# ]
    do 		
        if [ ${!i} == "--output-folder" ]; then
            ((i++))
            output_folder=${!i}        
		else
			infer_args+="${!i} "
		fi
        ((i++))
    done
fi

echo "Processing {$1}"
# Preparation
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"
if [ -d infer-staging ]; then rm -Rf infer-staging; fi

echo -e "Copying binaries to a staging folder...\n"
cp -r "$1" infer-staging

# Run InferSharp analysis.
echo -e "Code translation started..."
/./infersharp/Cilsil/Cilsil translate infer-staging --outcfg infer-staging/cfg.json --outtenv infer-staging/tenv.json --cfgtxt infer-staging/cfg.txt --extprogress
echo -e "Code translation completed. Analyzing...\n"
infer run $infer_args --cfg-json infer-staging/cfg.json --tenv-json infer-staging/tenv.json

if [ "$output_folder" != "" ]; then
    if [ ! -d "$output_folder" ]; then
        mkdir "$output_folder"
    fi

    cp infer-out/report.sarif infer-out/report.txt $output_folder/
    if [ ${github_sarif,,} == 'true' ]; then
        ## Replace "startColumn": 0 with "startColumn": 1
        sed -i.backup 's/\"startColumn\":0/\"startColumn\":1/g' $output_folder/report.sarif
    fi
    echo -e "\nFull reports available at '$output_folder'\n"
fi